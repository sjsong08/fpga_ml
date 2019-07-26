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


module mr_rate_detect 
#(
    parameter [23:0] CYC_MEASURE_CLK_IN_10_MSEC = 24'h0F4240 // 100MHz clock has 0x0F4240 samples in ten milliseconds 
) 
(
    input  wire        refclock,         // clock to be measured
    input  wire        measure_clk,      // fixed reference clock to this module, eg. 100MHz
    input  wire        reset,            // reset signal 
    input  wire        enable,	 
    output wire [23:0] refclock_measure,
    output wire        valid
);

wire refclock_rst_sync;
altera_reset_controller #(
    .NUM_RESET_INPUTS (1),
    .SYNC_DEPTH (3)			  
) u_refclock_rst_sync (
    .reset_in0 (reset),
    .clk (refclock),
    .reset_out (refclock_rst_sync)
);

reg [23:0] count_measure_clk;
reg [23:0] count_refclock;
reg [23:0] refclock_measure_min2;
reg [23:0] refclock_measure_min1;
reg [23:0] refclock_measure_min0;
//reg        latch;
wire       latch_count;
reg        gate;
reg        valid_r1;
reg [1:0]  valid_count;
reg        gate_min2;
reg        gate_min1;
reg        gate_min0;
always @ (posedge measure_clk or posedge reset)
begin
    if (reset) begin
        count_measure_clk <= 24'd0;       
        //count_refclock <= 24'd0;
        //latch <= 1'b0;
        gate <= 1'b0;
        valid_r1 <= 1'b0;
        valid_count <= 2'd0;
        refclock_measure_min2 <= 24'hFFFFFF;
        refclock_measure_min1 <= 24'hFFFFFF;
        refclock_measure_min0 <= 24'hFFFFFF;                                                   
    end else if (enable) begin
        if (count_measure_clk == CYC_MEASURE_CLK_IN_10_MSEC - 2) begin
            //latch <= 1'b1;
            count_measure_clk <= count_measure_clk + 24'd1;            
        end else if (count_measure_clk == CYC_MEASURE_CLK_IN_10_MSEC - 1) begin
            count_measure_clk <= 24'd0;
            gate <= ~gate;
            //latch <= 1'b0;                                  
        end else begin
            count_measure_clk <= count_measure_clk + 24'd1;
            //latch <= 1'b0;                  
        end
         
        //if (latch & gate) begin
        if (latch_count) begin
            //valid <= 1'b1;
            refclock_measure_min2 <= count_refclock;
            refclock_measure_min1 <= refclock_measure_min2;
            refclock_measure_min0 <= refclock_measure_min1; 

            if (valid_count < 2) begin            
                valid_count <= valid_count+ 2'd1;
            end else begin
                valid_r1 <= 1'b1;            
            end                                                    
        end else begin
            valid_r1 <= 1'b0;         
        end                        
    end else begin
        count_measure_clk <= 24'd0;       
        //count_refclock <= 24'd0;
        //latch <= 1'b0;
        gate <= 1'b0;
        valid_r1 <= 1'b0;
        valid_count <= 2'd0;
        refclock_measure_min2 <= 24'hFFFFFF;
        refclock_measure_min1 <= 24'hFFFFFF;
        refclock_measure_min0 <= 24'hFFFFFF; 
    end
end  
  
always @ (posedge refclock or posedge refclock_rst_sync)
begin
    if (refclock_rst_sync) begin
        count_refclock <= 24'd0;
        gate_min2 <= 1'b0; 
        gate_min1 <= 1'b0;
        gate_min0 <= 1'b0;                        
    end else if (enable) begin
        gate_min2 <= gate; 
        gate_min1 <= gate_min2;
        gate_min0 <= gate_min1;
        
        if (gate_min0) begin
            count_refclock <= count_refclock + 24'd1;         
        end else if (gate_min1 && ~gate_min0) begin
            count_refclock <= 24'd0;
        end                    
    end else begin
        count_refclock <= 24'd0;
        gate_min2 <= 1'b0; 
        gate_min1 <= 1'b0;
        gate_min0 <= 1'b0;                        
    end 	 
end  

assign refclock_measure = refclock_measure_min0;
assign valid = valid_r1;
   
//----------------------------------------------------------------------------
// Capture & hold incoming signal in its own domain:
// capture can only follow input when sig_o_dd == capture.
reg capture, capture_d, capture_dd, sig_o_d, sig_o_dd;
always @(posedge refclock or posedge refclock_rst_sync)
   begin: capture_block
   if (refclock_rst_sync)
      capture <= 1'b0;
   else
      if (capture ^ sig_o_dd) // Signals differ
         capture <= capture;
      else                    // Signals are the same or X
         capture <= gate_min0 && ~gate_min1;
end

//----------------------------------------------------------------------------
// Change domains:
// Get rid of metastability.
reg sig_o_reg;
reg sig_o_p_reg;
always @(posedge measure_clk or posedge reset)
   if (reset)
      begin
      capture_d <= 0;
      capture_dd <= 0;
      end
   else
      begin
      capture_d <= capture;
      sig_o_reg <= capture_d;
      capture_dd <= capture_d;
      sig_o_p_reg <= capture_d && ~capture_dd;
      end

assign latch_count = sig_o_p_reg;

//----------------------------------------------------------------------------
// Cross back into incoming domain for comparison:

always @(posedge refclock or posedge refclock_rst_sync)
   if (refclock_rst_sync)
      begin
      sig_o_d <= 0;
      sig_o_dd <= 0;
      end
   else
      begin
      sig_o_d <= sig_o_reg;
      sig_o_dd <= sig_o_d;
      end

endmodule
