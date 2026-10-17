// Main frame buffer: 16 banks reduce address fan-out and register the read mux.
// Both clocks must be the same 165-MHz clock. Read data is valid six clocks
// after rdreq; MainTxPack explicitly waits before consuming it.
module MainWaveFifo(input aclr,input [15:0] data,input rdclk,rdreq,wrclk,wrreq,
 output logic [7:0] q=0,output wire rdempty,wrfull);
 logic [17:0] words=0;logic [18:0] bytes_read=0;
 logic write_pipe=0;logic [16:0] write_addr=0;logic [17:0] read_addr=0;logic [15:0] write_data=0;
 assign wrfull=words[17];assign rdempty=bytes_read=={words,1'b0};
 wire write_en=wrreq&&!wrfull,read_en=rdreq&&!rdempty;
 always @(posedge wrclk or posedge aclr)begin
  if(aclr)begin words<=0;bytes_read<=0;write_pipe<=0;write_addr<=0;read_addr<=0;write_data<=0;end
  else begin
   write_pipe<=write_en;if(write_en)begin words<=words+1'b1;write_addr<=words[16:0];write_data<=data;end
   if(read_en)begin bytes_read<=bytes_read+1'b1;read_addr<=bytes_read[17:0];end
  end
 end
 wire [15:0] bank_q[0:15];
 genvar b; generate for(b=0;b<16;b=b+1)begin:banks
  (* preserve, dont_merge *) logic [12:0] wa=0,ra=0;
  (* preserve, dont_merge *) logic [15:0] wd=0;
  logic we=0;
  always @(posedge wrclk)begin
   we<=write_pipe&&(write_addr[16:13]==b)&&!aclr;wa<=write_addr[12:0];wd<=write_data;
   ra<=read_addr[13:1];
  end
  MainWaveBank ram(.clk(wrclk),.we(we),.wa(wa),.ra(ra),.data(wd),.q(bank_q[b]));
 end
 endgenerate
 logic [15:0] group_word[0:3];
 genvar g;generate for(g=0;g<4;g=g+1)begin:read_groups
  (* preserve, dont_merge *) logic [1:0] sel=0;
  always @(posedge rdclk)begin sel<=read_addr[15:14];group_word[g]<=bank_q[g*4+sel];end
 end endgenerate
 always @(posedge rdclk)q<=read_addr[0] ? group_word[read_addr[17:16]][15:8] : group_word[read_addr[17:16]][7:0];
endmodule
// Split write enables further so one control register drives eight M10Ks.
module MainWaveBank(input clk,we,input [12:0] wa,ra,input [15:0] data,output logic [15:0] q);
 logic [11:0] wa_pipe=0;logic [15:0] data_pipe=0;
 (* preserve, dont_merge *) logic [1:0] we_half=0;
 wire [15:0] half_q[0:1];
 always @(posedge clk)begin wa_pipe<=wa[11:0];data_pipe<=data;we_half<={we&&wa[12],we&&!wa[12]};end
 genvar h;generate for(h=0;h<2;h=h+1)begin:halves
`ifdef FFT_USE_INTEL_RAM
 altsyncram #(.intended_device_family("Cyclone V"),.operation_mode("DUAL_PORT"),
 .width_a(16),.widthad_a(12),.numwords_a(4096),.width_b(16),.widthad_b(12),.numwords_b(4096),
 .width_byteena_a(1),.width_byteena_b(1),.address_reg_b("CLOCK1"),.outdata_reg_b("UNREGISTERED"),
 .clock_enable_input_a("BYPASS"),.clock_enable_input_b("BYPASS"),.clock_enable_output_a("BYPASS"),.clock_enable_output_b("BYPASS"),
 .ram_block_type("M10K"),.power_up_uninitialized("TRUE"),.read_during_write_mode_mixed_ports("DONT_CARE")) mem(
 .clock0(clk),.clock1(clk),.clocken0(1'b1),.clocken1(1'b1),.clocken2(1'b1),.clocken3(1'b1),.aclr0(1'b0),.aclr1(1'b0),
 .addressstall_a(1'b0),.addressstall_b(1'b0),.address_a(wa_pipe),.address_b(ra[11:0]),.data_a(data_pipe),.data_b(16'b0),
 .wren_a(we_half[h]),.wren_b(1'b0),.rden_a(1'b1),.rden_b(1'b1),.byteena_a(1'b1),.byteena_b(1'b1),.q_a(),.q_b(half_q[h]),.eccstatus());
`else
 logic [15:0] memory[0:4095];logic [15:0] mr;
 always @(posedge clk)begin if(we_half[h])memory[wa_pipe]<=data_pipe;mr<=memory[ra[11:0]];end
 assign half_q[h]=mr;
`endif
 end endgenerate
 always @(posedge clk)q<=half_q[ra[12]];
endmodule
