module brams_hdmi_conv0(
	input clk,
	input reset,
	input [23:0] bram_datain,
	input [10:0] bramaddr0, bramaddr1, bramaddr2, bramaddr3,
	input	wren0, wren1, wren2, wren3,
	output [23:0] q0, q1, q2, q3
);


bram bram0  (
	.data		(bram_datain),//24bit
	.address	(bramaddr0),//11bit
	.wren		(wren0),
	.inclock	(clk),
	.outclock(clk),
	.q			(q0) //24bit
);
bram bram1  (
	.data		(bram_datain),//24bit
	.address	(bramaddr1),//11bit
	.wren		(wren1),
	.inclock	(clk),
	.outclock(clk),
	.q			(q1) //24bit
);
bram bram2  (
	.data		(bram_datain),//24bit
	.address	(bramaddr2),//11bit
	.wren		(wren2),
	.inclock	(clk),
	.outclock(clk),
	.q			(q2) //24bit
);
bram bram3  (
	.data		(bram_datain),//24bit
	.address	(bramaddr3),//11bit
	.wren		(wren3),
	.inclock	(clk),
	.outclock(clk),
	.q			(q3) //24bit
);


endmodule 