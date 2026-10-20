// Grouped source. Edit the units below; retain BEGIN_SOURCE/END_SOURCE markers.

// BEGIN_SOURCE: fft_tdp_store.sv
// One-clock, two-port memory contract. The FFT never consumes read-during-write
// results. Quartus uses explicit M10K primitives; portable RTL simulation uses
// an equivalent array model. Enable FFT_USE_INTEL_RAM in Questa to verify with
// the actual Intel altsyncram model as well.
module fft_tdp_store #(
    parameter integer WIDTH=20,
    parameter integer ADDR_W=16,
    parameter integer DEPTH=65536,
    parameter INIT_MIF="UNUSED",
    parameter INIT_MEM="UNUSED"
) (
    input logic clk,
    input logic [ADDR_W-1:0] a_addr,b_addr,
    input logic a_we,b_we,
    input logic [WIDTH-1:0] a_data,b_data,
    output logic [WIDTH-1:0] a_q,b_q
);
`ifdef FFT_USE_INTEL_RAM
    altsyncram #(
        .intended_device_family("Cyclone V"),
        .operation_mode("BIDIR_DUAL_PORT"),
        .width_a(WIDTH),.widthad_a(ADDR_W),.numwords_a(DEPTH),
        .width_b(WIDTH),.widthad_b(ADDR_W),.numwords_b(DEPTH),
        .width_byteena_a(1),.width_byteena_b(1),
        .outdata_reg_a("UNREGISTERED"),.outdata_reg_b("UNREGISTERED"),
        .address_reg_b("CLOCK0"),.indata_reg_b("CLOCK0"),
        .wrcontrol_wraddress_reg_b("CLOCK0"),
        .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),
        .clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
        .read_during_write_mode_port_a("NEW_DATA_NO_NBE_READ"),
        .read_during_write_mode_port_b("NEW_DATA_NO_NBE_READ"),
        .read_during_write_mode_mixed_ports("DONT_CARE"),
        .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),
        // Force wider physical words: the default 8K x 1 layout wastes the
        // parity-capable bits of M10K when storing 20-bit FFT samples.
        .maximum_depth((WIDTH>=10) ? 1024 : 2048),
        .init_file(INIT_MIF),.lpm_type("altsyncram")
    ) storage (
        .clock0(clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),
        .aclr0(1'b0),.aclr1(1'b0),.addressstall_a(1'b0),.addressstall_b(1'b0),
        .address_a(a_addr),.address_b(b_addr),.wren_a(a_we),.wren_b(b_we),
        .rden_a(1'b1),.rden_b(1'b1),.data_a(a_data),.data_b(b_data),
        .byteena_a(1'b1),.byteena_b(1'b1),.q_a(a_q),.q_b(b_q),.eccstatus()
    );
`else
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    initial if(INIT_MEM!="UNUSED") $readmemb(INIT_MEM,memory);
    always_ff @(posedge clk) begin
        if(a_we) memory[a_addr]<=a_data;
        if(b_we) memory[b_addr]<=b_data;
        a_q<=memory[a_addr]; b_q<=memory[b_addr];
    end
`endif
endmodule

// END_SOURCE: fft_tdp_store.sv

// BEGIN_SOURCE: kaiser4_rfft.sv
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

// END_SOURCE: kaiser4_rfft.sv

// BEGIN_SOURCE: fft_power_peak.sv
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

// END_SOURCE: fft_power_peak.sv

// BEGIN_SOURCE: main_peak_interpolator.sv
// Three-point log-power parabola, computed entirely in the FFT clock domain.
// log(power)=2*log(amplitude), so the ratio equals the MATLAB log-amplitude
// formula. Output is signed Q16 bin offset, clamped to [-0.5,+0.5].
// Status: 0 valid; 1 invalid frame; 2 missing/mismatched neighbors;
//         3 zero power; 4 not a local maximum; 5 non-concave logarithms.
// A reused 25x25 multiplier computes log2 to 16 fraction bits. A restoring
// divider avoids a large combinational divide. No logarithm IP/ROM required.
module main_peak_interpolator #(
 parameter integer MIN_BIN=6,MAX_BIN=114
)(input logic clk,rst,
 input logic i_valid,i_sop,input logic [14:0] i_bin,input logic [40:0] i_power,
 input logic i_peak_valid,i_enable,input logic [14:0] i_peak_bin,input logic [40:0] i_peak_power,
 output logic o_done,output logic signed [31:0] o_delta_q16,output logic [7:0] o_status);
 logic seen,prev_valid,left_valid,right_valid;
 logic [14:0] best_bin,prev_bin;
 logic [40:0] best_power,prev_power,left_power,right_power;
 wire eligible=(i_bin>=MIN_BIN)&&(i_bin<=MAX_BIN);
 wire better=eligible&&(!seen||i_power>best_power||(i_power==best_power&&i_bin<best_bin));
 always_ff @(posedge clk)begin
  if(rst)begin
   seen<=0;prev_valid<=0;left_valid<=0;right_valid<=0;
   best_bin<=0;prev_bin<=0;best_power<=0;prev_power<=0;left_power<=0;right_power<=0;
  end else if(i_valid)begin
   prev_bin<=i_bin;prev_power<=i_power;prev_valid<=1;
   if(i_sop)begin
    seen<=eligible;best_bin<=i_bin;best_power<=i_power;
    left_valid<=0;right_valid<=0;left_power<=0;right_power<=0;
   end else if(better)begin
    seen<=1;best_bin<=i_bin;best_power<=i_power;left_power<=prev_power;
    left_valid<=prev_valid&&(i_bin!=0)&&(prev_bin==i_bin-1'b1);
    right_valid<=0;right_power<=0;
   end else if(seen&&(i_bin==best_bin+1'b1))begin right_power<=i_power;right_valid<=1;end
  end
 end
 typedef enum logic[3:0] {IDLE,NORM,MUL,LOG_BIT,CALC,DIV_INIT,DIVIDE,FINISH} state_t;
 state_t state;
 logic [40:0] powers[0:2];logic [21:0] logs[0:2];
 logic [1:0] side;logic [5:0] exponent,msb;logic [4:0] log_step;
 logic [24:0] x,normalized;logic [49:0] square;logic [15:0] fraction;
 logic signed [22:0] numerator;logic signed [23:0] denominator;
 logic [37:0] dividend,quotient;logic [24:0] remainder;
 logic [23:0] divisor;logic [5:0] div_step;logic negative;
 wire [15:0] fraction_next={fraction[14:0],square[49]};
 wire [24:0] trial={remainder[23:0],dividend[37]};
 wire [37:0] quotient_next={quotient[36:0],trial>={1'b0,divisor}};
 wire [22:0] abs_num=numerator[22] ? -numerator : numerator;
 always_comb begin
  msb=0;
  for(integer j=0;j<41;j=j+1)if(powers[side][j])msb=6'(j);
  normalized=msb>24 ? 25'(powers[side]>>(msb-24)) : 25'(powers[side]<<(24-msb));
 end
 always_ff @(posedge clk)begin
  if(rst)begin
   state<=IDLE;o_done<=0;o_delta_q16<=0;o_status<=1;side<=0;exponent<=0;log_step<=0;
   x<=0;square<=0;fraction<=0;numerator<=0;denominator<=0;
   dividend<=0;quotient<=0;remainder<=0;divisor<=0;div_step<=0;negative<=0;
   for(integer j=0;j<3;j=j+1)begin powers[j]<=0;logs[j]<=0;end
  end else begin
   o_done<=0;
   case(state)
    IDLE:if(i_peak_valid)begin
     o_delta_q16<=0;o_status<=0;
     powers[0]<=left_power;powers[1]<=best_power;powers[2]<=right_power;side<=0;
     if(!i_enable)begin o_status<=1;state<=FINISH;end
     else if(!seen||!left_valid||!right_valid||best_bin!=i_peak_bin||best_power!=i_peak_power)
      begin o_status<=2;state<=FINISH;end
     else if(left_power==0||best_power==0||right_power==0)begin o_status<=3;state<=FINISH;end
     else if(best_power<left_power||best_power<right_power)begin o_status<=4;state<=FINISH;end
     else state<=NORM;
    end
    NORM:begin x<=normalized;exponent<=msb;fraction<=0;log_step<=0;state<=MUL;end
    MUL:begin square<=x*x;state<=LOG_BIT;end
    LOG_BIT:begin
     x<=square[49] ? square[49:25] : square[48:24];fraction<=fraction_next;
     if(log_step==15)begin
      logs[side]<={exponent,fraction_next};
      if(side==2)state<=CALC;else begin side<=side+1'b1;state<=NORM;end
     end else begin log_step<=log_step+1'b1;state<=MUL;end
    end
    CALC:begin
     numerator<=$signed({1'b0,logs[0]})-$signed({1'b0,logs[2]});
     denominator<=$signed({2'b0,logs[0]})-($signed({2'b0,logs[1]})<<<1)+$signed({2'b0,logs[2]});
     state<=DIV_INIT;
    end
    DIV_INIT:begin
     if(denominator>=0)begin o_status<=5;state<=FINISH;end
     else begin
      divisor<=-denominator;dividend<={abs_num,15'b0};negative<=!numerator[22];
      remainder<=0;quotient<=0;div_step<=0;state<=DIVIDE;
     end
    end
    DIVIDE:begin
     dividend<={dividend[36:0],1'b0};quotient<=quotient_next;
     remainder<=trial>={1'b0,divisor} ? trial-{1'b0,divisor} : trial;
     if(div_step==37)begin
      if(quotient_next>38'd32768)o_delta_q16<=negative ? -32'sd32768 : 32'sd32768;
      else o_delta_q16<=negative ? -$signed({16'b0,quotient_next[15:0]}) : $signed({16'b0,quotient_next[15:0]});
      state<=FINISH;
     end else div_step<=div_step+1'b1;
    end
    FINISH:begin o_done<=1;state<=IDLE;end
    default:state<=IDLE;
   endcase
  end
 end
endmodule

// END_SOURCE: main_peak_interpolator.sv

// BEGIN_SOURCE: MainFftProcessor.sv
// Triggered FFT side branch. Full-rate ADC data are independent of raw-packet thinning.
// Frame RAM and bundled metadata remain immutable until the next main acquisition.
module MainFftProcessor #(
 parameter integer LOGN=10,VALID_SAMPLES=672,SAMPLE_TICKS=4608,DELTA_W=9,MIN_BIN=1,MAX_BIN=14
)(input logic sys_clk,fft_clk,sys_rst,fft_rst,i_start,i_capture_active,i_raw_valid,
 input logic signed [15:0] i_raw_sample,
 output logic o_done,output logic [31:0] o_seq,o_count,o_span,
 output logic [14:0] o_bin,output logic [40:0] o_power,
 output logic [15:0] o_min,o_max,output logic [7:0] o_flags,
 output logic signed [31:0] o_delta_q16,output logic [7:0] o_interp_status);
 logic start_last;wire start_pulse=i_start&&!start_last;
 wire cv,cr,cc;wire signed [15:0] cs;
 MainCicDecimator filter(.clk(sys_clk),.rst(sys_rst||start_pulse),
 .i_valid(i_raw_valid&&i_capture_active),.i_sample(i_raw_sample),.o_valid(cv),.o_ready(cr),.o_clipped(cc),.o_sample(cs));
 logic cap_active,saw_window,done_toggle;
 logic [LOGN:0] cap_count; // count includes the full capacity
 logic [31:0] cap_span,tick,first_tick,last_tick,cap_seq;
 logic signed [31:0] cap_sum;logic signed [15:0] cap_min,cap_max;logic [7:0] cap_flags;
 wire ram_we=cap_active&&i_capture_active&&cv&&cr&&(cap_count<VALID_SAMPLES);
 logic [LOGN-1:0] rd_addr;wire [15:0] ram_q;
 MainFrameRam #(.ADDR_W(LOGN)) frame(.wr_clk(sys_clk),.rd_clk(fft_clk),.we(ram_we),.wr_addr(cap_count[LOGN-1:0]),.rd_addr(rd_addr),.data(cs),.q(ram_q));
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
 typedef enum logic[3:0] {WAIT_FRAME,META,CHECK,MEAN_DIV,FSTART,RADDR,RWAIT,FEED,FWAIT,IWAIT,REPORT} state_t;
 state_t state;
 logic [31:0] report_seq,report_count,report_span;
 logic signed [31:0] report_sum;logic signed [15:0] report_min,report_max,dc_mean;
 logic [7:0] report_flags;logic [14:0] report_bin;logic [40:0] report_power;
 logic signed [31:0] report_delta;logic [7:0] report_interp_status;
 wire interp_done;wire signed [31:0] interp_delta;wire [7:0] interp_status;
 logic [31:0] div_work,div_rem,div_quot;logic [5:0] div_steps;logic div_negative;
 wire [31:0] div_trial={div_rem[30:0],div_work[31]};
 wire [31:0] div_next={div_quot[30:0],(div_trial>=VALID_SAMPLES)};
 wire signed [16:0] centered=$signed({ram_q[15],ram_q})-$signed({dc_mean[15],dc_mean});
 wire centered_clip=(centered>17'sd32767)||(centered< -17'sd32768);
 wire signed [15:0] fft_sample=centered>17'sd32767 ? 16'sh7fff : centered< -17'sd32768 ? 16'sh8000 : centered[15:0];
 logic [LOGN-1:0] sample_index;
 wire fft_input_ready,fft_busy,fft_valid,fft_ready,fft_sop,fft_eop,fft_done,fft_overflow;
 wire [LOGN-1:0] fft_bin;wire signed [19:0] fft_re,fft_im;
 wire [14:0] peak_bin,power_bin;wire [40:0] peak_power,power_value;
 wire power_valid,peak_valid,peak_found;wire signed [19:0] power_re,power_im;
 kaiser4_rfft #(.LOGN(LOGN),.VALID_SAMPLES(VALID_SAMPLES),.DELTA_W(DELTA_W),.WINDOW_FIRST(11597),
 .WINDOW_FILE("main_window_delta.mem"),.TWIDDLE_FILE("main_cos_quarter.mem"),
 .WINDOW_MIF("main_window_delta.mif"),.TWIDDLE_MIF("main_cos_quarter.mif")) fft(
 .clk(fft_clk),.rst(fft_rst),.i_start(state==FSTART),.i_valid(state==FEED),.i_sample(fft_sample),
 .o_in_ready(fft_input_ready),.o_busy(fft_busy),.i_out_ready(fft_ready),.o_out_valid(fft_valid),
 .o_out_bin(fft_bin),.o_out_re(fft_re),.o_out_im(fft_im),.o_out_sop(fft_sop),.o_out_eop(fft_eop),.o_done(fft_done),.o_overflow(fft_overflow));
 fft_power_peak #(.BIN_W(15)) peak(.clk(fft_clk),.rst(fft_rst),.i_valid(fft_valid),.o_ready(fft_ready),
 .i_re(fft_re),.i_im(fft_im),.i_bin(15'(fft_bin)),.i_sop(fft_sop),.i_eop(fft_eop),
 .i_min_bin(15'(MIN_BIN)),.i_max_bin(15'(MAX_BIN)),.i_min_power(41'd6400),
 .o_power_valid(power_valid),.i_power_ready(1'b1),.o_power(power_value),.o_bin(power_bin),.o_re(power_re),.o_im(power_im),.o_sop(),.o_eop(),
 .o_peak_valid(peak_valid),.i_peak_ready(1'b1),.o_peak_bin(peak_bin),.o_peak_power(peak_power),.o_peak_found(peak_found));
 main_peak_interpolator #(.MIN_BIN(MIN_BIN),.MAX_BIN(MAX_BIN)) interpolate(
 .clk(fft_clk),.rst(fft_rst),.i_valid(power_valid),.i_sop(power_bin==0),.i_bin(power_bin),.i_power(power_value),
 .i_peak_valid(peak_valid),.i_enable(peak_found&&(report_flags==0)&&!fft_overflow),.i_peak_bin(peak_bin),.i_peak_power(peak_power),
 .o_done(interp_done),.o_delta_q16(interp_delta),.o_status(interp_status));
 always_ff @(posedge fft_clk)begin
  if(fft_rst)begin
   done_sync<=0;done_seen<=0;result_toggle<=0;state<=WAIT_FRAME;report_seq<=0;report_count<=0;report_span<=0;
   report_sum<=0;report_min<=0;report_max<=0;dc_mean<=0;report_flags<=0;report_bin<=0;report_power<=0;report_delta<=0;report_interp_status<=1;
   div_work<=0;div_rem<=0;div_quot<=0;div_steps<=0;div_negative<=0;sample_index<=0;rd_addr<=0;
  end else begin
   done_sync<={done_sync[0],done_toggle};
   case(state)
    WAIT_FRAME:if(done_sync[1]!=done_seen)begin done_seen<=done_sync[1];state<=META;end
    META:begin
     report_seq<=cap_seq;report_count<=cap_count;report_span<=cap_span;report_sum<=cap_sum;
     report_min<=cap_min;report_max<=cap_max;report_flags<=cap_flags;report_bin<=0;report_power<=0;report_delta<=0;report_interp_status<=1;sample_index<=0;rd_addr<=0;state<=CHECK;
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
    FWAIT:if(peak_valid)begin report_bin<=peak_bin;report_power<=peak_power;report_flags[3]<=fft_overflow;report_flags[4]<=!peak_found;state<=IWAIT;end
    IWAIT:if(interp_done)begin report_delta<=interp_delta;report_interp_status<=interp_status;state<=REPORT;end
    REPORT:begin result_toggle<=~result_toggle;state<=WAIT_FRAME;end
    default:state<=WAIT_FRAME;
   endcase
  end
 end
 (* altera_attribute="-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) logic [1:0] result_sync;
 logic result_seen,result_pending;
 always_ff @(posedge sys_clk)begin
  if(sys_rst)begin
   result_sync<=0;result_seen<=0;result_pending<=0;o_done<=0;o_seq<=0;o_count<=0;o_span<=0;o_bin<=0;o_power<=0;o_min<=0;o_max<=0;o_flags<=0;o_delta_q16<=0;o_interp_status<=1;
  end else begin
   result_sync<={result_sync[0],result_toggle};
   if(start_pulse)o_done<=0;
   if(result_sync[1]!=result_seen)begin result_seen<=result_sync[1];result_pending<=1;end
   if(result_pending)begin
    result_pending<=0;o_seq<=report_seq;o_count<=report_count;o_span<=report_span;o_bin<=report_bin;
    o_power<=report_power;o_min<=report_min;o_max<=report_max;o_flags<=report_flags;o_delta_q16<=report_delta;o_interp_status<=report_interp_status;o_done<=1;
   end
  end
 end
endmodule

// END_SOURCE: MainFftProcessor.sv

// BEGIN_SOURCE: ScopeRxFft.sv
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

// END_SOURCE: ScopeRxFft.sv

