	avalon_st_multiplexer_0 u0 (
		.clk               (_connected_to_clk_),               //   input,   width = 1,   clk.clk
		.reset_n           (_connected_to_reset_n_),           //   input,   width = 1, reset.reset_n
		.out_data          (_connected_to_out_data_),          //  output,  width = 72,   out.data
		.out_valid         (_connected_to_out_valid_),         //  output,   width = 1,      .valid
		.out_ready         (_connected_to_out_ready_),         //   input,   width = 1,      .ready
		.out_startofpacket (_connected_to_out_startofpacket_), //  output,   width = 1,      .startofpacket
		.out_endofpacket   (_connected_to_out_endofpacket_),   //  output,   width = 1,      .endofpacket
		.out_channel       (_connected_to_out_channel_),       //  output,   width = 1,      .channel
		.in0_data          (_connected_to_in0_data_),          //   input,  width = 72,   in0.data
		.in0_valid         (_connected_to_in0_valid_),         //   input,   width = 1,      .valid
		.in0_ready         (_connected_to_in0_ready_),         //  output,   width = 1,      .ready
		.in0_startofpacket (_connected_to_in0_startofpacket_), //   input,   width = 1,      .startofpacket
		.in0_endofpacket   (_connected_to_in0_endofpacket_),   //   input,   width = 1,      .endofpacket
		.in1_data          (_connected_to_in1_data_),          //   input,  width = 72,   in1.data
		.in1_valid         (_connected_to_in1_valid_),         //   input,   width = 1,      .valid
		.in1_ready         (_connected_to_in1_ready_),         //  output,   width = 1,      .ready
		.in1_startofpacket (_connected_to_in1_startofpacket_), //   input,   width = 1,      .startofpacket
		.in1_endofpacket   (_connected_to_in1_endofpacket_)    //   input,   width = 1,      .endofpacket
	);

