module cnn(
	input [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8,
	input [15:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, 
	output [15:0] result
);

wire [63:0] result01, result23, result45, result67, result8;

fixedDSP conv0_01(
	.ax		({2'b00, in0}),
	.ay		({2'b00, w0}),
	.bx		({2'b00, in1}),
	.by		({2'b00, w1}),
	.resulta	(result01)
);

fixedDSP conv0_23(
	.ax		({2'b00, in2}),
	.ay		({2'b00, w2}),
	.bx		({2'b00, in3}),
	.by		({2'b00, w3}),
	.resulta	(result23)
);

fixedDSP conv0_45(
	.ax		({2'b00, in4}),
	.ay		({2'b00, w4}),
	.bx		({2'b00, in5}),
	.by		({2'b00, w5}),
	.resulta	(result45)
);

fixedDSP conv0_67(
	.ax		({2'b00, in6}),
	.ay		({2'b00, w6}),
	.bx		({2'b00, in7}),
	.by		({2'b00, w7}),
	.resulta	(result67)
);

fixedDSP conv0_8(
	.ax		({2'b00, in8}),
	.ay		({2'b00, w8}),
	.bx		(18'd0),
	.by		(18'd0),
	.resulta	(result8)
);


paral_add add0(
	.data0x	(result01[15:0]),
	.data1x	(result23[15:0]),
	.data2x	(result45[15:0]),
	.data3x	(result67[15:0]),
	.data4x	(result8[15:0]),
	.result	(result)
);


endmodule
