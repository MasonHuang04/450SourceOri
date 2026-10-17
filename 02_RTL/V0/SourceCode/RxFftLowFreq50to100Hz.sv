// External 50-100 Hz sine test. Original ADC/PLL clocks retained.
// CIC3 /128 -> 2048 effective samples, about 228.78 ms, FFT bin spacing 4.371 Hz.
module RxFftLowFreq50to100Hz #(
 parameter integer RESET_ADC_CYCLES=2048,RESET_FFT_CYCLES=50000,
 parameter integer BOOT_TICKS=2500000,REPEAT_TICKS=12500000,
 parameter integer CAP_TIMEOUT_TICKS=13750000
)(input wire iMAIN_CLK,
 output wire oLED_STATE,oLED_CHIRP,oLED_TX_FLT,oLED_TX_DIV1,oLED_TX_DIV2,oLED_TX_DIV4,oLED_TX_DIV8,
 output wire oLED_RX_FLT,oLED_RX_DIV1,oLED_RX_DIV2,oLED_RX_DIV4,oLED_RX_DIV8,
 output wire oTMP_SCL,inout wire ioTMP_SDA,
 output wire oUART_TXD,input wire iUART_RXD,output wire oUART_CTS,input wire iUART_RTS,
 output wire oAD_RST,oAD_CS,oAD_SCLK,oAD_SDI,input wire iAD_SDO,
 output wire oAD_START,input wire iAD_DRDY,output wire oAD_CLK,
 output wire oDA_PD,oDA_CLK,output wire [13:0] oDA_D,
 output wire oTX_MUX_EN,output wire [2:0] oTX_MUX_A,
 output wire oRX_MUX_EN,output wire [2:0] oRX_MUX_A);
 wire sysclk,locked;
 MainPLL pll(.refclk(iMAIN_CLK),.rst(1'b0),.outclk_0(sysclk),.locked(locked));
 logic [2:0] divide_count=0;
 logic adc_clock=0,fft_clock=0;
 always_ff @(posedge sysclk)begin
  if(divide_count==2)adc_clock<=1;
  if(divide_count==5)begin adc_clock<=0;divide_count<=0;end
  else divide_count<=divide_count+1'b1;
 end
 always_ff @(posedge iMAIN_CLK)fft_clock<=~fft_clock;
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] adc_lock_sync=0,fft_lock_sync=0;
 logic [$clog2(RESET_ADC_CYCLES+1)-1:0] adc_reset_count=0;
 logic [$clog2(RESET_FFT_CYCLES+1)-1:0] fft_reset_count=0;
 wire adc_rst=adc_reset_count<RESET_ADC_CYCLES;
 wire fft_rst=fft_reset_count<RESET_FFT_CYCLES;
 always_ff @(posedge adc_clock)begin
  adc_lock_sync<={adc_lock_sync[0],locked};
  if(!adc_lock_sync[1])adc_reset_count<=0;
  else if(adc_rst)adc_reset_count<=adc_reset_count+1'b1;
 end
 always_ff @(posedge fft_clock)begin
  fft_lock_sync<={fft_lock_sync[0],locked};
  if(!fft_lock_sync[1])fft_reset_count<=0;
  else if(fft_rst)fft_reset_count<=fft_reset_count+1'b1;
 end
 wire adc_ready,adc_valid,activity,heartbeat;wire signed [15:0] adc_sample;
 ScopeAdc27m5 adc(.clk(adc_clock),.rst(adc_rst),.sdo(iAD_SDO),.drdy(iAD_DRDY),
 .reset_n(oAD_RST),.cs_n(oAD_CS),.sdi(oAD_SDI),.sclk(oAD_SCLK),.start(oAD_START),
 .initialized(adc_ready),.valid(adc_valid),.sample(adc_sample));
 wire low_valid,low_ready,low_clip; wire signed [15:0] low_sample;
 ScopeCic128 filter(.clk(adc_clock),.rst(adc_rst),.i_valid(adc_valid),.i_sample(adc_sample),
 .o_valid(low_valid),.o_sample(low_sample),.o_ready(low_ready),.o_clipped(low_clip));
 assign oAD_CLK=adc_clock;
 ScopeRxFft #(.BOOT_TICKS(BOOT_TICKS),.REPEAT_TICKS(REPEAT_TICKS),.CAP_TIMEOUT_TICKS(CAP_TIMEOUT_TICKS)) engine(
 .adc_clk(adc_clock),.fft_clk(fft_clock),.adc_rst(adc_rst),.fft_rst(fft_rst),
 .adc_ready(adc_ready&&low_ready),.adc_valid(low_valid),.adc_sample(low_sample),.adc_clipped(low_clip),
 .uart_tx(oUART_TXD),.activity(activity),.heartbeat(heartbeat));
 assign oRX_MUX_EN=1'b1;assign oRX_MUX_A=3'b011; // bypass LPF, divide by 8
 assign oLED_STATE=adc_ready;assign oLED_CHIRP=activity;
 assign oLED_RX_DIV8=1'b1;assign oLED_RX_DIV1=0;assign oLED_RX_DIV2=0;assign oLED_RX_DIV4=0;assign oLED_RX_FLT=0;
 assign oLED_TX_DIV1=0;assign oLED_TX_DIV2=0;assign oLED_TX_DIV4=0;assign oLED_TX_DIV8=heartbeat;assign oLED_TX_FLT=0;
 assign oDA_PD=1;assign oDA_CLK=0;assign oDA_D=14'd8192;assign oTX_MUX_EN=0;assign oTX_MUX_A=0;
 assign oUART_CTS=1'bz;assign oTMP_SCL=1'bz;assign ioTMP_SDA=1'bz;
endmodule
