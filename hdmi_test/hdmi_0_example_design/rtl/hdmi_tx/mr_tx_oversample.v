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


module mr_tx_oversample #(
    parameter OVERSAMPLE_RATE = 5,  // Oversample rate
    parameter DATA_WIDTH      = 20  // Width of din & dout
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  din_valid,
    output reg  [DATA_WIDTH-1:0] dout
);

//--------------------------------------------------------------------------------------------------
// Make the set of output words. Each bit from the input data is repeated OVERSAMPLE_RATE times.
//--------------------------------------------------------------------------------------------------
reg [DATA_WIDTH*OVERSAMPLE_RATE-1:0] sample_vector;
reg [DATA_WIDTH-1:0]                 samples [0:OVERSAMPLE_RATE-1];
reg [DATA_WIDTH-1:0]                 t_sample;
integer i;
integer j;
always @ (din)
begin
    sample_vector = {OVERSAMPLE_RATE{1'b0}};
    // Make a sample vector with each data bit 5 times
    for (i=0; i<DATA_WIDTH*OVERSAMPLE_RATE; i=i+1) begin
        sample_vector[i] = din[i/OVERSAMPLE_RATE];
    end

    // Extract all the output words from the sample vector
    for (j=0; j<OVERSAMPLE_RATE; j=j+1) begin
        for (i=0; i<DATA_WIDTH; i=i+1) begin
            t_sample[i] = sample_vector[j*DATA_WIDTH+i];
        end	   
        samples[j] = t_sample;       
    end
end

//--------------------------------------------------------------------------------------------------
// Run a counter to select which output word to use
//--------------------------------------------------------------------------------------------------
reg [3:0]            count;
//reg [DATA_WIDTH-1:0] dout;
always @ (posedge clk or posedge rst)
begin
    if (rst) begin
        dout <= {DATA_WIDTH{1'b0}};
        count <= 4'd1;
    end else begin
        if (din_valid) begin
            // First set of sample bits
            dout <= samples[0];
            count <= 4'd1;
        //end else if (count>0) begin
        end else if (count < OVERSAMPLE_RATE) begin	   
            dout <= samples[count];
            count <= count + 4'd1;
        end
    end
end
   
//assign dout = dout1;
   
endmodule
