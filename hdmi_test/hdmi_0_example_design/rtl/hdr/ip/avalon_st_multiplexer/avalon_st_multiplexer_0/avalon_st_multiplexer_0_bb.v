module avalon_st_multiplexer_0 (
		input  wire        clk,               //   clk.clk
		input  wire        reset_n,           // reset.reset_n
		output wire [71:0] out_data,          //   out.data
		output wire        out_valid,         //      .valid
		input  wire        out_ready,         //      .ready
		output wire        out_startofpacket, //      .startofpacket
		output wire        out_endofpacket,   //      .endofpacket
		output wire        out_channel,       //      .channel
		input  wire [71:0] in0_data,          //   in0.data
		input  wire        in0_valid,         //      .valid
		output wire        in0_ready,         //      .ready
		input  wire        in0_startofpacket, //      .startofpacket
		input  wire        in0_endofpacket,   //      .endofpacket
		input  wire [71:0] in1_data,          //   in1.data
		input  wire        in1_valid,         //      .valid
		output wire        in1_ready,         //      .ready
		input  wire        in1_startofpacket, //      .startofpacket
		input  wire        in1_endofpacket    //      .endofpacket
	);
endmodule

