module bram_1port (
		input  wire [62:0] data,    //    data.datain
		output wire [62:0] q,       //       q.dataout
		input  wire [4:0]  address, // address.address
		input  wire        wren,    //    wren.wren
		input  wire        clock,   //   clock.clk
		input  wire        rden     //    rden.rden
	);
endmodule

