// iopll1.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module iopll1 (
		input  wire  rst,      //   reset.reset
		input  wire  refclk,   //  refclk.clk
		output wire  locked,   //  locked.export
		output wire  outclk_0  // outclk0.clk
	);

	iopll1_altera_iopll_181_roxg6ji iopll_0 (
		.rst      (rst),      //   input,  width = 1,   reset.reset
		.refclk   (refclk),   //   input,  width = 1,  refclk.clk
		.locked   (locked),   //  output,  width = 1,  locked.export
		.outclk_0 (outclk_0)  //  output,  width = 1, outclk0.clk
	);

endmodule
