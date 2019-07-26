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

module altera_hdmi_aux_src(

clk, reset,

// Rising edge requests packet send
in_valid,
in_ready,
done,


// Exported payload input
hb0,
hb1,
hb2,

// Payload input
pb,


// Avalon ST-output
out_data,
out_sop,
out_eop,
out_valid,
out_ready


);

input wire clk, reset;

input wire [7:0] hb0,hb1,hb2;

input wire [8*28-1:0] pb;
				 
input wire in_valid;
output wire in_ready;
output wire done; // Asserts when EOP is sent

// Avalon ST-output
output wire [71:0] out_data;
output wire out_sop;
output wire out_eop;
output wire out_valid;
input  wire out_ready;

// Signal the packet has been sent
assign done = out_eop & out_valid;

// Fanout payload
wire [7:0] pb0,pb1,pb2,pb3,pb4,
         pb5,pb6,pb7,pb8,pb9,
				 pb10,pb11,pb12,pb13,
				 pb14,pb15,pb16,pb17,
				 pb18,pb19,pb20,pb21,
				 pb22,pb23,pb24,pb25,
				 pb26,pb27;
				 
		
assign {pb0,pb1,pb2,pb3,pb4,
        pb5,pb6,pb7,pb8,pb9,
	     pb10,pb11,pb12,pb13,
		  pb14,pb15,pb16,pb17,
		  pb18,pb19,pb20,pb21,
		  pb22,pb23,pb24,pb25,
		  pb26,pb27} = pb;

reg [3:0] state;
always @(posedge clk or posedge reset)
  if(reset)
    begin
	  state <= 0;
	 end
  else
    begin
	  case(state)
	    0 : begin 
		  state <= (in_valid &  out_ready) ? 4'd1 : 4'd0;
		end
   	1 : begin
		  state <= (out_ready) ? 4'd2 : 4'd1; 
		end
		2 : begin 
		  state <= (out_ready) ? 4'd3 : 4'd2;
		end
		3 : begin 
		  state <= (out_ready) ? 4'd0 : 4'd3; 
		end
		default :
		  state <= 0;
	  endcase
	 end
	 
assign out_valid = in_valid;
assign in_ready  = out_ready;

assign out_data = 72'd0
                | {72{in_valid &  out_ready & (state == 0)}} & {pb22, pb21, pb15, pb14, pb8,  pb7,  pb1,  pb0, hb0} 
                | {72{in_valid &  out_ready & (state == 1)}} & {pb24, pb23, pb17, pb16, pb10, pb9,  pb3,  pb2, hb1}
                | {72{in_valid &  out_ready & (state == 2)}} & {pb26, pb25, pb19, pb18, pb12, pb11, pb5,  pb4, hb2}
                | {72{in_valid &  out_ready & (state == 3)}} & {8'd0, pb27, 8'd0, pb20, 8'd0, pb13, 8'd0, pb6, 8'd0};
                
assign out_sop = in_valid &  out_ready & (state == 0);
assign out_eop = in_valid &  out_ready & (state == 3);
endmodule