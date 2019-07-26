	gxb_tx u0 (
		.tx_analogreset          (_connected_to_tx_analogreset_),          //   input,    width = 4,          tx_analogreset.tx_analogreset
		.tx_digitalreset         (_connected_to_tx_digitalreset_),         //   input,    width = 4,         tx_digitalreset.tx_digitalreset
		.tx_cal_busy             (_connected_to_tx_cal_busy_),             //  output,    width = 4,             tx_cal_busy.tx_cal_busy
		.tx_bonding_clocks       (_connected_to_tx_bonding_clocks_),       //   input,   width = 24,       tx_bonding_clocks.clk
		.tx_serial_data          (_connected_to_tx_serial_data_),          //  output,    width = 4,          tx_serial_data.tx_serial_data
		.tx_coreclkin            (_connected_to_tx_coreclkin_),            //   input,    width = 4,            tx_coreclkin.clk
		.tx_clkout               (_connected_to_tx_clkout_),               //  output,    width = 4,               tx_clkout.clk
		.tx_parallel_data        (_connected_to_tx_parallel_data_),        //   input,   width = 80,        tx_parallel_data.tx_parallel_data
		.unused_tx_parallel_data (_connected_to_unused_tx_parallel_data_), //   input,  width = 432, unused_tx_parallel_data.unused_tx_parallel_data
		.tx_polinv               (_connected_to_tx_polinv_),               //   input,    width = 4,               tx_polinv.tx_polinv
		.reconfig_clk            (_connected_to_reconfig_clk_),            //   input,    width = 4,            reconfig_clk.clk
		.reconfig_reset          (_connected_to_reconfig_reset_),          //   input,    width = 4,          reconfig_reset.reset
		.reconfig_write          (_connected_to_reconfig_write_),          //   input,    width = 4,           reconfig_avmm.write
		.reconfig_read           (_connected_to_reconfig_read_),           //   input,    width = 4,                        .read
		.reconfig_address        (_connected_to_reconfig_address_),        //   input,   width = 40,                        .address
		.reconfig_writedata      (_connected_to_reconfig_writedata_),      //   input,  width = 128,                        .writedata
		.reconfig_readdata       (_connected_to_reconfig_readdata_),       //  output,  width = 128,                        .readdata
		.reconfig_waitrequest    (_connected_to_reconfig_waitrequest_)     //  output,    width = 4,                        .waitrequest
	);

