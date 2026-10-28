`timescale 1ns/1ps

module tb_mixer_arithmetic;
 reg clk=0,rst=1,start=0,valid=0;always #3.030303 clk=~clk;
 reg signed [15:0] rx=0,reference=0;
 wire ov,clip;wire signed [15:0] sample;
 MainDigitalMixer dut(.clk(clk),.rst(rst),.i_frame_start(start),.i_valid(valid),
  .i_rx(rx),.i_reference(reference),.o_valid(ov),.o_sample(sample),.o_clipped(clip));
 wire signed [15:0] reference18,reference84;
 MainReferenceDelay #(.DELAY_CYCLES(18)) delay18(.clk(clk),.rst(rst),.i_reference(reference),.o_reference(reference18));
 MainReferenceDelay #(.DELAY_CYCLES(84)) delay84(.clk(clk),.rst(rst),.i_reference(reference),.o_reference(reference84));
 reg signed [15:0] reference_history[0:4095];integer reference_count=0;
 always @(negedge clk)begin
  #0.01;
  if(rst)reference_count=0;
  else begin
   reference_history[reference_count]=reference;
   if(reference_count>=18&&reference18!==reference_history[reference_count-18])$fatal(1,"Default reference delay is not 18 clocks");
   if(reference_count>=84&&reference84!==reference_history[reference_count-84])$fatal(1,"Extra calibrated reference delay is not 84 clocks");
   reference_count++;
  end
 end
 integer expected[$];integer checks=0;integer expect_value;bit ever_clip=0;
 longint signed product,scaled;
 always @(posedge clk)begin
  if(rst||start)begin expected.delete();ever_clip=0;end
  else begin
   if(ov)begin
    if(expected.size()==0)$fatal(1,"Unexpected mixer valid");
    expect_value=expected.pop_front();
    if(sample!==16'(expect_value))$fatal(1,"Mixer result %0d != %0d",sample,expect_value);
    checks++;
   end
   if(valid)begin
    product=longint'(rx)*longint'(reference);scaled=(product+16384)>>>15;
    if(scaled>32767)begin scaled=32767;ever_clip=1;end
    if(scaled< -32768)begin scaled=-32768;ever_clip=1;end
    expected.push_back(integer'(scaled));
   end
  end
 end
 initial begin
  repeat(5)@(negedge clk);rst=0;
  for(integer k=0;k<2000;k++)begin
   @(negedge clk);valid=(k%7)!=0;
   rx=$signed($urandom());reference=$signed($urandom());
   if(k==1)begin rx=-32768;reference=-32768;end
   if(k==2)begin rx=-32768;reference=32767;end
   if(k==3)begin rx=32767;reference=32767;end
  end
  @(negedge clk);valid=0;repeat(5)@(negedge clk);
  if(expected.size()!=0||checks<1700||!clip)$fatal(1,"Mixer count or sticky clipping");
  start=1;@(negedge clk);start=0;repeat(2)@(negedge clk);
  if(clip||ov)$fatal(1,"New frame must clear clipping and pending valid");
  $display("PASS DIGITAL MIXER ARITHMETIC: %0d signed products, rounding/saturation/gaps/frame reset; reference delays18/84 clocks",checks);
  $finish;
 end
endmodule

module tb_mixer_frames;
 localparam integer WORDS=21770;
`ifdef MIX_REAL_CADENCE
 localparam integer TICKS=144,FIRST_CASE=16,LAST_CASE=16;
`else
 localparam integer TICKS=8,FIRST_CASE=0,LAST_CASE=26;
`endif
 reg clk=0,fftclk=0,rst=1,start=0,active=0,valid=0;
 always #3.030303 clk=~clk;always #10 fftclk=~fftclk;
 reg signed [15:0] rx=0,reference=0;
 wire mv,mc;wire signed [15:0] mixed;
 MainDigitalMixer mixer(.clk(clk),.rst(rst),.i_frame_start(start),.i_valid(valid),
  .i_rx(rx),.i_reference(reference),.o_valid(mv),.o_sample(mixed),.o_clipped(mc));
 wire done;wire [31:0] seq,count,span,delta;wire [14:0] bin;
 wire [40:0] power;wire [15:0] mn,mx;wire [7:0] flags,status;
 MainFftProcessor #(.SAMPLE_TICKS(32*TICKS),.MIN_BIN(1),.MAX_BIN(57)) dut(
  .sys_clk(clk),.fft_clk(fftclk),.sys_rst(rst),.fft_rst(rst),.i_start(start),
  .i_capture_active(active),.i_raw_valid(mv),.i_raw_sample(mixed),
  .o_done(done),.o_seq(seq),.o_count(count),.o_span(span),.o_bin(bin),.o_power(power),
  .o_min(mn),.o_max(mx),.o_flags(flags),.o_delta_q16(delta),.o_interp_status(status));
 reg [15:0] rx_words[0:WORDS-1],reference_words[0:WORDS-1],expected_products[0:WORDS-1];
 integer cap_file,spec_file,meta_file,case_no=0,products=0;
 always @(posedge clk)if(!rst)begin
  if(mv)begin
   if(mixed!==expected_products[products])$fatal(1,"Frame %0d product %0d mismatch",case_no,products);
   products++;
  end
  if(dut.ram_we)$fwrite(cap_file,"%0d,%0d,%0d\n",case_no,dut.cap_count,$signed(dut.cs));
 end
 always @(posedge fftclk)if(!rst&&dut.power_valid)
  $fwrite(spec_file,"%0d,%0d,%0d,%0d,%0d\n",case_no,dut.power_bin,$signed(dut.power_re),$signed(dut.power_im),dut.power_value);
 initial begin
  cap_file=$fopen("capture.csv","w");spec_file=$fopen("spectrum.csv","w");meta_file=$fopen("metadata.csv","w");
  $fwrite(cap_file,"case,index,code\n");$fwrite(spec_file,"case,bin,real,imag,power\n");
  $fwrite(meta_file,"case,count,span,bin,power,delta,status,flags\n");
  repeat(20)@(negedge clk);rst=0;repeat(20)@(negedge clk);
  for(case_no=FIRST_CASE;case_no<=LAST_CASE;case_no++)begin
   $readmemh($sformatf("rx_%0d.mem",case_no),rx_words);
   $readmemh($sformatf("ref_%0d.mem",case_no),reference_words);
   $readmemh($sformatf("product_%0d.mem",case_no),expected_products);
   products=0;start=1;active=1;repeat(3)@(negedge clk);start=0;repeat(3)@(negedge clk);
   for(integer n=0;n<WORDS;n++)begin
    rx=rx_words[n];reference=reference_words[n];valid=1;
    @(negedge clk);valid=0;repeat(TICKS-1)@(negedge clk);
   end
   repeat(12)@(negedge clk);active=0;wait(done);repeat(5)@(negedge clk);
   if(products!=WORDS||count!=672||span!=671*32*TICKS||flags!=0||status!=0||mc)
    $fatal(1,"Frame %0d count/span/flags/status: products=%0d count=%0d span=%0d flags=%h status=%h",case_no,products,count,span,flags,status);
   $fwrite(meta_file,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",case_no,count,span,bin,power,$signed(delta),status,flags);
   $display("PASS MIXER FRAME case=%0d bin=%0d delta=%0d",case_no,bin,$signed(delta));
   repeat(50)@(negedge clk);
  end
  $fclose(cap_file);$fclose(spec_file);$fclose(meta_file);
  $display("PASS DIGITAL MIXER FRAMES: complete RF words -> actual mixer/CIC/Kaiser/FFT/power/interpolation; ticks=%0d",TICKS);
  $finish;
 end
 initial begin #200000000;$fatal(1,"Digital mixer frame timeout");end
endmodule

module tb_adc_reference_pair;
 reg clk=0,rst=1,enable=0;always #3.030303 clk=~clk;
 reg sdo=0,drdy=1;reg signed [15:0] reference=0;
 wire adclk,resetn,start,cs,sclk,sdi,rv,fv,overflow,clip;
 wire [23:0] count;wire [15:0] raw,sample,sample_ref;
 MainAdcBridge dut(.iClk(clk),.iRst(rst),.iSamplingEn(enable),.iDownSampleRate(16'd3),
  .iADSDO(sdo),.iADDRdy(drdy),.iReference(reference),.oADRstz(resetn),.oADStart(start),
  .oADCSz(cs),.oADSClk(sclk),.oADSDI(sdi),.oADClk(adclk),.oDataCnt(count),.oNewData(rv),
  .oValue(raw),.oFftValid(fv),.oFftValue(sample),.oFftReference(sample_ref),.oOverflow(overflow),.oClipped(clip));
 integer ticks=0,conversion=0,ready_code=0,read_code=0,bits=0,fall_bits=0,init_count=0;
 reg active=0,initialized=0;reg [15:0] command_word;
 function automatic [15:0] cmd(input integer n);
  case(n)0:cmd=16'h0000;1:cmd=16'h8500;2:cmd=16'h8687;3:cmd=16'h870c;4:cmd=16'h8880;5:cmd=16'h8908;default:cmd=0;endcase
 endfunction
 always @(negedge adclk)begin
  if(!resetn||!start)begin ticks=0;conversion=0;drdy=1;reference=0;end
  else begin
   ticks++;reference=ticks;
   if(ticks>=96&&(ticks-96)%24==0)begin ready_code=1000+conversion;conversion++;drdy=0;end
   else if(ticks>=98&&(ticks-98)%24==0)drdy=1;
  end
 end
 always @(negedge cs)if(resetn)begin
  active=1;bits=0;fall_bits=0;command_word=0;read_code=ready_code;
 end
 always @(posedge sclk)if(active)begin
  if(initialized)sdo<=#23 ((read_code>>(15-bits))&1);
  bits++;
 end
 always @(negedge sclk)if(active)begin command_word={command_word[14:0],sdi};fall_bits++;end
 always @(posedge cs)if(active)begin
  active=0;
  if(!initialized)begin
   if(fall_bits!=16||command_word!==cmd(init_count))$fatal(1,"ADC init");
   init_count++;if(init_count==6)initialized=1;
  end else if(bits!=16)$fatal(1,"ADC bits");
 end
 integer pairs=0,expected_reference;
 always @(posedge clk)if(!rst&&fv)begin
  expected_reference=98+24*(integer'(sample)-1000);
  if(sample_ref!==16'(expected_reference))$fatal(1,"ADC/reference pairing code=%0d ref=%0d expected=%0d",sample,sample_ref,expected_reference);
  pairs++;
 end
 initial begin
  repeat(50)@(negedge clk);rst=0;wait(conversion>10);@(negedge clk);enable=1;
  wait(pairs==80);@(negedge clk);enable=0;repeat(1000)@(negedge clk);enable=1;
  wait(pairs==200);@(negedge clk);enable=0;
  if(overflow||clip)$fatal(1,"Unexpected ADC flags");
  $display("PASS ADC REFERENCE PAIRS: 200 real SPI words, changing references latched at DRDY, window restart");$finish;
 end
 initial begin #2000000;$fatal(1,"ADC/reference timeout");end
endmodule
