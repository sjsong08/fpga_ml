module nios_cpu (
		input  wire        clk,                                 //                       clk.clk
		input  wire        reset_n,                             //                     reset.reset_n
		input  wire        reset_req,                           //                          .reset_req
		output wire [18:0] d_address,                           //               data_master.address
		output wire [3:0]  d_byteenable,                        //                          .byteenable
		output wire        d_read,                              //                          .read
		input  wire [31:0] d_readdata,                          //                          .readdata
		input  wire        d_waitrequest,                       //                          .waitrequest
		output wire        d_write,                             //                          .write
		output wire [31:0] d_writedata,                         //                          .writedata
		output wire        debug_mem_slave_debugaccess_to_roms, //                          .debugaccess
		output wire [18:0] i_address,                           //        instruction_master.address
		output wire        i_read,                              //                          .read
		input  wire [31:0] i_readdata,                          //                          .readdata
		input  wire        i_waitrequest,                       //                          .waitrequest
		input  wire [31:0] irq,                                 //                       irq.irq
		output wire        debug_reset_request,                 //       debug_reset_request.reset
		input  wire [8:0]  debug_mem_slave_address,             //           debug_mem_slave.address
		input  wire [3:0]  debug_mem_slave_byteenable,          //                          .byteenable
		input  wire        debug_mem_slave_debugaccess,         //                          .debugaccess
		input  wire        debug_mem_slave_read,                //                          .read
		output wire [31:0] debug_mem_slave_readdata,            //                          .readdata
		output wire        debug_mem_slave_waitrequest,         //                          .waitrequest
		input  wire        debug_mem_slave_write,               //                          .write
		input  wire [31:0] debug_mem_slave_writedata,           //                          .writedata
		output wire        dummy_ci_port                        // custom_instruction_master.readra
	);
endmodule

