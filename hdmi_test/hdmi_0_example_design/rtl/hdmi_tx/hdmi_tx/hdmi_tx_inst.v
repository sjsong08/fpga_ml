	hdmi_tx u0 (
		.reset                (_connected_to_reset_),                //   input,   width = 1,                reset.export
		.vid_clk              (_connected_to_vid_clk_),              //   input,   width = 1,              vid_clk.export
		.ls_clk               (_connected_to_ls_clk_),               //   input,   width = 1,               ls_clk.export
		.mode                 (_connected_to_mode_),                 //   input,   width = 1,                 mode.export
		.vid_de               (_connected_to_vid_de_),               //   input,   width = 2,               vid_de.export
		.vid_data             (_connected_to_vid_data_),             //   input,  width = 96,             vid_data.export
		.vid_hsync            (_connected_to_vid_hsync_),            //   input,   width = 2,            vid_hsync.export
		.vid_vsync            (_connected_to_vid_vsync_),            //   input,   width = 2,            vid_vsync.export
		.out_b                (_connected_to_out_b_),                //  output,  width = 20,                out_b.export
		.out_r                (_connected_to_out_r_),                //  output,  width = 20,                out_r.export
		.out_g                (_connected_to_out_g_),                //  output,  width = 20,                out_g.export
		.out_c                (_connected_to_out_c_),                //  output,  width = 20,                out_c.export
		.Scrambler_Enable     (_connected_to_Scrambler_Enable_),     //   input,   width = 1,     Scrambler_Enable.export
		.TMDS_Bit_clock_Ratio (_connected_to_TMDS_Bit_clock_Ratio_), //   input,   width = 1, TMDS_Bit_clock_Ratio.export
		.ctrl                 (_connected_to_ctrl_)                  //   input,  width = 12,                 ctrl.export
	);

