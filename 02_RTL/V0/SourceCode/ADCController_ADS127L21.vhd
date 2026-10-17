
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;

entity ADCController_ADS127L21 is
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
end entity ADCController_ADS127L21;

architecture Beh of ADCController_ADS127L21 is

	signal cADClk : std_logic := '0';
	signal cClkEn : std_logic := '0';
	
	signal cDownSampleRate : integer range 0 to 65535 := 0;
	
	constant AD127L12_REGVAL_MUX : std_logic_vector(15 downto 0) := x"8500";
	--controls input signal source, 01 for reverse, 02 for offset noise test, 03 for common mode test
	
	constant AD127L12_REGVAL_CONF1 : std_logic_vector(15 downto 0) := x"8687";
	--open all precharge buffers, 16bit data
	
	constant AD127L12_REGVAL_CONF2 : std_logic_vector(15 downto 0) := x"870C";
	--max speed, start stop mode
	
	constant AD127L12_REGVAL_CONF3 : std_logic_vector(15 downto 0) := x"8880";
	--ext clk
	
	constant AD127L12_REGVAL_FILTER1 : std_logic_vector(15 downto 0) := x"8908";
	--sinc filter OSR = 12
	
begin

	--use input clock for AD SPI clock
	oADSClk <= cADClk and cClkEn;
	oADClk <= cADClk and cClkEn;


	process(iClk)
	
		variable vClkCnt : integer range 0 to 7;
	
		variable vNewData : std_logic := '0';
		variable vInitState : integer range 0 to 15 := 0;
		
		variable vCycleCnt : integer range 0 to 63 := 0;
		variable vADDRdy_L1 : std_logic := '1';
		
		variable vRegVal : std_logic_vector(15 downto 0) := x"0000";
		variable vValue : std_logic_vector(15 downto 0) := x"0000";
		
		variable vState : integer range 0 to 7 := 0;
		variable vCnt : integer range 0 to 65535 := 0;
		
		variable vSmpCnt : integer range 0 to 65535 := 0;
		variable vDataCnt : integer range 0 to 16777215 := 0;
		variable vSmpCntA1 : integer range 0 to 65535 := 1;
		variable vDataCntA1 : integer range 0 to 16777215 := 1;
	begin
	
		if iClk'event and iClk = '1' then
				
			vNewData := '0';
		
			if iRst = '1' then
			
				vInitState := 0;
				vCycleCnt := 0;
				
				oADRstz <= '1';
				oADStart <= '0';
				vClkCnt := 0;
				vState := 0;
				vCnt := 0;
				vSmpCnt := 0;
				vDataCnt := 0;
				vSmpCntA1 := 1;
				vDataCntA1 := 1;
			else
			
				oADRstz <= '1';
				
				if vState = 0 then
					--wait for start up
					cClkEn <= '0';
					if vCnt = 65535 then
						vCnt := 0;
						vState := 1;
					else
						vCnt := vCnt + 1;
					end if;
					
				
				elsif vState = 1 then
					--for init, clk is always enabled
					cClkEn <= '1';
					
					if vClkCnt = 0 then
						--falling edge
						cADClk <= '0';
						
						--assign reg address and value for differnt SPI command cycles
						if vInitState = 0 then
							vRegVal := x"0000"; --dummy for start up wait
						elsif vInitState = 1 then
							vRegVal := AD127L12_REGVAL_MUX;
						elsif vInitState = 2 then
							vRegVal := AD127L12_REGVAL_CONF1;
						elsif vInitState = 3 then
							vRegVal := AD127L12_REGVAL_CONF2;
						elsif vInitState = 4 then
							vRegVal := AD127L12_REGVAL_CONF3;
						elsif vInitState = 5 then
							vRegVal := AD127L12_REGVAL_FILTER1;
						end if;
					
						--assign CSz value
						if vCycleCnt >= 10 and vCycleCnt < 27 then
							oADCSz <= '0';
						else
							oADCSz <= '1';
						end if;
						
						--assign each bit of MOSI
						if vCycleCnt >= 11 and vCycleCnt < 27 then
							oADSDI <= vRegVal(26 - vCycleCnt);
						else
							oADSDI <= '0';
						end if;
						
						--loop to next or end init
						if vCycleCnt = 31 then
							vCycleCnt := 0;
							if vInitState = 5 then
								--init done
								vState := 2;
							else
								vInitState := vInitState + 1;
							end if;
						else
							vCycleCnt := vCycleCnt + 1;
						end if;
					elsif vClkCnt = 3 then
						--rising edge
						cADClk <= '1';
					
					end if;
					
					--count for low freq clk
					if vClkCnt = 5 then
						vClkCnt := 0;
					else
						vClkCnt := vClkCnt + 1;
					end if;
				
				elsif vState = 2 then
					--wait for start, clock disabled
					cClkEn <= '0';
					vClkCnt := 0;
					cADClk <= '0';
					vCnt := 0;
					oADStart <= '0';
					vCycleCnt := 63;
					vADDRdy_L1 := '0';
					vSmpCnt := 0;
					vDataCnt := 0;
					cDownSampleRate <= iDownSampleRate;
					
					if iSamplingEn = '1' then
						--if enabled go to next
						vState := 3;
					end if;
					
				elsif vState = 3 then
					--enable clck and wait for cycles
					cClkEn <= '1';
					
					if vClkCnt = 0 then
						--rising edge
						cADClk <= '1';
					elsif vClkCnt = 3 then
						--rising edge
						cADClk <= '0';
					end if;
					
					--count for low freq clk, wait for 64 low freq clk
					if vClkCnt = 5 then
						vClkCnt := 0;
						if vCnt = 63 then
							vCnt := 0;
							vState := 4;
						else
							vCnt := vCnt + 1;
						end if;
					else
						vClkCnt := vClkCnt + 1;
					end if;
					
				elsif vState = 4 then
					--sampling
					cClkEn <= '1';
					oADStart <= '1';
						
					if vClkCnt = 0 then
						--rising edge, input data
						cADClk <= '1';
						
						--latch MISO bit
						if vCycleCnt >= 1 and vCycleCnt <= 16 then
							vValue(16 - vCycleCnt) := iADSDO;
						end if;
						
						--output result
						if vCycleCnt = 17 then
							oValue <= conv_std_logic_vector(conv_integer(vValue) + 32768, 16);
							
							--skip samples
							if vSmpCnt = cDownSampleRate then
								vSmpCnt := 0;
								vNewData := '1';
								vDataCnt := vDataCntA1;
								oDataCnt <= vDataCnt;
							else
								vSmpCnt := vSmpCntA1;
							end if;
							
							--check end
							if iSamplingEn = '0' then
								vState := 2;
							end if;
						end if;
						
						--wait for DRdy signal to restart communication
						if iADDRdy = '0' and vADDRdy_L1 = '1' and vCycleCnt > 17 then
							vCycleCnt := 0;
						else
							if vCycleCnt /= 63 then
								vCycleCnt := vCycleCnt + 1;
							end if;
						end if;
												
						vADDRdy_L1 := iADDRdy;
						
					elsif vClkCnt = 3 then
					
						--dropping edge, output data
						cADClk <= '0';
						
						--assign CSz
						if vCycleCnt <= 17 then
							oADCSz <= '0';
						else
							oADCSz <= '1';
						end if;
						
					end if;
					
					--count for low freq clk
					if vClkCnt = 5 then
						vClkCnt := 0;
					else
						vClkCnt := vClkCnt + 1;
					end if;
						
				end if; --end of state machine
					
			end if; --end of rst
			
			oNewData <= vNewData;
			
			vSmpCntA1 := vSmpCnt + 1;
			vDataCntA1 := vDataCnt + 1;
			
		
		end if;
	
	end process;

end architecture Beh;