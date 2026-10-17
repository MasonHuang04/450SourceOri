library IEEE;
use IEEE.std_logic_1164.all;

package SysLib is

	constant FLOAT_0P5 : std_logic_vector(31 downto 0) := x"3f000000";
	constant FLOAT_8191 : std_logic_vector(31 downto 0) := x"45fff800";
	constant FLOAT_8192 : std_logic_vector(31 downto 0) := x"46000000";
	constant FLOAT_2PI : std_logic_vector(31 downto 0) := x"40c90fdb";

	constant DA_CLK_PERIOD : std_logic_vector(31 downto 0) := x"31d03da8"; --period for 165M
	constant AD_PERIOD : std_logic_vector(31 downto 0) := x"356a455d"; --period for AD, 8.727E-7
	constant DA_CLK_FREQ : std_logic_vector(31 downto 0) := x"4d1d5b34"; --165M
	
	
	type Bytex56 is array (55 downto 0) of std_logic_vector(7 downto 0);
	type Bytex64 is array (63 downto 0) of std_logic_vector(7 downto 0);
	
	
	
end package SysLib;