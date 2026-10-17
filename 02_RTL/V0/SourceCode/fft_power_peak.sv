// Exact unsigned power: signed Re^2 + signed Im^2, no truncation or sqrt.
// 20-bit Q3 complex inputs produce 41-bit Q6 power; divide by 64 for
// |FFT(window*x)/N|^2 in ADC-code^2 units. This is not calibrated watts/Hz.
// Natural-order frames are delimited by SOP/EOP. Search limits (inclusive)
// and threshold are latched on accepted SOP. Equal power selects lower bin.
// Zero or empty-band frames return found=0. Below-threshold frames retain
// the strongest bin/power for diagnostics but found=0. Threshold uses >=.
// One bin per three clocks; both streams support valid/ready backpressure.
module fft_power_peak #(
    parameter integer DATA_W=20,
    parameter integer BIN_W=17
) (
    input logic clk,rst,
    input logic i_valid,
    output logic o_ready,
    input logic signed [DATA_W-1:0] i_re,i_im,
    input logic [BIN_W-1:0] i_bin,
    input logic i_sop,i_eop,
    input logic [BIN_W-1:0] i_min_bin,i_max_bin,
    input logic [2*DATA_W:0] i_min_power,
    output logic o_power_valid,
    input logic i_power_ready,
    output logic [2*DATA_W:0] o_power,
    output logic [BIN_W-1:0] o_bin,
    output logic signed [DATA_W-1:0] o_re,o_im,
    output logic o_sop,o_eop,
    output logic o_peak_valid,
    input logic i_peak_ready,
    output logic [BIN_W-1:0] o_peak_bin,
    output logic [2*DATA_W:0] o_peak_power,
    output logic o_peak_found
);
    typedef enum logic [1:0] {ACCEPT,SUM,HOLD} state_t;
    state_t state;
    logic [2*DATA_W-1:0] square_re,square_im;
    logic [BIN_W-1:0] min_bin,max_bin,best_bin,next_bin;
    logic [2*DATA_W:0] threshold,best_power,next_power;
    logic seen,next_seen,eligible,better;
    assign o_ready=(state==ACCEPT)&&!o_peak_valid&&!rst;
    assign o_power_valid=(state==HOLD)&&!rst;
    always_comb begin
        eligible=(o_bin>=min_bin)&&(o_bin<=max_bin);
        better=eligible&&(!seen||(o_power>best_power)||((o_power==best_power)&&(o_bin<best_bin)));
        next_seen=seen||eligible;
        next_power=better ? o_power : best_power;
        next_bin=better ? o_bin : best_bin;
    end
    always_ff @(posedge clk) begin
        if(rst) begin
            state<=ACCEPT; square_re<='0;square_im<='0;
            o_re<='0;o_im<='0;o_bin<='0;o_power<='0;o_sop<=0;o_eop<=0;
            min_bin<='0;max_bin<='0;threshold<='0;
            best_bin<='0;best_power<='0;seen<=0;
            o_peak_valid<=0;o_peak_bin<='0;o_peak_power<='0;o_peak_found<=0;
        end else begin
            if(o_peak_valid&&i_peak_ready) o_peak_valid<=0;
            case(state)
                ACCEPT: if(i_valid&&o_ready) begin
                    square_re<=$signed(i_re)*$signed(i_re);
                    square_im<=$signed(i_im)*$signed(i_im);
                    o_re<=i_re;o_im<=i_im;o_bin<=i_bin;o_sop<=i_sop;o_eop<=i_eop;
                    if(i_sop) begin
                        min_bin<=i_min_bin;max_bin<=i_max_bin;threshold<=i_min_power;
                        best_bin<='0;best_power<='0;seen<=0;
                    end
                    state<=SUM;
                end
                SUM: begin
                    o_power<={1'b0,square_re}+{1'b0,square_im};
                    state<=HOLD;
                end
                HOLD: if(i_power_ready) begin
                    seen<=next_seen;best_power<=next_power;best_bin<=next_bin;
                    if(o_eop) begin
                        o_peak_bin<=next_bin;o_peak_power<=next_power;
                        o_peak_found<=next_seen&&(next_power!=0)&&(next_power>=threshold);
                        o_peak_valid<=1;
                    end
                    state<=ACCEPT;
                end
                default: state<=ACCEPT;
            endcase
        end
    end
endmodule
