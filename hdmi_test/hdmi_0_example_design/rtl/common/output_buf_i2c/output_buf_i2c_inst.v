	output_buf_i2c u0 (
		.dataout (_connected_to_dataout_), //  output,  width = 1,   dout.export
		.datain  (_connected_to_datain_),  //   input,  width = 1,    din.export
		.oe      (_connected_to_oe_),      //   input,  width = 1,     oe.export
		.dataio  (_connected_to_dataio_)   //   inout,  width = 1, pad_io.export
	);

