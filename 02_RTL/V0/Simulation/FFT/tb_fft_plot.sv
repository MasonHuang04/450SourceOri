`ifndef MF_LOGN
`define MF_LOGN 10
`define MF_VALID 672
`define MF_DW 9
`define MF_MIN 1
`define MF_MAX 14
`define MF_RAW 21770
`endif
`ifdef INTERP_TEST
`timescale 1ns/1ps
module tb_interpolation;
 reg clk=0,rst=1,valid=0,sop=0,pv=0,en=0;always #10 clk=~clk;
 reg [14:0] bin=0,pbin=0;reg [40:0] power=0,ppower=0;
 wire done;wire signed [31:0] delta;wire [7:0] status;
 main_peak_interpolator #(.MIN_BIN(`MF_MIN),.MAX_BIN(`MF_MAX)) dut(.clk(clk),.rst(rst),.i_valid(valid),.i_sop(sop),.i_bin(bin),.i_power(power),
 .i_peak_valid(pv),.i_enable(en),.i_peak_bin(pbin),.i_peak_power(ppower),.o_done(done),.o_delta_q16(delta),.o_status(status));
 integer f,o,rc,id,k,mode,enabled,j,latency,count=0;reg [40:0] l,c,r;
 initial begin
  f=$fopen("vectors.txt","r");o=$fopen("interpolated.csv","w");$fwrite(o,"id,delta_q16,status,latency\n");
  repeat(5)@(negedge clk);rst=0;
  while(!$feof(f))begin
   rc=$fscanf(f,"%d %d %d %d %d %d %d\n",id,l,c,r,k,enabled,mode);
   if(rc!=7)$fatal(1,"Bad stimulus line");
   for(j=0;j<=(mode==1?k:(`MF_MAX+2));j++)begin
    @(negedge clk);valid=1;sop=(j==0);bin=j;
    power=(j==k-1)?l:(j==k)?c:(j==k+1)?r:0;
    // Insert gaps without changing the accepted sequence.
    if(j%13==12)begin @(negedge clk);valid=0;sop=0;end
   end
   @(negedge clk);valid=0;sop=0;pv=1;en=enabled;pbin=k+(mode==2?1:0);ppower=c;
   @(negedge clk);pv=0;latency=0;
   while(!done&&latency<180)begin @(negedge clk);latency++;end
   if(!done||$isunknown({delta,status}))$fatal(1,"Interpolation timeout/unknown");
   $fwrite(o,"%0d,%0d,%0d,%0d\n",id,delta,status,latency);count++;
   @(negedge clk);
  end
  // Reset during an operation must cancel it and clear outputs.
  pv=1;en=1;@(negedge clk);pv=0;repeat(5)@(negedge clk);rst=1;
  @(negedge clk);if(done||delta!=0||status!=1)$fatal(1,"Reset did not clear interpolation");
  $fclose(f);$fclose(o);$display("PASS FPGA INTERPOLATION: %0d vectors, gaps, consecutive frames, reset",count);$finish;
 end
 initial begin #1000000000;$fatal(1,"Interpolation test global timeout");end
endmodule
`elsif MAIN_FFT_TEST
`timescale 1ns/1ps
module tb_main_fft;
 localparam LOGN=`MF_LOGN,NFFT=1<<LOGN,VCOUNT=`MF_VALID,RAW_WORDS=`MF_RAW,INPUT_LEN=RAW_WORDS+1024;
 bit done=0;reg ac=0,fc=0,rst=1;
 initial forever begin #7;if(done)break;ac=~ac;end
 initial forever begin #10;if(done)break;fc=~fc;end
 reg start=0,window_on=0,input_run=0,av=0;reg signed [15:0] sample=0;
 wire ready;wire [31:0] seq,count,span;wire [14:0] peak_bin;wire [40:0] peak_power;wire [15:0] vmin,vmax;wire [7:0] flags;
 wire signed [31:0] delta;wire [7:0] interp_status;
 MainFftProcessor #(.LOGN(LOGN),.VALID_SAMPLES(VCOUNT),.DELTA_W(`MF_DW),.MIN_BIN(`MF_MIN),.MAX_BIN(`MF_MAX),.SAMPLE_TICKS(32)) dut(.sys_clk(ac),.fft_clk(fc),.sys_rst(rst),.fft_rst(rst),.i_start(start),.i_capture_active(window_on),.i_raw_valid(av),.i_raw_sample(sample),
 .o_done(ready),.o_seq(seq),.o_count(count),.o_span(span),.o_bin(peak_bin),.o_power(peak_power),.o_min(vmin),.o_max(vmax),.o_flags(flags),.o_delta_q16(delta),.o_interp_status(interp_status));
 reg send=0,uart_busy=0;wire [7:0] outbyte;wire valid,sending,sent;
 MainPeakReport report(.clk(ac),.rst(rst),.i_start(send),.i_tx_busy(uart_busy),.i_seq(seq),.i_count(count),.i_span(span),.i_bin(peak_bin),.i_power(peak_power),.i_min(vmin),.i_max(vmax),.i_flags(flags),.i_delta_q16(delta),.i_interp_status(interp_status),.i_fft_length(16'(NFFT)),.o_data(outbyte),.o_valid(valid),.o_busy(sending),.o_done(sent));
 reg [15:0] stim[0:INPUT_LEN-1],expected[0:INPUT_LEN/32-1];integer case_no=0,n=0,dn=0,cn=0,bn=0,fn=0,sum=0,hold_count=0,bytes=0;
 integer fft_ticks=0,begin_tick=0,process_ticks=0;
 integer captured[0:VCOUNT-1];integer cf,sf,mf,uf;string path;integer centered;
 always @(negedge ac)begin
  av=0;
  if(input_run)begin
   if(n<(case_no==6 ? RAW_WORDS/2 : case_no==7 ? RAW_WORDS/8 : RAW_WORDS))begin
    sample=stim[n];av=(case_no!=7);n++;
   end else begin window_on=0;input_run=0;end
  end
 end
 always @(posedge ac)if(!rst)begin
  if(dut.cv)begin
   if(dut.cs!==expected[dn])$fatal(1,"CIC/FIR mismatch case=%0d index=%0d",case_no,dn);dn++;
  end
  if(dut.ram_we)begin
   if(dut.fft_busy||cn>=VCOUNT)$fatal(1,"Immutable frame overwritten");captured[cn]=dut.cs;sum+=dut.cs;
   $fwrite(cf,"%0d,%0d,%0d\n",case_no,cn,dut.cs);cn++;
  end
  if(hold_count>0)begin hold_count--;if(hold_count==0)uart_busy<=0;end
  if(valid)begin
   if(uart_busy)$fatal(1,"Reporter transmitted while UART busy");
   uart_busy<=1;hold_count=3;$fwrite(uf,"%c",outbyte);bytes++;
  end
 end
 always @(posedge fc)if(!rst)begin
  fft_ticks++;if(dut.state==dut.META)begin_tick=fft_ticks;if(dut.state==dut.REPORT)process_ticks=fft_ticks-begin_tick;
  if(dut.state==dut.FEED&&dut.fft_input_ready)begin
   if($signed(dut.ram_q)!==captured[fn]||$signed(dut.dc_mean)!==sum/VCOUNT)$fatal(1,"Read/DC mismatch");
   centered=captured[fn]-sum/VCOUNT;if(centered>32767)centered=32767;if(centered< -32768)centered=-32768;
   if($signed(dut.fft_sample)!==centered)$fatal(1,"Centering mismatch");fn++;
  end
  if(dut.power_valid)begin
   if(dut.power_bin!=bn)$fatal(1,"FFT ordering");
   $fwrite(sf,"%0d,%0d,%0d,%0d,%0d\n",case_no,bn,dut.power_re,dut.power_im,dut.power_value);bn++;
  end
 end
 initial begin
  cf=$fopen("capture.csv","w");sf=$fopen("spectrum.csv","w");mf=$fopen("metadata.csv","w");uf=$fopen("telemetry.txt","w");
  $fwrite(cf,"case,index,code\n");$fwrite(sf,"case,bin,real,imag,power\n");$fwrite(mf,"case,seq,count,span,flags,bin,power,mean,delta_q16,interp_status,process_cycles\n");
  repeat(30)@(negedge ac);#1;rst=0;
  for(case_no=0;case_no<8;case_no++)begin
   n=0;dn=0;cn=0;bn=0;fn=0;sum=0;bytes=0;
   path=$sformatf("input_%0d.mem",case_no);$readmemh(path,stim);
   path=$sformatf("expected_%0d.mem",case_no);$readmemh(path,expected);
   @(negedge ac);#1;start=1;@(negedge ac);#1;start=0;window_on=1;input_run=1;
   wait(!window_on);wait(ready);@(negedge ac);#1;
   if($isunknown({seq,count,span,peak_bin,peak_power,flags}))$fatal(1,"Unknown FFT result");
   if(seq!=case_no+1||count!=cn)$fatal(1,"Result CDC/sequence mismatch");
   if(case_no<6)begin
    if(cn!=VCOUNT||fn!=VCOUNT||bn!=NFFT/2+1||span!=(VCOUNT-1)*32)$fatal(1,"Frame length/cadence");
    if(case_no<5&&flags!=0)$fatal(1,"Unexpected flags %h",flags);
    if(case_no==5&&!flags[2])$fatal(1,"Clipping not detected");
   end else if(!flags[0]||bn!=0||fn!=0||peak_power!=0)$fatal(1,"Short/empty window reported valid FFT");
   send=1;wait(sending);@(negedge ac);#1;send=0;wait(sent);#1;
   if(bytes!=81)$fatal(1,"Report must be 81 bytes");
   $fwrite(mf,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",case_no,seq,count,span,flags,peak_bin,peak_power,dut.dc_mean,delta,interp_status,process_ticks);
   $display("PASS MAIN FFT case=%0d count=%0d bin=%0d flags=%h",case_no,count,peak_bin,flags);
  end
  $fclose(cf);$fclose(sf);$fclose(mf);$fclose(uf);$display("PASS MAIN FFT PIPELINE");done=1;
 end
 initial begin #100000000;if(!done)$fatal(1,"Global timeout");end
endmodule

`else
`timescale 1ns/1ps
module tb_lowfreq;
 bit done=0; reg ac=0,fc=0,rst=1; initial forever begin #7;if(done)break;ac=~ac;end initial forever begin #10;if(done)break;fc=~fc;end
 reg av=0;reg signed [15:0] sample=0;
 wire lv,lr,lc,uart;wire signed [15:0] ls;
 ScopeCic128 filter(.clk(ac),.rst(rst),.i_valid(av),.i_sample(sample),.o_valid(lv),.o_ready(lr),.o_clipped(lc),.o_sample(ls));
 // Test only removes the 23 idle ADC cycles between conversions. All 262144
 // raw sample values per frame are still processed by the production RTL.
 ScopeRxFft #(.SAMPLE_TICKS(128),.BOOT_TICKS(5000),.REPEAT_TICKS(2000000),.CAP_TIMEOUT_TICKS(300000)) engine(
 .adc_clk(ac),.fft_clk(fc),.adc_rst(rst),.fft_rst(rst),.adc_ready(1'b1),.adc_valid(lv&&lr),.adc_sample(ls),.adc_clipped(lc),
 .uart_tx(uart),.activity(),.heartbeat());
 reg [15:0] stimulus[0:499999];reg [15:0] expected[0:3905];
 integer case_no=0,n=0,dec_n=0,cap_n=0,feed_n=0,bins_seen=0,packets=0,cap_sum=0;
 integer captured[0:2047];integer capfile,specfile,metafile,uartfile;string fn;
 always @(negedge ac)begin
  if(rst)begin n=0;sample=0;av=0;end
  else if(case_no<10)begin sample=stimulus[n];av=1;n++;if(n>=500000)$fatal(1,"Input exhausted");end
  else av=0;
 end
 always @(posedge ac)if(!rst)begin
  if(lv)begin
   if(ls!==expected[dec_n])$fatal(1,"CIC differs from independent FIR case=%0d index=%0d got=%0d want=%0d",case_no,dec_n,ls,$signed(expected[dec_n]));
   dec_n++;
  end
  if(engine.ram_we)begin
   if(engine.fft_busy||cap_n>=2048)$fatal(1,"Frame write isolation/count");
   captured[cap_n]=ls;cap_sum+=ls;
   $fwrite(capfile,"%0d,%0d,%0d,%0d\n",case_no,cap_n,ls,dec_n-1);cap_n++;
  end
 end
 integer centered;
 always @(posedge fc)if(!rst)begin
  if(engine.fft_input_valid&&engine.fft_input_ready)begin
   if($signed(engine.ram_q)!==captured[feed_n])$fatal(1,"CDC sample order");
   if($signed(engine.dc_mean)!==cap_sum/2048)$fatal(1,"DC mean");
   centered=captured[feed_n]-cap_sum/2048;
   if(centered>32767)centered=32767;if(centered< -32768)centered=-32768;
   if($signed(engine.fft_sample)!==centered)$fatal(1,"DC subtraction");
   feed_n++;
  end
  if(engine.power_valid)begin
   if(engine.power_bin!=bins_seen)$fatal(1,"FFT bin ordering");
   $fwrite(specfile,"%0d,%0d,%0d,%0d,%0d\n",case_no,bins_seen,$signed(engine.power_re),$signed(engine.power_im),engine.power_value);bins_seen++;
  end
 end
 initial begin
  capfile=$fopen("capture.csv","w");specfile=$fopen("spectrum.csv","w");metafile=$fopen("metadata.csv","w");uartfile=$fopen("uart.txt","w");
  $fwrite(capfile,"case,index,code,decimator_index\n");$fwrite(specfile,"case,bin,real,imag,power\n");$fwrite(metafile,"case,count,span,flags,bin,power,dc_mean\n");
  for(case_no=0;case_no<11;case_no++)begin
   rst=1;repeat(30)@(negedge ac);dec_n=0;cap_n=0;feed_n=0;bins_seen=0;cap_sum=0;
   if(case_no<10)begin
    fn=$sformatf("input_%0d.mem",case_no);$readmemh(fn,stimulus);
    fn=$sformatf("expected_%0d.mem",case_no);$readmemh(fn,expected);
   end
   @(negedge ac);#1;rst=0;
   wait(engine.uart_done);#1;
   $fwrite(metafile,"%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",case_no,engine.report_count,engine.report_span,engine.report_flags,engine.report_bin,engine.report_power,$signed(engine.dc_mean));
   if(case_no<10)begin
    if(cap_n!=2048||feed_n!=2048||bins_seen!=1025||engine.report_span!=262016)$fatal(1,"Frame/cadence failure");
    if(case_no<9&&engine.report_flags!=0)$fatal(1,"Unexpected error flags %h",engine.report_flags);
    if(case_no==9&&!engine.report_flags[2])$fatal(1,"Raw ADC clipping was hidden by filter");
   end else if(engine.report_count!=0||!engine.report_flags[0]||bins_seen!=0)$fatal(1,"Timeout must reject frame");
   if(packets!=case_no+1)$fatal(1,"UART frame count");
   $display("PASS frame=%0d effective=%0d bin=%0d flags=%h CIC_samples=%0d",case_no,cap_n,engine.report_bin,engine.report_flags,dec_n);
  end
  $fclose(capfile);$fclose(specfile);$fclose(metafile);$fclose(uartfile);
  $display("PASS LOWFREQ: CIC/FIR equivalence, all 2048 samples, CDC, FFT, clipping, timeout and UART");done=1;
 end
 reg [7:0] b;integer bi,chars=0;
 initial forever begin
  @(negedge uart);#250;if(uart!==0)$fatal(1,"UART start");
  for(bi=0;bi<8;bi++)begin #500;b[bi]=uart;end
  #500;if(uart!==1)$fatal(1,"UART stop");$fwrite(uartfile,"%c",b);chars++;
  if(b==10)begin if(chars!=64)$fatal(1,"UART length");chars=0;packets++;end
 end
 initial begin #150000000;if(!done)$fatal(1,"Test timeout");end
endmodule

`endif
