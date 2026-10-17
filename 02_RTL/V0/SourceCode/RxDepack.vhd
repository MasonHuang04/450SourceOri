
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
