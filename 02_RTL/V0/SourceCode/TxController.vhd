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
			oWaveform : out integer range 0 to 16383 := 8192
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
		oWaveform => cCWG_Waveform);

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