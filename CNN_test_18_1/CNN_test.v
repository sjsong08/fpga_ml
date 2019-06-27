module CNN_test(
	input clk,
	
	output resulta

);

wire [15:0] resulta;

wire [3:0] in_source;
conv_layer layer0(
	.clk	(clk),
	.RESET		(in_source[3]),
	.sel			(in_source[2]),
	.start_wr	(in_source[0]),
	.start_rd	(in_source[1]),
	.result		(resulta),
	.in 			(in)
);

wire [431:0] in;
issp u1(
	.probe	({resulta, in}),
	.source	(in_source)
);




endmodule
