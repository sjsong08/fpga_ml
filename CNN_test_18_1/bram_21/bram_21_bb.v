module bram_21 (
		input  wire [20:0] data,    //    data.datain
		output wire [20:0] q,       //       q.dataout
		input  wire [10:0] address, // address.address
		input  wire        wren,    //    wren.wren
		input  wire        clock,   //   clock.clk
		input  wire        rden     //    rden.rden
	);
endmodule

