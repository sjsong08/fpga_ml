module hdmi_tx (
		input  wire        reset,                //                reset.export
		input  wire        vid_clk,              //              vid_clk.export
		input  wire        ls_clk,               //               ls_clk.export
		input  wire        mode,                 //                 mode.export
		input  wire [1:0]  vid_de,               //               vid_de.export
		input  wire [95:0] vid_data,             //             vid_data.export
		input  wire [1:0]  vid_hsync,            //            vid_hsync.export
		input  wire [1:0]  vid_vsync,            //            vid_vsync.export
		output wire [19:0] out_b,                //                out_b.export
		output wire [19:0] out_r,                //                out_r.export
		output wire [19:0] out_g,                //                out_g.export
		output wire [19:0] out_c,                //                out_c.export
		input  wire        Scrambler_Enable,     //     Scrambler_Enable.export
		input  wire        TMDS_Bit_clock_Ratio, // TMDS_Bit_clock_Ratio.export
		input  wire [11:0] ctrl                  //                 ctrl.export
	);
endmodule

