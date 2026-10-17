// M1 telemetry appended after the complete legacy waveform packet.
// Uses the existing UART byte transmitter, never a second pin driver.
module MainPeakReport(input logic clk,rst,i_start,i_tx_busy,
 input logic [31:0] i_seq,i_count,i_span,input logic [14:0] i_bin,
 input logic [40:0] i_power,input logic [15:0] i_min,i_max,input logic [7:0] i_flags,
 output logic [7:0] o_data,output logic o_valid,o_busy,o_done);
 logic [31:0] seq,count,span;logic [15:0] bin,minval,maxval;logic [43:0] power;
 logic [7:0] flags,checksum,ch,literal,literal_reg;logic [3:0] nib,nib_reg;logic is_hex,is_hex_reg;logic [6:0] index;
 typedef enum logic[2:0] {IDLE,PREP,ENCODE,SEND,ACCEPT,DRAIN} state_t;state_t state;
 function automatic [7:0] hexchar(input [3:0] n);hexchar=n<10 ? 8'd48+n : 8'd55+n;endfunction
 always_comb begin
 is_hex=0;nib=0;literal=8'h2c;
 case(index)
 0:literal="M";1:literal="1";62:literal=13;63:literal=10;
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
 60:begin is_hex=1;nib=checksum[7:4];end
 61:begin is_hex=1;nib=checksum[3:0];end
 default:literal=8'h2c;
 endcase
 end
 always_ff @(posedge clk)begin
  o_valid<=0;o_done<=0;
  if(rst)begin
   state<=IDLE;o_busy<=0;o_data<=0;index<=0;checksum<=0;
   ch<=0;nib_reg<=0;literal_reg<=0;is_hex_reg<=0;seq<=0;count<=0;span<=0;bin<=0;power<=0;minval<=0;maxval<=0;flags<=0;
  end else case(state)
   IDLE:if(i_start)begin
    seq<=i_seq;count<=i_count;span<=i_span;bin<={1'b0,i_bin};power<={3'b0,i_power};
    minval<=i_min;maxval<=i_max;flags<=i_flags;index<=0;checksum<=0;o_busy<=1;state<=PREP;
   end
   PREP:begin nib_reg<=nib;literal_reg<=literal;is_hex_reg<=is_hex;state<=ENCODE;end
   ENCODE:begin ch<=is_hex_reg ? hexchar(nib_reg) : literal_reg;state<=SEND;end
   SEND:if(!i_tx_busy)begin
    o_data<=ch;o_valid<=1;if(index<60)checksum<=checksum^ch;state<=ACCEPT;
   end
   ACCEPT:if(i_tx_busy)begin index<=index+1'b1;state<=DRAIN;end
   DRAIN:if(!i_tx_busy)begin
    if(index==64)begin o_busy<=0;o_done<=1;state<=IDLE;end else state<=PREP;
   end
  endcase
 end
endmodule
