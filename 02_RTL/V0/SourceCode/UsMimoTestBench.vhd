library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use Work.SysLib.ALL;
use Work.MainSettings.ALL;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity UsMimoTestBench is
 generic(BOOT_CYCLES:positive:=16500000;AUTO_TRIGGER_DEFAULT:std_logic:='0');
	port(
	
	----system signals
	
		iMAIN_CLK : in std_logic := '0';
		
	----LED indicators
	
		oLED_STATE : out std_logic := '0';
		oLED_CHIRP : out std_logic := '0';
		
		oLED_TX_FLT : out std_logic := '0';
		oLED_TX_DIV1 : out std_logic := '0';
		oLED_TX_DIV2 : out std_logic := '0';
		oLED_TX_DIV4 : out std_logic := '0';
		oLED_TX_DIV8 : out std_logic := '0';
		
		oLED_RX_FLT : out std_logic := '0';
		oLED_RX_DIV1 : out std_logic := '0';
		oLED_RX_DIV2 : out std_logic := '0';
		oLED_RX_DIV4 : out std_logic := '0';
		oLED_RX_DIV8 : out std_logic := '0';
		
	----temperature sensor
	
		oTMP_SCL : out std_logic := '0';
		ioTMP_SDA : inout std_logic := 'Z';
		
	----UART
	
		oUART_TXD : out std_logic := '1';
		iUART_RXD : in std_logic := '1';
		oUART_CTS : out std_logic := 'Z';
		iUART_RTS : in std_logic := '0';
		
	----AD
	
		oAD_RST : out std_logic := '1';
		oAD_CS : out std_logic := '1';
		oAD_SCLK : out std_logic := '0';
		oAD_SDI : out std_logic := '0';
		iAD_SDO : in std_logic;
		oAD_START : out std_logic := '1';
		iAD_DRDY : in std_logic;
		oAD_CLK : out std_logic;
		
	----DA
	
		oDA_PD : out std_logic := '0';
		oDA_CLK : out std_logic;
		oDA_D : out std_logic_vector(13 downto 0);
		
	----mux
		oTX_MUX_EN : out std_logic := '1';
		oTX_MUX_A : out std_logic_vector(2 downto 0) := "000";
		oRX_MUX_EN : out std_logic := '1';
		oRX_MUX_A : out std_logic_vector(2 downto 0) := "000"
		
	);
end entity UsMimoTestBench;

architecture Beh of UsMimoTestBench is

	signal cRst : std_logic := '1';

----

	component MainPLL is
		port (
			refclk   : in  std_logic := '0'; --  refclk.clk
			rst      : in  std_logic := '0'; --   reset.reset
			outclk_0 : out std_logic;        -- outclk0.clk
			locked   : out std_logic         --  locked.export
		);
	end component MainPLL;
	
	signal cClkH : std_logic := '1'; --165M high speed clk
	
----
	
	component UARTController is
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
	end component UARTController;
	
	signal cUART_RxDataValid : std_logic := '0';
	signal cUART_RxData : std_logic_vector(7 downto 0);
	signal cUART_TxBusy : std_logic := '0';
	signal cUART_TxDataValid : std_logic := '0';
	signal cUART_TxData : std_logic_vector(7 downto 0);
	
	component RxDepack is
		port(
			iClk : in std_logic;
			iRst : in std_logic;
			
			iRxDataValid : in std_logic := '0';
			iRxData : in std_logic_vector(7 downto 0);
			
			oTrigger : out std_logic := '0';
			oRxPackValid : out std_logic := '0';
			oRxPack : out Bytex56
		);
	end component RxDepack;
	
	
	signal cSys_Trigger : std_logic := '0';
	signal cSys_AutoTriggerEn : std_logic := AUTO_TRIGGER_DEFAULT;
	signal cSys_AutoTriggerPeriod : integer range 0 to 65535 := 0; --in ms, 0 for countinuous trigger
	signal cSys_SettingPackValid : std_logic := '0';
	signal cSys_SettingPack : Bytex56;
	
	component MainTxPack is
		port(
			iClk : in std_logic;
			iRst : in std_logic;
			
			iStart : in std_logic := '0';
			oBusy : out std_logic := '0';
			
			--data input
			iSamplingPeriod : in std_logic_vector(31 downto 0) := (others => '0');
			iDataCnt : in integer range 0 to 16777215 := 0;
			iNewData : in std_logic := '0';
			iValue : in std_logic_vector(15 downto 0) := x"0000";
			
			iTempData : in std_logic_vector(15 downto 0) := x"0000";
		
			--to uart controller
			iTxBusy : in std_logic := '0';
			oTxDataValid : out std_logic := '0';
			oTxData : out std_logic_vector(7 downto 0)
			
		);
	end component MainTxPack;
	
	signal cCOM_StartSend : std_logic := '0';
	signal cCOM_SendBusy : std_logic := '0';
	
	
----
	
	component MainTxController is
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
	end component MainTxController;
	
	signal cTx_Start : std_logic := '0'; --signal to start sending a chirp
	signal cTx_Busy : std_logic := '0';
	signal cTx_MuxSel :std_logic_vector(2 downto 0) := "000"; --match Chirp experiment: divide by 1, TX filter bypass
	
	signal cTx_SQWaveEn :std_logic := '0';
	signal cTx_DownSampleRate :integer range 0 to 65535 := 0; --sampling rate = 165M / (DownSampleRate + 1)
	signal cTx_DataResolution : integer range 0 to 31 := 14;
	signal cTx_Fc :std_logic_vector(31 downto 0) := x"471c4000"; --40 kHz center; match ChirpTxScope40k20ms
	signal cTx_BW :std_logic_vector(31 downto 0) := x"457a0000"; --4 kHz bandwidth: 38-42 kHz
	signal cTx_Tc :std_logic_vector(31 downto 0) := x"3ca3d70a"; --20 ms chirp duration
	signal cTx_A :std_logic_vector(31 downto 0) := x"3e800000"; --0.25 amplitude ratio; match Chirp experiment
	
----
			
	component MainRxController is
		port(
		
			iClk : in std_logic; --165M clk
			iRst : in std_logic := '0';
			
			--control
			iStart : in std_logic := '0'; --start signal of chirp, not Rx, delay done inside
			oBusy : out std_logic := '0';
			
			oFftValid:out std_logic;oFftValue:out std_logic_vector(15 downto 0);
            oCaptureActive:out std_logic;oRawOverflow,oRawClipped:out std_logic;
            --data output
			oDataCnt : out integer range 0 to 16777215 := 0;
			oNewData : out std_logic := '0';
			oValue : out std_logic_vector(15 downto 0) := x"0000";
			
			--parameters
			iTc : in std_logic_vector(31 downto 0) := x"3c23d70a"; --time duration for chirp, F32, s, def = 0.01
			iTd : in std_logic_vector(31 downto 0) := x"3a83126f"; --delay time for sampling after chirp start, F32, s, def = 0.001
			iDownSampleRate : in integer range 0 to 65535 := 0;
			iDataResolution : in integer range 0 to 31 := 16;
			oSamplingPeriod : out std_logic_vector(31 downto 0) := (others => '0'); --interval between two output data, F32, s
			
			--mux control
			iMuxSel : in std_logic_vector(2 downto 0) := "000"; --bit 2 for FLT, 1 downto 0 for gain. 000 for div 1 no flt
			
			--AD interface
			oAD_RST : out std_logic := '1';
			oAD_CS : out std_logic := '1';
			oAD_SCLK : out std_logic := '0';
			oAD_SDI : out std_logic := '0';
			iAD_SDO : in std_logic;
			oAD_START : out std_logic := '1';
			iAD_DRDY : in std_logic;
			oAD_CLK : out std_logic;
			
			--mux
			oRX_MUX_EN : out std_logic := '1';
			oRX_MUX_A : out std_logic_vector(2 downto 0) := "000";
			
			--LED indicators
			oLED_RX_FLT : out std_logic := '0';
			oLED_RX_DIV1 : out std_logic := '0';
			oLED_RX_DIV2 : out std_logic := '0';
			oLED_RX_DIV4 : out std_logic := '0';
			oLED_RX_DIV8 : out std_logic := '0'
		);
	end component MainRxController;
	

	signal cRx_Start : std_logic := '0'; --start signal of chirp, not Rx, delay done inside
	signal cRx_Busy : std_logic := '0';
	signal cRx_MuxSel : std_logic_vector(2 downto 0) := "100"; --bit 2 for FLT, 1 downto 0 for gain. 000 for div 1 no flt
			
	signal cRx_Tc : std_logic_vector(31 downto 0) := MF_RX_TC; --default 250ms continuous-low-frequency bench capture
	signal cRx_Td : std_logic_vector(31 downto 0) := x"3a83126f"; --delay time for sampling after chirp start, F32, s, def = 0.001
	signal cRx_DownSampleRate : integer range 0 to 65535 := MF_RX_DOWNSAMPLE;
	signal cRx_DataResolution : integer range 0 to 31 := 16;
	
	signal cRx_SamplingPeriod : std_logic_vector(31 downto 0) := (others => '0'); --interval between two output data, F32, s
	signal cRx_DataCnt : integer range 0 to 16777215 := 0;
	signal cRx_NewData : std_logic := '0';
	signal cRx_Value : std_logic_vector(15 downto 0) := x"0000";
	
	component MainTMP117Controller is
		port(
			iClk : in std_logic; --PCLK freq
			iRst : in std_logic;
			
			iAddr : in std_logic_vector(7 downto 0) := x"48";
			
			oDataValid : out std_logic := '0';
			oTempData : out std_logic_vector(15 downto 0) := x"0000";
			
			
			oTmp_SCL : out std_logic := '1';
			ioTmp_SDA : inout std_logic := 'Z'
		);
	end component MainTMP117Controller;
	
	signal cTmp_DataValid : std_logic := '0';
	signal cTmp_TempData : std_logic_vector(15 downto 0) := x"0000";

 
 signal cPLL_Locked:std_logic:='0';signal cLockSync:std_logic_vector(1 downto 0):="00";
 signal cFFTDivB,cFFTDivD:std_logic;
 attribute keep:boolean;attribute keep of cFFTDivB,cFFTDivD:signal is true;
 signal cFFTClk:std_logic:='0';signal cFFTRstSync:std_logic_vector(1 downto 0):="11";
 signal cFullValid,cCaptureActive,cRawOverflow,cRawClipped:std_logic:='0';signal cFullValue:std_logic_vector(15 downto 0);
 signal cAutoTriggerDue:boolean:=false;
 signal cFftDone,cFftSend,cFftSendBusy,cFftSendDone:std_logic:='0';
 signal cFftSeq,cFftCount,cFftSpan:std_logic_vector(31 downto 0);signal cFftBin:std_logic_vector(14 downto 0);
 signal cFftPower:std_logic_vector(40 downto 0);signal cFftMin,cFftMax:std_logic_vector(15 downto 0);
 signal cFftFlags,cReportFlags:std_logic_vector(7 downto 0);
 signal cRawTxValid,cFftTxValid:std_logic:='0';signal cRawTxData,cFftTxData:std_logic_vector(7 downto 0);
 signal cTxDac:std_logic_vector(13 downto 0);signal cTxPd:std_logic;
 attribute altera_attribute:string;
 attribute altera_attribute of cLockSync,cFFTRstSync:signal is "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
 component MainFftProcessor is
  generic(VALID_SAMPLES:integer:=8192;SAMPLE_TICKS:integer:=4608;DELTA_W:integer:=6;MIN_BIN:integer:=6;MAX_BIN:integer:=114);
  port(sys_clk,fft_clk,sys_rst,fft_rst,i_start,i_capture_active,i_raw_valid:in std_logic;i_raw_sample:in std_logic_vector(15 downto 0);
   o_done:out std_logic;o_seq,o_count,o_span:out std_logic_vector(31 downto 0);o_bin:out std_logic_vector(14 downto 0);
   o_power:out std_logic_vector(40 downto 0);o_min,o_max:out std_logic_vector(15 downto 0);o_flags:out std_logic_vector(7 downto 0));
 end component;
 component MainPeakReport is
  port(clk,rst,i_start,i_tx_busy:in std_logic;i_seq,i_count,i_span:in std_logic_vector(31 downto 0);
   i_bin:in std_logic_vector(14 downto 0);i_power:in std_logic_vector(40 downto 0);i_min,i_max:in std_logic_vector(15 downto 0);i_flags:in std_logic_vector(7 downto 0);
   o_data:out std_logic_vector(7 downto 0);o_valid,o_busy,o_done:out std_logic);
 end component;

begin

	uPLL : MainPLL port map (refclk => iMAIN_CLK, rst => '0', outclk_0 => cClkH, locked=>cPLL_Locked);

	uUART : UARTController port map (iClk => cClkH, iRst => cRst, iRx => iUART_RXD, oTx => oUART_TXD,
		oRxDataValid => cUART_RxDataValid, oRxData => cUART_RxData, 
		oTxBusy => cUART_TxBusy, iTxDataValid => cUART_TxDataValid, iTxData => cUART_TxData);
		
		
	uRxDepack : RxDepack port map (iClk => cClkH, iRst => cRst, iRxDataValid => cUART_RxDataValid, iRxData => cUART_RxData,
		oTrigger => cSys_Trigger, oRxPackValid => cSys_SettingPackValid, oRxPack => cSys_SettingPack);
		
	
	uTxPack : MainTxPack port map (iClk => cClkH, iRst => cRst, iStart => cCOM_StartSend, oBusy => cCOM_SendBusy,
		iSamplingPeriod => cRx_SamplingPeriod, iDataCnt => cRx_DataCnt, iNewData => cRx_NewData, iValue => cRx_Value, iTempData => cTmp_TempData,
		iTxBusy => cUART_TxBusy, oTxDataValid => cRawTxValid, oTxData => cRawTxData);
		
		
	uTx : MainTxController port map (iClk => cClkH, iRst => cRst, iStart => cTx_Start, oBusy => cTx_Busy,
		--parameters
		iSQWaveEn => cTx_SQWaveEn, iDownSampleRate => cTx_DownSampleRate, iDataResolution => cTx_DataResolution,
		iFc => cTx_Fc, iBW => cTx_BW, iTc => cTx_Tc, iA => cTx_A, iMuxSel => cTx_MuxSel,
		--control output
		oDA_PD => cTxPd, oDA_CLK => open, oDA_D => cTxDac, oTX_MUX_EN => oTX_MUX_EN, oTX_MUX_A => oTX_MUX_A,
		oLED_CHIRP => oLED_CHIRP, oLED_TX_FLT => oLED_TX_FLT, oLED_TX_DIV1 => oLED_TX_DIV1, oLED_TX_DIV2 => oLED_TX_DIV2,
		oLED_TX_DIV4 => oLED_TX_DIV4, oLED_TX_DIV8 => oLED_TX_DIV8);


	uRx : MainRxController port map (iClk => cClkH, iRst => cRst, iStart => cRx_Start, oBusy => cRx_Busy, iMuxSel => cRx_MuxSel,
		--parameters
		iTc => cRx_Tc, iTd => cRx_Td, iDownSampleRate => cRx_DownSampleRate, iDataResolution => cRx_DataResolution,
		--output
		oSamplingPeriod => cRx_SamplingPeriod, oDataCnt => cRx_DataCnt, oNewData => cRx_NewData, oValue => cRx_Value,
        oFftValid=>cFullValid,oFftValue=>cFullValue,oCaptureActive=>cCaptureActive,oRawOverflow=>cRawOverflow,oRawClipped=>cRawClipped,
		--control interface
		oAD_RST => oAD_RST, oAD_CS => oAD_CS, oAD_SCLK => oAD_SCLK, oAD_SDI => oAD_SDI, iAD_SDO => iAD_SDO, 
		oAD_START => oAD_START, iAD_DRDY => iAD_DRDY, oAD_CLK => oAD_CLK,
		oRX_MUX_EN => oRX_MUX_EN, oRX_MUX_A => oRX_MUX_A, oLED_RX_FLT => oLED_RX_FLT, 
		oLED_RX_DIV1 => oLED_RX_DIV1, oLED_RX_DIV2 => oLED_RX_DIV2, oLED_RX_DIV4 => oLED_RX_DIV4, oLED_RX_DIV8 => oLED_RX_DIV8);
		
	uTmp : MainTMP117Controller port map (iClk => cClkH, iRst => cRst, iAddr => x"48",
		oDataValid => cTmp_DataValid, oTempData => cTmp_TempData, oTmp_SCL => oTmp_SCL, ioTmp_SDA => ioTmp_SDA);
	


 -- Preserve two feedback cells so the /2 divider meets fast-corner hold.
 uFFTDivHold0:lcell port map(a_in=>not cFFTClk,a_out=>cFFTDivB);
 uFFTDivHold1:lcell port map(a_in=>cFFTDivB,a_out=>cFFTDivD);
 process(iMAIN_CLK) begin if rising_edge(iMAIN_CLK) then cFFTClk<=cFFTDivD;end if;end process;
 process(cFFTClk) begin if rising_edge(cFFTClk) then cFFTRstSync<=cFFTRstSync(0)&cRst;end if;end process;
 process(cClkH) begin if rising_edge(cClkH) then cLockSync<=cLockSync(0)&cPLL_Locked;oDA_D<=cTxDac;end if;end process;
 oDA_CLK<=not cClkH;oDA_PD<=cTxPd or cRst or not cPLL_Locked;
 cReportFlags<=cFftFlags or (cRawOverflow & "0000" & cRawClipped & "00");
 cUART_TxDataValid<=cFftTxValid when cFftSendBusy='1' else cRawTxValid;
 cUART_TxData<=cFftTxData when cFftSendBusy='1' else cRawTxData;
 uFFT:MainFftProcessor generic map(VALID_SAMPLES=>MF_VALID_SAMPLES,DELTA_W=>MF_DELTA_W,MIN_BIN=>MF_MIN_BIN,MAX_BIN=>MF_MAX_BIN)
 port map(sys_clk=>cClkH,fft_clk=>cFFTClk,sys_rst=>cRst,fft_rst=>cFFTRstSync(1),i_start=>cRx_Start,
 i_capture_active=>cCaptureActive,i_raw_valid=>cFullValid,i_raw_sample=>cFullValue,
 o_done=>cFftDone,o_seq=>cFftSeq,o_count=>cFftCount,o_span=>cFftSpan,o_bin=>cFftBin,o_power=>cFftPower,o_min=>cFftMin,o_max=>cFftMax,o_flags=>cFftFlags);
 uPeakReport:MainPeakReport port map(clk=>cClkH,rst=>cRst,i_start=>cFftSend,i_tx_busy=>cUART_TxBusy,
 i_seq=>cFftSeq,i_count=>cFftCount,i_span=>cFftSpan,i_bin=>cFftBin,i_power=>cFftPower,i_min=>cFftMin,i_max=>cFftMax,i_flags=>cReportFlags,
 o_data=>cFftTxData,o_valid=>cFftTxValid,o_busy=>cFftSendBusy,o_done=>cFftSendDone);

	oLED_STATE <= cRx_Busy;
	
	
	--main process
	
	process(cClkH)
	
		variable vAutoTriggerCnt : integer range 0 to 1650000000 := 0;
		variable vAutoTriggerTh : integer range 0 to 1650000000 := 0;
		variable vCnt : integer range 0 to 164999999 := 0;
		variable vState : integer range 0 to 31 := 0;
	
	begin
	
		if cClkH'event and cClkH = '1' then
            cAutoTriggerDue<=vAutoTriggerCnt>=vAutoTriggerTh;

			
			if cLockSync(1)='0' then
                cRst<='1';vState:=0;vCnt:=0;cTx_Start<='0';cRx_Start<='0';cCOM_StartSend<='0';cFftSend<='0';
            elsif vState = 0 then
				--hold rst for 0.1s 
				
				cRst <= '1';
				if vCnt = BOOT_CYCLES-1 then
					vCnt := 0;
					vState := 1;
				else
					vCnt := vCnt + 1;
				end if;
			
			elsif vState = 1 then
				--release rst for 0.1s 
				
				cRst <= '0';
				if vCnt = BOOT_CYCLES-1 then
					vCnt := 0;
					vState := 2;
				else
					vCnt := vCnt + 1;
				end if;
			
			elsif vState = 2 then
				--wait for trigger
				if ((cSys_AutoTriggerEn = '1') and cAutoTriggerDue) or cSys_Trigger = '1' then
					--start detection
					vAutoTriggerCnt := 0;
					cTx_Start <= '1';
					cRx_Start <= '1';
					vState := 3;
				end if;
				
			elsif vState = 3 then
				--deassert start
				if cTx_Busy = '1' and cRx_Busy = '1' then
					cTx_Start <= '0';
					cRx_Start <= '0';
					vState := 4;
				end if;
				
			elsif vState = 4 then
				--wait for Tx finish
				if cTx_Busy = '0' then
					vState := 5;
				end if;
				
			elsif vState = 5 then
				--wait for Rx finish
				if cRx_Busy = '0' then
					vState := 6;
				end if;
				
			elsif vState = 6 then
				--start send
				cCOM_StartSend <= '1';
				if cCOM_SendBusy = '1' then
					cCOM_StartSend <= '0';
					vState := 7;
				end if;
				
			elsif vState = 7 then
				--wait for send
				if cCOM_SendBusy = '0' then
					vState := 8;
				end if;
				
			elsif vState = 8 then
                if cFftDone='1' then vState:=9;end if;
            elsif vState = 9 then
                cFftSend<='1';if cFftSendBusy='1' then cFftSend<='0';vState:=10;end if;
            elsif vState = 10 then
                if cFftSendBusy='0' and cUART_TxBusy='0' then vState:=31;end if;
            elsif vState = 31 then
			
				--goto next cycle
				vState := 2;
				
			end if;
			
			
			
            if vAutoTriggerCnt<1650000000 then vAutoTriggerCnt := vAutoTriggerCnt + 1;end if;
			if cSys_AutoTriggerPeriod <= 10000 then
				vAutoTriggerTh := cSys_AutoTriggerPeriod * 165000;
			else
				vAutoTriggerTh := 1650000000;
			end if;
			
		
			--mapping settings from pack to signals		
			if cSys_SettingPackValid = '1' then
				
				cSys_AutoTriggerEn <= cSys_SettingPack(0)(0);
				cSys_AutoTriggerPeriod <= conv_integer(cSys_SettingPack(3) & cSys_SettingPack(2));
				
				cTx_SQWaveEn <= cSys_SettingPack(4)(0);
				cTx_DownSampleRate <= conv_integer(cSys_SettingPack(6) & cSys_SettingPack(5));
				cTx_DataResolution <= conv_integer(cSys_SettingPack(7));
				cTx_Fc <= (cSys_SettingPack(11) & cSys_SettingPack(10) & cSys_SettingPack(9) & cSys_SettingPack(8));
				cTx_BW <= (cSys_SettingPack(15) & cSys_SettingPack(14) & cSys_SettingPack(13) & cSys_SettingPack(12));
				cTx_Tc <= (cSys_SettingPack(19) & cSys_SettingPack(18) & cSys_SettingPack(17) & cSys_SettingPack(16));
				cTx_A <= (cSys_SettingPack(23) & cSys_SettingPack(22) & cSys_SettingPack(21) & cSys_SettingPack(20));
				cTx_MuxSel <= cSys_SettingPack(24)(2 downto 0);
				
				cRx_Tc <= (cSys_SettingPack(39) & cSys_SettingPack(38) & cSys_SettingPack(37) & cSys_SettingPack(36));
				cRx_Td <= (cSys_SettingPack(43) & cSys_SettingPack(42) & cSys_SettingPack(41) & cSys_SettingPack(40));
				cRx_DownSampleRate <= conv_integer(cSys_SettingPack(45) & cSys_SettingPack(44));
				cRx_DataResolution <= conv_integer(cSys_SettingPack(46));
				cRx_MuxSel <= cSys_SettingPack(47)(2 downto 0);
			
			end if;
		
		
		
		end if;
	
	end process;
	




end architecture Beh;