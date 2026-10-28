-- Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

-- BEGIN_SOURCE: ChirpWaveGen.vhd
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
		oWaveform : out integer range 0 to 16383 := 8192;
        oSineWaveform : out integer range 0 to 16383 := 8192
		
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
    signal cPeakInt : std_logic_vector(31 downto 0);
    signal cPeakCode : integer range 0 to 8191 := 0;
	
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
	

    -- Square-wave height follows the SAME amplitude setting as the sine.
    -- The previous legacy limiter ignored amplitude and drove both DAC rails.
    uPeak : FPFFP32ToInt32 port map(clk=>iClk,areset=>cRst,a=>cADig,q=>cPeakInt);
    cPeakCode <= 0 when cPeakInt(31)='1' else
        8191 when cPeakInt(30 downto 13)/="000000000000000000" else
        conv_integer(cPeakInt(12 downto 0));

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
	cWaveformSQCheck_L105 <= cWaveformUInt14_L105 when cSQWaveEn='0' else
        8192-cPeakCode when cWaveformUInt14_L105<8192 else
        8192+cPeakCode;
						
----L106

	--output
	oWaveform <= cWaveformSQCheck_L106;

	process(iClk)
	begin
		if iClk'event and iClk = '1' then
		
			cWaveformUInt14_L105 <= cWaveformUInt14_L104;
			cWaveformSQCheck_L106 <= cWaveformSQCheck_L105;
            oSineWaveform <= cWaveformUInt14_L105;
		
			cRst <= iRst;
			
			cSQWaveEn <= iSQWaveEn;
			cF0 <= iF0;
			cK <= iK;
			cA <= iA;
			cDT <= iDT;
		
		end if;
	end process;
	
end architecture Beh;
-- END_SOURCE: ChirpWaveGen.vhd

-- BEGIN_SOURCE: TxController.vhd
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use work.SysLib.ALL;
use work.DSPLib.ALL;

entity TxController is
	port(
		--input clock
		iClk : in std_logic;
		iRst : in std_logic := '1';
		
		--control
		iStart : in std_logic := '0'; --signal to start sending a chirp
		oBusy : out std_logic := '0';
		
		--chirp parameters
		iSQWaveEn : in std_logic := '0';
		iDownSampleRate : in integer range 0 to 65535 := 0; --sampling rate = 165M / (DownSampleRate + 1)
		iDataResolution : in integer range 0 to 31 := 14;
		iFc : in std_logic_vector(31 downto 0) := x"471c4000"; --center freq, F32, Hz, def = 40000
		iBW : in std_logic_vector(31 downto 0) := x"459c4000"; --bandwidth, F32, Hz, def = 5000
		iTc : in std_logic_vector(31 downto 0) := x"3c23d70a"; --time duration for chirp, F32, s, def = 0.01
		iA : in std_logic_vector(31 downto 0) := x"3f800000"; --amp ratio, F32, def = 1.0f for full range
		
		--mux control
		iMuxSel : in std_logic_vector(2 downto 0) := "000"; --bit 2 for FLT, 1 downto 0 for gain. 000 for div 1 no flt
		
		--DA interface
		oDA_PD : out std_logic := '0';
		oDA_CLK : out std_logic;
		oDA_D : out std_logic_vector(13 downto 0);
		
		--mux
		oTX_MUX_EN : out std_logic := '1';
		oTX_MUX_A : out std_logic_vector(2 downto 0) := "000";
		
		--LED indicators
		oLED_CHIRP : out std_logic := '0';
		oLED_TX_FLT : out std_logic := '0';
		oLED_TX_DIV1 : out std_logic := '0';
		oLED_TX_DIV2 : out std_logic := '0';
		oLED_TX_DIV4 : out std_logic := '0';
		oLED_TX_DIV8 : out std_logic := '0'
	);
end entity TxController;

architecture Beh of TxController is

	component ChirpWaveGen is
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
			oWaveform : out integer range 0 to 16383 := 8192;
        oSineWaveform : out integer range 0 to 16383 := 8192
		);
	end component ChirpWaveGen;
	
	signal cRst : std_logic := '1';
	signal cBusy : std_logic := '0';
	
	--padding params
	signal cSQWaveEn : std_logic := '0';
	signal cDownSampleRate : integer range 0 to 65535 := 0;
	signal cDataResolution : integer range 0 to 31 := 14;
	signal cFc : std_logic_vector(31 downto 0) := x"471c4000";
	signal cBW : std_logic_vector(31 downto 0) := x"459c4000";
	signal cTc : std_logic_vector(31 downto 0) := x"3c23d70a";
	signal cA : std_logic_vector(31 downto 0) := x"3f800000";
	signal cMuxSel : std_logic_vector(2 downto 0) := "000"; 
	
	--param to be calculated
	signal cDataMask : std_logic_vector(13 downto 0) := (others => '1');
	signal cHalfBW : std_logic_vector(31 downto 0);
	signal cF0 : std_logic_vector(31 downto 0);
	signal cK : std_logic_vector(31 downto 0);
	signal cNFloat : std_logic_vector(31 downto 0);
	signal cNInt : std_logic_vector(31 downto 0);
	signal cN : integer range 0 to 268435455 := 0;
	
	--CWG signals
	signal cCWG_DIdx : std_logic_vector(31 downto 0) := (others => '0');
	signal cCWG_Waveform : integer range 0 to 16383 := 8192;
begin

----parameter calculation

	--start freq F0 = Fc - BW/2
	u0 : FPFMult port map (clk => iClk, areset => cRst, a => cBW, b => FLOAT_0P5, q => cHalfBW);
	u1 : FPFSub port map (clk => iClk, areset => cRst, a => cFc, b => cHalfBW, q => cF0);
	
	--freq change slowp K = BW / Tc
	u2 : FPFDiv port map (clk => iClk, areset => cRst, a => cBW, b => cTc, q => cK);
	
	--num of clk cycles N = Tc * fClk
	u3 : FPFMult port map (clk => iClk, areset => cRst, a => cTc, b => DA_CLK_FREQ, q => cNFloat);
	u4 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cNFloat, q => cNInt);
	cN <= 1650 when (cNInt = x"00000000") or (cNInt(31) = '1') else --small val protection, 10us
			268435455 when cNInt(30 downto 24) /= "0000000" else --big val protection
			conv_integer(cNInt);
			
	--resolution
	cDataMask <= 	"10000000000000" when cDataResolution = 1 else
						"11000000000000" when cDataResolution = 2 else
						"11100000000000" when cDataResolution = 3 else
						"11110000000000" when cDataResolution = 4 else
						"11111000000000" when cDataResolution = 5 else
						"11111100000000" when cDataResolution = 6 else
						"11111110000000" when cDataResolution = 7 else
						"11111111000000" when cDataResolution = 8 else
						"11111111100000" when cDataResolution = 9 else
						"11111111110000" when cDataResolution = 10 else
						"11111111111000" when cDataResolution = 11 else
						"11111111111100" when cDataResolution = 12 else
						"11111111111110" when cDataResolution = 13 else
						"11111111111111";
	
	
----chirp generate

	uCWG : ChirpWaveGen port map (iClk => iClk, iRst => cRst,
		iSQWaveEn => cSQWaveEn, iDIdx => cCWG_DIdx, iF0 => cF0, iK => cK, iA => cA, iDT => DA_CLK_PERIOD,
		oWaveform => cCWG_Waveform, oSineWaveform => open);

----direct output signals

	oBusy <= cBusy;

	oDA_PD <= '0';
	oDA_CLK <= iClk;
	
	oTX_MUX_EN <= '1';
	oTX_MUX_A <= cMuxSel;
	
	oLED_CHIRP <= cBusy;
	oLED_TX_FLT <= cMuxSel(2);
	oLED_TX_DIV1 <= '1' when cMuxSel(1 downto 0) = "00" else '0';
	oLED_TX_DIV2 <= '1' when cMuxSel(1 downto 0) = "01" else '0';
	oLED_TX_DIV4 <= '1' when cMuxSel(1 downto 0) = "10" else '0';
	oLED_TX_DIV8 <= '1' when cMuxSel(1 downto 0) = "11" else '0';
	
	process(iClk)
		
		variable vState : integer range 0 to 7 := 0;
		variable vCnt : integer range 0 to 268435455 := 0;
		variable vDownSampleCnt : integer range 0 to 65535 := 0;
		variable vStart_L1 : std_logic := '0';
		
		variable vN : integer range 0 to 268435455 := 0;
		
	begin
		if iClk'event and iClk = '1' then
		
			if cRst = '1' then
				
				vState := 0;
				vCnt := 0;
				vStart_L1 := '0';
				cBusy <= '0';
				vDownSampleCnt := 0;
				
			else
			
				if vState = 0 then
					
					vCnt := 0;
					cBusy <= '0';
					
					--set DA @ 0V
					oDA_D <= conv_std_logic_vector(8192, 14);
					cCWG_DIdx <= (others => '0');
				
					--latch settings
					cSQWaveEn <= iSQWaveEn;
					cDownSampleRate <= iDownSampleRate;
					cDataResolution <= iDataResolution;
					vDownSampleCnt := iDownSampleRate; --let first cycle always update
					cFc <= iFc;
					cBW <= iBW;
					cTc <= iTc;
					cA <= iA;
					cMuxSel <= iMuxSel;
					
					--wait for start signal
					if iStart = '1' and vStart_L1 = '0' then
						vState := 1;
						cBusy <= '1';
					end if;
					
				elsif vState = 1 then
				
					--wait for parameter calculation
					
					if vCnt = 99 then
						vCnt := 0;
						vN := cN;
						vState := 2;
					else
						vCnt := vCnt + 1;
					end if;
					
				elsif vState = 2 then
				
					--during Tx chirp generation
					
					--check down sample
					if vDownSampleCnt = cDownSampleRate then
						vDownSampleCnt := 0;
						cCWG_DIdx <= conv_std_logic_vector(vCnt, 32);
					else
						--block index update
						vDownSampleCnt := vDownSampleCnt + 1;
					end if;
					
					oDA_D <= conv_std_logic_vector(cCWG_Waveform, 14) and cDataMask;
					
					--check end of chirp
					if vCnt = vN then
						vCnt := 0;
						vState := 0;
					else
						vCnt := vCnt + 1;
					end if;
					
				end if;
			
			end if;
		
		
			vStart_L1 := iStart;
			cRst <= iRst;
		end if;
	end process;
	
end architecture Beh;
-- END_SOURCE: TxController.vhd

-- BEGIN_SOURCE: MainTxController.vhd
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use work.SysLib.ALL;
use work.DSPLib.ALL;

entity MainTxController is
	port(
		--input clock
		iClk : in std_logic;
		iRst : in std_logic := '1';
		
		--control
		iStart : in std_logic := '0'; --signal to start sending a chirp
		oBusy : out std_logic := '0';
        oSineReference : out std_logic_vector(15 downto 0) := (others=>'0');
		
		--chirp parameters
		iSQWaveEn : in std_logic := '0';
		iDownSampleRate : in integer range 0 to 65535 := 0; --sampling rate = 165M / (DownSampleRate + 1)
		iDataResolution : in integer range 0 to 31 := 14;
		iFc : in std_logic_vector(31 downto 0) := x"471c4000"; --center freq, F32, Hz, def = 40000
		iBW : in std_logic_vector(31 downto 0) := x"459c4000"; --bandwidth, F32, Hz, def = 5000
		iTc : in std_logic_vector(31 downto 0) := x"3c23d70a"; --time duration for chirp, F32, s, def = 0.01
		iA : in std_logic_vector(31 downto 0) := x"3f800000"; --amp ratio, F32, def = 1.0f for full range
		
		--mux control
		iMuxSel : in std_logic_vector(2 downto 0) := "000"; --bit 2 for FLT, 1 downto 0 for gain. 000 for div 1 no flt
		
		--DA interface
		oDA_PD : out std_logic := '0';
		oDA_CLK : out std_logic;
		oDA_D : out std_logic_vector(13 downto 0);
		
		--mux
		oTX_MUX_EN : out std_logic := '1';
		oTX_MUX_A : out std_logic_vector(2 downto 0) := "000";
		
		--LED indicators
		oLED_CHIRP : out std_logic := '0';
		oLED_TX_FLT : out std_logic := '0';
		oLED_TX_DIV1 : out std_logic := '0';
		oLED_TX_DIV2 : out std_logic := '0';
		oLED_TX_DIV4 : out std_logic := '0';
		oLED_TX_DIV8 : out std_logic := '0'
	);
end entity MainTxController;

architecture Beh of MainTxController is

	component ChirpWaveGen is
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
			oWaveform : out integer range 0 to 16383 := 8192;
        oSineWaveform : out integer range 0 to 16383 := 8192
		);
	end component ChirpWaveGen;
	
	signal cRst : std_logic := '1';
	signal cBusy : std_logic := '0';
	
	--padding params
	signal cSQWaveEn : std_logic := '0';
	signal cDownSampleRate : integer range 0 to 65535 := 0;
	signal cDataResolution : integer range 0 to 31 := 14;
	signal cFc : std_logic_vector(31 downto 0) := x"471c4000";
	signal cBW : std_logic_vector(31 downto 0) := x"459c4000";
	signal cTc : std_logic_vector(31 downto 0) := x"3c23d70a";
	signal cA : std_logic_vector(31 downto 0) := x"3f800000";
	signal cMuxSel : std_logic_vector(2 downto 0) := "000"; 
	
	--param to be calculated
	signal cDataMask : std_logic_vector(13 downto 0) := (others => '1');
	signal cHalfBW : std_logic_vector(31 downto 0);
	signal cF0 : std_logic_vector(31 downto 0);
	signal cK : std_logic_vector(31 downto 0);
	signal cNFloat : std_logic_vector(31 downto 0);
	signal cNIntPipe:std_logic_vector(31 downto 0):=(others=>'0');
	signal cNCalc:integer range 0 to 268435455:=0;
	signal cNInt : std_logic_vector(31 downto 0);
	signal cN : integer range 0 to 268435455 := 0;
	
	--CWG signals
	signal cCWG_DIdx : std_logic_vector(31 downto 0) := (others => '0');
	signal cCWG_Waveform : integer range 0 to 16383 := 8192;
    signal cCWG_Sine : integer range 0 to 16383 := 8192;
begin

----parameter calculation

	--start freq F0 = Fc - BW/2
	u0 : FPFMult port map (clk => iClk, areset => cRst, a => cBW, b => FLOAT_0P5, q => cHalfBW);
	u1 : FPFSub port map (clk => iClk, areset => cRst, a => cFc, b => cHalfBW, q => cF0);
	
	--freq change slowp K = BW / Tc
	u2 : FPFDiv port map (clk => iClk, areset => cRst, a => cBW, b => cTc, q => cK);
	
	--num of clk cycles N = Tc * fClk
	u3 : FPFMult port map (clk => iClk, areset => cRst, a => cTc, b => DA_CLK_FREQ, q => cNFloat);
	u4 : FPFFP32ToInt32 port map (clk => iClk, areset => cRst, a => cNFloat, q => cNInt);
	cNCalc <= 1650 when (cNIntPipe = x"00000000") or (cNIntPipe(31) = '1') else --small val protection, 10us
			268435455 when cNIntPipe(30 downto 24) /= "0000000" else --big val protection
			conv_integer(cNIntPipe);
			
	process(iClk)begin if rising_edge(iClk)then cNIntPipe<=cNInt;cN<=cNCalc;end if;end process;
	--resolution
	cDataMask <= 	"10000000000000" when cDataResolution = 1 else
						"11000000000000" when cDataResolution = 2 else
						"11100000000000" when cDataResolution = 3 else
						"11110000000000" when cDataResolution = 4 else
						"11111000000000" when cDataResolution = 5 else
						"11111100000000" when cDataResolution = 6 else
						"11111110000000" when cDataResolution = 7 else
						"11111111000000" when cDataResolution = 8 else
						"11111111100000" when cDataResolution = 9 else
						"11111111110000" when cDataResolution = 10 else
						"11111111111000" when cDataResolution = 11 else
						"11111111111100" when cDataResolution = 12 else
						"11111111111110" when cDataResolution = 13 else
						"11111111111111";
	
	
----chirp generate

	uCWG : ChirpWaveGen port map (iClk => iClk, iRst => cRst,
		iSQWaveEn => cSQWaveEn, iDIdx => cCWG_DIdx, iF0 => cF0, iK => cK, iA => cA, iDT => DA_CLK_PERIOD,
		oWaveform => cCWG_Waveform, oSineWaveform => cCWG_Sine);

----direct output signals

	oBusy <= cBusy;

	oDA_PD <= '0';
	oDA_CLK <= iClk;
	
	oTX_MUX_EN <= '1';
	oTX_MUX_A <= cMuxSel;
	
	oLED_CHIRP <= cBusy;
	oLED_TX_FLT <= cMuxSel(2);
	oLED_TX_DIV1 <= '1' when cMuxSel(1 downto 0) = "00" else '0';
	oLED_TX_DIV2 <= '1' when cMuxSel(1 downto 0) = "01" else '0';
	oLED_TX_DIV4 <= '1' when cMuxSel(1 downto 0) = "10" else '0';
	oLED_TX_DIV8 <= '1' when cMuxSel(1 downto 0) = "11" else '0';
	
	process(iClk)
		
		variable vState : integer range 0 to 7 := 0;
		variable vCnt : integer range 0 to 268435455 := 0;
		variable vDownSampleCnt : integer range 0 to 65535 := 0;
		variable vStart_L1 : std_logic := '0';
		
		variable vN : integer range 0 to 268435455 := 0;
		
	begin
		if iClk'event and iClk = '1' then
		
			if cRst = '1' then
				
				vState := 0;
				vCnt := 0;
				vStart_L1 := '0';
				cBusy <= '0';
                oSineReference <= (others=>'0');
				vDownSampleCnt := 0;
				
			else
			
				if vState = 0 then
					
					vCnt := 0;
					cBusy <= '0';
					
					--set DA @ 0V
					oDA_D <= conv_std_logic_vector(8192, 14);
                    oSineReference <= (others=>'0');
					cCWG_DIdx <= (others => '0');
				
					--latch settings
					cSQWaveEn <= iSQWaveEn;
					cDownSampleRate <= iDownSampleRate;
					cDataResolution <= iDataResolution;
					vDownSampleCnt := iDownSampleRate; --let first cycle always update
					cFc <= iFc;
					cBW <= iBW;
					cTc <= iTc;
					cA <= iA;
					cMuxSel <= iMuxSel;
					
					--wait for start signal
					if iStart = '1' and vStart_L1 = '0' then
						vState := 1;
						cBusy <= '1';
					end if;
					
				elsif vState = 1 then
				
					--wait for parameter calculation
					
					if vCnt = 99 then
						vCnt := 0;
						vN := cN;
						vState := 2;
					else
						vCnt := vCnt + 1;
					end if;
					
				elsif vState = 2 then
				
					--during Tx chirp generation
					
					--check down sample
					if vDownSampleCnt = cDownSampleRate then
						vDownSampleCnt := 0;
						cCWG_DIdx <= conv_std_logic_vector(vCnt, 32);
					else
						--block index update
						vDownSampleCnt := vDownSampleCnt + 1;
					end if;
					
					oDA_D <= conv_std_logic_vector(cCWG_Waveform, 14) and cDataMask;
                    -- Pre-square sine, same pipeline/output gate as the DAC.
                    oSineReference <= conv_std_logic_vector((cCWG_Sine-8192)*4,16);
					
					--check end of chirp
					if vCnt = vN then
						vCnt := 0;
						vState := 0;
					else
						vCnt := vCnt + 1;
					end if;
					
				end if;
			
			end if;
		
		
			vStart_L1 := iStart;
			cRst <= iRst;
		end if;
	end process;
	
end architecture Beh;
-- END_SOURCE: MainTxController.vhd

-- BEGIN_SOURCE: ScopeBurstControl.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Synthesizable auto-trigger sequencer. Actual defaults are in system clocks.
-- Wait for PLL lock, release TX reset, enable DAC after data can settle, then
-- emit one-cycle triggers every 200 ms. Never issue a trigger while TX is busy.
entity ScopeBurstControl is
 generic(RESET_CYCLES:positive:=16500;DAC_ENABLE_CYCLES:positive:=33000;
         BOOT_CYCLES:positive:=16500000;PERIOD_CYCLES:positive:=33000000);
 port(clk,pll_locked,tx_busy:in std_logic;
      tx_reset,tx_start,dac_power_down,ready:out std_logic);
end;
architecture rtl of ScopeBurstControl is
 signal lock_sync:std_logic_vector(1 downto 0):=(others=>'0');
 signal boot_count:natural range 0 to BOOT_CYCLES:=0;
 signal repeat_count:natural range 0 to PERIOD_CYCLES-1:=0;
 signal start_reg:std_logic:='0';
 attribute altera_attribute:string;
 attribute altera_attribute of lock_sync:signal is "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
begin
 assert RESET_CYCLES<DAC_ENABLE_CYCLES and DAC_ENABLE_CYCLES<BOOT_CYCLES
  report "Reset, DAC enable and first trigger must be ordered" severity failure;
 tx_reset<='1' when lock_sync(1)='0' or boot_count<RESET_CYCLES else '0';
 dac_power_down<='1' when lock_sync(1)='0' or boot_count<DAC_ENABLE_CYCLES else '0';
 ready<='1' when lock_sync(1)='1' and boot_count=BOOT_CYCLES else '0';
 tx_start<=start_reg;
 process(clk) begin
  if rising_edge(clk) then
   lock_sync<=lock_sync(0)&pll_locked;start_reg<='0';
   if lock_sync(1)='0' then boot_count<=0;repeat_count<=0;
   elsif boot_count<BOOT_CYCLES then boot_count<=boot_count+1;repeat_count<=0;
   else
    if repeat_count=0 and tx_busy='0' then start_reg<='1';end if;
    if repeat_count=PERIOD_CYCLES-1 then repeat_count<=0;
    else repeat_count<=repeat_count+1;end if;
   end if;
  end if;
 end process;
end;

-- END_SOURCE: ScopeBurstControl.vhd

