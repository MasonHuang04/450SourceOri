-- Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

-- BEGIN_SOURCE: UARTController.vhd

library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;

entity UARTController is
	port(
		iClk : in std_logic; --165M clk
		iRst : in std_logic;
		
		--UART pins, 6M Buad Rate
		iRx : in std_logic;
		oTx : out std_logic := '1';
		
		oRxDataValid : out std_logic := '0';
		oRxData : out std_logic_vector(7 downto 0);
		
		oTxBusy : out std_logic := '0';
		iTxDataValid : in std_logic := '0';
		iTxData : in std_logic_vector(7 downto 0)
	);
end entity UARTController;

architecture Beh of UARTController is
	
begin


	process(iClk, iRst)
	
		variable vRx_L1 : std_logic := '0';
		variable vRx_L2 : std_logic := '0';
		variable vRx_L3 : std_logic := '0';
		
	
		variable vRxCnt : integer range 0 to 1023 := 0;
		variable vRxData : std_logic_vector(7 downto 0);
		
		variable vTxCnt : integer range 0 to 1023 := 0;
		variable vTxData : std_logic_vector(7 downto 0);
		
		variable vRxDataValid : std_logic := '0';
	
	begin
	
		if iClk'event and iClk = '1' then

			vRxDataValid := '0';
		
			if iRst = '1' then
				vRxCnt := 0;
				vTxCnt := 0;
				oTxBusy <= '0';
			else
			
			
				----------Rx
			
				if vRxCnt = 0 then
					--wait for start bit dropping edge to start count
					if vRx_L2 = '0' and vRx_L3 = '1' then
						--dropping edge of start bit detected, start count
						vRxCnt := 1;
					end if;
				else
				
					--latch data bit @ 1.5, 2.5, 3.5, 4.5....8.5 cycles after start bit edge
					case vRxCnt is

						--165M
						when 124 => vRxData(0) := vRx_L3;
						when 206 => vRxData(1) := vRx_L3;
						when 289 => vRxData(2) := vRx_L3;
						when 371 => vRxData(3) := vRx_L3;
						when 454 => vRxData(4) := vRx_L3;
						when 536 => vRxData(5) := vRx_L3;
						when 619 => vRxData(6) := vRx_L3;
						when 701 => vRxData(7) := vRx_L3;
						
						when others => null;
					end case;
				
					if vRxCnt = 784 then --output @ 9.5 cycle after start bit
						vRxCnt := 0;
						vRxDataValid := '1';
						oRxData <= vRxData;
					else
						vRxCnt := vRxCnt + 1;
					end if;
					
				end if;
				
				
				----------Tx
				
				if vTxCnt = 0 then
					--wait for Tx send, latch data and start to count
					if iTxDataValid = '1' then
						vTxData := iTxData;
						vTxCnt := 1;
						oTx <= '0'; --start bit
						oTxBusy <= '1';
					end if;
					
				else
				
					case vTxCnt is 
						--send @ T * 1 ~ 9 cycles after start bit
						--165M
						when 83 => oTx <= vTxData(0);
						when 165 => oTx <= vTxData(1);
						when 248 => oTx <= vTxData(2);
						when 330 => oTx <= vTxData(3);
						when 413 => oTx <= vTxData(4);
						when 495 => oTx <= vTxData(5);
						when 578 => oTx <= vTxData(6);
						when 660 => oTx <= vTxData(7);
						when 743 => oTx <= '1'; --stop bit
						
						when others => null;
					end case;
					
					--finish @ 10th edge, slightly shorter than 10 cycle to enable loopback
					if vTxCnt = 825 then --165M --275
						vTxCnt := 0;
						oTxBusy <= '0';
					else
						vTxCnt := vTxCnt + 1;
					end if;
				
				end if;
				
			
			end if;
			
			oRxDataValid <= vRxDataValid;
			
			vRx_L3 := vRx_L2;
			vRx_L2 := vRx_L1;
			vRx_L1 := iRx;
		
		end if;
	
	end process;


end architecture Beh;
-- END_SOURCE: UARTController.vhd

-- BEGIN_SOURCE: RxDepack.vhd

library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use Work.SysLib.ALL;

entity RxDepack is
	port(
		iClk : in std_logic;
		iRst : in std_logic;
		
		iRxDataValid : in std_logic := '0';
		iRxData : in std_logic_vector(7 downto 0);
		
		oTrigger : out std_logic := '0';
		oRxPackValid : out std_logic := '0';
		oRxPack : out Bytex56
	);
end entity RxDepack;

architecture Beh of RxDepack is

begin

	process(iClk, iRst)
	
		variable vRxPackValid : std_logic := '0';
		variable vTrigger : std_logic := '0';
		variable vBuffer : Bytex64;
		variable vRxDataValid_L1 : std_logic := '0';
	begin
	
		if iClk'event and iClk = '1' then
		
			vTrigger := '0';
			vRxPackValid := '0';
		
			if iRst = '1' then
				oTrigger <= '0';
			else
			
			
				if vRxDataValid_L1 = '1' then
					if vBuffer(56) = x"00" and vBuffer(57) = x"5A" and vBuffer(58) = x"00" and vBuffer(59) = x"5A" and 
						vBuffer(60) = x"A5" and vBuffer(61) = x"FF" and vBuffer(62) = x"A5" and vBuffer(63) = x"FF" then
						--trigger detection
						vTrigger := '1';
					end if;
						
					if vBuffer(0) = x"00" and vBuffer(1) = x"A5" and vBuffer(2) = x"00" and vBuffer(3) = x"A5" and 
						vBuffer(60) = x"5A" and vBuffer(61) = x"FF" and vBuffer(62) = x"5A" and vBuffer(63) = x"FF" then
						--setting pack detection
						
						vRxPackValid := '1';
						
						for Idx in 0 to 55 loop
							oRxPack(Idx) <= vBuffer(Idx + 4);
						end loop;
						
					end if;
					
				end if;
			
				if iRxDataValid = '1' then
					--shift reg
					for Idx in 0 to 62 loop
						vBuffer(Idx) := vBuffer(Idx + 1);
					end loop;
					vBuffer(63) := iRxData;
				end if;
				
			
			end if;
			
			vRxDataValid_L1 := iRxDataValid;
			
			oTrigger <= vTrigger;
			oRxPackValid <= vRxPackValid;
		
		end if;
	
	end process;
	
end architecture Beh;

-- END_SOURCE: RxDepack.vhd

-- BEGIN_SOURCE: MainRxController.vhd

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

-- END_SOURCE: MainRxController.vhd

-- BEGIN_SOURCE: MainTxPack.vhd

library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use Work.SysLib.ALL;

entity MainTxPack is
	port(
		iClk : in std_logic;
		iRst : in std_logic;
		
		iStart : in std_logic := '0';
		oBusy : out std_logic := '0';
		
		--data input
		iSamplingPeriod : in std_logic_vector(31 downto 0) := (others => '0');
		iDataCnt : in integer range 0 to 16777215 := 0;
		iNewData : in std_logic := '0';
		iValue : in std_logic_vector(15 downto 0) := x"0000";
		
		iTempData : in std_logic_vector(15 downto 0) := x"0000";
		
		--to uart controller
		iTxBusy : in std_logic := '0';
		oTxDataValid : out std_logic := '0';
		oTxData : out std_logic_vector(7 downto 0)
		
	);
end entity MainTxPack;

architecture Beh of MainTxPack is

	component MainWaveFifo
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	signal cFIFOClr : std_logic := '1';
	
	signal cFIFOFull : std_logic := '0';
	signal cFIFOWReq : std_logic := '0';
	signal cFIFOData : std_logic_vector(15 downto 0) := x"0000";
	signal cFIFOEmpty : std_logic := '1';
	signal cFIFORReq : std_logic := '0';
	signal cMetaByte,cTailByte,cBodyByte:std_logic_vector(7 downto 0):=(others=>'0');
	signal cFIFOQ : std_logic_vector(7 downto 0) := x"00";
	
	signal cWriteEn : std_logic := '0';
		
	
begin

	--block filling FIFO if it is full
	cFIFOWReq <= '1' when (cFIFOFull = '0') and (iNewData = '1') and (cWriteEn = '1') else '0';
	cFIFOData <= iValue;

	f1 : MainWaveFifo port map ( aclr => cFIFOClr, 
		--input
		wrclk => iClk, wrfull => cFIFOFull, wrreq => cFIFOWReq, data => cFIFOData, 
		--output
		rdclk => iClk, rdempty => cFIFOEmpty, rdreq => cFIFORReq, q => cFIFOQ);
	

	process(iClk, iRst)
		variable vStart_L1 : std_logic := '0';
		variable vCnt : integer range 0 to 255 := 0;
		variable vState : integer range 0 to 15 := 0;
		variable vDataCnt : std_logic_vector(31 downto 0) := (others => '0');
		variable vSamplingPeriod : std_logic_vector(31 downto 0) := (others => '0');
		variable vTxDataValid : std_logic := '0';
		variable vFIFORReq : std_logic := '0';
		variable vTempData : std_logic_vector(15 downto 0) := (others => '0');
	begin
	
		if iClk'event and iClk = '1' then
            cBodyByte<=cFIFOQ;
            case vCnt is
							when 0 => cMetaByte <= x"00";
							when 1 => cMetaByte <= x"00";
							when 2 => cMetaByte <= x"FF";
							when 3 => cMetaByte <= x"FF";
							when 4 => cMetaByte <= x"00";
							when 5 => cMetaByte <= x"FF";
							when 6 => cMetaByte<=x"5A";
							when 7 => cMetaByte <= x"00";
							
							when 8 => cMetaByte <= vDataCnt(7 downto 0);
							when 9 => cMetaByte <= vDataCnt(15 downto 8);
							when 10 => cMetaByte <= vDataCnt(23 downto 16);
							when 11 => cMetaByte <= vDataCnt(31 downto 24);
							when 12 => cMetaByte <= x"00";
							when 13 => cMetaByte <= x"FF";
							when 14 => cMetaByte <= x"FF";
							when 15 => cMetaByte <= x"00";
							
							when 16 => cMetaByte <= vSamplingPeriod(7 downto 0);
							when 17 => cMetaByte <= vSamplingPeriod(15 downto 8);
							when 18 => cMetaByte <= vSamplingPeriod(23 downto 16);
							when 19 => cMetaByte <= vSamplingPeriod(31 downto 24);
							when 20 => cMetaByte <= x"00";
							when 21 => cMetaByte <= x"FF";
							when 22 => cMetaByte <= x"FF";
							when 23 => cMetaByte <= x"00";
							
							when 24 => cMetaByte <= x"00";
							when 25 => cMetaByte<=x"5A";
							when 26 => cMetaByte <= vTempData(7 downto 0);
							when 27 => cMetaByte <= vTempData(15 downto 8);
							when 28 => cMetaByte <= x"FF";
							when 29 => cMetaByte <= x"FF";
							when 30 => cMetaByte <= x"00";
							when others => cMetaByte <= x"00";
						end case;
case vCnt is
							when 0 => cTailByte <= x"00";
							when 1 => cTailByte <= x"00";
							when 2 => cTailByte <= x"FF";
							when 3 => cTailByte <= x"FF";
							when 4 => cTailByte <= x"00";
							when 5 => cTailByte <= x"FF";
							when 6 => cTailByte<=x"A5";
							when 7 => cTailByte <= x"00";
							
							when 8 => cTailByte <= vDataCnt(7 downto 0);
							when 9 => cTailByte <= vDataCnt(15 downto 8);
							when 10 => cTailByte <= vDataCnt(23 downto 16);
							when 11 => cTailByte <= vDataCnt(31 downto 24);
							when 12 => cTailByte <= x"00";
							when 13 => cTailByte <= x"FF";
							when 14 => cTailByte <= x"FF";
							when 15 => cTailByte <= x"00";
							
							when 16 => cTailByte <= vSamplingPeriod(7 downto 0);
							when 17 => cTailByte <= vSamplingPeriod(15 downto 8);
							when 18 => cTailByte <= vSamplingPeriod(23 downto 16);
							when 19 => cTailByte <= vSamplingPeriod(31 downto 24);
							when 20 => cTailByte <= x"00";
							when 21 => cTailByte <= x"FF";
							when 22 => cTailByte <= x"FF";
							when 23 => cTailByte <= x"00";
							
							when 24 => cTailByte <= x"00";
							when 25 => cTailByte<=x"A5";
							when 26 => cTailByte <= vTempData(7 downto 0);
							when 27 => cTailByte <= vTempData(15 downto 8);
							when 28 => cTailByte <= x"FF";
							when 29 => cTailByte <= x"FF";
							when 30 => cTailByte <= x"00";
							when others => cTailByte <= x"00";
						end case;
		
			vTxDataValid := '0';
			vFIFORReq := '0';
			
			if iRst = '1' then
				cFIFOClr <= '1';
				cFIFORReq <= '0';
				cWriteEn <= '0';
				vCnt := 0;
				vState := 0;
				oBusy <= '0';
			else
			
				if vState = 0 then
					--release clr, fill FIFO and wait for start
					cFIFOClr <= '0';
					cWriteEn <= '1';
					oBusy <= '0';
					
					if iStart = '1' and vStart_L1 = '0' then
						--rising edge of start, stop fill FIFO, start to send
						vDataCnt := conv_std_logic_vector(iDataCnt, 32);
						vSamplingPeriod := iSamplingPeriod;
						vTempData := iTempData;
						cWriteEn <= '0';
						vCnt := 0;
						oBusy <= '1';
						vState := 1;
					end if;
					
				elsif vState = 1 then
					--wait Tx idle, and send byte
					if iTxBusy = '0' then
					
						--send 32 byte pack head
						vTxDataValid := '1';
						
						oTxData <= cMetaByte;
						
						vState := 2;
					end if;
						
				elsif vState = 2 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--check head send finish
						if vCnt = 31 then
							--finish head
							vCnt := 0;
							vState := 3;
						else
							--send next byte
							vCnt := vCnt + 1;
							vState := 1;
						end if;
					end if;
					
				elsif vState = 3 then
					--check FIFO empty and read
					if cFIFOEmpty = '0' then
						--read one byte
						vFIFORReq := '1';
						vState := 4;
					else
						--FIFO empty, body send end
                        cFIFOClr<='1'; --reclaim the complete main frame before the next capture
						vState := 7;
					end if;
					
				elsif vState = 4 then
					--dummy for FIFO latency
					vState := 9;
					
				elsif vState = 9 then
                    vState := 10; --banked frame buffer read pipeline
                elsif vState=10 then vState:=11;
                elsif vState=11 then vState:=12;
                elsif vState=12 then vState:=13;
                elsif vState=13 then vState:=14;
                elsif vState=14 then vState:=5;
                elsif vState = 5 then
					--wait Tx idle and send byte
					if iTxBusy = '0' then
						vTxDataValid := '1';
						oTxData <= cBodyByte;
						vState := 6;
					end if;
					
				elsif vState = 6 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--goto next byte
						vState := 3;
					end if;
					
				elsif vState = 7 then
					--send pack tail
					if iTxBusy = '0' then
					
						--send 32 byte pack tail
						vTxDataValid := '1';
						
						oTxData <= cTailByte;
						
						vState := 8;
					end if;
						
				elsif vState = 8 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--check tail send finish
						if vCnt = 31 then
							--finish tail
							vCnt := 0;
							vState := 0;
						else
							--send next byte
							vCnt := vCnt + 1;
							vState := 7;
						end if;
					end if;
						
				end if;--end of state machine
			
			end if;--end of rst
			
			cFIFORReq <= vFIFORReq;
			oTxDataValid <= vTxDataValid;
			
			vStart_L1 := iStart;
		end if; --end of clk
	
	end process;
	
end architecture Beh;

-- END_SOURCE: MainTxPack.vhd

-- BEGIN_SOURCE: MainTMP117Controller.vhd

library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;

entity MainTMP117Controller is
	port(
		iClk : in std_logic; --PCLK freq
		iRst : in std_logic;
		
		iAddr : in std_logic_vector(7 downto 0) := x"48";
		
		oDataValid : out std_logic := '0';
        oUpdated : out std_logic := '0';
		oTempData : out std_logic_vector(15 downto 0) := x"0000";
		
		
		oTmp_SCL : out std_logic := '1';
		ioTmp_SDA : inout std_logic := 'Z'
	);
end entity MainTMP117Controller;

architecture Beh of MainTMP117Controller is
	
begin


	process(iClk, iRst)
	
		variable vAddr : std_logic_vector(7 downto 0) := x"48";
	
		variable vState : integer range 0 to 15 := 0;
		variable vClkCnt : integer range 0 to 127 := 0;
		variable vWaitCnt : integer range 0 to 1023 := 0;
	
		variable vCycle : integer range 0 to 3 := 0;
		variable vPeriod : integer range 0 to 31 := 0;
		variable vTempData : std_logic_vector(15 downto 0) := (others => '0');
		variable vDataValid : std_logic := '0';
	begin
	
		--update at falling edge
		if iClk'event and iClk = '1' then
            oUpdated <= '0';

		
			if iRst = '1' then
				vState := 0;
				vClkCnt := 0;
				oTmp_SCL <= '1';
				ioTmp_SDA <= 'Z';
				oTempData <= x"0000";
				vWaitCnt := 0;
				vDataValid := '0';
				oDataValid <= '0';
			else
			
				if vClkCnt = 127 then --165MHz /128 /4 = 322.266kHz; TMP117 max 400kHz
					vClkCnt := 0;
					--quad SCL freq
					
					if vState = 0 then
						--delay for start
						oTmp_SCL <= '1';
						ioTmp_SDA <= 'Z';
						
						vAddr := iAddr;
						
						if vWaitCnt < 1023 then
							vWaitCnt := vWaitCnt + 1;
						else
							vWaitCnt := 0;
							vState := 1;
						end if;
						
					elsif vState = 1 then
						--Send Start, prepare
						oTmp_SCL <= '1';
						ioTmp_SDA <= '0';
						vState := 2;
						vCycle := 0;
						vPeriod := 0;
						
					elsif vState = 2 then
						--Communication
						if vCycle = 0 then
							--Dropping of SCL
							vCycle := 1;
						
							oTmp_SCL <= '0';
						
						elsif vCycle = 1 then
							--Output of SDA
							vCycle := 2;
							
							case vPeriod is
							
								--slave address
								when 0 	=> if vAddr(6)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 1 	=> if vAddr(5)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 2 	=> if vAddr(4)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 3 	=> if vAddr(3)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 4 	=> if vAddr(2)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 5 	=> if vAddr(1)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 6 	=> if vAddr(0)='0' then ioTmp_SDA<='0';else ioTmp_SDA<='Z';end if;
								when 7 	=> ioTmp_SDA <= 'Z'; --read, open drain
								when 8 	=> ioTmp_SDA <= 'Z'; --slave ack
								
								--data H
								when 9 	=> ioTmp_SDA <= 'Z';
								when 10 	=> ioTmp_SDA <= 'Z';
								when 11 	=> ioTmp_SDA <= 'Z';
								when 12 	=> ioTmp_SDA <= 'Z';
								when 13 	=> ioTmp_SDA <= 'Z';
								when 14 	=> ioTmp_SDA <= 'Z';
								when 15 	=> ioTmp_SDA <= 'Z';
								when 16 	=> ioTmp_SDA <= 'Z';
								when 17 	=> ioTmp_SDA <= '0'; --master ack
								
								--data L
								when 18 	=> ioTmp_SDA <= 'Z';
								when 19 	=> ioTmp_SDA <= 'Z';
								when 20 	=> ioTmp_SDA <= 'Z';
								when 21 	=> ioTmp_SDA <= 'Z';
								when 22 	=> ioTmp_SDA <= 'Z';
								when 23 	=> ioTmp_SDA <= 'Z';
								when 24 	=> ioTmp_SDA <= 'Z';
								when 25 	=> ioTmp_SDA <= 'Z';
								when 26 	=> ioTmp_SDA <= 'Z'; --master NACK ends the two-byte read
								
								--stop
								when 27 	=> ioTmp_SDA <= '0'; --master ack
								
								when others => null;
							end case;
							
						elsif vCycle = 2 then
							--Rising of SCL
							vCycle := 3;
							
							oTmp_SCL <= '1';
							
						else
							--Read SDA, check end
							vCycle := 0;						
							
							case vPeriod is
								when 8 	=> vDataValid := not ioTmp_SDA;
								when 9 	=> vTempData(15) := ioTmp_SDA;
								when 10 	=> vTempData(14) := ioTmp_SDA;
								when 11 	=> vTempData(13) := ioTmp_SDA;
								when 12 	=> vTempData(12) := ioTmp_SDA;
								when 13 	=> vTempData(11) := ioTmp_SDA;
								when 14 	=> vTempData(10) := ioTmp_SDA;
								when 15 	=> vTempData(9) := ioTmp_SDA;
								when 16 	=> vTempData(8) := ioTmp_SDA;
								when 18 	=> vTempData(7) := ioTmp_SDA;
								when 19 	=> vTempData(6) := ioTmp_SDA;
								when 20 	=> vTempData(5) := ioTmp_SDA;
								when 21 	=> vTempData(4) := ioTmp_SDA;
								when 22 	=> vTempData(3) := ioTmp_SDA;
								when 23 	=> vTempData(2) := ioTmp_SDA;
								when 24 	=> vTempData(1) := ioTmp_SDA;
								when 25 	=> vTempData(0) := ioTmp_SDA;
								when others => null;
							end case;
							
							if vPeriod = 27 then
								--end of communication
								vPeriod := 0;
								vState := 3;
							else
								vPeriod := vPeriod + 1;
							end if;
							
						end if;
						
					elsif vState = 3 then
						--Stop, send output
						oTmp_SCL <= '1';
						ioTmp_SDA <= 'Z';
						
						oUpdated <= '1';
                        oDataValid <= vDataValid;
						oTempData <= vTempData;
						
						vState := 0;
						
					end if;--end of state machine
					
				else
					vClkCnt := vClkCnt + 1;
				end if;--end of clk div
					
			end if; --end of rst judge
			
		end if; --end of clk edge
	
	end process;


end architecture Beh;
-- END_SOURCE: MainTMP117Controller.vhd

