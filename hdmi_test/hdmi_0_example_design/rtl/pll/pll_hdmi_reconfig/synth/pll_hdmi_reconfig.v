// pll_hdmi_reconfig.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module pll_hdmi_reconfig #(
		parameter ENABLE_BYTEENABLE   = 0,
		parameter BYTEENABLE_WIDTH    = 4,
		parameter RECONFIG_ADDR_WIDTH = 9,
		parameter RECONFIG_DATA_WIDTH = 32,
		parameter reconf_width        = 64,
		parameter WAIT_FOR_LOCK       = 0
	) (
		input  wire        mgmt_clk,          //          mgmt_clk.clk
		input  wire        mgmt_reset,        //        mgmt_reset.reset
		output wire        mgmt_waitrequest,  // mgmt_avalon_slave.waitrequest
		input  wire        mgmt_read,         //                  .read
		input  wire        mgmt_write,        //                  .write
		output wire [31:0] mgmt_readdata,     //                  .readdata
		input  wire [8:0]  mgmt_address,      //                  .address
		input  wire [31:0] mgmt_writedata,    //                  .writedata
		output wire [63:0] reconfig_to_pll,   //   reconfig_to_pll.reconfig_to_pll
		input  wire [63:0] reconfig_from_pll  // reconfig_from_pll.reconfig_from_pll
	);

	altera_pll_reconfig_top #(
		.device_family       ("Cyclone 10 GX"),
		.ENABLE_MIF          (0),
		.MIF_FILE_NAME       (""),
		.ENABLE_BYTEENABLE   (ENABLE_BYTEENABLE),
		.BYTEENABLE_WIDTH    (BYTEENABLE_WIDTH),
		.RECONFIG_ADDR_WIDTH (RECONFIG_ADDR_WIDTH),
		.RECONFIG_DATA_WIDTH (RECONFIG_DATA_WIDTH),
		.reconf_width        (reconf_width),
		.WAIT_FOR_LOCK       (WAIT_FOR_LOCK)
	) pll_hdmi_reconfig (
		.mgmt_clk          (mgmt_clk),          //   input,   width = 1,          mgmt_clk.clk
		.mgmt_reset        (mgmt_reset),        //   input,   width = 1,        mgmt_reset.reset
		.mgmt_waitrequest  (mgmt_waitrequest),  //  output,   width = 1, mgmt_avalon_slave.waitrequest
		.mgmt_read         (mgmt_read),         //   input,   width = 1,                  .read
		.mgmt_write        (mgmt_write),        //   input,   width = 1,                  .write
		.mgmt_readdata     (mgmt_readdata),     //  output,  width = 32,                  .readdata
		.mgmt_address      (mgmt_address),      //   input,   width = 9,                  .address
		.mgmt_writedata    (mgmt_writedata),    //   input,  width = 32,                  .writedata
		.reconfig_to_pll   (reconfig_to_pll),   //  output,  width = 64,   reconfig_to_pll.reconfig_to_pll
		.reconfig_from_pll (reconfig_from_pll), //   input,  width = 64, reconfig_from_pll.reconfig_from_pll
		.mgmt_byteenable   (4'b0000)            // (terminated),                                
	);

endmodule
