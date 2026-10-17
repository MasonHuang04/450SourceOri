library ieee;
use ieee.std_logic_1164.all;
use work.ChirpSettings.all;

entity ChirpTxScope40k20ms is
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
end entity ChirpTxScope40k20ms;

-- Independent physical-board test top. Reuses original PLL, TxController,
-- ChirpWaveGen and Intel IP. The production UsMimoTestBench top is unchanged.
-- Auto: 38-42 kHz over 20 ms, every 200 ms; amplitude 0.25; TX LPF bypass.
architecture rtl of ChirpTxScope40k20ms is
 component MainPLL is
  port(refclk,rst:in std_logic;outclk_0,locked:out std_logic);
 end component;
 signal sysclk,pll_locked,tx_reset,tx_start,tx_busy,pd,ready:std_logic:='0';
 signal tx_pd:std_logic;
 signal dac_data:std_logic_vector(13 downto 0):="10000000000000";
begin
 pll:MainPLL port map(refclk=>iMAIN_CLK,rst=>'0',outclk_0=>sysclk,locked=>pll_locked);
 sequence_control:entity work.ScopeBurstControl(rtl)
  generic map(BOOT_CYCLES=>CFG_BOOT_CYCLES,PERIOD_CYCLES=>CFG_PERIOD_CYCLES)
  port map(clk=>sysclk,pll_locked=>pll_locked,tx_busy=>tx_busy,
           tx_reset=>tx_reset,tx_start=>tx_start,dac_power_down=>pd,ready=>ready);
 tx:entity work.TxController(Beh)
  port map(iClk=>sysclk,iRst=>tx_reset,iStart=>tx_start,oBusy=>tx_busy,
   iSQWaveEn=>'0',iDownSampleRate=>0,iDataResolution=>14,
   iFc=>CFG_FC,iBW=>CFG_BW,iTc=>CFG_TC,iA=>CFG_AMPLITUDE,iMuxSel=>"000",
   oDA_PD=>tx_pd,oDA_CLK=>open,oDA_D=>dac_data,oTX_MUX_EN=>oTX_MUX_EN,oTX_MUX_A=>oTX_MUX_A,
   oLED_CHIRP=>oLED_CHIRP,oLED_TX_FLT=>oLED_TX_FLT,oLED_TX_DIV1=>oLED_TX_DIV1,
   oLED_TX_DIV2=>oLED_TX_DIV2,oLED_TX_DIV4=>oLED_TX_DIV4,oLED_TX_DIV8=>oLED_TX_DIV8);
 -- DAC904 samples rising CLK. Invert the forwarded clock so its capture edge
 -- is halfway between successive data updates; external setup/hold are in SDC.
 -- Separate I/O register removes long controller-to-pin control routing.
 -- Adds one fixed system-clock latency without changing the Chirp sweep.
 process(sysclk) begin
  if rising_edge(sysclk) then oDA_D<=dac_data;end if;
 end process;
 oDA_CLK<=not sysclk;
 oDA_PD<=pd or tx_pd or not pll_locked;
 oLED_STATE<=ready;
 -- Defined inactive states for the rest of the existing board pinout.
 oAD_RST<='0';oAD_CS<='1';oAD_SCLK<='0';oAD_SDI<='0';oAD_START<='0';oAD_CLK<='0';
 oRX_MUX_EN<='0';oRX_MUX_A<="011";
 oLED_RX_FLT<='0';oLED_RX_DIV1<='0';oLED_RX_DIV2<='0';oLED_RX_DIV4<='0';oLED_RX_DIV8<='0';
 oUART_TXD<='1';oUART_CTS<='Z';oTMP_SCL<='Z';ioTMP_SDA<='Z';
end;
