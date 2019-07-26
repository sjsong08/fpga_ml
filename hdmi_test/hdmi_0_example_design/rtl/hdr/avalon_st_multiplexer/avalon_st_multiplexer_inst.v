	avalon_st_multiplexer u0 (
		.clk_clk                       (_connected_to_clk_clk_),                       //   input,   width = 1,             clk.clk
		.multiplexer_in0_data          (_connected_to_multiplexer_in0_data_),          //   input,  width = 72, multiplexer_in0.data
		.multiplexer_in0_endofpacket   (_connected_to_multiplexer_in0_endofpacket_),   //   input,   width = 1,                .endofpacket
		.multiplexer_in0_ready         (_connected_to_multiplexer_in0_ready_),         //  output,   width = 1,                .ready
		.multiplexer_in0_startofpacket (_connected_to_multiplexer_in0_startofpacket_), //   input,   width = 1,                .startofpacket
		.multiplexer_in0_valid         (_connected_to_multiplexer_in0_valid_),         //   input,   width = 1,                .valid
		.multiplexer_in1_data          (_connected_to_multiplexer_in1_data_),          //   input,  width = 72, multiplexer_in1.data
		.multiplexer_in1_endofpacket   (_connected_to_multiplexer_in1_endofpacket_),   //   input,   width = 1,                .endofpacket
		.multiplexer_in1_ready         (_connected_to_multiplexer_in1_ready_),         //  output,   width = 1,                .ready
		.multiplexer_in1_startofpacket (_connected_to_multiplexer_in1_startofpacket_), //   input,   width = 1,                .startofpacket
		.multiplexer_in1_valid         (_connected_to_multiplexer_in1_valid_),         //   input,   width = 1,                .valid
		.multiplexer_out_channel       (_connected_to_multiplexer_out_channel_),       //  output,   width = 1, multiplexer_out.channel
		.multiplexer_out_data          (_connected_to_multiplexer_out_data_),          //  output,  width = 72,                .data
		.multiplexer_out_endofpacket   (_connected_to_multiplexer_out_endofpacket_),   //  output,   width = 1,                .endofpacket
		.multiplexer_out_ready         (_connected_to_multiplexer_out_ready_),         //   input,   width = 1,                .ready
		.multiplexer_out_startofpacket (_connected_to_multiplexer_out_startofpacket_), //  output,   width = 1,                .startofpacket
		.multiplexer_out_valid         (_connected_to_multiplexer_out_valid_),         //  output,   width = 1,                .valid
		.reset_reset_n                 (_connected_to_reset_reset_n_)                  //   input,   width = 1,           reset.reset_n
	);

