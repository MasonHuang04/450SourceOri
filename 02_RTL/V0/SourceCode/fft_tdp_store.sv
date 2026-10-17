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
