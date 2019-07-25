// bram_1port.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module bram_1port (
		input  wire [62:0] data,    //    data.datain
		output wire [62:0] q,       //       q.dataout
		input  wire [4:0]  address, // address.address
		input  wire        wren,    //    wren.wren
		input  wire        clock,   //   clock.clk
		input  wire        rden     //    rden.rden
	);

	bram_1port_ram_1port_181_b5j5wiy ram_1port_0 (
		.data    (data),    //   input,  width = 63,    data.datain
		.q       (q),       //  output,  width = 63,       q.dataout
		.address (address), //   input,   width = 5, address.address
		.wren    (wren),    //   input,   width = 1,    wren.wren
		.clock   (clock),   //   input,   width = 1,   clock.clk
		.rden    (rden)     //   input,   width = 1,    rden.rden
	);

endmodule