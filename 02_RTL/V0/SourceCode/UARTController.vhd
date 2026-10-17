
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