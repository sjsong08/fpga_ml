module pll_hdmi (
		input  wire        rst,               //             reset.reset
		input  wire        refclk,            //            refclk.clk
		output wire        locked,            //            locked.export
		input  wire [63:0] reconfig_to_pll,   //   reconfig_to_pll.reconfig_to_pll
		output wire [63:0] reconfig_from_pll, // reconfig_from_pll.reconfig_from_pll
		output wire        outclk_0,          //           outclk0.clk
		output wire        outclk_1,          //           outclk1.clk
		output wire        outclk_2           //           outclk2.clk
	);
endmodule

