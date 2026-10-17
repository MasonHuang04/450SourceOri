
library IEEE;
use IEEE.std_logic_1164.all;

entity FIFOInt is
	generic(
		gUpperBond : integer := 255;
		gLowerBond : integer := 0;
		gDepth : natural := 1
	);
	port(
		iClk : in std_logic := '0';
		iClkEn : in std_logic := '1';
		iRst : in std_logic := '0';
		iData : in integer range gLowerBond to gUpperBond;
		oData : out integer range gLowerBond to gUpperBond
	);
end entity FIFOInt;

architecture Beh of FIFOInt is
    type tArrayType is array (gDepth downto 0) of integer range gLowerBond to gUpperBond;
    signal cArray : tArrayType;
begin

	--data in at the top
	cArray(gDepth) <= iData;
	--data out at the bottom
	oData <= cArray(0);
	
	DepthCheck: if 0 < gDepth generate
   begin
		GenLoop: for i in gDepth-1 downto 0 generate
		begin
			process(iClk, iRst)
         begin
				if iRst = '1' then
					cArray(i) <= 0;
				elsif iClk'event and iClk='1' then
					if iClkEn = '1' then
						cArray(i) <= cArray(i + 1);
					end if;
				end if;
			end process;
		end generate;
	end generate;

end architecture Beh;