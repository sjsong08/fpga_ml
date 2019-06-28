module conv_layer(
	input clk,
	input RESET,
	input sel,
	input start_wr, start_rd,
	output [15:0] result,
	output reg [431:0] in, w
);


wire value = sel? 16'd1 : 16'd0;

reg [9:0] cnt_wr, cnt_rd;
reg [5:0] addr_in, addr_w;
wire [15:0] data_in = value;
wire [15:0] data_w = value;
reg wren_in, wren_w;


always@(negedge clk)
begin
	if(RESET)
	begin
		cnt_wr <= 10'd0;
		cnt_rd <= 10'd0;
		addr_in <= 6'd63;
		addr_w <= 6'd63;
		wren_w <= 1'b0;
		wren_in <= 1'b0;
	end
	
	if(start_wr)
	begin
		if(cnt_wr==10'd0)
			cnt_wr<=10'd1;
		else if(cnt_wr<=10'd27)
		begin
			cnt_wr<=cnt_wr+10'd1;
			wren_in <= 1'b1;
			wren_w <= 1'b1;
			addr_in <= cnt_wr[5:0] - 6'd1;
			addr_w  <= cnt_wr[5:0] + 6'd26;
		end
		else
		begin
			cnt_wr <= 10'd0;
			wren_in <= 1'b0;
			wren_w <= 1'b0;
			addr_in <= 6'd63;
			addr_w <= 6'd63;
		end
	end

	
	else if(start_rd)
	begin
		wren_in <= 1'b0;
		wren_w <= 1'b0;
		if(cnt_rd==10'd0)
			cnt_rd<=10'd1;
		else if(cnt_rd<=10'd27)
		begin
			cnt_rd<=cnt_rd+10'd1;
			addr_in <= cnt_rd[5:0] - 6'd1;
			addr_w  <= cnt_rd[5:0] + 6'd26;
		end
		else if(cnt_rd==10'd28)
		begin
			cnt_rd<=10'd29;
			addr_in <= 6'd63;
			addr_w <= 6'd63;
		end
		else if(cnt_rd==10'd29)
		begin
			cnt_rd <= 10'd30;
		end
		
		else
		begin
			addr_in <= 6'd63;
			addr_w <= 6'd63;
			cnt_rd <= 10'd0;
		end
	end
	
	else
	begin
		cnt_wr<=10'd0;
		cnt_rd<=10'd0;
		wren_in <= 1'b0;
		wren_w <= 1'b0;
		addr_in <= 6'd63;
		addr_w  <= 6'd63;
	end
end




wire [15:0] q_in, q_w;
bram bram0 (
	.clock	(clk),
	.wren_a	(wren_in),
	.wren_b	(wren_w),
	.data_a	(data_in),
	.data_b	(data_w),
	.address_a(addr_in),
	.address_b(addr_w),
	
	.q_a		(q_in),
	.q_b		(q_w)
);

//reg [431:0] in, w;
always@(posedge clk)
begin
	if(cnt_rd >= 30'd4 && cnt_rd <= 30'd30)
	begin
		in[15:0] <= q_in;
		w[15:0] <= q_w;
		in[431:16] <= in[415:0];
		w[431:16] <= in[415:0];
	end
end

// depth wise
wire [15:0] result0, result1, result2, result3, result4, result5, result6, result7, result8;
wire [15:0] result_a, result_b, result_c;
cnn conv0(
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
	.result(result0)
);

cnn conv1(
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
	.result(result1)
);

cnn conv2(
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
	.result(result2)
);

paral_add p_add0(
	.data0x(result0),
	.data1x(result1),
	.data2x(result2),
	.result(result_a)
);

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
endmodule
