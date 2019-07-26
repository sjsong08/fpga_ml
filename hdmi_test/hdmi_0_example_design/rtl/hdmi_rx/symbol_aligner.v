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


module symbol_aligner #(
  parameter SYMBOLS_PER_CLOCK = 2,
  //parameter PMA_PCS_WIDTH = 20,
  parameter CHANNEL = 3			
) (
  input  wire                                    reset,  
  input  wire                                    mgmt_clk, 
  input  wire [CHANNEL-1:0]                      rx_clk,
  input  wire [SYMBOLS_PER_CLOCK*10*CHANNEL-1:0] rx_parallel_data,
  //input  wire [PMA_PCS_WIDTH/10*CHANNEL-1:0]     rx_patterndetect,
  input  wire [5*CHANNEL-1:0]                    rx_std_bitslipboundarysel,
  input  wire [CHANNEL-1:0]                      rx_ready,
  input  wire                                    rx_reconfig_pcs_in_progress,
  output wire                                    token_detected,
  output wire [SYMBOLS_PER_CLOCK*10*CHANNEL-1:0] rx_parallel_data_aligned             
);

genvar l;
reg [SYMBOLS_PER_CLOCK-1:0] marker [CHANNEL-1:0];
reg [4:0] boundary_d1 [CHANNEL-1:0];
reg [4:0] boundary_d2 [CHANNEL-1:0];
reg [CHANNEL-1:0] tkn_detected;
wire [SYMBOLS_PER_CLOCK*10*3-1:0] data_aligned [CHANNEL-1:0];
wire [CHANNEL-1:0] reset_rxclk;
wire [CHANNEL-1:0] ready_sync;
wire [CHANNEL-1:0] rcfg_pcs_in_prog_sync;
wire [CHANNEL-1:0] tkn_detected_sync;
altera_reset_controller #(.NUM_RESET_INPUTS(1),.SYNC_DEPTH(3)) u_rx_clk0_rst_sync (.reset_in0(reset),.clk(rx_clk[0]),.reset_out(reset_rxclk[0]));
altera_reset_controller #(.NUM_RESET_INPUTS(1),.SYNC_DEPTH(3)) u_rx_clk1_rst_sync (.reset_in0(reset),.clk(rx_clk[1]),.reset_out(reset_rxclk[1]));
altera_reset_controller #(.NUM_RESET_INPUTS(1),.SYNC_DEPTH(3)) u_rx_clk2_rst_sync (.reset_in0(reset),.clk(rx_clk[2]),.reset_out(reset_rxclk[2]));
clock_crosser #(.W(1)) cc_ready_sync0 (.in(rx_ready[0]),.out(ready_sync[0]),.in_clk(mgmt_clk),.out_clk(rx_clk[0]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_ready_sync1 (.in(rx_ready[1]),.out(ready_sync[1]),.in_clk(mgmt_clk),.out_clk(rx_clk[1]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_ready_sync2 (.in(rx_ready[2]),.out(ready_sync[2]),.in_clk(mgmt_clk),.out_clk(rx_clk[2]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_rcfg_pcs_in_prog_sync0 (.in(rx_reconfig_pcs_in_progress),.out(rcfg_pcs_in_prog_sync[0]),.in_clk(mgmt_clk),.out_clk(rx_clk[0]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_rcfg_pcs_in_prog_sync1 (.in(rx_reconfig_pcs_in_progress),.out(rcfg_pcs_in_prog_sync[1]),.in_clk(mgmt_clk),.out_clk(rx_clk[1]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_rcfg_pcs_in_prog_sync2 (.in(rx_reconfig_pcs_in_progress),.out(rcfg_pcs_in_prog_sync[2]),.in_clk(mgmt_clk),.out_clk(rx_clk[2]),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_tkn_detected_sync0 (.in(tkn_detected[0]),.out(tkn_detected_sync[0]),.in_clk(rx_clk[0]),.out_clk(mgmt_clk),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_tkn_detected_sync1 (.in(tkn_detected[1]),.out(tkn_detected_sync[1]),.in_clk(rx_clk[1]),.out_clk(mgmt_clk),.in_reset(1'b0),.out_reset(1'b0));
clock_crosser #(.W(1)) cc_tkn_detected_sync2 (.in(tkn_detected[2]),.out(tkn_detected_sync[2]),.in_clk(rx_clk[2]),.out_clk(mgmt_clk),.in_reset(1'b0),.out_reset(1'b0));

generate
  for(l=0;l<CHANNEL;l=l+1)
    begin: gen_phy_symbol_align
      genvar s;
      wire [SYMBOLS_PER_CLOCK-1:0] tkn_detect;
      for(s=0;s<SYMBOLS_PER_CLOCK;s=s+1)
        begin: gen_phy_tkn_detect
          wire [9:0] in_data = rx_parallel_data[(l*SYMBOLS_PER_CLOCK*10+s*10)+:10];			 
          assign tkn_detect[s] = ready_sync[l] & ((in_data[7:0] == 8'h54 | in_data[7:0] == 8'hab));
        end

      reg [3:0] tkn_cntr [SYMBOLS_PER_CLOCK-1:0];
      wire [3:0] tkn_cntr_i [SYMBOLS_PER_CLOCK-1:0];
      assign tkn_cntr_i[0] = tkn_detect[0] ? tkn_cntr[SYMBOLS_PER_CLOCK-1] + (tkn_cntr[SYMBOLS_PER_CLOCK-1] < 4'd8) : 4'd0;
      always@(posedge rx_clk[l] or posedge reset_rxclk[l])		
      begin
        if(reset_rxclk[l]) begin
          tkn_cntr[0] <= 4'd0;		
          marker[l][0] <= 1'b0;
        end else begin
          tkn_cntr[0] <= tkn_cntr_i[0];		
          marker[l][0] <= tkn_cntr_i[0] >= 4'd4;	
        end		
      end

      for(s=1;s<SYMBOLS_PER_CLOCK;s=s+1)
        begin: gen_phy_tkn_cntr
          assign tkn_cntr_i[s] = tkn_detect[s] ? tkn_cntr_i[s-1] + (tkn_cntr_i[s-1] < 4'd8) : 4'd0;
          always@(posedge rx_clk[l] or posedge reset_rxclk[l])
          begin
            if(reset_rxclk[l]) begin
              tkn_cntr[s] <= 4'd0;
              marker[l][s] <= 1'b0;		
            end else begin
              tkn_cntr[s] <= tkn_cntr_i[s];
              marker[l][s] <= tkn_cntr_i[s] >= 4'd4;		
            end		
          end		
        end

      reg [SYMBOLS_PER_CLOCK*10-1:0] data_d1;
      reg [SYMBOLS_PER_CLOCK*10-1:0] data_d2;
      reg [SYMBOLS_PER_CLOCK*10-1:0] data_d3;		
      always@(posedge rx_clk[l] or posedge reset_rxclk[l])
      begin
        if(reset_rxclk[l]) begin
          boundary_d1[l] <= 5'd0;
          boundary_d2[l] <= 5'd0;	 
          tkn_detected[l] <= 1'b0;
          data_d1 <= {SYMBOLS_PER_CLOCK{10'd0}};
          data_d2 <= {SYMBOLS_PER_CLOCK{10'd0}};
          data_d3 <= {SYMBOLS_PER_CLOCK{10'd0}};
        end else begin
          boundary_d1[l] <= rx_std_bitslipboundarysel[l*5+:5];			 
          data_d1 <= rx_parallel_data[l*SYMBOLS_PER_CLOCK*10+:SYMBOLS_PER_CLOCK*10];
          data_d2 <= data_d1;
          data_d3 <= data_d2;			 
          if(ready_sync[l]) begin
            if(tkn_detected[l] & rcfg_pcs_in_prog_sync[l]) begin				
              tkn_detected[l] <= 1'b0; 				  
            end else if(|marker[l] & boundary_d1[l] != 5'h1F) begin
              tkn_detected[l] <= 1'b1;
              boundary_d2[l] <= boundary_d1[l]; 	    
            end 
          end else begin
            tkn_detected[l] <= 1'b0;
            boundary_d2[l] <= 5'd0;
          end		
        end		
      end
  
      //assign data_aligned[l] = {rx_parallel_data[l*SYMBOLS_PER_CLOCK*10+:SYMBOLS_PER_CLOCK*10], data_d1}
      assign data_aligned[l] = {data_d1, data_d2, data_d3} >> boundary_d2[l];		
    end
endgenerate

assign token_detected = &tkn_detected_sync;	    
assign rx_parallel_data_aligned = {data_aligned[2][SYMBOLS_PER_CLOCK*10-1:0], 
                                   data_aligned[1][SYMBOLS_PER_CLOCK*10-1:0], 
                                   data_aligned[0][SYMBOLS_PER_CLOCK*10-1:0]};
	     
endmodule		       
