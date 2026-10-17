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