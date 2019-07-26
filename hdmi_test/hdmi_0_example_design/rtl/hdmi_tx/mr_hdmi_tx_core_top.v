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



module mr_hdmi_tx_core_top #(
    parameter SUPPORT_DEEP_COLOR  = 0,
    parameter SUPPORT_AUXILIARY   = 0,
    parameter SYMBOLS_PER_CLOCK   = 2,
    parameter SUPPORT_AUDIO       = 0 
) (
    input  wire                                    reset,
    input  wire                                    vid_clk, 
    input  wire                                    ls_clk,
    input  wire                                    tx_clk,
    input  wire [1:0]                              os,   
    input  wire                                    mode,
    input  wire [6*SYMBOLS_PER_CLOCK-1:0]          ctrl,    
    input  wire [48*SYMBOLS_PER_CLOCK-1:0]         vid_data,
    input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_vsync, 
    input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_hsync,
    input  wire [1*SYMBOLS_PER_CLOCK-1:0]          vid_de,
    input  wire                                    Scrambler_Enable,   
    input  wire                                    TMDS_Bit_clock_Ratio,
    output wire [SYMBOLS_PER_CLOCK*10*4-1:0]       tx_parallel_data   
);

genvar i;
//wire os_sync;
//altera_std_synchronizer #(.depth(3)) u_os_sync (.clk(tx_clk),.reset_n(1'b1),.din(os),.dout(os_sync));

wire [SYMBOLS_PER_CLOCK*10-1:0] out_b;
wire [SYMBOLS_PER_CLOCK*10-1:0] out_c;
wire [SYMBOLS_PER_CLOCK*10-1:0] out_g;
wire [SYMBOLS_PER_CLOCK*10-1:0] out_r;
//bitec_hdmi_tx u_bitec_hdmi_tx (
hdmi_tx u_hdmi_tx (
    /* I */ .reset (reset), // was ls_clk_rst_sync
    /* I */ .vid_clk (vid_clk), 
    /* I */ .ls_clk (ls_clk), 
    /* I */ .vid_data (vid_data), 
    /* I */ .vid_de (vid_de), 
    /* I */ .vid_hsync (vid_hsync),
    /* I */ .vid_vsync (vid_vsync),
    /* I */ .ctrl (ctrl), 
    /* O */ .out_b (out_b),
    /* O */ .out_c (out_c),
    /* O */ .out_g (out_g),
    /* O */ .out_r (out_r),
    /* I */ .mode (mode),
    /* I */ .Scrambler_Enable (Scrambler_Enable),
    /* I */ .TMDS_Bit_clock_Ratio (TMDS_Bit_clock_Ratio)
);
//defparam u_bitec_hdmi_tx.SUPPORT_8CHAN_AUDIO = SUPPORT_8CHAN_AUDIO;
//defparam u_bitec_hdmi_tx.SUPPORT_AUDIO = SUPPORT_AUDIO;
//defparam u_bitec_hdmi_tx.SUPPORT_AUXILIARY = SUPPORT_AUXILIARY;
//defparam u_bitec_hdmi_tx.SUPPORT_DEEP_COLOR = SUPPORT_DEEP_COLOR;
//defparam u_bitec_hdmi_tx.SYMBOLS_PER_CLOCK = SYMBOLS_PER_CLOCK; 

wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_core_out;       

wire                              tx_data_valid_3;
wire                              tx_data_valid_4;
wire                              tx_data_valid_5;
wire                              tx_data_valid_r_3;
wire                              tx_data_valid_r_4;
wire                              tx_data_valid_r_5;
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_fifo_out;
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_oversample_out_3; 
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_oversample_out_4;
wire [SYMBOLS_PER_CLOCK*10*4-1:0] tx_oversample_out_5; 
wire                              tx_fifo_rdreq;

wire tx_clk0_rst_sync;
altera_reset_controller #(
    .NUM_RESET_INPUTS (1),
    .SYNC_DEPTH (3)			  
) u_tx_clk0_rst_sync (
    /* I */ .reset_in0 (reset),
    /* I */ .clk (tx_clk),
    /* O */ .reset_out (tx_clk0_rst_sync)
);
  
generate
    for (i=0; i<4; i=i+1) begin: TX_DCFIFO   
        mr_clock_sync #(
            .DEVICE_FAMILY ("Cyclone 10 GX"),
            .SYMBOLS_PER_CLOCK (SYMBOLS_PER_CLOCK)			
        ) u_tx_clock_sync (
            /* I */ .wrclk (ls_clk),
            /* I */ .rdclk (tx_clk),
            /* I */ .aclr (tx_clk0_rst_sync), 
            /* I */ .wrreq (1'b1),
            /* I */ .data (tx_core_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* I */ .rdreq (tx_fifo_rdreq),
            /* O */ .q (tx_fifo_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10])		      
        );
    end
endgenerate

generate
    
    for (i=0; i<4; i=i+1) begin: TX_OVERSAMPLE_3   
        mr_tx_oversample #(
            .OVERSAMPLE_RATE (3),
            .DATA_WIDTH (SYMBOLS_PER_CLOCK*10)		   
        ) u_tx_os_3 (
            /* I */ .clk (tx_clk),
            /* I */ .rst (tx_clk0_rst_sync), 
            /* I */ .din (tx_fifo_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* I */ .din_valid (tx_data_valid_r_3),
            /* O */ .dout (tx_oversample_out_3[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10])		       
        );
    end

    for (i=0; i<4; i=i+1) begin: TX_OVERSAMPLE_4   
        mr_tx_oversample #(
            .OVERSAMPLE_RATE (4),
            .DATA_WIDTH (SYMBOLS_PER_CLOCK*10)		   
        ) u_tx_os_4 (
            /* I */ .clk (tx_clk),
            /* I */ .rst (tx_clk0_rst_sync), 
            /* I */ .din (tx_fifo_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* I */ .din_valid (tx_data_valid_r_4),
            /* O */ .dout (tx_oversample_out_4[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10])		       
        );
    end
    
    for (i=0; i<4; i=i+1) begin: TX_OVERSAMPLE_5   
        mr_tx_oversample #(
            .OVERSAMPLE_RATE (5),
            .DATA_WIDTH (SYMBOLS_PER_CLOCK*10)		   
        ) u_tx_os_5 (
            /* I */ .clk (tx_clk),
            /* I */ .rst (tx_clk0_rst_sync), 
            /* I */ .din (tx_fifo_out[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10]),
            /* I */ .din_valid (tx_data_valid_r_5),
            /* O */ .dout (tx_oversample_out_5[i*SYMBOLS_PER_CLOCK*10+SYMBOLS_PER_CLOCK*10-1:i*SYMBOLS_PER_CLOCK*10])		       
        );
    end

endgenerate

mr_ce 
#(
  .OVERSAMPLE_RATE(3)
) u_ce_3 (
    /* I */ .clk (tx_clk),
    /* I */ .rst (tx_clk0_rst_sync), 
    /* O */ .txdata_valid (tx_data_valid_3),
    /* O */ .txdata_valid_r (tx_data_valid_r_3)	
);

mr_ce 
#(
  .OVERSAMPLE_RATE(4)
) u_ce_2 (
    /* I */ .clk (tx_clk),
    /* I */ .rst (tx_clk0_rst_sync), 
    /* O */ .txdata_valid (tx_data_valid_4),
    /* O */ .txdata_valid_r (tx_data_valid_r_4)	
);

mr_ce 
#(
  .OVERSAMPLE_RATE(5)
) u_ce_5 (
    /* I */ .clk (tx_clk),
    /* I */ .rst (tx_clk0_rst_sync), 
    /* O */ .txdata_valid (tx_data_valid_5),
    /* O */ .txdata_valid_r (tx_data_valid_r_5)	
);


assign tx_parallel_data = (os == 2'd1)? tx_oversample_out_3 :
                          (os == 2'd2)? tx_oversample_out_4 :
                          (os == 2'd3)? tx_oversample_out_5 : tx_fifo_out;
                          
assign tx_fifo_rdreq =  (os == 2'd1)? tx_data_valid_3 :
                        (os == 2'd2)? tx_data_valid_4 :
                        (os == 2'd3)? tx_data_valid_5 : 1'b1;
                          
assign tx_core_out = {out_r, out_g, out_b, out_c};

   
endmodule   

