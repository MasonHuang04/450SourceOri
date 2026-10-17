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
