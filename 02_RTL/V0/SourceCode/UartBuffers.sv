// Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

// BEGIN_SOURCE: MainWaveFifo.sv
// Main frame buffer: 16 banks reduce address fan-out and register the read mux.
// Both clocks must be the same 165-MHz clock. Read data is valid six clocks
// after rdreq; MainTxPack explicitly waits before consuming it.
module MainWaveFifo(input aclr,input [15:0] data,input rdclk,rdreq,wrclk,wrreq,
 output logic [7:0] q=0,output wire rdempty,wrfull);
 logic [17:0] words=0;logic [18:0] bytes_read=0;
 logic write_pipe=0;logic [16:0] write_addr=0;logic [17:0] read_addr=0;logic [15:0] write_data=0;
 wire write_en=wrreq&&!wrfull,read_en=rdreq&&!rdempty;
 (* preserve, dont_merge *) logic [16:0] write_addr_group[0:3];
 (* preserve, dont_merge *) logic [17:0] read_addr_group[0:3];
 integer ag;
 always @(posedge wrclk or posedge aclr)begin
  if(aclr)begin for(integer n=0;n<4;n=n+1)begin write_addr_group[n]<=0;read_addr_group[n]<=0;end end
  else begin
   if(write_en)for(integer n=0;n<4;n=n+1)write_addr_group[n]<=words[16:0];
   if(read_en)for(integer n=0;n<4;n=n+1)read_addr_group[n]<=bytes_read[17:0];
  end
 end
 assign wrfull=words[17];assign rdempty=bytes_read=={words,1'b0};
 always @(posedge wrclk or posedge aclr)begin
  if(aclr)begin words<=0;bytes_read<=0;write_pipe<=0;write_addr<=0;read_addr<=0;write_data<=0;end
  else begin
   write_pipe<=write_en;if(write_en)begin words<=words+1'b1;write_addr<=words[16:0];write_data<=data;end
   if(read_en)begin bytes_read<=bytes_read+1'b1;read_addr<=bytes_read[17:0];end
  end
 end
 wire [15:0] bank_q[0:15];
 genvar b; generate for(b=0;b<16;b=b+1)begin:banks
  (* preserve, dont_merge *) logic [12:0] wa=0,ra=0;
  (* preserve, dont_merge *) logic [15:0] wd=0;
  logic we=0;
  always @(posedge wrclk)begin
   we<=write_pipe&&(write_addr_group[b/4][16:13]==b)&&!aclr;wa<=write_addr_group[b/4][12:0];wd<=write_data;
   ra<=read_addr_group[b/4][13:1];
  end
  MainWaveBank ram(.clk(wrclk),.we(we),.wa(wa),.ra(ra),.data(wd),.q(bank_q[b]));
 end
 endgenerate
 logic [15:0] group_word[0:3];
 genvar g;generate for(g=0;g<4;g=g+1)begin:read_groups
  (* preserve, dont_merge *) logic [1:0] sel=0;
  always @(posedge rdclk)begin sel<=read_addr[15:14];group_word[g]<=bank_q[g*4+sel];end
 end endgenerate
 always @(posedge rdclk)q<=read_addr[0] ? group_word[read_addr[17:16]][15:8] : group_word[read_addr[17:16]][7:0];
endmodule
// Split write enables further so one control register drives eight M10Ks.
module MainWaveBank(input clk,we,input [12:0] wa,ra,input [15:0] data,output logic [15:0] q);
 logic [11:0] wa_pipe=0;logic [15:0] data_pipe=0;
 (* preserve, dont_merge *) logic [1:0] we_half=0;
 wire [15:0] half_q[0:1];
 always @(posedge clk)begin wa_pipe<=wa[11:0];data_pipe<=data;we_half<={we&&wa[12],we&&!wa[12]};end
 genvar h;generate for(h=0;h<2;h=h+1)begin:halves
`ifdef FFT_USE_INTEL_RAM
 altsyncram #(.intended_device_family("Cyclone V"),.operation_mode("DUAL_PORT"),
 .width_a(16),.widthad_a(12),.numwords_a(4096),.width_b(16),.widthad_b(12),.numwords_b(4096),
 .width_byteena_a(1),.width_byteena_b(1),.address_reg_b("CLOCK1"),.outdata_reg_b("UNREGISTERED"),
 .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),.clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
 .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),.read_during_write_mode_mixed_ports("DONT_CARE")) mem(
 .clock0(clk),.clock1(clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),.aclr0(1'b0),.aclr1(1'b0),
 .addressstall_a(1'b0),.addressstall_b(1'b0),.address_a(wa_pipe),.address_b(ra[11:0]),.data_a(data_pipe),.data_b(16'b0),
 .wren_a(we_half[h]),.wren_b(1'b0),.rden_a(1'b1),.rden_b(1'b1),.byteena_a(1'b1),.byteena_b(1'b1),.q_a(),.q_b(half_q[h]),.eccstatus());
`else
 logic [15:0] memory[0:4095];logic [15:0] mr;
 always @(posedge clk)begin if(we_half[h])memory[wa_pipe]<=data_pipe;mr<=memory[ra[11:0]];end
 assign half_q[h]=mr;
`endif
 end endgenerate
 always @(posedge clk)q<=half_q[ra[12]];
endmodule

// END_SOURCE: MainWaveFifo.sv

// BEGIN_SOURCE: ScopeUartReport.sv
// 50 MHz, 2 Mbaud, 8N1. Fixed 64-byte ASCII/hex diagnostic record.
// L1,SEQ8,N8,BIN4,POWER11,MIN4,MAX4,FLAGS2,SPAN8,XOR2\r\n
// XOR covers bytes 0..59 inclusive. Data are latched on accepted start.
module ScopeUartReport(input logic clk,rst,i_start,
 input logic [31:0] i_seq,i_count,i_span,input logic [14:0] i_bin,
 input logic [40:0] i_power,input logic [15:0] i_min,i_max,input logic [7:0] i_flags,
 output logic tx,busy,done);
 logic [31:0] seq,count,span;logic [15:0] bin,minval,maxval;logic [43:0] power;
 logic [7:0] flags,checksum,ch;logic [6:0] index;
 logic uart_busy;logic [4:0] timer;logic [3:0] bitidx;logic [9:0] shifter;
 function automatic [7:0] hexchar(input [3:0] n);hexchar=n<10 ? 8'd48+n : 8'd55+n;endfunction
 always_comb begin
  ch=8'h2c;
  if(index==0)ch="L";else if(index==1)ch="1";
  else if(index>=3&&index<=10)ch=hexchar(seq>>((10-index)*4));
  else if(index>=12&&index<=19)ch=hexchar(count>>((19-index)*4));
  else if(index>=21&&index<=24)ch=hexchar(bin>>((24-index)*4));
  else if(index>=26&&index<=36)ch=hexchar(power>>((36-index)*4));
  else if(index>=38&&index<=41)ch=hexchar(minval>>((41-index)*4));
  else if(index>=43&&index<=46)ch=hexchar(maxval>>((46-index)*4));
  else if(index>=48&&index<=49)ch=hexchar(flags>>((49-index)*4));
  else if(index>=51&&index<=58)ch=hexchar(span>>((58-index)*4));
  else if(index==60)ch=hexchar(checksum[7:4]);else if(index==61)ch=hexchar(checksum[3:0]);
  else if(index==62)ch=13;else if(index==63)ch=10;
 end
 always_ff @(posedge clk)begin
  done<=0;
  if(rst)begin
   seq<=0;count<=0;span<=0;bin<=0;power<=0;minval<=0;maxval<=0;flags<=0;checksum<=0;
   tx<=1;busy<=0;uart_busy<=0;timer<=0;bitidx<=0;shifter<=10'h3ff;index<=0;
  end else begin
   if(i_start&&!busy)begin
    seq<=i_seq;count<=i_count;span<=i_span;bin<={1'b0,i_bin};power<={3'b0,i_power};
    minval<=i_min;maxval<=i_max;flags<=i_flags;checksum<=0;index<=0;busy<=1;
   end
   if(busy&&!uart_busy)begin
    if(index==64)begin busy<=0;done<=1;end
    else begin
     tx<=0;shifter<={1'b1,ch,1'b0};uart_busy<=1;timer<=24;bitidx<=0;
     if(index<60)checksum<=checksum^ch;
     index<=index+1'b1;
    end
   end
   if(uart_busy)begin
    if(timer!=0)timer<=timer-1'b1;
    else if(bitidx==9)begin uart_busy<=0;tx<=1;end
    else begin timer<=24;bitidx<=bitidx+1'b1;shifter<={1'b1,shifter[9:1]};tx<=shifter[1];end
   end
  end
 end
endmodule

// END_SOURCE: ScopeUartReport.sv

// BEGIN_SOURCE: MainTempSnapshot.sv
// Latest acknowledged TMP117 read, captured with the RX frame. Q7 deg C.
// Status: 0 valid; 1 no successful/current read; 2 stale; 3 outside sensor range.
module MainTempSnapshot #(parameter integer MAX_AGE=330000000)(
 input logic clk,rst,i_updated,i_valid,i_capture,input logic signed [15:0] i_temp,
 output logic [15:0] o_temp,output logic [7:0] o_status);
 localparam AW=$clog2(MAX_AGE+1);
 logic [AW-1:0] age;logic seen,last_valid,capture_last;logic signed [15:0] last_temp;
 wire signed [15:0] selected_temp=i_updated ? i_temp:last_temp;
 wire fresh_valid=i_updated ? i_valid:(seen&&last_valid);
 always_ff @(posedge clk)begin
  if(rst)begin age<=MAX_AGE;seen<=0;last_valid<=0;last_temp<=0;o_temp<=0;o_status<=1;capture_last<=0;end
  else begin
   capture_last<=i_capture;
   if(age<MAX_AGE)age<=age+1'b1;
   if(i_updated)begin seen<=1;last_valid<=i_valid;last_temp<=i_temp;age<=0;end
   if(i_capture&&!capture_last)begin
    o_temp<=selected_temp;
    if(!fresh_valid)o_status<=1;
    else if(!i_updated&&age>=MAX_AGE)o_status<=2;
    else if(selected_temp< -16'sd7040||selected_temp>16'sd19200)o_status<=3;
    else o_status<=0;
   end
  end
 end
endmodule
// END_SOURCE: MainTempSnapshot.sv

// BEGIN_SOURCE: MainRangeCalculator.sv
// Runs in the existing 50 MHz FFT domain. All arithmetic is on the FPGA.
// c_mm/s=round(331300 + 606*temperature_Q7/128).
// R_um=round(c_mm/s * f_mHz * T_us / (2000 * B_mHz)).
// IEEE32 runtime B/T are rounded to milliHz/microseconds (GUI steps are coarser).
// Range status: 0 valid estimate; 1 FFT flags; 2 temperature invalid;
// 3 chirp parameters invalid; 4 overflow; 5 interpolation unavailable.
module MainRangeCalculator(input logic clk,rst,i_start,
 input logic [15:0] i_bin,i_fft_length,input logic [7:0] i_flags,i_interp_status,i_temp_status,
 input logic signed [31:0] i_delta_q16,input logic signed [15:0] i_temp,
 input logic [31:0] i_bandwidth_fp,i_duration_fp,input logic i_chirp,
 output logic o_done,output logic [31:0] o_frequency_millihz,o_distance_um,
 output logic [7:0] o_status);
 typedef enum logic[3:0] {IDLE,FMUL,FDIV,DECODE,CHECK_PARAMS,RMUL,RMUL_INIT,RMUL_STEP,RDIV,DIVIDE,DONE} state_t;
 state_t state;logic [31:0] fq,bw_bits,time_bits,bw_millihz,duration_us,speed_mm_s;
 logic signed [15:0] temp_latched;logic [15:0] nfft;logic [7:0] pending_status;logic chirp;
 logic [63:0] frequency_product,range_product,mul_factor,mul_acc;
 logic [31:0] mul_times;logic [5:0] mul_step;
 logic [63:0] dividend,divisor,quotient;logic [64:0] remainder;logic [6:0] div_step;logic range_div;
 logic [63:0] bw_fixed,time_fixed;
 wire signed [33:0] fq_input=$signed({2'b00,i_bin,16'b0})+((i_interp_status==0&&i_flags==0)?$signed({{2{i_delta_q16[31]}},i_delta_q16}):34'sd0);
 wire signed [31:0] speed_numerator=32'sd42406400+32'sd606*$signed(temp_latched)+32'sd64;
 wire [64:0] trial={remainder[63:0],dividend[63]};
 wire subtract_ok=trial>={1'b0,divisor};
 wire [63:0] quotient_next={quotient[62:0],subtract_ok};
 function automatic [63:0] fp_scaled(input logic [31:0] value,input logic [31:0] scale);
  logic [63:0] product;integer sh;
  begin
   product={1'b1,value[22:0]}*scale;sh=integer'(value[30:23])-150;
   if(value[31]||value[30:23]==255)fp_scaled=64'hffffffffffffffff;
   else if(value[30:23]==0)fp_scaled=0;
   else if(sh>=0)begin
    if(sh>=64||product>(64'hffffffffffffffff>>sh))fp_scaled=64'hffffffffffffffff;
    else fp_scaled=product<<sh;
   end else if(-sh>=64)fp_scaled=0;
   else fp_scaled=(product+(64'd1<<(-sh-1)))>>(-sh);
  end
 endfunction
 always_ff @(posedge clk)begin
  if(rst)begin
   state<=IDLE;o_done<=0;o_frequency_millihz<=0;o_distance_um<=0;o_status<=1;
   fq<=0;bw_bits<=0;time_bits<=0;bw_millihz<=0;duration_us<=0;speed_mm_s<=0;temp_latched<=0;nfft<=0;pending_status<=1;chirp<=0;
   frequency_product<=0;range_product<=0;mul_factor<=0;mul_acc<=0;mul_times<=0;mul_step<=0;
   dividend<=0;divisor<=0;quotient<=0;remainder<=0;div_step<=0;range_div<=0;bw_fixed<=0;time_fixed<=0;
  end else begin
   o_done<=0;
   case(state)
    IDLE:if(i_start)begin
     o_distance_um<=0;o_frequency_millihz<=0;o_status<=1;
     fq<=fq_input[31:0];nfft<=i_fft_length;bw_bits<=i_bandwidth_fp;time_bits<=i_duration_fp;chirp<=i_chirp;
     temp_latched<=i_temp;
     pending_status<=i_flags!=0 ? 1:i_temp_status!=0 ? 2:i_interp_status!=0 ? 5:0;
     if(fq_input<=0||i_bin>i_fft_length/2||!(i_fft_length==1024||i_fft_length==2048||i_fft_length==4096||i_fft_length==8192))state<=DONE;
     else state<=FMUL;
    end
    FMUL:begin frequency_product<=fq*32'd107421875;state<=FDIV;end
    FDIV:begin
     divisor<=64'(nfft)*64'd196608;
     dividend<=frequency_product+64'(nfft)*64'd98304;
     quotient<=0;remainder<=0;div_step<=0;range_div<=0;state<=DIVIDE;
    end
    DECODE:begin speed_mm_s<=speed_numerator>>>7;bw_fixed<=fp_scaled(bw_bits,32'd1000);time_fixed<=fp_scaled(time_bits,32'd1000000);state<=CHECK_PARAMS;end
    CHECK_PARAMS:begin
     if(pending_status!=0)begin o_status<=pending_status;state<=DONE;end
     else if(!chirp||bw_fixed==0||bw_fixed>1000000000||time_fixed<10||time_fixed>100000)begin o_status<=3;state<=DONE;end
     else begin bw_millihz<=bw_fixed[31:0];duration_us<=time_fixed[31:0];state<=RMUL;end
    end
    RMUL:begin range_product<=speed_mm_s*o_frequency_millihz;state<=RMUL_INIT;end
    RMUL_INIT:begin mul_factor<=range_product;mul_acc<=0;mul_times<=duration_us;mul_step<=0;state<=RMUL_STEP;end
    RMUL_STEP:begin
     if(mul_times[0])mul_acc<=mul_acc+mul_factor;
     mul_factor<=mul_factor<<1;mul_times<=mul_times>>1;
     if(mul_step==31)state<=RDIV;else mul_step<=mul_step+1'b1;
    end
    RDIV:begin
     divisor<=64'(bw_millihz)*64'd2000;dividend<=mul_acc+64'(bw_millihz)*64'd1000;
     quotient<=0;remainder<=0;div_step<=0;range_div<=1;state<=DIVIDE;
    end
    DIVIDE:begin
     dividend<={dividend[62:0],1'b0};quotient<=quotient_next;
     remainder<=subtract_ok ? trial-{1'b0,divisor}:trial;
     if(div_step==63)begin
      if(quotient_next>64'hffffffff)begin o_status<=4;state<=DONE;end
      else if(range_div)begin o_distance_um<=quotient_next[31:0];o_status<=0;state<=DONE;end
      else begin o_frequency_millihz<=quotient_next[31:0];state<=DECODE;end
     end else div_step<=div_step+1'b1;
    end
    DONE:begin o_done<=1;state<=IDLE;end
    default:state<=IDLE;
   endcase
  end
 end
endmodule
// END_SOURCE: MainRangeCalculator.sv


// BEGIN_SOURCE: MainPeakReport.sv
// M3 compatibility by default. Main enables 110-byte M4 temperature/range telemetry.
module MainPeakReport #(parameter integer RANGE_REPORT=0)(input logic clk,rst,i_start,i_tx_busy,
 input logic [31:0] i_seq,i_count,i_span,input logic [14:0] i_bin,
 input logic [40:0] i_power,input logic [15:0] i_min,i_max,input logic [7:0] i_flags,
 input logic [15:0] i_fft_length,input logic signed [31:0] i_delta_q16,input logic [7:0] i_interp_status,
 input logic i_calc_clk,i_calc_rst,input logic [15:0] i_temp,input logic [7:0] i_temp_status,
 input logic [31:0] i_bandwidth_fp,i_duration_fp,input logic i_chirp,
 output logic [7:0] o_data,output logic o_valid,o_busy,o_done);
 localparam integer TOTAL=RANGE_REPORT ? 110:81,CHECK_AT=TOTAL-4;
 logic [15:0] fft_length,bin,minval,maxval,temp_raw;
 logic [31:0] seq,count,span,delta_q16,bw_bits,time_bits,frequency_millihz,distance_um;
 logic [7:0] flags,interp_status,temp_status,range_status,checksum,ch,literal,literal_reg;
 logic [43:0] power;logic waveform_ok;logic [3:0] nib,nib_reg;logic is_hex,is_hex_reg;logic [6:0] index;
 logic request,ack_seen;wire result_toggle;wire [71:0] result_hold;
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] result_sync;
 typedef enum logic[2:0] {IDLE,PREP,ENCODE,SEND,ACCEPT,DRAIN,WAIT_CALC} state_t;state_t state;
 function automatic [7:0] hexchar(input [3:0] n);hexchar=n<10 ? 8'd48+n : 8'd55+n;endfunction
 generate if(RANGE_REPORT)begin:g_range
  (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] request_sync;
  logic request_seen,calc_start,ack;(* preserve, dont_merge *) logic [168:0] args_cap;(* preserve, dont_merge *) logic [71:0] held;
  wire [15:0] arg_bin,arg_nfft,arg_temp;wire [7:0] arg_flags,arg_interp,arg_temp_status;
  wire [31:0] arg_delta,arg_bw,arg_time;wire arg_chirp;
  wire calc_done;wire [31:0] calc_frequency,calc_distance;wire [7:0] calc_status;
  assign {arg_bin,arg_flags,arg_delta,arg_interp,arg_nfft,arg_temp,arg_temp_status,arg_bw,arg_time,arg_chirp}=args_cap;
  MainRangeCalculator calculator(.clk(i_calc_clk),.rst(i_calc_rst),.i_start(calc_start),.i_bin(arg_bin),.i_fft_length(arg_nfft),
   .i_flags(arg_flags),.i_interp_status(arg_interp),.i_temp_status(arg_temp_status),.i_delta_q16(arg_delta),.i_temp(arg_temp),
   .i_bandwidth_fp(arg_bw),.i_duration_fp(arg_time),.i_chirp(arg_chirp),.o_done(calc_done),
   .o_frequency_millihz(calc_frequency),.o_distance_um(calc_distance),.o_status(calc_status));
  always_ff @(posedge i_calc_clk)begin
   if(i_calc_rst)begin request_sync<=0;request_seen<=0;calc_start<=0;args_cap<=0;held<=0;ack<=0;end
   else begin
    request_sync<={request_sync[0],request};calc_start<=0;
    if(request_sync[1]!=request_seen)begin
     request_seen<=request_sync[1];args_cap<={bin,flags,delta_q16,interp_status,fft_length,temp_raw,temp_status,bw_bits,time_bits,waveform_ok};calc_start<=1;
    end
    if(calc_done)begin held<={calc_frequency,calc_distance,calc_status};ack<=~ack;end
   end
  end
  assign result_hold=held;assign result_toggle=ack;
 end else begin:g_legacy
  assign result_hold=72'd0;assign result_toggle=1'b0;
 end endgenerate
 logic [TOTAL-1:0] position;
 always_comb begin
  is_hex=0;nib=0;literal=8'h2c;
  if(position[0])literal="M";
  else if(position[1])literal=RANGE_REPORT ? "4":"3";
  else if(position[TOTAL-2])literal=13;
  else if(position[TOTAL-1])literal=10;
   nib=nib|(seq[31:28]&{4{position[3]}});is_hex=is_hex|position[3];
   nib=nib|(seq[27:24]&{4{position[4]}});is_hex=is_hex|position[4];
   nib=nib|(seq[23:20]&{4{position[5]}});is_hex=is_hex|position[5];
   nib=nib|(seq[19:16]&{4{position[6]}});is_hex=is_hex|position[6];
   nib=nib|(seq[15:12]&{4{position[7]}});is_hex=is_hex|position[7];
   nib=nib|(seq[11:8]&{4{position[8]}});is_hex=is_hex|position[8];
   nib=nib|(seq[7:4]&{4{position[9]}});is_hex=is_hex|position[9];
   nib=nib|(seq[3:0]&{4{position[10]}});is_hex=is_hex|position[10];
   nib=nib|(count[31:28]&{4{position[12]}});is_hex=is_hex|position[12];
   nib=nib|(count[27:24]&{4{position[13]}});is_hex=is_hex|position[13];
   nib=nib|(count[23:20]&{4{position[14]}});is_hex=is_hex|position[14];
   nib=nib|(count[19:16]&{4{position[15]}});is_hex=is_hex|position[15];
   nib=nib|(count[15:12]&{4{position[16]}});is_hex=is_hex|position[16];
   nib=nib|(count[11:8]&{4{position[17]}});is_hex=is_hex|position[17];
   nib=nib|(count[7:4]&{4{position[18]}});is_hex=is_hex|position[18];
   nib=nib|(count[3:0]&{4{position[19]}});is_hex=is_hex|position[19];
   nib=nib|(bin[15:12]&{4{position[21]}});is_hex=is_hex|position[21];
   nib=nib|(bin[11:8]&{4{position[22]}});is_hex=is_hex|position[22];
   nib=nib|(bin[7:4]&{4{position[23]}});is_hex=is_hex|position[23];
   nib=nib|(bin[3:0]&{4{position[24]}});is_hex=is_hex|position[24];
   nib=nib|(power[43:40]&{4{position[26]}});is_hex=is_hex|position[26];
   nib=nib|(power[39:36]&{4{position[27]}});is_hex=is_hex|position[27];
   nib=nib|(power[35:32]&{4{position[28]}});is_hex=is_hex|position[28];
   nib=nib|(power[31:28]&{4{position[29]}});is_hex=is_hex|position[29];
   nib=nib|(power[27:24]&{4{position[30]}});is_hex=is_hex|position[30];
   nib=nib|(power[23:20]&{4{position[31]}});is_hex=is_hex|position[31];
   nib=nib|(power[19:16]&{4{position[32]}});is_hex=is_hex|position[32];
   nib=nib|(power[15:12]&{4{position[33]}});is_hex=is_hex|position[33];
   nib=nib|(power[11:8]&{4{position[34]}});is_hex=is_hex|position[34];
   nib=nib|(power[7:4]&{4{position[35]}});is_hex=is_hex|position[35];
   nib=nib|(power[3:0]&{4{position[36]}});is_hex=is_hex|position[36];
   nib=nib|(minval[15:12]&{4{position[38]}});is_hex=is_hex|position[38];
   nib=nib|(minval[11:8]&{4{position[39]}});is_hex=is_hex|position[39];
   nib=nib|(minval[7:4]&{4{position[40]}});is_hex=is_hex|position[40];
   nib=nib|(minval[3:0]&{4{position[41]}});is_hex=is_hex|position[41];
   nib=nib|(maxval[15:12]&{4{position[43]}});is_hex=is_hex|position[43];
   nib=nib|(maxval[11:8]&{4{position[44]}});is_hex=is_hex|position[44];
   nib=nib|(maxval[7:4]&{4{position[45]}});is_hex=is_hex|position[45];
   nib=nib|(maxval[3:0]&{4{position[46]}});is_hex=is_hex|position[46];
   nib=nib|(flags[7:4]&{4{position[48]}});is_hex=is_hex|position[48];
   nib=nib|(flags[3:0]&{4{position[49]}});is_hex=is_hex|position[49];
   nib=nib|(span[31:28]&{4{position[51]}});is_hex=is_hex|position[51];
   nib=nib|(span[27:24]&{4{position[52]}});is_hex=is_hex|position[52];
   nib=nib|(span[23:20]&{4{position[53]}});is_hex=is_hex|position[53];
   nib=nib|(span[19:16]&{4{position[54]}});is_hex=is_hex|position[54];
   nib=nib|(span[15:12]&{4{position[55]}});is_hex=is_hex|position[55];
   nib=nib|(span[11:8]&{4{position[56]}});is_hex=is_hex|position[56];
   nib=nib|(span[7:4]&{4{position[57]}});is_hex=is_hex|position[57];
   nib=nib|(span[3:0]&{4{position[58]}});is_hex=is_hex|position[58];
   nib=nib|(delta_q16[31:28]&{4{position[60]}});is_hex=is_hex|position[60];
   nib=nib|(delta_q16[27:24]&{4{position[61]}});is_hex=is_hex|position[61];
   nib=nib|(delta_q16[23:20]&{4{position[62]}});is_hex=is_hex|position[62];
   nib=nib|(delta_q16[19:16]&{4{position[63]}});is_hex=is_hex|position[63];
   nib=nib|(delta_q16[15:12]&{4{position[64]}});is_hex=is_hex|position[64];
   nib=nib|(delta_q16[11:8]&{4{position[65]}});is_hex=is_hex|position[65];
   nib=nib|(delta_q16[7:4]&{4{position[66]}});is_hex=is_hex|position[66];
   nib=nib|(delta_q16[3:0]&{4{position[67]}});is_hex=is_hex|position[67];
   nib=nib|(interp_status[7:4]&{4{position[69]}});is_hex=is_hex|position[69];
   nib=nib|(interp_status[3:0]&{4{position[70]}});is_hex=is_hex|position[70];
   nib=nib|(fft_length[15:12]&{4{position[72]}});is_hex=is_hex|position[72];
   nib=nib|(fft_length[11:8]&{4{position[73]}});is_hex=is_hex|position[73];
   nib=nib|(fft_length[7:4]&{4{position[74]}});is_hex=is_hex|position[74];
   nib=nib|(fft_length[3:0]&{4{position[75]}});is_hex=is_hex|position[75];
  if(RANGE_REPORT)begin
   nib=nib|(temp_raw[15:12]&{4{position[77]}});is_hex=is_hex|position[77];
   nib=nib|(temp_raw[11:8]&{4{position[78]}});is_hex=is_hex|position[78];
   nib=nib|(temp_raw[7:4]&{4{position[79]}});is_hex=is_hex|position[79];
   nib=nib|(temp_raw[3:0]&{4{position[80]}});is_hex=is_hex|position[80];
   nib=nib|(temp_status[7:4]&{4{position[82]}});is_hex=is_hex|position[82];
   nib=nib|(temp_status[3:0]&{4{position[83]}});is_hex=is_hex|position[83];
   nib=nib|(frequency_millihz[31:28]&{4{position[85]}});is_hex=is_hex|position[85];
   nib=nib|(frequency_millihz[27:24]&{4{position[86]}});is_hex=is_hex|position[86];
   nib=nib|(frequency_millihz[23:20]&{4{position[87]}});is_hex=is_hex|position[87];
   nib=nib|(frequency_millihz[19:16]&{4{position[88]}});is_hex=is_hex|position[88];
   nib=nib|(frequency_millihz[15:12]&{4{position[89]}});is_hex=is_hex|position[89];
   nib=nib|(frequency_millihz[11:8]&{4{position[90]}});is_hex=is_hex|position[90];
   nib=nib|(frequency_millihz[7:4]&{4{position[91]}});is_hex=is_hex|position[91];
   nib=nib|(frequency_millihz[3:0]&{4{position[92]}});is_hex=is_hex|position[92];
   nib=nib|(distance_um[31:28]&{4{position[94]}});is_hex=is_hex|position[94];
   nib=nib|(distance_um[27:24]&{4{position[95]}});is_hex=is_hex|position[95];
   nib=nib|(distance_um[23:20]&{4{position[96]}});is_hex=is_hex|position[96];
   nib=nib|(distance_um[19:16]&{4{position[97]}});is_hex=is_hex|position[97];
   nib=nib|(distance_um[15:12]&{4{position[98]}});is_hex=is_hex|position[98];
   nib=nib|(distance_um[11:8]&{4{position[99]}});is_hex=is_hex|position[99];
   nib=nib|(distance_um[7:4]&{4{position[100]}});is_hex=is_hex|position[100];
   nib=nib|(distance_um[3:0]&{4{position[101]}});is_hex=is_hex|position[101];
   nib=nib|(range_status[7:4]&{4{position[103]}});is_hex=is_hex|position[103];
   nib=nib|(range_status[3:0]&{4{position[104]}});is_hex=is_hex|position[104];
   nib=nib|(checksum[7:4]&{4{position[106]}});is_hex=is_hex|position[106];
   nib=nib|(checksum[3:0]&{4{position[107]}});is_hex=is_hex|position[107];
  end else begin
   nib=nib|(checksum[7:4]&{4{position[77]}});is_hex=is_hex|position[77];
   nib=nib|(checksum[3:0]&{4{position[78]}});is_hex=is_hex|position[78];
  end
 end
 always_ff @(posedge clk)begin
  o_valid<=0;o_done<=0;
  if(rst)begin
   state<=IDLE;o_busy<=0;o_data<=0;index<=0;checksum<=0;
   ch<=0;nib_reg<=0;literal_reg<=0;is_hex_reg<=0;seq<=0;count<=0;span<=0;bin<=0;power<=0;minval<=0;maxval<=0;flags<=0;delta_q16<=0;interp_status<=1;fft_length<=0;
   temp_raw<=0;temp_status<=1;range_status<=1;frequency_millihz<=0;distance_um<=0;bw_bits<=0;time_bits<=0;waveform_ok<=0;
   request<=0;ack_seen<=0;result_sync<=0;position<=0;
  end else begin
   result_sync<={result_sync[0],result_toggle};
   case(state)
    IDLE:if(i_start)begin
     seq<=i_seq;count<=i_count;span<=i_span;bin<={1'b0,i_bin};power<={3'b0,i_power};
     minval<=i_min;maxval<=i_max;flags<=i_flags;fft_length<=i_fft_length;delta_q16<=i_delta_q16;interp_status<=i_interp_status;
     temp_raw<=i_temp;temp_status<=i_temp_status;bw_bits<=i_bandwidth_fp;time_bits<=i_duration_fp;waveform_ok<=i_chirp;
     index<=0;checksum<=0;o_busy<=1;position<={{(TOTAL-1){1'b0}},1'b1};
     if(RANGE_REPORT)begin request<=~request;state<=WAIT_CALC;end else state<=PREP;
    end
    WAIT_CALC:if(result_sync[1]!=ack_seen)begin
     ack_seen<=result_sync[1];{frequency_millihz,distance_um,range_status}<=result_hold;state<=PREP;
    end
    PREP:begin nib_reg<=nib;literal_reg<=literal;is_hex_reg<=is_hex;state<=ENCODE;end
    ENCODE:begin ch<=is_hex_reg ? hexchar(nib_reg) : literal_reg;state<=SEND;end
    SEND:if(!i_tx_busy)begin o_data<=ch;o_valid<=1;if(index<CHECK_AT)checksum<=checksum^ch;state<=ACCEPT;end
    ACCEPT:if(i_tx_busy)begin index<=index+1'b1;position<=position<<1;state<=DRAIN;end
    DRAIN:if(!i_tx_busy)begin if(index==TOTAL)begin o_busy<=0;o_done<=1;state<=IDLE;end else state<=PREP;end
   endcase
  end
 end
endmodule
// END_SOURCE: MainPeakReport.sv

