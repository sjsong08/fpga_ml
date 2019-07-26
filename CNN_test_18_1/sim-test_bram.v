`timescale 1us/1ns


module test_bram(
	input wire clk,
	input wire RESET,

	input wire start_wr,

	input wire de_in,
	input wire [10:0] rd_addr,
	input wire in0_rden, in1_rden, in2_rden, in3_rden,
	
	output wire de_out,
	output wire [23:0] in0_q, in1_q, in2_q, in3_q
);

parameter bit_depth = 8;
parameter image_width = 12'd28;
parameter image_height = 11'd28;




///////////////////////////////////////////////////////////////////////////////////

reg in0_wren, in1_wren, in2_wren, in3_wren;
reg [10:0] wr_addr;



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
cnt_de <= 12'd0;

assign de_out = de_del1 & de_del6;

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
		wr_addr <= 11'd0;
		in0_wren <= 1'b0;
		in1_wren <= 1'b0;
		in2_wren <= 1'b0;
		in3_wren <= 1'b0;
	end
	else
	begin
		if (de_in)
		begin
			wr_addr <= wr_addr + 11'd1;
		
			if(cnt_de[1:0] == 2'b00)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b1; 
			end
			else if(cnt_de[1:0] == 2'b01)
			begin
				in0_wren <= 1'b1; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b0; 
			end
			else if(cnt_de[1:0] == 2'b10)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b1; 
				in2_wren <= 1'b0; 
				in3_wren <= 1'b0; 
			end
			else if(cnt_de[1:0] == 2'b11)
			begin
				in0_wren <= 1'b0; 
				in1_wren <= 1'b0; 
				in2_wren <= 1'b1; 
				in3_wren <= 1'b0; 
			end	
		end
		else
		begin
			wr_addr <= 11'd0;
			in0_wren <= 1'b0;
			in1_wren <= 1'b0;
			in2_wren <= 1'b0;
			in3_wren <= 1'b0;
		end	
	end
end



reg [23:0] in_0, in_1, in_2, in_3;

always @(posedge clk)
begin
	if (de_in)
	begin
		in_0 <= in_0 + 24'd1;
		in_1 <= in_1 + 24'd1;
		in_2 <= in_2 + 24'd1;
		in_3 <= in_3 + 24'd1;
	end
	else
	begin
		in_0 <= 24'd1;
		in_1 <= 24'd2;
		in_2 <= 24'd3;
		in_3 <= 24'd4;
	end
end
wire [10:0] addr0, addr1, addr2, addr3;


assign addr0 = (in0_wren) ? wr_addr : rd_addr;
assign addr1 = (in1_wren) ? wr_addr : rd_addr;
assign addr2 = (in2_wren) ? wr_addr : rd_addr;
assign addr3 = (in3_wren) ? wr_addr : rd_addr;


bram_24 bram_in0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(addr0),
	.data	(in_0),
	
	.q		(in0_q)
);

bram_24 bram_in1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(addr1),
	.data	(in_1),
	
	.q		(in1_q)
);

bram_24 bram_in2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(addr2),
	.data	(in_2),
	
	.q		(in2_q)
);

bram_24 bram_in3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(addr3),
	.data	(in_3),
	
	.q		(in3_q)
);


		
endmodule		
/////////////////////////////////////////////////////////////////////////////////////////

