
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;

entity TMP117Controller is
	port(
		iClk : in std_logic; --PCLK freq
		iRst : in std_logic;
		
		iAddr : in std_logic_vector(7 downto 0) := x"48";
		
		oDataValid : out std_logic := '0';
		oTempData : out std_logic_vector(15 downto 0) := x"0000";
		
		
		oTmp_SCL : out std_logic := '1';
		ioTmp_SDA : inout std_logic := 'Z'
	);
end entity TMP117Controller;

architecture Beh of TMP117Controller is
	
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
		if iClk'event and iClk = '0' then

		
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
			
				if vClkCnt = 63 then
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
								when 0 	=> ioTmp_SDA <= vAddr(6);
								when 1 	=> ioTmp_SDA <= vAddr(5);
								when 2 	=> ioTmp_SDA <= vAddr(4);
								when 3 	=> ioTmp_SDA <= vAddr(3);
								when 4 	=> ioTmp_SDA <= vAddr(2);
								when 5 	=> ioTmp_SDA <= vAddr(1);
								when 6 	=> ioTmp_SDA <= vAddr(0);
								when 7 	=> ioTmp_SDA <= '1'; --read
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
								when 26 	=> ioTmp_SDA <= '0'; --master ack
								
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