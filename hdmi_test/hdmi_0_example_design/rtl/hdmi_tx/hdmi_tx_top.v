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



module hdmi_tx_top #(
   parameter USE_FPLL                = 1,
   parameter SUPPORT_DEEP_COLOR      = 0,
   parameter SUPPORT_AUXILIARY       = 0,
   parameter SYMBOLS_PER_CLOCK       = 2,
   parameter SUPPORT_AUDIO           = 0,
   parameter POLARITY_INVERSION      = 1,
   parameter BITEC_DAUGHTER_CARD_REV = 6
) (
   // Clock, reset & PLL locked signals 
   input  wire                                    mgmt_clk,
   input  wire                                    reset,      
   input  wire                                    hdmi_clk_in,
   output wire                                    vid_clk_out,
   output wire                                    ls_clk_out,   
   output wire                                    iopll_locked,    
   input  wire                                    reset_xcvr,
   input  wire                                    reset_pll,
   input  wire                                    reset_pll_reconfig,
   input  wire                                    sys_init,
   //i2c slave avalon 
   output wire                                    tx_i2c_avalon_waitrequest,
   input  wire [2:0]                              tx_i2c_avalon_address,
   input  wire [7:0]                              tx_i2c_avalon_writedata, 
   output wire [7:0]                              tx_i2c_avalon_readdata, 
   input  wire                                    tx_i2c_avalon_chipselect,
   input  wire                                    tx_i2c_avalon_write,
   output wire                                    tx_i2c_irq,
	
   output wire                                    tx_ti_i2c_avalon_waitrequest,
   input  wire [2:0]                              tx_ti_i2c_avalon_address,
   input  wire [7:0]                              tx_ti_i2c_avalon_writedata, 
   output wire [7:0]                              tx_ti_i2c_avalon_readdata, 
   input  wire                                    tx_ti_i2c_avalon_chipselect,
   input  wire                                    tx_ti_i2c_avalon_write,
   output wire                                    tx_ti_i2c_irq,
	

   // GXB TX signals
   //input  wire                                    gxb_reconfig_write,
   //input  wire                                    gxb_reconfig_read,
   //input  wire [11:0]                             gxb_reconfig_address,
   //input  wire [31:0]                             gxb_reconfig_writedata,
   //output wire [31:0]                             gxb_reconfig_readdata,
   //output wire                                    gxb_reconfig_waitrequest,
   output wire [3:0]                              tx_serial_data,
   output wire                                    txpll_locked,
   output wire                                    gxb_tx_ready,	
   // GXB ATX PLL reconfig signals
   input  wire                                    tx_pll_reconfig_write,
   input  wire                                    tx_pll_reconfig_read,
   input  wire [9:0]                              tx_pll_reconfig_address,
   input  wire [31:0]                             tx_pll_reconfig_writedata,
   output wire [31:0]                             tx_pll_reconfig_readdata,
   output wire                                    tx_pll_reconfig_waitrequest,   
   // PLL reconfig signals 
   input  wire                                    pll_reconfig_write,
   input  wire                                    pll_reconfig_read,
   input  wire [8:0]                              pll_reconfig_address,
   input  wire [31:0]                             pll_reconfig_writedata,
   output wire [31:0]                             pll_reconfig_readdata,
   output wire                                    pll_reconfig_waitrequest,  
   // HDMI core signals
   input  wire [1:0]                              os,
   input  wire                                    mode,
   input  wire [6*SYMBOLS_PER_CLOCK-1:0]          ctrl,
   input  wire [48*SYMBOLS_PER_CLOCK-1:0]         vid_data,
   input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_vsync, 
   input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_hsync,
   input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_de,
   input  wire                                    Scrambler_Enable,   
   input  wire                                    TMDS_Bit_clock_Ratio,
   input  wire                                    tx_hpd_ack,
   output wire                                    tx_hpd_req,
   input  wire                                    hdmi_tx_hpd_n,
   inout  wire                                    hdmi_tx_i2c_sda,
   inout  wire                                    hdmi_tx_i2c_scl,
	
   inout  wire                                    hdmi_tx_ti_i2c_sda,
   inout  wire                                    hdmi_tx_ti_i2c_scl,

   
   output wire [3:0]  gxb_tx_cal_busy_out,
   input wire  [3:0]  gxb_reconfig_write,
   input wire  [3:0]  gxb_reconfig_read,
   input wire  [39:0] gxb_reconfig_address,
   input wire  [127:0] gxb_reconfig_writedata,
   output wire [127:0] gxb_reconfig_readdata,
   output wire [3:0]  gxb_reconfig_waitrequest,
   input wire  [3:0]  gxb_tx_cal_busy_in
);

//
// Reset synchronizers
//
wire reset_sync;
altera_reset_controller #(
   .NUM_RESET_INPUTS          (2),
   .SYNC_DEPTH                (3),
   .RESET_REQ_WAIT_TIME       (1),
   .MIN_RST_ASSERTION_TIME    (3),
   .RESET_REQ_EARLY_DSRT_TIME (1)
) u_reset_sync (
   /* I */ .reset_in0 (reset),
   /* I */ .reset_in1 (sys_init),
   /* I */ .clk (mgmt_clk),
   /* O */ .reset_out (reset_sync)
);

//
// Placeholder for next revision of Bitec HDMI 2.0 FMC daughter card
// The current version (Rev2) of daughter card has level shifter issue
// Hot-plug activity between FPGA source and external sink for 2.0 rate is
// expected to not work reliably for Rev2
//
// Detect the TX HPD event and instruct NIOS to resend SCDC bit for 2.0 rate
//
wire hdmi_tx_hpd;
assign hdmi_tx_hpd = ~hdmi_tx_hpd_n;
reg [23:0] tx_unplug_count = 24'd0;
reg [23:0] tx_plug_count = 24'd0;
reg tx_hpd_req_int = 1'b0;
reg power_up = 1'b1;

//wire tx_hpd_ack;
always @ (posedge mgmt_clk or posedge reset_sync)
begin
    if(reset_sync) begin
        tx_unplug_count <= 24'd0;
        tx_plug_count <= 24'd0;
        tx_hpd_req_int <= 1'b0;

    end else begin
        if (~hdmi_tx_hpd && (tx_unplug_count < 24'd1000_0000)) begin
            tx_unplug_count <= tx_unplug_count + 24'd1;
        end else if (tx_hpd_ack | (hdmi_tx_hpd && (tx_unplug_count < 24'd1000_0000))) begin
            tx_unplug_count <= 24'd0;
        end
        
        if (hdmi_tx_hpd && ((tx_unplug_count > 24'd999_9999) || power_up)) begin
            if (hdmi_tx_hpd && (tx_plug_count < 24'd10000)) begin
                tx_plug_count <= tx_plug_count + 24'd1;
            end else if (~hdmi_tx_hpd | tx_hpd_ack) begin
                tx_plug_count <= 24'd0;
            end
        end 

        if (hdmi_tx_hpd && (tx_plug_count > 24'd9999)) begin
            tx_hpd_req_int <= 1'b1;
        end else if (tx_hpd_ack) begin
            tx_hpd_req_int <= 1'b0;
            power_up <= 1'd0;
        end
    end
end
assign tx_hpd_req = tx_hpd_req_int;

// moved the i2c_master from NIOS-II qsys to TX top
wire tx_i2c_avalon_waitrequestn;
assign tx_i2c_avalon_waitrequest = ~tx_i2c_avalon_waitrequestn;

oc_i2c_master u_oc_i2c_master (
    /* B */ .scl_pad_io (hdmi_tx_i2c_scl ),
    /* B */ .sda_pad_io (hdmi_tx_i2c_sda ),
    /* O */ .wb_ack_o (tx_i2c_avalon_waitrequestn ),
    /* I */ .wb_adr_i  (tx_i2c_avalon_address ),
    /* I */ .wb_clk_i (mgmt_clk ),
    /* I */ .wb_dat_i (tx_i2c_avalon_writedata ),
    /* O */ .wb_dat_o (tx_i2c_avalon_readdata ),
    /* I */ //.wb_rst_i (reset_sync | wd_reset | sys_init ),
    /* I */ .wb_rst_i (reset_sync | reset_pll_reconfig ),
    /* I */ .wb_stb_i (tx_i2c_avalon_chipselect ),
    /* I */ .wb_we_i (tx_i2c_avalon_write ),
    /* O */ .wb_inta_o (tx_i2c_irq )
  );
  
wire tx_ti_i2c_avalon_waitrequestn;
assign tx_ti_i2c_avalon_waitrequest = ~tx_ti_i2c_avalon_waitrequestn;

oc_i2c_master u_oc_ti_i2c_master (
    /* B */ .scl_pad_io (hdmi_tx_ti_i2c_scl ),
    /* B */ .sda_pad_io (hdmi_tx_ti_i2c_sda ),
    /* O */ .wb_ack_o (tx_ti_i2c_avalon_waitrequestn ),
    /* I */ .wb_adr_i  (tx_ti_i2c_avalon_address ),
    /* I */ .wb_clk_i (mgmt_clk ),
    /* I */ .wb_dat_i (tx_ti_i2c_avalon_writedata ),
    /* O */ .wb_dat_o (tx_ti_i2c_avalon_readdata ),
    /* I */ //.wb_rst_i (reset_sync | wd_reset | sys_init ),
    /* I */ .wb_rst_i (reset_sync | reset_pll_reconfig ),
    /* I */ .wb_stb_i (tx_ti_i2c_avalon_chipselect ),
    /* I */ .wb_we_i (tx_ti_i2c_avalon_write ),
    /* O */ .wb_inta_o (tx_ti_i2c_irq )
  );


// Tx Native PHY Transceiver
wire [3:0]  tx_analogreset;
wire [5:0]  tx_bonding_clocks;
wire [3:0]  tx_digitalreset;
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_parallel_data;
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_parallel_data_i;
wire [3:0]  tx_clk;

// Add registers to relax fitting
wire [SYMBOLS_PER_CLOCK*10-1:0] r,g,b,c;
generate 
if(BITEC_DAUGHTER_CARD_REV==11) begin : BITEC_TX_MAP
  assign {r,g,b,c} = tx_parallel_data_i;
  assign tx_parallel_data = {c,b,g,r};
end else if (BITEC_DAUGHTER_CARD_REV==4 || BITEC_DAUGHTER_CARD_REV==6) begin
  assign {r,g,b,c} = tx_parallel_data_i;
  assign tx_parallel_data = {r,g,b,c};
end else begin
  assign {r,g,b,c} = tx_parallel_data_i;
  assign tx_parallel_data = {r,g,b,c};
end
endgenerate
   
gxb_tx u_gxb_tx (
  /* I */ .reconfig_write (gxb_reconfig_write),
  /* I */ .reconfig_read (gxb_reconfig_read),
  /* I */ .reconfig_address (gxb_reconfig_address),
  /* I */ .reconfig_writedata (gxb_reconfig_writedata),
  /* O */ .reconfig_readdata (gxb_reconfig_readdata),
  /* O */ .reconfig_waitrequest (gxb_reconfig_waitrequest),
  /* I */ .reconfig_clk ({4{mgmt_clk}}), 
  /* I */ .reconfig_reset ({4{reset_sync}}), 
  /* I */ .tx_analogreset (tx_analogreset),
  /* I */ .tx_bonding_clocks ({4{tx_bonding_clocks}}),		 
  /* O */ .tx_cal_busy (gxb_tx_cal_busy_out),
  /* O */ .tx_clkout (tx_clk),
  /* I */ .tx_coreclkin ({4{tx_clk[0]}}),
  /* I */ .tx_polinv ({(POLARITY_INVERSION)? 4'b1111 : 4'b0000}),
  /* I */ .tx_digitalreset (tx_digitalreset),
  /* I */ .tx_parallel_data (tx_parallel_data), 
  /* O */ .tx_serial_data (tx_serial_data),
  /* I */ .unused_tx_parallel_data ()
);
   
// Tx Transceiver Reset Controller
wire       tx_plllocked;
wire       tx_pll_powerdown;
wire [3:0] tx_ready;
wire [3:0] tx_cal_busy;
wire       tx_pll_cal_busy;
gxb_tx_reset u_gxb_tx_reset (
  /* I */ .clock (mgmt_clk), 
  /* I */ .pll_locked (tx_plllocked),
  /* O */ .pll_powerdown (tx_pll_powerdown),
  /* I */ .pll_select (1'b0),
  /* I */ .reset (reset_sync | reset_xcvr),
  /* O */ .tx_analogreset (tx_analogreset),
  /* I */ .tx_cal_busy (tx_cal_busy),
  /* O */ .tx_digitalreset (tx_digitalreset),
  /* O */ .tx_ready (tx_ready)			     
);	
assign gxb_tx_ready   = &tx_ready;
assign tx_cal_busy[0] = tx_pll_cal_busy | gxb_tx_cal_busy_in[0];
assign tx_cal_busy[1] = tx_pll_cal_busy | gxb_tx_cal_busy_in[1];
assign tx_cal_busy[2] = tx_pll_cal_busy | gxb_tx_cal_busy_in[2];
assign tx_cal_busy[3] = tx_pll_cal_busy | gxb_tx_cal_busy_in[3];

// A10 transceiver cmu pll does not support feedback compensation bonding 
// or xN/x6 clock line usage (bonded or non-bonded)
wire iopll_outclk0;

gxb_tx_fpll u_gxb_tx_fpll (
  /* I */ .mcgb_rst (reset_sync | reset_pll),
  /* O */ .pll_cal_busy (tx_pll_cal_busy),
  /* O */ .pll_locked (tx_plllocked),
  /* I */ .pll_powerdown (tx_pll_powerdown),
  /* I */ .pll_refclk0 (hdmi_clk_in),
  /* I */ .reconfig_write0 (tx_pll_reconfig_write), 
  /* I */ .reconfig_read0 (tx_pll_reconfig_read),
  /* I */ .reconfig_address0 (tx_pll_reconfig_address),
  /* I */ .reconfig_writedata0 (tx_pll_reconfig_writedata),
  /* O */ .reconfig_readdata0 (tx_pll_reconfig_readdata),
  /* O */ .reconfig_waitrequest0 (tx_pll_reconfig_waitrequest),
  /* I */ .reconfig_clk0 (mgmt_clk),
  /* I */ .reconfig_reset0 (reset_sync),
  /* O */ .tx_bonding_clocks (tx_bonding_clocks),
  /* O */ .tx_serial_clk ()				 
    );

assign txpll_locked = tx_plllocked;
   
// HDMI Tx core
wire vid_clk;
wire ls_clk;
wire [1:0] os_sync;
clock_crosser #(.W(2), .DEPTH(3)) cc_os (.in(os), .out(os_sync), .in_clk(mgmt_clk),.out_clk(tx_clk[0]),.in_reset(1'b0),.out_reset(1'b0));

mr_hdmi_tx_core_top u_hdmi_tx_core_top (
   /* I */ .reset (reset_sync | ~(&tx_ready && tx_plllocked &iopll_locked)), 		    
   /* I */ .vid_clk (vid_clk), 
   /* I */ .ls_clk (ls_clk), 
   /* I */ .tx_clk (tx_clk[0]),
   /* I */ .os (os_sync), 
   /* I */ .mode (mode),
   /* I */ .ctrl (ctrl),					
   /* I */ .vid_data (vid_data), 
   /* I */ .vid_de (vid_de), 
   /* I */ .vid_hsync (vid_hsync),
   /* I */ .vid_vsync (vid_vsync),
   /* I */ .Scrambler_Enable (Scrambler_Enable),
   /* I */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio),
   /* O */ .tx_parallel_data (tx_parallel_data_i)
);
defparam u_hdmi_tx_core_top.SUPPORT_AUDIO = SUPPORT_AUDIO;
defparam u_hdmi_tx_core_top.SUPPORT_AUXILIARY = SUPPORT_AUXILIARY;
defparam u_hdmi_tx_core_top.SUPPORT_DEEP_COLOR = SUPPORT_DEEP_COLOR;
defparam u_hdmi_tx_core_top.SYMBOLS_PER_CLOCK = SYMBOLS_PER_CLOCK;
   
// GPLL to generate HDMI clocks
// The IO PLL is defaulted to the following settings to ease timing constraint/analysis
// The default setting is not optimum for real time run, reconfig to the right value per the desired 
// outgoing stream rate will be performed (taken care by NIOS in multi-rate operation) upon power-up.
// refclk = 300MHz (for rate detect 24-bit counter)
// outclk_0 = 600MHz (for GXB to generate output clock of 300MHz in 2-symbol mode)
// outclk_1 = 300MHz (ls clk)
// outclk_2 = 300MHz (vid clk)
wire [63:0] reconfig_to_pll;
wire [63:0] reconfig_from_pll;

pll_hdmi u_iopll_tx (   
   /* I */ .refclk (hdmi_clk_in),
   /* I */ .rst (reset_pll), 
   /* O */ .outclk_0 (iopll_outclk0),
   /* O */ .outclk_1 (ls_clk),
   /* O */ .outclk_2 (vid_clk),
   /* O */ .locked (iopll_locked),
   /* I */ .reconfig_to_pll (reconfig_to_pll),  
   /* O */ .reconfig_from_pll (reconfig_from_pll) 
);

assign vid_clk_out = vid_clk;
assign ls_clk_out = ls_clk;

pll_hdmi_reconfig u_iopll_reconfig_tx (
   /* I */ .mgmt_clk (mgmt_clk),
   /* I */ .mgmt_reset (reset_pll_reconfig),
   /* O */ .mgmt_waitrequest (pll_reconfig_waitrequest),
   /* I */ .mgmt_read (pll_reconfig_read),
   /* I */ .mgmt_write (pll_reconfig_write), 
   /* O */ .mgmt_readdata (pll_reconfig_readdata),
   /* I */ .mgmt_address (pll_reconfig_address),
   /* I */ .mgmt_writedata (pll_reconfig_writedata),
   /* O */ .reconfig_to_pll (reconfig_to_pll),
   /* I */ .reconfig_from_pll (reconfig_from_pll)			       
);
      
endmodule

