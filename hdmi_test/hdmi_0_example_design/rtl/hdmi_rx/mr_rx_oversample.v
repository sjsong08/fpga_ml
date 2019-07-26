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


module mr_rx_oversample #(   
   parameter [6:0]                 DIN_WIDTH       = 7'd20,   // Width of din
   parameter [4:0]                 DOUT_WIDTH      = 5'd20,   // Width of dout
   parameter [5:0]                 SAMPLE_INTERVAL = 6'd5,    // Sample repeat period in absence of transition aka oversampling ratio
   parameter [SAMPLE_INTERVAL-1:0] SAMPLE_MASK     = 5'b00100 // Position of sample point(s) wrt transition		     
) (
   input  wire                  clk,       // Local clock running at sample rate / data width
   input  wire                  rst,       // Active high reset	
   input  wire [DIN_WIDTH-1:0]  din,       // Parallel sample data from transceiver
   output reg  [DOUT_WIDTH-1:0] dout,      // Parallel extracted data
   output reg                   dout_valid // Asserted for one clock cycle for each valid dout word
);

function integer alt_clogb2_pure;
   input [31:0] value;
   integer i;
   begin
      alt_clogb2_pure = 32;
      for (i=31; i>0; i=i-1) begin
         if (2**i >= value) begin
            alt_clogb2_pure = i;
         end
      end
   end
endfunction 

localparam MAX_SAMPLES_PER_WORD = DIN_WIDTH / SAMPLE_INTERVAL + 1;
localparam MAX_SAMPLES_PER_WORD_WIDTH = alt_clogb2_pure(MAX_SAMPLES_PER_WORD);
localparam ADDER_WIDTH = alt_clogb2_pure(DOUT_WIDTH+MAX_SAMPLES_PER_WORD);
   
//--------------------------------------------------------------------------------------------------
// Retime input from transceiver and detect transitions. A bit of "transition" is set to 1 when the
// corresponding bit in "din_d1" is different to the preceding bit (processed lsb first).
// e.g. if din_d1 contains 1100000111 then transition will be 0100001000.
//--------------------------------------------------------------------------------------------------
reg [DIN_WIDTH-1:0] din_d1;
reg [DIN_WIDTH-1:0] din_d2;
reg [DIN_WIDTH-1:0] transition;   
integer i;
   
always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      din_d1 <= {{DIN_WIDTH}{1'b0}};
      din_d2 <= {{DIN_WIDTH}{1'b0}};
      transition <= {{DIN_WIDTH}{1'b0}};		
   end else begin
      for (i=0; i<DIN_WIDTH; i=i+1) begin
         din_d1[i] <= din[i];
         din_d2[i] <= din_d1[i];
         if (i==0) begin
            transition[0] <= (din[0]!=din_d1[DIN_WIDTH-1]);
         end else begin
            transition[i] <= (din[i]!=din[i-1]);
         end		  
      end		
   end
end
   
//--------------------------------------------------------------------------------------------------
// Sample data. Each bit of the received parallel word is processed in turn, lsb first. If the bit
// is a transition bit, then sample_pos is reset. sample_pos increments for non-transition bits,
// wrapping at the parameterized boundary which corresponds to the bit rate. Data is extracted when
// sample_pos is at a value corresponding to the centre sample of the incoming bit. Extracted data
// is pushed in to a shift register (with valid flag) for subsequent processing.
//--------------------------------------------------------------------------------------------------
reg [SAMPLE_INTERVAL-1:0] t_sample_pos, sample_pos; // A shift register rather than count is used for speed
reg [DIN_WIDTH-1:0]       t_sample_now, sample_now; // Asserted when sample_pos indicates data should be extracted
integer j;

// The t_sample_pos has to be kept running for every clock cycle.
always @ (*)
begin
   t_sample_pos = sample_pos;
   t_sample_now = {{DIN_WIDTH}{1'b0}};

   for (i=0; i<DIN_WIDTH; i=i+1) begin
      // Reset sample position tracker on transition
      if (transition[i]) begin
         t_sample_pos = {{(SAMPLE_INTERVAL-1){1'b0}}, 1'b1}; 
      end

      // Sample data points defined in mask,
      // Sample_now values are stored in a register array
      // for speed reasons.
      for (j=0; j<SAMPLE_INTERVAL; j=j+1) begin
         if (SAMPLE_MASK[j] & t_sample_pos[j]) begin
            t_sample_now[i] = 1'b1;
         end
      end

      // Increment sample tracker, wrapping at SAMPLE_INTERVAL
      t_sample_pos = {t_sample_pos[SAMPLE_INTERVAL-2:0], t_sample_pos[SAMPLE_INTERVAL-1]};
   end
end
 
always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      sample_pos <= {(SAMPLE_INTERVAL){1'b0}};
      sample_now <= {{DIN_WIDTH}{1'b0}};
   end else begin
      sample_pos <= t_sample_pos;
      sample_now <= t_sample_now;
   end
end

// --------------------------------------------------------------------------------------------
// The generation of the "samples" word has now been split into four.  This was done for speed.
// There in the inclusion of an additional register stage so latency is increased.
// --------------------------------------------------------------------------------------------
reg [MAX_SAMPLES_PER_WORD/4:0]       t_samplesa, samplesa;
reg [MAX_SAMPLES_PER_WORD/4:0]       t_samplesb, samplesb;
reg [MAX_SAMPLES_PER_WORD/4:0]       t_samplesc, samplesc;
reg [MAX_SAMPLES_PER_WORD/4:0]       t_samplesd, samplesd;
reg [MAX_SAMPLES_PER_WORD_WIDTH-1:0] t_cnta, cnta;
reg [MAX_SAMPLES_PER_WORD_WIDTH-1:0] t_cntb, cntb; 
reg [MAX_SAMPLES_PER_WORD_WIDTH-1:0] t_cntc, cntc;
reg [MAX_SAMPLES_PER_WORD_WIDTH-1:0] t_cntd, cntd;
reg [MAX_SAMPLES_PER_WORD-1:0]       samples_data;
reg [MAX_SAMPLES_PER_WORD-1:0]       samples_per_word;
integer na, nb, nc, nd;
	
always @ (*)
begin
   t_samplesa = {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
   t_cnta = {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
 
   for (na=0; na<DIN_WIDTH/4; na=na+1) begin         
      if (sample_now[na]) begin
         t_samplesa[t_cnta] = din_d2[na];
         t_cnta = t_cnta + {{(MAX_SAMPLES_PER_WORD_WIDTH-1){1'b0}}, 1'b1};
      end
   end  
end

always @ (*)
begin
   t_samplesb = {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
   t_cntb = {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
   
   for (nb=DIN_WIDTH/4; nb<DIN_WIDTH/2; nb=nb+1) begin       
      if (sample_now[nb]) begin
         t_samplesb[t_cntb] = din_d2[nb];
         t_cntb = t_cntb + {{(MAX_SAMPLES_PER_WORD_WIDTH-1){1'b0}}, 1'b1};
      end
   end
end

always @ (*)
begin
   t_samplesc = {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
   t_cntc = {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
   
   for (nc=DIN_WIDTH/2; nc<DIN_WIDTH*3/4; nc=nc+1) begin        
      if (sample_now[nc]) begin
         t_samplesc[t_cntc] = din_d2[nc];
         t_cntc = t_cntc + {{(MAX_SAMPLES_PER_WORD_WIDTH-1){1'b0}}, 1'b1};
      end
   end
end

always @ (*)
begin
   t_samplesd = {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
   t_cntd = {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
   
   for (nd=DIN_WIDTH*3/4; nd<DIN_WIDTH; nd=nd+1) begin       
      if (sample_now[nd]) begin
         t_samplesd[t_cntd] = din_d2[nd];
         t_cntd = t_cntd + {{(MAX_SAMPLES_PER_WORD_WIDTH-1){1'b0}}, 1'b1};
      end
   end
end

always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      samplesa         <= {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
      samplesb         <= {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
      samplesc         <= {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
      samplesd         <= {(MAX_SAMPLES_PER_WORD/4+1){1'b0}};
      cnta             <= {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};		
      cntb             <= {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
      cntc             <= {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
      cntd             <= {(MAX_SAMPLES_PER_WORD_WIDTH){1'b0}};
      samples_data     <= {(MAX_SAMPLES_PER_WORD){1'b0}};
      samples_per_word <= {(MAX_SAMPLES_PER_WORD){1'b0}};
   end else begin
      // Store extracted samples in shift register
      samplesa <= t_samplesa;
      samplesb <= t_samplesb;
      samplesc <= t_samplesc;
      samplesd <= t_samplesd;
      cnta <= t_cnta;		
      cntb <= t_cntb;
      cntc <= t_cntc;
      cntd <= t_cntd;		

      samples_data <= (samplesd << (cnta + cntb + cntc)) |
                      (samplesc << (cnta + cntb)) |
                      (samplesb << cnta) |
                      samplesa;					  
      samples_per_word <= cnta + cntb + cntc + cntd;	
   end 
end

//-----------------------------------------------------------------------------------------------------
// Convert sampled data into output words. Extracted data samples are removed from the shift
// register and loaded into a parallel word. Once the word is complete, it is output with a valid flag. 
//-----------------------------------------------------------------------------------------------------
reg [ADDER_WIDTH-1:0]                     total_accumulated_samples;
reg [DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:0] dout_sr;
wire                                      valid;
   
always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      total_accumulated_samples <= {{ADDER_WIDTH}{1'b0}};
   end else begin
      if (total_accumulated_samples >= DOUT_WIDTH) begin
         total_accumulated_samples <= (total_accumulated_samples - DOUT_WIDTH) + samples_per_word;
      end else begin
         total_accumulated_samples <= total_accumulated_samples + samples_per_word;
      end
   end
end

assign valid = total_accumulated_samples >= DOUT_WIDTH;

always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      dout_sr <= {{DOUT_WIDTH+MAX_SAMPLES_PER_WORD}{1'b0}};
   end else begin
      dout_sr <= dout_sr;
      case (samples_per_word)
         // Unfortunately, the for loop inside an case statement is forbidden by Quartus synthesizer!	
         //for (i=1; i<MAX_SAMPLES_PER_WORD; i=i+1) begin : rloop
         //   i: begin dout_sr <= {dout_sr[0+:DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1-i], samples_data[0+:i]}; end
         //   default: begin dout_sr <= dout_sr; end
         //end
         // So manual edits is still required to the following case statement when MAX_SAMPLES_PER_WORD changes
         // Number of lines equal MAX_SAMPLES_PER_WORD...			
         1      : begin dout_sr <= {samples_data[0+:1],  dout_sr[DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:1]}; end
         2      : begin dout_sr <= {samples_data[0+:2],  dout_sr[DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:2]}; end
         3      : begin dout_sr <= {samples_data[0+:3],  dout_sr[DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:3]}; end
         4      : begin dout_sr <= {samples_data[0+:4],  dout_sr[DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:4]}; end
         5      : begin dout_sr <= {samples_data[0+:5],  dout_sr[DOUT_WIDTH+MAX_SAMPLES_PER_WORD-1:5]}; end
         default: begin dout_sr <= dout_sr;                                                             end	   
      endcase
   end
end

always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      dout <= {{DOUT_WIDTH}{1'b0}};
      dout_valid <= 1'b0;
   end else begin
      dout <= dout;
      dout_valid <= valid;
	
      case (total_accumulated_samples)
         //for (i=DOUT_WIDTH; i<DOUT_WIDTH+MAX_SAMPLES_PER_WORD; i=i+1) begin
         //   i: begin dout <= dout_sr[i-1:i-DOUT_WIDTH]; end
         //   default: begin dout <= dout; end
         //end
         DOUT_WIDTH   : begin dout <= dout_sr[(MAX_SAMPLES_PER_WORD)   +:DOUT_WIDTH]; end 
         DOUT_WIDTH+1 : begin dout <= dout_sr[(MAX_SAMPLES_PER_WORD-1) +:DOUT_WIDTH]; end 
         DOUT_WIDTH+2 : begin dout <= dout_sr[(MAX_SAMPLES_PER_WORD-2) +:DOUT_WIDTH]; end 
         DOUT_WIDTH+3 : begin dout <= dout_sr[(MAX_SAMPLES_PER_WORD-3) +:DOUT_WIDTH]; end 
         DOUT_WIDTH+4 : begin dout <= dout_sr[(MAX_SAMPLES_PER_WORD-4) +:DOUT_WIDTH]; end 
         default      : begin dout <= dout;                                           end
      endcase
   end
end

endmodule
