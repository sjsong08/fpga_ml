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
// The main state machine that controls both GXB RX and PLL reconfig in full handshake manner
// It determine the incoming HDMI data rate by examining the TMDS_Bit_Clock_ratio from Bitec RX, 1=HDMI 2.0, 0=HDMI 1.4
//
//
module mr_state_machine #(
    parameter FAST_SIMULATION   = 0,
    parameter POINTER_WIDTH     = 5, // alt_clogb2(NUMBER_OF_MIF_RANGE)
    parameter RX_RANGE_WIDTH    = 6, // alt_clogb2(LOOPS_MAX)	 
    parameter PLL_RANGE_WIDTH   = 3
) (
    input wire                          clock,
    input wire                          reset,
    input wire                          rx_is_20,                   // from bitec rx - TMDS_Bit_Clock_ratio
    input wire  [2:0]                   rx_hdmi_locked,             // from bitec rx - indicate hdmi locked
    input wire  [3:0]                   rx_color_depth,             // from bitec rx - indicate received color depth	 
    input wire  [2:0]                   rx_cal_busy,                // recalibration busy signal from transceiver
    input wire                          rx_ready,                   // from transceiver reset controller - indicate gxb rx is locked
    input wire                          rx_reconfig_done,           // from reconfig master rx - indicate gxb rx reconfig is complete
    input wire                          pll_locked,                 // from pll - indicate pll is locked
    input wire                          pll_reconfig_done,          // from reconfig master pll - indicate pll reconfig is complete
    input wire  [RX_RANGE_WIDTH-1:0]    rx_range,                   // from compare rx - indicate the data rate range that the current stream falls into
    input wire                          rx_offset_pointer_valid,    // from compare rx - indicate the start offset pointer is a valid one
    input wire                          rx_oversampled,             // from compare rx - indicate if it is oversampled
    input wire                          pll_offset_pointer_valid,   // from compare pll - indicate the start offset pointer is a valid one
    input wire  [PLL_RANGE_WIDTH-1:0]   pll_range,                  // from compare pll - indicate the TMDS clock frequency range that the current stream falls into
    output reg  [2:0]                   set_locktoref,              // to gxb rx - if oversampled, set to all 1 else set to all 0
    output wire [3:0]                   color_depth_out,            // to pll compare - latched color depth from bitec rx core
    output wire                         clr_compare_valid,          // to all compare - provide full handshake signal to indicate ready to measure
    output wire                         clr_pll_reconfig_done,      // to pll reconfig - provide full handshake signal to indicate pll reconfig done signal is serviced
    output wire                         clr_xcvr_reconfig_done,     // to xcvr reconfig - provide full handshake signal to indicate xcvr reconfig done signal is serviced
    output reg                          reset_core,                 // to bitec rx core - reset signal for video data path only
    output reg                          reset_xcvr,                 // to transceiver reset controller - reset transceiver
    output reg                          reset_pll,                  // to pll - reset pll
    output reg                          reset_pll_reconfig,         // to pll reconfig - reset pll reconfig happens only when unexpected error occurs
    output reg                          enable_measure,             // to rate detect - initiate TMDS clock measure
    output reg                          pll_reconfig_request,       // to pll reconfig master - to request for pll reconfig
    output reg                          xcvr_reconfig_request,      // to xcvr reconfig master - to request for xcvr reconfig	 
    //output reg  [31:0]                  freerun_timer,              // for lock time debug purpose
    input wire                          i2c_trans_detected,         // from upper level - indicate scdc write to scrambler enable happened
    output reg                          i2c_trans_detected_ack,     // to upper level - ful handshaking to acknowledge reception of scdc write detection
    input wire                          tkn_detected,               // from symbol aligner - indicate consecutive control characters are detected
    output reg                          pcs_reconfig_request        // to xcvr reconfig master - to request for pcs reconfig
);

localparam [3:0]
    RESET           = 4'd0,
    MEASURE         = 4'd1,
    RECONFIG_PLL    = 4'd2,
    WAIT_PLL_LOCK   = 4'd3,
    PLL_LOCK_STABLE = 4'd4,
    RECONFIG_XCVR   = 4'd5,
    WAIT_READY      = 4'd6,
    READY_STABLE    = 4'd7,
    WAIT_LOCK       = 4'd8,
    LOCKED          = 4'd9,
    CHECK_THRESHOLD = 4'd10,
    WAIT_VIDEO      = 4'd11,
    RECONFIG_PCS    = 4'd12;

reg [29:0]                count;
reg [3:0]                 current_state;
reg [3:0]                 next_state;
reg                       assert_reset_core;
reg                       assert_reset_xcvr;
reg                       assert_reset_pll;
reg                       assert_reset_pll_reconfig;
reg                       dec_count;
reg                       go_measure;
reg                       pll_reconfig_req;
reg                       xcvr_reconfig_req;
reg                       assert_set_locktoref;
reg                       clr_set_locktoref;
reg                       clr_pll_rcfg_done;
reg                       clr_xcvr_rcfg_done;
reg                       load_range;
reg                       init_count;
reg                       set_pll_lock_count;
reg                       set_ready_count;
reg                       set_locked_count;
reg                       set_max_count;
reg                       ready_to_measure;
reg                       init_ready_drop_count;
reg                       dec_ready_drop_count;	
reg [RX_RANGE_WIDTH-1:0]  rx_range_prev;
reg [PLL_RANGE_WIDTH-1:0] pll_range_prev;
reg                       rx_is_20_prev;
reg [9:0]                 ready_drop_count;
reg                       latch_color_depth_temp;
reg [3:0]                 color_depth_prev;
reg [3:0]                 color_depth_temp;
wire                      rx_hdmi_locked_sync;
wire                      pll_locked_sync;
wire                      compare_valid;
wire                      oversampled;
wire                      ready;
wire                      locked;
wire                      go_reconfig;
wire                      xcvr_reconfig_done;
wire                      rx_is_20_change;
wire                      color_depth_change;
reg                       set_wait_video_count;
reg                       pcs_reconfig_req;

// Synchronizers  
altera_std_synchronizer #(.depth(3)) u_rx_hdmi_locked_sync (.clk(clock),.reset_n(1'b1),.din(&rx_hdmi_locked),.dout(rx_hdmi_locked_sync));
altera_std_synchronizer #(.depth(3)) u_pll_locked_sync     (.clk(clock),.reset_n(1'b1),.din(pll_locked),     .dout(pll_locked_sync));

assign compare_valid = rx_offset_pointer_valid && pll_offset_pointer_valid;
assign oversampled = rx_oversampled;
assign ready = rx_ready && ~|rx_cal_busy;
assign locked = rx_hdmi_locked_sync;
assign xcvr_reconfig_done = rx_reconfig_done;
   
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        current_state <= RESET; 
    end else begin
        current_state <= next_state;
    end       
end

always @ (*)
begin
    next_state = current_state;
    assert_reset_core = 1'b0;	 
    assert_reset_xcvr = 1'b0;
    assert_reset_pll = 1'b0;
    assert_reset_pll_reconfig = 1'b0;
    dec_count = 1'b0;
    go_measure = 1'b0;
    pll_reconfig_req = 1'b0;
    xcvr_reconfig_req = 1'b0;
    assert_set_locktoref = 1'b0;
    clr_set_locktoref = 1'b0;
    clr_pll_rcfg_done = 1'b0;
    clr_xcvr_rcfg_done = 1'b0;
    load_range = 1'b0;
    init_count = 1'b0;
    set_pll_lock_count = 1'b0;     
    set_ready_count = 1'b0;
    set_locked_count = 1'b0;
    set_max_count = 1'b0;
    ready_to_measure = 1'b0;
    init_ready_drop_count = 1'b0;
    dec_ready_drop_count = 1'b0;
    latch_color_depth_temp = 1'b0;
    set_wait_video_count = 1'b0;
    pcs_reconfig_req = 1'b0;
	 
    case (current_state)
        // reset gxb rx and pll during idle state or after reconfig
        RESET: begin
            assert_reset_core = 1'b1;		  
            assert_reset_xcvr = 1'b1;
            assert_reset_pll = pll_reconfig_done;
            dec_count = 1'b1;
            if (count == 0) begin
                set_max_count = 1'b1;	   
                if (pll_reconfig_done) begin
                    next_state = WAIT_PLL_LOCK;
                end else if (xcvr_reconfig_done) begin
                    next_state = WAIT_READY;
                end else begin
                    ready_to_measure = 1'b1;
                    next_state = MEASURE;
                end 
            end			
        end
		   
        WAIT_VIDEO: begin
            assert_reset_core = 1'b1;		  
            assert_reset_xcvr = 1'b1;
            assert_reset_pll = pll_reconfig_done;
            dec_count = 1'b1;
            if (count == 0) begin
                set_max_count = 1'b1;
                ready_to_measure = 1'b1;
                next_state = MEASURE;
            end
        end
		  
        // enable measure to the TMDS clock      
        MEASURE: begin
            assert_reset_core = 1'b1;		  
            assert_reset_xcvr = 1'b1;		  
            go_measure = 1'b1;
            clr_pll_rcfg_done = 1'b1;
            clr_xcvr_rcfg_done = 1'b1;
            dec_count = 1'b1;
            if (compare_valid) begin
                set_ready_count = 1'b1;
                next_state = RECONFIG_PLL;
            end else if (i2c_trans_detected) begin
                assert_reset_pll_reconfig = 1'b1;
                set_wait_video_count = 1'b1;
                next_state = WAIT_VIDEO;
            end else if (count == 0) begin
                assert_reset_pll_reconfig = 1'b1;
                init_count = 1'b1;
                next_state = RESET;
            end	   
        end

        // request for pll reconfig and wait for pll reconfig done  		  
        RECONFIG_PLL: begin
            assert_reset_core = 1'b1;		  
            assert_reset_xcvr = 1'b1;
            pll_reconfig_req = 1'b1;
            dec_count = 1'b1;
            if (pll_reconfig_done) begin
                init_count = 1'b1;
                next_state = RESET;
            end else if (count == 0) begin	       
                assert_reset_pll_reconfig = 1'b1;
                init_count = 1'b1;
                next_state = RESET;
            end
        end
		  
        // wait for pll locked signal
        WAIT_PLL_LOCK: begin
            assert_reset_core = 1'b1;
            assert_reset_xcvr = 1'b1;
            clr_pll_rcfg_done = 1'b1;
            dec_count = 1'b1;
            if (pll_locked_sync) begin
                set_pll_lock_count = 1'b1;
                next_state = PLL_LOCK_STABLE;
            end else if (i2c_trans_detected) begin
                assert_reset_pll_reconfig = 1'b1;
                set_wait_video_count = 1'b1;
                next_state = WAIT_VIDEO;
            end else if (count == 0) begin
                assert_reset_pll_reconfig = 1'b1;
                ready_to_measure = 1'b1;
                set_max_count = 1'b1;
                next_state = MEASURE;
            end
        end

        // check if pll locked signal stable	
        // to make sure reference clock to the cdr is stable before
        // reconfig and recalibration is performed on cdr		  
        PLL_LOCK_STABLE: begin
            assert_reset_core = 1'b1;             
            assert_reset_xcvr = 1'b1;				
            if (pll_locked_sync) begin
                dec_count = 1'b1;
                if (count == 0) begin
                    init_ready_drop_count = 1'b1;
                    set_max_count = 1'b1;
                    next_state = RECONFIG_XCVR;
                end	       
            end else begin
                dec_ready_drop_count = 1'b1;
                if (ready_drop_count == 0) begin	       
                    assert_reset_pll_reconfig = 1'b1;
                    init_count = 1'b1;
                    next_state = RESET;
                end else begin
                    set_max_count = 1'b1;
       	           next_state = WAIT_PLL_LOCK;
                end		   
            end        
        end

        // request for xcvr reconfig and wait for xcvr reconfig done      
        RECONFIG_XCVR: begin
            assert_reset_core = 1'b1;		  
            assert_reset_xcvr = 1'b1;
            xcvr_reconfig_req = 1'b1;
            dec_count = 1'b1;
            if (xcvr_reconfig_done) begin
                load_range = 1'b1;
                init_count = 1'b1;
                if (oversampled) begin
                    assert_set_locktoref = 1'b1;
                end else begin
                    clr_set_locktoref = 1'b1;
                end
                next_state = RESET;	       
            end else if (count == 0) begin	       
                assert_reset_pll_reconfig = 1'b1;
                init_count = 1'b1;
                next_state = RESET;
            end	   
        end
		  
        // wait for xcvr to be ready     
        WAIT_READY: begin
            assert_reset_core = 1'b1;		  
            clr_xcvr_rcfg_done = 1'b1;
            dec_count = 1'b1; 
            if (ready) begin
                set_ready_count = 1'b1;
                next_state = READY_STABLE;
            end else if (i2c_trans_detected) begin
                assert_reset_pll_reconfig = 1'b1;
                set_wait_video_count = 1'b1;
                next_state = WAIT_VIDEO;
            end else if (count == 0) begin
                assert_reset_pll_reconfig = 1'b1;
                ready_to_measure = 1'b1;
                set_max_count = 1'b1;
                next_state = MEASURE;
            end	   
        end

        // once xcvr is locked, monitor further if it is really ready and stable    
        READY_STABLE: begin
            assert_reset_core = 1'b1;		  
            if (tkn_detected) begin
                set_max_count = 1'b1;
                next_state = RECONFIG_PCS;
	    end else if (ready) begin
                dec_count = 1'b1;
                if (count == 0) begin
                    init_ready_drop_count = 1'b1;
                    set_max_count = 1'b1;
                    next_state = WAIT_LOCK;
                end	       
            end else begin
                dec_ready_drop_count = 1'b1;
                if (ready_drop_count == 0) begin	       
                    assert_reset_pll_reconfig = 1'b1;
                    init_count = 1'b1;
                    next_state = RESET;
                end else begin
                    set_max_count = 1'b1;
       	           next_state = WAIT_READY;
                end		   
            end        
        end

        // wait for hdmi lock signal      
        WAIT_LOCK: begin
            clr_pll_rcfg_done = 1'b1;
            clr_xcvr_rcfg_done = 1'b1;
            dec_count = 1'b1;
            if (locked) begin	   
                set_locked_count = 1'b1;
                ready_to_measure = 1'b1;					 
                next_state = LOCKED;
            end else if (i2c_trans_detected) begin
                assert_reset_pll_reconfig = 1'b1;
                set_wait_video_count = 1'b1;
                next_state = WAIT_VIDEO;
            end else if (tkn_detected) begin
                set_max_count = 1'b1;
                next_state = RECONFIG_PCS;
            end else if (count == 0) begin	           
                assert_reset_pll_reconfig = 1'b1;
                init_count = 1'b1;
                next_state = RESET;
            end	   
        end

        RECONFIG_PCS: begin
            //assert_reset_core = 1'b1; 		  
            //assert_reset_xcvr = 1'b1;
            pcs_reconfig_req = 1'b1;
            dec_count = 1'b1;
            if (xcvr_reconfig_done) begin
                set_max_count = 1'b1;
                next_state = WAIT_LOCK; //RESET;	       
            end else if (count == 0) begin
                assert_reset_pll_reconfig = 1'b1;
                init_count = 1'b1;
                next_state = RESET;
            end	       
        end
	   
        // locked to hdmi signal, monitor TMDS clock frequency and pll and gxb rx stability      
        LOCKED: begin
            go_measure = 1'b1;
            if (~locked || ~ready || ~pll_locked_sync) begin
                init_count = 1'b1;					 
                next_state = RESET;
            end else if (compare_valid) begin
                if (go_reconfig) begin
                    next_state = CHECK_THRESHOLD;
                end else begin
                    set_locked_count = 1'b1;
                end		   
            end	         
        end

        // if TMDS clock frequency range change, do check again to see if it happens consecutively
        // threshold can be increased so that it is less prone to error 
        CHECK_THRESHOLD: begin
            if (color_depth_change) begin
                latch_color_depth_temp = 1'b1;								
                ready_to_measure = 1'b1;
                set_max_count = 1'b1;
                next_state = MEASURE;
            end else if (rx_is_20_change) begin
                ready_to_measure = 1'b1;
                set_max_count = 1'b1;
                next_state = MEASURE;				   
            end else if (count == 0) begin
                set_ready_count = 1'b1;
                next_state = RECONFIG_PLL;
            end else begin
                dec_count = 1'b1;
                ready_to_measure = 1'b1;
                next_state = LOCKED;
            end	        
        end

        default: begin
            next_state = RESET;
            assert_reset_core = 1'b1;				
            assert_reset_xcvr = 1'b1;
            assert_reset_pll = 1'b1;
            assert_reset_pll_reconfig = 1'b1;
            dec_count = 1'b0;
            go_measure = 1'b0;
            pll_reconfig_req = 1'b0;
            xcvr_reconfig_req = 1'b0;
            assert_set_locktoref = 1'b0;
            clr_set_locktoref = 1'b0;
            clr_pll_rcfg_done = 1'b0;
            clr_xcvr_rcfg_done = 1'b0;
            load_range = 1'b0;
            init_count = 1'b0;
            set_pll_lock_count = 1'b0;				
            set_ready_count = 1'b0;
            set_locked_count = 1'b0;
            set_max_count = 1'b0;
            ready_to_measure = 1'b1;
            init_ready_drop_count = 1'b0;
            dec_ready_drop_count = 1'b0;
            latch_color_depth_temp = 1'b0;
            set_wait_video_count = 1'b0;
            pcs_reconfig_req = 1'b0;
        end		  
    endcase 
end   

//always @ (posedge clock or posedge reset)
//begin
//    if (reset) freerun_timer <= 32'd0;
//    else freerun_timer <= freerun_timer + 32'd1;
//end

// Timeout counter 
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        count <= 30'h0000000F;
    end else begin
        if (init_count) begin
            count <= 30'h0000000F;
        end else if (set_wait_video_count) begin
            count <= 30'd10000000; // 100ms
        end else if (set_max_count) begin
            count <= 30'd50000000; // 500ms
        end else if (set_pll_lock_count) begin
            count <= FAST_SIMULATION ? 30'h000003E8 : 30'h00001388; // 50us
        end else if (set_ready_count) begin
            count <= FAST_SIMULATION ? 30'h000003E8 : 30'd500000; // 50ms
        end else if (set_locked_count) begin
            count <= 30'h00000001;	   
        end else if (dec_count) begin
            count <= count - 30'h00000001;
        end	   
    end       
end

// The ready from transceiver may toggle for unknown cycles
// before it gets stabilized, this count prevent the state machine
// to go into infinite loop when the ready signal is unstable
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        ready_drop_count <= 10'd10; 
    end else begin
        if (init_ready_drop_count) begin
            ready_drop_count <= 10'd10; 
        end else if (dec_ready_drop_count) begin
            ready_drop_count <= ready_drop_count - 10'd1;
        end				
    end       
end

// Assert to set transceiver to lock-to-ref mode for oversampled data
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        set_locktoref <= 3'b000;
    end else begin
        if (clr_set_locktoref) begin
            set_locktoref <= 3'b000;
        end else if (assert_set_locktoref) begin
            set_locktoref <= 3'b111;
        end
    end
end

// Reset signals out
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        reset_core <= 1'b1;	 
        reset_xcvr <= 1'b1;
        reset_pll <= 1'b1;
        reset_pll_reconfig <= 1'b1;
        enable_measure <= 1'b0;
        pll_reconfig_request <= 1'b0; 
        xcvr_reconfig_request <= 1'b0;
        pcs_reconfig_request <= 1'b0; 
        i2c_trans_detected_ack <= 1'b0;
    end else begin
        reset_core <= assert_reset_core;	 
        reset_xcvr <= assert_reset_xcvr;
        reset_pll <= assert_reset_pll;
        reset_pll_reconfig <= assert_reset_pll_reconfig; 
        enable_measure <= go_measure; 
        pll_reconfig_request <= pll_reconfig_req;
        xcvr_reconfig_request <= xcvr_reconfig_req;
        pcs_reconfig_request <= pcs_reconfig_req;
        i2c_trans_detected_ack <= current_state == WAIT_VIDEO;
    end       
end

// Load the successful reconfigured frequency ranges/scdc/color depth
always @ (posedge clock or posedge reset)
begin
    if (reset) begin
        rx_range_prev <= {RX_RANGE_WIDTH{1'b1}};
        pll_range_prev <= {PLL_RANGE_WIDTH{1'b1}};
        rx_is_20_prev <= 1'b0;
        color_depth_prev <= 4'b0000;
        color_depth_temp <= 4'b0000;		  
    end else begin
        if (load_range) begin
            // load the comparison/cd/scdc value to previous value only after the successful reconfiguration		  
            rx_range_prev <= rx_range;   
            pll_range_prev <= pll_range;
            rx_is_20_prev <= rx_is_20;
            color_depth_prev <= color_depth_temp;				
        end else if (latch_color_depth_temp) begin
            // upon detecting HDMI RX core retrieves a valid color depth which differs from the previous
            // latch the value for PLL compare module as the HDMI RX core may gone through reset sequence which
            // indirectly clear the color depth information to 0s		  
            color_depth_temp <= rx_color_depth;				 
        end		 
    end       
end 

assign rx_is_20_change = rx_is_20_prev != rx_is_20;
assign color_depth_change = ((rx_color_depth[1:0] == 2'b00) && (color_depth_temp[1:0] != rx_color_depth[1:0]))  // to workaround source that sends 4'b0000 instead of 4'b0100 for 8bpc video
                         || ((rx_color_depth[3:2] == 2'b01) && (color_depth_temp[1:0] != rx_color_depth[1:0])); // [3:2] qualify if the [1:0] is valid, so cd_temp and cd_prev is always valid
assign go_reconfig = (rx_range_prev != rx_range)|| (pll_range_prev != pll_range) || rx_is_20_change || color_depth_change || (color_depth_prev[1:0] != color_depth_temp[1:0]);
assign clr_compare_valid = ready_to_measure;
assign clr_pll_reconfig_done = clr_pll_rcfg_done;
assign clr_xcvr_reconfig_done = clr_xcvr_rcfg_done;
assign color_depth_out = color_depth_temp;
   
endmodule			  
