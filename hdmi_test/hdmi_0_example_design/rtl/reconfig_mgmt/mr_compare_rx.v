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
//  GXB RX comparison circuitry that sequentially check the measured value against the predetermined threshold
//  and output the expected start offset pointer 
// 
module mr_compare_rx #(
    parameter       FAST_SIMULATION  = 0,
    parameter [3:0] MIF_OFFSET       = 7,  // ROM_DEPTH_FOR_EACH_MIF_RANGE			
    parameter       POINTER_WIDTH    = 8,  // alt_clogb2(TOTAL_ROM_DEPTH_FOR_VALUEMASK)			  
    parameter       LOOPS_MAX        = 46, 		     
    parameter       LOOPS_WIDTH      = 6   // alt_clogb2(LOOPS_MAX)
) (
    input  wire                     clock,
    input  wire                     reset,
    input  wire                     clr_valid,
    input  wire [23:0]              measure,
    input  wire                     measure_valid,
    output wire [POINTER_WIDTH-1:0] offset_pointer,
    output wire                     offset_pointer_valid,
    output wire [LOOPS_WIDTH-1:0]   range,   
    output wire                     oversampled
);
   
// **** PERL SCIPT TO GENERATE BEGIN **** //
// 1.4 threshold (250Mbps to 3400Mbps & equivalent TMDS clock 25MHz to 340MHz)
localparam [23:0]	 
    THRESHOLD_0  = FAST_SIMULATION ? 24'd 220 : 24'd 220000, // THRESHOLD_15 divide 5 (Oversampling)
    THRESHOLD_1  = FAST_SIMULATION ? 24'd 240 : 24'd 240000, // THRESHOLD_16 divide 5 (Oversampling)
    THRESHOLD_2  = FAST_SIMULATION ? 24'd 260 : 24'd 260000, // THRESHOLD_17 divide 5 (Oversampling)
    THRESHOLD_3  = FAST_SIMULATION ? 24'd 300 : 24'd 300000, // THRESHOLD_18 divide 5 (Oversampling)
    THRESHOLD_4  = FAST_SIMULATION ? 24'd 340 : 24'd 340000, // THRESHOLD_19 divide 5 (Oversampling)
    THRESHOLD_5  = FAST_SIMULATION ? 24'd 440 : 24'd 440000, // THRESHOLD_20 divide 5 (Oversampling)
    THRESHOLD_6  = FAST_SIMULATION ? 24'd 480 : 24'd 480000, // THRESHOLD_21 divide 5 (Oversampling)
    THRESHOLD_7  = FAST_SIMULATION ? 24'd 520 : 24'd 520000, // THRESHOLD_22 divide 5 (Oversampling)
    THRESHOLD_8  = FAST_SIMULATION ? 24'd 600 : 24'd 600000, // THRESHOLD_23 divide 5 (Oversampling)
    THRESHOLD_9  = FAST_SIMULATION ? 24'd 680 : 24'd 680000, // THRESHOLD_24 divide 5 (Oversampling)
    THRESHOLD_10 = FAST_SIMULATION ? 24'd 700 : 24'd 700000, // THRESHOLD_25 divide 5 (Oversampling)
    THRESHOLD_11 = FAST_SIMULATION ? 24'd 800 : 24'd 800000, // THRESHOLD_26 divide 5 (Oversampling)
    THRESHOLD_12 = FAST_SIMULATION ? 24'd 900 : 24'd 900000, // THRESHOLD_27 divide 5 (Oversampling)
    THRESHOLD_13 = FAST_SIMULATION ? 24'd 960 : 24'd 960000, // THRESHOLD_28 divide 5 (Oversampling)
    THRESHOLD_14 = FAST_SIMULATION ? 24'd1000 : 24'd1000000, // THRESHOLD_29 divide 5 (Oversampling)
    THRESHOLD_15 = FAST_SIMULATION ? 24'd1100 : 24'd1100000,
    THRESHOLD_16 = FAST_SIMULATION ? 24'd1200 : 24'd1200000,
    THRESHOLD_17 = FAST_SIMULATION ? 24'd1300 : 24'd1300000,
    THRESHOLD_18 = FAST_SIMULATION ? 24'd1500 : 24'd1500000,
    THRESHOLD_19 = FAST_SIMULATION ? 24'd1700 : 24'd1700000,
    THRESHOLD_20 = FAST_SIMULATION ? 24'd2200 : 24'd2200000,
    THRESHOLD_21 = FAST_SIMULATION ? 24'd2400 : 24'd2400000,
    THRESHOLD_22 = FAST_SIMULATION ? 24'd2600 : 24'd2600000,
    THRESHOLD_23 = FAST_SIMULATION ? 24'd3000 : 24'd3000000,
    THRESHOLD_24 = FAST_SIMULATION ? 24'd3400 : 24'd3400000,
    THRESHOLD_25 = FAST_SIMULATION ? 24'd3500 : 24'd3500000,
    THRESHOLD_26 = FAST_SIMULATION ? 24'd4000 : 24'd4000000,
    THRESHOLD_27 = FAST_SIMULATION ? 24'd4500 : 24'd4500000,
    THRESHOLD_28 = FAST_SIMULATION ? 24'd4800 : 24'd4800000,
    THRESHOLD_29 = FAST_SIMULATION ? 24'd5200 : 24'd5200000,
    THRESHOLD_30 = FAST_SIMULATION ? 24'd6000 : 24'd6000000;
   
localparam [4:0]
    ROM_OFFSET_0  = 0,  // less than 1100 or 220
    ROM_OFFSET_1  = 1,  // less than 1200 or 240
    ROM_OFFSET_2  = 2,  // less than 1300 or 260
    ROM_OFFSET_3  = 3,  // less than 1500 or 300
    ROM_OFFSET_4  = 4,  // less than 1700 or 340
    ROM_OFFSET_5  = 5,  // less than 2200 or 440
    ROM_OFFSET_6  = 6,  // less than 2400 or 480
    ROM_OFFSET_7  = 7,  // less than 2600 or 520
    ROM_OFFSET_8  = 8,  // less than 3000 or 600
    ROM_OFFSET_9  = 9,  // less than 3400 or 680
    ROM_OFFSET_10 = 10, // less than 3500 or 700
    ROM_OFFSET_11 = 11, // less than 4000 or 800
    ROM_OFFSET_12 = 12, // less than 4500 or 900
    ROM_OFFSET_13 = 13, // less than 4800 or 960
    ROM_OFFSET_14 = 14, // less than 5200 or 1000
    ROM_OFFSET_15 = 15; // less than 6000
// **** PERL SCIPT TO GENERATE END ****** //

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
reg                     os;
reg                     os_r;
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
            loops <= loops + {{{LOOPS_WIDTH-1}{1'b0}},1'b1};
        end 
    end
end 

// **** PERL SCIPT TO GENERATE BEGIN **** //
// 1.4 combinatorial
always @ (loops)
begin
    threshold  = THRESHOLD_30; 
    offset_ptr = ROM_OFFSET_15 * MIF_OFFSET; // was offset_ptr_r
    os         = 1'b0; // was or_r
    case (loops)                                                                                    
        0:  begin threshold = THRESHOLD_0;  offset_ptr = ROM_OFFSET_0 * MIF_OFFSET;  os = 1'b1; end // <22MHz
        1:  begin threshold = THRESHOLD_1;  offset_ptr = ROM_OFFSET_1 * MIF_OFFSET;  os = 1'b1; end // <24MHz
        2:  begin threshold = THRESHOLD_2;  offset_ptr = ROM_OFFSET_2 * MIF_OFFSET;  os = 1'b1; end // <26MHz
        3:  begin threshold = THRESHOLD_3;  offset_ptr = ROM_OFFSET_3 * MIF_OFFSET;  os = 1'b1; end // <30MHz
        4:  begin threshold = THRESHOLD_4;  offset_ptr = ROM_OFFSET_4 * MIF_OFFSET;  os = 1'b1; end // <34MHz
        5:  begin threshold = THRESHOLD_5;  offset_ptr = ROM_OFFSET_5 * MIF_OFFSET;  os = 1'b1; end // <44MHz
        6:  begin threshold = THRESHOLD_6;  offset_ptr = ROM_OFFSET_6 * MIF_OFFSET;  os = 1'b1; end // <48MHz
        7:  begin threshold = THRESHOLD_7;  offset_ptr = ROM_OFFSET_7 * MIF_OFFSET;  os = 1'b1; end // <52MHz
        8:  begin threshold = THRESHOLD_8;  offset_ptr = ROM_OFFSET_8 * MIF_OFFSET;  os = 1'b1; end // <60MHz
        9:  begin threshold = THRESHOLD_9;  offset_ptr = ROM_OFFSET_9 * MIF_OFFSET;  os = 1'b1; end // <68MHz
        10: begin threshold = THRESHOLD_10; offset_ptr = ROM_OFFSET_10 * MIF_OFFSET; os = 1'b1; end // <70MHz
        11: begin threshold = THRESHOLD_11; offset_ptr = ROM_OFFSET_11 * MIF_OFFSET; os = 1'b1; end // <80MHz
        12: begin threshold = THRESHOLD_12; offset_ptr = ROM_OFFSET_12 * MIF_OFFSET; os = 1'b1; end // <90MHz
        13: begin threshold = THRESHOLD_13; offset_ptr = ROM_OFFSET_13 * MIF_OFFSET; os = 1'b1; end // <96MHz
        14: begin threshold = THRESHOLD_14; offset_ptr = ROM_OFFSET_14 * MIF_OFFSET; os = 1'b1; end // <100MHz
        15: begin threshold = THRESHOLD_15; offset_ptr = ROM_OFFSET_0 * MIF_OFFSET;  os = 1'b0; end // <110MHz
        16: begin threshold = THRESHOLD_16; offset_ptr = ROM_OFFSET_1 * MIF_OFFSET;  os = 1'b0; end // <120MHz
        17: begin threshold = THRESHOLD_17; offset_ptr = ROM_OFFSET_2 * MIF_OFFSET;  os = 1'b0; end // <130MHz
        18: begin threshold = THRESHOLD_18; offset_ptr = ROM_OFFSET_3 * MIF_OFFSET;  os = 1'b0; end // <150MHz
        19: begin threshold = THRESHOLD_19; offset_ptr = ROM_OFFSET_4 * MIF_OFFSET;  os = 1'b0; end // <170MHz
        20: begin threshold = THRESHOLD_20; offset_ptr = ROM_OFFSET_5 * MIF_OFFSET;  os = 1'b0; end // <220MHz
        21: begin threshold = THRESHOLD_21; offset_ptr = ROM_OFFSET_6 * MIF_OFFSET;  os = 1'b0; end // <240MHz
 	      22: begin threshold = THRESHOLD_22; offset_ptr = ROM_OFFSET_7 * MIF_OFFSET;  os = 1'b0; end // <260MHz
        23: begin threshold = THRESHOLD_23; offset_ptr = ROM_OFFSET_8 * MIF_OFFSET;  os = 1'b0; end // <300MHz
        24: begin threshold = THRESHOLD_24; offset_ptr = ROM_OFFSET_9 * MIF_OFFSET;  os = 1'b0; end // <340MHz
        25: begin threshold = THRESHOLD_25; offset_ptr = ROM_OFFSET_10 * MIF_OFFSET; os = 1'b0; end // <350MHz
        26: begin threshold = THRESHOLD_26; offset_ptr = ROM_OFFSET_11 * MIF_OFFSET; os = 1'b0; end // <400MHz
        27: begin threshold = THRESHOLD_27; offset_ptr = ROM_OFFSET_12 * MIF_OFFSET; os = 1'b0; end // <450MHz
        28: begin threshold = THRESHOLD_28; offset_ptr = ROM_OFFSET_13 * MIF_OFFSET; os = 1'b0; end // <480MHz
        29: begin threshold = THRESHOLD_29; offset_ptr = ROM_OFFSET_14 * MIF_OFFSET; os = 1'b0; end // <520MHz
        30: begin threshold = THRESHOLD_30; offset_ptr = ROM_OFFSET_15 * MIF_OFFSET; os = 1'b0; end // <600MHz
	     default: begin 
		            threshold = THRESHOLD_30; offset_ptr = ROM_OFFSET_15 * MIF_OFFSET; os = 1'b0; end // <600MHz
    endcase
end 
// **** PERL SCIPT TO GENERATE END ****** //

assign match = measure < threshold;
assign loops_max = loops == LOOPS_MAX;

// Outputs
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        offset_ptr_r <= ROM_OFFSET_15 * MIF_OFFSET;
        offset_ptr_valid_r <= 1'b0;
        os_r <= 1'b0;
        range_r <= {LOOPS_WIDTH{1'b0}};
    end else begin
        if (clr_valid | measure_valid) begin
            offset_ptr_valid_r <= 1'b0;
        end else if (set_valid) begin
            offset_ptr_r <= offset_ptr;
            offset_ptr_valid_r <= 1'b1;
            os_r <= os;
            range_r <= loops;
        end 
    end
end

assign offset_pointer = offset_ptr_r;
assign offset_pointer_valid = offset_ptr_valid_r;
assign oversampled = os_r;
assign range = range_r;

endmodule
