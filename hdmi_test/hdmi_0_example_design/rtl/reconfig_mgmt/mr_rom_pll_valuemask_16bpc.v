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
// This ROM stores the field valuemask for PLL that need reconfig
// This file will not changed across A10 device parts 
//
module mr_rom_pll_valuemask_16bpc #(
    parameter NUMBER_OF_MIF_RANGE          = 6,
    parameter ROM_DEPTH_FOR_EACH_MIF_RANGE = 7,			      
    parameter ROM_SIZE                     = 32,   
    parameter TOTAL_ROM_DEPTH              = 42, // 6*7
    parameter ADDR_WIDTH                   = 6   // alt_clogb2(42) 
) (
    input  wire                  clock,
    input  wire [ADDR_WIDTH-1:0] addr_ptr,
    output wire [ROM_SIZE-1:0]   rdata_out
);

reg  [ROM_SIZE-1:0]   ROM [0:TOTAL_ROM_DEPTH-1];
wire [ROM_SIZE-1:0]   DATAA = {ROM_SIZE{1'b0}};
wire [ADDR_WIDTH-1:0] RADDR;
   
initial begin
            // FIELD_VALMASK
    // ROM OFFSET 0 (25MHz - 50MHz)  
    ROM[0]  <= 32'h00000F0F; // m 30
    ROM[1]  <= 32'h00010000; // n 1
    ROM[2]  <= 32'h00000303; // c0 6
    ROM[3]  <= 32'h00001E1E; // c1 60
    ROM[4]  <= 32'h00003C3C; // c2 120
    ROM[5]  <= 32'h00000010; // cp
    ROM[6]  <= 32'h00000100; // bw
    // ROM OFFSET 1 (51MHz - 70MHz)  
    ROM[7]  <= 32'h00000A0A; // m 20
    ROM[8]  <= 32'h00010000; // n 1
    ROM[9]  <= 32'h00000202; // c0 4
    ROM[10] <= 32'h00001414; // c1 40
    ROM[11] <= 32'h00002828; // c2 80
    ROM[12] <= 32'h0000000B; // cp
    ROM[13] <= 32'h000000C0; // bw
    // ROM OFFSET 2 (71MHz - 100MHz)  
    ROM[14] <= 32'h00000505; // m 10
    ROM[15] <= 32'h00010000; // n 1
    ROM[16] <= 32'h00000101; // c0 2
    ROM[17] <= 32'h00000A0A; // c1 20
    ROM[18] <= 32'h00001414; // c2 40
    ROM[19] <= 32'h00000010; // cp 
    ROM[20] <= 32'h000000C0; // bw
    // ROM OFFSET 3 (101MHz - 170MHz)  
    ROM[21] <= 32'h00000404; // m 8
    ROM[22] <= 32'h00010000; // n 1
    ROM[23] <= 32'h00000404; // c0 8
    ROM[24] <= 32'h00000808; // c1 16
    ROM[25] <= 32'h00001010; // c2 32
    ROM[26] <= 32'h00000010; // cp
    ROM[27] <= 32'h000000C0; // bw
    // ROM OFFSET 4 (171MHz - 340MHz)  
    ROM[28] <= 32'h00000202; // m 4
    ROM[29] <= 32'h00010000; // n 1
    ROM[30] <= 32'h00000202; // c0 4
    ROM[31] <= 32'h00000404; // c1 8
    ROM[32] <= 32'h00000808; // c2 16
    ROM[33] <= 32'h00000010; // cp
    ROM[34] <= 32'h000000C0; // bw
    // ROM OFFSET 5 (85.25MHz - 150MHz) - 2.0  
    ROM[35] <= 32'h00000404; // m 8
    ROM[36] <= 32'h00010000; // n 1
    ROM[37] <= 32'h00000101; // c0 2
    ROM[38] <= 32'h00000202; // c1 4
    ROM[39] <= 32'h00000404; // c2 8
    ROM[40] <= 32'h00000010; // cp
    ROM[41] <= 32'h000000C0; // bw
    // Set the rest to all zeros
    ROM[42] <= 32'h00000000;
    ROM[43] <= 32'h00000000;
    ROM[44] <= 32'h00000000;
    ROM[45] <= 32'h00000000;
    ROM[46] <= 32'h00000000;
    ROM[47] <= 32'h00000000;
    ROM[48] <= 32'h00000000;
    ROM[49] <= 32'h00000000;
    ROM[50] <= 32'h00000000;
    ROM[51] <= 32'h00000000;
    ROM[52] <= 32'h00000000;
    ROM[53] <= 32'h00000000;
    ROM[54] <= 32'h00000000;
    ROM[55] <= 32'h00000000;
    ROM[56] <= 32'h00000000;
    ROM[57] <= 32'h00000000;
    ROM[58] <= 32'h00000000;
    ROM[59] <= 32'h00000000;
    ROM[60] <= 32'h00000000;
    ROM[61] <= 32'h00000000;
    ROM[62] <= 32'h00000000;
    ROM[63] <= 32'h00000000;           
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