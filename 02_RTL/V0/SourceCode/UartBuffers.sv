// Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

// BEGIN_SOURCE: MainWaveFifo.sv
// Main frame buffer: 16 banks reduce address fan-out and register the read mux.
// Both clocks must be the same 165-MHz clock. Read data is valid six clocks
// after rdreq; MainTxPack explicitly waits before consuming it.
module MainWaveFifo(input aclr,input [15:0] data,input rdclk,rdreq,wrclk,wrreq,
 output logic [7:0] q=0,output wire rdempty,wrfull);
 logic [17:0] words=0;logic [18:0] bytes_read=0;
 logic write_pipe=0;logic [16:0] write_addr=0;logic [17:0] read_addr=0;logic [15:0] write_data=0;
 assign wrfull=words[17];assign rdempty=bytes_read=={words,1'b0};
 wire write_en=wrreq&&!wrfull,read_en=rdreq&&!rdempty;
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
   we<=write_pipe&&(write_addr[16:13]==b)&&!aclr;wa<=write_addr[12:0];wd<=write_data;
   ra<=read_addr[13:1];
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

// BEGIN_SOURCE: MainPeakReport.sv
// 81-byte M3 telemetry (signed Q16 offset and interpolation status) appended after the complete legacy waveform packet.
// Uses the existing UART byte transmitter, never a second pin driver.
module MainPeakReport(input logic clk,rst,i_start,i_tx_busy,
 input logic [31:0] i_seq,i_count,i_span,input logic [14:0] i_bin,
 input logic [40:0] i_power,input logic [15:0] i_min,i_max,input logic [7:0] i_flags,
 input logic [15:0] i_fft_length,
 input logic signed [31:0] i_delta_q16,input logic [7:0] i_interp_status,
 output logic [7:0] o_data,output logic o_valid,o_busy,o_done);
 logic [15:0] fft_length;logic [31:0] seq,count,span,delta_q16;logic [7:0] interp_status;logic [15:0] bin,minval,maxval;logic [43:0] power;
 logic [7:0] flags,checksum,ch,literal,literal_reg;logic [3:0] nib,nib_reg;logic is_hex,is_hex_reg;logic [6:0] index;
 typedef enum logic[2:0] {IDLE,PREP,ENCODE,SEND,ACCEPT,DRAIN} state_t;state_t state;
 function automatic [7:0] hexchar(input [3:0] n);hexchar=n<10 ? 8'd48+n : 8'd55+n;endfunction
 always_comb begin
 is_hex=0;nib=0;literal=8'h2c;
 case(index)
 0:literal="M";1:literal="3";79:literal=13;80:literal=10;
 3:begin is_hex=1;nib=seq[31:28];end
 4:begin is_hex=1;nib=seq[27:24];end
 5:begin is_hex=1;nib=seq[23:20];end
 6:begin is_hex=1;nib=seq[19:16];end
 7:begin is_hex=1;nib=seq[15:12];end
 8:begin is_hex=1;nib=seq[11:8];end
 9:begin is_hex=1;nib=seq[7:4];end
 10:begin is_hex=1;nib=seq[3:0];end
 12:begin is_hex=1;nib=count[31:28];end
 13:begin is_hex=1;nib=count[27:24];end
 14:begin is_hex=1;nib=count[23:20];end
 15:begin is_hex=1;nib=count[19:16];end
 16:begin is_hex=1;nib=count[15:12];end
 17:begin is_hex=1;nib=count[11:8];end
 18:begin is_hex=1;nib=count[7:4];end
 19:begin is_hex=1;nib=count[3:0];end
 21:begin is_hex=1;nib=bin[15:12];end
 22:begin is_hex=1;nib=bin[11:8];end
 23:begin is_hex=1;nib=bin[7:4];end
 24:begin is_hex=1;nib=bin[3:0];end
 26:begin is_hex=1;nib=power[43:40];end
 27:begin is_hex=1;nib=power[39:36];end
 28:begin is_hex=1;nib=power[35:32];end
 29:begin is_hex=1;nib=power[31:28];end
 30:begin is_hex=1;nib=power[27:24];end
 31:begin is_hex=1;nib=power[23:20];end
 32:begin is_hex=1;nib=power[19:16];end
 33:begin is_hex=1;nib=power[15:12];end
 34:begin is_hex=1;nib=power[11:8];end
 35:begin is_hex=1;nib=power[7:4];end
 36:begin is_hex=1;nib=power[3:0];end
 38:begin is_hex=1;nib=minval[15:12];end
 39:begin is_hex=1;nib=minval[11:8];end
 40:begin is_hex=1;nib=minval[7:4];end
 41:begin is_hex=1;nib=minval[3:0];end
 43:begin is_hex=1;nib=maxval[15:12];end
 44:begin is_hex=1;nib=maxval[11:8];end
 45:begin is_hex=1;nib=maxval[7:4];end
 46:begin is_hex=1;nib=maxval[3:0];end
 48:begin is_hex=1;nib=flags[7:4];end
 49:begin is_hex=1;nib=flags[3:0];end
 51:begin is_hex=1;nib=span[31:28];end
 52:begin is_hex=1;nib=span[27:24];end
 53:begin is_hex=1;nib=span[23:20];end
 54:begin is_hex=1;nib=span[19:16];end
 55:begin is_hex=1;nib=span[15:12];end
 56:begin is_hex=1;nib=span[11:8];end
 57:begin is_hex=1;nib=span[7:4];end
 58:begin is_hex=1;nib=span[3:0];end
 60:begin is_hex=1;nib=delta_q16[31:28];end
 61:begin is_hex=1;nib=delta_q16[27:24];end
 62:begin is_hex=1;nib=delta_q16[23:20];end
 63:begin is_hex=1;nib=delta_q16[19:16];end
 64:begin is_hex=1;nib=delta_q16[15:12];end
 65:begin is_hex=1;nib=delta_q16[11:8];end
 66:begin is_hex=1;nib=delta_q16[7:4];end
 67:begin is_hex=1;nib=delta_q16[3:0];end
 69:begin is_hex=1;nib=interp_status[7:4];end
 70:begin is_hex=1;nib=interp_status[3:0];end
 72:begin is_hex=1;nib=fft_length[15:12];end
 73:begin is_hex=1;nib=fft_length[11:8];end
 74:begin is_hex=1;nib=fft_length[7:4];end
 75:begin is_hex=1;nib=fft_length[3:0];end
 77:begin is_hex=1;nib=checksum[7:4];end
 78:begin is_hex=1;nib=checksum[3:0];end
 default:literal=8'h2c;
 endcase
 end
 always_ff @(posedge clk)begin
  o_valid<=0;o_done<=0;
  if(rst)begin
   state<=IDLE;o_busy<=0;o_data<=0;index<=0;checksum<=0;
   ch<=0;nib_reg<=0;literal_reg<=0;is_hex_reg<=0;seq<=0;count<=0;span<=0;bin<=0;power<=0;minval<=0;maxval<=0;flags<=0;delta_q16<=0;interp_status<=1;fft_length<=0;
  end else case(state)
   IDLE:if(i_start)begin
    seq<=i_seq;count<=i_count;span<=i_span;bin<={1'b0,i_bin};power<={3'b0,i_power};
    minval<=i_min;maxval<=i_max;flags<=i_flags;fft_length<=i_fft_length;delta_q16<=i_delta_q16;interp_status<=i_interp_status;index<=0;checksum<=0;o_busy<=1;state<=PREP;
   end
   PREP:begin nib_reg<=nib;literal_reg<=literal;is_hex_reg<=is_hex;state<=ENCODE;end
   ENCODE:begin ch<=is_hex_reg ? hexchar(nib_reg) : literal_reg;state<=SEND;end
   SEND:if(!i_tx_busy)begin
    o_data<=ch;o_valid<=1;if(index<77)checksum<=checksum^ch;state<=ACCEPT;
   end
   ACCEPT:if(i_tx_busy)begin index<=index+1'b1;state<=DRAIN;end
   DRAIN:if(!i_tx_busy)begin
    if(index==81)begin o_busy<=0;o_done<=1;state<=IDLE;end else state<=PREP;
   end
  endcase
 end
endmodule

// END_SOURCE: MainPeakReport.sv

