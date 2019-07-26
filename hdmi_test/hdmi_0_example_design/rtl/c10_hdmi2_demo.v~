// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



//`define SEPARATE_RCFG_INTF_EN
`ifdef SEPARATE_RCFG_INTF_EN
    `define SEPARATE_RCFG_INTF 1
`else
    `define SEPARATE_RCFG_INTF 0
`endif

module c10_hdmi2_demo (
    //Clocks Inputs
    input        c10_refclk2_p, // 100MHz

    input       refclk_emif_p,

    //User-IO
    output [3:0] user_led_g, 
    input  [2:0] user_pb,
    input        user_dipsw0,

    input       user_dipsw1,  
    input       user_dipsw2,  
    input       user_dipsw3,  
			    
    //FPGA Mezzanine Card (fmc)
    //XCVR Interface///
    input        fmc_gbtclk_m2c_p_0,             
    input  [2:0] fmc_dp_m2c_p,     
    output [3:0] fmc_dp_c2m_p,     

    //Cyclone 10 LDVS 
    inout       fmc_la_tx_p_11,
    inout       fmc_la_rx_n_9,	
    input       fmc_la_rx_p_9,
    inout       fmc_la_rx_p_8,     
    inout       fmc_la_rx_n_8, 
    input       fmc_la_tx_p_10, 
    input       fmc_la_tx_p_12,
    inout       fmc_la_tx_n_12,
    inout       fmc_la_rx_p_10,

    //EMIF interfaces
			output          ddr3_ckp           , // CKp
			output          ddr3_ckn           , // CKn
			inout   [39:0]  ddr3_d             , // Data
			output  [4:0]   ddr3_dm            , // DM
			inout   [4:0]   ddr3_dqsn          , // DQSn
			inout   [4:0]   ddr3_dqsp          , // DQSp
			output  [2:0]   ddr3_ba            , // BA
			output          ddr3_casn          , // CASn
			output          ddr3_rasn          , // RASn
			output  [14:0]  ddr3_a             , // ADDR
			output  [0:0]   ddr3_cke           , // CKe
			output  [0:0]   ddr3_odt           , // ODT
			output  [0:0]   ddr3_csn           , // CSn
			output          ddr3_wen           , // WEn
			output          ddr3_rstn          , // RESETn
			input           ddr3_rzq             // RZQ
    
);

/////////////////////////////////////////////////////
///////////////        TEST        //////////////////
/////////////////////////////////////////////////////

wire reset2;
wire wrst, rdst, calend, virtual_bt;
wire bt1, bt2;
reg [95:0] tx_data_sample;

wire issp_bramen;
wire [10:0] issp_addr;
issp issp (
	.source	({reset2, wrst, rdst, calend, bt1, bt2, issp_bramen, issp_addr}),
	.probe  ({bram_wren0, bram_wren1, bram_wren2, bram_wre3, bram_q0, bram_q1, bram_q2, bram_q3})
);

wire test_wr, test_rd;
wire [24:0] test_addr;
wire [6:0] test_burst;
test_ddr test_ddr (
	.emif_usr_clk	(emif_usr_clk),
	.rst	(reset2),
	.bt1	(bt1),
	.bt2	(bt2),
	.amm_ready (amm_ready),
	.amm_rd		(test_rd),
	.amm_wr		(test_wr),
	.amm_addr	(test_addr),
	.amm_burstcnt	(test_burst)
);




/////////////////////////////////////////////////////
///////////////        EMIF        //////////////////
/////////////////////////////////////////////////////
parameter burstlength = 3;

wire local_cal_success, local_cal_fail;
wire emif_usr_reset_n, emif_usr_clk;
wire amm_ready;
wire [319:0] amm_rddata;
wire amm_rddatavalild;

wire amm_rd, amm_wr;
wire [24:0] amm_addr;
//reg [319:0] amm_wrdata;
wire [319:0] amm_wrdata;// = {40{8'b0011_1111}};
wire [6:0] amm_burstcnt;
wire [39:0] amm_byteenable = 40'hff_ffff_ffff;


emif emif01(
			.global_reset_n		(~reset2), 	//in
			.pll_ref_clk			(refclk_emif_p),	//in
			.oct_rzqin				(ddr3_rzq),	//in
			
			.mem_ck					(ddr3_ckp),	//out
			.mem_ck_n				(ddr3_ckn),	//out
			.mem_a					(ddr3_a),	//out
			.mem_ba					(ddr3_ba),	//out
			.mem_cke					(ddr3_cke),	//out
			.mem_cs_n				(ddr3_csn),	//out
			.mem_odt					(ddr3_odt),	//out
			.mem_reset_n			(ddr3_rstn),	//out
			.mem_we_n				(ddr3_wen),	//out
			.mem_ras_n				(ddr3_rasn),	//out
			.mem_cas_n				(ddr3_casn),	//out
			.mem_dqs					(ddr3_dqsp),	//inout
			.mem_dqs_n				(ddr3_dqsn),	//inout
			.mem_dq					(ddr3_d),	//inout
			.mem_dm					(ddr3_dm),	//out
			.local_cal_success	(local_cal_success),	//out
			.local_cal_fail		(local_cal_fail),	//out
			
			
			.emif_usr_reset_n		(emif_usr_reset_n),	//out
			.emif_usr_clk			(emif_usr_clk),		//out
			.amm_ready_0			(amm_ready),	//out
			
			.amm_readdata_0		(amm_rddata),	//out
			.amm_readdatavalid_0	(amm_rddatavalid),	//out

			.amm_read_0				(amm_rd),	//in
			.amm_write_0			(amm_wr),	//in
			.amm_address_0			(amm_addr),	//in
			.amm_writedata_0		(amm_wrdata),	//in
			.amm_burstcount_0		(amm_burstcnt),	//in
			.amm_byteenable_0		(amm_byteenable)	//in
);


wire [24:0] wraddr, rdaddr;
wire [6:0] wrburst, rdburst;
wire wr, rd;

assign amm_wr = (bt1)? test_wr : wr;
assign amm_rd = (bt2)? test_rd : rd;
assign amm_addr =(test_rd)? test_addr: (amm_wr)? wraddr : (amm_rd)? rdaddr : 25'hz;
assign amm_burstcnt =(test_rd)? test_burst: (amm_wr)? wrburst : (amm_rd)? rdburst : 7'hz;


hdmi2ddr hdmi2ddr(
	.hdmiclk			(hdmi_tx_vid_clk),
	.ddrclk			(emif_usr_clk),
	.reset			(reset2),
	.DE				(hdmi_tx_de),
	.HS				(hdmi_tx_hsync),
	.VS				(hdmi_tx_vsync),
	.RxData			(hdmi_tx_data),
	.wr				(wr),
	.WrData			(amm_wrdata),
	.addr				(wraddr),
	.burst			(wrburst),
	.wrbt				(wrst)
);


//wire calend;
wire [23:0] bram_q0, bram_q1, bram_q2, bram_q3;
wire [23:0] bram_datain;
wire [10:0] bram_addr_wr;
wire bram_wren0, bram_wren1, bram_wren2, bram_wren3;
ddr2bram ddr2bram(
	.ddrclk			(emif_usr_clk),
	.reset			(reset2),
	.rdbt				(rdst),//!user_pb[2]),
	.RdData			(amm_rddata),
	.readvalid		(amm_rddatavalid),
	.calend			(calend),
	.rd				(rd),
	.addr				(rdaddr),
	.burst			(rdburst),
	.bram_datain	(bram_datain),
	.Bramaddr		(bram_addr_wr),
	.wren0			(bram_wren0),
	.wren1			(bram_wren1),
	.wren2			(bram_wren2),
	.wren3			(bram_wren3)

);


wire [10:0] bram_addr0, bram_addr1, bram_addr2, bram_addr3;
assign bram_addr0 = (bram_wren0)? bram_addr_wr : issp_addr;
assign bram_addr1 = (bram_wren1)? bram_addr_wr : issp_addr;
assign bram_addr2 = (bram_wren2)? bram_addr_wr : issp_addr;
assign bram_addr3 = (bram_wren3)? bram_addr_wr : issp_addr;
brams brams(
	.clk		(emif_usr_clk),
	.reset	(reset2),
	.bram_datain	(bram_datain),
	.bramaddr0		(bram_addr0),
	.bramaddr1		(bram_addr1),
	.bramaddr2		(bram_addr2),
	.bramaddr3		(bram_addr3),
	.wren0			(bram_wren0),
	.wren1			(bram_wren1),
	.wren2			(bram_wren2),
	.wren3			(bram_wren3),
	.q0				(bram_q0),
	.q1				(bram_q1),
	.q2				(bram_q2),
	.q3				(bram_q3)
);







/////////////////////////////////////////////////////
///////////////        HDMI        //////////////////
/////////////////////////////////////////////////////

localparam SYMBOLS_PER_CLOCK = 2;
localparam SUPPORT_AUDIO = 0;
localparam SUPPORT_AUXILIARY = 0;
localparam SUPPORT_DEEP_COLOR = 0;

//valid value: 4, 6, 11, 0 (no configuration change due to schematics)
localparam BITEC_DAUGHTER_CARD_REV = 11;

//Invert polarity due to the polarity inversion on the Bitec HDMI FMC daugther card, you should disable this if the polarity inversion is not required
localparam TX_POLARITY_INVERSION = (BITEC_DAUGHTER_CARD_REV==6 || BITEC_DAUGHTER_CARD_REV==4)? 1 : 
                                   (BITEC_DAUGHTER_CARD_REV==11)? 0 : 0;
	  
   
wire                                   sys_init;
wire                                   user_pb_0;
wire                                   user_pb_1;
wire                                   user_pb_2;
wire                                   user_dipsw_0;
wire                                   mgmt_clk_reset_sync;
wire [2:0]                             hdmi_rx_locked;
wire [SYMBOLS_PER_CLOCK*48-1:0]        hdmi_rx_data;
wire [SYMBOLS_PER_CLOCK-1:0]           hdmi_rx_vsync;
wire [SYMBOLS_PER_CLOCK-1:0]           hdmi_rx_hsync;
wire [SYMBOLS_PER_CLOCK-1:0]           hdmi_rx_de;
wire                                   hdmi_rx_vid_clk;
wire                                   hdmi_rx_ls_clk;
wire                                   hdmi_rx_iopll_locked;
wire                                   gxb_rx_ready;
wire [23:0]                            measure;
wire                                   measure_valid;
wire                                   rx_os;
wire [1:0]                             tx_os;
wire                                   tx_audio_de;
wire [255:0]                           tx_audio_data;
wire [47:0]                            tx_audio_info_ai;
wire [19:0]                            tx_audio_N;
wire [19:0]                            tx_audio_CTS;
wire [164:0]                           tx_audio_metadata;
wire [4:0]                             tx_audio_format;
wire [111:0]                           tx_info_avi;
wire [60:0]                            tx_info_vsi;
wire                                   TMDS_Bit_clock_Ratio;
wire                                   reset;
wire                                   hpd;
wire                                   rx_hpd;
wire                                   rx_hdmi_locked;
wire                                   rx_iopll_locked;
wire                                   rx_ready;
wire                                   tx_ready;
wire                                   tx_iopll_locked;
wire                                   tx_pll_locked;

wire                                   cpu_clk_reset_n;
wire                                   i2c_clk_reset_sync;
wire                                   tx_i2c_avalon_waitrequest;
wire  [2:0]                            tx_i2c_avalon_address;
wire  [7:0]                            tx_i2c_avalon_writedata;
wire  [7:0]                            tx_i2c_avalon_readdata;
wire                                   tx_i2c_avalon_chipselect;
wire                                   tx_i2c_avalon_write;
wire                                   tx_ti_i2c_avalon_waitrequest;
wire  [2:0]                            tx_ti_i2c_avalon_address;
wire  [7:0]                            tx_ti_i2c_avalon_writedata;
wire  [7:0]                            tx_ti_i2c_avalon_readdata;
wire                                   tx_ti_i2c_avalon_chipselect;
wire                                   tx_ti_i2c_avalon_write;
wire                                   tx_i2c_irq;
wire                                   tx_hpd_ack;
wire                                   tx_hpd_req;
wire  [23:0]                           reserve_writedata;


wire clk100;
wire i2c_clk;
assign clk100  = c10_refclk2_p;
assign i2c_clk = c10_refclk2_p;

				       
assign rx_hdmi_locked = &hdmi_rx_locked;
assign user_led_g[0]  = (rx_iopll_locked & rx_ready);
assign user_led_g[1]  = (rx_hdmi_locked);
assign user_led_g[2]  = (tx_iopll_locked & tx_ready & tx_pll_locked);
assign user_led_g[3]  = (rx_os & (|tx_os));
assign reset          = ~(user_pb_0);

wire tmds_clk_in;
wire hdmi_clk_in;
wire mgmt_clk;
assign tmds_clk_in = fmc_gbtclk_m2c_p_0;
assign hdmi_clk_in = tmds_clk_in;
assign mgmt_clk = clk100;

debouncer #(.CNTR_WIDTH(8)) u_debouncer0(.pb_in(user_pb[0]),.clk(clk100),.out(),.pb_out(user_pb_0));
debouncer #(.CNTR_WIDTH(8)) u_debouncer1(.pb_in(user_pb[1]),.clk(mgmt_clk),.out(),.pb_out(user_pb_1));

//
// HDMI RX video path and transceiver/PLL reconfig controller (master + slave)
//
wire [5:0]  tx_gcp;
wire [71:0] tx_aux_data;
wire        tx_aux_valid;
wire        tx_aux_sop;
wire        tx_aux_eop;

wire        rx_reconfig_mgmt_write;
wire        rx_reconfig_mgmt_read;
wire [11:0] rx_reconfig_mgmt_address;
wire [31:0] rx_reconfig_mgmt_writedata;
wire  [31:0] rx_reconfig_mgmt_readdata;
wire         rx_reconfig_mgmt_waitrequest;
wire [2:0]  gxb_rx_cal_busy_out;
wire        rx_reconfig_en;

wire [2:0] gxb_rx_reconfig_write;
wire [2:0] gxb_rx_reconfig_read;
wire [29:0] gxb_rx_reconfig_address;
wire [95:0] gxb_rx_reconfig_writedata;
wire [95:0] gxb_rx_reconfig_readdata;
wire [2:0] gxb_rx_reconfig_waitrequest;
wire [2:0]   gxb_rx_cal_busy_in;

wire        rx_mgmt_clk_reset;
wire [1:0]  color_depth_sync;

wire [7:0]  rx_edid_ram_address;
wire        rx_edid_ram_write;
wire        rx_edid_ram_read;
wire [7:0]  rx_edid_ram_readdata;
wire [7:0]  rx_edid_ram_writedata;
wire        rx_edid_ram_waitrequest;
wire        rx_edid_ram_access;
  
hdmi_rx_top #(
   .SUPPORT_DEEP_COLOR (SUPPORT_DEEP_COLOR),
   .SUPPORT_AUXILIARY (SUPPORT_AUXILIARY),
   .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK),
   .SUPPORT_AUDIO (SUPPORT_AUDIO),
   .BITEC_DAUGHTER_CARD_REV (BITEC_DAUGHTER_CARD_REV)
) u_hdmi_rx_top (
   /* I */ .reset (reset),
   /* I */ .mgmt_clk (mgmt_clk),
   /* I */ .hdmi_clk_in (hdmi_clk_in),
   /* I */ .tmds_clk_in (tmds_clk_in),
   /* O */ .vid_clk_out (hdmi_rx_vid_clk),
   /* O */ .ls_clk_out (hdmi_rx_ls_clk),		 
   /* O */ .iopll_locked (rx_iopll_locked),
   /* O */ .sys_init(sys_init),
   /* I */ .rx_serial_data (fmc_dp_m2c_p[2:0]),
   /* O */ .gxb_rx_ready (rx_ready),
   /* O */ .os (rx_os),		 
   /* O */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio), 
   /* O */ .colordepth_mgmt_sync (color_depth_sync),
   /* O */ .locked (hdmi_rx_locked),
   /* O */ .vid_data (hdmi_rx_data),
   /* O */ .vid_de (hdmi_rx_de),
   /* O */ .vid_hsync (hdmi_rx_hsync),
   /* O */ .vid_vsync (hdmi_rx_vsync),
   /* O */ .vid_lock (),
   /* I */ .in_5v_power ({~fmc_la_rx_p_9}), // Connect to +5v of HDMI connector
   /* I */ //.in_hpd (fmc_la_rx_p_8_tmp), // Connect to RX HPD of HDMI connector
   /* B */ .hdmi_rx_hpd_n (fmc_la_rx_p_8),
   /* I */ .user_pb_1 (user_pb_1),
   /* O */ .mode (),
   /* O */ .ctrl (),			     
   /* O */ .measure (measure),
   /* O */ .measure_valid (measure_valid),		 
   /* B */ .hdmi_rx_i2c_sda(fmc_la_rx_n_8),
   /* B */ .hdmi_rx_i2c_scl(fmc_la_tx_p_10),
   /* I */ .i2c_clk (i2c_clk),			 
   /* I */ //.scdc_i2c_addr (scdc_addr),
   /* O */ //.scdc_i2c_rdata (scdc_rdata),
   /* I */ //.scdc_i2c_wdata (scdc_wdata),
   /* I */ //.scdc_i2c_r (scdc_r),
   /* I */ //.scdc_i2c_w (scdc_w),
   
  /* O */ .reconfig_mgmt_write(rx_reconfig_mgmt_write),
  /* O */ .reconfig_mgmt_read(rx_reconfig_mgmt_read),
  /* O */ .reconfig_mgmt_address(rx_reconfig_mgmt_address),
  /* O */ .reconfig_mgmt_writedata(rx_reconfig_mgmt_writedata),
  /* I */ .reconfig_mgmt_readdata(rx_reconfig_mgmt_readdata),
  /* I */ .reconfig_mgmt_waitrequest(rx_reconfig_mgmt_waitrequest),
  /* O */ .gxb_rx_cal_busy_out(gxb_rx_cal_busy_out),
  /* O */ .rx_reconfig_en(rx_reconfig_en),

  /* I */ .gxb_reconfig_write(gxb_rx_reconfig_write),
  /* I */ .gxb_reconfig_read(gxb_rx_reconfig_read),
  /* I */ .gxb_reconfig_address(gxb_rx_reconfig_address),
  /* I */ .gxb_reconfig_writedata(gxb_rx_reconfig_writedata),
  /* O */ .gxb_reconfig_readdata(gxb_rx_reconfig_readdata),
  /* O */ .gxb_reconfig_waitrequest(gxb_rx_reconfig_waitrequest),
  /* I */ .gxb_rx_cal_busy_in(gxb_rx_cal_busy_in),
  
   /* I */ .edid_ram_access(rx_edid_ram_access),
   /* I */ .edid_ram_address (rx_edid_ram_address),
   /* I */ .edid_ram_write (rx_edid_ram_write),
   /* I */ .edid_ram_read (rx_edid_ram_read),
   /* O */ .edid_ram_readdata (rx_edid_ram_readdata),
   /* I */ .edid_ram_writedata (rx_edid_ram_writedata),
   /* O */ .edid_ram_waitrequest (rx_edid_ram_waitrequest)
);

//wire [7:0]  gnd8;
//wire        SYNTHESIZED_WIRE_0;
//wire        SYNTHESIZED_WIRE_1;
//wire [31:0] GDFX_TEMP_SIGNAL_3;
//wire [31:0] GDFX_TEMP_SIGNAL_4;
//assign gnd8 = 8'b00000000;
//assign SYNTHESIZED_WIRE_0 = edid_r | edid_w;
//assign SYNTHESIZED_WIRE_1 = scdc_r | scdc_w;
//assign GDFX_TEMP_SIGNAL_3 = {gnd8[7:0], edid_wdata[7:0], edid_rdata[7:0], edid_addr[7:0]};
//assign GDFX_TEMP_SIGNAL_4 = {gnd8[7:0], scdc_wdata[7:0], scdc_rdata[7:0], scdc_addr[7:0]};

//
// Qsys system for TX reconfig & I2C master (TX DDC)
// Placeholder for VIP passthrough system
//
wire                             tx_rst_pll;
wire                             tx_rst_xcvr;
wire                             wd_reset;
wire                             hdmi_tx_vid_clk;
wire                             hdmi_tx_ls_clk;
wire [48*SYMBOLS_PER_CLOCK-1:0]  hdmi_tx_data;
wire [1*SYMBOLS_PER_CLOCK-1:0]   hdmi_tx_vsync;
wire [1*SYMBOLS_PER_CLOCK-1:0]   hdmi_tx_hsync;
wire [1*SYMBOLS_PER_CLOCK-1:0]   hdmi_tx_de;
//wire [1:0]                       color_depth_sync;
wire [9:0]                       tx_pll_reconfig_mgmt_address;
wire                             tx_pll_reconfig_mgmt_waitrequest;
wire                             tx_pll_reconfig_mgmt_write;
wire [31:0]                      tx_pll_reconfig_mgmt_writedata;
wire                             tx_pll_reconfig_mgmt_read;
wire [31:0]                      tx_pll_reconfig_mgmt_readdata;
wire [8:0]                       tx_iopll_reconfig_mgmt_address;
wire                             tx_iopll_reconfig_mgmt_waitrequest;
wire                             tx_iopll_reconfig_mgmt_write;
wire [31:0]                      tx_iopll_reconfig_mgmt_writedata;
wire                             tx_iopll_reconfig_mgmt_read;
wire [31:0]                      tx_iopll_reconfig_mgmt_readdata;

wire [9:0] tx_pma_rcfg_mgmt_address;
wire [11:0] tx_pma_rcfg_mgmt_translator_avalon_anti_slave_address;
wire        tx_pma_rcfg_mgmt_write;
wire        tx_pma_rcfg_mgmt_read;
wire [31:0] tx_pma_rcfg_mgmt_readdata;
wire [31:0] tx_pma_rcfg_mgmt_writedata;
wire        tx_pma_rcfg_mgmt_waitrequest;
wire        tx_reconfig_en;
wire [1:0]  tx_pma_ch;
		
		
//wire [3*8*SYMBOLS_PER_CLOCK-1:0] cvi_data_in;
//wire [3*8*SYMBOLS_PER_CLOCK-1:0] cvo_data_out;
wire [47:0] cvo_data_out;
wire [1:0]  cvo_de;
wire [1:0]  cvo_vsync;
wire [1:0]  cvo_hsync;
wire [3:0]  gxb_tx_cal_busy_in;

assign cpu_clk_reset_n = ~(reset | wd_reset | sys_init);

nios u_nios (
   /* I */ .cpu_clk (clk100),
   /* I */ //.cpu_clk_reset_n (user_pb_0 & ~wd_reset & ~sys_init), 
   /* I */ .cpu_clk_reset_n (cpu_clk_reset_n),
   /* B */ //.oc_i2c_master_0_conduit_start_scl_pad_io (fmc_la_rx_p_10),
   /* B */ //.oc_i2c_master_0_conduit_start_sda_pad_io (fmc_la_tx_n_12), 
   /* I */ .tmds_bit_clock_ratio_pio_external_connection_export (TMDS_Bit_clock_Ratio), 				     
   /* I */ .measure_pio_external_connection_export (measure),
   /* I */ //.measure_valid_pio_external_connection_export (measure_valid & (hdmi_rx_locked_sync)),
   /* I */ .measure_valid_pio_external_connection_export (measure_valid),

   /* O */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_address (tx_i2c_avalon_address),
   /* O */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_write (tx_i2c_avalon_write),
   /* I */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_readdata ({24'd0, tx_i2c_avalon_readdata}),
   /* O */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_writedata ({reserve_writedata,tx_i2c_avalon_writedata}),
   /* I */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_waitrequest (tx_i2c_avalon_waitrequest),
   /* O */ .oc_i2c_master_av_slave_translator_avalon_anti_slave_0_chipselect (tx_i2c_avalon_chipselect) ,
  
   /* O */ .oc_i2c_master_ti_avalon_anti_slave_address (tx_ti_i2c_avalon_address),
   /* O */ .oc_i2c_master_ti_avalon_anti_slave_write (tx_ti_i2c_avalon_write),
   /* I */ .oc_i2c_master_ti_avalon_anti_slave_readdata ({24'd0, tx_ti_i2c_avalon_readdata}),
   /* O */ .oc_i2c_master_ti_avalon_anti_slave_writedata ({reserve_writedata,tx_ti_i2c_avalon_writedata}),
   /* I */ .oc_i2c_master_ti_avalon_anti_slave_waitrequest (tx_ti_i2c_avalon_waitrequest),
   /* O */ .oc_i2c_master_ti_avalon_anti_slave_chipselect (tx_ti_i2c_avalon_chipselect) ,
  
   /* O */ .edid_ram_access_pio_external_connection_export(rx_edid_ram_access),
   /* O */ .edid_ram_slave_translator_address (rx_edid_ram_address),
   /* O */ .edid_ram_slave_translator_write (rx_edid_ram_write),
   /* O */ .edid_ram_slave_translator_read (rx_edid_ram_read),
   /* I */ .edid_ram_slave_translator_readdata (rx_edid_ram_readdata),
   /* O */ .edid_ram_slave_translator_writedata (rx_edid_ram_writedata),
   /* I */ .edid_ram_slave_translator_waitrequest (rx_edid_ram_waitrequest),

   /* I */ .color_depth_pio_external_connection_export (color_depth_sync),	
   /* I */ .tx_iopll_waitrequest_pio_external_connection_export (tx_iopll_reconfig_mgmt_waitrequest),
   /* I */ .tx_pll_waitrequest_pio_external_connection_export (tx_pll_reconfig_mgmt_waitrequest),
   /* I */ .tx_hpd_req_pio_external_connection_export (tx_hpd_req),
   /* O */ .tx_hpd_ack_pio_external_connection_export (tx_hpd_ack),					     
   /* I */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_waitrequest (tx_pll_reconfig_mgmt_waitrequest),
   /* O */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_writedata (tx_pll_reconfig_mgmt_writedata),
   /* O */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_address (tx_pll_reconfig_mgmt_address),
   /* O */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_write (tx_pll_reconfig_mgmt_write),
   /* O */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_read (tx_pll_reconfig_mgmt_read),
   /* I */ .tx_pll_rcfg_mgmt_translator_avalon_anti_slave_readdata (tx_pll_reconfig_mgmt_readdata),					     
   /* O */ .tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_writedata (tx_iopll_reconfig_mgmt_writedata),
   /* O */ .tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_address (tx_iopll_reconfig_mgmt_address),
   /* O */ .tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_write (tx_iopll_reconfig_mgmt_write),
   /* O */ .tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_read (tx_iopll_reconfig_mgmt_read),
   /* I */ .tx_iopll_rcfg_mgmt_translator_avalon_anti_slave_readdata (tx_iopll_reconfig_mgmt_readdata),
   
   /* O */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_address(tx_pma_rcfg_mgmt_translator_avalon_anti_slave_address),
   /* O */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_write(tx_pma_rcfg_mgmt_write),
   /* O */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_read(tx_pma_rcfg_mgmt_read),
   /* I */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_readdata(tx_pma_rcfg_mgmt_readdata),
   /* O */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_writedata(tx_pma_rcfg_mgmt_writedata),
   /* I */ .tx_pma_rcfg_mgmt_translator_avalon_anti_slave_waitrequest(tx_pma_rcfg_mgmt_waitrequest),
   /* I */ .tx_pma_waitrequest_pio_external_connection_export(tx_pma_rcfg_mgmt_waitrequest),
   /* I */ .tx_pma_cal_busy_pio_external_connection_export( {|gxb_tx_cal_busy_in} ),
   /* O */ .tx_pma_ch_export(tx_pma_ch),
   
   /* O */ .tx_rcfg_en_pio_external_connection_export(tx_reconfig_en),
   /* O */ .tx_os_pio_external_connection_export (tx_os),
   /* O */ .tx_rst_pll_pio_external_connection_export (tx_rst_pll),
   /* O */ .tx_rst_xcvr_pio_external_connection_export (tx_rst_xcvr),
   /* O */ .wd_timer_resetrequest_reset (wd_reset)
);

//wire [21:0] CTS_audio;
wire [3:0]  tx_serial_data;  

wire [3:0]    gxb_tx_reconfig_write;
wire [3:0]    gxb_tx_reconfig_read;
wire [39:0]   gxb_tx_reconfig_address;
wire [127:0]  gxb_tx_reconfig_writedata;
wire [127:0]  gxb_tx_reconfig_readdata;
wire [3:0]    gxb_tx_reconfig_waitrequest;
wire [3:0]    gxb_tx_cal_busy_out;

wire          tx_reset_pll_reconfig;
assign tx_reset_pll_reconfig = sys_init | wd_reset;

debouncer #(.CNTR_WIDTH(8)) u_debouncer2(.pb_in(user_pb[2]),.clk(hdmi_tx_ls_clk),.out(),.pb_out(user_pb_2));
debouncer #(.CNTR_WIDTH(8)) u_debouncer3(.pb_in(user_dipsw0),.clk(hdmi_tx_ls_clk),.out(),.pb_out(user_dipsw_0));


hdmi_tx_top #(
   .SUPPORT_DEEP_COLOR (SUPPORT_DEEP_COLOR),
   .SUPPORT_AUXILIARY (SUPPORT_AUXILIARY),
   .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK),
   .SUPPORT_AUDIO (SUPPORT_AUDIO),
   .POLARITY_INVERSION (TX_POLARITY_INVERSION),
   .BITEC_DAUGHTER_CARD_REV (BITEC_DAUGHTER_CARD_REV)
) u_hdmi_tx_top (
   /* I */ .mgmt_clk (mgmt_clk),
   /* I */ .reset (reset),
   /* I */ .hdmi_clk_in (hdmi_clk_in),
   /* O */ .vid_clk_out (hdmi_tx_vid_clk),
   /* O */ .ls_clk_out (hdmi_tx_ls_clk),		 
   /* O */ .iopll_locked (tx_iopll_locked),
   /* O */ .txpll_locked (tx_pll_locked),
   /* O */ .gxb_tx_ready (tx_ready),
   /* I */ .reset_xcvr (tx_rst_xcvr),  
   /* I */ .reset_pll (tx_rst_pll),  
   /* I */ //.reset_pll_reconfig (sys_init | wd_reset), 
   /* I */ .reset_pll_reconfig (tx_reset_pll_reconfig),
   /* I */ .sys_init (sys_init),

   /* O */ .tx_i2c_avalon_waitrequest (tx_i2c_avalon_waitrequest),
   /* I */ .tx_i2c_avalon_address (tx_i2c_avalon_address),
   /* I */ .tx_i2c_avalon_writedata (tx_i2c_avalon_writedata),
   /* O */ .tx_i2c_avalon_readdata (tx_i2c_avalon_readdata),
   /* I */ .tx_i2c_avalon_chipselect (tx_i2c_avalon_chipselect),
   /* I */ .tx_i2c_avalon_write (tx_i2c_avalon_write),
   /* O */ .tx_i2c_irq ( ),
	
   /* O */ .tx_ti_i2c_avalon_waitrequest (tx_ti_i2c_avalon_waitrequest),
   /* I */ .tx_ti_i2c_avalon_address (tx_ti_i2c_avalon_address),
   /* I */ .tx_ti_i2c_avalon_writedata (tx_ti_i2c_avalon_writedata),
   /* O */ .tx_ti_i2c_avalon_readdata (tx_ti_i2c_avalon_readdata),
   /* I */ .tx_ti_i2c_avalon_chipselect (tx_ti_i2c_avalon_chipselect),
   /* I */ .tx_ti_i2c_avalon_write (tx_ti_i2c_avalon_write),
   /* O */ .tx_ti_i2c_irq ( ),

   /* O */ .tx_serial_data (tx_serial_data[3:0]),		 
   /* I */ //.gxb_reconfig_write (tx_gxb_reconfig_mgmt_write),
   /* I */ //.gxb_reconfig_read (tx_gxb_reconfig_mgmt_read),
   /* I */ //.gxb_reconfig_address (tx_gxb_reconfig_mgmt_address),
   /* I */ //.gxb_reconfig_writedata (tx_gxb_reconfig_mgmt_writedata),
   /* O */ //.gxb_reconfig_readdata (tx_gxb_reconfig_mgmt_readdata),
   /* O */ //.gxb_reconfig_waitrequest (tx_gxb_reconfig_mgmt_waitrequest),
   /* I */ .tx_pll_reconfig_write (tx_pll_reconfig_mgmt_write),
   /* I */ .tx_pll_reconfig_read (tx_pll_reconfig_mgmt_read),
   /* I */ .tx_pll_reconfig_address (tx_pll_reconfig_mgmt_address),
   /* I */ .tx_pll_reconfig_writedata (tx_pll_reconfig_mgmt_writedata),
   /* O */ .tx_pll_reconfig_readdata (tx_pll_reconfig_mgmt_readdata),
   /* O */ .tx_pll_reconfig_waitrequest (tx_pll_reconfig_mgmt_waitrequest),
   /* I */ .pll_reconfig_write (tx_iopll_reconfig_mgmt_write),
   /* I */ .pll_reconfig_read (tx_iopll_reconfig_mgmt_read),
   /* I */ .pll_reconfig_address (tx_iopll_reconfig_mgmt_address),
   /* I */ .pll_reconfig_writedata (tx_iopll_reconfig_mgmt_writedata),
   /* O */ .pll_reconfig_readdata (tx_iopll_reconfig_mgmt_readdata),
   /* O */ .pll_reconfig_waitrequest (tx_iopll_reconfig_mgmt_waitrequest),
   /* I */ .os (tx_os), 
   /* I */ .mode (user_dipsw_0), 
   /* I */ .ctrl ({SYMBOLS_PER_CLOCK{6'd0}}),					
   /* I */ .vid_data (hdmi_tx_data), // use tpg: hdmi_tx_data_from_cvo    
   /* I */ .vid_de (hdmi_tx_de), // use tpg: hdmi_tx_de_from_cvo
   /* I */ .vid_hsync (hdmi_tx_hsync), // use tpg: hdmi_tx_hsync_from_cvo
   /* I */ .vid_vsync (hdmi_tx_vsync), // use tpg: hdmi_tx_vsync_from_cvo
   /* I */ .Scrambler_Enable (TMDS_Bit_clock_Ratio), 
   /* I */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio),

   /* I */ .tx_hpd_ack (tx_hpd_ack), 
   /* O */ .tx_hpd_req (tx_hpd_req), 
   /* I */ .hdmi_tx_hpd_n (fmc_la_tx_p_12), 
   /* B */ .hdmi_tx_i2c_sda (fmc_la_tx_n_12),
   /* B */ .hdmi_tx_i2c_scl (fmc_la_rx_p_10),
  
   /* B */ .hdmi_tx_ti_i2c_sda (fmc_la_tx_p_11),
   /* B */ .hdmi_tx_ti_i2c_scl (fmc_la_rx_n_9),
  
   /* O */ .gxb_tx_cal_busy_out(gxb_tx_cal_busy_out),
   /* I */ .gxb_reconfig_write(gxb_tx_reconfig_write),
   /* I */ .gxb_reconfig_read(gxb_tx_reconfig_read),
   /* I */ .gxb_reconfig_address(gxb_tx_reconfig_address),
   /* I */ .gxb_reconfig_writedata(gxb_tx_reconfig_writedata),
   /* O */ .gxb_reconfig_readdata(gxb_tx_reconfig_readdata),
   /* O */ .gxb_reconfig_waitrequest(gxb_tx_reconfig_waitrequest),
   /* I */ .gxb_tx_cal_busy_in(gxb_tx_cal_busy_in)
);

assign fmc_dp_c2m_p = tx_serial_data;

localparam LANES = 4;
localparam DPRIO_ADDRESS_WIDTH = 10;
localparam DPRIO_DATA_WIDTH = 32;
wire [LANES-1:0]                         reconfig_write;
wire [LANES-1:0]                         reconfig_read;
wire [(LANES*DPRIO_ADDRESS_WIDTH)-1:0]   reconfig_address;
wire [(LANES*DPRIO_DATA_WIDTH)-1:0]      reconfig_writedata;
wire [LANES-1:0]                         rx_reconfig_cal_busy;

xcvr_reconfig_arbiter #(
    .LANES(LANES),
    .DPRIO_ADDRESS_WIDTH(DPRIO_ADDRESS_WIDTH), 
    .DPRIO_DATA_WIDTH(DPRIO_DATA_WIDTH),
    .EXPIRED_COUNTER(32'h042C1D80)       // 700ms
) u_c10_reconfig_arbiter_inst(
    /* I */ .clk(mgmt_clk),            // This should be the same 100MHz clock driving the reconfig controller
    /* I */ .reset(reset),          // This should be the same reset driving the reconfig controller
    /* I */ .rx_rcfg_en(rx_reconfig_en),
    /* I */ .tx_rcfg_en(tx_reconfig_en), 
    /* I */ .rx_rcfg_ch(rx_reconfig_mgmt_address[11:10]),
    /* I */ .tx_rcfg_ch(tx_pma_ch),
    /* I */ .rx_reconfig_mgmt_write(rx_reconfig_mgmt_write),
    /* I */ .rx_reconfig_mgmt_read(rx_reconfig_mgmt_read),
    /* I */ .rx_reconfig_mgmt_address(rx_reconfig_mgmt_address[9:0]),
    /* I */ .rx_reconfig_mgmt_writedata(rx_reconfig_mgmt_writedata),
    /* O */ .rx_reconfig_mgmt_readdata(rx_reconfig_mgmt_readdata),
    /* O */ .rx_reconfig_mgmt_waitrequest(rx_reconfig_mgmt_waitrequest),

    /* I */ .tx_reconfig_mgmt_write(tx_pma_rcfg_mgmt_write),
    /* I */ .tx_reconfig_mgmt_read(tx_pma_rcfg_mgmt_read),
    /* I */ .tx_reconfig_mgmt_address(tx_pma_rcfg_mgmt_address[9:0]),
    /* I */ .tx_reconfig_mgmt_writedata(tx_pma_rcfg_mgmt_writedata),
    /* O */ .tx_reconfig_mgmt_readdata(tx_pma_rcfg_mgmt_readdata),
    /* O */ .tx_reconfig_mgmt_waitrequest(tx_pma_rcfg_mgmt_waitrequest),
      
    /* O */ .reconfig_write(reconfig_write),
    /* O */ .reconfig_read(reconfig_read),
    /* O */ .reconfig_address(reconfig_address),
    /* O */ .reconfig_writedata(reconfig_writedata),

    /* I */ .rx_reconfig_readdata({32'd0, gxb_rx_reconfig_readdata}),
    /* I */ .rx_reconfig_waitrequest({1'd0, gxb_rx_reconfig_waitrequest}),
    /* I */ .tx_reconfig_readdata(gxb_tx_reconfig_readdata),
    /* I */ .tx_reconfig_waitrequest(gxb_tx_reconfig_waitrequest),

    /* I */ .rx_cal_busy({1'b0, gxb_rx_cal_busy_out}),
    /* I */ .tx_cal_busy(gxb_tx_cal_busy_out),
    /* O */ .rx_reconfig_cal_busy(rx_reconfig_cal_busy),
    /* O */ .tx_reconfig_cal_busy(gxb_tx_cal_busy_in)
);

assign tx_pma_rcfg_mgmt_address = tx_pma_rcfg_mgmt_translator_avalon_anti_slave_address[11:2];

assign gxb_rx_reconfig_write = reconfig_write[2:0];
assign gxb_rx_reconfig_read = reconfig_read[2:0];
assign gxb_rx_reconfig_address = reconfig_address[29:0];
assign gxb_rx_reconfig_writedata = reconfig_writedata[95:0];
assign gxb_rx_cal_busy_in = rx_reconfig_cal_busy[2:0];

assign gxb_tx_reconfig_write = reconfig_write[3:0];
assign gxb_tx_reconfig_read = reconfig_read[3:0];
assign gxb_tx_reconfig_address = reconfig_address[39:0];
assign gxb_tx_reconfig_writedata = reconfig_writedata[127:0];


///new block
rxtx_link #(
   .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK)
) u_rxtx_link (

   /* I */  .reset(reset),
   /* I */  .mgmt_clk(mgmt_clk),
   /* I */  .i2c_clk(i2c_clk),
   /* I */  .hdmi_tx_ls_clk(hdmi_tx_ls_clk),
   /* I */  .hdmi_rx_ls_clk(hdmi_rx_ls_clk),
   /* I */  .hdmi_tx_vid_clk(hdmi_tx_vid_clk),
   /* I */  .hdmi_rx_vid_clk(hdmi_rx_vid_clk),
   /* I */  .hdmi_rx_locked(hdmi_rx_locked),
   /* I */  .user_pb_2 (user_pb_2),

   /* I */  .hdmi_rx_de(hdmi_rx_de),
   /* I */  .hdmi_rx_hsync(hdmi_rx_hsync),
   /* I */  .hdmi_rx_vsync(hdmi_rx_vsync),
   /* I */  .hdmi_rx_data(hdmi_rx_data),
   /* O */ .hdmi_tx_de(hdmi_tx_de),
   /* O */ .hdmi_tx_hsync(hdmi_tx_hsync),
   /* O */ .hdmi_tx_vsync(hdmi_tx_vsync),
   /* O */ .hdmi_tx_data(hdmi_tx_data),
   /* O */ .tx_audio_format(tx_audio_format),
   /* O */ .tx_audio_metadata(tx_audio_metadata),
   /* O */ .tx_audio_info_ai(tx_audio_info_ai),
   /* O */ .tx_audio_CTS(tx_audio_CTS),
   /* O */ .tx_audio_N(tx_audio_N),
   /* O */ .tx_audio_de(tx_audio_de),
   /* O */ .tx_audio_data(tx_audio_data),
   /* O */ .tx_gcp(tx_gcp),
   /* O */ .tx_info_avi(tx_info_avi),
   /* O */ .tx_info_vsi(tx_info_vsi),
   /* O */ .tx_aux_eop(tx_aux_eop),
   /* O */ .tx_aux_sop(tx_aux_sop),
   /* O */ .tx_aux_valid(tx_aux_valid),
   /* O */ .tx_aux_data(tx_aux_data),

   /* I */ .sys_init(sys_init),
   /* I */ .wd_reset(wd_reset)

);

        
endmodule


