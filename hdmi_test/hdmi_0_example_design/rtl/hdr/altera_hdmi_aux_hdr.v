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


`timescale 1 ps / 1 ps

module altera_hdmi_aux_hdr (
  input  wire        clk,
  input  wire        reset,
  input  wire        hdmi_tx_vsync,
  input  wire [71:0] multiplexer_in1_data,
  input  wire        multiplexer_in1_valid,
  output wire        multiplexer_in1_ready,
  input  wire        multiplexer_in1_startofpacket,
  input  wire        multiplexer_in1_endofpacket,
  output wire [71:0] multiplexer_out_data,
  output wire        multiplexer_out_valid,
  input  wire        multiplexer_out_ready,
  output wire        multiplexer_out_startofpacket,
  output wire        multiplexer_out_endofpacket,
  output wire        multiplexer_out_channel
);
  
wire [7:0]  hdr_hb0;
wire [7:0]  hdr_hb1;
wire [7:0]  hdr_hb2;
wire [28*8-1:0] hdr_pb;
wire [71:0] multiplexer_in0_data;
wire        multiplexer_in0_valid;
wire        multiplexer_in0_ready;
wire        multiplexer_in0_startofpacket;
wire        multiplexer_in0_endofpacket;
reg         aux_src_valid;
wire        aux_src_done;

reg  hdmi_tx_vsync_r;
wire hdmi_tx_vsync_rise;
wire hdmi_tx_vsync_rise_sync;

always @(posedge clk or posedge reset)
begin
  if(reset) begin 
    hdmi_tx_vsync_r <= 1'b0;
  end else begin
    hdmi_tx_vsync_r <= hdmi_tx_vsync;
  end
end

assign hdmi_tx_vsync_rise = hdmi_tx_vsync & ~hdmi_tx_vsync_r;

always @(posedge clk or posedge reset)
begin
  if(reset) begin
      aux_src_valid <= 1'b0;
  end else begin
      if (hdmi_tx_vsync_rise) aux_src_valid <= 1'b1;
      else if(aux_src_done) aux_src_valid <= 1'b0;
      else aux_src_valid <= aux_src_valid;
  end
end
  
altera_hdmi_hdr_infoframe altera_hdmi_hdr_infoframe_inst(
  .hb0(hdr_hb0),
  .hb1(hdr_hb1),
  .hb2(hdr_hb2),
  .pb(hdr_pb)
  );
    
altera_hdmi_aux_src altera_hdmi_aux_src_inst(
  .clk(clk), 
  .reset(reset),
  .in_valid(aux_src_valid),
  .in_ready(),
  .done(aux_src_done),
  .hb0(hdr_hb0),
  .hb1(hdr_hb1),
  .hb2(hdr_hb2),
  .pb(hdr_pb),
  .out_data(multiplexer_in0_data),
  .out_sop(multiplexer_in0_startofpacket),
  .out_eop(multiplexer_in0_endofpacket),
  .out_valid(multiplexer_in0_valid),
  .out_ready(multiplexer_in0_ready)
  );
  
avalon_st_multiplexer avalon_st_multiplexer_inst (
  .clk_clk(clk),
  .multiplexer_in0_data(multiplexer_in0_data),
  .multiplexer_in0_valid(multiplexer_in0_valid),
  .multiplexer_in0_ready(multiplexer_in0_ready),
  .multiplexer_in0_startofpacket(multiplexer_in0_startofpacket),
  .multiplexer_in0_endofpacket(multiplexer_in0_endofpacket),
  .multiplexer_in1_data(multiplexer_in1_data),
  .multiplexer_in1_valid(multiplexer_in1_valid),
  .multiplexer_in1_ready(multiplexer_in1_ready),
  .multiplexer_in1_startofpacket(multiplexer_in1_startofpacket),
  .multiplexer_in1_endofpacket(multiplexer_in1_endofpacket),
  .multiplexer_out_data(multiplexer_out_data),
  .multiplexer_out_valid(multiplexer_out_valid),
  .multiplexer_out_ready(multiplexer_out_ready),
  .multiplexer_out_startofpacket(multiplexer_out_startofpacket),
  .multiplexer_out_endofpacket(multiplexer_out_endofpacket),
  .multiplexer_out_channel(multiplexer_out_channel),
  .reset_reset_n(~reset)
);

endmodule
