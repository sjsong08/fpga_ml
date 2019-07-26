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


module rxtx_link #(
    parameter SYMBOLS_PER_CLOCK = 4
) (

   input  reset,
   input  mgmt_clk,
   input  i2c_clk,
   input  hdmi_tx_ls_clk,
   //output hdmi_tx_ls_clk_reset_sync,
   input  hdmi_rx_ls_clk,
   input  hdmi_tx_vid_clk,
   input  hdmi_rx_vid_clk,
   input  [2:0] hdmi_rx_locked,
   input  user_pb_2,

   input  [SYMBOLS_PER_CLOCK-1:0] hdmi_rx_de,
   input  [SYMBOLS_PER_CLOCK-1:0] hdmi_rx_hsync,
   input  [SYMBOLS_PER_CLOCK-1:0] hdmi_rx_vsync,
   input  [SYMBOLS_PER_CLOCK*48-1:0] hdmi_rx_data,
   input  [4:0] rx_audio_format,
   input  [164:0] rx_audio_metadata,
   input  [47:0] rx_audio_info_ai,
   input  [19:0] rx_audio_CTS,
   input  [19:0] rx_audio_N,
   input  rx_audio_de,
   input  [255:0] rx_audio_data,
   input  [5:0] rx_gcp,
   input  [111:0] rx_info_avi,
   input  [60:0] rx_info_vsi,
   input  rx_aux_eop,
   input  rx_aux_sop,
   input  rx_aux_valid,
   input  [71:0] rx_aux_data,

   output [1*SYMBOLS_PER_CLOCK-1:0] hdmi_tx_de,
   output [1*SYMBOLS_PER_CLOCK-1:0] hdmi_tx_hsync,
   output [1*SYMBOLS_PER_CLOCK-1:0] hdmi_tx_vsync,
   output [48*SYMBOLS_PER_CLOCK-1:0] hdmi_tx_data,
   output [4:0] tx_audio_format,
   output [164:0] tx_audio_metadata,
   output [47:0] tx_audio_info_ai,
   output [19:0] tx_audio_CTS,
   output [19:0] tx_audio_N,
   output tx_audio_de,
   output [255:0] tx_audio_data,
   output [5:0] tx_gcp,
   output [111:0] tx_info_avi,
   output [60:0] tx_info_vsi,
   output tx_aux_eop,
   output tx_aux_sop,
   output tx_aux_valid,
   output [71:0] tx_aux_data,
   input  tx_aux_ready,
  
   //output [1:0] color_depth_sync,
   //output hdmi_rx_locked_sync,
   input  sys_init,
   input  wd_reset
   //output rx_mgmt_clk_reset
   

);


//
// HDMI video/audio/aux/infoframes bypass fifos
//
wire vid_bp_ff_wrreq;
wire vid_bp_ff_rdreq;
wire vid_bp_ff_full;
wire vid_bp_ff_mt;

assign vid_bp_ff_wrreq = ~vid_bp_ff_full;
assign vid_bp_ff_rdreq = ~vid_bp_ff_mt;

dcfifo_inst #(.WIDTH(102)) u_vid_bypass_fifo (
   /* I */ .rdclk (hdmi_tx_vid_clk),
   /* I */ .wrclk (hdmi_rx_vid_clk),
   /* I */ .wrreq (vid_bp_ff_wrreq),
   /* I */ .aclr (reset | ~&hdmi_rx_locked),
   /* I */ .data ({hdmi_rx_de, hdmi_rx_hsync, hdmi_rx_vsync, hdmi_rx_data}),
   /* I */ .rdreq (vid_bp_ff_rdreq),
   /* O */ .wrfull (vid_bp_ff_full),
   /* O */ .q ({hdmi_tx_de, hdmi_tx_hsync, hdmi_tx_vsync, hdmi_tx_data}),
   /* O */ .rdempty (vid_bp_ff_mt));

wire aud_bp_ff_wrreq;
wire aud_bp_ff_rdreq;
wire aud_bp_ff_full;
wire aud_bp_ff_mt;

assign aud_bp_ff_wrreq = ~aud_bp_ff_full;
assign aud_bp_ff_rdreq = ~aud_bp_ff_mt;

dcfifo_inst #( .WIDTH(5 + 165+ 48 + 20 + 20 + 1 + 256)) u_aud_bypass_fifo (
   /* I */ .rdclk (hdmi_tx_ls_clk),
   /* I */ .wrclk (hdmi_rx_ls_clk),
   /* I */ .wrreq (aud_bp_ff_wrreq),
   /* I */ .aclr (reset | ~&hdmi_rx_locked),
   /* I */ .data ({rx_audio_format, rx_audio_metadata, rx_audio_info_ai, rx_audio_CTS, rx_audio_N, rx_audio_de, rx_audio_data}),
   /* I */ .rdreq (aud_bp_ff_rdreq),
   /* O */ .wrfull (aud_bp_ff_full),
   /* O */ .q ({tx_audio_format, tx_audio_metadata, tx_audio_info_ai, tx_audio_CTS, tx_audio_N, tx_audio_de, tx_audio_data}),
   /* O */ .rdempty (aud_bp_ff_mt));

wire if_bp_ff_wrreq;
wire if_bp_ff_rdreq;
wire if_bp_ff_full;
wire if_bp_ff_mt;

assign if_bp_ff_wrreq = ~if_bp_ff_full;
assign if_bp_ff_rdreq = ~if_bp_ff_mt;

dcfifo_inst #(.WIDTH(179)) u_if_passthru_fifo (
   /* I */ .rdclk (hdmi_tx_ls_clk),
   /* I */ .wrclk (hdmi_rx_ls_clk),
   /* I */ .wrreq (if_bp_ff_wrreq),
   /* I */ .aclr (reset | ~&hdmi_rx_locked),
   /* I */ .data ({rx_gcp, rx_info_avi, rx_info_vsi}),
   /* I */ .rdreq (if_bp_ff_rdreq),
   /* O */ .wrfull (if_bp_ff_full),
   /* O */ .q ({tx_gcp, tx_info_avi, tx_info_vsi}),
   /* O */ .rdempty (if_bp_ff_mt));

wire aux_bp_ff_wrreq;
wire aux_bp_ff_rdreq;
wire aux_bp_ff_full;
wire aux_bp_ff_mt;
wire [71:0] aux_bp_ff_data;
reg         aux_bp_ff_valid;
wire        aux_bp_ff_sop;
wire        aux_bp_ff_eop;
wire 		aux_bp_ff_ready;


assign aux_bp_ff_wrreq = rx_aux_valid & ~aux_bp_ff_full;
assign aux_bp_ff_rdreq = aux_bp_ff_ready & ~aux_bp_ff_mt;
//assign aux_bp_ff_valid = ~aux_bp_ff_mt;

wire hdmi_tx_ls_clk_reset_sync;
always @ (posedge hdmi_tx_ls_clk or posedge hdmi_tx_ls_clk_reset_sync)
begin   
   if (hdmi_tx_ls_clk_reset_sync) begin
      aux_bp_ff_valid <= 1'b0;
   end else begin
        if      (aux_bp_ff_ready & ~aux_bp_ff_mt)    aux_bp_ff_valid <= 1'b1; // 1 clock cycle delay of the read will be the valid for the data
        else if (~aux_bp_ff_ready & aux_bp_ff_valid) aux_bp_ff_valid <= 1'b1; // need to hold the valid until the ready asserted so that data can be read by AV ST MUX
        else                                         aux_bp_ff_valid <= 1'b0;
   end
end

dcfifo_inst #(.WIDTH(74)) u_aux_passthru_fifo (
   /* I */ .rdclk (hdmi_tx_ls_clk),
   /* I */ .wrclk (hdmi_rx_ls_clk),
   /* I */ .wrreq (aux_bp_ff_wrreq),
   /* I */ .aclr (reset | ~&hdmi_rx_locked),
   /* I */ .data ({rx_aux_eop, rx_aux_sop, rx_aux_data}),
   /* I */ .rdreq (aux_bp_ff_rdreq),
   /* O */ .wrfull (aux_bp_ff_full),
   /* O */ .q ({aux_bp_ff_eop, aux_bp_ff_sop, aux_bp_ff_data}),
   /* O */ .rdempty (aux_bp_ff_mt));

   
   
//---------------------------------------------------------------------------------------------------------
// High Dynamic Range (HDR) 

wire hdmi_tx_vsync_sync;
wire multiplexer_in_ready;
wire ext_aux_block;


clock_crosser #(.W(1)) hdmi_tx_vsync_cc (.in(hdmi_tx_vsync[0]), .out(hdmi_tx_vsync_sync), .in_clk(hdmi_tx_vid_clk),.out_clk(hdmi_tx_ls_clk),.in_reset(1'b0),.out_reset(1'b0));

altera_hdmi_aux_hdr altera_hdmi_aux_hdr_inst (
  .clk(hdmi_tx_ls_clk),
  .reset(hdmi_tx_ls_clk_reset_sync),
  .hdmi_tx_vsync(hdmi_tx_vsync_sync),
  .multiplexer_in1_data(aux_bp_ff_data),
  .multiplexer_in1_valid(aux_bp_ff_valid & ~ext_aux_block),
  .multiplexer_in1_ready(multiplexer_in_ready),
  .multiplexer_in1_startofpacket(aux_bp_ff_sop),
  .multiplexer_in1_endofpacket(aux_bp_ff_eop),
  .multiplexer_out_data(tx_aux_data),
  .multiplexer_out_valid(tx_aux_valid),
  .multiplexer_out_ready(tx_aux_ready),
  .multiplexer_out_startofpacket(tx_aux_sop),
  .multiplexer_out_endofpacket(tx_aux_eop),
  .multiplexer_out_channel()
  
);
   
//---------------------------------------------------------------------------------------------------------
//
// Example of external filtering of audio sample, timestamp on the auxiliary data port which is loopback from the sink.
// (Workaround) Filter the audio infoframe on the auxiliary data port as well when msb of audio_info_ai is 0.
//

wire block_ext_aud_related_packet;
wire block_ext_hdr_packet;
wire block_ext_aud_sample;
wire block_ext_aud_timestamp;
wire block_ext_aud_infoframe;
wire block_ext_hdr_infoframe;
wire block_ext_aux_packet;
wire ext_aud_sample;
wire ext_aud_timestamp;
wire ext_aud_infoframe;
wire ext_hdr_infoframe;
reg do_ext_aux_block;

assign block_ext_aud_sample = 1'b1;
assign block_ext_aud_timestamp = 1'b1;
assign block_ext_aud_infoframe = ~user_pb_2;
assign block_ext_hdr_infoframe = 1'b1;
assign ext_aud_sample = aux_bp_ff_sop & (aux_bp_ff_data[7:0] == 8'h02) & aux_bp_ff_valid;
assign ext_aud_timestamp = aux_bp_ff_sop & (aux_bp_ff_data[7:0] == 8'h01) & aux_bp_ff_valid;
assign ext_aud_infoframe = aux_bp_ff_sop & (aux_bp_ff_data[7:0] == 8'h84) & aux_bp_ff_valid;
assign ext_hdr_infoframe = aux_bp_ff_sop & (aux_bp_ff_data[7:0] == 8'h87) & aux_bp_ff_valid;
assign block_ext_aud_related_packet = (block_ext_aud_sample & ext_aud_sample) | 
                                      (block_ext_aud_timestamp & ext_aud_timestamp) |
                                      (block_ext_aud_infoframe & ext_aud_infoframe);
assign block_ext_hdr_packet = block_ext_hdr_infoframe & ext_hdr_infoframe;

assign block_ext_aux_packet = block_ext_aud_related_packet | block_ext_hdr_packet;

always @ (posedge hdmi_tx_ls_clk or posedge hdmi_tx_ls_clk_reset_sync)
begin   
   if (hdmi_tx_ls_clk_reset_sync)
      do_ext_aux_block <= 1'b0;
   else
      do_ext_aux_block <= do_ext_aux_block ? ~(aux_bp_ff_eop & aux_bp_ff_valid) : block_ext_aux_packet;
end
    
assign ext_aux_block = block_ext_aux_packet | do_ext_aux_block; 
assign aux_bp_ff_ready = multiplexer_in_ready | ext_aux_block;


altera_reset_controller #(
   .NUM_RESET_INPUTS          (1),
   .SYNC_DEPTH                (3),
   .RESET_REQ_WAIT_TIME       (1),
   .MIN_RST_ASSERTION_TIME    (3),
   .RESET_REQ_EARLY_DSRT_TIME (1)
) u_hdmi_tx_ls_clk_reset_sync (
  .reset_in0 (reset),
  .clk (hdmi_tx_ls_clk),
  .reset_out (hdmi_tx_ls_clk_reset_sync)
);

endmodule

