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


//
// This ROM stores the address offset for PLL that needs reconfig
//
module mr_rom_pll_dprioaddr #(
    parameter ROM_SIZE        = 8,
    parameter TOTAL_ROM_DEPTH = 7,
    parameter ADDR_WIDTH      = 3			      
) (
    input  wire                  clock,
    input  wire [ADDR_WIDTH-1:0] addr_ptr,
    output wire [ROM_SIZE-1:0]   rdata_out
);

reg  [ROM_SIZE-1:0]   ROM [0:TOTAL_ROM_DEPTH-1];
wire [ROM_SIZE-1:0]   DATAA = {ROM_SIZE{1'b0}};
wire [ADDR_WIDTH-1:0] RADDR;
   
initial begin
           // ADDR_OFST 
    ROM[0] <= 8'h90; // m
    ROM[1] <= 8'hA0; // n
    ROM[2] <= 8'hC0; // c0
    ROM[3] <= 8'hC1; // c1
    ROM[4] <= 8'hC2; // c2
    ROM[5] <= 8'h20; // cp
    ROM[6] <= 8'h40; // bw
    // Set the rest to all zeros
    ROM[7] <= 8'h00;
end

// write is unused
wire [ADDR_WIDTH-1:0] ADDRA = {ADDR_WIDTH{1'b0}}; 
wire                  WEA   = 1'b0; 
always @ (posedge clock)
begin
    if (WEA) begin
        ROM[ADDRA] <= DATAA;
    end
end
   
assign RADDR = addr_ptr;
   
reg [ROM_SIZE-1:0] RDATA;
always @ (posedge clock)
begin
     RDATA <= ROM[RADDR];
end

assign rdata_out = RDATA;
   
endmodule			      