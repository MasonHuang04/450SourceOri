
library IEEE;
use IEEE.std_logic_1164.all;

entity FIFO is
	generic(
		gWidth : natural := 32;
		gDepth : natural := 1
	);
	port(
		iClk : in std_logic := '0';
		iClkEn : in std_logic := '1';
		iRst : in std_logic := '0';
		iData : in std_logic_vector (gWidth-1 downto 0);
		oData : out std_logic_vector (gWidth-1 downto 0)
	);
end entity FIFO;

architecture Beh of FIFO is
    type tArrayType is array (gDepth downto 0) of std_logic_vector(gWidth-1 downto 0);
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
					cArray(i) <= (others => '0');
				elsif iClk'event and iClk='1' then
					if iClkEn = '1' then
						cArray(i) <= cArray(i + 1);
					end if;
				end if;
			end process;
		end generate;
	end generate;

end architecture Beh;