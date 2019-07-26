`timescale 1us/1ns


module mid_bram(
	input wire clk,
	input wire RESET,

	input wire start_wr,
	input wire [20:0] in_a, in_b, in_c,
	input wire de_in,

	input wire in0_rden, in1_rden, in2_rden, in3_rden,
	input wire [10:0] rd_addr,

	output reg de_out,
	output reg fin_rd,
	output wire bram_toggle,
	output wire [20:0] qa_0, qa_1, qa_2, qa_3,
	output wire [20:0] qb_0, qb_1, qb_2, qb_3,
	output wire [20:0] qc_0, qc_1, qc_2, qc_3
);

parameter bit_depth = 8;
parameter image_width = 11'd28;
parameter image_height = 11'd28;




///////////////////////////////////////////////////////////////////////////////////

reg in0_wren, in1_wren, in2_wren, in3_wren;
reg [10:0] wr_addr;

reg [20:0] in_a_sam, in_b_sam, in_c_sam;
always@(negedge clk)
begin
	in_a_sam <= in_a;
	in_b_sam <= in_b;
	in_c_sam <= in_c;
end

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

assign bram_toggle = cnt_de[1];

always @(posedge clk)
begin
	if (cnt_de[0] == 1'b1 && de_del3 == 1'b0 && de_del4 == 1'b1)
		fin_rd <= 1'b1;
	else
		fin_rd <= 1'b0;
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
			wr_addr <= 11'd0;
			in0_wren <= 1'b0;
			in1_wren <= 1'b0;
			in2_wren <= 1'b0;
			in3_wren <= 1'b0;
		end	
	end
end

wire [10:0] addr0, addr1, addr2, addr3;

assign addr0 = (in0_wren) ? wr_addr : rd_addr;
assign addr1 = (in1_wren) ? wr_addr : rd_addr;
assign addr2 = (in2_wren) ? wr_addr : rd_addr;
assign addr3 = (in3_wren) ? wr_addr : rd_addr;

bram_21 bram_ina0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(addr0),
	.data	(in_a_sam),
	
	.q		(qa_0)
);
bram_21 bram_inb0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(addr0),
	.data	(in_b_sam),
	
	.q		(qb_0)
);
bram_21 bram_inc0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(addr0),
	.data	(in_c_sam),
	
	.q		(qc_0)
);



bram_21 bram_ina1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(addr1),
	.data	(in_a_sam),
	
	.q		(qa_1)
);
bram_21 bram_inb1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(addr1),
	.data	(in_b_sam),
	
	.q		(qb_1)
);
bram_21 bram_inc1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(addr1),
	.data	(in_c_sam),
	
	.q		(qc_1)
);



bram_21 bram_ina2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(addr2),
	.data	(in_a_sam),
	
	.q		(qa_2)
);
bram_21 bram_inb2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(addr2),
	.data	(in_b_sam),
	
	.q		(qb_2)
);
bram_21 bram_inc2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(addr2),
	.data	(in_c_sam),
	
	.q		(qc_2)
);



bram_21 bram_ina3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(addr3),
	.data	(in_a_sam),
	
	.q		(qa_3)
);
bram_21 bram_inb3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(addr3),
	.data	(in_b_sam),
	
	.q		(qb_3)
);
bram_21 bram_inc3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(addr3),
	.data	(in_c_sam),
	
	.q		(qc_3)
);

	
endmodule		
/////////////////////////////////////////////////////////////////////////////////////////

