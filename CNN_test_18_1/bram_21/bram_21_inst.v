	bram_21 u0 (
		.data    (_connected_to_data_),    //   input,  width = 21,    data.datain
		.q       (_connected_to_q_),       //  output,  width = 21,       q.dataout
		.address (_connected_to_address_), //   input,  width = 11, address.address
		.wren    (_connected_to_wren_),    //   input,   width = 1,    wren.wren
		.clock   (_connected_to_clock_),   //   input,   width = 1,   clock.clk
		.rden    (_connected_to_rden_)     //   input,   width = 1,    rden.rden
	);

