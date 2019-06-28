// bram.v

// Generated using ACDS version 19.1 240

`timescale 1 ps / 1 ps
module bram (
		input  wire [15:0] data_a,    //    data_a.datain_a
		output wire [15:0] q_a,       //       q_a.dataout_a
		input  wire [15:0] data_b,    //    data_b.datain_b
		output wire [15:0] q_b,       //       q_b.dataout_b
		input  wire [5:0]  address_a, // address_a.address_a
		input  wire [5:0]  address_b, // address_b.address_b
		input  wire        wren_a,    //    wren_a.wren_a
		input  wire        wren_b,    //    wren_b.wren_b
		input  wire        clock      //     clock.clk
	);

	bram_ram_2port_191_w2okdta ram_2port_0 (
		.data_a    (data_a),    //   input,  width = 16,    data_a.datain_a
		.q_a       (q_a),       //  output,  width = 16,       q_a.dataout_a
		.data_b    (data_b),    //   input,  width = 16,    data_b.datain_b
		.q_b       (q_b),       //  output,  width = 16,       q_b.dataout_b
		.address_a (address_a), //   input,   width = 6, address_a.address_a
		.address_b (address_b), //   input,   width = 6, address_b.address_b
		.wren_a    (wren_a),    //   input,   width = 1,    wren_a.wren_a
		.wren_b    (wren_b),    //   input,   width = 1,    wren_b.wren_b
		.clock     (clock)      //   input,   width = 1,     clock.clk
	);

endmodule