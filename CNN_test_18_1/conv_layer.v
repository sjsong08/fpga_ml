

module conv_layer(
	input clk,
	input RESET,
	input de,
	input in,
	input start_wr, start_rd,
	output wire result
);

parameter bit_depth = 16;

wire de;
wire [bit_depth-1:0] in;
wire [bit_depth-1:0] result;
reg [bit_depth*14-1:0] w1, w2; 

reg [9:0] cnt_wr, cnt_rd;
reg [4:0] addr_a, addr_b;
wire [bit_depth-1:0] data_a = 16'd3;
wire [bit_depth-1:0] data_b = 16'd1;
reg wren_a, wren_b, rden_a, rden_b;


///////////////////////////////////////////////////////////////////////////////////

reg in_wren_a, in_rden_a, in_wren_b, in_rden_b;
reg [5:0] in0_addr_a, in0_addr_b; 
reg [5:0] in1_addr_a, in1_addr_b; 
reg [5:0] in2_addr_a, in2_addr_b; 


reg [bit_depth-1:0] in_sam;
always@(negedge clk)
	in_sam <= in;

reg de_del1, de_del2, de_del3, de_del4, de_del5, de_del6;

always@(posedge clk)
begin	
	de_del1 <= de;
	de_del2 <= de_del1;
	de_del3 <= de_del2;
	de_del4 <= de_del3;
	de_del5 <= de_del4;
	de_del6 <= de_del5;
end


reg [3:0] cnt_de;
always @(posedge clk)
begin
	if (RESET || start_wr == 1'b0)
		cnt_de <= 2'd0;	
	if (de == 1'b0 && de_del1 == 1'b1)
		cnt_de <= cnt_de + 1'b1;
	else
		cnt_de <= cnt_de;
end

always@(negedge clk)
begin
	if(RESET)
	begin
		in_wren_a <= 1'b0;
		in_wren_b <= 1'b0;
		in_rden_a <= 1'b0;
		in_rden_b <= 1'b0;
		in0_addr_a <= 6'b000000;
		in0_addr_b <= 6'b100000;
		in1_addr_a <= 6'b000000;
		in1_addr_b <= 6'b100000;
		in2_addr_a <= 6'b000000;
		in2_addr_b <= 6'b100000;
	end
	
	if(start_wr)
	begin
		if (de)
		begin
			in_wren_a <= 1'b1;
			in_rden_a <= 1'b0;
			in_wren_b <= 1'b0;
			in_rden_b <= 1'b1;
			in0_addr_a <= in0_addr_a + 6'b1;
			in0_addr_b <= in0_addr_b + 6'b1;
			in1_addr_a <= in1_addr_a + 6'b1;
			in1_addr_b <= in1_addr_b + 6'b1;
			in2_addr_a <= in2_addr_a + 6'b1;
			in2_addr_b <= in2_addr_b + 6'b1;
		end
		else
		begin
			in_wren_a <= 1'b0;
			in_rden_a <= 1'b0;
			in_wren_b <= 1'b0;
			in_rden_b <= 1'b0;

			if(cnt_de[0] == 1'b0)
			begin
				in0_addr_a <= 6'b000000; 	in0_addr_b <= 6'b100000;
				in1_addr_a <= 6'b100000 - 6'd2;	in1_addr_b <= 6'b000000;
				in2_addr_a <= 6'b000000 - 6'd2;	in2_addr_b <= 6'b100000;
			end
			else if(cnt_de[0] == 1'b1)
			begin
				in0_addr_a <= 6'b100000; 	in0_addr_b <= 6'b000000;
				in1_addr_a <= 6'b000000 - 6'd2;	in1_addr_b <= 6'b100000;
				in2_addr_a <= 6'b100000 - 6'd2;	in2_addr_b <= 6'b000000;
			end

		end
			
	end
	else
	begin
		in_wren_a <= 1'b0;
		in_wren_b <= 1'b0;
		in_rden_a <= 1'b0;
		in_rden_b <= 1'b0;
		in0_addr_a <= 6'b000000;
		in0_addr_b <= 6'b100000;
		in1_addr_a <= 6'b000000;
		in1_addr_b <= 6'b100000;
		in2_addr_a <= 6'b000000;
		in2_addr_b <= 6'b100000;
	end

end


wire [bit_depth-1:0] in0_q_a, in0_q_b;
wire [bit_depth-1:0] in1_q_a, in1_q_b;
wire [bit_depth-1:0] in2_q_a, in2_q_b;

reg [15:0] in0_sam, in1_sam, in2_sam;
always @(negedge clk)
begin
	in0_sam <= in0_q_b;
	in1_sam <= in1_q_b;
	in2_sam <= in2_q_b;
end


bram_64 bram_in0 (
	.clock	(clk),
	.wren_a	(in_wren_a),
	.wren_b	(in_wren_b),
	.rden_a	(in_rden_a),
	.rden_b	(in_rden_b),
	.address_a(in0_addr_a),
	.address_b(in0_addr_b),
	.data_a	(in_sam),
	.data_b	(in_sam),
	
	.q_a		(in0_q_a),
	.q_b		(in0_q_b)
);


bram_64 bram_in1 (
	.clock	(clk),
	.wren_a	(in_wren_a),
	.wren_b	(in_wren_b),
	.rden_a	(in_rden_a),
	.rden_b	(in_rden_b),
	.address_a(in1_addr_a),
	.address_b(in1_addr_b),
	.data_a	(in0_sam),
	.data_b	(in0_sam),

	.q_a		(in1_q_a),
	.q_b		(in1_q_b)
);


bram_64 bram_in2 (
	.clock	(clk),
	.wren_a	(in_wren_a),
	.wren_b	(in_wren_b),
	.rden_a	(in_rden_a),
	.rden_b	(in_rden_b),
	.address_a(in2_addr_a),
	.address_b(in2_addr_b),
	.data_a	(in1_sam),
	.data_b	(in1_sam),

	.q_a		(in2_q_a),
	.q_b		(in2_q_b)
);


reg [bit_depth-1:0] in00, in01, in02, in10, in11, in12, in20, in21, in22;
always@(posedge clk)
begin
	if (de || de_del3)
	begin
		in00 <= in2_q_b; in01 <= in00; in02 <= in01;
		in10 <= in1_q_b; in11 <= in10; in12 <= in11;
		in20 <= in0_q_b; in21 <= in20; in22 <= in21;
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

wire [bit_depth-1:0] result0, result1, result2;
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
