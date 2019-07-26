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
endmodule

