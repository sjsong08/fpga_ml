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
endmodule

