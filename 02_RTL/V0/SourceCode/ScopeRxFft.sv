`include "FftSettings.svh"
module ScopeRxFft #(
 parameter integer SAMPLES=2048,SAMPLE_TICKS=3072,BOOT_TICKS=2500000,REPEAT_TICKS=12500000,
 parameter integer CAP_TIMEOUT_TICKS=13750000
)(input logic adc_clk,fft_clk,adc_rst,fft_rst,adc_ready,adc_valid,adc_clipped,
 input logic signed [15:0] adc_sample, output wire uart_tx,
 output logic activity,heartbeat);
 // A toggle requests capture. The frame and its statistics stay immutable
 // from done until the next request, after FFT and UART have finished.
 logic request_toggle,done_toggle,request_seen;
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] request_sync,done_sync,adc_ready_sync;
 logic cap_active;logic [31:0] cap_count,cap_span,tick,first_tick,last_tick,timeout_count;
 logic signed [15:0] cap_min,cap_max;
 logic signed [31:0] cap_sum;
 logic [7:0] cap_flags;
 wire ram_we=cap_active&&adc_valid&&(cap_count<SAMPLES);
 logic [10:0] rd_addr;wire [15:0] ram_q;
 ScopeFrameRam frame(.wr_clk(adc_clk),.rd_clk(fft_clk),.we(ram_we),
 .wr_addr(cap_count[10:0]),.rd_addr(rd_addr),.data(adc_sample),.q(ram_q));
 always_ff @(posedge adc_clk)begin
  if(adc_rst)begin
   request_sync<=0;request_seen<=0;done_toggle<=0;cap_active<=0;
   cap_count<=0;cap_span<=0;cap_flags<=0;cap_min<=16'sh7fff;cap_max<=16'sh8000;cap_sum<=0;
   tick<=0;first_tick<=0;last_tick<=0;timeout_count<=0;
  end else begin
   tick<=tick+1'b1;request_sync<={request_sync[0],request_toggle};
   if(!cap_active&&request_sync[1]!=request_seen)begin
    request_seen<=request_sync[1];cap_active<=1;cap_count<=0;cap_span<=0;
    cap_min<=16'sh7fff;cap_max<=16'sh8000;cap_flags<=0;timeout_count<=0;cap_sum<=0;
   end else if(cap_active)begin
    timeout_count<=timeout_count+1'b1;
    if(adc_valid)begin
     cap_sum<=cap_sum+$signed(adc_sample);
     if(cap_count==0)first_tick<=tick;
     else if(tick-last_tick!=SAMPLE_TICKS)cap_flags[1]<=1;
     last_tick<=tick;
     if(adc_sample<cap_min)cap_min<=adc_sample;
     if(adc_sample>cap_max)cap_max<=adc_sample;
     if(adc_clipped||adc_sample==32767||adc_sample==-32768)cap_flags[2]<=1;
     cap_count<=cap_count+1'b1;
     if(cap_count==SAMPLES-1)begin cap_active<=0;cap_span<=tick-first_tick;done_toggle<=~done_toggle;end
    end
    if(timeout_count==CAP_TIMEOUT_TICKS-1&&!(adc_valid&&cap_count==SAMPLES-1))begin
     cap_active<=0;cap_flags[0]<=1;cap_span<=cap_count==0 ? 32'd0 : last_tick-first_tick;done_toggle<=~done_toggle;
    end
   end
  end
 end

 typedef enum logic[3:0] {BOOT,WAIT_READY,CAPTURE,META,CHECKMETA,MEAN_DIV,FSTART,RADDR,RWAIT,FEED,FWAIT,REPORT,UART_WAIT,PAUSE} state_t;
 state_t state;
 logic [31:0] timer,sequence_number,report_count,report_span;
 logic signed [15:0] report_min,report_max;
 logic signed [31:0] report_sum;
 logic signed [15:0] dc_mean;
 logic [31:0] div_work,div_rem,div_quot;
 logic [5:0] div_steps;
 logic div_negative;
 wire [31:0] div_trial={div_rem[30:0],div_work[31]};
 wire [31:0] div_next={div_quot[30:0],(div_trial>=SAMPLES)};
 wire signed [16:0] centered=$signed({ram_q[15],ram_q})-$signed({dc_mean[15],dc_mean});
 wire centered_clip=(centered>17'sd32767)||(centered< -17'sd32768);
 wire signed [15:0] fft_sample=centered>17'sd32767 ? 16'sh7fff : centered< -17'sd32768 ? 16'sh8000 : centered[15:0];
 logic [7:0] report_flags;
 logic [10:0] sample_index;logic [14:0] report_bin;
 logic [40:0] report_power;
 logic done_seen;
 wire fft_start=(state==FSTART),fft_input_valid=(state==FEED);
 wire fft_input_ready,fft_busy,fft_valid,fft_ready,fft_sop,fft_eop,fft_done,fft_overflow;
 wire [10:0] fft_bin;wire [14:0] peak_bin,power_bin;
 wire signed [19:0] fft_re,fft_im,power_re,power_im;
 wire [40:0] power_value,peak_power;
 wire power_valid,power_sop,power_eop,peak_valid,peak_found;
 wire uart_busy,uart_done;
 kaiser4_rfft #(.LOGN(11),.VALID_SAMPLES(SAMPLES),.DELTA_W(8),.WINDOW_FIRST(11597),
 .WINDOW_FILE("scopelf_window_delta.mem"),.TWIDDLE_FILE("scopelf_cos_quarter.mem"),
 .WINDOW_MIF("scopelf_window_delta.mif"),.TWIDDLE_MIF("scopelf_cos_quarter.mif")) fft(
 .clk(fft_clk),.rst(fft_rst),.i_start(fft_start),.i_valid(fft_input_valid),.i_sample(fft_sample),
 .o_in_ready(fft_input_ready),.o_busy(fft_busy),.i_out_ready(fft_ready),.o_out_valid(fft_valid),
 .o_out_bin(fft_bin),.o_out_re(fft_re),.o_out_im(fft_im),.o_out_sop(fft_sop),.o_out_eop(fft_eop),
 .o_done(fft_done),.o_overflow(fft_overflow));
 // Guarded search bins 10..25 (43.71..109.28 Hz), allowing edge tones 50 and 100 Hz.
 // Accepted input test range is 50..100 Hz. Frequency uses Fs/128, not raw ADC Fs.
 // Exact integer frame mean is removed before the window to suppress ADC DC.
 fft_power_peak #(.BIN_W(15)) peak(.clk(fft_clk),.rst(fft_rst),.i_valid(fft_valid),.o_ready(fft_ready),
 .i_re(fft_re),.i_im(fft_im),.i_bin({4'b0,fft_bin}),.i_sop(fft_sop),.i_eop(fft_eop),
 .i_min_bin(`FFT_SEARCH_MIN_BIN),.i_max_bin(`FFT_SEARCH_MAX_BIN),.i_min_power(41'd6400),
 .o_power_valid(power_valid),.i_power_ready(1'b1),.o_power(power_value),.o_bin(power_bin),
 .o_re(power_re),.o_im(power_im),.o_sop(power_sop),.o_eop(power_eop),
 .o_peak_valid(peak_valid),.i_peak_ready(1'b1),.o_peak_bin(peak_bin),.o_peak_power(peak_power),.o_peak_found(peak_found));
 ScopeUartReport report(.clk(fft_clk),.rst(fft_rst),.i_start(state==REPORT),
 .i_seq(sequence_number),.i_count(report_count),.i_span(report_span),.i_bin(report_bin),
 .i_power(report_power),.i_min(report_min),.i_max(report_max),.i_flags(report_flags),
 .tx(uart_tx),.busy(uart_busy),.done(uart_done));
 assign activity=(state>=CAPTURE&&state<=FWAIT);
 always_ff @(posedge fft_clk)begin
  if(fft_rst)begin
   done_sync<=0;adc_ready_sync<=0;state<=BOOT;timer<=0;request_toggle<=0;
   sequence_number<=0;report_count<=0;report_span<=0;report_min<=0;report_max<=0;
   report_flags<=0;report_bin<=0;report_power<=0;done_seen<=0;sample_index<=0;rd_addr<=0;heartbeat<=0;
   report_sum<=0;dc_mean<=0;div_work<=0;div_rem<=0;div_quot<=0;div_steps<=0;div_negative<=0;
  end else begin
   done_sync<={done_sync[0],done_toggle};adc_ready_sync<={adc_ready_sync[0],adc_ready};
   case(state)
    BOOT:if(timer==BOOT_TICKS-1)begin timer<=0;state<=WAIT_READY;end else timer<=timer+1'b1;
    WAIT_READY:if(adc_ready_sync[1])begin
      request_toggle<=~request_toggle;done_seen<=done_sync[1];sequence_number<=sequence_number+1'b1;
      state<=CAPTURE;
     end
    CAPTURE:if(done_sync[1]!=done_seen)begin done_seen<=done_sync[1];state<=META;end
    META:begin
      report_count<=cap_count;report_span<=cap_span;report_min<=cap_min;report_max<=cap_max;
      report_sum<=cap_sum;
      report_flags<=cap_flags;report_bin<=0;report_power<=0;sample_index<=0;rd_addr<=0;
      state<=CHECKMETA;
     end
    CHECKMETA:if(report_flags[0]||report_count!=SAMPLES)state<=REPORT;
     else begin
      div_work<=report_sum[31] ? -report_sum : report_sum;div_negative<=report_sum[31];
      div_rem<=0;div_quot<=0;div_steps<=0;state<=MEAN_DIV;
     end
    MEAN_DIV:begin
      div_work<={div_work[30:0],1'b0};div_quot<=div_next;
      div_rem<=div_trial>=SAMPLES ? div_trial-SAMPLES : div_trial;
      if(div_steps==31)begin
       dc_mean<=div_negative ? -$signed({1'b0,div_next[15:0]}) : $signed({1'b0,div_next[15:0]});state<=FSTART;
      end else div_steps<=div_steps+1'b1;
     end
    FSTART:state<=RADDR;
    RADDR:begin rd_addr<=sample_index;state<=RWAIT;end
    RWAIT:state<=FEED;
    FEED:if(fft_input_ready)begin
      if(centered_clip)report_flags[5]<=1;
      if(sample_index==SAMPLES-1)state<=FWAIT;
      else begin sample_index<=sample_index+1'b1;state<=RADDR;end
     end
    FWAIT:if(peak_valid)begin
      report_bin<=peak_bin;report_power<=peak_power;
      report_flags[3]<=fft_overflow;report_flags[4]<=!peak_found;state<=REPORT;
     end
    REPORT:state<=UART_WAIT;
    UART_WAIT:if(uart_done)begin timer<=0;heartbeat<=~heartbeat;state<=PAUSE;end
    PAUSE:if(timer==REPEAT_TICKS-1)begin timer<=0;state<=WAIT_READY;end else timer<=timer+1'b1;
    default:state<=BOOT;
   endcase
  end
 end
endmodule
