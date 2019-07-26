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


// *********************************************************************
// Description
// 
// Clock domain crossing synchronizers 
//
// *********************************************************************

// synopsys translate_off
`timescale 1ns / 1ns
// synopsys translate_on
`default_nettype none

//--------------------------------------------------
// Clock crossing for static or almost static data
//
// Input data is periodically sampled and transferred
// to the output.
// When in_clk < out_clk/2 input data maybe lost if
// its duration is only one in_clk cycle
//--------------------------------------------------

module clock_crosser 
(
  in, 
  in_clk,  // Used for W > 1
  in_reset, 

  out, 
  out_clk, 
  out_reset
);

parameter W=1;
parameter DEPTH=2; // Must be at least 2
   
input wire [W-1:0] in;
input wire in_clk, in_reset, out_clk, out_reset;
output wire [W-1:0] out;

generate
  if(W == 1)
  begin

    //-------------------------------------
    // 1-bit clock crossing
    // Input sampled @ every out_clk cycle
    //-------------------------------------

    (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*clock_crosser:*|data_out_sync0}]\" " *) reg data_out_sync0 /* synopsys translate_off */ = 0 /* synopsys translate_on */;
    (* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON" *) reg [DEPTH-2:0] data_out_sync1 /* synopsys translate_off */ = 0 /* synopsys translate_on */;

    always @ (posedge out_reset or posedge out_clk)
      if(out_reset) 
      begin
        data_out_sync0 <= 1'b0;
        data_out_sync1 <= {DEPTH-1{1'b0}};
      end 
      else 
      begin
        data_out_sync0 <= in;
        if (DEPTH < 3) begin
          data_out_sync1 <= data_out_sync0;
        end else begin	 
          data_out_sync1 <= {data_out_sync1[DEPTH-3:0], data_out_sync0};
        end	   
      end

    assign out = data_out_sync1[DEPTH-2];
    
  end
  else
  begin

    //------------------------------------------------------
    // N-bit clock crossing using an handshake synchronizer
    // Input NOT sampled @ every out_clk cycle
    // Sampling period depends on in_clk/out_clk ratio
    //------------------------------------------------------

    (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*clock_crosser:*|in_ready}] -to [get_keepers {*clock_crosser:*|in_ready_r[0]}]\" "} *) reg in_ready /* synopsys translate_off */ = 0 /* synopsys translate_on */;
    (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*clock_crosser:*|in_ack}] -to [get_keepers {*clock_crosser:*|in_ack_r[0]}]\" "} *) reg in_ack /* synopsys translate_off */ = 0 /* synopsys translate_on */;
    (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [DEPTH-1:0] in_ack_r;   
    (* altera_attribute = {"-name SDC_STATEMENT \"set_false_path -from [get_keepers {*clock_crosser:*|in_r[*]}] -to [all_registers]\" "} *) reg [W-1:0] in_r;
    always @ (posedge in_clk or posedge in_reset)
      if(in_reset)
      begin
        in_ready <= 1'b0;
        in_ack_r <= {DEPTH{1'b0}};
        in_r <= {W{1'b0}};
      end
      else
      begin        
        in_ack_r <= {in_ack_r[DEPTH-2:0],in_ack};
        if(~in_ready & ~in_ack_r[DEPTH-1])
        begin
          in_ready <= 1'b1;
          in_r <= in;
        end
        else if(in_ack_r[DEPTH-1])
          in_ready <= 1'b0;
      end

    (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [DEPTH-1:0] in_ready_r;   
    reg [W-1:0] data_out /* synthesis ALTERA_ATTRIBUTE = "disable_da_rule=\"D101,D102\"" */;
    always @ (posedge out_clk or posedge out_reset)
      if(out_reset)
      begin
        in_ack <= 1'b0;
        in_ready_r <= {DEPTH{1'b0}};
        data_out <= {W{1'b0}};
      end
      else
      begin
        in_ready_r <= {in_ready_r[DEPTH-2:0],in_ready};
        if(in_ack & ~in_ready_r[DEPTH-1])
          in_ack <= 1'b0;
        else if(~in_ack & in_ready_r[DEPTH-1])
        begin
          in_ack <= 1'b1;
          data_out <= in_r;
        end
      end
  
    assign  out = data_out;

  end // if(W != 1)
  
endgenerate

endmodule
