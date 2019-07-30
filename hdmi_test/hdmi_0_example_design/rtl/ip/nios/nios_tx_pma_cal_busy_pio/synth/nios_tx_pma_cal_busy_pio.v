// nios_tx_pma_cal_busy_pio.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module nios_tx_pma_cal_busy_pio (
		input  wire        clk,        //                 clk.clk
		input  wire        reset_n,    //               reset.reset_n
		input  wire [1:0]  address,    //                  s1.address
		input  wire        write_n,    //                    .write_n
		input  wire [31:0] writedata,  //                    .writedata
		input  wire        chipselect, //                    .chipselect
		output wire [31:0] readdata,   //                    .readdata
		input  wire        in_port,    // external_connection.export
		output wire        irq         //                 irq.irq
	);

	nios_tx_pma_cal_busy_pio_altera_avalon_pio_181_boura4q tx_pma_cal_busy_pio (
		.clk        (clk),        //   input,   width = 1,                 clk.clk
		.reset_n    (reset_n),    //   input,   width = 1,               reset.reset_n
		.address    (address),    //   input,   width = 2,                  s1.address
		.write_n    (write_n),    //   input,   width = 1,                    .write_n
		.writedata  (writedata),  //   input,  width = 32,                    .writedata
		.chipselect (chipselect), //   input,   width = 1,                    .chipselect
		.readdata   (readdata),   //  output,  width = 32,                    .readdata
		.in_port    (in_port),    //   input,   width = 1, external_connection.export
		.irq        (irq)         //  output,   width = 1,                 irq.irq
	);

endmodule