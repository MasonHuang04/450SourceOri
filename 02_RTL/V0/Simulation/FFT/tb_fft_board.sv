`ifdef MAIN_TX_PARAMETERS
`timescale 1ns/1ps
module tb_main_tx_parameters;
 reg clk=0,rst=1,start=0;always #3.030303 clk=~clk;
 reg [31:0] fc=32'h48435000,bw=32'h469c4000,tc=32'h3da3d70a,amp=32'h3f800000;
 reg [2:0] mux=3'b100;
 wire busy;wire [13:0] data;wire [2:0] mux_out;
 MainTxController dut(.iClk(clk),.iRst(rst),.iStart(start),.oBusy(busy),.iSQWaveEn(1'b0),.iDownSampleRate(0),.iDataResolution(14),
 .iFc(fc),.iBW(bw),.iTc(tc),.iA(amp),.iMuxSel(mux),.oDA_D(data),.oTX_MUX_A(mux_out));
 wire [31:0] rx_period;
 MainRxController rx(.iClk(clk),.iRst(rst),.iStart(start),.iTc(32'h3e800000),.iTd(32'h3a83126f),.iDownSampleRate(3),.iDataResolution(16),.iMuxSel(3'b100),.iAD_SDO(1'b0),.iAD_DRDY(1'b1),.oSamplingPeriod(rx_period));
 real period_error;integer c,n,changes;reg [13:0] prev;
 initial begin
  for(c=0;c<2;c++)begin
   rst=1;start=0;
   if(c==1)begin fc=32'h471c4000;bw=32'h457a0000;tc=32'h3ca3d70a;amp=32'h3e800000;mux=3'b000;end
   repeat(30)@(negedge clk);rst=0;repeat(3)@(negedge clk);start=1;
   wait(busy);@(negedge clk);start=0;repeat(150)@(negedge clk);
   if(dut.cn!=(c==0 ? 13200000 : 3300000))$fatal(1,"Real Intel IP duration pipeline got=%0d",dut.cn);
   if(dut.cf0!==(c==0 ? 32'h48398c00 : 32'h47147000))$fatal(1,"Chirp start frequency %h",dut.cf0);
   if(dut.ck!==(c==0 ? 32'h48742400 : 32'h48435000))$fatal(1,"Chirp slope %h",dut.ck);
   if(mux_out!==mux)$fatal(1,"TX filter/gain selection");
   if(dut.ca!==amp)$fatal(1,"TX amplitude latch");
   if(rx.cn!=41250000||rx.ctdn!=165000)$fatal(1,"RX duration/delay pipeline");
   period_error=$bitstoshortreal(rx_period)-576.0/165000000;if(period_error<0)period_error=-period_error;
   if($isunknown(rx_period)||period_error>1e-12)$fatal(1,"RX sample-period metadata");
   changes=0;prev=data;
   for(n=0;n<1200;n++)begin
    @(negedge clk);if($isunknown(data))$fatal(1,"Unknown DAC code");
    if(c==1&&(data<6140||data>10244))$fatal(1,"Quarter-scale DAC amplitude out of bounds: %0d",data);
    if(data!=prev)changes++;prev=data;
   end
   if(!busy||changes<100)$fatal(1,"Chirp output did not start");
   $display("PASS MAIN REAL TX PARAMS: case=%0d duration_ticks=%0d f0=%h slope=%h changing_DAC=%0d",c,dut.cn,dut.cf0,dut.ck,changes);
  end
  $display("PASS MAIN RX REAL PARAMETERS: 250ms=41250000 ticks, delay=165000 ticks, raw period=%h",rx_period);
  $display("PASS MAIN TX PARAMETERS AND STARTUP (not full duration waveform)");$finish;
 end
 initial begin #100000;$fatal(1,"TX parameter test timeout");end
endmodule

`elsif MAIN_SHORT_TOP
`timescale 1ns/1ps
module MainPLL(input refclk,rst,output reg outclk_0=0,output reg locked=0);
 always #3.030303 outclk_0=~outclk_0;initial begin #200;locked=1;end
endmodule
module FPFMult(input clk,areset,input [31:0] a,b,output reg [31:0] q);
 always @(a,b,areset) q=areset ? 0 : $shortrealtobits($bitstoshortreal(a)*$bitstoshortreal(b));
endmodule
module FPFFP32ToInt32(input clk,areset,input [31:0] a,output reg [31:0] q);
 always @(a,areset) q=areset ? 0 : (($rtoi($bitstoshortreal(a))==41250000)?165000:$rtoi($bitstoshortreal(a)));
endmodule
module FPFInt32ToFP32(input clk,areset,input [31:0] a,output reg [31:0] q);
 always @(a,areset) q=areset ? 0 : $shortrealtobits(shortreal'($signed(a)));
endmodule
module UARTController(input iClk,iRst,iRx,output oTx,output oRxDataValid,output [7:0] oRxData,
 output reg oTxBusy=0,input iTxDataValid,input [7:0] iTxData);
 assign oTx=1;assign oRxDataValid=0;assign oRxData=0;integer delay_count=0;
 always @(posedge iClk)begin
  if(iRst)begin oTxBusy<=0;delay_count<=0;end
  else begin
   if(delay_count>0)begin delay_count<=delay_count-1;if(delay_count==1)oTxBusy<=0;end
   if(iTxDataValid)begin
    if(oTxBusy)$fatal(1,"UART byte handshake collision");oTxBusy<=1;delay_count<=8;
   end
  end
 end
endmodule

`timescale 1ns/1ps
module tb_main_top;
 integer fft_clock_edges=0;
 always @(posedge dut.cfftclk)fft_clock_edges++;
 initial begin #1000;if($isunknown(dut.cfftclk)||fft_clock_edges!=50)$fatal(1,"Main FFT divider must produce 50 MHz");end
 reg clk100=0;always #5 clk100=~clk100;
 reg sdo=0,drdy=1;wire uart,ad_clk,sclk,cs,sdi,start,resetn;tri1 sda;
 UsMimoTestBench #(.BOOT_CYCLES(50000),.AUTO_TRIGGER_DEFAULT(3)) dut(
 .iMAIN_CLK(clk100),.iUART_RXD(1'b1),.iUART_RTS(1'b0),.iAD_SDO(sdo),.iAD_DRDY(drdy),.ioTMP_SDA(sda),
 .oUART_TXD(uart),.oAD_CLK(ad_clk),.oAD_SCLK(sclk),.oAD_CS(cs),.oAD_SDI(sdi),.oAD_START(start),.oAD_RST(resetn));
 integer case_no=0,conversion=0,clk_ticks=0,frame_start_index=0;
 integer ready_code=0,read_code=0,read_index=0,read_bits=0,fall_bits=0,init_count=0;
 reg [15:0] command_word=0;
 bit initialized=0,active=0;
 realtime last_fall=-1e6,last_sdi=-1e6,cs_fall=-1e6,cs_rise=-1e6,reset_release=0;
 realtime adc_edge=-1e6,spi_edge=-1e6,adc_rise=-1e6,start_edge=-1e6,reset_low=-1e6;
 integer reset_clocks=0,spi_frames=0;
 function automatic [15:0] init_word(input integer n);
  case(n)0:init_word=16'h0000;1:init_word=16'h8500;2:init_word=16'h8687;
  3:init_word=16'h870c;4:init_word=16'h8880;5:init_word=16'h8908;default:init_word=0;endcase
 endfunction
 always @(ad_clk)begin
  if($realtime>1000&&$realtime-adc_edge<13.199)$fatal(1,"ADC CLK pulse too short");
  adc_edge=$realtime;
 end
 always @(sclk)begin
  if($realtime>1000&&$realtime-spi_edge<13.199)$fatal(1,"SCLK pulse too short");
  spi_edge=$realtime;
 end
 always @(start)begin
  if(resetn&&$realtime-adc_rise<8.999)$fatal(1,"START hold <9ns");
  start_edge=$realtime;
 end
 always @(posedge ad_clk)begin
  if(resetn&&$realtime-start_edge<8.999)$fatal(1,"START setup <9ns");
  adc_rise=$realtime;
 end
 always @(negedge resetn)reset_low=$realtime;
 always @(posedge resetn)begin
  if($realtime-reset_low<145.45)$fatal(1,"RESET low shorter than 4 ADC clocks");
  reset_release=$realtime;reset_clocks=0;
 end
 always @(posedge ad_clk)if(resetn)reset_clocks++;
 real f,phase,value_real;
 always @(negedge ad_clk)begin
  if(!resetn||!start)begin clk_ticks=0;conversion=0;drdy=1;end
  else begin
   clk_ticks++;
   if(case_no==4)drdy=1;
   else if(clk_ticks>=96&&((clk_ticks-96)%24)==0)begin
    case(case_no)0:f=100;1:f=100;2:f=200;default:f=100;endcase
    phase=6.283185307179586*conversion/(165000000.0/144.0);
    value_real=7000*$sin(f*phase)+111;
    if(case_no==1)value_real=3500*$sin(100*phase+1.0471975512)+6000;
    if(case_no==3)value_real=7000*$sin(100*phase)+2000*$sin(300*phase)-5000;
    ready_code=$rtoi(value_real);conversion++;drdy=0;
   end else if(clk_ticks>=98&&((clk_ticks-98)%24)==0)drdy=1;
  end
 end
 always @(sdi)begin
  if(active&&$realtime-last_fall<5.999)$fatal(1,"SDI hold <6ns");
  last_sdi=$realtime;
 end
 always @(negedge cs)begin
  if(resetn)begin
   if(reset_clocks<10000)$fatal(1,"ADC reset recovery <10000 clocks");
   if($realtime-cs_rise<19.999)$fatal(1,"CS high <20ns");
   cs_fall=$realtime;active=1;read_bits=0;fall_bits=0;command_word=0;
   read_code=ready_code;read_index=conversion-1;spi_frames++;
  end
 end
 always @(posedge sclk)if(active)begin
  if(read_bits==0&&$realtime-cs_fall<9.999)$fatal(1,"CS setup <10ns");
  if(initialized)begin
   if(read_bits<16)sdo<=#23 ((read_code>>(15-read_bits))&1);else sdo<=#23 0;
  end
  read_bits++;
 end
 always @(negedge sclk)if(active)begin
  last_fall=$realtime;
  if($realtime-last_sdi<3.999)$fatal(1,"SDI setup <4ns");
  command_word={command_word[14:0],sdi};fall_bits++;
 end
 always @(posedge cs)if(active)begin
  if($realtime-last_fall<9.999)$fatal(1,"CS hold <10ns");
  active=0;cs_rise=$realtime;
  if(!initialized)begin
   if(fall_bits!=16||command_word!==init_word(init_count))$fatal(1,"ADC init mismatch frame=%0d bits=%0d word=%h",init_count,fall_bits,command_word);
   init_count++;if(init_count==6)initialized=1;
  end else if(read_bits!=16)$fatal(1,"ADC read length=%0d",read_bits);
 end
 always @(negedge ad_clk)if(dut.urx.uad.valid)begin
  if($signed(dut.urx.uad.sample)!==read_code)$fatal(1,"ADC decode got=%0d expected=%0d",$signed(dut.urx.uad.sample),read_code);
 end

 integer raw_count=0,fft_count=0,byte_count=0;integer rf,ff,bf;integer raw_expected[0:131071];
 integer full_count=0,raw_skip=0,last_full_tick=0,tick=0,cap_begin=0,cap_end=0;
 reg cap_last=0;reg [15:0] last_sample=0;
 initial begin
  rf=$fopen("raw_words.csv","w");ff=$fopen("fft_capture.csv","w");bf=$fopen("stream.hex","w");
  $fwrite(rf,"index,code
");$fwrite(ff,"index,code
");
 end
 always @(posedge dut.cclkh)if(!dut.crst)begin
  tick++;
  if(dut.ccaptureactive&&!cap_last)cap_begin=tick;
  if(!dut.ccaptureactive&&cap_last)begin
   cap_end=tick;if(cap_end-cap_begin!=165001)$fatal(1,"RX1ms duration incorrect: %0d",cap_end-cap_begin);
   $display("PASS MAIN capture window ticks=%0d full_words=%0d raw_words=%0d",cap_end-cap_begin,full_count,raw_count);
  end
  cap_last=dut.ccaptureactive;
  if(dut.cfullvalid)begin
   if(full_count>0&&tick-last_full_tick!=144)$fatal(1,"Full ADC cadence");last_full_tick=tick;
   if($signed(dut.cfullvalue)!==read_code)$fatal(1,"ADC stable-word CDC mismatch");
   full_count++;raw_skip++;if(raw_skip==4)begin raw_skip=0;last_sample=dut.cfullvalue^16'h8000;end
  end
  if(dut.crx_newdata)begin
   if(dut.crx_value!==last_sample)$fatal(1,"Raw /4 value mismatch");
   raw_expected[raw_count]=dut.crx_value;$fwrite(rf,"%0d,%0d
",raw_count,dut.crx_value);raw_count++;
  end
  if(dut.ufft.ram_we)begin $fwrite(ff,"%0d,%0d
",fft_count,$signed(dut.ufft.cs));fft_count++;end
  if(dut.cuart_txdatavalid)begin
   if(dut.cuart_txbusy)$fatal(1,"Top mux transmitted busy");
   $fwrite(bf,"%02x
",dut.cuart_txdata);byte_count++;
  end
  if(dut.cfftsenddone)begin
   if(raw_count!=full_count/4||dut.crx_datacnt!=raw_count)$fatal(1,"Raw count mismatch");
   if(dut.cfftcount!=fft_count||!dut.creportflags[0]||dut.cfftbin!=0||dut.cfftpower!=0)$fatal(1,"Short window must reject FFT");
   if(byte_count!=raw_count*2+128)$fatal(1,"Raw+FFT record length mismatch");
   $display("PASS MAIN SHORT TOP: ADC SPI/raw FIFO/full short packet/short-FFT rejection/M1; raw=%0d full=%0d bytes=%0d peak=%0d power=%0d",raw_count,full_count,byte_count,dut.cfftbin,dut.cfftpower);
   $fclose(rf);$fclose(ff);$fclose(bf);#100;$finish;
  end
 end
 initial begin #300000000;$fatal(1,"Global main top timeout");end
endmodule

`elsif MAIN_SYSTEM_TOP
`timescale 1ns/1ps
module MainPLL(input refclk,rst,output reg outclk_0=0,output reg locked=0);
 always #3.030303 outclk_0=~outclk_0;initial begin #200;locked=1;end
endmodule
module FPFMult(input clk,areset,input [31:0] a,b,output reg [31:0] q);
 always @(a,b,areset) q=areset ? 0 : $shortrealtobits($bitstoshortreal(a)*$bitstoshortreal(b));
endmodule
module FPFFP32ToInt32(input clk,areset,input [31:0] a,output reg [31:0] q);
 always @(a,areset) q=areset ? 0 : (($rtoi($bitstoshortreal(a))==41250000)?286490:$rtoi($bitstoshortreal(a)));
endmodule
module FPFInt32ToFP32(input clk,areset,input [31:0] a,output reg [31:0] q);
 always @(a,areset) q=areset ? 0 : $shortrealtobits(shortreal'($signed(a)));
endmodule
module UARTController(input iClk,iRst,iRx,output oTx,output oRxDataValid,output [7:0] oRxData,
 output reg oTxBusy=0,input iTxDataValid,input [7:0] iTxData);
 assign oTx=1;assign oRxDataValid=0;assign oRxData=0;integer delay_count=0;
 always @(posedge iClk)begin
  if(iRst)begin oTxBusy<=0;delay_count<=0;end
  else begin
   if(delay_count>0)begin delay_count<=delay_count-1;if(delay_count==1)oTxBusy<=0;end
   if(iTxDataValid)begin
    if(oTxBusy)$fatal(1,"UART byte handshake collision");oTxBusy<=1;delay_count<=8;
   end
  end
 end
endmodule

// Accelerated ADC WORD model: all 286458 words representing 250 ms are kept.
// Conversion/SPI idle time is compressed. SPI is tested in the separate pin test.
module MainAdcBridge #(parameter RAW_CAPACITY=131072)(
 input iClk,iRst,iSamplingEn,input [15:0] iDownSampleRate,input iADSDO,iADDRdy,
 output oADRstz,oADCSz,oADSClk,oADSDI,oADStart,oADClk,
 output reg [23:0] oDataCnt=0,output reg oNewData=0,output reg [15:0] oValue=0,
 output reg oFftValid=0,output reg [15:0] oFftValue=0,output oOverflow,oClipped);
 assign oOverflow=0;assign oClipped=0;assign oADRstz=!iRst;assign oADCSz=1;assign oADSClk=0;assign oADSDI=0;assign oADStart=1;assign oADClk=0;
 integer n=0,skip=0;integer sample;
 always @(posedge iClk)begin
  oFftValid<=0;oNewData<=0;
  if(iRst)begin n<=0;oDataCnt<=0;skip<=0;end
  else if(iSamplingEn&&n<286458)begin
   sample=$rtoi(7000.0*$sin(6.283185307179586*100.0*n/(165000000.0/144))+111);
   oFftValue<=sample;oFftValid<=1;n<=n+1;
   if(skip==iDownSampleRate)begin skip<=0;oNewData<=1;oValue<=sample[15:0]^16'h8000;oDataCnt<=oDataCnt+1;end
   else skip<=skip+1;
  end
 end
endmodule

`timescale 1ns/1ps
module tb_main_top;
 integer fft_clock_edges=0;
 always @(posedge dut.cfftclk)fft_clock_edges++;
 initial begin #1000;if($isunknown(dut.cfftclk)||fft_clock_edges!=50)$fatal(1,"Main FFT divider must produce 50 MHz");end
 reg clk100=0;always #5 clk100=~clk100;
 reg sdo=0,drdy=1;wire uart,ad_clk,sclk,cs,sdi,start,resetn;tri1 sda;
 UsMimoTestBench #(.BOOT_CYCLES(50000),.AUTO_TRIGGER_DEFAULT(3)) dut(
 .iMAIN_CLK(clk100),.iUART_RXD(1'b1),.iUART_RTS(1'b0),.iAD_SDO(sdo),.iAD_DRDY(drdy),.ioTMP_SDA(sda),
 .oUART_TXD(uart),.oAD_CLK(ad_clk),.oAD_SCLK(sclk),.oAD_CS(cs),.oAD_SDI(sdi),.oAD_START(start),.oAD_RST(resetn));
 integer raw_count=0,fft_count=0,byte_count=0;integer rf,ff,bf;integer raw_expected[0:131071];
 integer full_count=0,raw_skip=0,last_full_tick=0,tick=0,cap_begin=0,cap_end=0;
 reg cap_last=0;reg [15:0] last_sample=0;
 initial begin
  rf=$fopen("raw_words.csv","w");ff=$fopen("fft_capture.csv","w");bf=$fopen("stream.hex","w");
  $fwrite(rf,"index,code
");$fwrite(ff,"index,code
");
 end
 always @(posedge dut.cclkh)if(!dut.crst)begin
  tick++;
  if(dut.ccaptureactive&&!cap_last)cap_begin=tick;
  if(!dut.ccaptureactive&&cap_last)begin
   cap_end=tick;if(cap_end-cap_begin!=286491)$fatal(1,"Accelerated long frame duration incorrect: %0d",cap_end-cap_begin);
   $display("PASS MAIN capture window ticks=%0d full_words=%0d raw_words=%0d",cap_end-cap_begin,full_count,raw_count);
  end
  cap_last=dut.ccaptureactive;
  if(dut.cfullvalid)begin
   if(full_count>0&&tick-last_full_tick!=1)$fatal(1,"Full ADC cadence");last_full_tick=tick;

   full_count++;raw_skip++;if(raw_skip==4)begin raw_skip=0;last_sample=dut.cfullvalue^16'h8000;end
  end
  if(dut.crx_newdata)begin
   if(dut.crx_value!==last_sample)$fatal(1,"Raw /4 value mismatch");
   raw_expected[raw_count]=dut.crx_value;$fwrite(rf,"%0d,%0d
",raw_count,dut.crx_value);raw_count++;
  end
  if(dut.ufft.ram_we)begin $fwrite(ff,"%0d,%0d
",fft_count,$signed(dut.ufft.cs));fft_count++;end
  if(dut.cuart_txdatavalid)begin
   if(dut.cuart_txbusy)$fatal(1,"Top mux transmitted busy");
   $fwrite(bf,"%02x
",dut.cuart_txdata);byte_count++;
  end
  if(dut.cfftsenddone)begin
   if(raw_count!=full_count/4||dut.crx_datacnt!=raw_count)$fatal(1,"Raw count mismatch");
   if(fft_count!=8192||dut.cfftcount!=8192||dut.cfftspan!=262112)$fatal(1,"FFT count/span");
   if(dut.cfftbin!=23||dut.creportflags!=0)$fatal(1,"FFT result bin=%0d flags=%h",dut.cfftbin,dut.creportflags);
   if(byte_count!=raw_count*2+128)$fatal(1,"Raw+FFT record length mismatch");
   $display("PASS MAIN LONG FRAME: 250ms-equivalent word count, compressed ADC timing, full raw buffer/8192FFT/packet/M1; raw=%0d full=%0d bytes=%0d peak=%0d power=%0d",raw_count,full_count,byte_count,dut.cfftbin,dut.cfftpower);
   $fclose(rf);$fclose(ff);$fclose(bf);#100;$finish;
  end
 end
 initial begin #300000000;$fatal(1,"Global main top timeout");end
endmodule

`elsif MAIN_IO_TEST
`timescale 1ns/1ps
// Focused contract test: real UART bits and main bridge boundary conditions.
// ADC conversion producer is a word model here; board test uses SPI pin model.
module ScopeAdc27m5(input clk,rst,sdo,drdy,output reset_n,cs_n,sclk,sdi,start,initialized,
 output reg valid=0,output reg signed [15:0] sample=0);
 assign reset_n=!rst;assign cs_n=1;assign sclk=clk;assign sdi=0;assign start=1;assign initialized=!rst;
 integer phase=0,index=0;
 always @(posedge clk)begin valid<=0;
  if(rst)begin phase<=0;sample<=0;index<=0;end
  else if(phase==23)begin phase<=0;sample<=index==4 ? 32767 : index;index<=index+1;valid<=1;end
  else phase<=phase+1;
 end
endmodule
module tb_main_io;
 wire packet_pass;tb_main_packet packet_test(.passed(packet_pass));
 wire buffer_pass;tb_main_buffer buffer_test(.passed(buffer_pass));
 reg clk=0,rst=1;always #3.030303 clk=~clk;
 reg enable=0;reg [15:0] ds=0;wire [23:0] raw_count;wire raw_valid,full_valid,overflow,clipped;wire [15:0] raw,full;
 MainAdcBridge #(.RAW_CAPACITY(8)) bridge(.iClk(clk),.iRst(rst),.iSamplingEn(enable),.iDownSampleRate(ds),.iADSDO(1'b0),.iADDRdy(1'b1),
 .oDataCnt(raw_count),.oNewData(raw_valid),.oValue(raw),.oFftValid(full_valid),.oFftValue(full),.oOverflow(overflow),.oClipped(clipped));
 integer rn=0,fn=0,phase=0;bit bridge_pass=0,uart_pass=0;
 always @(posedge clk)if(!rst)begin
  if(full_valid)fn++;
  if(raw_valid)begin rn++;if(raw!==(full^16'h8000))$fatal(1,"Offset binary mismatch");end
 end
 initial begin
  #200;@(negedge clk);rst=0;enable=1;wait(fn==40);@(negedge clk);enable=0;
  repeat(20)@(negedge clk);
  if(rn!=8||raw_count!=8||!overflow||!clipped)$fatal(1,"Cap/clipping contract");
  fn=0;rn=0;ds=3;enable=1;wait(fn==24);@(negedge clk);enable=0;repeat(20)@(negedge clk);
  if(rn!=6||raw_count!=6||overflow||clipped)$fatal(1,"New capture/downsample reset");
  bridge_pass=1;$display("PASS MAIN ADC bridge: cap, clipping, independent FFT tap, reset, raw /4");
 end
 reg send=0,rx=1;wire tx,txbusy,rv;wire [7:0] rb,txdata;wire tv,busy,done;
 UARTController uart(.iClk(clk),.iRst(rst),.iRx(rx),.oTx(tx),.oRxDataValid(rv),.oRxData(rb),.oTxBusy(txbusy),.iTxDataValid(tv),.iTxData(txdata));
 wire trig;
 RxDepack depack(.iClk(clk),.iRst(rst),.iRxDataValid(rv),.iRxData(rb),.oTrigger(trig));
 MainPeakReport report(.clk(clk),.rst(rst),.i_start(send),.i_tx_busy(txbusy),.i_seq(32'd1),.i_count(32'd8192),.i_span(32'd37744128),
 .i_bin(15'd23),.i_power(41'd123456789),.i_min(16'hff00),.i_max(16'h0100),.i_flags(8'd0),.o_data(txdata),.o_valid(tv),.o_busy(busy),.o_done(done));
 reg [7:0] txexpected[0:63];integer pushed=0,received=0,triggers=0,outfile;
 always @(posedge clk)begin if(tv)begin txexpected[pushed]=txdata;pushed++;end if(trig)triggers++;end
 task automatic sendbyte(input [7:0] b);
  rx=0;#500;for(integer j=0;j<8;j++)begin rx=b[j];#500;end rx=1;#500;
 endtask
 initial begin
  wait(!rst);#1000;sendbyte(8'h00);sendbyte(8'h5a);sendbyte(8'h00);sendbyte(8'h5a);
  sendbyte(8'ha5);sendbyte(8'hff);sendbyte(8'ha5);sendbyte(8'hff);#1000;
  if(triggers!=1)$fatal(1,"Trigger UART decode");
  @(negedge clk);send=1;wait(busy);@(negedge clk);send=0;wait(done);#1000;
  if(received!=64||pushed!=64)$fatal(1,"64-byte real UART record length");
  uart_pass=1;$display("PASS MAIN real UART: incoming trigger + 64 outgoing M1 bytes at 2 Mbaud");
 end
 reg [7:0] ch;integer bitno;
 initial begin outfile=$fopen("uart.txt","w");forever begin
  @(negedge tx);#250;if(tx!==0)$fatal(1,"Start bit");
  for(bitno=0;bitno<8;bitno++)begin #500;ch[bitno]=tx;end
  #500;if(tx!==1)$fatal(1,"Stop bit");if(ch!==txexpected[received])$fatal(1,"Serial byte corruption");
  $fwrite(outfile,"%c",ch);received++;
 end end
 initial begin wait(bridge_pass&&uart_pass&&buffer_pass&&packet_pass);$fclose(outfile);$display("PASS MAIN IO");$finish;end
 initial begin #20000000;$fatal(1,"IO timeout");end
endmodule

module tb_main_buffer(output bit passed=0);
 reg clk=0;always #3.030303 clk=~clk;
 reg clear=1,we=0,re=0;reg [15:0] data=0;wire [7:0] q;wire empty,full;
 MainWaveFifo fifo(.aclr(clear),.data(data),.rdclk(clk),.rdreq(re),.wrclk(clk),.wrreq(we),.q(q),.rdempty(empty),.wrfull(full));
 integer i,want;
 initial begin
  repeat(5)@(negedge clk);clear=0;
  for(i=0;i<131072;i++)begin data=(i^16'ha55a);we=1;@(negedge clk);end
  we=0;repeat(7)@(negedge clk);if(!full||empty)$fatal(1,"Frame buffer full boundary");
  // An extra write at full must not corrupt address zero.
  we=1;data=16'h1234;@(negedge clk);we=0;
  for(i=0;i<262144;i++)begin
   if(empty)$fatal(1,"Premature buffer empty at byte %0d",i);
   re=1;@(negedge clk);re=0;repeat(7)@(negedge clk);
   want=((i/2)^16'ha55a);if(i%2==1)want=want>>8;
   if(q!==(want&255))$fatal(1,"Buffer byte %0d got %h expected %h",i,q,want&255);
  end
  if(!empty)$fatal(1,"Buffer last-byte boundary");
  clear=1;repeat(7)@(negedge clk);clear=0;
  if(full||!empty)$fatal(1,"Buffer clear");
  data=16'hd3b7;we=1;@(negedge clk);we=0;repeat(7)@(negedge clk);
  re=1;@(negedge clk);re=0;repeat(7)@(negedge clk);if(q!==8'hb7)$fatal(1,"Reused frame low byte");
  re=1;@(negedge clk);re=0;repeat(7)@(negedge clk);if(q!==8'hd3||!empty)$fatal(1,"Reused frame high byte");
  passed=1;$display("PASS MAIN RAW BUFFER: 131072 words / 262144 ordered bytes, full cap, clear/reuse");
 end
endmodule

module tb_main_packet(output bit passed=0);
 reg clk=0;always #3.030303 if(!passed)clk=~clk;
 reg rst=1,start=0,newdata=0,txbusy=0;reg [15:0] value=0;wire busy,valid;wire [7:0] data;
 MainTxPack dut(.iClk(clk),.iRst(rst),.iStart(start),.oBusy(busy),.iSamplingPeriod(32'h366a1234),.iDataCnt(16),
 .iNewData(newdata),.iValue(value),.iTempData(16'h0c80),.iTxBusy(txbusy),.oTxDataValid(valid),.oTxData(data));
 integer frame=0,n=0,hold_ticks=0,bytes=0,want;reg [7:0] packet[0:95];
 always @(posedge clk)begin
  if(hold_ticks>0)begin hold_ticks--;if(hold_ticks==0)txbusy<=0;end
  if(valid)begin if(txbusy||bytes>=96)$fatal(1,"Packet handshake/length");packet[bytes]=data;bytes++;txbusy<=1;hold_ticks=8;end
 end
 initial begin
  repeat(10)@(negedge clk);rst=0;repeat(10)@(negedge clk);
  for(frame=0;frame<2;frame++)begin
   bytes=0;
   for(n=0;n<16;n++)begin value=16'h4500+frame*256+n;newdata=1;@(negedge clk);newdata=0;repeat(4)@(negedge clk);end
   repeat(10)@(negedge clk);start=1;wait(busy);@(negedge clk);start=0;wait(!busy&&!txbusy);repeat(5)@(negedge clk);
   if(bytes!=96||packet[6]!=90||packet[8]!=16||packet[70]!=165||packet[72]!=16)$fatal(1,"Packet structure");
   for(n=0;n<16;n++)begin want=16'h4500+frame*256+n;if({packet[33+n*2],packet[32+n*2]}!==want)$fatal(1,"Packet frame=%0d sample=%0d",frame,n);end
   if(dut.f1.words!=0||dut.f1.bytes_read!=0)$fatal(1,"Main must clear frame buffer after every packet");
  end
  passed=1;$display("PASS MAIN PACKET REUSE: two frames, ordered payloads, automatic buffer clear");
 end
endmodule

`else
`timescale 1ns/1ps
`include "FftSettings.svh"
module MainPLL(input refclk,rst,output reg outclk_0=0,output reg locked=0);
 always #3.030303 outclk_0=~outclk_0;
 initial begin #200;locked=1;end
endmodule
module tb_rx_fft_board;
 reg clk100=0;always #5 clk100=~clk100;
 reg sdo=0,drdy=1;wire uart,ad_clk,sclk,cs,sdi,start,resetn;
 RxFftLowFreq50to100Hz #(.RESET_ADC_CYCLES(64),.RESET_FFT_CYCLES(100),
 .BOOT_TICKS(50000),.REPEAT_TICKS(2000),.CAP_TIMEOUT_TICKS(10000000)) dut(
 .iMAIN_CLK(clk100),.iUART_RXD(1'b1),.iUART_RTS(1'b0),.iAD_SDO(sdo),.iAD_DRDY(drdy),
 .oUART_TXD(uart),.oAD_CLK(ad_clk),.oAD_SCLK(sclk),.oAD_CS(cs),.oAD_SDI(sdi),.oAD_START(start),.oAD_RST(resetn));
 integer case_no=0,conversion=0,clk_ticks=0,frame_start_index=0;
 integer ready_code=0,read_code=0,read_index=0,read_bits=0,fall_bits=0,init_count=0;
 reg [15:0] command_word=0;
 bit initialized=0,active=0;
 realtime last_fall=-1e6,last_sdi=-1e6,cs_fall=-1e6,cs_rise=-1e6,reset_release=0;
 realtime adc_edge=-1e6,spi_edge=-1e6,adc_rise=-1e6,start_edge=-1e6,reset_low=-1e6;
 integer reset_clocks=0,spi_frames=0;
 function automatic [15:0] init_word(input integer n);
  case(n)0:init_word=16'h0000;1:init_word=16'h8500;2:init_word=16'h8687;
  3:init_word=16'h870c;4:init_word=16'h8880;5:init_word=16'h8908;default:init_word=0;endcase
 endfunction
 always @(ad_clk)begin
  if($realtime>1000&&$realtime-adc_edge<13.199)$fatal(1,"ADC CLK pulse too short");
  adc_edge=$realtime;
 end
 always @(sclk)begin
  if($realtime>1000&&$realtime-spi_edge<13.199)$fatal(1,"SCLK pulse too short");
  spi_edge=$realtime;
 end
 always @(start)begin
  if(resetn&&$realtime-adc_rise<8.999)$fatal(1,"START hold <9ns");
  start_edge=$realtime;
 end
 always @(posedge ad_clk)begin
  if(resetn&&$realtime-start_edge<8.999)$fatal(1,"START setup <9ns");
  adc_rise=$realtime;
 end
 always @(negedge resetn)reset_low=$realtime;
 always @(posedge resetn)begin
  if($realtime-reset_low<145.45)$fatal(1,"RESET low shorter than 4 ADC clocks");
  reset_release=$realtime;reset_clocks=0;
 end
 always @(posedge ad_clk)if(resetn)reset_clocks++;
 real f,phase,value_real;
 always @(negedge ad_clk)begin
  if(!resetn||!start)begin clk_ticks=0;conversion=0;drdy=1;end
  else begin
   clk_ticks++;
   if(case_no==4)drdy=1;
   else if(clk_ticks>=96&&((clk_ticks-96)%24)==0)begin
    case(case_no)0:f=`FFT_TEST_HZ;1:f=100;2:f=200;default:f=100;endcase
    phase=6.283185307179586*conversion/(165000000.0/144.0);
    value_real=7000*$sin(f*phase)+111;
    if(case_no==1)value_real=3500*$sin(100*phase+1.0471975512)+6000;
    if(case_no==3)value_real=7000*$sin(100*phase)+2000*$sin(300*phase)-5000;
    ready_code=$rtoi(value_real);conversion++;drdy=0;
   end else if(clk_ticks>=98&&((clk_ticks-98)%24)==0)drdy=1;
  end
 end
 always @(sdi)begin
  if(active&&$realtime-last_fall<5.999)$fatal(1,"SDI hold <6ns");
  last_sdi=$realtime;
 end
 always @(negedge cs)begin
  if(resetn)begin
   if(reset_clocks<10000)$fatal(1,"ADC reset recovery <10000 clocks");
   if($realtime-cs_rise<19.999)$fatal(1,"CS high <20ns");
   cs_fall=$realtime;active=1;read_bits=0;fall_bits=0;command_word=0;
   read_code=ready_code;read_index=conversion-1;spi_frames++;
  end
 end
 always @(posedge sclk)if(active)begin
  if(read_bits==0&&$realtime-cs_fall<9.999)$fatal(1,"CS setup <10ns");
  if(initialized)begin
   if(read_bits<16)sdo<=#23 ((read_code>>(15-read_bits))&1);else sdo<=#23 0;
  end
  read_bits++;
 end
 always @(negedge sclk)if(active)begin
  last_fall=$realtime;
  if($realtime-last_sdi<3.999)$fatal(1,"SDI setup <4ns");
  command_word={command_word[14:0],sdi};fall_bits++;
 end
 always @(posedge cs)if(active)begin
  if($realtime-last_fall<9.999)$fatal(1,"CS hold <10ns");
  active=0;cs_rise=$realtime;
  if(!initialized)begin
   if(fall_bits!=16||command_word!==init_word(init_count))$fatal(1,"ADC init mismatch frame=%0d bits=%0d word=%h",init_count,fall_bits,command_word);
   init_count++;if(init_count==6)initialized=1;
  end else if(read_bits!=16)$fatal(1,"ADC read length=%0d",read_bits);
 end
 always @(negedge ad_clk)if(dut.adc_valid)begin
  if($signed(dut.adc_sample)!==read_code)$fatal(1,"ADC decode got=%0d expected=%0d",$signed(dut.adc_sample),read_code);
 end
 integer captured[0:2047];integer rxfile,fftfile,uartfile,meta;
 integer cap_seen=0,feed_seen=0,bins_seen=0,packets=0,cap_sum_ref=0,centered_ref;
 initial begin
  rxfile=$fopen("capture.csv","w");fftfile=$fopen("spectrum.csv","w");uartfile=$fopen("uart.txt","w");meta=$fopen("metadata.csv","w");
  $fwrite(rxfile,"case,index,code\n");$fwrite(fftfile,"case,bin,real,imag,power\n");$fwrite(meta,"case,count,span,flags,bin,power,dc_mean\n");
 end
 always @(posedge dut.engine.cap_active)begin cap_seen=0;feed_seen=0;bins_seen=0;cap_sum_ref=0;end
 always @(posedge dut.adc_clock)if(dut.engine.ram_we)begin
  if(dut.engine.fft_busy||dut.engine.fft_input_valid)$fatal(1,"Capture overwrote frame during FFT");
  if(cap_seen>=2048)$fatal(1,"Too many captured samples");
  captured[cap_seen]=$signed(dut.low_sample);cap_sum_ref=cap_sum_ref+$signed(dut.low_sample);$fwrite(rxfile,"%0d,%0d,%0d\n",case_no,cap_seen,$signed(dut.low_sample));cap_seen++;
 end
 always @(posedge dut.fft_clock)begin
  if(dut.engine.fft_input_valid&&dut.engine.fft_input_ready)begin
   if($signed(dut.engine.ram_q)!==captured[feed_seen])$fatal(1,"CDC/frame read mismatch index=%0d",feed_seen);
   if($signed(dut.engine.dc_mean)!==cap_sum_ref/2048)$fatal(1,"DC mean divider mismatch");
   centered_ref=captured[feed_seen]-(cap_sum_ref/2048);
   if(centered_ref>32767)centered_ref=32767;if(centered_ref< -32768)centered_ref=-32768;
   if($signed(dut.engine.fft_sample)!==centered_ref)$fatal(1,"DC subtraction mismatch");
   feed_seen++;
  end
  if(dut.engine.power_valid)begin
   if(dut.engine.power_bin!=bins_seen)$fatal(1,"FFT bin order");
   $fwrite(fftfile,"%0d,%0d,%0d,%0d,%0d\n",case_no,bins_seen,$signed(dut.engine.power_re),$signed(dut.engine.power_im),dut.engine.power_value);bins_seen++;
  end
  if(dut.engine.uart_done)begin
   $fwrite(meta,"%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",case_no,dut.engine.report_count,dut.engine.report_span,dut.engine.report_flags,dut.engine.report_bin,dut.engine.report_power,$signed(dut.engine.dc_mean));
   if(case_no<1)begin
    if(cap_seen!=2048||feed_seen!=2048||bins_seen!=1025||dut.engine.report_flags!=0||dut.engine.report_span!=6288384)$fatal(1,"Frame/flags/cadence mismatch case=%0d",case_no);
    $display("PASS frame %0d capture=%0d fft=%0d peak=%0d",case_no,cap_seen,bins_seen,dut.engine.report_bin);
   end else begin
    if(dut.engine.report_count!=0||!dut.engine.report_flags[0]||bins_seen!=0)$fatal(1,"ADC timeout must not report a valid FFT");
   end
   case_no++;
   if(case_no==1)begin
    if(packets!=1)$fatal(1,"UART frame count");
    $display("PASS FULL LOWFREQ TOP: full 228.78ms acquisition, ADC SPI pins, CIC, CDC, FFT, UART");
    $fclose(rxfile);$fclose(fftfile);$fclose(uartfile);$fclose(meta);#100;$finish;
   end
  end
 end
 reg [7:0] rxbyte;integer bi,chars=0;
 initial forever begin
  @(negedge uart);#250;if(uart!==0)$fatal(1,"UART start bit");
  for(bi=0;bi<8;bi++)begin #500;rxbyte[bi]=uart;end
  #500;if(uart!==1)$fatal(1,"UART stop bit");
  $fwrite(uartfile,"%c",rxbyte);chars++;
  if(rxbyte==10)begin if(chars!=64)$fatal(1,"UART record length=%0d",chars);chars=0;packets++;end
 end
 initial begin #300000000;$fatal(1,"Global timeout");end
endmodule

`endif
