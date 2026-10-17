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
