module gxb_rx_reset (
		input  wire       clock,              //              clock.clk
		input  wire       reset,              //              reset.reset
		output wire [2:0] rx_analogreset,     //     rx_analogreset.rx_analogreset
		output wire [2:0] rx_digitalreset,    //    rx_digitalreset.rx_digitalreset
		output wire [2:0] rx_ready,           //           rx_ready.rx_ready
		input  wire [2:0] rx_is_lockedtodata, // rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [2:0] rx_cal_busy         //        rx_cal_busy.rx_cal_busy
	);
endmodule

