// output_buf_i2c.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module output_buf_i2c (
		output wire [0:0] dataout, //   dout.export
		input  wire [0:0] datain,  //    din.export
		input  wire [0:0] oe,      //     oe.export
		inout  wire [0:0] dataio   // pad_io.export
	);

	output_buf_i2c_altera_gpio_181_eva6c2y output_buf_i2c (
		.dataout (dataout), //  output,  width = 1,   dout.export
		.datain  (datain),  //   input,  width = 1,    din.export
		.oe      (oe),      //   input,  width = 1,     oe.export
		.dataio  (dataio)   //   inout,  width = 1, pad_io.export
	);

endmodule