`timescale 1us/1ns


module mid_bram(
	input wire clk,
	input wire RESET,

	input wire start_wr,
	input wire [62:0] in,
	input wire de_in,
	input wire in0_rden, in1_rden, in2_rden, in3_rden,
	
	output reg de_out,
	output wire [62:0] in0_q, in1_q, in2_q, in3_q
);

parameter bit_depth = 8;
parameter image_width = 12'd28;
parameter image_height = 11'd28;




///////////////////////////////////////////////////////////////////////////////////

reg in0_wren, in1_wren, in2_wren, in3_wren;
reg [4:0] in_addr;

reg [62:0] in_sam;
always@(negedge clk)
	in_sam <= in;

reg de_del1;
reg de_del2;
reg de_del3;
reg de_del4;
reg de_del5;
reg de_del6;

reg [11:0] cnt_de;

always@(posedge clk)
begin	
	de_del1 <= de_in;
	de_del2 <= de_del1;
	de_del3 <= de_del2;
	de_del4 <= de_del3;
	de_del5 <= de_del4;
	de_del6 <= de_del5;
end

initial
cnt_de <= 5'd0;

always @(posedge clk)
begin
	if (RESET || start_wr)
		cnt_de <= 12'd0;	
	if (de_del3 == 1'b0 && de_del4 == 1'b1)
	begin
		if (cnt_de == image_height - 12'd1)
			cnt_de <= 5'd0;
		else
			cnt_de <= cnt_de + 5'd1;
	end
	else
		cnt_de <= cnt_de;
end


always@(negedge clk)
begin
	if(RESET)
	begin
		in_addr <= 5'd0;
		in0_wren <= 1'b0;
		in1_wren <= 1'b0;
		in2_wren <= 1'b0;
		in3_wren <= 1'b0;
	end
		if (de_in)
		begin
			in_addr <= in_addr + 5'd1;
			
			if(cnt_de[1:0] == 2'b00)
			begin
				in0_wren <= 1'b1; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b0; 
			end
			else if(cnt_de[1:0] == 2'b01)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b1; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b0; 
			end
			else if(cnt_de[1:0] == 2'b10)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b1; 
				in3_wren <= 1'b0; 
			end
			else if(cnt_de[1:0] == 2'b11)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b1; 
			end

		end
	else
	begin
		in_addr <= 6'd0;
		in0_wren <= 1'b0;
		in1_wren <= 1'b0;
		in2_wren <= 1'b0;
		in3_wren <= 1'b0;
	end
end



bram_1port bram_in0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in0_q)
);

bram_1port bram_in1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in1_q)
);

bram_1port bram_in2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in2_q)
);

bram_1port bram_in3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in3_q)
);


wire [20:0] in0R, in0G, in0B, in1R, in1G, in1B, in2R, in2G, in2B, in3R, in3G, in3B;

assign in0R = in0_q[20:0];
assign in0G = in0_q[41:21];
assign in0B = in0_q[62:42];

assign in1R = in1_q[20:0];
assign in1G = in1_q[41:21];
assign in1B = in1_q[62:42];

assign in2R = in2_q[20:0];
assign in2G = in2_q[41:21];
assign in2B = in2_q[62:42];

assign in3R = in3_q[20:0];
assign in3G = in3_q[41:21];
assign in3B = in3_q[62:42];
		
endmodule		
/////////////////////////////////////////////////////////////////////////////////////////

