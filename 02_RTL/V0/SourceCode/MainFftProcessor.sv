// Triggered FFT side branch. Full-rate ADC data are independent of raw-packet thinning.
// Frame RAM and bundled metadata remain immutable until the next main acquisition.
module MainFftProcessor #(
 parameter integer VALID_SAMPLES=8192,SAMPLE_TICKS=4608,DELTA_W=6,MIN_BIN=6,MAX_BIN=114
)(input logic sys_clk,fft_clk,sys_rst,fft_rst,i_start,i_capture_active,i_raw_valid,
 input logic signed [15:0] i_raw_sample,
 output logic o_done,output logic [31:0] o_seq,o_count,o_span,
 output logic [14:0] o_bin,output logic [40:0] o_power,
 output logic [15:0] o_min,o_max,output logic [7:0] o_flags);
 logic start_last;wire start_pulse=i_start&&!start_last;
 wire cv,cr,cc;wire signed [15:0] cs;
 MainCicDecimator filter(.clk(sys_clk),.rst(sys_rst||start_pulse),
 .i_valid(i_raw_valid&&i_capture_active),.i_sample(i_raw_sample),.o_valid(cv),.o_ready(cr),.o_clipped(cc),.o_sample(cs));
 logic cap_active,saw_window,done_toggle;
 logic [13:0] cap_count; //0..8192; match the fixed main frame capacity
 logic [31:0] cap_span,tick,first_tick,last_tick,cap_seq;
 logic signed [31:0] cap_sum;logic signed [15:0] cap_min,cap_max;logic [7:0] cap_flags;
 wire ram_we=cap_active&&i_capture_active&&cv&&cr&&(cap_count<VALID_SAMPLES);
 logic [12:0] rd_addr;wire [15:0] ram_q;
 MainFrameRam frame(.wr_clk(sys_clk),.rd_clk(fft_clk),.we(ram_we),.wr_addr(cap_count[12:0]),.rd_addr(rd_addr),.data(cs),.q(ram_q));
 always_ff @(posedge sys_clk)begin
  if(sys_rst)begin
   start_last<=0;cap_active<=0;saw_window<=0;done_toggle<=0;cap_count<=0;cap_span<=0;
   tick<=0;first_tick<=0;last_tick<=0;cap_seq<=0;cap_sum<=0;cap_min<=16'sh7fff;cap_max<=16'sh8000;cap_flags<=0;
  end else begin
   start_last<=i_start;tick<=tick+1'b1;
   if(start_pulse)begin
    cap_active<=1;saw_window<=0;cap_seq<=cap_seq+1'b1;cap_count<=0;cap_span<=0;cap_sum<=0;
    cap_min<=16'sh7fff;cap_max<=16'sh8000;cap_flags<=0;
   end else if(cap_active)begin
    if(i_capture_active)saw_window<=1;
    if(i_raw_valid&&i_capture_active&&(i_raw_sample==32767||i_raw_sample==-32768))cap_flags[2]<=1;
    if(ram_we)begin
     cap_sum<=cap_sum+$signed(cs);cap_count<=cap_count+1'b1;
     if(cap_count==0)first_tick<=tick;else if(tick-last_tick!=SAMPLE_TICKS)cap_flags[1]<=1;
     last_tick<=tick;if(cs<cap_min)cap_min<=cs;if(cs>cap_max)cap_max<=cs;if(cc)cap_flags[2]<=1;
     if(cap_count==VALID_SAMPLES-1)begin cap_span<=tick-first_tick;cap_active<=0;done_toggle<=~done_toggle;end
    end else if(saw_window&&!i_capture_active)begin
     cap_flags[0]<=1;cap_span<=cap_count==0 ? 0 : last_tick-first_tick;
     cap_active<=0;done_toggle<=~done_toggle;
    end
   end
  end
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] done_sync;
 logic done_seen,result_toggle;
 typedef enum logic[3:0] {WAIT_FRAME,META,CHECK,MEAN_DIV,FSTART,RADDR,RWAIT,FEED,FWAIT,REPORT} state_t;
 state_t state;
 logic [31:0] report_seq,report_count,report_span;
 logic signed [31:0] report_sum;logic signed [15:0] report_min,report_max,dc_mean;
 logic [7:0] report_flags;logic [14:0] report_bin;logic [40:0] report_power;
 logic [31:0] div_work,div_rem,div_quot;logic [5:0] div_steps;logic div_negative;
 wire [31:0] div_trial={div_rem[30:0],div_work[31]};
 wire [31:0] div_next={div_quot[30:0],(div_trial>=VALID_SAMPLES)};
 wire signed [16:0] centered=$signed({ram_q[15],ram_q})-$signed({dc_mean[15],dc_mean});
 wire centered_clip=(centered>17'sd32767)||(centered< -17'sd32768);
 wire signed [15:0] fft_sample=centered>17'sd32767 ? 16'sh7fff : centered< -17'sd32768 ? 16'sh8000 : centered[15:0];
 logic [12:0] sample_index;
 wire fft_input_ready,fft_busy,fft_valid,fft_ready,fft_sop,fft_eop,fft_done,fft_overflow;
 wire [12:0] fft_bin;wire signed [19:0] fft_re,fft_im;
 wire [14:0] peak_bin,power_bin;wire [40:0] peak_power,power_value;
 wire power_valid,peak_valid,peak_found;wire signed [19:0] power_re,power_im;
 kaiser4_rfft #(.LOGN(13),.VALID_SAMPLES(VALID_SAMPLES),.DELTA_W(DELTA_W),.WINDOW_FIRST(11597),
 .WINDOW_FILE("main_window_delta.mem"),.TWIDDLE_FILE("main_cos_quarter.mem"),
 .WINDOW_MIF("main_window_delta.mif"),.TWIDDLE_MIF("main_cos_quarter.mif")) fft(
 .clk(fft_clk),.rst(fft_rst),.i_start(state==FSTART),.i_valid(state==FEED),.i_sample(fft_sample),
 .o_in_ready(fft_input_ready),.o_busy(fft_busy),.i_out_ready(fft_ready),.o_out_valid(fft_valid),
 .o_out_bin(fft_bin),.o_out_re(fft_re),.o_out_im(fft_im),.o_out_sop(fft_sop),.o_out_eop(fft_eop),.o_done(fft_done),.o_overflow(fft_overflow));
 fft_power_peak #(.BIN_W(15)) peak(.clk(fft_clk),.rst(fft_rst),.i_valid(fft_valid),.o_ready(fft_ready),
 .i_re(fft_re),.i_im(fft_im),.i_bin({2'b0,fft_bin}),.i_sop(fft_sop),.i_eop(fft_eop),
 .i_min_bin(15'(MIN_BIN)),.i_max_bin(15'(MAX_BIN)),.i_min_power(41'd6400),
 .o_power_valid(power_valid),.i_power_ready(1'b1),.o_power(power_value),.o_bin(power_bin),.o_re(power_re),.o_im(power_im),.o_sop(),.o_eop(),
 .o_peak_valid(peak_valid),.i_peak_ready(1'b1),.o_peak_bin(peak_bin),.o_peak_power(peak_power),.o_peak_found(peak_found));
 always_ff @(posedge fft_clk)begin
  if(fft_rst)begin
   done_sync<=0;done_seen<=0;result_toggle<=0;state<=WAIT_FRAME;report_seq<=0;report_count<=0;report_span<=0;
   report_sum<=0;report_min<=0;report_max<=0;dc_mean<=0;report_flags<=0;report_bin<=0;report_power<=0;
   div_work<=0;div_rem<=0;div_quot<=0;div_steps<=0;div_negative<=0;sample_index<=0;rd_addr<=0;
  end else begin
   done_sync<={done_sync[0],done_toggle};
   case(state)
    WAIT_FRAME:if(done_sync[1]!=done_seen)begin done_seen<=done_sync[1];state<=META;end
    META:begin
     report_seq<=cap_seq;report_count<=cap_count;report_span<=cap_span;report_sum<=cap_sum;
     report_min<=cap_min;report_max<=cap_max;report_flags<=cap_flags;report_bin<=0;report_power<=0;sample_index<=0;rd_addr<=0;state<=CHECK;
    end
    CHECK:if(report_flags[0]||report_count!=VALID_SAMPLES)state<=REPORT;
     else begin div_work<=report_sum[31] ? -report_sum : report_sum;div_negative<=report_sum[31];div_rem<=0;div_quot<=0;div_steps<=0;state<=MEAN_DIV;end
    MEAN_DIV:begin
     div_work<={div_work[30:0],1'b0};div_quot<=div_next;div_rem<=div_trial>=VALID_SAMPLES ? div_trial-VALID_SAMPLES : div_trial;
     if(div_steps==31)begin dc_mean<=div_negative ? -$signed({1'b0,div_next[15:0]}) : $signed({1'b0,div_next[15:0]});state<=FSTART;end
     else div_steps<=div_steps+1'b1;
    end
    FSTART:state<=RADDR;
    RADDR:begin rd_addr<=sample_index;state<=RWAIT;end
    RWAIT:state<=FEED;
    FEED:if(fft_input_ready)begin
     if(centered_clip)report_flags[5]<=1;
     if(sample_index==VALID_SAMPLES-1)state<=FWAIT;else begin sample_index<=sample_index+1'b1;state<=RADDR;end
    end
    FWAIT:if(peak_valid)begin report_bin<=peak_bin;report_power<=peak_power;report_flags[3]<=fft_overflow;report_flags[4]<=!peak_found;state<=REPORT;end
    REPORT:begin result_toggle<=~result_toggle;state<=WAIT_FRAME;end
    default:state<=WAIT_FRAME;
   endcase
  end
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] result_sync;
 logic result_seen,result_pending;
 always_ff @(posedge sys_clk)begin
  if(sys_rst)begin
   result_sync<=0;result_seen<=0;result_pending<=0;o_done<=0;o_seq<=0;o_count<=0;o_span<=0;o_bin<=0;o_power<=0;o_min<=0;o_max<=0;o_flags<=0;
  end else begin
   result_sync<={result_sync[0],result_toggle};
   if(start_pulse)o_done<=0;
   if(result_sync[1]!=result_seen)begin result_seen<=result_sync[1];result_pending<=1;end
   if(result_pending)begin
    result_pending<=0;o_seq<=report_seq;o_count<=report_count;o_span<=report_span;o_bin<=report_bin;
    o_power<=report_power;o_min<=report_min;o_max<=report_max;o_flags<=report_flags;o_done<=1;
   end
  end
 end
endmodule
