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



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  paral_add_parallel_add_181_cn5dh3i  (
	data0x,
	data1x,
	data2x,
	data3x,
	data4x,
	result);

	input	[7:0]  data0x;
	input	[7:0]  data1x;
	input	[7:0]  data2x;
	input	[7:0]  data3x;
	input	[7:0]  data4x;
	output	[10:0]  result;

	wire [10:0] sub_wire6;
	wire [7:0] sub_wire5 = data4x[7:0];
	wire [7:0] sub_wire4 = data3x[7:0];
	wire [7:0] sub_wire3 = data2x[7:0];
	wire [7:0] sub_wire2 = data1x[7:0];
	wire [7:0] sub_wire0 = data0x[7:0];
	wire [39:0] sub_wire1 = {sub_wire5, sub_wire4, sub_wire3, sub_wire2, sub_wire0};
	wire [10:0] result = sub_wire6[10:0];

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
		parallel_add_component.width = 8,
		parallel_add_component.widthr = 11;


endmodule


