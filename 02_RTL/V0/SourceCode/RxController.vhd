
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use work.SysLib.ALL;
use work.DSPLib.ALL;

entity RxController is
	port(
	
		iClk : in std_logic; --165M clk
		iRst : in std_logic := '0';
		
		--control
		iStart : in std_logic := '0'; --start signal of chirp, not Rx, delay done inside
		oBusy : out std_logic := '0';
		
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
end entity RxController;

architecture Beh of RxController is
	
	component ADCController_ADS127L21 is
		port(
			iClk : in std_logic; --165M clk
			iRst : in std_logic := '0';
			
			oADRstz : out std_logic := '1';
			oADCSz : out std_logic := '1';
			oADSClk : out std_logic := '0';
			oADSDI : out std_logic := '0';
			iADSDO : in std_logic;
			oADStart : out std_logic := '1';
			iADDRdy : in std_logic;
			oADClk : out std_logic;
			
			iDownSampleRate : in integer range 0 to 65535 := 0;
			iSamplingEn : in std_logic := '1';
			
			oDataCnt : out integer range 0 to 16777215 := 0;
			oNewData : out std_logic := '0';
			oValue : out std_logic_vector(15 downto 0) := x"0000"
		);
	end component ADCController_ADS127L21;
	
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
	
begin

----parameter calculation

	--num of clk cycles N = Tc * fclk
	u0 : FPFMult port map (clk => iClk, areset => cRst, a => cTc, b => DA_CLK_FREQ, q => cNFloat);
	u1 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cNFloat, q => cNInt);
	cN <= 1650 when (cNInt = x"00000000") or (cNInt(31) = '1') else --small val protection, 10us
			268435455 when cNInt(30 downto 24) /= "0000000" else --big val protection
			conv_integer(cNInt);
			
	--num of Rx delay after chirp start clk cycles TdN = Td * fclk
	u2 : FPFMult port map (clk => iClk, areset => cRst, a => cTd, b => DA_CLK_FREQ, q => cTdNFloat);
	u3 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cTdNFloat, q => cTdNInt);
	cTdN <= 268435455 when cTdNInt(30 downto 24) /= "0000000" else --big val protection
			conv_integer(cTdNInt);
			
	--sample interval
	u4 : FPFInt32ToFP32 port map (clk => iClk, areset => cRst, a => conv_std_logic_vector(cDownSampleRate + 1, 32), q => cSmpClkNumF);
	u5 : FPFMult port map (clk => iClk, areset => cRst, a => cSmpClkNumF, b => AD_PERIOD, q => oSamplingPeriod);
	
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
	uAD : ADCController_ADS127L21 port map (iClk => iClk, iRst => cRst, 
		--control
		iDownSampleRate => cDownSampleRate, iSamplingEn => cSamplingEn,
		--AD port
		oADRstz => oAD_RST, oADCSz => oAD_CS, oADSClk => oAD_SCLK, oADSDI => oAD_SDI, iADSDO => iAD_SDO,
		oADStart => oAD_START, iADDRdy => iAD_DRDY, oADClk => oAD_CLK, 
		--data port
		oDataCnt => cDataCnt, oNewData => cNewData, oValue => cValue);
		
	
----direct output signals

	oRX_MUX_EN <= '1';
	oRX_MUX_A <= cMuxSel;
	
	oLED_RX_FLT <= cMuxSel(2);
	oLED_RX_DIV1 <= '1' when cMuxSel(1 downto 0) = "00" else '0';
	oLED_RX_DIV2 <= '1' when cMuxSel(1 downto 0) = "01" else '0';
	oLED_RX_DIV4 <= '1' when cMuxSel(1 downto 0) = "10" else '0';
	oLED_RX_DIV8 <= '1' when cMuxSel(1 downto 0) = "11" else '0';
	
	process(iClk)
		variable vCnt : integer range 0 to 268435455 := 0;
		variable vState : integer range 0 to 7 := 0;
		variable vStart_L1 : std_logic := '0';
		
		variable vTdN : integer range 0 to 268435455 := 0;
		variable vN : integer range 0 to 268435455 := 0;
	begin
	
		if iClk'event and iClk = '1' then
		
			--output data padding
			oDataCnt <= cDataCnt;
			oNewData <= cNewData;
			oValue <= cValue and cDataMask;
		
			if cRst = '1' then
				vCnt := 0;
				vState := 0;
				cSamplingEn <= '0';
				oBusy <= '0';
			else
			
				if vState = 0 then
					oBusy <= '0';
					cSamplingEn <= '0';
					cDownSampleRate <= iDownSampleRate;
					cDataResolution <= iDataResolution;
					cTc <= iTc;
					cTd <= iTd;
					cMuxSel <= iMuxSel;
					
					--wait for start signal
					if iStart = '1' and vStart_L1 = '0' then
						vState := 1;
						oBusy <= '1';
					end if;
					
				elsif vState = 1 then
					
					--wait for parameter calculation
					
					if vCnt = 99 then
						vCnt := 0;
						vTdN := cTdN;
						vN := cN;
						vState := 2;
					else
						vCnt := vCnt + 1;
					end if;
					
				elsif vState = 2 then
				
					--Rx Delay
					
					if vCnt = vTdN then
						vCnt := 0;
						vState := 3;
					else
						vCnt := vCnt + 1;
					end if;
					
				elsif vState = 3 then
				
					--during RX
					
					cSamplingEn <= '1';
					if vCnt = vN then
						--end of sampling period
						vCnt := 0;
						vState := 4;
					else
						vCnt := vCnt + 1;
					end if;
					
				elsif vState = 4 then
				
					--short delay after RX
					
					cSamplingEn <= '0';
					if vCnt = 255 then
						vCnt := 0;
						vState := 0;
					else
						vCnt := vCnt + 1;
					end if;
					
				end if;
			
			end if;
			
			vStart_L1 := iStart;
			cRst <= iRst;
		
		end if;
	
	end process;
		
end architecture Beh;