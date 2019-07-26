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
// This ROM stores the field valuemask for GXB RX that needs reconfig across various data rate ranges
//
// field_valmask - particular bit value that needs reconfig, to interpret this, get the field bitmask from the
// other ROM file, let's consider ROM[1], field bitmask=8'h0F, field valmask=8'h0A, this means the value of attribute
// cdr_pll_set_cdr_vco_speed_fix when data rate <1100Mbps is bit[3:0]=1010    
//
module mr_rom_rx_valuemask #(
    parameter NUMBER_OF_MIF_RANGE          = 16,  
    parameter ROM_DEPTH_FOR_EACH_MIF_RANGE = 9,       
    parameter ROM_SIZE                     = 8,   // number of bits per rom address - [7:0] field valmask
    parameter TOTAL_ROM_DEPTH              = 256, 
    parameter ADDR_WIDTH                   = 8    // alt_clogb2(189) 
) (
    input  wire                  clock,
    input  wire [ADDR_WIDTH-1:0] addr_ptr,
    output wire [ROM_SIZE-1:0]   rdata_out
);

reg  [ROM_SIZE-1:0]   ROM [0:TOTAL_ROM_DEPTH-1];
wire [ROM_SIZE-1:0]   DATAA = {ROM_SIZE{1'b0}};
wire [ADDR_WIDTH-1:0] RADDR;

// **** PERL SCIPT TO GENERATE BEGIN **** //   
initial begin
              // FIELD_VALMASK
    // ROM OFFSET 0 (<1100Mbps or <220Mbps)                                                  
    ROM[  0] <= 8'hB6; // [2]cdr_pll_set_cdr_vco_speed_fix, [0] cdr_pll_set_cdr_vco_speed_fix
    ROM[  1] <= 8'hC2; // [6] cdr_pll_set_cdr_vco_speed_fix
    ROM[  2] <= 8'h02; // [6] cdr_pll_set_cdr_vco_speed_fix, [3:2] cdr_pll_lf_resistor_pd, [1:0] cdr_pll_lf_resistor_pfd
    ROM[  3] <= 8'h0A; // [3:0] cdr_pll_set_cdr_vco_speed_fix
    ROM[  4] <= 8'h0B; // [6:2] cdr_pll_set_cdr_vco_speed
    ROM[  5] <= 8'hA4; // [7] cdr_pll_pd_fastlock_mode, [2:0] cdr_pll_chgpmp_current_pfd
    ROM[  6] <= 8'h33; // [7:6] cdr_pll_fref_clklow_div, [5:3] cdr_pll_pd_l_counter, [2:0] cdr_pll_pfd_l_counter
    ROM[  7] <= 8'h28; // [7:0] cdr_pll_m_counter
    ROM[  8] <= 8'h71; // [3:2] cdr_pll_n_counter
    ROM[  9] <= 8'h08; // Backup: 8'h20;
    ROM[ 10] <= 8'h54;
    ROM[ 11] <= 8'h00;
    ROM[ 12] <= 8'h00;
    // ROM OFFSET 1 (<1200Mbps or <240Mbps)
    ROM[ 13] <= 8'hB6;
    ROM[ 14] <= 8'hC2;
    ROM[ 15] <= 8'h43;
    ROM[ 16] <= 8'h04;
    ROM[ 17] <= 8'h0B;
    ROM[ 18] <= 8'hA1;
    ROM[ 19] <= 8'h33;
    ROM[ 20] <= 8'h28;
    ROM[ 21] <= 8'h71;
    ROM[ 22] <= 8'h08; 
    ROM[ 23] <= 8'h54;
    ROM[ 24] <= 8'h00;
    ROM[ 25] <= 8'h00;
    // ROM OFFSET 2 (<1300Mbps or <260Mbps)
    ROM[ 26] <= 8'hB2;
    ROM[ 27] <= 8'hC2;
    ROM[ 28] <= 8'h42;
    ROM[ 29] <= 8'h0C;
    ROM[ 30] <= 8'h0F;
    ROM[ 31] <= 8'h23;
    ROM[ 32] <= 8'h2A;
    ROM[ 33] <= 8'h28;
    ROM[ 34] <= 8'h71;
    ROM[ 35] <= 8'h08; 
    ROM[ 36] <= 8'h54;
    ROM[ 37] <= 8'h00;
    ROM[ 38] <= 8'h00;
    // ROM OFFSET 3 (<1500Mbps or <300Mbps)
    ROM[ 39] <= 8'hB2;
    ROM[ 40] <= 8'hC2;
    ROM[ 41] <= 8'h42;
    ROM[ 42] <= 8'h0C;
    ROM[ 43] <= 8'h0F;
    ROM[ 44] <= 8'h23;
    ROM[ 45] <= 8'h2B;
    ROM[ 46] <= 8'h14;
    ROM[ 47] <= 8'h71;
    ROM[ 48] <= 8'h08; 
    ROM[ 49] <= 8'h54;
    ROM[ 50] <= 8'h00;
    ROM[ 51] <= 8'h00;
    // ROM OFFSET 4 (<1700Mbps or <340Mbps)
    ROM[ 52] <= 8'hB6;
    ROM[ 53] <= 8'h82;
    ROM[ 54] <= 8'h02;
    ROM[ 55] <= 8'h0A;
    ROM[ 56] <= 8'h0F;
    ROM[ 57] <= 8'h23;
    ROM[ 58] <= 8'h2B;
    ROM[ 59] <= 8'h14;
    ROM[ 60] <= 8'h71;
    ROM[ 61] <= 8'h08; 
    ROM[ 62] <= 8'h54;
    ROM[ 63] <= 8'h00;
    ROM[ 64] <= 8'h00;
    // ROM OFFSET 5 (<2200Mbps or <440Mbps)
    ROM[ 65] <= 8'hB6;
    ROM[ 66] <= 8'hC2;
    ROM[ 67] <= 8'h02;
    ROM[ 68] <= 8'h0A;
    ROM[ 69] <= 8'h0B;
    ROM[ 70] <= 8'h22;
    ROM[ 71] <= 8'h2B;
    ROM[ 72] <= 8'h14;
    ROM[ 73] <= 8'h71;
    ROM[ 74] <= 8'h08; 
    ROM[ 75] <= 8'h54;
    ROM[ 76] <= 8'h00;
    ROM[ 77] <= 8'h00;
    // ROM OFFSET 6 (<2400Mbps or <480Mbps)
    ROM[ 78] <= 8'hB6;
    ROM[ 79] <= 8'hC2;
    ROM[ 80] <= 8'h42;
    ROM[ 81] <= 8'h04;
    ROM[ 82] <= 8'h0B;
    ROM[ 83] <= 8'h22;
    ROM[ 84] <= 8'h2B;
    ROM[ 85] <= 8'h14;
    ROM[ 86] <= 8'h71;
    ROM[ 87] <= 8'h08;
    ROM[ 88] <= 8'h54;
    ROM[ 89] <= 8'h00;
    ROM[ 90] <= 8'h00;
    // ROM OFFSET 7 (<2600Mbps or <520Mbps)
    ROM[ 91] <= 8'hB2;
    ROM[ 92] <= 8'hC2;
    ROM[ 93] <= 8'h4E;
    ROM[ 94] <= 8'h0C;
    ROM[ 95] <= 8'h0F;
    ROM[ 96] <= 8'h22;
    ROM[ 97] <= 8'h22;
    ROM[ 98] <= 8'h14;
    ROM[ 99] <= 8'h71;
    ROM[100] <= 8'h08;
    ROM[101] <= 8'h54;
    ROM[102] <= 8'h00;
    ROM[103] <= 8'h00;
    // ROM OFFSET 8 (<3000Mbps or <600Mbps)
    ROM[104] <= 8'hB2;
    ROM[105] <= 8'hC2;
    ROM[106] <= 8'h4E;
    ROM[107] <= 8'h0C;
    ROM[108] <= 8'h0F;
    ROM[109] <= 8'h22;
    ROM[110] <= 8'h23;
    ROM[111] <= 8'h0A;
    ROM[112] <= 8'h71;
    ROM[113] <= 8'h08;
    ROM[114] <= 8'h54;
    ROM[115] <= 8'h00;
    ROM[116] <= 8'h00;
    // ROM OFFSET 9 (<3400Mbps or <680Mbps)
    ROM[117] <= 8'hB6;
    ROM[118] <= 8'h82;
    ROM[119] <= 8'h0E;
    ROM[120] <= 8'h0A;
    ROM[121] <= 8'h0F;
    ROM[122] <= 8'h22;
    ROM[123] <= 8'h23;
    ROM[124] <= 8'h0A;
    ROM[125] <= 8'h71;
    ROM[126] <= 8'h08;
    ROM[127] <= 8'h54;
    ROM[128] <= 8'h00;
    ROM[129] <= 8'h00;
    // ROM OFFSET 10 (<3500Mbps or <700Mbps)
    ROM[130] <= 8'hB6;
    ROM[131] <= 8'h82;
    ROM[132] <= 8'h0E;
    ROM[133] <= 8'h0A;
    ROM[134] <= 8'h0B;
    ROM[135] <= 8'h21;
    ROM[136] <= 8'h23;
    ROM[137] <= 8'h0A;
    ROM[138] <= 8'h71;
    ROM[139] <= 8'h08;
    ROM[140] <= 8'h54;
    ROM[141] <= 8'h00;
    ROM[142] <= 8'h00;
    // ROM OFFSET 11 (<4000Mbps or <800Mbps)
    ROM[143] <= 8'hB6;
    ROM[144] <= 8'hC2;
    ROM[145] <= 8'h0E;
    ROM[146] <= 8'h0A;
    ROM[147] <= 8'h0B;
    ROM[148] <= 8'h22;
    ROM[149] <= 8'h23;
    ROM[150] <= 8'h14;
    ROM[151] <= 8'h75;
    ROM[152] <= 8'h08;
    ROM[153] <= 8'h54;
    ROM[154] <= 8'h00;
    ROM[155] <= 8'h00;
    // ROM OFFSET 12 (<4500Mbps or <900Mbps)
    ROM[156] <= 8'hB6;
    ROM[157] <= 8'hC2;
    ROM[158] <= 8'h0E;
    ROM[159] <= 8'h0A;
    ROM[160] <= 8'h0B;
    ROM[161] <= 8'h22;
    ROM[162] <= 8'h63;
    ROM[163] <= 8'h14;
    ROM[164] <= 8'h75;
    ROM[165] <= 8'h08;
    ROM[166] <= 8'h54;
    ROM[167] <= 8'h00;
    ROM[168] <= 8'h00;
    // ROM OFFSET 13 (<4800Mbps or <960Mbps)
    ROM[169] <= 8'hB6;
    ROM[170] <= 8'hC2;
    ROM[171] <= 8'h4E;
    ROM[172] <= 8'h04;
    ROM[173] <= 8'h0B;
    ROM[174] <= 8'h22;
    ROM[175] <= 8'h63;
    ROM[176] <= 8'h14;
    ROM[177] <= 8'h75;
    ROM[178] <= 8'h08;
    ROM[179] <= 8'h54;
    ROM[180] <= 8'h00;
    ROM[181] <= 8'h00;
    // ROM OFFSET 14 (<5200Mbps or <1000Mbps)
    ROM[182] <= 8'hB2;
    ROM[183] <= 8'hC2;
    ROM[184] <= 8'h4E;
    ROM[185] <= 8'h0C;
    ROM[186] <= 8'h0F;
    ROM[187] <= 8'h22;
    ROM[188] <= 8'h5A;
    ROM[189] <= 8'h14;
    ROM[190] <= 8'h75;
    ROM[191] <= 8'h08;
    ROM[192] <= 8'h54;
    ROM[193] <= 8'h00;
    ROM[194] <= 8'h00;
    // ROM OFFSET 15 (<6000Mbps)
    ROM[195] <= 8'hB2;
    ROM[196] <= 8'hC2;
    ROM[197] <= 8'h4E;
    ROM[198] <= 8'h0C;
    ROM[199] <= 8'h0F;
    ROM[200] <= 8'h22;
    ROM[201] <= 8'h5B;
    ROM[202] <= 8'h0A;
    ROM[203] <= 8'h75;
    ROM[204] <= 8'h08;
    ROM[205] <= 8'h54;
    ROM[206] <= 8'h00;
    ROM[207] <= 8'h00;
    ROM[208] <= 8'h00;
    ROM[209] <= 8'h00;
    ROM[210] <= 8'h00;
    ROM[211] <= 8'h00;
    ROM[212] <= 8'h00;
    ROM[213] <= 8'h00;
    ROM[214] <= 8'h00;
    ROM[215] <= 8'h00;
    ROM[216] <= 8'h00;
    ROM[217] <= 8'h00;
    ROM[218] <= 8'h00;
    ROM[219] <= 8'h00;
    ROM[220] <= 8'h00;
    ROM[221] <= 8'h00;
    ROM[222] <= 8'h00;
    ROM[223] <= 8'h00;
    ROM[224] <= 8'h00;
    ROM[225] <= 8'h00;
    ROM[226] <= 8'h00;
    ROM[227] <= 8'h00;
    ROM[228] <= 8'h00;
    ROM[229] <= 8'h00;
    ROM[230] <= 8'h00;
    ROM[231] <= 8'h00;
    ROM[232] <= 8'h00;
    ROM[233] <= 8'h00;
    ROM[234] <= 8'h00;
    ROM[235] <= 8'h00;
    ROM[236] <= 8'h00;
    ROM[237] <= 8'h00;
    ROM[238] <= 8'h00;
    ROM[239] <= 8'h00;
    ROM[240] <= 8'h00;
    ROM[241] <= 8'h00;
    ROM[242] <= 8'h00;
    ROM[243] <= 8'h00;
    ROM[244] <= 8'h00;
    ROM[245] <= 8'h00;
    ROM[246] <= 8'h00;
    ROM[247] <= 8'h00;
    ROM[248] <= 8'h00;
    ROM[249] <= 8'h00;
    ROM[250] <= 8'h00;
    ROM[251] <= 8'h00;
    ROM[252] <= 8'h00;
    ROM[253] <= 8'h00;
    ROM[254] <= 8'h00;
    ROM[255] <= 8'h00;  
end
// **** PERL SCIPT TO GENERATE END ****** //

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
