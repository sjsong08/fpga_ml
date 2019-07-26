	hdmi_rx u0 (
		.reset                (_connected_to_reset_),                //   input,   width = 1,                reset.export
		.vid_clk              (_connected_to_vid_clk_),              //   input,   width = 1,              vid_clk.export
		.ls_clk               (_connected_to_ls_clk_),               //   input,   width = 3,               ls_clk.export
		.locked               (_connected_to_locked_),               //  output,   width = 3,               locked.export
		.mode                 (_connected_to_mode_),                 //  output,   width = 1,                 mode.export
		.ctrl                 (_connected_to_ctrl_),                 //  output,  width = 12,                 ctrl.export
		.vid_lock             (_connected_to_vid_lock_),             //  output,   width = 1,             vid_lock.export
		.vid_de               (_connected_to_vid_de_),               //  output,   width = 2,               vid_de.export
		.vid_data             (_connected_to_vid_data_),             //  output,  width = 96,             vid_data.export
		.vid_hsync            (_connected_to_vid_hsync_),            //  output,   width = 2,            vid_hsync.export
		.vid_vsync            (_connected_to_vid_vsync_),            //  output,   width = 2,            vid_vsync.export
		.in_b                 (_connected_to_in_b_),                 //   input,  width = 20,                 in_b.export
		.in_r                 (_connected_to_in_r_),                 //   input,  width = 20,                 in_r.export
		.in_g                 (_connected_to_in_g_),                 //   input,  width = 20,                 in_g.export
		.in_lock              (_connected_to_in_lock_),              //   input,   width = 3,              in_lock.export
		.scdc_i2c_clk         (_connected_to_scdc_i2c_clk_),         //   input,   width = 1,         scdc_i2c_clk.clk
		.scdc_i2c_addr        (_connected_to_scdc_i2c_addr_),        //   input,   width = 8,        scdc_i2c_addr.export
		.scdc_i2c_wdata       (_connected_to_scdc_i2c_wdata_),       //   input,   width = 8,       scdc_i2c_wdata.export
		.scdc_i2c_r           (_connected_to_scdc_i2c_r_),           //   input,   width = 1,           scdc_i2c_r.export
		.scdc_i2c_w           (_connected_to_scdc_i2c_w_),           //   input,   width = 1,           scdc_i2c_w.export
		.scdc_i2c_rdata       (_connected_to_scdc_i2c_rdata_),       //  output,   width = 8,       scdc_i2c_rdata.export
		.TMDS_Bit_clock_Ratio (_connected_to_TMDS_Bit_clock_Ratio_), //  output,   width = 1, TMDS_Bit_clock_Ratio.export
		.in_5v_power          (_connected_to_in_5v_power_),          //   input,   width = 1,          in_5v_power.export
		.in_hpd               (_connected_to_in_hpd_)                //   input,   width = 1,               in_hpd.export
	);

