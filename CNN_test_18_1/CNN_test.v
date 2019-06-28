module CNN_test(
	input clk,
	
	output resulta

);

parameter bit_depth = 16;
wire [bit_depth*9-1:0] in;

wire [15:0] resulta;
wire [3:0] in_source;
conv_layer layer0(
	.clk	(clk),
	.RESET		(in_source[3]),
	.start_wr	(in_source[0]),
	.start_rd	(in_source[1]),
	.result		(resulta),
	.in			(in)
);


issp u1(
	.probe	(resulta),
	.source	(in_source)
);




assign in = {9{16'd1}};

endmodule
