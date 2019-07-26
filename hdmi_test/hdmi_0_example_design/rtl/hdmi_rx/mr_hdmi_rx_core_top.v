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



module mr_hdmi_rx_core_top #(
    parameter SUPPORT_DEEP_COLOR  = 0,
    parameter SUPPORT_AUXILIARY   = 0,
    parameter SYMBOLS_PER_CLOCK   = 2,
    parameter SUPPORT_AUDIO       = 0
) (
    input  wire                                    reset,			 
    input  wire [2:0]                              rx_clk,
    input  wire                                    ls_clk,
    input  wire                                    vid_clk,			 
    input  wire                                    os,
    input  wire [SYMBOLS_PER_CLOCK*10*3-1:0]       rx_parallel_data,
    input  wire [2:0]                              rx_datalock,
    input  wire                                    scdc_i2c_clk,
    input  wire [7:0]                              scdc_i2c_addr,
    output wire [7:0]                              scdc_i2c_rdata,
    input  wire [7:0]                              scdc_i2c_wdata,
    input  wire                                    scdc_i2c_r,
    input  wire                                    scdc_i2c_w,
    output wire                                    TMDS_Bit_clock_Ratio,
    output wire [2:0]                              locked,
    output wire [SYMBOLS_PER_CLOCK*48-1:0]         vid_data,
    output wire [SYMBOLS_PER_CLOCK-1:0]            vid_vsync,
    output wire [SYMBOLS_PER_CLOCK-1:0]            vid_hsync,
    output wire [SYMBOLS_PER_CLOCK-1:0]            vid_de,
    output wire                                    vid_lock,
    input  wire                                    in_5v_power,
    input  wire                                    in_hpd,
    output wire                                    mode,
    output wire [SYMBOLS_PER_CLOCK*6-1:0]          ctrl
);

genvar i;
wire [2:0] rx_clk_rst_sync;
generate
    for (i=0; i<3; i=i+1) begin: RX_CLK_RST_SYNCHRONIZER
        altera_reset_controller #(
            .NUM_RESET_INPUTS (2),
            .SYNC_DEPTH (3)				
        ) u_rx_clk_rst_sync (
            /* I */ .reset_in0 (reset),
            /* I */ .reset_in1 ({~&rx_datalock}),
            /* I */ .clk (rx_clk[i]),
            /* O */ .reset_out (rx_clk_rst_sync[i])
        );
    end 
endgenerate
   
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_oversample_out;
wire [2:0]                        rx_oversample_out_valid; 
wire [2:0]                        rx_fifo_wrreq;           
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_fifo_in;              
wire [SYMBOLS_PER_CLOCK*10*3-1:0] rx_fifo_out;                
       
generate
    for (i=0; i<3; i=i+1) begin: RX_OVERSAMPLE   
        mr_rx_oversample #(
            .DIN_WIDTH (SYMBOLS_PER_CLOCK*10),			    
            .DOUT_WIDTH (SYMBOLS_PER_CLOCK*10),
            .SAMPLE_INTERVAL (5),
            .SAMPLE_MASK (5'b00100)		   
        ) u_rx_os (
            /* I */ .clk (rx_clk[i]),
            /* I */ .rst (rx_clk_rst_sync[i]),
            /* I */ .din (rx_parallel_data[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* O */ .dout (rx_oversample_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* O */ .dout_valid (rx_oversample_out_valid[i])       
        );
    end
endgenerate

wire ls_clk_rst_sync;
altera_reset_controller #(
    .NUM_RESET_INPUTS (2),
    .SYNC_DEPTH (3)			  
) u_ls_clk_rst_sync (
    /* I */ .reset_in0 (reset),
    /* I */ .reset_in1 ({~&rx_datalock}),
    /* I */ .clk (ls_clk),
    /* O */ .reset_out (ls_clk_rst_sync)
);
   
assign rx_fifo_in = os ? rx_oversample_out : rx_parallel_data;
assign rx_fifo_wrreq = os ? rx_oversample_out_valid : 3'b111;
   
generate
    for (i=0; i<3; i=i+1) begin: RX_DCFIFO   
        mr_clock_sync #(
            .DEVICE_FAMILY ("Cyclone 10 GX"),
            .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK)			 
        ) u_rx_clock_sync (
            /* I */ .wrclk (rx_clk[i]),
            /* I */ .rdclk (ls_clk),
            /* I */ .aclr (ls_clk_rst_sync), 
            /* I */ .wrreq (rx_fifo_wrreq[i]),
            /* I */ .data (rx_fifo_in[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]), 
            /* I */ .rdreq (1'b1),
            /* O */ .q (rx_fifo_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10])		      
        );
    end
endgenerate


//bitec_hdmi_rx u_bitec_hdmi_rx (
hdmi_rx u_hdmi_rx (   
    /* I */ .reset (reset), // was ls_clk_rst_sync
    /* I */ .vid_clk (vid_clk),
    /* I */ .ls_clk ({3{ls_clk}}),						
    /* I */ .in_b (rx_fifo_out[SYMBOLS_PER_CLOCK*10*1-1:0]), 
    /* I */ .in_g (rx_fifo_out[SYMBOLS_PER_CLOCK*10*2-1:SYMBOLS_PER_CLOCK*10*1]),
    /* I */ .in_r (rx_fifo_out[SYMBOLS_PER_CLOCK*10*3-1:SYMBOLS_PER_CLOCK*10*2]), 	 
    /* I */ .in_lock (rx_datalock[2:0]),
    /* O */ .vid_data (vid_data),
    /* O */ .vid_de (vid_de),
    /* O */ .vid_hsync (vid_hsync),
    /* O */ .vid_vsync (vid_vsync),
    /* O */ .vid_lock (vid_lock),
    /* O */ .locked (locked),
    /* I */ .in_5v_power (in_5v_power),
    /* I */ .in_hpd (in_hpd), 
    /* O */ .mode (mode),
    /* O */ .ctrl (ctrl),		      
    /* I */ .scdc_i2c_clk (scdc_i2c_clk),
    /* I */ .scdc_i2c_addr (scdc_i2c_addr),
    /* O */ .scdc_i2c_rdata (scdc_i2c_rdata),
    /* I */ .scdc_i2c_wdata (scdc_i2c_wdata),
    /* I */ .scdc_i2c_r (scdc_i2c_r),
    /* I */ .scdc_i2c_w (scdc_i2c_w),
    /* O */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio)
);
//defparam u_bitec_hdmi_rx.SUPPORT_8CHAN_AUDIO = SUPPORT_8CHAN_AUDIO;
//defparam u_bitec_hdmi_rx.SUPPORT_AUDIO = SUPPORT_AUDIO;
//defparam u_bitec_hdmi_rx.SUPPORT_AUXILIARY = SUPPORT_AUXILIARY;
//defparam u_bitec_hdmi_rx.SUPPORT_DEEP_COLOR = SUPPORT_DEEP_COLOR;
//defparam u_bitec_hdmi_rx.SYMBOLS_PER_CLOCK = SYMBOLS_PER_CLOCK;
   
endmodule			

