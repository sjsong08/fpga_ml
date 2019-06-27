module conv_layer(
	input clk,
	input RESET,
	//input in,
	input start_wr, start_rd,
	output result
);

parameter bit_depth = 16;


wire [bit_depth*9-1:0] in;
wire [bit_depth-1:0] result;
reg [bit_depth*14-1:0] w1, w2; 

reg [9:0] cnt_wr, cnt_rd;
reg [4:0] addr_a, addr_b;
wire [bit_depth-1:0] data_a = 16'd2;
wire [bit_depth-1:0] data_b = 16'd1;
reg wren_a, wren_b;



assign in = {9*16'd1};

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
	end
	
	if(start_wr)
	begin
		if(cnt_wr==10'd0)
			cnt_wr<=10'd1;
		else if(cnt_wr<=10'd14)
		begin
			cnt_wr<=cnt_wr+10'd1;
			wren_a <= 1'b1;
			wren_b <= 1'b1;
			addr_a <= cnt_wr[4:0] - 5'd1;
			addr_b  <= cnt_wr[4:0] + 5'd13;
		end
		else
		begin
			cnt_wr <= 10'd0;
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
			cnt_rd<=cnt_rd+10'd1;
			addr_a <= cnt_rd[4:0] - 5'd1;
			addr_b  <= cnt_rd[4:0] + 5'd13;
		end
		else if(cnt_rd==10'd15)
		begin
			cnt_rd<=10'd29;
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
			cnt_rd <= 10'd0;
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
bram bram0 (
	.clock	(clk),
	.wren_a	(wren_a),
	.wren_b	(wren_b),
	.data_a	(data_a),
	.data_b	(data_b),
	.address_a(addr_a),
	.address_b(addr_b),
	
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

wire [bit_depth*27-1:0] w = {w1, w2[bit_depth*14-1:bit_depth]};

// depth wise
wire [bit_depth-1:0] result0, result1, result2;
wire [bit_depth-1:0] result_a;
cnn conv0(
	.in0(in[bit_depth*9-1:bit_depth*8]),
	.in1(in[bit_depth*8-1:bit_depth*7]),
	.in2(in[bit_depth*7-1:bit_depth*6]),
	.in3(in[bit_depth*6-1:bit_depth*5]),
	.in4(in[bit_depth*5-1:bit_depth*4]),
	.in5(in[bit_depth*4-1:bit_depth*3]),
	.in6(in[bit_depth*3-1:bit_depth*2]),
	.in7(in[bit_depth*2-1:bit_depth*1]),
	.in8(in[bit_depth*1-1:bit_depth*0]),
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
	.in0(in[bit_depth*9-1:bit_depth*8]),
	.in1(in[bit_depth*8-1:bit_depth*7]),
	.in2(in[bit_depth*7-1:bit_depth*6]),
	.in3(in[bit_depth*6-1:bit_depth*5]),
	.in4(in[bit_depth*5-1:bit_depth*4]),
	.in5(in[bit_depth*4-1:bit_depth*3]),
	.in6(in[bit_depth*3-1:bit_depth*2]),
	.in7(in[bit_depth*2-1:bit_depth*1]),
	.in8(in[bit_depth*1-1:bit_depth*0]),
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
	.in0(in[bit_depth*9-1:bit_depth*8]),
	.in1(in[bit_depth*8-1:bit_depth*7]),
	.in2(in[bit_depth*7-1:bit_depth*6]),
	.in3(in[bit_depth*6-1:bit_depth*5]),
	.in4(in[bit_depth*5-1:bit_depth*4]),
	.in5(in[bit_depth*4-1:bit_depth*3]),
	.in6(in[bit_depth*3-1:bit_depth*2]),
	.in7(in[bit_depth*2-1:bit_depth*1]),
	.in8(in[bit_depth*1-1:bit_depth*0]),
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
