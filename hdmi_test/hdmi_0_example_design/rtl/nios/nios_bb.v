module nios (
		input  wire [1:0]  color_depth_pio_external_connection_export,                        //                   color_depth_pio_external_connection.export
		input  wire        cpu_clk,                                                           //                                                   cpu.clk
		input  wire        cpu_clk_reset_n,                                                   //                                               cpu_clk.reset_n
		output wire        edid_ram_access_pio_external_connection_export,                    //               edid_ram_access_pio_external_connection.export
		output wire [7:0]  edid_ram_slave_translator_address,                                 //                             edid_ram_slave_translator.address
		output wire        edid_ram_slave_translator_write,                                   //                                                      .write
		output wire        edid_ram_slave_translator_read,                                    //                                                      .read
		input  wire [7:0]  edid_ram_slave_translator_readdata,                                //                                                      .readdata
		output wire [7:0]  edid_ram_slave_translator_writedata,                               //                                                      .writedata
		input  wire        edid_ram_slave_translator_waitrequest,                             //                                                      .waitrequest
		input  wire [23:0] measure_pio_external_connection_export,                            //                       measure_pio_external_connection.export
		input  wire        measure_valid_pio_external_connection_export,                      //                 measure_valid_pio_external_connection.export
		output wire [2:0]  oc_i2c_master_av_slave_translator_avalon_anti_slave_0_address,     // oc_i2c_master_av_slave_translator_avalon_anti_slave_0.address
		output wire        oc_i2c_master_av_slave_translator_avalon_anti_slave_0_write,       //                                                      .write
		input  wire [31:0] oc_i2c_master_av_slave_translator_avalon_anti_slave_0_readdata,    //                                                      .readdata
		output wire [31:0] oc_i2c_master_av_slave_translator_avalon_anti_slave_0_writedata,   //                                                      .writedata
		input  wire        oc_i2c_master_av_slave_translator_avalon_anti_slave_0_waitrequest, //                                                      .waitrequest
		output wire        oc_i2c_master_av_slave_translator_avalon_anti_slave_0_chipselect,  //                                                      .chipselect
		output wire [2:0]  oc_i2c_master_ti_avalon_anti_slave_address,                        //                    oc_i2c_master_ti_avalon_anti_slave.address
		output wire        oc_i2c_master_ti_avalon_anti_slave_write,                          //                                                      .write
		input  wire [31:0] oc_i2c_master_ti_avalon_anti_slave_readdata,                       //                                                      .readdata
		output wire [31:0] oc_i2c_master_ti_avalon_anti_slave_writedata,                      //                                                      .writedata
		input  wire        oc_i2c_master_ti_avalon_anti_slave_waitrequest,                    //                                                      .waitrequest
		output wire        oc_i2c_master_ti_avalon_anti_slave_chipselect,                     //                                                      .chipselect
		input  wire        tmds_bit_clock_ratio_pio_external_connection_export,               //          tmds_bit_clock_ratio_pio_external_connection.export
		output wire        tx_hpd_ack_pio_external_connection_export,                         //                    tx_hpd_ack_pio_external_connection.export
		input  wire        tx_hpd_req_pio_external_connection_export,                         //                    tx_hpd_req_pio_external_connection.export
		output wire [8:0]  tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_address,           //       tx_iopll_rcfg_mgmt_translator_avalon_anti_slave.address
		output wire        tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_write,             //                                                      .write
		output wire        tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_read,              //                                                      .read
		input  wire [31:0] tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_readdata,          //                                                      .readdata
		output wire [31:0] tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_writedata,         //                                                      .writedata
		input  wire        tx_iopll_waitrequest_pio_external_connection_export,               //          tx_iopll_waitrequest_pio_external_connection.export
		output wire [1:0]  tx_os_pio_external_connection_export,                              //                         tx_os_pio_external_connection.export
		output wire [9:0]  tx_pll_rcfg_mgmt_translator_avalon_anti_slave_address,             //         tx_pll_rcfg_mgmt_translator_avalon_anti_slave.address
		output wire        tx_pll_rcfg_mgmt_translator_avalon_anti_slave_write,               //                                                      .write
		output wire        tx_pll_rcfg_mgmt_translator_avalon_anti_slave_read,                //                                                      .read
		input  wire [31:0] tx_pll_rcfg_mgmt_translator_avalon_anti_slave_readdata,            //                                                      .readdata
		output wire [31:0] tx_pll_rcfg_mgmt_translator_avalon_anti_slave_writedata,           //                                                      .writedata
		input  wire        tx_pll_rcfg_mgmt_translator_avalon_anti_slave_waitrequest,         //                                                      .waitrequest
		input  wire        tx_pll_waitrequest_pio_external_connection_export,                 //            tx_pll_waitrequest_pio_external_connection.export
		input  wire        tx_pma_cal_busy_pio_external_connection_export,                    //               tx_pma_cal_busy_pio_external_connection.export
		output wire [1:0]  tx_pma_ch_export,                                                  //                                             tx_pma_ch.export
		output wire [11:0] tx_pma_rcfg_mgmt_translator_avalon_anti_slave_address,             //         tx_pma_rcfg_mgmt_translator_avalon_anti_slave.address
		output wire        tx_pma_rcfg_mgmt_translator_avalon_anti_slave_write,               //                                                      .write
		output wire        tx_pma_rcfg_mgmt_translator_avalon_anti_slave_read,                //                                                      .read
		input  wire [31:0] tx_pma_rcfg_mgmt_translator_avalon_anti_slave_readdata,            //                                                      .readdata
		output wire [31:0] tx_pma_rcfg_mgmt_translator_avalon_anti_slave_writedata,           //                                                      .writedata
		input  wire        tx_pma_rcfg_mgmt_translator_avalon_anti_slave_waitrequest,         //                                                      .waitrequest
		input  wire        tx_pma_waitrequest_pio_external_connection_export,                 //            tx_pma_waitrequest_pio_external_connection.export
		output wire        tx_rcfg_en_pio_external_connection_export,                         //                    tx_rcfg_en_pio_external_connection.export
		output wire        tx_rst_pll_pio_external_connection_export,                         //                    tx_rst_pll_pio_external_connection.export
		output wire        tx_rst_xcvr_pio_external_connection_export,                        //                   tx_rst_xcvr_pio_external_connection.export
		output wire        wd_timer_resetrequest_reset                                        //                                 wd_timer_resetrequest.reset
	);
endmodule

