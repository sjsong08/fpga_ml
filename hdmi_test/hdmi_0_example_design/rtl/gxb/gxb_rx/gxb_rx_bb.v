module gxb_rx (
		input  wire [2:0]   rx_analogreset,            //            rx_analogreset.rx_analogreset
		input  wire [2:0]   rx_digitalreset,           //           rx_digitalreset.rx_digitalreset
		output wire [2:0]   rx_cal_busy,               //               rx_cal_busy.rx_cal_busy
		input  wire         rx_cdr_refclk0,            //            rx_cdr_refclk0.clk
		input  wire [2:0]   rx_serial_data,            //            rx_serial_data.rx_serial_data
		input  wire [2:0]   rx_set_locktodata,         //         rx_set_locktodata.rx_set_locktodata
		input  wire [2:0]   rx_set_locktoref,          //          rx_set_locktoref.rx_set_locktoref
		output wire [2:0]   rx_is_lockedtoref,         //         rx_is_lockedtoref.rx_is_lockedtoref
		output wire [2:0]   rx_is_lockedtodata,        //        rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [2:0]   rx_coreclkin,              //              rx_coreclkin.clk
		output wire [2:0]   rx_clkout,                 //                 rx_clkout.clk
		output wire [59:0]  rx_parallel_data,          //          rx_parallel_data.rx_parallel_data
		output wire [5:0]   rx_patterndetect,          //          rx_patterndetect.rx_patterndetect
		output wire [5:0]   rx_syncstatus,             //             rx_syncstatus.rx_syncstatus
		output wire [311:0] unused_rx_parallel_data,   //   unused_rx_parallel_data.unused_rx_parallel_data
		output wire [14:0]  rx_std_bitslipboundarysel, // rx_std_bitslipboundarysel.rx_std_bitslipboundarysel
		input  wire [2:0]   rx_std_wa_patternalign,    //    rx_std_wa_patternalign.rx_std_wa_patternalign
		input  wire [2:0]   reconfig_clk,              //              reconfig_clk.clk
		input  wire [2:0]   reconfig_reset,            //            reconfig_reset.reset
		input  wire [2:0]   reconfig_write,            //             reconfig_avmm.write
		input  wire [2:0]   reconfig_read,             //                          .read
		input  wire [29:0]  reconfig_address,          //                          .address
		input  wire [95:0]  reconfig_writedata,        //                          .writedata
		output wire [95:0]  reconfig_readdata,         //                          .readdata
		output wire [2:0]   reconfig_waitrequest       //                          .waitrequest
	);
endmodule

