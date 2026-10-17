// Standalone 50 MHz wrapper. Original Chirp/ADC/UART and FFT core unchanged.
// FFT power stream includes all nonnegative bins, even those outside the
// peak-search band. Configuration must be stable at accepted i_start.
// Busy covers capture, FFT, power readout AND the pending peak result.
// A new frame may start after the peak result is acknowledged.
module kaiser4_fft_peak #(
    parameter integer LOGN=17,
    parameter integer VALID_SAMPLES=91667,
    parameter integer DELTA_W=3,
    parameter integer WINDOW_FIRST=11597
) (
    input logic clk,rst,i_start,i_valid,
    input logic signed [15:0] i_sample,
    output logic o_in_ready,o_busy,o_done,o_overflow,
    input logic [LOGN-1:0] i_min_bin,i_max_bin,
    input logic [40:0] i_min_power,
    output logic o_power_valid,
    input logic i_power_ready,
    output logic [LOGN-1:0] o_bin,
    output logic signed [19:0] o_re,o_im,
    output logic [40:0] o_power,
    output logic o_sop,o_eop,o_peak_valid,
    input logic i_peak_ready,
    output logic [LOGN-1:0] o_peak_bin,
    output logic [40:0] o_peak_power,
    output logic o_peak_found
);
    logic fft_valid,fft_ready,fft_sop,fft_eop,fft_in_ready;
    logic [LOGN-1:0] fft_bin,search_min,search_max;
    logic [40:0] threshold;
    logic signed [19:0] fft_re,fft_im;
    wire start_accepted=i_start&&!o_busy&&!rst;
    assign o_in_ready=fft_in_ready&&o_busy&&!rst;
    always_ff @(posedge clk) begin
        o_done<=0;
        if(rst) begin
            o_busy<=0;search_min<='0;search_max<='0;threshold<='0;
        end else begin
            if(start_accepted) begin
                o_busy<=1;search_min<=i_min_bin;search_max<=i_max_bin;threshold<=i_min_power;
            end
            if(o_peak_valid&&i_peak_ready) begin o_busy<=0;o_done<=1;end
        end
    end
    kaiser4_rfft #(.LOGN(LOGN),.VALID_SAMPLES(VALID_SAMPLES),.DELTA_W(DELTA_W),.WINDOW_FIRST(WINDOW_FIRST)) fft (
        .clk(clk),.rst(rst),.i_start(start_accepted),.i_valid(i_valid&&o_busy),.i_sample(i_sample),
        .o_in_ready(fft_in_ready),.o_busy(),.i_out_ready(fft_ready),.o_out_valid(fft_valid),
        .o_out_bin(fft_bin),.o_out_re(fft_re),.o_out_im(fft_im),.o_out_sop(fft_sop),.o_out_eop(fft_eop),
        .o_done(),.o_overflow(o_overflow));
    fft_power_peak #(.BIN_W(LOGN)) detector (
        .clk(clk),.rst(rst),.i_valid(fft_valid),.o_ready(fft_ready),.i_re(fft_re),.i_im(fft_im),
        .i_bin(fft_bin),.i_sop(fft_sop),.i_eop(fft_eop),.i_min_bin(search_min),.i_max_bin(search_max),.i_min_power(threshold),
        .o_power_valid(o_power_valid),.i_power_ready(i_power_ready),.o_power(o_power),.o_bin(o_bin),
        .o_re(o_re),.o_im(o_im),.o_sop(o_sop),.o_eop(o_eop),.o_peak_valid(o_peak_valid),.i_peak_ready(i_peak_ready),
        .o_peak_bin(o_peak_bin),.o_peak_power(o_peak_power),.o_peak_found(o_peak_found));
endmodule
