module brams_conv0_mp0 #(
	parameter BD = 18)
(
	input clk,
	input reset,
	input [BD*3-1:0] bram_datain,
	input [10:0] bramaddr0, bramaddr1, bramaddr2, bramaddr3,
	input wren0, wren1, wren2, wren3,
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

bram1 bram0a  (
	.data		(bram_datain[BD*3-1:BD*2]),//18bit
	.address	(bramaddr0),//11bit
	.wren		(wren0),
	.clock	(clk),
	.q		(q0a) //24bit
);

bram1 bram0b  (
	.data		(bram_datain[BD*2-1:BD*1]),//18bit
	.address	(bramaddr0),//11bit
	.wren		(wren0),
	.clock	(clk),
	.q		(q0b) //24bit
);

bram1 bram0c  (
	.data		(bram_datain[BD*1-1:0]),//18bit
	.address	(bramaddr0),//11bit
	.wren		(wren0),
	.clock	(clk),
	.q		(q0c) //24bit
);
bram1 bram1a  (
	.data		(bram_datain[BD*3-1:BD*2]),//18bit
	.address	(bramaddr1),//11bit
	.wren		(wren1),
	.clock	(clk),
	.q		(q1a) //24bit
);

bram1 bram1b  (
	.data		(bram_datain[BD*2-1:BD*1]),//18bit
	.address	(bramaddr1),//11bit
	.wren		(wren1),
	.clock	(clk),
	.q		(q1b) //24bit
);

bram1 bram1c  (
	.data		(bram_datain[BD*1-1:0]),//18bit
	.address	(bramaddr1),//11bit
	.wren		(wren1),
	.clock	(clk),
	.q		(q1c) //24bit
);
bram1 bram2a  (
	.data		(bram_datain[BD*3-1:BD*2]),//18bit
	.address	(bramaddr2),//11bit
	.wren		(wren2),
	.clock	(clk),
	.q		(q2a) //24bit
);

bram1 bram2b  (
	.data		(bram_datain[BD*2-1:BD*1]),//18bit
	.address	(bramaddr2),//11bit
	.wren		(wren2),
	.clock	(clk),
	.q		(q2b) //24bit
);

bram1 bram2c  (
	.data		(bram_datain[BD*1-1:0]),//18bit
	.address	(bramaddr2),//11bit
	.wren		(wren2),
	.clock	(clk),
	.q		(q2c) //24bit
);
bram1 bram3a  (
	.data		(bram_datain[BD*3-1:BD*2]),//18bit
	.address	(bramaddr3),//11bit
	.wren		(wren3),
	.clock	(clk),
	.q		(q3a) //24bit
);

bram1 bram3b  (
	.data		(bram_datain[BD*2-1:BD*1]),//18bit
	.address	(bramaddr3),//11bit
	.wren		(wren3),
	.clock	(clk),
	.q		(q3b) //24bit
);

bram1 bram3c  (
	.data		(bram_datain[BD*1-1:0]),//18bit
	.address	(bramaddr3),//11bit
	.wren		(wren3),
	.clock	(clk),
	.q		(q3c) //24bit
);
endmodule 
