	pll_hdmi_reconfig #(
		.ENABLE_BYTEENABLE   (BOOLEAN_VALUE_FOR_ENABLE_BYTEENABLE),
		.BYTEENABLE_WIDTH    (INTEGER_VALUE_FOR_BYTEENABLE_WIDTH),
		.RECONFIG_ADDR_WIDTH (INTEGER_VALUE_FOR_RECONFIG_ADDR_WIDTH),
		.RECONFIG_DATA_WIDTH (INTEGER_VALUE_FOR_RECONFIG_DATA_WIDTH),
		.reconf_width        (INTEGER_VALUE_FOR_reconf_width),
		.WAIT_FOR_LOCK       (BOOLEAN_VALUE_FOR_WAIT_FOR_LOCK)
	) u0 (
		.mgmt_clk          (_connected_to_mgmt_clk_),          //   input,   width = 1,          mgmt_clk.clk
		.mgmt_reset        (_connected_to_mgmt_reset_),        //   input,   width = 1,        mgmt_reset.reset
		.mgmt_waitrequest  (_connected_to_mgmt_waitrequest_),  //  output,   width = 1, mgmt_avalon_slave.waitrequest
		.mgmt_read         (_connected_to_mgmt_read_),         //   input,   width = 1,                  .read
		.mgmt_write        (_connected_to_mgmt_write_),        //   input,   width = 1,                  .write
		.mgmt_readdata     (_connected_to_mgmt_readdata_),     //  output,  width = 32,                  .readdata
		.mgmt_address      (_connected_to_mgmt_address_),      //   input,   width = 9,                  .address
		.mgmt_writedata    (_connected_to_mgmt_writedata_),    //   input,  width = 32,                  .writedata
		.reconfig_to_pll   (_connected_to_reconfig_to_pll_),   //  output,  width = 64,   reconfig_to_pll.reconfig_to_pll
		.reconfig_from_pll (_connected_to_reconfig_from_pll_)  //   input,  width = 64, reconfig_from_pll.reconfig_from_pll
	);

