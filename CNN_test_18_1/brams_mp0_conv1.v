module brams_mp0_conv1 #(
        parameter BD = 18)
(
	input clk, reset,
	input wren0, wren1, wren2, wren3,
	input [9:0] wraddr,
	input [BD-1:0] d_a, d_b, d_c,
	 
	output [BD*3-1:0] q0, q1, q2, q3
);

assign q0 = {q0a, q0b, q0c};
assign q1 = {q1a, q1b, q1c};
assign q2 = {q2a, q2b, q2c};
assign q3 = {q3a, q3b, q3c};

wire [BD-1:0] q0a, q0b, q0c;
wire [BD-1:0] q1a, q1b, q1c;
wire [BD-1:0] q2a, q2b, q2c;
wire [BD-1:0] q3a, q3b, q3c;


bram2 bram0_a(
	.clock			(clk),
	.wren			(wren0),
	.data			(d_a),
	.address		(wraddr),
	.q			(q0a)
	);
bram2 bram0_b(
	.clock			(clk),
	.wren			(wren0),
	.data			(d_b),
	.address		(wraddr),
	.q			(q0b)
	);
bram2 bram0_c(
	.clock			(clk),
	.wren			(wren0),
	.data			(d_c),
	.address		(wraddr),
	.q			(q0c)
	);

bram2 bram1_a(
	.clock			(clk),
	.wren			(wren1),
	.data			(d_a),
	.address		(wraddr),
	.q			(q1a)
	);
bram2 bram1_b(
	.clock			(clk),
	.wren			(wren1),
	.data			(d_b),
	.address		(wraddr),
	.q			(q1b)
	);
bram2 bram1_c(
	.clock			(clk),
	.wren			(wren1),
	.data			(d_c),
	.address		(wraddr),
	.q			(q1c)
	);

bram2 bram2_a(
	.clock			(clk),
	.wren			(wren2),
	.data			(d_a),
	.address		(wraddr),
	.q			(q2a)
	);
bram2 bram2_b(
	.clock			(clk),
	.wren			(wren2),
	.data			(d_b),
	.address		(wraddr),
	.q			(q2b)
	);
bram2 bram2_c(
	.clock			(clk),
	.wren			(wren2),
	.data			(d_c),
	.address		(wraddr),
	.q			(q2c)
	);

bram2 bram3_a(
	.clock			(clk),
	.wren			(wren3),
	.data			(d_a),
	.address		(wraddr),
	.q			(q3a)
	);
bram2 bram3_b(
	.clock			(clk),
	.wren			(wren3),
	.data			(d_b),
	.address		(wraddr),
	.q			(q3b)
	);
bram2 bram3_c(
	.clock			(clk),
	.wren			(wren3),
	.data			(d_c),
	.address		(wraddr),
	.q			(q3c)
	);


endmodule
