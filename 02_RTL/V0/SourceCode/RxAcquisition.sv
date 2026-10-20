// Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

// BEGIN_SOURCE: ScopeAdc27m5.sv
// Independent bench ADC interface; original ADCController is not modified.
// Same ADS127L21 words and 27.5 MHz CLK / sinc OSR12 / 16-bit format.
// SDI changes on rising CLK, sampled by ADC on falling SCLK.
// Gated SCLK starts a full clock after CS falls and stops before CS rises.
module ScopeAdc27m5(input logic clk,rst, input logic sdo,drdy,
 output logic reset_n,cs_n,sdi,sclk,start,initialized,valid,
 output logic signed [15:0] sample);
 typedef enum logic[3:0] {BOOT,GAP,WRITE,CLOSE,START_CONV,WAIT_DATA,READ_DATA,READ_LAST} state_t;
 state_t state;
 logic [13:0] wait_count;
 logic [2:0] command_index;
 logic [4:0] bit_index;
 logic [15:0] shift_data;
 logic spi_request,spi_gate,start_request;
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] drdy_sync;
 logic drdy_last,drdy_pending;
 function automatic [15:0] command(input [2:0] n);
  case(n) 0:command=16'h0000;1:command=16'h8500;2:command=16'h8687;
   3:command=16'h870c;4:command=16'h8880;default:command=16'h8908;endcase
 endfunction
 wire [15:0] command_data=command(command_index);
 assign sclk=clk & spi_gate;
 // Clock gate enable changes only while source clock is low.
 always_ff @(negedge clk) begin
  if(rst) begin spi_gate<=0;start<=0;end
  else begin spi_gate<=spi_request;start<=start_request;end
 end
 always_ff @(posedge clk) begin
  if(rst) begin
   state<=BOOT;wait_count<=0;command_index<=0;bit_index<=0;
   reset_n<=0;cs_n<=1;sdi<=0;initialized<=0;valid<=0;sample<=0;
   spi_request<=0;start_request<=0;shift_data<=0;
   drdy_sync<=2'b11;drdy_last<=1;drdy_pending<=0;
  end else begin
   reset_n<=1;valid<=0;drdy_sync<={drdy_sync[0],drdy};drdy_last<=drdy_sync[1];
   if(drdy_last&&!drdy_sync[1])drdy_pending<=1;
   case(state)
    BOOT: if(wait_count==10015) begin wait_count<=0;state<=GAP;end
          else wait_count<=wait_count+1'b1;
    GAP: if(wait_count==3) begin
      wait_count<=0;cs_n<=0;sdi<=0;spi_request<=1;bit_index<=0;state<=WRITE;
     end else wait_count<=wait_count+1'b1;
    WRITE: begin
      sdi<=command_data[15-bit_index];
      if(bit_index==15)begin spi_request<=0;state<=CLOSE;end
      else bit_index<=bit_index+1'b1;
     end
    CLOSE: begin
      cs_n<=1;sdi<=0;
      if(command_index==5)begin initialized<=1;state<=START_CONV;end
      else begin command_index<=command_index+1'b1;state<=GAP;end
     end
    START_CONV:begin start_request<=1;drdy_pending<=0;state<=WAIT_DATA;end
    WAIT_DATA:if(drdy_pending)begin
      drdy_pending<=0;cs_n<=0;spi_request<=1;bit_index<=0;state<=READ_DATA;
     end
    READ_DATA:begin
      // First SCLK rising edge launches MSB. Capture it one full period later.
      if(bit_index!=0)shift_data<={shift_data[14:0],sdo};
      if(bit_index==15)begin spi_request<=0;state<=READ_LAST;end
      else bit_index<=bit_index+1'b1;
     end
    READ_LAST:begin
      sample<={shift_data[14:0],sdo};valid<=1;cs_n<=1;state<=WAIT_DATA;
     end
    default:state<=BOOT;
   endcase
  end
 end
endmodule

// END_SOURCE: ScopeAdc27m5.sv

// BEGIN_SOURCE: MainAdcBridge.sv
// Validated ADC driver plus a stable-word toggle crossing into the main clock.
// Raw packet decimation is separate from the full-rate FFT tap.
module MainAdcBridge #(parameter integer RAW_CAPACITY=131072)(
 input logic iClk,iRst,iSamplingEn,input logic [15:0] iDownSampleRate,
 input logic iADSDO,iADDRdy,
 output wire oADRstz,oADCSz,oADSClk,oADSDI,oADStart,oADClk,
 output logic [23:0] oDataCnt,output logic oNewData,output logic [15:0] oValue,
 output logic oFftValid,output logic [15:0] oFftValue,
 output logic oOverflow,oClipped);
 logic [2:0] divide_count=0;logic adc_clock=0;
 always_ff @(posedge iClk)begin
  if(divide_count==2)adc_clock<=1;
  if(divide_count==5)begin adc_clock<=0;divide_count<=0;end
  else divide_count<=divide_count+1'b1;
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] adc_reset_sync=3;
 always_ff @(posedge adc_clock)adc_reset_sync<={adc_reset_sync[0],iRst};
 wire adc_rst=adc_reset_sync[1];wire valid,initialized;wire signed [15:0] sample;
 ScopeAdc27m5 adc(.clk(adc_clock),.rst(adc_rst),.sdo(iADSDO),.drdy(iADDRdy),
 .reset_n(oADRstz),.cs_n(oADCSz),.sclk(oADSClk),.sdi(oADSDI),.start(oADStart),
 .initialized(initialized),.valid(valid),.sample(sample));
 assign oADClk=adc_clock;
 logic word_toggle=0;logic [15:0] held_sample=0;
 always_ff @(posedge adc_clock)begin
  if(adc_rst)begin word_toggle<=0;held_sample<=0;end
  else if(valid)begin held_sample<=sample;word_toggle<=~word_toggle;end
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] word_sync;
 logic seen,enabled_last,pending;
 logic [15:0] skip,skip_limit;
 always_ff @(posedge iClk)begin
  oNewData<=0;oFftValid<=0;
  if(iRst)begin
   word_sync<=0;seen<=0;enabled_last<=0;pending<=0;
   skip<=0;skip_limit<=0;oDataCnt<=0;oValue<=16'h8000;oFftValue<=0;oOverflow<=0;oClipped<=0;
  end else begin
   word_sync<={word_sync[0],word_toggle};enabled_last<=iSamplingEn;
   if(word_sync[1]!=seen)begin seen<=word_sync[1];pending<=1;end
   if(!iSamplingEn)begin pending<=0;skip<=0;end
   if(iSamplingEn&&!enabled_last)begin
    skip_limit<=iDownSampleRate;skip<=0;oDataCnt<=0;oOverflow<=0;oClipped<=0;pending<=0;
   end else if(pending&&iSamplingEn)begin
    pending<=0;oFftValue<=held_sample;oFftValid<=1;
    if(held_sample==16'h7fff||held_sample==16'h8000)oClipped<=1;
    if(skip==skip_limit)begin
     skip<=0;
     if(oDataCnt<RAW_CAPACITY)begin
      oValue<=held_sample^16'h8000;oNewData<=1;oDataCnt<=oDataCnt+1'b1;
     end else oOverflow<=1;
    end else skip<=skip+1'b1;
   end
  end
 end
endmodule

// END_SOURCE: MainAdcBridge.sv

// BEGIN_SOURCE: ScopeCic128.sv
// Three-stage CIC low-pass decimator, R=128, differential delay=1.
// Exact DC gain 128^3=2^21. 40-bit modulo arithmetic avoids integrator overflow
// corruption; the final bounded comb result is rounded back to signed 16 bits.
// Equivalent FIR: three length-128 boxcar convolutions, not sample dropping.
// Group delay 190.5 raw ADC periods (166.25 us); warm up before frame capture.
module ScopeCic128(input logic clk,rst,i_valid,input logic signed [15:0] i_sample,
 output logic o_valid,o_ready,o_clipped,output logic signed [15:0] o_sample);
 logic signed [39:0] int1,int2,int3,z1,z2,z3;
 wire signed [39:0] next1=int1+{{24{i_sample[15]}},i_sample};
 wire signed [39:0] next2=int2+next1;
 wire signed [39:0] next3=int3+next2;
 wire signed [39:0] comb1=next3-z1,comb2=comb1-z2,comb3=comb2-z3;
 wire signed [39:0] rounded=(comb3+40'sd1048576)>>>21;
 logic [6:0] phase;
 logic [1:0] warm;
 logic clipped;
 wire rail=(i_sample==16'sh7fff)||(i_sample==16'sh8000);
 always_ff @(posedge clk)begin
  o_valid<=0;
  if(rst)begin
   int1<=0;int2<=0;int3<=0;z1<=0;z2<=0;z3<=0;phase<=0;warm<=0;
   o_ready<=0;o_clipped<=0;o_sample<=0;clipped<=0;
  end else if(i_valid)begin
   int1<=next1;int2<=next2;int3<=next3;
   clipped<=clipped||rail;
   if(phase==127)begin
    phase<=0;z1<=next3;z2<=comb1;z3<=comb2;
    o_sample<=rounded[15:0];o_valid<=1;o_clipped<=clipped||rail;clipped<=0;
    if(warm!=3)warm<=warm+1'b1;
    if(warm>=2)o_ready<=1;
   end else phase<=phase+1'b1;
  end
 end
endmodule

// END_SOURCE: ScopeCic128.sv

// BEGIN_SOURCE: MainCicDecimator.sv
// Main-only, pipelined CIC3 decimator. ADC sample cadence is unchanged.
// Each arithmetic stage has one adder; valid tokens follow samples through
// the pipeline. Equivalent to three length-32 boxcar FIRs, gain 2^15.
module MainCicDecimator(input logic clk,rst,i_valid,input logic signed [15:0] i_sample,
 output logic o_valid,o_ready,o_clipped,output logic signed [15:0] o_sample);
 logic signed [39:0] int1,int2,int3,z1,z2,z3,c1,c2,c3;
 logic v1,v2,d0,d1,d2,d3,rail1,rail2,clipped,clip0,clip1,clip2,clip3;
 logic [4:0] phase;logic [1:0] warm;
 wire signed [39:0] rounded=(c3+40'sd16384)>>>15;
 always_ff @(posedge clk)begin
  if(rst)begin
   int1<=0;int2<=0;int3<=0;z1<=0;z2<=0;z3<=0;c1<=0;c2<=0;c3<=0;
   v1<=0;v2<=0;d0<=0;d1<=0;d2<=0;d3<=0;rail1<=0;rail2<=0;
   clipped<=0;clip0<=0;clip1<=0;clip2<=0;clip3<=0;phase<=0;warm<=0;
   o_valid<=0;o_ready<=0;o_clipped<=0;o_sample<=0;
  end else begin
   v1<=i_valid;v2<=v1;d0<=0;d1<=d0;d2<=d1;d3<=d2;o_valid<=d3;
   if(i_valid)begin int1<=int1+{{24{i_sample[15]}},i_sample};rail1<=i_sample==32767||i_sample==-32768;end
   if(v1)begin int2<=int2+int1;rail2<=rail1;end
   if(v2)begin
    int3<=int3+int2;phase<=phase+1'b1;clipped<=clipped||rail2;
    if(phase==31)begin d0<=1;clip0<=clipped||rail2;clipped<=0;end
   end
   if(d0)begin c1<=int3-z1;z1<=int3;clip1<=clip0;end
   if(d1)begin c2<=c1-z2;z2<=c1;clip2<=clip1;end
   if(d2)begin c3<=c2-z3;z3<=c2;clip3<=clip2;end
   if(d3)begin
    o_sample<=rounded[15:0];o_clipped<=clip3;
    if(warm!=3)warm<=warm+1'b1;if(warm>=2)o_ready<=1;
   end
  end
 end
endmodule

// END_SOURCE: MainCicDecimator.sv

// BEGIN_SOURCE: ScopeFrameRam.sv
// One complete, immutable frame crosses the clock domains by a done toggle.
// Never written while FFT reads it. Read latency is one rd_clk edge.
module ScopeFrameRam(input logic wr_clk,rd_clk,we,
 input logic [10:0] wr_addr,rd_addr,input logic [15:0] data,
 output wire [15:0] q);
`ifdef FFT_USE_INTEL_RAM
 altsyncram #(.intended_device_family("Cyclone V"),.operation_mode("DUAL_PORT"),
 .width_a(16),.widthad_a(11),.numwords_a(2048),.width_b(16),.widthad_b(11),.numwords_b(2048),
 .width_byteena_a(1),.width_byteena_b(1),.address_reg_b("CLOCK1"),.outdata_reg_b("UNREGISTERED"),
 .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),
 .clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
 .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),.read_during_write_mode_mixed_ports("DONT_CARE")) mem(
 .clock0(wr_clk),.clock1(rd_clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),
 .aclr0(1'b0),.aclr1(1'b0),.addressstall_a(1'b0),.addressstall_b(1'b0),
 .address_a(wr_addr),.address_b(rd_addr),.data_a(data),.data_b(16'b0),.wren_a(we),.wren_b(1'b0),
 .rden_a(1'b1),.rden_b(1'b1),.byteena_a(1'b1),.byteena_b(1'b1),.q_a(),.q_b(q),.eccstatus());
`else
 logic [15:0] memory[0:2047];logic [15:0] qr;
 always_ff @(posedge wr_clk)if(we)memory[wr_addr]<=data;
 always_ff @(posedge rd_clk)qr<=memory[rd_addr];
 assign q=qr;
`endif
endmodule

// END_SOURCE: ScopeFrameRam.sv

// BEGIN_SOURCE: MainFrameRam.sv
// One complete, immutable frame crosses the clock domains by a done toggle.
// Never written while FFT reads it. Read latency is one rd_clk edge.
module MainFrameRam #(parameter integer ADDR_W=10)(input logic wr_clk,rd_clk,we,
 input logic [ADDR_W-1:0] wr_addr,rd_addr,input logic [15:0] data,
 output wire [15:0] q);
`ifdef FFT_USE_INTEL_RAM
 altsyncram #(.intended_device_family("Cyclone V"),.operation_mode("DUAL_PORT"),
 .width_a(16),.widthad_a(ADDR_W),.numwords_a(1<<ADDR_W),.width_b(16),.widthad_b(ADDR_W),.numwords_b(1<<ADDR_W),
 .width_byteena_a(1),.width_byteena_b(1),.address_reg_b("CLOCK1"),.outdata_reg_b("UNREGISTERED"),
 .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),
 .clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
 .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),.read_during_write_mode_mixed_ports("DONT_CARE")) mem(
 .clock0(wr_clk),.clock1(rd_clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),
 .aclr0(1'b0),.aclr1(1'b0),.addressstall_a(1'b0),.addressstall_b(1'b0),
 .address_a(wr_addr),.address_b(rd_addr),.data_a(data),.data_b(16'b0),.wren_a(we),.wren_b(1'b0),
 .rden_a(1'b1),.rden_b(1'b1),.byteena_a(1'b1),.byteena_b(1'b1),.q_a(),.q_b(q),.eccstatus());
`else
 logic [15:0] memory[0:(1<<ADDR_W)-1];logic [15:0] qr;
 always_ff @(posedge wr_clk)if(we)memory[wr_addr]<=data;
 always_ff @(posedge rd_clk)qr<=memory[rd_addr];
 assign q=qr;
`endif
endmodule

// END_SOURCE: MainFrameRam.sv

