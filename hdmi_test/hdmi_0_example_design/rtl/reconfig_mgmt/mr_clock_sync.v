// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module mr_clock_sync #(
    parameter DEVICE_FAMILY = "Arria V",
    parameter SYMBOLS_PER_CLOCK = 4		       
) (
    input  wire                            wrclk,
    input  wire                            rdclk,
    input  wire                            aclr,    
    input  wire                            wrreq,
    input  wire [SYMBOLS_PER_CLOCK*10-1:0] data,
    input  wire                            rdreq,
    output wire [SYMBOLS_PER_CLOCK*10-1:0] q
);

reg        rd;
wire [7:0] rdusedw;
wire       rdempty;
wire       rdreq_i;
wire       wrfull;
wire       wrreq_i;
always @ (posedge rdclk or posedge aclr)
begin
    if (aclr) begin
        rd <= 1'b0;
    end else begin
        if (rdusedw[7]) begin
            rd <= 1'b1;
        end	    
    end       
end 

assign rdreq_i = rd & ~rdempty & rdreq;
assign wrreq_i = ~wrfull & wrreq;
  
fifo u_dcfifo_inst (
    .rdclk (rdclk), 
    .wrclk (wrclk),
    .wrreq (wrreq_i),
    .aclr (aclr), 
    .data (data),
    .rdreq (rdreq_i),
    .q (q),
    .rdempty (rdempty),
    .rdusedw (rdusedw),
    .wrfull (wrfull)	   
);
   
endmodule		
