// Standalone, frame-based Kaiser(beta=4) real-input FFT.
// Default: 91667 valid 16-bit samples, zero padded to 131072 points.
// Input rate is a system-level property; the verified profile is 165 MHz / 144.
// No FIR, decimator, mixer, ADC driver, or UART is included or modified.
//
// Memory reduction: pack even/odd real samples into a half-length complex FFT,
// then reconstruct the nonnegative real-FFT spectrum in place. Window ROM holds
// exact differences of quantized symmetric coefficients (no interpolation).
//
// Output value / 2**INPUT_FRAC is FFT(window*x) / NFFT in ADC-code units.
// Output bins are natural order, including DC and Nyquist. Hold i_out_ready low
// to stall readout. o_out_* remain stable while stalled. A new frame can start
// after the last bin is accepted. No continuous-frame double buffering.
module kaiser4_rfft #(
    parameter integer LOGN = 17,
    parameter integer VALID_SAMPLES = 91667,
    parameter integer DATA_W = 20,
    parameter integer INPUT_FRAC = 3,
    parameter integer COEF_FRAC = 17,
    parameter integer DELTA_W = 3,
    parameter integer WINDOW_FIRST = 11597,
    parameter WINDOW_FILE = "window_delta.mem",
    parameter TWIDDLE_FILE = "cos_quarter.mem",
    parameter WINDOW_MIF = "window_delta.mif",
    parameter TWIDDLE_MIF = "cos_quarter.mif"
) (
    input  logic clk,
    input  logic rst,
    input  logic i_start,
    input  logic i_valid,
    input  logic signed [15:0] i_sample,
    output logic o_in_ready,
    output logic o_busy,
    input  logic i_out_ready,
    output logic o_out_valid,
    output logic [LOGN-1:0] o_out_bin,
    output logic signed [DATA_W-1:0] o_out_re,
    output logic signed [DATA_W-1:0] o_out_im,
    output logic o_out_sop,
    output logic o_out_eop,
    output logic o_done,
    output logic o_overflow
);
    localparam integer N = 1 << LOGN;
    localparam integer LOGM = LOGN-1;
    localparam integer M = N/2;
    localparam integer Q = N/4;
    localparam integer HALF_WINDOW = (VALID_SAMPLES+1)/2;
    localparam integer WINDOW_AW = (HALF_WINDOW>1) ? $clog2(HALF_WINDOW) : 1;
    localparam integer VALID_PAIRS = (VALID_SAMPLES+1)/2;
    localparam integer COEF_W = COEF_FRAC+1;
    localparam integer PROD_W = DATA_W+1+COEF_W+1;
    localparam integer WIN_PROD_W = 16+COEF_W+1;

    typedef enum logic [4:0] {
        IDLE, LOAD, W_WAIT, W_COEF, W_MUL, W_STORE, PAD,
        F_READ, F_LATCH, MUL, ROT_SUM, ROT_ROUND, CALC, STORE,
        P0_READ, P0_CALC, P0_STORE, P_READ, P_LATCH, P_SUM,
        MID_READ, MID_CALC, MID_STORE, OUT_READ, OUT_LATCH, OUT_HOLD
    } state_t;
    state_t state;

    logic [LOGM-1:0] a_addr,b_addr;
    logic a_we,b_we;
    logic signed [DATA_W-1:0] a_wr_re,a_wr_im,b_wr_re,b_wr_im;
    logic signed [DATA_W-1:0] a_rd_re,a_rd_im,b_rd_re,b_rd_im;
    fft_tdp_store #(.WIDTH(DATA_W),.ADDR_W(LOGM),.DEPTH(M)) ram_real
      (.clk(clk),.a_addr(a_addr),.b_addr(b_addr),.a_we(a_we),.b_we(b_we),
       .a_data(a_wr_re),.b_data(b_wr_re),.a_q(a_rd_re),.b_q(b_rd_re));
    fft_tdp_store #(.WIDTH(DATA_W),.ADDR_W(LOGM),.DEPTH(M)) ram_imag
      (.clk(clk),.a_addr(a_addr),.b_addr(b_addr),.a_we(a_we),.b_we(b_we),
       .a_data(a_wr_im),.b_data(b_wr_im),.a_q(a_rd_im),.b_q(b_rd_im));

    logic [LOGN-1:0] in_count,out_index;
    logic [LOGM-1:0] pad_pair,base_index,j_index,post_index;
    logic [LOGM:0] half_size,span;
    logic [$clog2(LOGN+1)-1:0] tw_shift;
    logic phase_post;
    logic signed [15:0] sample_hold;
    logic [LOGN-1:0] delta_addr;
    logic delta_subtract;
    logic [DELTA_W-1:0] delta_q;
    logic [COEF_W-1:0] window_accum,window_coef;
    logic signed [WIN_PROD_W-1:0] window_product;
    logic signed [DATA_W-1:0] even_hold,window_value;
    logic [LOGM-1:0] tw_phase;
    logic [LOGM:0] cos_addr,sin_addr;
    logic [COEF_W-1:0] cos_q,sin_q;
    logic negate_cos;
    logic signed [COEF_W:0] wr,wi;
    logic signed [DATA_W-1:0] ar,ai,br,bi;
    logic signed [DATA_W:0] sum_r,sum_i,mul_ar,mul_ai;
    logic signed [PROD_W-1:0] prod_rr,prod_ii,prod_ri,prod_ir;
    logic signed [PROD_W:0] rot_num_r,rot_num_i;
    logic signed [DATA_W+2:0] rot_r,rot_i;
    logic signed [DATA_W-1:0] write_ar,write_ai,write_br,write_bi,nyquist;
    logic signed [63:0] v0,v1,v2,v3;

    function automatic logic [LOGM-1:0] bit_reverse(input logic [LOGM-1:0] x);
        integer k;
        begin for(k=0;k<LOGM;k=k+1) bit_reverse[k]=x[LOGM-1-k]; end
    endfunction
    // Round to nearest, with exactly-half cases toward +infinity.
    function automatic signed [63:0] rshift(input signed [63:0] x,input integer s);
        begin
            if(s==0) rshift=x;
            else rshift=(x+(64'sd1 << (s-1))) >>> s;
        end
    endfunction
    function automatic logic fits(input signed [63:0] x);
        begin fits=(x >= -(64'sd1 << (DATA_W-1))) && (x <= ((64'sd1 << (DATA_W-1))-1)); end
    endfunction
    function automatic signed [DATA_W-1:0] sat(input signed [63:0] x);
        begin
            if(x > ((64'sd1 << (DATA_W-1))-1)) sat={1'b0,{(DATA_W-1){1'b1}}};
            else if(x < -(64'sd1 << (DATA_W-1))) sat={1'b1,{(DATA_W-1){1'b0}}};
            else sat=x[DATA_W-1:0];
        end
    endfunction

    assign o_in_ready=(state==LOAD);
    assign o_busy=(state!=IDLE);
    assign window_value=sat(rshift($signed(window_product),COEF_FRAC-INPUT_FRAC));
    always_comb begin
        tw_phase=phase_post ? post_index : (j_index << tw_shift);
        negate_cos=(tw_phase>Q);
        if(tw_phase<=Q) begin cos_addr=tw_phase; sin_addr=Q-tw_phase; end
        else begin cos_addr=M-tw_phase; sin_addr=tw_phase-Q; end
    end
    fft_tdp_store #(.WIDTH(DELTA_W),.ADDR_W(WINDOW_AW),.DEPTH(HALF_WINDOW),.INIT_MIF(WINDOW_MIF),.INIT_MEM(WINDOW_FILE)) window_rom
      (.clk(clk),.a_addr(delta_addr[WINDOW_AW-1:0]),.b_addr({WINDOW_AW{1'b0}}),.a_we(1'b0),.b_we(1'b0),
       .a_data({DELTA_W{1'b0}}),.b_data({DELTA_W{1'b0}}),.a_q(delta_q),.b_q());
    fft_tdp_store #(.WIDTH(COEF_W),.ADDR_W(LOGM),.DEPTH(Q+1),.INIT_MIF(TWIDDLE_MIF),.INIT_MEM(TWIDDLE_FILE)) twiddle_rom
      (.clk(clk),.a_addr(cos_addr[LOGM-1:0]),.b_addr(sin_addr[LOGM-1:0]),.a_we(1'b0),.b_we(1'b0),
       .a_data({COEF_W{1'b0}}),.b_data({COEF_W{1'b0}}),.a_q(cos_q),.b_q(sin_q));

    always_comb begin
        a_addr=phase_post ? post_index : (base_index+j_index);
        b_addr=phase_post ? (M-post_index) : (base_index+j_index+half_size);
        a_we=1'b0; b_we=1'b0;
        a_wr_re=write_ar; a_wr_im=write_ai;
        b_wr_re=write_br; b_wr_im=write_bi;
        case(state)
            W_STORE: begin
                a_addr=bit_reverse(in_count >> 1);
                if(in_count[0]) begin a_we=1'b1; a_wr_re=even_hold; a_wr_im=window_value; end
                else if(in_count==VALID_SAMPLES-1) begin a_we=1'b1; a_wr_re=window_value; a_wr_im='0; end
            end
            PAD: begin a_addr=bit_reverse(pad_pair); a_we=1'b1; a_wr_re='0; a_wr_im='0; end
            STORE: begin a_we=1'b1; b_we=1'b1; end
            P0_READ,P0_CALC: a_addr='0;
            P0_STORE: begin a_addr='0; a_we=1'b1; end
            MID_READ,MID_CALC: a_addr=Q;
            MID_STORE: begin a_addr=Q; a_we=1'b1; end
            OUT_READ,OUT_LATCH,OUT_HOLD: a_addr=out_index[LOGM-1:0];
            default: ;
        endcase
        if(rst) begin a_we=1'b0; b_we=1'b0; end
    end

    always_ff @(posedge clk) begin
        o_done<=1'b0;
        if(rst) begin
            state<=IDLE; o_out_valid<=1'b0; o_done<=1'b0; o_overflow<=1'b0;
            o_out_re<='0; o_out_im<='0; o_out_bin<='0; o_out_sop<=1'b0; o_out_eop<=1'b0;
            in_count<='0; out_index<='0; pad_pair<='0; base_index<='0; j_index<='0; post_index<='0;
            half_size<=1; span<=2; tw_shift<=LOGN-1; phase_post<=1'b0;
            window_accum<=WINDOW_FIRST; window_coef<=WINDOW_FIRST;
            sample_hold<='0; delta_addr<='0; delta_subtract<=1'b0; even_hold<='0;
            write_ar<='0; write_ai<='0; write_br<='0; write_bi<='0; nyquist<='0;
            ar<='0; ai<='0; br<='0; bi<='0; wr<='0; wi<='0; mul_ar<='0; mul_ai<='0;
            sum_r<='0; sum_i<='0; window_product<='0;
            prod_rr<='0; prod_ii<='0; prod_ri<='0; prod_ir<='0;
            rot_num_r<='0; rot_num_i<='0; rot_r<='0; rot_i<='0;
        end else begin
            case(state)
                IDLE: if(i_start) begin
                    in_count<='0; phase_post<=1'b0; window_accum<=WINDOW_FIRST;
                    o_overflow<=1'b0; o_out_valid<=1'b0; state<=LOAD;
                end
                LOAD: if(i_valid) begin
                    sample_hold<=i_sample;
                    if(in_count==0 || ((VALID_SAMPLES%2==0) && in_count==VALID_SAMPLES/2)) delta_addr<='0;
                    else if(in_count<HALF_WINDOW) delta_addr<=in_count;
                    else delta_addr<=VALID_SAMPLES-in_count;
                    delta_subtract<=(in_count>=HALF_WINDOW);
                    state<=W_WAIT;
                end
                W_WAIT: state<=W_COEF;
                W_COEF: begin
                    if(delta_subtract) begin window_coef<=window_accum-delta_q; window_accum<=window_accum-delta_q; end
                    else begin window_coef<=window_accum+delta_q; window_accum<=window_accum+delta_q; end
                    state<=W_MUL;
                end
                W_MUL: begin window_product<=sample_hold*$signed({1'b0,window_coef}); state<=W_STORE; end
                W_STORE: begin
                    if(!fits(rshift($signed(window_product),COEF_FRAC-INPUT_FRAC))) o_overflow<=1'b1;
                    if(!in_count[0]) even_hold<=window_value;
                    if(in_count==VALID_SAMPLES-1) begin
                        half_size<=1; span<=2; tw_shift<=LOGN-1; base_index<='0; j_index<='0;
                        if(VALID_PAIRS<M) begin pad_pair<=VALID_PAIRS; state<=PAD; end
                        else state<=F_READ;
                    end else begin in_count<=in_count+1'b1; state<=LOAD; end
                end
                PAD: begin
                    if(pad_pair==M-1) state<=F_READ;
                    else pad_pair<=pad_pair+1'b1;
                end
                F_READ: state<=F_LATCH;
                F_LATCH: begin
                    ar<=a_rd_re; ai<=a_rd_im;
                    mul_ar<={b_rd_re[DATA_W-1],b_rd_re}; mul_ai<={b_rd_im[DATA_W-1],b_rd_im};
                    wr<=negate_cos ? -$signed({1'b0,cos_q}) : $signed({1'b0,cos_q});
                    wi<=-$signed({1'b0,sin_q}); state<=MUL;
                end
                MUL: begin
                    prod_rr<=mul_ar*wr; prod_ii<=mul_ai*wi;
                    prod_ri<=mul_ar*wi; prod_ir<=mul_ai*wr;
                    state<=ROT_SUM;
                end
                ROT_SUM: begin
                    rot_num_r<={prod_rr[PROD_W-1],prod_rr}-{prod_ii[PROD_W-1],prod_ii};
                    rot_num_i<={prod_ri[PROD_W-1],prod_ri}+{prod_ir[PROD_W-1],prod_ir};
                    state<=ROT_ROUND;
                end
                ROT_ROUND: begin
                    rot_r<=rshift($signed(rot_num_r),COEF_FRAC); rot_i<=rshift($signed(rot_num_i),COEF_FRAC);
                    state<=CALC;
                end
                CALC: begin
                    if(!phase_post) begin
                        v0=rshift($signed(ar)+$signed(rot_r),1); v1=rshift($signed(ai)+$signed(rot_i),1);
                        v2=rshift($signed(ar)-$signed(rot_r),1); v3=rshift($signed(ai)-$signed(rot_i),1);
                    end else begin
                        // Z is scaled by 1/M. Division by 4 below includes the
                        // real-FFT reconstruction and the additional M/N = 1/2.
                        v0=rshift($signed(sum_r)+$signed(rot_i),2); v1=rshift($signed(sum_i)-$signed(rot_r),2);
                        v2=rshift($signed(sum_r)-$signed(rot_i),2); v3=rshift(-$signed(sum_i)-$signed(rot_r),2);
                    end
                    write_ar<=sat(v0); write_ai<=sat(v1); write_br<=sat(v2); write_bi<=sat(v3);
                    if(!fits(v0)||!fits(v1)||!fits(v2)||!fits(v3)) o_overflow<=1'b1;
                    state<=STORE;
                end
                STORE: begin
                    if(phase_post) begin
                        if(post_index==Q-1) state<=MID_READ;
                        else begin post_index<=post_index+1'b1; state<=P_READ; end
                    end else if(j_index==half_size-1) begin
                        j_index<='0;
                        if(base_index+span>=M) begin
                            base_index<='0;
                            if(span==M) begin phase_post<=1'b1; post_index<='0; state<=P0_READ; end
                            else begin half_size<=half_size<<1; span<=span<<1; tw_shift<=tw_shift-1'b1; state<=F_READ; end
                        end else begin base_index<=base_index+span; state<=F_READ; end
                    end else begin j_index<=j_index+1'b1; state<=F_READ; end
                end
                P0_READ: state<=P0_CALC;
                P0_CALC: begin
                    v0=rshift($signed(a_rd_re)+$signed(a_rd_im),1);
                    v1=rshift($signed(a_rd_re)-$signed(a_rd_im),1);
                    write_ar<=sat(v0); write_ai<='0; nyquist<=sat(v1);
                    if(!fits(v0)||!fits(v1)) o_overflow<=1'b1;
                    state<=P0_STORE;
                end
                P0_STORE: begin post_index<=1; state<=P_READ; end
                P_READ: state<=P_LATCH;
                P_LATCH: begin
                    ar<=a_rd_re; ai<=a_rd_im; br<=b_rd_re; bi<=b_rd_im;
                    wr<=negate_cos ? -$signed({1'b0,cos_q}) : $signed({1'b0,cos_q});
                    wi<=-$signed({1'b0,sin_q}); state<=P_SUM;
                end
                P_SUM: begin
                    sum_r<={ar[DATA_W-1],ar}+{br[DATA_W-1],br};
                    sum_i<={ai[DATA_W-1],ai}-{bi[DATA_W-1],bi};
                    mul_ar<={ar[DATA_W-1],ar}-{br[DATA_W-1],br};
                    mul_ai<={ai[DATA_W-1],ai}+{bi[DATA_W-1],bi};
                    state<=MUL;
                end
                MID_READ: state<=MID_CALC;
                MID_CALC: begin
                    write_ar<=sat(rshift($signed(a_rd_re),1));
                    write_ai<=sat(rshift(-$signed(a_rd_im),1));
                    state<=MID_STORE;
                end
                MID_STORE: begin out_index<='0; state<=OUT_READ; end
                OUT_READ: state<=OUT_LATCH;
                OUT_LATCH: begin
                    o_out_bin<=out_index;
                    o_out_re<=(out_index==M) ? nyquist : a_rd_re;
                    o_out_im<=(out_index==M) ? '0 : a_rd_im;
                    o_out_sop<=(out_index==0); o_out_eop<=(out_index==M);
                    o_out_valid<=1'b1; state<=OUT_HOLD;
                end
                OUT_HOLD: if(i_out_ready) begin
                    o_out_valid<=1'b0;
                    if(out_index==M) begin o_done<=1'b1; state<=IDLE; end
                    else begin out_index<=out_index+1'b1; state<=OUT_READ; end
                end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
