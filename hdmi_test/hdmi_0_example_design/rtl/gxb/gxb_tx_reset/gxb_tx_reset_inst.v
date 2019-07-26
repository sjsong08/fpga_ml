	gxb_tx_reset u0 (
		.clock           (_connected_to_clock_),           //   input,  width = 1,           clock.clk
		.reset           (_connected_to_reset_),           //   input,  width = 1,           reset.reset
		.pll_powerdown   (_connected_to_pll_powerdown_),   //  output,  width = 1,   pll_powerdown.pll_powerdown
		.tx_analogreset  (_connected_to_tx_analogreset_),  //  output,  width = 4,  tx_analogreset.tx_analogreset
		.tx_digitalreset (_connected_to_tx_digitalreset_), //  output,  width = 4, tx_digitalreset.tx_digitalreset
		.tx_ready        (_connected_to_tx_ready_),        //  output,  width = 4,        tx_ready.tx_ready
		.pll_locked      (_connected_to_pll_locked_),      //   input,  width = 1,      pll_locked.pll_locked
		.pll_select      (_connected_to_pll_select_),      //   input,  width = 1,      pll_select.pll_select
		.tx_cal_busy     (_connected_to_tx_cal_busy_)      //   input,  width = 4,     tx_cal_busy.tx_cal_busy
	);

