module gxb_tx (
		input  wire [3:0]   tx_analogreset,          //          tx_analogreset.tx_analogreset
		input  wire [3:0]   tx_digitalreset,         //         tx_digitalreset.tx_digitalreset
		output wire [3:0]   tx_cal_busy,             //             tx_cal_busy.tx_cal_busy
		input  wire [23:0]  tx_bonding_clocks,       //       tx_bonding_clocks.clk
		output wire [3:0]   tx_serial_data,          //          tx_serial_data.tx_serial_data
		input  wire [3:0]   tx_coreclkin,            //            tx_coreclkin.clk
		output wire [3:0]   tx_clkout,               //               tx_clkout.clk
		input  wire [79:0]  tx_parallel_data,        //        tx_parallel_data.tx_parallel_data
		input  wire [431:0] unused_tx_parallel_data, // unused_tx_parallel_data.unused_tx_parallel_data
		input  wire [3:0]   tx_polinv,               //               tx_polinv.tx_polinv
		input  wire [3:0]   reconfig_clk,            //            reconfig_clk.clk
		input  wire [3:0]   reconfig_reset,          //          reconfig_reset.reset
		input  wire [3:0]   reconfig_write,          //           reconfig_avmm.write
		input  wire [3:0]   reconfig_read,           //                        .read
		input  wire [39:0]  reconfig_address,        //                        .address
		input  wire [127:0] reconfig_writedata,      //                        .writedata
		output wire [127:0] reconfig_readdata,       //                        .readdata
		output wire [3:0]   reconfig_waitrequest     //                        .waitrequest
	);
endmodule

