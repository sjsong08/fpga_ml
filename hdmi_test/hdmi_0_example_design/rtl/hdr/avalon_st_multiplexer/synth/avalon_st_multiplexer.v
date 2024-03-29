// avalon_st_multiplexer.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module avalon_st_multiplexer (
		input  wire        clk_clk,                       //             clk.clk
		input  wire [71:0] multiplexer_in0_data,          // multiplexer_in0.data
		input  wire        multiplexer_in0_endofpacket,   //                .endofpacket
		output wire        multiplexer_in0_ready,         //                .ready
		input  wire        multiplexer_in0_startofpacket, //                .startofpacket
		input  wire        multiplexer_in0_valid,         //                .valid
		input  wire [71:0] multiplexer_in1_data,          // multiplexer_in1.data
		input  wire        multiplexer_in1_endofpacket,   //                .endofpacket
		output wire        multiplexer_in1_ready,         //                .ready
		input  wire        multiplexer_in1_startofpacket, //                .startofpacket
		input  wire        multiplexer_in1_valid,         //                .valid
		output wire        multiplexer_out_channel,       // multiplexer_out.channel
		output wire [71:0] multiplexer_out_data,          //                .data
		output wire        multiplexer_out_endofpacket,   //                .endofpacket
		input  wire        multiplexer_out_ready,         //                .ready
		output wire        multiplexer_out_startofpacket, //                .startofpacket
		output wire        multiplexer_out_valid,         //                .valid
		input  wire        reset_reset_n                  //           reset.reset_n
	);

	avalon_st_multiplexer_0 avalon_st_multiplexer_0 (
		.clk               (clk_clk),                       //   input,   width = 1,   clk.clk
		.in0_data          (multiplexer_in0_data),          //   input,  width = 72,   in0.data
		.in0_endofpacket   (multiplexer_in0_endofpacket),   //   input,   width = 1,      .endofpacket
		.in0_ready         (multiplexer_in0_ready),         //  output,   width = 1,      .ready
		.in0_startofpacket (multiplexer_in0_startofpacket), //   input,   width = 1,      .startofpacket
		.in0_valid         (multiplexer_in0_valid),         //   input,   width = 1,      .valid
		.in1_data          (multiplexer_in1_data),          //   input,  width = 72,   in1.data
		.in1_endofpacket   (multiplexer_in1_endofpacket),   //   input,   width = 1,      .endofpacket
		.in1_ready         (multiplexer_in1_ready),         //  output,   width = 1,      .ready
		.in1_startofpacket (multiplexer_in1_startofpacket), //   input,   width = 1,      .startofpacket
		.in1_valid         (multiplexer_in1_valid),         //   input,   width = 1,      .valid
		.out_channel       (multiplexer_out_channel),       //  output,   width = 1,   out.channel
		.out_data          (multiplexer_out_data),          //  output,  width = 72,      .data
		.out_endofpacket   (multiplexer_out_endofpacket),   //  output,   width = 1,      .endofpacket
		.out_ready         (multiplexer_out_ready),         //   input,   width = 1,      .ready
		.out_startofpacket (multiplexer_out_startofpacket), //  output,   width = 1,      .startofpacket
		.out_valid         (multiplexer_out_valid),         //  output,   width = 1,      .valid
		.reset_n           (reset_reset_n)                  //   input,   width = 1, reset.reset_n
	);

endmodule
