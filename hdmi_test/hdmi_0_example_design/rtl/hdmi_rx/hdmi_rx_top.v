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



module hdmi_rx_top #(
   parameter SUPPORT_DEEP_COLOR      = 0,
   parameter SUPPORT_AUXILIARY       = 0,
   parameter SYMBOLS_PER_CLOCK       = 2,
   parameter SUPPORT_AUDIO           = 0,
   parameter BITEC_DAUGHTER_CARD_REV = 6
) (  
   // Clock, reset and PLL locked signals 
   input  wire                                    reset,
   input  wire                                    mgmt_clk,
   input  wire                                    hdmi_clk_in,
   input  wire                                    tmds_clk_in,	
   output wire                                    vid_clk_out,
   output wire                                    ls_clk_out,   
   output wire                                    iopll_locked,
   output wire                                    sys_init,
   // GXB RX signals
   input  wire [2:0]                              rx_serial_data,
   output wire                                    gxb_rx_ready,	
   // HDMI RX signals
   output wire                                    TMDS_Bit_clock_Ratio,
   output wire [1:0]                              colordepth_mgmt_sync,
   output wire [2:0]                              locked,
   output wire [SYMBOLS_PER_CLOCK*48-1:0]         vid_data,
   output wire [SYMBOLS_PER_CLOCK-1:0]            vid_vsync,
   output wire [SYMBOLS_PER_CLOCK-1:0]            vid_hsync,
   output wire [SYMBOLS_PER_CLOCK-1:0]            vid_de,
   output wire                                    vid_lock,
   input  wire                                    in_5v_power,
   inout  wire                                    hdmi_rx_hpd_n,
   input  wire                                    user_pb_1,
   output wire                                    mode,
   output wire [SYMBOLS_PER_CLOCK*6-1:0]          ctrl,     
   // Reconfig mgmt signals
   output wire [23:0]                             measure,
   output wire                                    measure_valid,
   output wire                                    os, 
   // I2C signals
   inout  wire                                    hdmi_rx_i2c_sda,
   inout  wire                                    hdmi_rx_i2c_scl,
   input  wire                                    i2c_clk,
   //output wire [7:0]                              scdc_i2c_rdata,
   //input  wire                                    scdc_i2c_w,
   //input  wire                                    scdc_i2c_r,
   //input  wire [7:0]                              scdc_i2c_addr,
   //input  wire [7:0]                              scdc_i2c_wdata,

   output wire        reconfig_mgmt_write,
   output wire        reconfig_mgmt_read,
   output wire [11:0] reconfig_mgmt_address,
   output wire [31:0] reconfig_mgmt_writedata,
   input wire  [31:0] reconfig_mgmt_readdata,
   input wire         reconfig_mgmt_waitrequest,
   output wire [2:0]  gxb_rx_cal_busy_out,
   output wire        rx_reconfig_en,

   input wire[2:0]      gxb_reconfig_write,
   input wire[2:0]      gxb_reconfig_read,
   input wire  [29:0]   gxb_reconfig_address,
   input wire  [95:0]   gxb_reconfig_writedata,
   output wire [95:0]   gxb_reconfig_readdata,
   output wire[2:0]     gxb_reconfig_waitrequest,
   input wire [2:0]     gxb_rx_cal_busy_in,
   
   input wire           edid_ram_access,
   input wire [7:0]     edid_ram_address,
   input wire           edid_ram_write,
   input wire           edid_ram_read,
   output wire [7:0]    edid_ram_readdata,
   input wire [7:0]     edid_ram_writedata,
   output wire          edid_ram_waitrequest
);

wire [2:0]  locked_int;
wire        rx_hpd;
wire        hdmi_rx_hpd_tmp;
wire        mgmt_clk_reset_sync;
//assign hdmi_rx_hpd_tmp   = rx_hpd & user_pb_1 & cpu_resetn;
assign hdmi_rx_hpd_tmp   = rx_hpd;
assign locked = locked_int;

//
// Generate the HPD for source to re-trigger the SCDC write upon power up
//
localparam [31:0] HPD_TIMEOUT_COUNT = 32'd100000000; //hold HPD for 1s
wire    sys_init_int;
wire clr_count;
wire hdmi_rx_5v_detect_sync;

//assign clr_count = ~hdmi_rx_5v_detect_sync | edid_ram_access | mgmt_clk_reset_sync | ~user_pb_1;
assign clr_count = ~hdmi_rx_5v_detect_sync |  ~user_pb_1;

altera_std_synchronizer sync_locked(
    .clk(mgmt_clk), 
    .reset_n(~mgmt_clk_reset_sync), 
    .din(in_5v_power), 
    .dout(hdmi_rx_5v_detect_sync)
);

reg [31:0] hpd_count = 32'd0;
always @ (posedge mgmt_clk or posedge mgmt_clk_reset_sync)
begin
    if(mgmt_clk_reset_sync) begin
        hpd_count <= 32'd0;
    end else begin
        if(clr_count) begin
            hpd_count <= 32'd0;
        end else begin
            if (hpd_count < HPD_TIMEOUT_COUNT) begin 
                hpd_count <= hpd_count + 32'd1;
            end
        end
    end
end
assign rx_hpd = hpd_count > (HPD_TIMEOUT_COUNT - 32'd1);

reg [3:0] sys_init_count = 4'd0;

always @ (posedge mgmt_clk)
begin
    if (sys_init_count < 4'd11) begin
        sys_init_count <= sys_init_count + 4'd1;
    end
end


assign sys_init_int = sys_init_count > 4'd5 && sys_init_count < 4'd10;
assign sys_init = sys_init_int;

//
// RX Display Data Channel (DDC)
// I2C slave and EDID components
//
wire        i2c_clk_reset_sync;
wire [7:0]  edid_rdata;
//wire        edid_w;
wire        edid_r;
wire [31:0] edid_addr;
//wire [31:0] edid_wdata;
wire        edid_sda_oe;
wire        i2c_sda_in;
wire [7:0]  scdc_rdata;
wire        scdc_w;
wire        scdc_r;
wire [31:0] scdc_addr;
wire [31:0] scdc_wdata;
   
reg edid_rdvalid;
always @(posedge i2c_clk)
   edid_rdvalid <= edid_r;
	
i2cslave_to_avlmm_bridge #(
   .I2C_SLAVE_ADDRESS (10'b0001010000),
   .BYTE_ADDRESSING (1),
   .ADDRESS_STEALING (0),
   .READ_ONLY (0)
) u_i2cslave_edid (
   .clk (i2c_clk),
   .rst_n (~i2c_clk_reset_sync),
   .address (edid_addr),
   .read (edid_r),
   .readdata ({24'd0, edid_rdata}),
   .readdatavalid (edid_rdvalid),
   .waitrequest (1'b0),
   .write (),
   .byteenable (),
   .writedata (),
   .i2c_data_in (i2c_sda_in),
   .i2c_clk_in (hdmi_rx_i2c_scl),
   .i2c_data_oe (edid_sda_oe),
   .i2c_clk_oe ()	    
);

wire scdc_sda_oe;
   
reg scdc_rdvalid;
always @(posedge i2c_clk)
   scdc_rdvalid <= scdc_r;
	
i2cslave_to_avlmm_bridge #(
   .I2C_SLAVE_ADDRESS (10'b0001010100),
   .BYTE_ADDRESSING (1),
   .ADDRESS_STEALING (0),
   .READ_ONLY (0)
) u_i2cslave_scdc (
   .clk (i2c_clk),
   .rst_n (~i2c_clk_reset_sync),
   .address (scdc_addr),
   .read (scdc_r),
   .readdata ({24'd0, scdc_rdata}),
   .readdatavalid (scdc_rdvalid),
   .waitrequest	(1'b0),
   .write (scdc_w),
   .byteenable (),
   .writedata (scdc_wdata),
   .i2c_data_in (i2c_sda_in),
   .i2c_clk_in (hdmi_rx_i2c_scl),
   .i2c_data_oe (scdc_sda_oe),
   .i2c_clk_oe ()	    
);

wire SYNTHESIZED_WIRE_3;
assign SYNTHESIZED_WIRE_3 = scdc_sda_oe | edid_sda_oe;
   
output_buf_i2c u_i2c_buf (
   /* I */ .datain (1'b0),
   /* B */ .dataio (hdmi_rx_i2c_sda), 
   /* I */ .oe (SYNTHESIZED_WIRE_3),
   /* O */ .dataout (i2c_sda_in)
);

output_buf_i2c u_rx_hpd_buf (
   /* I */ .datain (1'b0),
   /* B */ .dataio (hdmi_rx_hpd_n), 
   /* I */ .oe (hdmi_rx_hpd_tmp),
   /* O */ .dataout ()
);

wire [7:0] edid_ram_address_tmp;
wire edid_ram_read_tmp;
reg [2:0] edid_ram_read_r;
reg edid_ram_write_r0;

edid_ram u_edid_ram (
   /* I */ .wren ({edid_ram_write & ~edid_ram_write_r0}), //write data change after the first clock cycle of write, write pulse for 2 cycles, so need to limit write to 1 cycle
   /* I */ .rden (edid_ram_read_tmp),
   /* I */ .clock (i2c_clk),
   /* I */ .address (edid_ram_address_tmp),
   /* I */ .data (edid_ram_writedata),
   /* O */ .q (edid_rdata)
);

assign edid_ram_address_tmp = ({8{~edid_ram_access}} & edid_addr[7:0]) | ({8{edid_ram_access}} & edid_ram_address);
assign edid_ram_read_tmp = (~edid_ram_access) | (edid_ram_access & edid_ram_read & ~edid_ram_read_r[0]);
assign edid_ram_readdata = edid_rdata;
assign edid_ram_waitrequest = edid_ram_access & ((edid_ram_read & ~edid_ram_read_r[0]) | {edid_ram_write & ~edid_ram_write_r0});

always @(posedge i2c_clk or posedge i2c_clk_reset_sync)
begin
    if(i2c_clk_reset_sync) begin
        edid_ram_read_r <= 1'b0;
        edid_ram_write_r0 <= 1'b0;
    end else begin
        edid_ram_read_r <= {edid_ram_read_r[1:0], edid_ram_read};
        edid_ram_write_r0 <= edid_ram_write;
    end
end

// Rx Native PHY Transceiver
wire        mgmt_clk_core_reset_sync;
wire        reset_xcvr;
wire        reset_pll;
wire        reset_pll_reconfig;
wire [2:0]  rx_analogreset;
wire [2:0]  rx_digitalreset;
wire [2:0]  rx_set_locktoref;
wire [2:0]  rx_freqlocked;
wire [2:0]  rx_is_lockedtoref;
wire [59:0] rx_data;
wire [2:0]  rx_clk; 
wire        cdr_refclk0;
wire [3:0]  color_depth;
wire [3:0]  color_depth_sync;
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_parallel_data;
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_parallel_data_i;
wire [14:0] rx_std_bitslipboundarysel;
wire        reconfig_pcs_in_progress;

gxb_rx u_gxb_rx (
  /* I */ .reconfig_write (gxb_reconfig_write), 
  /* I */ .reconfig_read (gxb_reconfig_read),
  /* I */ .reconfig_address (gxb_reconfig_address),
  /* I */ .reconfig_writedata (gxb_reconfig_writedata),
  /* O */ .reconfig_readdata (gxb_reconfig_readdata),
  /* O */ .reconfig_waitrequest (gxb_reconfig_waitrequest),
  /* I */ .reconfig_clk ({3{mgmt_clk}}),
  /* I */ .reconfig_reset ({3{mgmt_clk_reset_sync}}),
  /* I */ .rx_analogreset (rx_analogreset),
  /* O */ .rx_cal_busy (gxb_rx_cal_busy_out),
  /* I */ .rx_cdr_refclk0 (cdr_refclk0),
  /* O */ .rx_clkout (rx_clk),
  /* I */ .rx_coreclkin (rx_clk),
  /* I */ .rx_digitalreset (rx_digitalreset | {3{reconfig_pcs_in_progress}}),
  /* O */ .rx_is_lockedtodata (rx_freqlocked), 
  /* O */ .rx_is_lockedtoref (rx_is_lockedtoref),
  /* O */ .rx_parallel_data (rx_parallel_data_i),
  /* I */ .rx_serial_data (rx_serial_data),
  /* I */ .rx_set_locktodata (3'd0), 
  /* I */ .rx_set_locktoref (rx_set_locktoref), 
  /* O */ .unused_rx_parallel_data (),
  /* O */ .rx_patterndetect (),
  /* O */ .rx_syncstatus (),
  /* I */ .rx_std_wa_patternalign (3'b000), 
  /* O */ .rx_std_bitslipboundarysel (rx_std_bitslipboundarysel)
);

wire [2:0] rx_datalock;
wire tkn_detected;
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_parallel_data_aligned;
symbol_aligner #(
  .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK)
) u_symbol_aligner (
  /* I */ .reset (reset),
  /* I */ .mgmt_clk (mgmt_clk),
  /* I */ .rx_clk (rx_clk),
  /* I */ .rx_parallel_data (rx_parallel_data_i),
  /* I */ .rx_std_bitslipboundarysel (rx_std_bitslipboundarysel),
  /* I */ .rx_ready (rx_datalock),
  /* I */ .rx_reconfig_pcs_in_progress (reconfig_pcs_in_progress),
  /* O */ .token_detected (tkn_detected),
  /* O */ .rx_parallel_data_aligned (rx_parallel_data_aligned)				 
);
  
// Rx Transceiver Reset Controller
//wire         reset_xcvr;
wire [2:0] rx_reset_is_lockedtodata;
assign rx_reset_is_lockedtodata = &rx_set_locktoref ? rx_is_lockedtoref : rx_freqlocked;

gxb_rx_reset u_gxb_rx_reset (
  /* I */ .clock (mgmt_clk),
  /* I */ .reset (reset_xcvr),
  /* O */ .rx_analogreset (rx_analogreset),
  /* I */ .rx_cal_busy (gxb_rx_cal_busy_in), 
  /* O */ .rx_digitalreset (rx_digitalreset),
  /* I */ .rx_is_lockedtodata (rx_reset_is_lockedtodata), 
  /* O */ .rx_ready (rx_datalock)			     
);

assign gxb_rx_ready = &rx_datalock;
   
// HDMI Rx core
wire       ls_clk;
wire       vid_clk;
wire [2:0] rx_core_ready;
wire       reset_core;

assign rx_core_ready = rx_datalock & {3{~reset_core}};


wire [SYMBOLS_PER_CLOCK*10-1:0] r,g,b;
wire [2:0] rx_clk_remap;
wire clk_r, clk_g, clk_b;

generate
if (BITEC_DAUGHTER_CARD_REV==11) begin: BITEC_RX_MAP
   assign {b,r,g} = rx_parallel_data_aligned;
   assign rx_parallel_data = {r,g,b};
   assign {clk_b, clk_r, clk_g} = rx_clk;
   assign rx_clk_remap = {clk_r, clk_g, clk_b};
end else if (BITEC_DAUGHTER_CARD_REV==4 || BITEC_DAUGHTER_CARD_REV==6) begin 
   assign {r,b,g} = rx_parallel_data_aligned;
   assign rx_parallel_data = ~{r,g,b};
   assign {clk_r, clk_b, clk_g} = rx_clk;
   assign rx_clk_remap = {clk_r, clk_g, clk_b};
end else begin
   assign {r,g,b} = rx_parallel_data_aligned;
   assign rx_parallel_data = {r,g,b};
   assign {clk_r, clk_g, clk_b} = rx_clk;
   assign rx_clk_remap = {clk_r, clk_g, clk_b};
end
endgenerate

//wire       os;
//wire [7:0] scdc_rdata;
//wire       scdc_w;
//wire       scdc_r;
//wire [7:0] scdc_addr;
//wire [7:0] scdc_wdata;
//wire       i2c_clk;
mr_hdmi_rx_core_top u_hdmi_rx_core_top (
   /* I */ .reset ({mgmt_clk_core_reset_sync}), // was mgmt_clk_reset_sync | ~(&rx_datalock && iopll_locked)
   /* I */ .rx_clk (rx_clk_remap),
   /* I */ .ls_clk (ls_clk),  	    
   /* I */ .vid_clk (vid_clk),  
   /* I */ .os (os),
   /* I */ .rx_parallel_data (rx_parallel_data),
   /* I */ .rx_datalock (rx_core_ready), 
   /* O */ .locked (locked_int),
   /* O */ .vid_data (vid_data),
   /* O */ .vid_de (vid_de),
   /* O */ .vid_hsync (vid_hsync),
   /* O */ .vid_vsync (vid_vsync),
   /* O */ .vid_lock (vid_lock),
   /* I */ .in_5v_power (in_5v_power), 
   /* I */ .in_hpd (hdmi_rx_hpd_tmp), 
   /* O */ .mode (mode),
   /* O */ .ctrl (ctrl),					
   /* I */ .scdc_i2c_clk (i2c_clk),
   /* I */ .scdc_i2c_addr (scdc_addr[7:0]),
   /* O */ .scdc_i2c_rdata (scdc_rdata),
   /* I */ .scdc_i2c_wdata (scdc_wdata[7:0]),
   /* I */ .scdc_i2c_r (scdc_r),
   /* I */ .scdc_i2c_w (scdc_w),
   /* O */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio));
defparam u_hdmi_rx_core_top.SUPPORT_AUDIO = SUPPORT_AUDIO;
defparam u_hdmi_rx_core_top.SUPPORT_AUXILIARY = SUPPORT_AUXILIARY;
defparam u_hdmi_rx_core_top.SUPPORT_DEEP_COLOR = SUPPORT_DEEP_COLOR;
defparam u_hdmi_rx_core_top.SYMBOLS_PER_CLOCK = SYMBOLS_PER_CLOCK;
   
// GPLL to generate HDMI clocks
wire iopll_outclk0;
clock_control u_clock_control1 (
   /* I */ .inclk (iopll_outclk0),
   /* O */ .outclk (cdr_refclk0)
);

// The IO PLL is defaulted to the following settings to ease timing constraint/analysis
// The default setting is not optimum for real time run, reconfig to the right value per incoming
// stream rate will be performed (taken care by state machine in multi-rate operation) upon power-up.
// refclk = 300MHz (for rate detect 24-bit counter)
// outclk_0 = 600MHz (for GXB to generate output clock of 300MHz in 2-symbol mode)
// outclk_1 = 300MHz (ls clk)
// outclk_2 = 300MHz (vid clk)
//wire pll_locked;
wire [63:0] reconfig_to_pll;
wire [63:0] reconfig_from_pll;
pll_hdmi u_iopll (
   /* I */ .refclk (tmds_clk_in), 
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
  
// PLL reconfig controller
wire        pll_reconfig_waitrequest;
wire [8:0]  pll_reconfig_address;
wire        pll_reconfig_write;
wire [31:0] pll_reconfig_writedata;
pll_hdmi_reconfig u_iopll_reconfig (
   /* I */ .mgmt_clk (mgmt_clk),
   /* I */ .mgmt_reset (reset_pll_reconfig), 
   /* O */ .mgmt_waitrequest (pll_reconfig_waitrequest),
   /* I */ .mgmt_read (),
   /* I */ .mgmt_write (pll_reconfig_write), 
   /* O */ .mgmt_readdata (),
   /* I */ .mgmt_address (pll_reconfig_address),
   /* I */ .mgmt_writedata (pll_reconfig_writedata),
   /* O */ .reconfig_to_pll (reconfig_to_pll),
   /* I */ .reconfig_from_pll (reconfig_from_pll)
);   
 
assign color_depth = 4'b0;
clock_crosser #(.W(4)) cc_cd (.in(color_depth), .out(color_depth_sync), .in_clk(ls_clk),.out_clk(mgmt_clk),.in_reset(1'b0),.out_reset(1'b0));
assign colordepth_mgmt_sync = color_depth_sync[1:0]; // only bit 1 and 0 used by CPU
wire measure_valid_reconfig_mgmt;

wire i2c_trans_detected_ack;
reg i2c_trans_detected;
always @(posedge i2c_clk or posedge i2c_clk_reset_sync)
begin
  if(i2c_clk_reset_sync) begin
    i2c_trans_detected <= 1'b0;
  end else begin
    if(scdc_w & (scdc_addr == 8'h20) & ((scdc_wdata[1:0] == 2'b11) | (scdc_wdata[1:0] == 2'b00)))
      i2c_trans_detected <= 1'b1;
    else if(i2c_trans_detected_ack)
      i2c_trans_detected <= 1'b0;
  end
end


mr_reconfig_mgmt u_mr_reconfig_mgmt (
  /* I */ .clock (mgmt_clk),
  /* I */ .reset (mgmt_clk_reset_sync),
  /* I */ .refclock (tmds_clk_in), 
  /* I */ .rx_is_20 (TMDS_Bit_clock_Ratio),  
  /* I */ .rx_hdmi_locked (locked),
  /* I */ .rx_color_depth (color_depth_sync),  
  /* I */ .rx_ready (&rx_datalock),
  /* I */ .pll_locked (iopll_locked),
  /* O */ .reset_core (reset_core), 
  /* O */ .reset_xcvr (reset_xcvr),
  /* O */ .reset_pll (reset_pll),
  /* O */ .reset_pll_reconfig (reset_pll_reconfig),
  /* O */ .rx_set_locktoref (rx_set_locktoref),
  /* O */ .measure (measure),
  /* O */ .measure_valid (measure_valid_reconfig_mgmt),
  /* I */ .rx_cal_busy (gxb_rx_cal_busy_in),
  /* I */ .rx_reconfig_waitrequest (reconfig_mgmt_waitrequest),
  /* I */ .rx_reconfig_readdata (reconfig_mgmt_readdata),
  /* O */ .rx_reconfig_write (reconfig_mgmt_write),
  /* O */ .rx_reconfig_read (reconfig_mgmt_read),
  /* O */ .rx_reconfig_address (reconfig_mgmt_address),
  /* O */ .rx_reconfig_writedata (reconfig_mgmt_writedata),
  /* I */ .pll_reconfig_waitrequest (pll_reconfig_waitrequest),
  /* O */ .pll_reconfig_write (pll_reconfig_write),
  /* O */ .pll_reconfig_address (pll_reconfig_address),
  /* O */ .pll_reconfig_writedata (pll_reconfig_writedata),
  /* O */ .rx_reconfig_en (rx_reconfig_en),
  /* I */ .i2c_trans_detected (i2c_trans_detected),
  /* O */ .i2c_trans_detected_ack (i2c_trans_detected_ack),
  /* I */ .tkn_detected (tkn_detected),
  /* O */ .reconfig_pcs_in_progress (reconfig_pcs_in_progress)
);	
defparam u_mr_reconfig_mgmt.FAST_SIMULATION = 0;
   
assign os = &rx_set_locktoref;

wire locked_sync;
clock_crosser #(.W(1)) cc_hdmi_rx_locked (.in(&locked_int), .out(locked_sync), .in_clk(ls_clk),.out_clk(mgmt_clk),.in_reset(1'b0),.out_reset(1'b0));
assign measure_valid = measure_valid_reconfig_mgmt & (locked_sync);

//
// Reset synchronizers
//
altera_reset_controller #(
   .NUM_RESET_INPUTS          (3),
   .SYNC_DEPTH                (3),
   .RESET_REQ_WAIT_TIME       (1),
   .MIN_RST_ASSERTION_TIME    (3),
   .RESET_REQ_EARLY_DSRT_TIME (1)
) u_mgmt_clk_reset_sync_sync (
   /* I */ .reset_in0 (reset),
   /* I */ .reset_in1 (sys_init_int),
   /* I */ .reset_in2 (edid_ram_access),
   /* I */ .clk (mgmt_clk),
   /* O */ .reset_out (mgmt_clk_reset_sync)
);

altera_reset_controller #(
   .NUM_RESET_INPUTS          (2),
   .SYNC_DEPTH                (3),
   .RESET_REQ_WAIT_TIME       (1),
   .MIN_RST_ASSERTION_TIME    (3),
   .RESET_REQ_EARLY_DSRT_TIME (1)
) u_mgmt_clk_core_reset_sync (
   /* I */ .reset_in0 (reset),
   /* I */ .reset_in1 (sys_init_int),
   /* I */ .clk (mgmt_clk),
   /* O */ .reset_out (mgmt_clk_core_reset_sync)
);

altera_reset_controller #(
   .NUM_RESET_INPUTS          (1),
   .SYNC_DEPTH                (3),
   .RESET_REQ_WAIT_TIME       (1),
   .MIN_RST_ASSERTION_TIME    (3),
   .RESET_REQ_EARLY_DSRT_TIME (1)
) u_i2c_clk_reset_sync (
   /* I */ .reset_in0 (reset),
   /* I */ .clk (i2c_clk),
   /* O */ .reset_out (i2c_clk_reset_sync)
);


endmodule


