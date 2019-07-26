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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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
// Module to create dummy HDR InfoFrame packet header and payload data
//

module altera_hdmi_hdr_infoframe ( hb0, hb1, hb2, pb );

output wire [7:0] hb0; // InfoFrame type = HDR
output wire [7:0] hb1; // Version number
output wire [7:0] hb2; // Length of HDR Metadata InfoFrame

output wire [28*8-1:0] pb;

assign hb0 = 8'h87;
assign hb1 = 8'h01;
assign hb2 = 8'h26;

// Electro-Optical Transfer Function
// 0 = Native Gamma
// 1 = SMPTE 2084 [2]
// 2 = Future EOTF
// 3 - 7 Reserved
wire [2:0] EOTF = 3'b000;

//EOTF_Transition_Flag
// 0 = No info
// 1 = The EOTF signaled in the HDR and Colorimetry InfoFrame might not be consistent with the EOTF in the current stream.
wire [0:0] EOTF_Transition_Flag = 1'b0;

// Static_Metadata_Descriptor_ID
// 0 = Blu-ray Disc Association Static Metadata
// 1 = Reserved
wire [2:0] Static_Metadata_Descriptor_ID = 1'b0;

wire [7:0] Static_Metadata_Descriptor [26:3];

assign Static_Metadata_Descriptor[ 3] = 8'h3; // display_primaries_x[0], LSB
assign Static_Metadata_Descriptor[ 4] = 8'h4; // display_primaries_x[0], MSB
assign Static_Metadata_Descriptor[ 5] = 8'h5; // display_primaries_y[0], LSB
assign Static_Metadata_Descriptor[ 6] = 8'h6; // display_primaries_y[0], MSB
assign Static_Metadata_Descriptor[ 7] = 8'h7; // display_primaries_x[1], LSB
assign Static_Metadata_Descriptor[ 8] = 8'h8; // display_primaries_x[1], MSB
assign Static_Metadata_Descriptor[ 9] = 8'h9; // display_primaries_y[1], LSB
assign Static_Metadata_Descriptor[10] = 8'hA; // display_primaries_y[1], MSB
assign Static_Metadata_Descriptor[11] = 8'hB; // display_primaries_x[2], LSB
assign Static_Metadata_Descriptor[12] = 8'hC; // display_primaries_x[2], MSB
assign Static_Metadata_Descriptor[13] = 8'hD; // display_primaries_y[2], LSB
assign Static_Metadata_Descriptor[14] = 8'hE; // display_primaries_y[2], MSB
assign Static_Metadata_Descriptor[15] = 8'hF; // white_point_x, LSB
assign Static_Metadata_Descriptor[16] = 8'h10; // white_point_x, MSB
assign Static_Metadata_Descriptor[17] = 8'h11; // white_point_y, LSB
assign Static_Metadata_Descriptor[18] = 8'h12; // white_point_y, MSB
assign Static_Metadata_Descriptor[19] = 8'h13; // max_display_mastering_luminance, LSB
assign Static_Metadata_Descriptor[20] = 8'h14; // max_display_mastering_luminance, MSB
assign Static_Metadata_Descriptor[21] = 8'h15; // min_display_mastering_luminance, LSB
assign Static_Metadata_Descriptor[22] = 8'h16; // min_display_mastering_luminance, MSB
assign Static_Metadata_Descriptor[23] = 8'h17; // Maximum Content Light Level, LSB
assign Static_Metadata_Descriptor[24] = 8'h18; // Maximum Content Light Level, MSB
assign Static_Metadata_Descriptor[25] = 8'h19; // Maximum Frame-average Light Level, LSB
assign Static_Metadata_Descriptor[26] = 8'h1A; // Maximum Frame-average Light Level, MSB


assign pb = 
  {
    {5'd0, EOTF},                                                 // Data byte 1
    {4'd0, EOTF_Transition_Flag, Static_Metadata_Descriptor_ID},  // Data byte 2
      Static_Metadata_Descriptor[ 3],                             // Data byte 3
      Static_Metadata_Descriptor[ 4],                             // Data byte 4
      Static_Metadata_Descriptor[ 5],                             // Data byte 5
      Static_Metadata_Descriptor[ 6],                             // Data byte 6
      Static_Metadata_Descriptor[ 7],                             // Data byte 7
      Static_Metadata_Descriptor[ 8],                             // Data byte 8
      Static_Metadata_Descriptor[ 9],                             // Data byte 9
      Static_Metadata_Descriptor[10],                             // Data byte 10
      Static_Metadata_Descriptor[11],                             // Data byte 11
      Static_Metadata_Descriptor[12],                             // Data byte 12
      Static_Metadata_Descriptor[13],                             // Data byte 13
      Static_Metadata_Descriptor[14],                             // Data byte 14
      Static_Metadata_Descriptor[15],                             // Data byte 15
      Static_Metadata_Descriptor[16],                             // Data byte 16
      Static_Metadata_Descriptor[17],                             // Data byte 17
      Static_Metadata_Descriptor[18],                             // Data byte 18
      Static_Metadata_Descriptor[19],                             // Data byte 19
      Static_Metadata_Descriptor[20],                             // Data byte 20
      Static_Metadata_Descriptor[21],                             // Data byte 21
      Static_Metadata_Descriptor[22],                             // Data byte 22
      Static_Metadata_Descriptor[23],                             // Data byte 23
      Static_Metadata_Descriptor[24],                             // Data byte 24
      Static_Metadata_Descriptor[25],                             // Data byte 25
      Static_Metadata_Descriptor[26],                             // Data byte 26
      16'd0 // padding
  };
endmodule