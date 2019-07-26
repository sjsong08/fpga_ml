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



module mr_ce #(
  parameter [3:0] OVERSAMPLE_RATE = 4'd5
)
(
    input  wire clk,
    input  wire rst,
    output wire txdata_valid,
    output wire txdata_valid_r
);

reg [3:0] count;
always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      count <= 4'd0;
   end else begin
      if (count != OVERSAMPLE_RATE) begin
         count <= count + 4'd1;
      end else begin
         count <= 4'd1;
      end
   end
end

assign txdata_valid = count == 4'd1;
assign txdata_valid_r = count == 4'd2;

endmodule