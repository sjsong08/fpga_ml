module CNN_test(
	input clk,
	
	output resulta

);




wire [23:0] in0_q, in1_q, in2_q, in3_q;
wire in0_rden, in1_rden, in2_rden, in3_rden;
wire [62:0] result_1;

wire fin_rd, de_out1;
wire [4:0] rd_addr;


conv_layer conv1(
	.clk		(clk),
	.RESET		(rst),
	.start_rd	(start_rd),
	.in0_q		(in0_q),	
	.in1_q		(in1_q),	
	.in2_q		(in2_q),	
	.in3_q		(in3_q),
	
	.in0_rden	(in0_rden),
	.in1_rden	(in1_rden),
	.in2_rden	(in2_rden),
	.in3_rden 	(in3_rden),
	.in_addr	(rd_addr),

	.result		(result1),
	.fin_rd		(fin_rd),
	.de_out		(de_out1)
);

wire de_out2;
wire a, b, c, d;
assign a = 1'b1;
assign b = 1'b1;
assign c = 1'b1;
assign d = 1'b1;

wire [20:0] e,f ,g, h;

mid_bram mid_bram1(
	.clk		(clk),
	.RESET		(rst),

	.start_wr	(fin_rd),
	.in		(result1),
	.de_in		(de_out1),

	.in0_rden	(a),
	.in1_rden	(b),
	.in2_rden	(c),
	.in3_rden	(d),
	
	.de_out		(de_out2),
	.in0_q		(e),
	.in1_q		(f),
	.in2_q		(g),
	.in3_q		(h)
);


endmodule
