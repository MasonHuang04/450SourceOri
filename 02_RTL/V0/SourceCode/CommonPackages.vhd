-- Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

-- BEGIN_SOURCE: SysLib.vhd
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
-- END_SOURCE: SysLib.vhd

-- BEGIN_SOURCE: DSPLib.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use work.SysLib.ALL;


package DSPLib is

	component FIFO is
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
	end component FIFO;
	
	component FIFOStdLogic
		generic(
			gDepth : natural := 1
		);
		port(
			iClk : in std_logic := '0';
			iClkEn : in std_logic := '1';
			iRst : in std_logic := '0';
			iData : in std_logic := '0';
			oData : out std_logic := '0'
		);
	end component FIFOStdLogic;
	
	component FIFOInt is
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
	end component FIFOInt;
	
	--LAT = 13
	component FPFAdd
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			b      : in  std_logic_vector(31 downto 0) := (others => '0'); --      b.b
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFAdd;

	--LAT = 13
	component FPFSub
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			b      : in  std_logic_vector(31 downto 0) := (others => '0'); --      b.b
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFSub;
	
	--LAT = 6
	component FPFMult
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			b      : in  std_logic_vector(31 downto 0) := (others => '0'); --      b.b
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFMult;

	--LAT = 14
	component FPFDiv
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			b      : in  std_logic_vector(31 downto 0) := (others => '0'); --      b.b
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFDiv;
	
	--LAT = 32
	component FPFCos
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFCos;
	
	--LAT = 5
	component FPFFP32ToInt32
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFFP32ToInt32;
	
	--LAT = 11
	component FPFInt32ToFP32
		port (
			clk    : in  std_logic                     := '0';             --    clk.clk
			areset : in  std_logic                     := '0';             -- areset.reset
			a      : in  std_logic_vector(31 downto 0) := (others => '0'); --      a.a
			q      : out std_logic_vector(31 downto 0)                     --      q.q
		);
	end component FPFInt32ToFP32;

	
end package DSPLib;
-- END_SOURCE: DSPLib.vhd

