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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// synthesis translate_off
`timescale 1ns / 1ns
// synthesis translate_on

module altera_hdmi_aux_snk(

clk, reset,

in_data,
in_sop,
in_eop,
in_valid,

hb0,
hb1,
hb2,
hbch,
pb,

valid0,
valid1,
valid2,
valid3

);
parameter [7:0] HB = 8'h84;

input wire clk, reset;
input wire [71:0] in_data;
input wire in_sop;
input wire in_eop;
input wire in_valid;

output reg [7:0] hb0,hb1,hb2, hbch;

// Payload
output wire [28*8-1:0] pb;
				 
output reg valid0,valid1,valid2,valid3;

reg [7:0] pb0,pb1,pb2,pb3,pb4,
				 pb5,pb6,pb7,pb8,pb9,
				 pb10,pb11,pb12,pb13,
				 pb14,pb15,pb16,pb17,
				 pb18,pb19,pb20,pb21,
				 pb22,pb23,pb24,pb25,
				 pb26,pb27,bch0,bch1,
				 bch2,bch3;
         
reg [3:0] state;

// Fanout Payload
assign pb = {pb0,pb1,pb2,pb3,pb4,
				 pb5,pb6,pb7,pb8,pb9,
				 pb10,pb11,pb12,pb13,
				 pb14,pb15,pb16,pb17,
				 pb18,pb19,pb20,pb21,
				 pb22,pb23,pb24,pb25,
				 pb26,pb27,bch0,bch1,
				 bch2,bch3};


always @(posedge clk or posedge reset)
  if(reset)
    begin
		{ hb0,hb1,hb2, hbch,
		  pb0,pb1,pb2,pb3,pb4,
		  pb5,pb6,pb7,pb8,pb9,
		  pb10,pb11,pb12,pb13,
		  pb14,pb15,pb16,pb17,
		  pb18,pb19,pb20,pb21,
		  pb22,pb23,pb24,pb25,
		  pb26,pb27,
		  bch0,bch1,bch2,bch3} <= 0;
		  state <= 0;
	 end
  else
    begin
	   case(state)
		   0 : begin 
			       state  <= (in_valid & in_sop) ? 4'd1 : 4'd0;
					 {pb22, pb21, pb15, pb14, pb8,  pb7,  pb1,  pb0, hb0} <= (in_valid & in_sop) ? in_data : {pb22, pb21, pb15, pb14, pb8,  pb7,  pb1,  pb0, hb0};
				 end
   		1 : begin
			      state <= (in_valid) ? 4'd2 : 4'd1; 
			      {pb24, pb23, pb17, pb16, pb10, pb9,  pb3,  pb2, hb1}  <= (in_valid) ?  in_data : {pb24, pb23, pb17, pb16, pb10, pb9,  pb3,  pb2, hb1};
				 end
		   2 : begin 
			       state <= (in_valid) ? 4'd3 : 4'd2;
			      {pb26, pb25, pb19, pb18, pb12, pb11, pb5,  pb4, hb2}  <= (in_valid) ?  in_data : {pb26, pb25, pb19, pb18, pb12, pb11, pb5,  pb4, hb2};
			    end
		   3 : begin 
			       state <= (in_valid) ? 4'd0 : 4'd3; 
			      {bch3, pb27, bch2, pb20, bch1, pb13, bch0, pb6, hbch} <= (in_valid) ?  in_data : {bch3, pb27, bch2, pb20, bch1, pb13, bch0, pb6, hbch};
			    end
		endcase
	 end
	 
always @(posedge clk or posedge reset)
  if(reset)
    begin
      valid0 <= 0;
      valid1 <= 0;
      valid2 <= 0;
      valid3 <= 0;
	 end
  else
    begin
      valid0 <= (state == 0 & in_sop) & in_valid;
      valid1 <= (state == 1) & in_valid;
      valid2 <= (state == 2) & in_valid;
      valid3 <= (state == 3) & in_valid;
	 end
				 
endmodule