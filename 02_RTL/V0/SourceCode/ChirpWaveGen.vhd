library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use work.SysLib.ALL;
use work.DSPLib.ALL;

entity ChirpWaveGen is
	port(
		--input clock
		iClk : in std_logic;
		iRst : in std_logic := '1';
		
		iSQWaveEn : in std_logic := '0';
		
		--data index, as # of clock edge, in int32
		iDIdx : in std_logic_vector(31 downto 0) := (others => '0');
		
		--parameters, in float 32
		iF0 : in std_logic_vector(31 downto 0) := x"47127c00"; --initial freq
		iK : in std_logic_vector(31 downto 0) := x"48f42400"; --slope of freq
		iA : in std_logic_vector(31 downto 0) := x"3f800000"; --amp ratio, 1.0f for full range
		iDT : in std_logic_vector(31 downto 0) := x"31d03da8"; --period for clock
		
		--output, LAT = 106
		oWaveform : out integer range 0 to 16383 := 8192
		
	);
end entity ChirpWaveGen;

architecture Beh of ChirpWaveGen is

	signal cRst : std_logic := '1';
	signal cSQWaveEn : std_logic := '0';
	signal cF0 : std_logic_vector(31 downto 0);
	signal cK : std_logic_vector(31 downto 0);
	signal cA : std_logic_vector(31 downto 0);
	signal cDT : std_logic_vector(31 downto 0);
	
	signal cKDiv2 : std_logic_vector(31 downto 0);
	signal cADig : std_logic_vector(31 downto 0);
	
	--L11
	signal cDIdxF_L11 : std_logic_vector(31 downto 0);
	
	--L17
	signal cT_L17 : std_logic_vector(31 downto 0);
	
	--L23
	signal cT2_L23 : std_logic_vector(31 downto 0);
	signal cF0T_L23 : std_logic_vector(31 downto 0);
	
	--L29
	signal cF0T_L29 : std_logic_vector(31 downto 0);
	signal cKDiv2T2_L29 : std_logic_vector(31 downto 0);
	
	--L42
	signal cF0TAddKDiv2T2_L42 : std_logic_vector(31 downto 0);
	
	--L48
	signal cPhi_L48 : std_logic_vector(31 downto 0);
	
	--L80
	signal cCosPhi_L80 : std_logic_vector(31 downto 0);
	
	--L86
	signal cACosPhi_L86 : std_logic_vector(31 downto 0);
	
	--L99
	signal cWaveformF_L99 : std_logic_vector(31 downto 0);
	
	--L104
	signal cWaveformInt32_L104 : std_logic_vector(31 downto 0);
	signal cWaveformUInt14_L104 : integer range 0 to 16383 := 8192;
	
	--L105
	signal cWaveformUInt14_L105 : integer range 0 to 16383 := 8192;
	signal cWaveformSQCheck_L105 : integer range 0 to 16383 := 8192;
	
	--L106
	signal cWaveformSQCheck_L106 : integer range 0 to 16383 := 8192;

begin

----constant calculation

	--calculate half K
	u0 : FPFMult port map (clk => iClk, areset => cRst, a => cK, b => FLOAT_0P5, q => cKDiv2);
	
	--calculate amp from 0~1 range to 0 to 8191 range
	u1 : FPFMult port map (clk => iClk, areset => cRst, a => cA, b => FLOAT_8191, q => cADig);
	

----L0

	--convert index float
	u2 : FPFInt32ToFP32 port map (clk => iClk, areset => cRst, a => iDIdx, q => cDIdxF_L11);
	
----L11

	--calculate time 
	u3 : FPFMult port map (clk => iClk, areset => cRst, a => cDIdxF_L11, b => cDT, q => cT_L17);
	
----L17

	--calculate t^2 
	u4 : FPFMult port map (clk => iClk, areset => cRst, a => cT_L17, b => cT_L17, q => cT2_L23);
	
	--calculate f0 * t
	u5 : FPFMult port map (clk => iClk, areset => cRst, a => cF0, b => cT_L17, q => cF0T_L23);
	
----L23
	
	--calculate K/2 * t^2
	u6 : FPFMult port map (clk => iClk, areset => cRst, a => cKDiv2, b => cT2_L23, q => cKDiv2T2_L29);
	
	--fifo f0 * t for 6 beats
	f0 : FIFO generic map (gWidth => 32, gDepth => 6) 
		port map (iClk => iClk, iRst => cRst, iData => cF0T_L23, oData => cF0T_L29);
		
----L29
	
	--calculate f0 * t + K/2 * t^2
	u7 : FPFAdd port map (clk => iClk, areset => cRst, a => cF0T_L29, b => cKDiv2T2_L29, q => cF0TAddKDiv2T2_L42);

----L42
	
	--calculate phi
	u8 : FPFMult port map (clk => iClk, areset => cRst, a => cF0TAddKDiv2T2_L42, b => FLOAT_2PI, q => cPhi_L48);
	
----L48

	--calculate cos(phi)
	u9 : FPFCos port map (clk => iClk, areset => cRst, a => cPhi_L48, q => cCosPhi_L80);
	
----L80

	--calculate A * cos(phi)
	u10 : FPFMult port map (clk => iClk, areset => cRst, a => cADig, b => cCosPhi_L80, q => cACosPhi_L86);
	
----L86

	--calculate 8192 + A * cos(phi)
	u11 : FPFAdd port map (clk => iClk, areset => cRst, a => FLOAT_8192, b => cACosPhi_L86, q => cWaveformF_L99);
	
----L99

	--convert to int
	u12 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cWaveformF_L99, q => cWaveformInt32_L104);
	
----L104

	--check range
	cWaveformUInt14_L104 <= 0 when cWaveformInt32_L104(31) = '1' else --force to 0 when it is negative
									16383 when cWaveformInt32_L104(30 downto 14) /= "00000000000000000" else --force to 16383 when larger
									conv_integer(cWaveformInt32_L104(13 downto 0));
							
----L105
	
	--quare wave check
	cWaveformSQCheck_L105 <= cWaveformUInt14_L105 when (cSQWaveEn = '0') or (cWaveformUInt14_L105 = 8192) else
						0 when cWaveformUInt14_L105 < 8192 else
						16383 ;
						
----L106

	--output
	oWaveform <= cWaveformSQCheck_L106;

	process(iClk)
	begin
		if iClk'event and iClk = '1' then
		
			cWaveformUInt14_L105 <= cWaveformUInt14_L104;
			cWaveformSQCheck_L106 <= cWaveformSQCheck_L105;
		
			cRst <= iRst;
			
			cSQWaveEn <= iSQWaveEn;
			cF0 <= iF0;
			cK <= iK;
			cA <= iA;
			cDT <= iDT;
		
		end if;
	end process;
	
end architecture Beh;