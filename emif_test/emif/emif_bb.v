module emif (
		input  wire         global_reset_n,      //   global_reset_n.reset_n,           Asynchronous reset causes the memory interface to be reset and recalibrated. The global reset signal applies to all memory interfaces placed within an I/O column.
		input  wire         pll_ref_clk,         //      pll_ref_clk.clk,               PLL reference clock input
		input  wire         oct_rzqin,           //              oct.oct_rzqin,         Calibrated On-Chip Termination (OCT) RZQ input pin
		output wire [0:0]   mem_ck,              //              mem.mem_ck,            CK clock
		output wire [0:0]   mem_ck_n,            //                 .mem_ck_n,          CK clock (negative leg)
		output wire [14:0]  mem_a,               //                 .mem_a,             Address
		output wire [2:0]   mem_ba,              //                 .mem_ba,            Bank address
		output wire [0:0]   mem_cke,             //                 .mem_cke,           Clock enable
		output wire [0:0]   mem_cs_n,            //                 .mem_cs_n,          Chip select
		output wire [0:0]   mem_odt,             //                 .mem_odt,           On-die termination
		output wire [0:0]   mem_reset_n,         //                 .mem_reset_n,       Asynchronous reset
		output wire [0:0]   mem_we_n,            //                 .mem_we_n,          WE command
		output wire [0:0]   mem_ras_n,           //                 .mem_ras_n,         RAS command
		output wire [0:0]   mem_cas_n,           //                 .mem_cas_n,         CAS command
		inout  wire [4:0]   mem_dqs,             //                 .mem_dqs,           Data strobe
		inout  wire [4:0]   mem_dqs_n,           //                 .mem_dqs_n,         Data strobe (negative leg)
		inout  wire [39:0]  mem_dq,              //                 .mem_dq,            Read/write data
		output wire [4:0]   mem_dm,              //                 .mem_dm,            Write data mask
		output wire         local_cal_success,   //           status.local_cal_success, When high, indicates that PHY calibration was successful
		output wire         local_cal_fail,      //                 .local_cal_fail,    When high, indicates that PHY calibration failed
		output wire         emif_usr_reset_n,    // emif_usr_reset_n.reset_n,           Reset for the user clock domain. Asynchronous assertion and synchronous deassertion
		output wire         emif_usr_clk,        //     emif_usr_clk.clk,               User clock domain
		output wire         amm_ready_0,         //       ctrl_amm_0.waitrequest_n,     Wait-request is asserted when controller is busy
		input  wire         amm_read_0,          //                 .read,              Read request signal
		input  wire         amm_write_0,         //                 .write,             Write request signal
		input  wire [24:0]  amm_address_0,       //                 .address,           Address for the read/write request
		output wire [319:0] amm_readdata_0,      //                 .readdata,          Read data
		input  wire [319:0] amm_writedata_0,     //                 .writedata,         Write data
		input  wire [6:0]   amm_burstcount_0,    //                 .burstcount,        Number of transfers in each read/write burst
		input  wire [39:0]  amm_byteenable_0,    //                 .byteenable,        Byte-enable for write data
		output wire         amm_readdatavalid_0  //                 .readdatavalid,     Indicates whether read data is valid
	);
endmodule

