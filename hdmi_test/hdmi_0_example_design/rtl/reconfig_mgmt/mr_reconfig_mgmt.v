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


//
// Reconfig management top level for GXB RX and PLL
//
module mr_reconfig_mgmt #(
    parameter FAST_SIMULATION = 0
) (
    input  wire        clock,
    input  wire        reset,
    input  wire        refclock,   
    input  wire        rx_is_20,   
    input  wire [2:0]  rx_hdmi_locked,
    input  wire [3:0]  rx_color_depth,    
    input  wire        rx_ready,   
    input  wire        pll_locked,
    output wire        reset_core,	 
    output wire        reset_xcvr,
    output wire        reset_pll,
    output wire        reset_pll_reconfig,
    output wire [2:0]  rx_set_locktoref,
    output wire [23:0] measure,
    output wire        measure_valid,
    input  wire [2:0]  rx_cal_busy,   
    input  wire        rx_reconfig_waitrequest,
    input  wire [31:0] rx_reconfig_readdata,   
    output wire        rx_reconfig_write,
    output wire        rx_reconfig_read,   
    output wire [11:0] rx_reconfig_address, // upper 2 bits indicate logical channel number
    output wire [31:0] rx_reconfig_writedata,    
    input  wire        pll_reconfig_waitrequest,
    output wire        pll_reconfig_write,
    output wire [8:0]  pll_reconfig_address,
    output wire [31:0] pll_reconfig_writedata,
    output wire        rx_reconfig_en,
    input  wire        i2c_trans_detected,
    output wire        i2c_trans_detected_ack,
    input  wire        tkn_detected,
    output wire        reconfig_pcs_in_progress
);

function integer alt_clogb2;
    input [31:0] value;
    integer i;
    begin
        alt_clogb2 = 32;
        for (i=31; i>0; i=i-1) begin
            if (2**i>=value)
                alt_clogb2 = i;
        end
    end
endfunction

// **** PERL SCIPT TO GENERATE BEGIN **** //
localparam NUMBER_OF_MIF_RANGE                   = 16;
localparam ROM_DEPTH_FOR_EACH_MIF_RANGE          = 13; 
localparam TOTAL_ROM_DEPTH_FOR_VALUEMASK         = NUMBER_OF_MIF_RANGE * ROM_DEPTH_FOR_EACH_MIF_RANGE;
localparam TOTAL_ROM_DEPTH_FOR_DPRIOADDR_BITMASK = ROM_DEPTH_FOR_EACH_MIF_RANGE; 
localparam ADDR_WIDTH_FOR_VALUEMASK              = alt_clogb2(TOTAL_ROM_DEPTH_FOR_VALUEMASK);
localparam ADDR_WIDTH_FOR_DPRIOADDR_BITMASK      = alt_clogb2(ROM_DEPTH_FOR_EACH_MIF_RANGE);
localparam ROM_SIZE_FOR_VALUEMASK                = 8;
localparam ROM_SIZE_FOR_DPRIOADDR_BITMASK        = 18;

//localparam POINTER_WIDTH                         = alt_clogb2(TOTAL_ROM_DEPTH_FOR_VALUEMASK);
localparam LOOPS_MAX                             = 31;
localparam LOOPS_WIDTH                           = alt_clogb2(LOOPS_MAX);   
// **** PERL SCIPT TO GENERATE END ****** //

wire [ADDR_WIDTH_FOR_DPRIOADDR_BITMASK-1:0] rx_dprioaddr_bitmask_addr_ptr;
wire [ADDR_WIDTH_FOR_VALUEMASK-1:0]         rx_valuemask_addr_ptr;
wire [10-1:0]                               rx_dprio_offset;
wire [8-1:0]                                rx_field_bitmask;
wire [8-1:0]                                rx_field_valuemask;
wire                                        clr_compare_valid;
wire                                        clr_pll_reconfig_done;
wire                                        clr_xcvr_reconfig_done;
wire [ADDR_WIDTH_FOR_VALUEMASK-1:0]         rx_offset_pointer;
wire                                        rx_offset_pointer_valid;
wire                                        rx_oversampled;
wire [LOOPS_WIDTH-1:0]                      rx_range;
wire                                        pll_reconfig_request;
wire                                        xcvr_reconfig_request;
wire                                        rx_reconfig_done;
wire                                        pll_reconfig_done;
wire [3-1:0]                                pll_dprioaddr_addr_ptr;
wire [6-1:0]                                pll_valuemask_addr_ptr;
wire [8-1:0]                                pll_dprio_offset;
wire [32-1:0]                               pll_field_valuemask; 
wire [32-1:0]                               pll_field_valuemask_8bpc;
wire [32-1:0]                               pll_field_valuemask_10bpc;
wire [32-1:0]                               pll_field_valuemask_12bpc;
wire [32-1:0]                               pll_field_valuemask_16bpc;  
wire [6-1:0]                                pll_offset_pointer;
wire                                        pll_offset_pointer_valid;
wire [3-1:0]                                pll_range;
wire                                        enable_measure;
wire [23:0]                                 measure_for_compare;
wire [3:0]                                  color_depth_out;
wire                                        pcs_reconfig_request;

assign measure_for_compare = rx_is_20 ? {measure[21:0], 2'b00} : measure;

assign rx_reconfig_en = xcvr_reconfig_request;

// ROM storing address offset and field bitmask for GXB RX   
mr_rom_rx_dprioaddr_bitmask #(
    .ROM_SIZE        (ROM_SIZE_FOR_DPRIOADDR_BITMASK),
    .ADDR_WIDTH      (ADDR_WIDTH_FOR_DPRIOADDR_BITMASK)			      
) u_rom_rx_dprioaddr_bitmask (
    /* I */ .clock     (clock),
    /* I */ .addr_ptr  (rx_dprioaddr_bitmask_addr_ptr),
    /* O */ .rdata_out ({rx_dprio_offset, rx_field_bitmask})  
);

// ROM storing field valuemask for GXB RX across various data rate ranges
mr_rom_rx_valuemask #(
    .NUMBER_OF_MIF_RANGE          (NUMBER_OF_MIF_RANGE),
    .ROM_DEPTH_FOR_EACH_MIF_RANGE (ROM_DEPTH_FOR_EACH_MIF_RANGE),
    .ROM_SIZE                     (ROM_SIZE_FOR_VALUEMASK),
    .ADDR_WIDTH                   (ADDR_WIDTH_FOR_VALUEMASK)		      
) u_rom_rx_valuemask (
    /* I */ .clock     (clock),
    /* I */ .addr_ptr  (rx_valuemask_addr_ptr),
    /* O */ .rdata_out (rx_field_valuemask)		      
);

wire [10-1:0] pcs_dprio_offset;
wire [8-1:0]  pcs_field_bitmask;
wire [8-1:0]  pcs_field_valuemask;
mr_rom_pcs #(
    .ROM_SIZE   (26),
    .ADDR_WIDTH (4)			      
) u_rom_pcs_dprioaddr_bitmask (
    /* I */ .clock     (clock),
    /* I */ .addr_ptr  (rx_dprioaddr_bitmask_addr_ptr),
    /* O */ .rdata_out ({pcs_dprio_offset, pcs_field_bitmask, pcs_field_valuemask})  
);
   
// GXB RX comparison circuitry
mr_compare_rx #(
    .FAST_SIMULATION (FAST_SIMULATION),
    .MIF_OFFSET      (ROM_DEPTH_FOR_EACH_MIF_RANGE),		   
    .POINTER_WIDTH   (ADDR_WIDTH_FOR_VALUEMASK),
    .LOOPS_MAX       (LOOPS_MAX),
    .LOOPS_WIDTH     (LOOPS_WIDTH)		  
) u_compare_rx (
    /* I */ .clock                (clock),
    /* I */ .reset                (reset),
    /* I */ .clr_valid            (clr_compare_valid),
    /* I */ .measure              (measure_for_compare),
    /* I */ .measure_valid        (measure_valid),
    /* O */ .offset_pointer       (rx_offset_pointer),
    /* O */ .offset_pointer_valid (rx_offset_pointer_valid),
    /* O */ .range                (rx_range),		   
    /* O */ .oversampled          (rx_oversampled)		    
);

// Avalon-MM reconfig master for GXB RX 
mr_reconfig_master_rx #(
    .MIF_OFFSET                       (ROM_DEPTH_FOR_EACH_MIF_RANGE),
    .ADDR_WIDTH_FOR_VALUEMASK         (ADDR_WIDTH_FOR_VALUEMASK),
    .ADDR_WIDTH_FOR_DPRIOADDR_BITMASK (ADDR_WIDTH_FOR_DPRIOADDR_BITMASK),
    .DPRIO_ADDRESS_WIDTH              (10+2),
    .DPRIO_DATA_WIDTH                 (32)		  
) u_reconfig_master_rx (
    /* I */ .clock                      (clock),
    /* I */ .reset                      (reset),
    /* I */ .rx_cal_busy                (rx_cal_busy),
    /* I */ .pcs_reconfig_request       (pcs_reconfig_request),			
    /* I */ .reconfig_request           (xcvr_reconfig_request),
    /* O */ .reconfig_busy              (),
    /* O */ .reconfig_done              (rx_reconfig_done),
    /* I */ .clr_reconfig_done          (clr_xcvr_reconfig_done),
    /* I */ .offset_pointer             (pcs_reconfig_request ? ({ADDR_WIDTH_FOR_VALUEMASK{1'd0}}) : rx_offset_pointer),
    /* O */ .valuemask_addr_ptr         (rx_valuemask_addr_ptr),
    /* O */ .dprioaddr_bitmask_addr_ptr (rx_dprioaddr_bitmask_addr_ptr),
    /* I */ .dprio_offset               (pcs_reconfig_request ? pcs_dprio_offset : rx_dprio_offset),
    /* I */ .field_bitmask              (pcs_reconfig_request ? pcs_field_bitmask : rx_field_bitmask),
    /* I */ .field_valuemask            (pcs_reconfig_request ? pcs_field_valuemask : rx_field_valuemask),
    /* I */ .reconfig_waitrequest       (rx_reconfig_waitrequest),
    /* I */ .reconfig_readdata          (rx_reconfig_readdata),
    /* O */ .reconfig_write             (rx_reconfig_write),
    /* O */ .reconfig_read              (rx_reconfig_read),
    /* O */ .reconfig_address           (rx_reconfig_address),
    /* O */ .reconfig_writedata         (rx_reconfig_writedata)		    
);   

// Main state machine controlling both GXB RX and PLL reconfig
mr_state_machine #(
    .FAST_SIMULATION (FAST_SIMULATION),
    .POINTER_WIDTH   (ADDR_WIDTH_FOR_VALUEMASK),
    .RX_RANGE_WIDTH  (LOOPS_WIDTH),
    .PLL_RANGE_WIDTH (3)			 
) u_state_machine ( 
    /* I */ .clock                      (clock),
    /* I */ .reset                      (reset),
    /* I */ .rx_is_20                   (rx_is_20),
    /* I */ .rx_hdmi_locked             (rx_hdmi_locked),
    /* I */ .rx_color_depth             (rx_color_depth),	 
    /* I */ .rx_ready                   (rx_ready),
    /* I */ .rx_cal_busy                (rx_cal_busy),
    /* I */ .rx_reconfig_done           (rx_reconfig_done),
    /* I */ .pll_locked                 (pll_locked),
    /* I */ .pll_reconfig_done          (pll_reconfig_done),
    /* I */ .rx_range                   (rx_range),
    /* I */ .rx_offset_pointer_valid    (rx_offset_pointer_valid),
    /* I */ .rx_oversampled             (rx_oversampled),
    /* I */ .pll_offset_pointer_valid   (pll_offset_pointer_valid),
    /* I */ .pll_range                  (pll_range),	 
    /* O */ .set_locktoref              (rx_set_locktoref),
    /* O */ .color_depth_out            (color_depth_out),	 
    /* O */ .clr_compare_valid          (clr_compare_valid),
    /* O */ .clr_pll_reconfig_done      (clr_pll_reconfig_done),
    /* O */ .clr_xcvr_reconfig_done     (clr_xcvr_reconfig_done),
    /* O */ .reset_core                 (reset_core),	 
    /* O */ .reset_xcvr                 (reset_xcvr),
    /* O */ .reset_pll                  (reset_pll),
    /* O */ .reset_pll_reconfig         (reset_pll_reconfig),
    /* O */ .enable_measure             (enable_measure),
    /* O */ .pll_reconfig_request       (pll_reconfig_request),
    /* O */ .xcvr_reconfig_request      (xcvr_reconfig_request),
    /* I */ .i2c_trans_detected         (i2c_trans_detected),
    /* O */ .i2c_trans_detected_ack     (i2c_trans_detected_ack),
    /* I */ .tkn_detected               (tkn_detected),
    /* O */ .pcs_reconfig_request       (pcs_reconfig_request)
);

assign reconfig_pcs_in_progress = pcs_reconfig_request;
   
// The parameter values for PLL reconfig related blocks are pre-determined across a10 device parts
// ROM storing address offset for PLL   
mr_rom_pll_dprioaddr #(
    .ROM_SIZE        (8),
    .TOTAL_ROM_DEPTH (8), // was 7
    .ADDR_WIDTH      (3)			      
) u_rom_pll_dprioaddr (
    /* I */ .clock     (clock),
    /* I */ .addr_ptr  (pll_dprioaddr_addr_ptr),
    /* O */ .rdata_out (pll_dprio_offset)  
);

// ROM storing field valuemask for PLL across various TMDS clock frequency ranges 
mr_rom_pll_valuemask_8bpc #(
    .NUMBER_OF_MIF_RANGE          (6),
    .ROM_DEPTH_FOR_EACH_MIF_RANGE (7),
    .ROM_SIZE                     (32),
    .TOTAL_ROM_DEPTH              (64), // 42
    .ADDR_WIDTH                   (6)		      
) u_rom_pll_valuemask_8bpc (
    /* I */ .clock       (clock),
    /* I */ .addr_ptr    (pll_valuemask_addr_ptr),
    /* O */ .rdata_out   (pll_field_valuemask_8bpc) 
);

mr_rom_pll_valuemask_10bpc #(
    .NUMBER_OF_MIF_RANGE          (6),
    .ROM_DEPTH_FOR_EACH_MIF_RANGE (7),
    .ROM_SIZE                     (32),
    .TOTAL_ROM_DEPTH              (64), // 42
    .ADDR_WIDTH                   (6)		      
) u_rom_pll_valuemask_10bpc (
    /* I */ .clock       (clock),
    /* I */ .addr_ptr    (pll_valuemask_addr_ptr),
    /* O */ .rdata_out   (pll_field_valuemask_10bpc) 
);

mr_rom_pll_valuemask_12bpc #(
    .NUMBER_OF_MIF_RANGE          (6),
    .ROM_DEPTH_FOR_EACH_MIF_RANGE (7),
    .ROM_SIZE                     (32),
    .TOTAL_ROM_DEPTH              (64), // 42
    .ADDR_WIDTH                   (6)		      
) u_rom_pll_valuemask_12bpc (
    /* I */ .clock       (clock),
    /* I */ .addr_ptr    (pll_valuemask_addr_ptr),
    /* O */ .rdata_out   (pll_field_valuemask_12bpc) 
);

mr_rom_pll_valuemask_16bpc #(
    .NUMBER_OF_MIF_RANGE          (6),
    .ROM_DEPTH_FOR_EACH_MIF_RANGE (7),
    .ROM_SIZE                     (32),
    .TOTAL_ROM_DEPTH              (64), // 42
    .ADDR_WIDTH                   (6)		      
) u_rom_pll_valuemask_16bpc (
    /* I */ .clock       (clock),
    /* I */ .addr_ptr    (pll_valuemask_addr_ptr),
    /* O */ .rdata_out   (pll_field_valuemask_16bpc) 
);

assign pll_field_valuemask = color_depth_out == 4'b0101 ? pll_field_valuemask_10bpc :
                             color_depth_out == 4'b0110 ? pll_field_valuemask_12bpc :
                             color_depth_out == 4'b0111 ? pll_field_valuemask_16bpc :
                                                          pll_field_valuemask_8bpc;
																			 
// PLL comparison circuitry
mr_compare_pll #(
    .FAST_SIMULATION (FAST_SIMULATION),
    .MIF_OFFSET      (7),		   
    .POINTER_WIDTH   (6),
    .LOOPS_MAX       (5),
    .LOOPS_WIDTH     (3)		  
) u_compare_pll (
    /* I */ .clock                (clock),
    /* I */ .reset                (reset),
    /* I */ .clr_valid            (clr_compare_valid),
    /* I */ .measure              (measure_for_compare),
    /* I */ .measure_valid        (measure_valid),
    /* O */ .offset_pointer       (pll_offset_pointer),
    /* O */ .offset_pointer_valid (pll_offset_pointer_valid),
    /* O */ .range                (pll_range)
);

// Avalon-MM reconfig master for PLL reconfig
mr_reconfig_master_pll #(
    .MIF_OFFSET               (7),
    .ADDR_WIDTH_FOR_VALUEMASK (6),
    .ADDR_WIDTH_FOR_DPRIOADDR (3),
    .DPRIO_ADDRESS_WIDTH      (9),
    .DPRIO_DATA_WIDTH         (32)
) u_reconfig_master_pll (
    /* I */ .clock                (clock),
    /* I */ .reset                (reset),
    /* I */ .reconfig_request     (pll_reconfig_request),
    /* O */ .reconfig_done        (pll_reconfig_done),
    /* I */ .clr_reconfig_done    (clr_pll_reconfig_done),    
    /* I */ .offset_pointer       (pll_offset_pointer),
    /* O */ .valuemask_addr_ptr   (pll_valuemask_addr_ptr),
    /* O */ .dprioaddr_addr_ptr   (pll_dprioaddr_addr_ptr),
    /* I */ .dprio_offset         (pll_dprio_offset),
    /* I */ .field_valuemask      (pll_field_valuemask),
    /* I */ .reconfig_waitrequest (pll_reconfig_waitrequest),
    /* O */ .reconfig_write       (pll_reconfig_write),
    /* O */ .reconfig_address     (pll_reconfig_address),
    /* O */ .reconfig_writedata   (pll_reconfig_writedata)
);

// Measure circuitry for TMDS clock
mr_rate_detect #(		 
    .CYC_MEASURE_CLK_IN_10_MSEC (FAST_SIMULATION ? 1000 : 1000000) 
) u_rate_detect (
    /* I */ .refclock         (refclock), 
    /* I */ .measure_clk      (clock),
    /* I */ .reset            (reset),
    /* I */ .enable           (enable_measure),    
    /* O */ .refclock_measure (measure),
    /* O */ .valid            (measure_valid)
);
  
endmodule
