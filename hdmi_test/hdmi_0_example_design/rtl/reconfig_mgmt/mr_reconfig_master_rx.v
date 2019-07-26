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
// The Avalon-MM master for A10 GXB RX reconfiguration
// 
module mr_reconfig_master_rx #(     
    parameter MIF_OFFSET                       = 7,   // ROM_DEPTH_FOR_EACH_MIF_RANGE - total cram address that differ resulted from mif files comparison
    parameter ADDR_WIDTH_FOR_VALUEMASK         = 8,   // alt_clogb2(TOTAL_ROM_DEPTH_FOR_VALUEMASK) - number of bits representation for total ROM depth for valuemask 
    parameter ADDR_WIDTH_FOR_DPRIOADDR_BITMASK = 3,   // alt_clogb2(ROM_DEPTH_FOR_EACH_MIF_RANGE) - number of bits representation for total CRAM address that differ
    parameter DPRIO_ADDRESS_WIDTH              = 12,  // 10 + 2 - extra 2 bits required at msb to indicate transceiver channel number (0, 1, 2) that intended for reconfig
    parameter DPRIO_DATA_WIDTH                 = 32   // 			 
) (
    input  wire                                        clock,
    input  wire                                        reset,
    input  wire [2:0]                                  rx_cal_busy,                // from gxb - indicate recalibration in progress
    input  wire                                        reconfig_request,           // from main state machine - request for reconfig
    input  wire                                        pcs_reconfig_request,       // from main state machine - request for pcs (wa) reconfig     
    output reg                                         reconfig_busy,              // to main state machine - indicate reconfig is in progress (not used)
    output reg                                         reconfig_done,              // to main state machine - indicate reconfig is completed
    input  wire                                        clr_reconfig_done,          // from main state machine - full handshake signal to acknowledge reconfig_done (both rx & pll) is serviced
    input  wire [ADDR_WIDTH_FOR_VALUEMASK-1:0]         offset_pointer,             // from main state machine - indicate which rom address (mif range) to be read
    output wire [ADDR_WIDTH_FOR_VALUEMASK-1:0]         valuemask_addr_ptr,         // to value mask rom - start from offset_pointer & increment by 1 for each cycle & increment for MIF_OFFSET times
    output wire [ADDR_WIDTH_FOR_DPRIOADDR_BITMASK-1:0] dprioaddr_bitmask_addr_ptr, // to dprio addr rom - start from 0 & increment by 1 for each cycle & increment for MIF_OFFSET times 
    input  wire [9:0]                                  dprio_offset,               // from dprio addr rom - indicate which cram address to write to
    input  wire [7:0]                                  field_bitmask,              // from dprio addr rom - indicate which cram bit to write to (in 8-bitmask format)
    input  wire [7:0]                                  field_valuemask,            // from value mask rom - indicate the value of cram bit to write to (in 8-bitmask format)
    input  wire                                        reconfig_waitrequest,       //
    input  wire [DPRIO_DATA_WIDTH-1:0]                 reconfig_readdata,          //
    output reg                                         reconfig_write,             //
    output reg                                         reconfig_read,              // Reconfig signals to/from GXB RX
    output wire [DPRIO_ADDRESS_WIDTH-1:0]              reconfig_address,           //
    output reg  [DPRIO_DATA_WIDTH-1:0]                 reconfig_writedata          //       
);

function integer alt_clogb2;
    input [31:0] value;
    integer i;
    begin
        alt_clogb2 = 32;
        for (i=31; i>0; i=i-1) begin
            if (2**i>=value)
                alt_clogb2 = i;
        end
    end
endfunction

localparam [3:0]
    IDLE  = 0,
    REQ   = 1,		
    RD    = 2,
    MOD   = 3,
    WR    = 4,
    TRANS = 5,		
    REL   = 6,
    NXT   = 7,	       
    DONE  = 8;

localparam POST_MIF_OFFSET         = 3;
localparam OFFSET_RECAL_EN         = MIF_OFFSET;
localparam OFFSET_RATE_SWITCH_FLAG = MIF_OFFSET+1;
localparam OFFSET_DIS_TX_CAL_BUSY  = MIF_OFFSET+2;
localparam NUM_EXE_WIDTH           = alt_clogb2(MIF_OFFSET+POST_MIF_OFFSET);
localparam PCS_MIF_OFFSET          = 4;
  
reg  [3:0]                          next_state;     
reg  [3:0]                          current_state;
reg  [DPRIO_DATA_WIDTH-1:0]         saved_readdata; // store reconfig read data from GXB RX
wire [DPRIO_DATA_WIDTH-1:0]         data_to_write;  // data to be written to GXB RX
reg  [NUM_EXE_WIDTH-1:0]            num_exec;       // offset start from 0 & increment by 1 & for MIF_OFFSET times
reg  [ADDR_WIDTH_FOR_VALUEMASK-1:0] pointer;        // get the pointer start offset from main state machine
reg  [1:0]                          channel;        // indicate channel to be written to
reg                                 last_channel;   // indicate if the current channel is the last or not
reg                                 last_offset;    // indicate if the current offset is the last or not
wire [9:0]                          address_offset;
reg                                 exec_recal_en;
reg                                 exec_rate_switch_flag;
reg                                 exec_dis_tx_cal_busy;
reg                                 exec_en_tx_cal_busy;
reg  [2:0]                          rx_cal_busy_negedge;
reg  [2:0]                          rx_cal_busy_reg;
   
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        rx_cal_busy_reg <= 3'b0;
        rx_cal_busy_negedge <= 3'b0;
    end else begin
        rx_cal_busy_reg <= rx_cal_busy;
        
        if(rx_cal_busy_negedge[0] == 1'b0) 
            rx_cal_busy_negedge[0] <= ~rx_cal_busy[0] & rx_cal_busy_reg[0];
        else if(next_state == DONE || (~reconfig_request & ~pcs_reconfig_request)) 
            rx_cal_busy_negedge[0] <= 1'b0;
        
        if(rx_cal_busy_negedge[1] == 1'b0)
            rx_cal_busy_negedge[1] <= ~rx_cal_busy[1] & rx_cal_busy_reg[1];
        else if(next_state == DONE || (~reconfig_request & ~pcs_reconfig_request)) 
            rx_cal_busy_negedge[1] <= 1'b0;
        
        if(rx_cal_busy_negedge[2] == 1'b0) 
            rx_cal_busy_negedge[2] <= ~rx_cal_busy[2] & rx_cal_busy_reg[2];
        else if(next_state == DONE || (~reconfig_request & ~pcs_reconfig_request)) 
            rx_cal_busy_negedge[2] <= 1'b0;
    end        
end
   
//assign rx_cal_busy_negedge = ~|rx_cal_busy & rx_cal_busy_reg;

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        exec_en_tx_cal_busy <= 1'b0;
        exec_recal_en <= 1'b0;
        exec_rate_switch_flag <= 1'b0;
        exec_dis_tx_cal_busy <= 1'b0;
    end else begin
        if (current_state === NXT && last_channel && last_offset) begin
            exec_en_tx_cal_busy <= 1'b1;
        end else if (next_state == DONE || (~reconfig_request & ~pcs_reconfig_request)) begin //clear the exec_en_tx_cal_busy when timeout in main state machine
            exec_en_tx_cal_busy <= 1'b0;
        end

        exec_recal_en <= num_exec == OFFSET_RECAL_EN;
        exec_rate_switch_flag <= num_exec == OFFSET_RATE_SWITCH_FLAG;
        exec_dis_tx_cal_busy <= num_exec == OFFSET_DIS_TX_CAL_BUSY;
    end
end
 
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end        
end   

// next state logic
always @ (*) 
begin
    next_state = current_state;
     
    case (current_state)
        IDLE: begin
            if (reconfig_request | pcs_reconfig_request) begin
                if(exec_en_tx_cal_busy) begin
                    if(&rx_cal_busy_negedge) begin
                        next_state = REQ;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin
                    next_state = REQ;
                end
            end else begin    
                next_state = IDLE;
            end	      
        end

        REQ: begin
            if (reconfig_waitrequest) begin
                next_state = REQ;
            end else begin
                next_state = RD;
            end	       
        end
      
        // reconfig read
        RD: begin
            if (reconfig_waitrequest) begin
                next_state = RD;
            end else begin
                next_state = MOD;
            end	       
        end

        // 1-cycle delay      
        MOD: begin
            next_state = WR;
        end

        // reconfig write      
        WR: begin
            if (reconfig_waitrequest) begin
                next_state = WR;
            end else begin
                next_state = TRANS;
            end	       
        end

        // cycle to next offset before it hits MIF_OFFSET times
        // else cycle to repeat for next transceiver channel
        TRANS : begin
            if (exec_en_tx_cal_busy) begin
                next_state = REL;	
            end else if (last_offset) begin
                next_state = REL;
            end else begin
                next_state = RD;
            end
        end

        REL: begin
            if (reconfig_waitrequest) begin
                next_state = REL;
            end else begin
                next_state = NXT;
            end
        end 

        NXT: begin
            if (last_channel) begin
                if (exec_en_tx_cal_busy | pcs_reconfig_request) begin
                    next_state = DONE;
                end else begin
                    next_state = IDLE;
                end
            end else begin
                next_state = REQ;
            end	       
        end
      
        // full handshaking between this master and main state machine      
        DONE: begin
            if (~reconfig_request & ~pcs_reconfig_request) begin
                next_state = IDLE;
            end	        
        end	    
    endcase
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        channel <= 2'd0;
        last_channel <= 1'b0;
    end else begin
        if (next_state == IDLE) begin                
            channel <= 2'd0;
        end else if (next_state == NXT && ~last_channel) begin
            channel <= channel + 2'd1; 
        end

        last_channel <= channel == 2;
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        num_exec <= {NUM_EXE_WIDTH{1'b0}};
        pointer <= {ADDR_WIDTH_FOR_VALUEMASK{1'b0}};
        last_offset <= 1'b0;
    end else begin
        if (next_state == IDLE || next_state == NXT) begin
            num_exec <= {NUM_EXE_WIDTH{1'b0}};
            pointer <= offset_pointer;
        end else if (next_state == TRANS && ~last_offset) begin
            num_exec <= num_exec + {{{NUM_EXE_WIDTH-1}{1'b0}}, 1'b1};
            pointer <= pointer + {{{ADDR_WIDTH_FOR_VALUEMASK-1}{1'b0}}, 1'b1};
        end

        last_offset <= pcs_reconfig_request ? num_exec == (PCS_MIF_OFFSET - 1) : 
                                              num_exec == (MIF_OFFSET - 1 + POST_MIF_OFFSET);
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_busy <= 1'b0;
    end else begin
        if (reconfig_request | pcs_reconfig_request) begin
            reconfig_busy <= 1'b1; 
        end else if (next_state == IDLE) begin 
            reconfig_busy <= 1'b0;
        end 
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_read <= 1'b0; 
    end else begin
        if (next_state == RD) begin
            reconfig_read <= 1'b1; 
        end else begin
            reconfig_read <= 1'b0;
        end
    end
end

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        saved_readdata <= {32{1'b0}}; 
    end else begin
        if (next_state == MOD) begin
            saved_readdata <= reconfig_readdata;
        end
    end
end
   
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_write <= 1'b0; 
    end else begin
        if (next_state == WR || next_state == REQ || next_state == REL) begin  
            reconfig_write <= 1'b1; 
        end else begin 
            reconfig_write <= 1'b0; 
        end
    end
end
   
assign reconfig_address = {channel, (current_state == REQ || current_state == REL) ? 10'h000 : address_offset};
assign address_offset = exec_recal_en                                ? 10'h100 :
                        exec_rate_switch_flag                        ? 10'h166 :
                        (exec_dis_tx_cal_busy | exec_en_tx_cal_busy) ? 10'h281 : dprio_offset;
assign data_to_write = exec_recal_en         ? {saved_readdata[31:7], 1'b0, saved_readdata[5:2], 1'b1, saved_readdata[0]} :
                       exec_rate_switch_flag ? {saved_readdata[31:8], 1'b0, saved_readdata[6:0]} :
                       exec_dis_tx_cal_busy  ? {saved_readdata[31:5], 1'b0, saved_readdata[3:0]} : 
                       exec_en_tx_cal_busy   ? {saved_readdata[31:5], 1'b1, saved_readdata[3:0]} :
                                               {saved_readdata[31:8], ((saved_readdata[7:0] & ~field_bitmask) | (field_valuemask & field_bitmask))};

always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reconfig_writedata <= {DPRIO_DATA_WIDTH{1'b0}}; 
    end else begin
        if (next_state == WR) begin
            reconfig_writedata <= data_to_write;
        end else if (next_state == REQ) begin
            reconfig_writedata <= {{(DPRIO_DATA_WIDTH-2){1'b0}}, 2'h2};
        end else if (next_state == REL && exec_en_tx_cal_busy) begin
            reconfig_writedata <= {{(DPRIO_DATA_WIDTH-2){1'b0}}, 2'h3};
        end else if (next_state == REL) begin
            reconfig_writedata <= pcs_reconfig_request ? {{(DPRIO_DATA_WIDTH-2){1'b0}}, 2'h3}
                                                       : {{(DPRIO_DATA_WIDTH-2){1'b0}}, 2'h1};
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

assign dprioaddr_bitmask_addr_ptr = num_exec;
assign valuemask_addr_ptr = pointer;
 
endmodule
