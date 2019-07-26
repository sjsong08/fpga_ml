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
//  PLL comparison circuitry that sequentially check the measured value against the predetermined threshold
//  and output the expected start offset pointer 
//
module mr_compare_pll #(
    parameter       FAST_SIMULATION = 0,
    parameter [2:0] MIF_OFFSET      = 7,  			
    parameter       POINTER_WIDTH   = 6, // alt_clogb2(42)  			  
    parameter       LOOPS_MAX       = 5, 		     
    parameter       LOOPS_WIDTH     = 3   
) (
    input  wire                     clock,
    input  wire                     reset,
    input  wire                     clr_valid,
    input  wire [23:0]              measure,
    input  wire                     measure_valid,
    output wire [POINTER_WIDTH-1:0] offset_pointer,
    output wire                     offset_pointer_valid,
    output wire [LOOPS_WIDTH-1:0]   range   
);

// threshold (250Mbps to 3400Mbps & equivalent TMDS clock 25MHz to 340MHz)
localparam [23:0]	 
    THRESHOLD_0 = FAST_SIMULATION ? 24'd 500 : 24'd 500000, 
    THRESHOLD_1 = FAST_SIMULATION ? 24'd 700 : 24'd 700000, 
    THRESHOLD_2 = FAST_SIMULATION ? 24'd1000 : 24'd1000000, 
    THRESHOLD_3 = FAST_SIMULATION ? 24'd1700 : 24'd1700000, 
    THRESHOLD_4 = FAST_SIMULATION ? 24'd3400 : 24'd3400000, 
    THRESHOLD_5 = FAST_SIMULATION ? 24'd6000 : 24'd6000000;
   
localparam [2:0]
    ROM_OFFSET_0 = 0, 
    ROM_OFFSET_1 = 1, 
    ROM_OFFSET_2 = 2, 
    ROM_OFFSET_3 = 3, 
    ROM_OFFSET_4 = 4,
    ROM_OFFSET_5 = 5;
   
reg                     current_state;
reg                     next_state;
reg                     inc_loops;
reg                     clr_loops;
reg                     set_valid;
reg [LOOPS_WIDTH-1:0]   loops;
reg [23:0]              threshold;
reg [POINTER_WIDTH-1:0] offset_ptr;
reg [POINTER_WIDTH-1:0] offset_ptr_r;
reg                     offset_ptr_valid_r;
reg [LOOPS_WIDTH-1:0]   range_r;
wire                    match;
wire                    loops_max;
   
// Simple FSM to sequentially compare against the predefined thresholds
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        current_state <= 1'b0;    
    end else begin
        current_state <= next_state;
    end  
end

always @ (*)
begin
    next_state = current_state;
    clr_loops = 1'b0;
    inc_loops = 1'b0;
    set_valid = 1'b0;
      
    case (current_state)
        0: begin
            clr_loops = 1'b1;
            if (measure_valid) begin
                next_state = 1'b1;
            end        
        end
        
        1: begin
            inc_loops = 1'b1;
            if (match | loops_max) begin
               set_valid = 1'b1;
               clr_loops = 1'b1;
               next_state = 1'b0;
            end                         
        end
    endcase  
end 

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
       loops <= {LOOPS_WIDTH{1'b0}};  
    end else begin
        if (clr_loops) begin
            loops <= 0;
        end else if (inc_loops) begin
            loops <= loops + {{{LOOPS_WIDTH-1}{1'b0}}, 1'b1};
        end 
    end
end 

// 1.4 combinatorial
always @ (loops)
begin
    threshold  = THRESHOLD_4; 
    offset_ptr = ROM_OFFSET_4 * MIF_OFFSET; // was offset_ptr_r
    case (loops)                                                                       
        0:  begin threshold = THRESHOLD_0; offset_ptr = ROM_OFFSET_0 * MIF_OFFSET; end // <50MHz 
        1:  begin threshold = THRESHOLD_1; offset_ptr = ROM_OFFSET_1 * MIF_OFFSET; end // <70MHz
        2:  begin threshold = THRESHOLD_2; offset_ptr = ROM_OFFSET_2 * MIF_OFFSET; end // <100MHz
        3:  begin threshold = THRESHOLD_3; offset_ptr = ROM_OFFSET_3 * MIF_OFFSET; end // <170MHz
        4:  begin threshold = THRESHOLD_4; offset_ptr = ROM_OFFSET_4 * MIF_OFFSET; end // <340MHz
        5:  begin threshold = THRESHOLD_5; offset_ptr = ROM_OFFSET_5 * MIF_OFFSET; end // <600MHz
        default:  begin 
                  threshold = THRESHOLD_5; offset_ptr = ROM_OFFSET_5 * MIF_OFFSET; end // <600MHz
    endcase
end 
 
assign match = measure < threshold;
assign loops_max = loops == LOOPS_MAX;

// Outputs
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        offset_ptr_r <= ROM_OFFSET_4 * MIF_OFFSET;
        offset_ptr_valid_r <= 1'b0;
        range_r <= {LOOPS_WIDTH{1'b0}};
    end else begin
        if (clr_valid | measure_valid) begin
            offset_ptr_valid_r <= 1'b0;
        end else if (set_valid) begin
            offset_ptr_r <= offset_ptr;
            offset_ptr_valid_r <= 1'b1;
            range_r <= loops;
        end 
    end
end

assign offset_pointer = offset_ptr_r;
assign offset_pointer_valid = offset_ptr_valid_r;
assign range = range_r;
  
endmodule