	bram u0 (
		.data     (_connected_to_data_),     //   input,  width = 24,     data.datain
		.q        (_connected_to_q_),        //  output,  width = 24,        q.dataout
		.address  (_connected_to_address_),  //   input,  width = 11,  address.address
		.wren     (_connected_to_wren_),     //   input,   width = 1,     wren.wren
		.inclock  (_connected_to_inclock_),  //   input,   width = 1,  inclock.clk
		.outclock (_connected_to_outclock_)  //   input,   width = 1, outclock.clk
	);

