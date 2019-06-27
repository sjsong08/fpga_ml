// (C) 2001-2019 Intel Corporation. All rights reserved.
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



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  paral_add_parallel_add_191_u2agy2i  (
	data0x,
	data1x,
	data2x,
	data3x,
	data4x,
	result);

	input	[15:0]  data0x;
	input	[15:0]  data1x;
	input	[15:0]  data2x;
	input	[15:0]  data3x;
	input	[15:0]  data4x;
	output	[18:0]  result;

	wire [18:0] sub_wire6;
	wire [15:0] sub_wire5 = data4x[15:0];
	wire [15:0] sub_wire4 = data3x[15:0];
	wire [15:0] sub_wire3 = data2x[15:0];
	wire [15:0] sub_wire2 = data1x[15:0];
	wire [15:0] sub_wire0 = data0x[15:0];
	wire [79:0] sub_wire1 = {sub_wire5, sub_wire4, sub_wire3, sub_wire2, sub_wire0};
	wire [18:0] result = sub_wire6[18:0];

	parallel_add	parallel_add_component (
				.data (sub_wire1),
				.result (sub_wire6)
				// synopsys translate_off
				,
				.aclr (),
				.clken (),
				.clock ()
				// synopsys translate_on
				);
	defparam
		parallel_add_component.msw_subtract = "NO",
		parallel_add_component.pipeline = 0,
		parallel_add_component.representation = "SIGNED",
		parallel_add_component.result_alignment = "LSB",
		parallel_add_component.shift = 0,
		parallel_add_component.size = 5,
		parallel_add_component.width = 16,
		parallel_add_component.widthr = 19;


endmodule


