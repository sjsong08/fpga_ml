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


module mr_reconfig_master_pll #(
    parameter MIF_OFFSET               = 7,  // total cram address that differ resulted from PLL mif files comparison
    parameter ADDR_WIDTH_FOR_VALUEMASK = 6,  // number of bits representation for total ROM depth for PLL valuemask 
    parameter ADDR_WIDTH_FOR_DPRIOADDR = 3,  // number of bits representation for total CRAM address that differ
    parameter DPRIO_ADDRESS_WIDTH      = 9,  //
    parameter DPRIO_DATA_WIDTH         = 32  //			 
) (
    input  wire                                clock,
    input  wire                                reset,
    input  wire                                reconfig_request,     // from main state machine - request for reconfig
    output reg                                 reconfig_done,        // to main state machine - indicate reconfig is completed
    input  wire                                clr_reconfig_done,    // from main state machine - full handshake signal to acknowledge reconfig_done (both rx & pll) is serviced
    input  wire [ADDR_WIDTH_FOR_VALUEMASK-1:0] offset_pointer,       // from main state machine - indicate which rom address (mif range) to be read
    output wire [ADDR_WIDTH_FOR_VALUEMASK-1:0] valuemask_addr_ptr,   // to value mask rom - start from offset_pointer & increment by 1 for each cycle & increment for MIF_OFFSET times
    output wire [ADDR_WIDTH_FOR_DPRIOADDR-1:0] dprioaddr_addr_ptr,   // to dprio addr rom - start from 0 & increment by 1 for each cycle & increment for MIF_OFFSET times 
    input  wire [7:0]                          dprio_offset,         // from dprio addr rom - indicate which cram address to write to
    input  wire [31:0]                         field_valuemask,      // from value mask rom - indicate the value of cram bit to write to (in 8-bitmask format)
    input  wire                                reconfig_waitrequest, // 
    output reg                                 reconfig_write,       // Reconfig signals to/from PLL reconfig controller
    output reg  [DPRIO_ADDRESS_WIDTH-1:0]      reconfig_address,     //
    output reg  [DPRIO_DATA_WIDTH-1:0]         reconfig_writedata    //      
);

localparam [2:0]
    IDLE        = 0,
    MOD         = 1,		
    WR          = 2,
    TRANS       = 3,
    START       = 4,
    WAITREQUEST = 5,
    DONE        = 6;

reg  [2:0]                          next_state; 
reg  [2:0]                          current_state;
wire [DPRIO_DATA_WIDTH-1:0]         data_to_write;             // data to be written to PLL
reg  [ADDR_WIDTH_FOR_DPRIOADDR-1:0] num_exec;                  // offset start from 0 & increment by 1 & for MIF_OFFSET times                   
reg  [ADDR_WIDTH_FOR_VALUEMASK-1:0] pointer;                   // get the pointer start offset from main state machine
reg                                 last_offset;               // indicate if the current offset is the last or not
wire                                reconfig_waitrequest_sync; // synchronize waitrequest signal from the PLL reconfig controller
   
altera_std_synchronizer #(.depth(3)) u_reconfig_waitrequest_sync (.clk(clock),.reset_n(1'b1),.din(reconfig_waitrequest),.dout(reconfig_waitrequest_sync));
      
always @ (posedge clock or posedge reset)   
begin
    if (reset) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end       
end

always @ (*)
begin
    next_state = current_state;
      
    case (current_state)
        IDLE: begin
	         if (reconfig_request) begin
                next_state = MOD;
            end	       
        end

        MOD: begin
            next_state = WR;
        end	   

        // reconfig write       
        WR: begin
            //if (~reconfig_waitrequest_sync) begin
            //    next_state = TRANS;
            //end else if (~reconfig_request) begin
            //    next_state = IDLE;
            //end	
            if (~reconfig_request) begin
                next_state = IDLE;
            end else begin
                next_state = TRANS;
            end				
        end

        // cycle to next offset before it hits MIF_OFFSET times
        TRANS: begin
            if (last_offset) begin
                next_state = START;
            end else begin
                next_state = MOD;
            end	       
        end

        // write to start register to initiate the PLL reconfig
        // then wait for waitrequest signal to be asserted        
        START: begin
            if (reconfig_waitrequest_sync) begin
                next_state = WAITREQUEST;
            end else if (~reconfig_request) begin	   
                next_state = IDLE;
            end	   
        end

        // once waitrequest is deasserted, PLL reconfig is complete      
        WAITREQUEST: begin
            if (~reconfig_waitrequest_sync) begin
                next_state = DONE;
            end else if (~reconfig_request) begin	   
                next_state = IDLE;
            end
        end

        // full handshaking between this master and main state machine      
        DONE: begin
            if (~reconfig_request) begin
                next_state = IDLE;
            end	       
        end        
    endcase   
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        num_exec <= {ADDR_WIDTH_FOR_DPRIOADDR{1'b0}};
        pointer <= {ADDR_WIDTH_FOR_VALUEMASK{1'b0}};
        last_offset <= 1'b0;
    end else begin
        if (next_state == IDLE) begin
            num_exec <= {ADDR_WIDTH_FOR_DPRIOADDR{1'b0}};
            pointer <= offset_pointer;	   
        end else if (next_state == TRANS && ~last_offset) begin
            num_exec <= num_exec + {{{ADDR_WIDTH_FOR_DPRIOADDR-1}{1'b0}}, 1'b1};
            pointer <= pointer + {{{ADDR_WIDTH_FOR_VALUEMASK-1}{1'b0}}, 1'b1};	   
        end

        last_offset <= num_exec == (MIF_OFFSET - 1);
    end
end
   
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_write <= 1'b0; 
    end else begin
        if (next_state == WR || next_state == START) begin  
            reconfig_write <= 1'b1; 
        end else begin 
            reconfig_write <= 1'b0; 
        end
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_address <= {DPRIO_ADDRESS_WIDTH{1'b0}}; 
    end else begin
        if (next_state == WR) begin
            reconfig_address <= {1'b0, dprio_offset};
        end else if (next_state == START) begin
            reconfig_address <= {1'b0, 8'h00};
        end	   
    end
end

assign data_to_write = field_valuemask;
  
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_writedata <= {DPRIO_DATA_WIDTH{1'b0}}; 
    end else begin
        if (next_state == WR) begin
            reconfig_writedata <= data_to_write;
        end else if (next_state == START) begin
            reconfig_writedata <= 32'd0;
        end	   
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_done <= 1'b0;
    end else begin
        if (clr_reconfig_done) begin
            reconfig_done <= 1'b0;
        end else if (next_state == DONE) begin
            reconfig_done <= 1'b1;
        end	   
    end       
end
   
assign dprioaddr_addr_ptr = num_exec;
assign valuemask_addr_ptr = pointer;
   
endmodule			 