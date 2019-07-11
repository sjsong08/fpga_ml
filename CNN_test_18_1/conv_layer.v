
module conv_layer(
	input wire clk,
	input wire RESET,
	input wire de,
	input wire [bit_depth-1:0] in,
	input wire start_wr, start_rd,
	output wire [bit_depth-1:0] result
);

parameter bit_depth = 16;


reg [bit_depth*14-1:0] w1, w2; 

reg [9:0] cnt_wr, cnt_rd;
reg [4:0] addr_a, addr_b;
wire [bit_depth-1:0] data_a = 16'd3;
wire [bit_depth-1:0] data_b = 16'd1;
reg wren_a, wren_b, rden_a, rden_b;


///////////////////////////////////////////////////////////////////////////////////

reg in0_wren, in0_rden, in1_wren, in1_rden, in2_wren, in2_rden, in3_wren, in3_rden;
reg [4:0] in_addr;

reg [bit_depth-1:0] in_sam;
always@(negedge clk)
	in_sam <= in;

reg de_del1;
reg de_del2;
reg de_del3;
reg de_del4;
reg de_del5;
reg de_del6;

reg [4:0] cnt_de;

always@(posedge clk)
begin	
	de_del1 <= de;
	de_del2 <= de_del1;
	de_del3 <= de_del2;
	de_del4 <= de_del3;
	de_del5 <= de_del4;
	de_del6 <= de_del5;
end

always @(posedge clk)
begin
	if (RESET || start_wr == 1'b0)
		cnt_de <= 5'd0;	
	if (de_del3 == 1'b0 && de_del4 == 1'b1)
	begin
		if (cnt_de == 5'd27)
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
		in0_rden <= 1'b0;
		in1_wren <= 1'b0;
		in1_rden <= 1'b0;
		in2_wren <= 1'b0;
		in2_rden <= 1'b0;
		in3_wren <= 1'b0;
		in3_rden <= 1'b0;
	end
	
	if(start_wr)
	begin
		if (de)
		begin
			in_addr <= in_addr + 5'd1;
			
			if(cnt_de[1:0] == 2'b00)
			begin
				in0_wren <= 1'b1; in0_rden <= 1'b0;
				in1_wren <= 1'b0; in1_rden <= 1'b1;
				in2_wren <= 1'b0; in2_rden <= 1'b1;
				in3_wren <= 1'b0; in3_rden <= 1'b1;
			end
			else if(cnt_de[1:0] == 2'b01)
			begin
				in0_wren <= 1'b0; in0_rden <= 1'b1;
				in1_wren <= 1'b1; in1_rden <= 1'b0;
				in2_wren <= 1'b0; in2_rden <= 1'b1;
				in3_wren <= 1'b0; in3_rden <= 1'b1;
			end
			else if(cnt_de[1:0] == 2'b10)
			begin
				in0_wren <= 1'b0; in0_rden <= 1'b1;
				in1_wren <= 1'b0; in1_rden <= 1'b1;
				in2_wren <= 1'b1; in2_rden <= 1'b0;
				in3_wren <= 1'b0; in3_rden <= 1'b1;
			end
			else if(cnt_de[1:0] == 2'b11)
			begin
				in0_wren <= 1'b0; in0_rden <= 1'b1;
				in1_wren <= 1'b0; in1_rden <= 1'b1;
				in2_wren <= 1'b0; in2_rden <= 1'b1;
				in3_wren <= 1'b1; in3_rden <= 1'b0;
			end

		end
		else
		begin
			in_addr <= 5'd0;
			in0_wren <= 1'b0;
			in0_rden <= 1'b0;
			in1_wren <= 1'b0;
			in1_rden <= 1'b0;
			in2_wren <= 1'b0;
			in2_rden <= 1'b0;
			in3_wren <= 1'b0;
			in3_rden <= 1'b0;
		end	
	end
	else
	begin
		in_addr <= 6'd0;
		in0_wren <= 1'b0;
		in0_rden <= 1'b0;
		in1_wren <= 1'b0;
		in1_rden <= 1'b0;
		in2_wren <= 1'b0;
		in2_rden <= 1'b0;
		in3_wren <= 1'b0;
		in3_rden <= 1'b0;
	end
end



wire [bit_depth-1:0] in0_q;
bram_1port bram_in0 (
	.clock	(clk),
	.wren	(in0_wren),
	.rden	(in0_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in0_q)
);

wire [bit_depth-1:0] in1_q;
bram_1port bram_in1 (
	.clock	(clk),
	.wren	(in1_wren),
	.rden	(in1_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in1_q)
);

wire [bit_depth-1:0] in2_q;
bram_1port bram_in2 (
	.clock	(clk),
	.wren	(in2_wren),
	.rden	(in2_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in2_q)
);

wire [bit_depth-1:0] in3_q;
bram_1port bram_in3 (
	.clock	(clk),
	.wren	(in3_wren),
	.rden	(in3_rden),
	.address(in_addr),
	.data	(in_sam),
	
	.q		(in3_q)
);


reg [bit_depth-1:0] in00, in01, in02, in10, in11, in12, in20, in21, in22;
always@(posedge clk)
begin
	if (de || de_del3)
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
		

reg [bit_depth*9-1:0] in_fin;

always @(posedge clk)
begin
	if (de_del6 && de_del4)
	begin
		in_fin[bit_depth*9-1:bit_depth*8] <= in00;
		in_fin[bit_depth*8-1:bit_depth*7] <= in01;
		in_fin[bit_depth*7-1:bit_depth*6] <= in02;
		in_fin[bit_depth*6-1:bit_depth*5] <= in10;
		in_fin[bit_depth*5-1:bit_depth*4] <= in11;
		in_fin[bit_depth*4-1:bit_depth*3] <= in12;
		in_fin[bit_depth*3-1:bit_depth*2] <= in20;
		in_fin[bit_depth*2-1:bit_depth*1] <= in21;
		in_fin[bit_depth*1-1:bit_depth*0] <= in22;
	end
	else
		in_fin <= 'b0;
end
		
		
		
		
/////////////////////////////////////////////////////////////////////////////////////////

always@(negedge clk)
begin
	if(RESET)
	begin
		cnt_wr <= 10'd0;
		cnt_rd <= 10'd0;
		addr_a <= 5'd31;
		addr_b <= 5'd31;
		wren_a <= 1'b0;
		wren_b <= 1'b0;
		rden_a <= 1'b0;
		rden_b <= 1'b0;
	end
	
	if(start_wr)
	begin
		if(cnt_wr==10'd0)
			cnt_wr<=10'd1;
		else if(cnt_wr<=10'd14)
		begin
			cnt_wr <= cnt_wr+10'd1;
			wren_a <= 1'b1;
			wren_b <= 1'b1;
			addr_a <= cnt_wr[4:0] - 5'd1;
			addr_b <= cnt_wr[4:0] + 5'd13;
		end
		else
		begin
			wren_a <= 1'b0;
			wren_b <= 1'b0;
			addr_a <= 5'd31;
			addr_b <= 5'd31;
		end
	end

	
	else if(start_rd)
	begin
		wren_a <= 1'b0;
		wren_b <= 1'b0;
		if(cnt_rd==10'd0)
			cnt_rd<=10'd1;
		else if(cnt_rd<=10'd14)
		begin
			rden_a <= 1'b1;
			rden_b <= 1'b1;
			cnt_rd <= cnt_rd + 10'd1;
			addr_a <= cnt_rd[4:0] - 5'd1;
			addr_b <= cnt_rd[4:0] + 5'd13;
		end
		else if(cnt_rd==10'd15)
		begin
			cnt_rd <= 10'd16;
			rden_a <= 1'b0;
			rden_b <= 1'b0;
			addr_a <= 5'd31;
			addr_b <= 5'd31;
		end
		else if(cnt_rd==10'd16)
		begin
			cnt_rd <= 10'd17;
		end
		
		else
		begin
			addr_a <= 5'd31;
			addr_b <= 5'd31;
		end
	end
	
	else
	begin
		cnt_wr<=10'd0;
		cnt_rd<=10'd0;
		wren_a <= 1'b0;
		wren_b <= 1'b0;
		addr_a <= 5'd31;
		addr_b  <= 5'd31;
	end
end




wire [bit_depth-1:0] q_a, q_b;
bram bram_w (
	.clock	(clk),
	.wren_a	(wren_a),
	.wren_b	(wren_b),
	.data_a	(data_a),
	.data_b	(data_b),
	.address_a(addr_a),
	.address_b(addr_b),
	.rden_a	(rden_a),
	.rden_b	(rden_b),
	
	.q_a		(q_a),
	.q_b		(q_b)
);

always@(posedge clk)
begin
	if(cnt_rd >= 30'd4 && cnt_rd <= 30'd17)
	begin
		w1[bit_depth-1:0] <= q_a;
		w2[bit_depth-1:0] <= q_b;
		w1[bit_depth*14-1:bit_depth] <= w1[bit_depth*13-1:0];
		w2[bit_depth*14-1:bit_depth] <= w2[bit_depth*13-1:0];
	end
end

wire [bit_depth*27-1:0] w = (RESET)? 432'd0 : {w1, w2[bit_depth*14-1:bit_depth]};

wire [bit_depth-1+4:0] result0, result1, result2;
wire [bit_depth-1:0] result_a;
cnn conv0(
	.in0(in_fin[bit_depth*9-1:bit_depth*8]),
	.in1(in_fin[bit_depth*8-1:bit_depth*7]),
	.in2(in_fin[bit_depth*7-1:bit_depth*6]),
	.in3(in_fin[bit_depth*6-1:bit_depth*5]),
	.in4(in_fin[bit_depth*5-1:bit_depth*4]),
	.in5(in_fin[bit_depth*4-1:bit_depth*3]),
	.in6(in_fin[bit_depth*3-1:bit_depth*2]),
	.in7(in_fin[bit_depth*2-1:bit_depth*1]),
	.in8(in_fin[bit_depth*1-1:bit_depth*0]),
	.w0(w[bit_depth*27-1:bit_depth*26]),
	.w1(w[bit_depth*26-1:bit_depth*25]),
	.w2(w[bit_depth*25-1:bit_depth*24]),
	.w3(w[bit_depth*24-1:bit_depth*23]),
	.w4(w[bit_depth*23-1:bit_depth*22]),
	.w5(w[bit_depth*22-1:bit_depth*21]),
	.w6(w[bit_depth*21-1:bit_depth*20]),
	.w7(w[bit_depth*20-1:bit_depth*19]),
	.w8(w[bit_depth*19-1:bit_depth*18]),
	.result(result0)
);

cnn conv1(
	.in0(in_fin[bit_depth*9-1:bit_depth*8]),
	.in1(in_fin[bit_depth*8-1:bit_depth*7]),
	.in2(in_fin[bit_depth*7-1:bit_depth*6]),
	.in3(in_fin[bit_depth*6-1:bit_depth*5]),
	.in4(in_fin[bit_depth*5-1:bit_depth*4]),
	.in5(in_fin[bit_depth*4-1:bit_depth*3]),
	.in6(in_fin[bit_depth*3-1:bit_depth*2]),
	.in7(in_fin[bit_depth*2-1:bit_depth*1]),
	.in8(in_fin[bit_depth*1-1:bit_depth*0]),
	.w0(w[bit_depth*18-1:bit_depth*17]),
	.w1(w[bit_depth*17-1:bit_depth*16]),
	.w2(w[bit_depth*16-1:bit_depth*15]),
	.w3(w[bit_depth*15-1:bit_depth*14]),
	.w4(w[bit_depth*14-1:bit_depth*13]),
	.w5(w[bit_depth*13-1:bit_depth*12]),
	.w6(w[bit_depth*12-1:bit_depth*11]),
	.w7(w[bit_depth*11-1:bit_depth*10]),
	.w8(w[bit_depth*10-1:bit_depth*9]),
	.result(result1)
);

cnn conv2(
	.in0(in_fin[bit_depth*9-1:bit_depth*8]),
	.in1(in_fin[bit_depth*8-1:bit_depth*7]),
	.in2(in_fin[bit_depth*7-1:bit_depth*6]),
	.in3(in_fin[bit_depth*6-1:bit_depth*5]),
	.in4(in_fin[bit_depth*5-1:bit_depth*4]),
	.in5(in_fin[bit_depth*4-1:bit_depth*3]),
	.in6(in_fin[bit_depth*3-1:bit_depth*2]),
	.in7(in_fin[bit_depth*2-1:bit_depth*1]),
	.in8(in_fin[bit_depth*1-1:bit_depth*0]),
	.w0(w[bit_depth*9-1:bit_depth*8]),
	.w1(w[bit_depth*8-1:bit_depth*7]),
	.w2(w[bit_depth*7-1:bit_depth*6]),
	.w3(w[bit_depth*6-1:bit_depth*5]),
	.w4(w[bit_depth*5-1:bit_depth*4]),
	.w5(w[bit_depth*4-1:bit_depth*3]),
	.w6(w[bit_depth*3-1:bit_depth*2]),
	.w7(w[bit_depth*2-1:bit_depth*1]),
	.w8(w[bit_depth*1-1:bit_depth*0]),
	.result(result2)
);

paral_add p_add0(
	.data0x(result0),
	.data1x(result1),
	.data2x(result2),
	.result(result_a)
);

assign result = result_a;
endmodule
