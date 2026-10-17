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
