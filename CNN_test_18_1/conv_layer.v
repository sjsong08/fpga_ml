
module conv_layer(
	input wire clk,
	input wire RESET,
	
	input wire start_rd,
	input wire [bit_depth*3-1:0] in0_q, in1_q, in2_q, in3_q,
	
	output reg [4:0] in_addr,
	output reg in0_rden, in1_rden, in2_rden, in3_rden,
	output wire [62:0] result,
	output reg fin_rd,
	output wire de_out
);

parameter bit_depth = 8;
parameter image_width = 12'd28;
parameter image_height = 11'd28;

reg [11:0] cnt_clk;
always @(posedge clk)
begin
	if (start_rd)
	begin
		if (cnt_clk == image_width - 12'd1)
			cnt_clk <= 12'd0;
		else
			cnt_clk <= cnt_clk + 12'd0;
	end

	else
		cnt_clk <= 12'd0;
end

reg de_in;
always @(posedge clk)
begin
	if (cnt_clk >= 12'd10 && cnt_clk <= image_width + 12'd10 - 12'd1)
		de_in <= 1'b1;
	else
		de_in <= 1'b0;
end


reg de_del1;
reg de_del2;
reg de_del3;
reg de_del4;
reg de_del5;
reg de_del6;

always@(posedge clk)
begin	
	de_del1 <= de_in;
	de_del2 <= de_del1;
	de_del3 <= de_del2;
	de_del4 <= de_del3;
	de_del5 <= de_del4;
	de_del6 <= de_del5;
end

assign de_out = de_del1 & de_del6;

always @(posedge clk)
begin
	if (de_del2==1'b0 && de_del3==1'b1)
		fin_rd <= 1'b1;
	else
		fin_rd <= 1'b0;
end




reg [11:0] cnt_de;
always @(posedge clk)
begin
	if (RESET || start_rd == 1'b0)
		cnt_de <= 12'd0;	
	if (de_del3 == 1'b0 && de_del4 == 1'b1)
	begin
		if (cnt_de == image_height - 12'd1)
			cnt_de <= 12'd0;
		else
			cnt_de <= cnt_de + 12'd1;
	end
	else
		cnt_de <= cnt_de;
end




reg [4:0] in_addr;


always@(negedge clk)
begin
	if(RESET)
	begin
		in_addr <= 5'd0;
		in0_rden <= 1'b0;
		in1_rden <= 1'b0;
		in2_rden <= 1'b0;
		in3_rden <= 1'b0;
	end
	
	if(start_rd)
	begin
		if (de_in)
		begin
			in_addr <= in_addr + 5'd1;
			
			if(cnt_de[1:0] == 2'b00)
			begin
				in0_rden <= 1'b1;
				in1_rden <= 1'b1;
				in2_rden <= 1'b1;
				in3_rden <= 1'b0;
			end
			else if(cnt_de[1:0] == 2'b01)
			begin
				in0_rden <= 1'b0;
				in1_rden <= 1'b1;
				in2_rden <= 1'b1;
				in3_rden <= 1'b1;
			end
			else if(cnt_de[1:0] == 2'b10)
			begin
				in0_rden <= 1'b1;
				in1_rden <= 1'b0;
				in2_rden <= 1'b1;
				in3_rden <= 1'b1;
			end
			else if(cnt_de[1:0] == 2'b11)
			begin
				in0_rden <= 1'b1;
				in1_rden <= 1'b1;
				in2_rden <= 1'b0;
				in3_rden <= 1'b1;
			end

		end
		else
		begin
			in_addr <= 5'd0;
			in0_rden <= 1'b0;
			in1_rden <= 1'b0;
			in2_rden <= 1'b0;
			in3_rden <= 1'b0;
		end	
	end
	else
	begin
		in_addr <= 5'd0;
		in0_rden <= 1'b0;
		in1_rden <= 1'b0;
		in2_rden <= 1'b0;
		in3_rden <= 1'b0;	
	end
end




reg [bit_depth*3-1:0] in00, in01, in02, in10, in11, in12, in20, in21, in22;
always@(posedge clk)
begin
	if (de_del2)
	begin
		in00 <= in01; in01 <= in02;
		in10 <= in11; in11 <= in12;
		in20 <= in21; in21 <= in22;
	
		if(cnt_de[1:0] == 2'b00)
		begin
			in02 <= in1_q;
			in12 <= in2_q;
			in22 <= in3_q;
		end
		else if(cnt_de[1:0] == 2'b01)
		begin
			in02 <= in2_q;
			in12 <= in3_q;
		        in22 <= in0_q;	
		end
		else if(cnt_de[1:0] == 2'b10)
		begin
			in02 <= in3_q;
			in12 <= in0_q;
		        in22 <= in1_q;
		end
		else if(cnt_de[1:0] == 2'b11)
		begin
			in02 <= in0_q;
			in12 <= in1_q;
		        in22 <= in2_q;
		end
	end
	else
	begin
		in00 <= 'b0; in01 <= 'b0; in02 <= 'b0;
		in10 <= 'b0; in11 <= 'b0; in12 <= 'b0;
		in20 <= 'b0; in21 <= 'b0; in22 <= 'b0;
	end
end
		

reg [bit_depth*9-1:0] in_a;

always @(posedge clk)
begin
	if (de_del5 && de)
	begin
		in_a[bit_depth*9-1:bit_depth*8] <= in00[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*8-1:bit_depth*7] <= in01[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*7-1:bit_depth*6] <= in02[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*6-1:bit_depth*5] <= in10[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*5-1:bit_depth*4] <= in11[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*4-1:bit_depth*3] <= in12[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*3-1:bit_depth*2] <= in20[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*2-1:bit_depth*1] <= in21[bit_depth*3-1:bit_depth*2];
		in_a[bit_depth*1-1:bit_depth*0] <= in22[bit_depth*3-1:bit_depth*2];
	end
	else
		in_a <= 'b0;
end
		
reg [bit_depth*9-1:0] in_b;

always @(posedge clk)
begin
	if (de_del5 && de)
	begin
		in_b[bit_depth*9-1:bit_depth*8] <= in00[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*8-1:bit_depth*7] <= in01[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*7-1:bit_depth*6] <= in02[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*6-1:bit_depth*5] <= in10[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*5-1:bit_depth*4] <= in11[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*4-1:bit_depth*3] <= in12[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*3-1:bit_depth*2] <= in20[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*2-1:bit_depth*1] <= in21[bit_depth*2-1:bit_depth*1];
		in_b[bit_depth*1-1:bit_depth*0] <= in22[bit_depth*2-1:bit_depth*1];
	end
	else
		in_b <= 'b0;
end
		
reg [bit_depth*9-1:0] in_c;

always @(posedge clk)
begin
	if (de_del5 && de)
	begin
		in_c[bit_depth*9-1:bit_depth*8] <= in00[bit_depth*1-1:0];
		in_c[bit_depth*8-1:bit_depth*7] <= in01[bit_depth*1-1:0];
		in_c[bit_depth*7-1:bit_depth*6] <= in02[bit_depth*1-1:0];
		in_c[bit_depth*6-1:bit_depth*5] <= in10[bit_depth*1-1:0];
		in_c[bit_depth*5-1:bit_depth*4] <= in11[bit_depth*1-1:0];
		in_c[bit_depth*4-1:bit_depth*3] <= in12[bit_depth*1-1:0];
		in_c[bit_depth*3-1:bit_depth*2] <= in20[bit_depth*1-1:0];
		in_c[bit_depth*2-1:bit_depth*1] <= in21[bit_depth*1-1:0];
		in_c[bit_depth*1-1:bit_depth*0] <= in22[bit_depth*1-1:0];
	end
	else
		in_c <= 'b0;
end
		
		
/////////////////////////////////////////////////////////////////////////////////////////

reg [bit_depth-1:0] w0, w1, w2;

always @(posedge clk)
begin
	w0 <= 'b1;
	w1 <= 'b1;
	w2 <= 'b1;
end




wire [18:0] resulta0, resulta1, resulta2, resultb0, resultb1, resultb2, resultc0, resultc1, resultc2;

cnn ch_a_0(
	.in0(in_a[bit_depth*9-1:bit_depth*8]),
	.in1(in_a[bit_depth*8-1:bit_depth*7]),
	.in2(in_a[bit_depth*7-1:bit_depth*6]),
	.in3(in_a[bit_depth*6-1:bit_depth*5]),
	.in4(in_a[bit_depth*5-1:bit_depth*4]),
	.in5(in_a[bit_depth*4-1:bit_depth*3]),
	.in6(in_a[bit_depth*3-1:bit_depth*2]),
	.in7(in_a[bit_depth*2-1:bit_depth*1]),
	.in8(in_a[bit_depth*1-1:bit_depth*0]),
	.w0(w0),
	.w1(w0),
	.w2(w0),
	.w3(w0),
	.w4(w0),
	.w5(w0),
	.w6(w0),
	.w7(w0),
	.w8(w0),
	.result(resulta0)
);

cnn ch_a_1(
	.in0(in_a[bit_depth*9-1:bit_depth*8]),
	.in1(in_a[bit_depth*8-1:bit_depth*7]),
	.in2(in_a[bit_depth*7-1:bit_depth*6]),
	.in3(in_a[bit_depth*6-1:bit_depth*5]),
	.in4(in_a[bit_depth*5-1:bit_depth*4]),
	.in5(in_a[bit_depth*4-1:bit_depth*3]),
	.in6(in_a[bit_depth*3-1:bit_depth*2]),
	.in7(in_a[bit_depth*2-1:bit_depth*1]),
	.in8(in_a[bit_depth*1-1:bit_depth*0]),
	.w0(w1),
	.w1(w1),
	.w2(w1),
	.w3(w1),
	.w4(w1),
	.w5(w1),
	.w6(w1),
	.w7(w1),
	.w8(w1),
	.result(resulta1)
);

cnn ch_a_2(
	.in0(in_a[bit_depth*9-1:bit_depth*8]),
	.in1(in_a[bit_depth*8-1:bit_depth*7]),
	.in2(in_a[bit_depth*7-1:bit_depth*6]),
	.in3(in_a[bit_depth*6-1:bit_depth*5]),
	.in4(in_a[bit_depth*5-1:bit_depth*4]),
	.in5(in_a[bit_depth*4-1:bit_depth*3]),
	.in6(in_a[bit_depth*3-1:bit_depth*2]),
	.in7(in_a[bit_depth*2-1:bit_depth*1]),
	.in8(in_a[bit_depth*1-1:bit_depth*0]),
	.w0(w2),
	.w1(w2),
	.w2(w2),
	.w3(w2),
	.w4(w2),
	.w5(w2),
	.w6(w2),
	.w7(w2),
	.w8(w2),
	.result(resulta2)
);

cnn ch_b_0(
	.in0(in_b[bit_depth*9-1:bit_depth*8]),
	.in1(in_b[bit_depth*8-1:bit_depth*7]),
	.in2(in_b[bit_depth*7-1:bit_depth*6]),
	.in3(in_b[bit_depth*6-1:bit_depth*5]),
	.in4(in_b[bit_depth*5-1:bit_depth*4]),
	.in5(in_b[bit_depth*4-1:bit_depth*3]),
	.in6(in_b[bit_depth*3-1:bit_depth*2]),
	.in7(in_b[bit_depth*2-1:bit_depth*1]),
	.in8(in_b[bit_depth*1-1:bit_depth*0]),
	.w0(w0),
	.w1(w0),
	.w2(w0),
	.w3(w0),
	.w4(w0),
	.w5(w0),
	.w6(w0),
	.w7(w0),
	.w8(w0),
	.result(resultb0)
);

cnn ch_b_1(
	.in0(in_b[bit_depth*9-1:bit_depth*8]),
	.in1(in_b[bit_depth*8-1:bit_depth*7]),
	.in2(in_b[bit_depth*7-1:bit_depth*6]),
	.in3(in_b[bit_depth*6-1:bit_depth*5]),
	.in4(in_b[bit_depth*5-1:bit_depth*4]),
	.in5(in_b[bit_depth*4-1:bit_depth*3]),
	.in6(in_b[bit_depth*3-1:bit_depth*2]),
	.in7(in_b[bit_depth*2-1:bit_depth*1]),
	.in8(in_b[bit_depth*1-1:bit_depth*0]),
	.w0(w1),
	.w1(w1),
	.w2(w1),
	.w3(w1),
	.w4(w1),
	.w5(w1),
	.w6(w1),
	.w7(w1),
	.w8(w1),
	.result(resultb1)
);

cnn ch_b_2(
	.in0(in_b[bit_depth*9-1:bit_depth*8]),
	.in1(in_b[bit_depth*8-1:bit_depth*7]),
	.in2(in_b[bit_depth*7-1:bit_depth*6]),
	.in3(in_b[bit_depth*6-1:bit_depth*5]),
	.in4(in_b[bit_depth*5-1:bit_depth*4]),
	.in5(in_b[bit_depth*4-1:bit_depth*3]),
	.in6(in_b[bit_depth*3-1:bit_depth*2]),
	.in7(in_b[bit_depth*2-1:bit_depth*1]),
	.in8(in_b[bit_depth*1-1:bit_depth*0]),
	.w0(w2),
	.w1(w2),
	.w2(w2),
	.w3(w2),
	.w4(w2),
	.w5(w2),
	.w6(w2),
	.w7(w2),
	.w8(w2),
	.result(resultb2)
);

cnn ch_c_0(
	.in0(in_c[bit_depth*9-1:bit_depth*8]),
	.in1(in_c[bit_depth*8-1:bit_depth*7]),
	.in2(in_c[bit_depth*7-1:bit_depth*6]),
	.in3(in_c[bit_depth*6-1:bit_depth*5]),
	.in4(in_c[bit_depth*5-1:bit_depth*4]),
	.in5(in_c[bit_depth*4-1:bit_depth*3]),
	.in6(in_c[bit_depth*3-1:bit_depth*2]),
	.in7(in_c[bit_depth*2-1:bit_depth*1]),
	.in8(in_c[bit_depth*1-1:bit_depth*0]),
	.w0(w0),
	.w1(w0),
	.w2(w0),
	.w3(w0),
	.w4(w0),
	.w5(w0),
	.w6(w0),
	.w7(w0),
	.w8(w0),
	.result(resultc0)
);

cnn ch_c_1(
	.in0(in_c[bit_depth*9-1:bit_depth*8]),
	.in1(in_c[bit_depth*8-1:bit_depth*7]),
	.in2(in_c[bit_depth*7-1:bit_depth*6]),
	.in3(in_c[bit_depth*6-1:bit_depth*5]),
	.in4(in_c[bit_depth*5-1:bit_depth*4]),
	.in5(in_c[bit_depth*4-1:bit_depth*3]),
	.in6(in_c[bit_depth*3-1:bit_depth*2]),
	.in7(in_c[bit_depth*2-1:bit_depth*1]),
	.in8(in_c[bit_depth*1-1:bit_depth*0]),
	.w0(w1),
	.w1(w1),
	.w2(w1),
	.w3(w1),
	.w4(w1),
	.w5(w1),
	.w6(w1),
	.w7(w1),
	.w8(w1),
	.result(resultc1)
);

cnn ch_c_2(
	.in0(in_c[bit_depth*9-1:bit_depth*8]),
	.in1(in_c[bit_depth*8-1:bit_depth*7]),
	.in2(in_c[bit_depth*7-1:bit_depth*6]),
	.in3(in_c[bit_depth*6-1:bit_depth*5]),
	.in4(in_c[bit_depth*5-1:bit_depth*4]),
	.in5(in_c[bit_depth*4-1:bit_depth*3]),
	.in6(in_c[bit_depth*3-1:bit_depth*2]),
	.in7(in_c[bit_depth*2-1:bit_depth*1]),
	.in8(in_c[bit_depth*1-1:bit_depth*0]),
	.w0(w2),
	.w1(w2),
	.w2(w2),
	.w3(w2),
	.w4(w2),
	.w5(w2),
	.w6(w2),
	.w7(w2),
	.w8(w2),
	.result(resultc2)
);

wire result_0, result_1, result_2; 
para_add padd_0(
	.data0x(resulta0),
	.data1x(resultb0),
	.data2x(resultc0),
	.result(result_0)
);

para_add padd_1(
	.data0x(resulta1),
	.data1x(resultb1),
	.data2x(resultc1),
	.result(result_1)
);


para_add padd_2(
	.data0x(resulta2),
	.data1x(resultb2),
	.data2x(resultc2),
	.result(result_2)
);


assign result = {result_0, result_1, result_2};




endmodule
