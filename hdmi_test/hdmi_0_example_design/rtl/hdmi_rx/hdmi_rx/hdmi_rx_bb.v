module hdmi_rx (
		input  wire        reset,                //                reset.export
		input  wire        vid_clk,              //              vid_clk.export
		input  wire [2:0]  ls_clk,               //               ls_clk.export
		output wire [2:0]  locked,               //               locked.export
		output wire        mode,                 //                 mode.export
		output wire [11:0] ctrl,                 //                 ctrl.export
		output wire        vid_lock,             //             vid_lock.export
		output wire [1:0]  vid_de,               //               vid_de.export
		output wire [95:0] vid_data,             //             vid_data.export
		output wire [1:0]  vid_hsync,            //            vid_hsync.export
		output wire [1:0]  vid_vsync,            //            vid_vsync.export
		input  wire [19:0] in_b,                 //                 in_b.export
		input  wire [19:0] in_r,                 //                 in_r.export
		input  wire [19:0] in_g,                 //                 in_g.export
		input  wire [2:0]  in_lock,              //              in_lock.export
		input  wire        scdc_i2c_clk,         //         scdc_i2c_clk.clk
		input  wire [7:0]  scdc_i2c_addr,        //        scdc_i2c_addr.export
		input  wire [7:0]  scdc_i2c_wdata,       //       scdc_i2c_wdata.export
		input  wire        scdc_i2c_r,           //           scdc_i2c_r.export
		input  wire        scdc_i2c_w,           //           scdc_i2c_w.export
		output wire [7:0]  scdc_i2c_rdata,       //       scdc_i2c_rdata.export
		output wire        TMDS_Bit_clock_Ratio, // TMDS_Bit_clock_Ratio.export
		input  wire        in_5v_power,          //          in_5v_power.export
		input  wire        in_hpd                //               in_hpd.export
	);
endmodule

