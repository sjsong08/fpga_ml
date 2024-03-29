// gxb_tx_reset.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module gxb_tx_reset (
		input  wire       clock,           //           clock.clk
		input  wire       reset,           //           reset.reset
		output wire [0:0] pll_powerdown,   //   pll_powerdown.pll_powerdown
		output wire [3:0] tx_analogreset,  //  tx_analogreset.tx_analogreset
		output wire [3:0] tx_digitalreset, // tx_digitalreset.tx_digitalreset
		output wire [3:0] tx_ready,        //        tx_ready.tx_ready
		input  wire [0:0] pll_locked,      //      pll_locked.pll_locked
		input  wire [0:0] pll_select,      //      pll_select.pll_select
		input  wire [3:0] tx_cal_busy      //     tx_cal_busy.tx_cal_busy
	);

	altera_xcvr_reset_control #(
		.CHANNELS              (4),
		.PLLS                  (1),
		.SYS_CLK_IN_MHZ        (100),
		.SYNCHRONIZE_RESET     (1),
		.REDUCED_SIM_TIME      (1),
		.TX_PLL_ENABLE         (1),
		.T_PLL_POWERDOWN       (1000),
		.SYNCHRONIZE_PLL_RESET (1),
		.TX_ENABLE             (1),
		.TX_PER_CHANNEL        (0),
		.T_TX_ANALOGRESET      (70000),
		.T_TX_DIGITALRESET     (70000),
		.T_PLL_LOCK_HYST       (0),
		.EN_PLL_CAL_BUSY       (0),
		.RX_ENABLE             (0),
		.RX_PER_CHANNEL        (0),
		.T_RX_ANALOGRESET      (40),
		.T_RX_DIGITALRESET     (4000)
	) gxb_tx_reset (
		.clock              (clock),           //   input,  width = 1,           clock.clk
		.reset              (reset),           //   input,  width = 1,           reset.reset
		.pll_powerdown      (pll_powerdown),   //  output,  width = 1,   pll_powerdown.pll_powerdown
		.tx_analogreset     (tx_analogreset),  //  output,  width = 4,  tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset), //  output,  width = 4, tx_digitalreset.tx_digitalreset
		.tx_ready           (tx_ready),        //  output,  width = 4,        tx_ready.tx_ready
		.pll_locked         (pll_locked),      //   input,  width = 1,      pll_locked.pll_locked
		.pll_select         (pll_select),      //   input,  width = 1,      pll_select.pll_select
		.tx_cal_busy        (tx_cal_busy),     //   input,  width = 4,     tx_cal_busy.tx_cal_busy
		.pll_cal_busy       (1'b0),            // (terminated),                             
		.tx_manual          (4'b0000),         // (terminated),                             
		.rx_analogreset     (),                // (terminated),                             
		.rx_digitalreset    (),                // (terminated),                             
		.rx_ready           (),                // (terminated),                             
		.rx_is_lockedtodata (4'b0000),         // (terminated),                             
		.rx_cal_busy        (4'b0000),         // (terminated),                             
		.rx_manual          (4'b0000),         // (terminated),                             
		.tx_digitalreset_or (4'b0000),         // (terminated),                             
		.rx_digitalreset_or (4'b0000)          // (terminated),                             
	);

endmodule
