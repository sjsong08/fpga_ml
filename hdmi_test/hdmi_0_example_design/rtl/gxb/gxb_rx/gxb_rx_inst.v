	gxb_rx u0 (
		.rx_analogreset            (_connected_to_rx_analogreset_),            //   input,    width = 3,            rx_analogreset.rx_analogreset
		.rx_digitalreset           (_connected_to_rx_digitalreset_),           //   input,    width = 3,           rx_digitalreset.rx_digitalreset
		.rx_cal_busy               (_connected_to_rx_cal_busy_),               //  output,    width = 3,               rx_cal_busy.rx_cal_busy
		.rx_cdr_refclk0            (_connected_to_rx_cdr_refclk0_),            //   input,    width = 1,            rx_cdr_refclk0.clk
		.rx_serial_data            (_connected_to_rx_serial_data_),            //   input,    width = 3,            rx_serial_data.rx_serial_data
		.rx_set_locktodata         (_connected_to_rx_set_locktodata_),         //   input,    width = 3,         rx_set_locktodata.rx_set_locktodata
		.rx_set_locktoref          (_connected_to_rx_set_locktoref_),          //   input,    width = 3,          rx_set_locktoref.rx_set_locktoref
		.rx_is_lockedtoref         (_connected_to_rx_is_lockedtoref_),         //  output,    width = 3,         rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata        (_connected_to_rx_is_lockedtodata_),        //  output,    width = 3,        rx_is_lockedtodata.rx_is_lockedtodata
		.rx_coreclkin              (_connected_to_rx_coreclkin_),              //   input,    width = 3,              rx_coreclkin.clk
		.rx_clkout                 (_connected_to_rx_clkout_),                 //  output,    width = 3,                 rx_clkout.clk
		.rx_parallel_data          (_connected_to_rx_parallel_data_),          //  output,   width = 60,          rx_parallel_data.rx_parallel_data
		.rx_patterndetect          (_connected_to_rx_patterndetect_),          //  output,    width = 6,          rx_patterndetect.rx_patterndetect
		.rx_syncstatus             (_connected_to_rx_syncstatus_),             //  output,    width = 6,             rx_syncstatus.rx_syncstatus
		.unused_rx_parallel_data   (_connected_to_unused_rx_parallel_data_),   //  output,  width = 312,   unused_rx_parallel_data.unused_rx_parallel_data
		.rx_std_bitslipboundarysel (_connected_to_rx_std_bitslipboundarysel_), //  output,   width = 15, rx_std_bitslipboundarysel.rx_std_bitslipboundarysel
		.rx_std_wa_patternalign    (_connected_to_rx_std_wa_patternalign_),    //   input,    width = 3,    rx_std_wa_patternalign.rx_std_wa_patternalign
		.reconfig_clk              (_connected_to_reconfig_clk_),              //   input,    width = 3,              reconfig_clk.clk
		.reconfig_reset            (_connected_to_reconfig_reset_),            //   input,    width = 3,            reconfig_reset.reset
		.reconfig_write            (_connected_to_reconfig_write_),            //   input,    width = 3,             reconfig_avmm.write
		.reconfig_read             (_connected_to_reconfig_read_),             //   input,    width = 3,                          .read
		.reconfig_address          (_connected_to_reconfig_address_),          //   input,   width = 30,                          .address
		.reconfig_writedata        (_connected_to_reconfig_writedata_),        //   input,   width = 96,                          .writedata
		.reconfig_readdata         (_connected_to_reconfig_readdata_),         //  output,   width = 96,                          .readdata
		.reconfig_waitrequest      (_connected_to_reconfig_waitrequest_)       //  output,    width = 3,                          .waitrequest
	);

