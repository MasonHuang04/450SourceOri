// One complete, immutable frame crosses the clock domains by a done toggle.
// Never written while FFT reads it. Read latency is one rd_clk edge.
module ScopeFrameRam(input logic wr_clk,rd_clk,we,
 input logic [10:0] wr_addr,rd_addr,input logic [15:0] data,
 output wire [15:0] q);
`ifdef FFT_USE_INTEL_RAM
 altsyncram #(.intended_device_family("Cyclone V"),.operation_mode("DUAL_PORT"),
 .width_a(16),.widthad_a(11),.numwords_a(2048),.width_b(16),.widthad_b(11),.numwords_b(2048),
 .width_byteena_a(1),.width_byteena_b(1),.address_reg_b("CLOCK1"),.outdata_reg_b("UNREGISTERED"),
 .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),
 .clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
 .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),.read_during_write_mode_mixed_ports("DONT_CARE")) mem(
 .clock0(wr_clk),.clock1(rd_clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),
 .aclr0(1'b0),.aclr1(1'b0),.addressstall_a(1'b0),.addressstall_b(1'b0),
 .address_a(wr_addr),.address_b(rd_addr),.data_a(data),.data_b(16'b0),.wren_a(we),.wren_b(1'b0),
 .rden_a(1'b1),.rden_b(1'b1),.byteena_a(1'b1),.byteena_b(1'b1),.q_a(),.q_b(q),.eccstatus());
`else
 logic [15:0] memory[0:2047];logic [15:0] qr;
 always_ff @(posedge wr_clk)if(we)memory[wr_addr]<=data;
 always_ff @(posedge rd_clk)qr<=memory[rd_addr];
 assign q=qr;
`endif
endmodule
