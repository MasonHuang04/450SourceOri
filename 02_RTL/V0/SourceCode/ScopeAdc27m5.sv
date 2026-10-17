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
