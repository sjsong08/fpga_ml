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
// This ROM stores the address offset and bitmask for GXB RX that needs reconfig
//
// addr_ofst - the address offset that needs reconfig
// field_bitmask - the bit that needs reconfig (eg. 8'h40 means only bit 6 needs reconfig)
//
module mr_rom_rx_dprioaddr_bitmask #(
    parameter ROM_SIZE        = 18, // number of bits per rom address - [17:8] address offset, [7:0] field bitmask   
    parameter TOTAL_ROM_DEPTH = 16, // ROM_DEPTH_FOR_EACH_MIF_RANGE - total attributes that needs reconfig
    parameter ADDR_WIDTH      = 3   // alt_clogb2(7)
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
            // ADDR_OFST, FIELD_BITMASK
    ROM[ 0] <= {10'h132, 8'h05}; // [2] cdr_pll_set_cdr_vco_speed_fix, [0] cdr_pll_set_cdr_vco_speed_fix
    ROM[ 1] <= {10'h134, 8'h40}; // [6] cdr_pll_set_cdr_vco_speed_fix
    ROM[ 2] <= {10'h135, 8'h4F}; // [6] cdr_pll_set_cdr_vco_speed_fix, [3:2] cdr_pll_lf_resistor_pd, [1:0] cdr_pll_lf_resistor_pfd
    ROM[ 3] <= {10'h136, 8'h0F}; // [3:0] cdr_pll_set_cdr_vco_speed_fix
    ROM[ 4] <= {10'h137, 8'h7C}; // [6:2] cdr_pll_set_cdr_vco_speed
    ROM[ 5] <= {10'h139, 8'h87}; // [7] cdr_pll_pd_fastlock_mode, [2:0] cdr_pll_chgpmp_current_pfd
    ROM[ 6] <= {10'h13A, 8'hFF}; // [7:6] cdr_pll_fref_clklow_div, [5:3] cdr_pll_pd_l_counter, [2:0] cdr_pll_pfd_l_counter
    ROM[ 7] <= {10'h13B, 8'hFF}; // [7:0] cdr_pll_m_counter
    ROM[ 8] <= {10'h13C, 8'h0C}; // [3:2] cdr_pll_n_counter
    ROM[ 9] <= {10'h033, 8'h0F}; // Backup: {10'h04C, 8'h70}; 
    ROM[10] <= {10'h038, 8'hFF};
    ROM[11] <= {10'h037, 8'hFF};
    ROM[12] <= {10'h036, 8'h0F};
    // Set the rest to all zeros
    ROM[13] <= {10'h000, 8'h00};
    ROM[14] <= {10'h000, 8'h00};
    ROM[15] <= {10'h000, 8'h00};   
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
