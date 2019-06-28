module conv_layer(
	input clk,
	input RESET,
	input in,
	input start_wr, start_rd,
	output result
);

parameter bit_depth = 16;


wire [bit_depth*9-1:0] in;
wire [bit_depth-1:0] result;
reg [bit_depth*14-1:0] w1, w2; 

reg [9:0] cnt_wr, cnt_rd;
reg [4:0] addr_a, addr_b;
wire [bit_depth-1:0] data_a = 16'd3;
wire [bit_depth-1:0] data_b = 16'd1;
reg wren_a, wren_b, rden_a, rden_b;




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
bram bram0 (
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

<<<<<<< HEAD
cnn conv3(
	.in0(in[15:0]),
	.in1(in[31:16]),
	.in2(in[47:32]),
	.in3(in[63:48]),
	.in4(in[79:64]),
	.in5(in[95:80]),
	.in6(in[111:96]),
	.in7(in[127:112]),
	.in8(in[143:128]),
	.w0(w[15:0]),
	.w1(w[31:16]),
	.w2(w[47:32]),
	.w3(w[63:48]),
	.w4(w[79:64]),
	.w5(w[95:80]),
	.w6(w[111:96]),
	.w7(w[127:112]),
	.w8(w[143:128]),
	.result(result3)
);

cnn conv4(
	.in0(in[159:144]),
	.in1(in[175:160]),
	.in2(in[191:176]),
	.in3(in[207:192]),
	.in4(in[223:208]),
	.in5(in[239:224]),
	.in6(in[255:240]),
	.in7(in[271:256]),
	.in8(in[287:272]),
	.w0(w[159:144]),
	.w1(w[175:160]),
	.w2(w[191:176]),
	.w3(w[207:192]),
	.w4(w[223:208]),
	.w5(w[239:224]),
	.w6(w[255:240]),
	.w7(w[271:256]),
	.w8(w[287:272]),
	.result(result4)
);

cnn conv5(
	.in0(in[303:288]),
	.in1(in[319:304]),
	.in2(in[335:320]),
	.in3(in[351:336]),
	.in4(in[367:352]),
	.in5(in[383:368]),
	.in6(in[399:384]),
	.in7(in[415:400]),
	.in8(in[431:416]),
	.w0(w[303:288]),
	.w1(w[319:304]),
	.w2(w[335:320]),
	.w3(w[351:336]),
	.w4(w[367:352]),
	.w5(w[383:368]),
	.w6(w[399:384]),
	.w7(w[415:400]),
	.w8(w[431:416]),
	.result(result5)
);

paral_add p_add1(
	.data0x(result3),
	.data1x(result4),
	.data2x(result5),
	.result(result_b)
);
cnn conv6(
	.in0(in[15:0]),
	.in1(in[31:16]),
	.in2(in[47:32]),
	.in3(in[63:48]),
	.in4(in[79:64]),
	.in5(in[95:80]),
	.in6(in[111:96]),
	.in7(in[127:112]),
	.in8(in[143:128]),
	.w0(w[15:0]),
	.w1(w[31:16]),
	.w2(w[47:32]),
	.w3(w[63:48]),
	.w4(w[79:64]),
	.w5(w[95:80]),
	.w6(w[111:96]),
	.w7(w[127:112]),
	.w8(w[143:128]),
	.result(result6)
);

cnn conv7(
	.in0(in[159:144]),
	.in1(in[175:160]),
	.in2(in[191:176]),
	.in3(in[207:192]),
	.in4(in[223:208]),
	.in5(in[239:224]),
	.in6(in[255:240]),
	.in7(in[271:256]),
	.in8(in[287:272]),
	.w0(w[159:144]),
	.w1(w[175:160]),
	.w2(w[191:176]),
	.w3(w[207:192]),
	.w4(w[223:208]),
	.w5(w[239:224]),
	.w6(w[255:240]),
	.w7(w[271:256]),
	.w8(w[287:272]),
	.result(result7)
);

cnn conv8(
	.in0(in[303:288]),
	.in1(in[319:304]),
	.in2(in[335:320]),
	.in3(in[351:336]),
	.in4(in[367:352]),
	.in5(in[383:368]),
	.in6(in[399:384]),
	.in7(in[415:400]),
	.in8(in[431:416]),
	.w0(w[303:288]),
	.w1(w[319:304]),
	.w2(w[335:320]),
	.w3(w[351:336]),
	.w4(w[367:352]),
	.w5(w[383:368]),
	.w6(w[399:384]),
	.w7(w[415:400]),
	.w8(w[431:416]),
	.result(result8)
);

paral_add p_add2(
	.data0x(result6),
	.data1x(result7),
	.data2x(result8),
	.result(result_c)
);

assign result = result_a + result_b + result_c;
=======

assign result = result_a;
>>>>>>> 189a62c202e19c582985203686f074e94f11a252
endmodule
