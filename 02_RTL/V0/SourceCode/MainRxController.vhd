
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use work.SysLib.ALL;
use work.DSPLib.ALL;

entity MainRxController is
	port(
	
		iClk : in std_logic; --165M clk
		iRst : in std_logic := '0';
		
		--control
		iStart : in std_logic := '0'; --start signal of chirp, not Rx, delay done inside
		oBusy : out std_logic := '0';
		
		--FFT full-rate tap and capture diagnostics
        oFftValid:out std_logic;oFftValue:out std_logic_vector(15 downto 0);
        oCaptureActive:out std_logic;oRawOverflow,oRawClipped:out std_logic;
        --data output
		oDataCnt : out integer range 0 to 16777215 := 0;
		oNewData : out std_logic := '0';
		oValue : out std_logic_vector(15 downto 0) := x"0000";
		
		--parameters
		iTc : in std_logic_vector(31 downto 0) := x"3c23d70a"; --time duration for chirp, F32, s, def = 0.01
		iTd : in std_logic_vector(31 downto 0) := x"3a83126f"; --delay time for sampling after chirp start, F32, s, def = 0.001
		iDownSampleRate : in integer range 0 to 65535 := 0;
		iDataResolution : in integer range 0 to 31 := 16;
		oSamplingPeriod : out std_logic_vector(31 downto 0) := (others => '0'); --interval between two output data, F32, s
		
		--mux control
		iMuxSel : in std_logic_vector(2 downto 0) := "000"; --bit 2 for FLT, 1 downto 0 for gain. 000 for div 1 no flt
		
		--AD interface
		oAD_RST : out std_logic := '1';
		oAD_CS : out std_logic := '1';
		oAD_SCLK : out std_logic := '0';
		oAD_SDI : out std_logic := '0';
		iAD_SDO : in std_logic;
		oAD_START : out std_logic := '1';
		iAD_DRDY : in std_logic;
		oAD_CLK : out std_logic;
		
		--mux
		oRX_MUX_EN : out std_logic := '1';
		oRX_MUX_A : out std_logic_vector(2 downto 0) := "000";
		
		--LED indicators
		oLED_RX_FLT : out std_logic := '0';
		oLED_RX_DIV1 : out std_logic := '0';
		oLED_RX_DIV2 : out std_logic := '0';
		oLED_RX_DIV4 : out std_logic := '0';
		oLED_RX_DIV8 : out std_logic := '0'
	);
end entity MainRxController;

architecture Beh of MainRxController is
	
 component MainAdcBridge is
  generic(RAW_CAPACITY:integer:=131072);
  port(iClk,iRst,iSamplingEn:in std_logic;iDownSampleRate:in std_logic_vector(15 downto 0);
   iADSDO,iADDRdy:in std_logic;oADRstz,oADCSz,oADSClk,oADSDI,oADStart,oADClk:out std_logic;
   oDataCnt:out std_logic_vector(23 downto 0);oNewData:out std_logic;oValue:out std_logic_vector(15 downto 0);
   oFftValid:out std_logic;oFftValue:out std_logic_vector(15 downto 0);oOverflow,oClipped:out std_logic);
 end component;
 signal count_bits:std_logic_vector(23 downto 0);

	
	signal cRst : std_logic := '0';
	
	signal cSamplingEn : std_logic := '1';
	signal cDataMask : std_logic_vector(15 downto 0) := (others => '1');
	
	--parameters padding
	signal cTc : std_logic_vector(31 downto 0);
	signal cTd : std_logic_vector(31 downto 0);
	signal cDownSampleRate : integer range 0 to 65535 := 0;
	signal cDataResolution : integer range 0 to 31 := 16;
	signal cMuxSel : std_logic_vector(2 downto 0) := "000"; 
	
	--parameters to be calculated
	signal cNFloat : std_logic_vector(31 downto 0);
	signal cNIntPipe,cTdNIntPipe:std_logic_vector(31 downto 0):=(others=>'0');
	signal cNCalc,cTdNCalc:integer range 0 to 268435455:=0;
	signal cNInt : std_logic_vector(31 downto 0);
	signal cN : integer range 0 to 268435455 := 0;
	signal cTdNFloat : std_logic_vector(31 downto 0);
	signal cTdNInt : std_logic_vector(31 downto 0);
	signal cTdN : integer range 0 to 268435455 := 0;
	signal cSmpClkNumF : std_logic_vector(31 downto 0);
	
	--data padding
	signal cDataCnt : integer range 0 to 16777215 := 0;
	signal cNewData : std_logic := '0';
	signal cValue : std_logic_vector(15 downto 0) := x"0000";
	
 signal cTick,cDeadline,cPreDelay,cPreWindow:std_logic_vector(27 downto 0):=(others=>'0');

begin

----parameter calculation

	--num of clk cycles N = Tc * fclk
	u0 : FPFMult port map (clk => iClk, areset => cRst, a => cTc, b => DA_CLK_FREQ, q => cNFloat);
	u1 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cNFloat, q => cNInt);
	cNCalc <= 1650 when (cNIntPipe = x"00000000") or (cNIntPipe(31) = '1') else --small val protection, 10us
			268435455 when cNIntPipe(30 downto 28) /= "000" else --big val protection
			conv_integer(cNIntPipe);
			
	--num of Rx delay after chirp start clk cycles TdN = Td * fclk
	u2 : FPFMult port map (clk => iClk, areset => cRst, a => cTd, b => DA_CLK_FREQ, q => cTdNFloat);
	u3 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cTdNFloat, q => cTdNInt);
	cTdNCalc <= 0 when cTdNIntPipe(31)='1' else 268435455 when cTdNIntPipe(30 downto 28) /= "000" else --big val protection
			conv_integer(cTdNIntPipe);
			
	--sample interval
	u4 : FPFInt32ToFP32 port map (clk => iClk, areset => cRst, a => conv_std_logic_vector(cDownSampleRate + 1, 32), q => cSmpClkNumF);
	u5 : FPFMult port map (clk => iClk, areset => cRst, a => cSmpClkNumF, b => AD_PERIOD, q => oSamplingPeriod);
	
	process(iClk)begin if rising_edge(iClk)then cNIntPipe<=cNInt;cTdNIntPipe<=cTdNInt;cN<=cNCalc;cTdN<=cTdNCalc;end if;end process;
	--resolution
	cDataMask <=	"1000000000000000" when cDataResolution = 1 else
						"1100000000000000" when cDataResolution = 2 else
						"1110000000000000" when cDataResolution = 3 else
						"1111000000000000" when cDataResolution = 4 else
						"1111100000000000" when cDataResolution = 5 else
						"1111110000000000" when cDataResolution = 6 else
						"1111111000000000" when cDataResolution = 7 else
						"1111111100000000" when cDataResolution = 8 else
						"1111111110000000" when cDataResolution = 9 else
						"1111111111000000" when cDataResolution = 10 else
						"1111111111100000" when cDataResolution = 11 else
						"1111111111110000" when cDataResolution = 12 else
						"1111111111111000" when cDataResolution = 13 else
						"1111111111111100" when cDataResolution = 14 else
						"1111111111111110" when cDataResolution = 15 else
						"1111111111111111";
----AD controller

	--this AD IP uses synchronized low freq clk according to sampling en signal
	uAD : MainAdcBridge port map (iClk => iClk, iRst => cRst, 
		--control
		iDownSampleRate => conv_std_logic_vector(cDownSampleRate,16), iSamplingEn => cSamplingEn,
		--AD port
		oADRstz => oAD_RST, oADCSz => oAD_CS, oADSClk => oAD_SCLK, oADSDI => oAD_SDI, iADSDO => iAD_SDO,
		oADStart => oAD_START, iADDRdy => iAD_DRDY, oADClk => oAD_CLK, 
		--data port
		oDataCnt => count_bits, oNewData => cNewData, oValue => cValue,
  oFftValid=>oFftValid,oFftValue=>oFftValue,oOverflow=>oRawOverflow,oClipped=>oRawClipped);
 cDataCnt<=conv_integer(count_bits);oCaptureActive<=cSamplingEn;
		
	
----direct output signals

	oRX_MUX_EN <= '1';
	oRX_MUX_A <= cMuxSel;
	
	oLED_RX_FLT <= cMuxSel(2);
	oLED_RX_DIV1 <= '1' when cMuxSel(1 downto 0) = "00" else '0';
	oLED_RX_DIV2 <= '1' when cMuxSel(1 downto 0) = "01" else '0';
	oLED_RX_DIV4 <= '1' when cMuxSel(1 downto 0) = "10" else '0';
	oLED_RX_DIV8 <= '1' when cMuxSel(1 downto 0) = "11" else '0';
	
 -- Free-running modulo timestamp separates the incrementer from end tests.
 -- Precomputed deadlines compensate one pipeline cycle. RX stays N+1 clocks,
 -- exactly matching the previous enable-window convention, including wrap.
 process(iClk)begin
  if rising_edge(iClk)then
   cTick<=cTick+1;
   cPreDelay<=cTick+conv_std_logic_vector(cTdN,28)+2;
   cPreWindow<=cTick+conv_std_logic_vector(cN,28)+1;
  end if;
 end process;
 process(iClk)
  variable vSmallCnt:integer range 0 to 255:=0;
  variable vState:integer range 0 to 7:=0;
  variable vStart_L1:std_logic:='0';
 begin
  if rising_edge(iClk)then
   oDataCnt<=cDataCnt;oNewData<=cNewData;oValue<=cValue and cDataMask;
   if cRst='1' then
    vSmallCnt:=0;vState:=0;cSamplingEn<='0';oBusy<='0';cDeadline<=(others=>'0');
   else
    case vState is
     when 0 =>
      oBusy<='0';cSamplingEn<='0';cDownSampleRate<=iDownSampleRate;cDataResolution<=iDataResolution;
      cTc<=iTc;cTd<=iTd;cMuxSel<=iMuxSel;
      if iStart='1' and vStart_L1='0' then vSmallCnt:=0;vState:=1;oBusy<='1';end if;
     when 1 =>
      if vSmallCnt=99 then vSmallCnt:=0;cDeadline<=cPreDelay;vState:=2;
      else vSmallCnt:=vSmallCnt+1;end if;
     when 2 => if cTick=cDeadline then vState:=3;end if;
     when 3 => cSamplingEn<='1';cDeadline<=cPreWindow;vState:=5;
     when 5 => if cTick=cDeadline then vSmallCnt:=0;vState:=4;end if;
     when 4 =>
      cSamplingEn<='0';
      if vSmallCnt=255 then vSmallCnt:=0;vState:=0;else vSmallCnt:=vSmallCnt+1;end if;
     when others => vState:=0;
    end case;
   end if;
   vStart_L1:=iStart;cRst<=iRst;
  end if;
 end process;
end architecture Beh;
