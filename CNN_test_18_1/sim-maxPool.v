module maxPool #(
   parameter BD = 18)

(
   input clk, reset,
   input ready_in,
   input [BD-1:0] q0_c0, q0_c1, q0_c2, q1_c0, q1_c1, q1_c2,

   output reg mpen,
   output reg [10:0] rdaddr,

   output reg wren,
   output reg [9:0] wraddr,
   output reg mpend,
   output wire [BD-1:0] d_c0, d_c1, d_c2,
   output reg [1:0] bram_num,
   output reg next_st
);

parameter INWIDTH = 11'd28;
parameter OUTWIDTH = 11'd28;


reg ready_sample0, ready_sample1;
always@(posedge clk)
begin
   if(reset)
   begin
      ready_sample0 <= 1'b0;
      ready_sample1 <= 1'b0;
   end
   else
   begin
      ready_sample0 <= ready_in;
      ready_sample1 <= ready_sample0;
   end
end

wire ready = ready_sample0 & ~ready_sample1;

always@(negedge clk)
begin
   if(reset)
      mpen <= 1'b0;
   else
   begin
      if(ready)
         mpen <= 1'b1;
      else if(wraddr == OUTWIDTH - 11'd1)
         mpen <= 1'b0;
   end
end


always@(negedge clk)
begin
   if(reset)
      rdaddr <= 11'd0;
   else
   begin
      if(mpen)
      begin
         if(rdaddr == INWIDTH - 11'd1)
            rdaddr <= 11'd0;
         else
            rdaddr <= rdaddr + 11'd1;
      end
      else
         rdaddr <= 11'd0;
   end
end
            

reg wincnt_pre, wincnt;
always@(negedge clk)
begin
   if(reset)
   begin
      wincnt_pre <= 1'b0;
      wincnt <= 1'b0;
   end
   else
   begin
      wincnt <= wincnt_pre;
      if(mpen)
         wincnt_pre <= wincnt_pre + 1'b1;
      else
         wincnt_pre <= 1'b0;
   end
end


always@(negedge clk)
begin
   if(reset)
   begin
      wraddr <= -10'd1;
      wren <= 1'b0;
      bram_num <= 2'd0;
   end
   else
   begin
      if(mpen && wincnt)
      begin
         wren <= 1'b1;
         wraddr <= wraddr + 11'd1;
      end
      else if(!mpen && wraddr == OUTWIDTH - 11'd1)
      begin
         wraddr <= -11'd1;
         bram_num <= bram_num + 2'd1;
      end

      else
      begin
         wren <= 1'b0;
         wraddr <= wraddr;
      end
   end
end


reg next_ready;
always@(negedge clk)
begin
   if(reset)
      next_ready <= 1'b0;
   else if(bram_num == 2'd2)
      next_ready <= 1'b1;
end

always@(negedge clk)
begin
   if(reset)
      next_st <= 1'b0;
   else
   begin
      if(next_ready && !mpen && wraddr == OUTWIDTH - 11'd1)
         next_st <= 1'b1;
      else
         next_st <= 1'b0;
   end
end



compare #(.BD (BD)) compare0 (
   .clk      (clk),
   .reset      (reset),
   .mpen      (mpen),
   .wincnt      (wincnt),
   .q0      (q0_c0),
   .q1      (q1_c0),
   .d      (d_c0)
);
compare #(.BD (BD)) compare1 (
   .clk      (clk),
   .reset      (reset),
   .mpen      (mpen),
   .wincnt      (wincnt),
   .q0      (q0_c1),
   .q1      (q1_c1),
   .d      (d_c1)
);
compare #(.BD (BD)) compare2 (
   .clk      (clk),
   .reset      (reset),
   .mpen      (mpen),
   .wincnt      (wincnt),
   .q0      (q0_c2),
   .q1      (q1_c2),
   .d      (d_c2)
);

endmodule

