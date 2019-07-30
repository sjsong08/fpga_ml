module convLayer #(
	parameter inBD = 8,
	parameter BD = 18
)(
	input clk,
	input reset,
	input ready_in,
	input [inBD*3-1:0] d0, d1, d2, d3,
	
	output reg conven,
	output reg [10:0] rdaddr,
	output [BD-1:0] qa, qb, qc,
	output reg next_st_conv, next_st_mp,
	output reg [10:0] wraddr,
	output reg wren,
	output reg bram_toggle,
	output reg [1:0] bram_num
);


parameter INWIDTH = 11'd1920;
parameter OUTWIDTH = 11'd1918;


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
	
reg pre_wait, pre_wait_check;
always@(negedge clk)
begin
	if(reset)
		pre_wait <= 1'b0;
	else
	begin
		if(conven&&ready)
			pre_wait <= 1'b1;
		else if(pre_wait_check)
			pre_wait <= 1'b0;
		else
			pre_wait <= pre_wait;
	end
end



always@(negedge clk)
begin
	if(reset)
	begin
		conven <= 1'b0;
		pre_wait_check <= 1'b0;
	end
	else
	begin
		if(ready)
			conven <= 1'b1;
		else if(rdaddr == INWIDTH - 11'd1) 	
		begin
			if(pre_wait)
			begin
				conven<= 1'b1;
				pre_wait_check <= 1'b1;
			end
			else
				conven <= 1'b0;
		end
		else
		begin
			pre_wait_check <= 1'b0;
			conven <= conven;
		end
	end
end

always@(negedge clk)
begin
	if(reset)
		rdaddr <= 11'd0;
	else
	begin
		if(conven)
		begin
			if(rdaddr == INWIDTH +11'd2 - 11'd1)
				rdaddr <= 11'd0;
			else
				rdaddr <= rdaddr + 11'd1;
		end
		else
			rdaddr <= 11'd0;
	end
end

//reg wren;
//reg [1:0] bram_num;
always@(negedge clk)
begin
	if(reset)
	begin
		wraddr <= -11'd1;
		wren <= 1'b0;
		bram_num <= 2'd0;
	end
	else
	begin
		if(conven && rdaddr >= 11'd3)
		begin
			wren <= 1'b1;
			wraddr <= wraddr + 11'd1;
		end
		else if(!conven) 
		begin
			if(wraddr == OUTWIDTH + 11'd2)
			begin
				wraddr <= -11'd1;
				bram_num <= bram_num + 2'd1;
			end
			else if(wraddr == OUTWIDTH - 11'd1)
			begin
				wraddr <= wraddr + 11'd1;
				wren <= 1'b0;
			end

			else if(wraddr < OUTWIDTH + 11'd2 && wraddr > 11'd0)
				wraddr <= wraddr + 11'd1;
			else
				wraddr <= wraddr;
		end

		else
		begin
			wren <= 1'b0;
			wraddr <= wraddr;
		end
	end
end

reg next_ready_conv;
always@(negedge clk)
begin
	if(reset)
		next_ready_conv <= 1'b0;
	else if(bram_num == 2'd2)
		next_ready_conv <= 1'b1;
end

always@(negedge clk)
begin
	if(reset)
	begin
		next_st_mp <= 1'b0;
		next_st_conv <= 1'b0;
		bram_toggle <= 1'b0;
	end
	else
	begin
		if(!conven && wraddr == OUTWIDTH)
		begin
			if(bram_num==2'd1 || bram_num==2'd3)
			begin
				next_st_mp <= 1'b1;
				bram_toggle <= ~bram_toggle;
			end
			if(next_ready_conv)
			begin
				next_st_conv <= 1'b1;
			end
			else
			begin
				next_st_mp <= 1'b0;
				next_st_conv <= 1'b0;
			end
		end
		else
		begin
			next_st_mp <= 1'b0;
			next_st_conv <= 1'b0;
		end
	end
end

reg [inBD*3-1:0] in_0a, in_0b, in_0c;
reg [inBD*3-1:0] in_1a, in_1b, in_1c;
reg [inBD*3-1:0] in_2a, in_2b, in_2c;

always@(posedge clk)
begin
	in_0a[inBD*3-1:inBD] <= in_0a[inBD*2-1:0];
	in_0b[inBD*3-1:inBD] <= in_0b[inBD*2-1:0];
	in_0c[inBD*3-1:inBD] <= in_0c[inBD*2-1:0];
	in_1a[inBD*3-1:inBD] <= in_1a[inBD*2-1:0];
	in_1b[inBD*3-1:inBD] <= in_1b[inBD*2-1:0];
	in_1c[inBD*3-1:inBD] <= in_1c[inBD*2-1:0];
	in_2a[inBD*3-1:inBD] <= in_2a[inBD*2-1:0];
	in_2b[inBD*3-1:inBD] <= in_2b[inBD*2-1:0];
	in_2c[inBD*3-1:inBD] <= in_2c[inBD*2-1:0];
	case(bram_num)
		2'd0:begin
			in_0a[inBD-1:0] <= d0[inBD*3-1:inBD*2];
			in_0b[inBD-1:0] <= d0[inBD*2-1:inBD*1];
			in_0c[inBD-1:0] <= d0[inBD*1-1:0];
			in_1a[inBD-1:0] <= d1[inBD*3-1:inBD*2];
			in_1b[inBD-1:0] <= d1[inBD*2-1:inBD*1];
			in_1c[inBD-1:0] <= d1[inBD*1-1:0];
			in_2a[inBD-1:0] <= d2[inBD*3-1:inBD*2];
			in_2b[inBD-1:0] <= d2[inBD*2-1:inBD*1];
			in_2c[inBD-1:0] <= d2[inBD*1-1:0];
		end
		2'd1:begin
			in_0a[inBD-1:0] <= d1[inBD*3-1:inBD*2];
			in_0b[inBD-1:0] <= d1[inBD*2-1:inBD*1];
			in_0c[inBD-1:0] <= d1[inBD*1-1:0];
			in_1a[inBD-1:0] <= d2[inBD*3-1:inBD*2];
			in_1b[inBD-1:0] <= d2[inBD*2-1:inBD*1];
			in_1c[inBD-1:0] <= d2[inBD*1-1:0];
			in_2a[inBD-1:0] <= d3[inBD*3-1:inBD*2];
			in_2b[inBD-1:0] <= d3[inBD*2-1:inBD*1];
			in_2c[inBD-1:0] <= d3[inBD*1-1:0];
		end
		2'd2:begin
			in_0a[inBD-1:0] <= d2[inBD*3-1:inBD*2];
			in_0b[inBD-1:0] <= d2[inBD*2-1:inBD*1];
			in_0c[inBD-1:0] <= d2[inBD*1-1:0];
			in_1a[inBD-1:0] <= d3[inBD*3-1:inBD*2];
			in_1b[inBD-1:0] <= d3[inBD*2-1:inBD*1];
			in_1c[inBD-1:0] <= d3[inBD*1-1:0];
			in_2a[inBD-1:0] <= d0[inBD*3-1:inBD*2];
			in_2b[inBD-1:0] <= d0[inBD*2-1:inBD*1];
			in_2c[inBD-1:0] <= d0[inBD*1-1:0];
		end
		2'd1:begin
			in_0a[inBD-1:0] <= d3[inBD*3-1:inBD*2];
			in_0b[inBD-1:0] <= d3[inBD*2-1:inBD*1];
			in_0c[inBD-1:0] <= d3[inBD*1-1:0];
			in_1a[inBD-1:0] <= d0[inBD*3-1:inBD*2];
			in_1b[inBD-1:0] <= d0[inBD*2-1:inBD*1];
			in_1c[inBD-1:0] <= d0[inBD*1-1:0];
			in_2a[inBD-1:0] <= d1[inBD*3-1:inBD*2];
			in_2b[inBD-1:0] <= d1[inBD*2-1:inBD*1];
			in_2c[inBD-1:0] <= d1[inBD*1-1:0];
		end
	endcase
end


wire [BD-1:0] r_aa, r_ba, r_ca, r_ab, r_bb, r_cb, r_ac, r_bc, r_cc;
cnn#(.BD(BD)) cnn_aa(
	.in0(in_0a[inBD*3-1:inBD*2]),
	.in1(in_0a[inBD*2-1:inBD*1]),
	.in2(in_0a[inBD*1-1:0]),
	.in3(in_1a[inBD*3-1:inBD*2]),
	.in4(in_1a[inBD*2-1:inBD*1]),
	.in5(in_1a[inBD*1-1:0]),
	.in6(in_2a[inBD*3-1:inBD*2]),
	.in7(in_2a[inBD*2-1:inBD*1]),
	.in8(in_2a[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_aa)
);
cnn#(.BD(BD)) cnn_ba(
	.in0(in_0a[inBD*3-1:inBD*2]),
	.in1(in_0a[inBD*2-1:inBD*1]),
	.in2(in_0a[inBD*1-1:0]),
	.in3(in_1a[inBD*3-1:inBD*2]),
	.in4(in_1a[inBD*2-1:inBD*1]),
	.in5(in_1a[inBD*1-1:0]),
	.in6(in_2a[inBD*3-1:inBD*2]),
	.in7(in_2a[inBD*2-1:inBD*1]),
	.in8(in_2a[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_ba)
);
cnn#(.BD(BD)) cnn_ca(
	.in0(in_0a[inBD*3-1:inBD*2]),
	.in1(in_0a[inBD*2-1:inBD*1]),
	.in2(in_0a[inBD*1-1:0]),
	.in3(in_1a[inBD*3-1:inBD*2]),
	.in4(in_1a[inBD*2-1:inBD*1]),
	.in5(in_1a[inBD*1-1:0]),
	.in6(in_2a[inBD*3-1:inBD*2]),
	.in7(in_2a[inBD*2-1:inBD*1]),
	.in8(in_2a[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_ca)
);
cnn#(.BD(BD)) cnn_ab(
	.in0(in_0b[inBD*3-1:inBD*2]),
	.in1(in_0b[inBD*2-1:inBD*1]),
	.in2(in_0b[inBD*1-1:0]),
	.in3(in_1a[inBD*3-1:inBD*2]),
	.in4(in_1b[inBD*2-1:inBD*1]),
	.in5(in_1b[inBD*1-1:0]),
	.in6(in_2b[inBD*3-1:inBD*2]),
	.in7(in_2b[inBD*2-1:inBD*1]),
	.in8(in_2b[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_ab)
);
cnn#(.BD(BD)) cnn_bb(
	.in0(in_0b[inBD*3-1:inBD*2]),
	.in1(in_0b[inBD*2-1:inBD*1]),
	.in2(in_0b[inBD*1-1:0]),
	.in3(in_1b[inBD*3-1:inBD*2]),
	.in4(in_1b[inBD*2-1:inBD*1]),
	.in5(in_1b[inBD*1-1:0]),
	.in6(in_2b[inBD*3-1:inBD*2]),
	.in7(in_2b[inBD*2-1:inBD*1]),
	.in8(in_2b[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_bb)
);
cnn#(.BD(BD)) cnn_cb(
	.in0(in_0b[inBD*3-1:inBD*2]),
	.in1(in_0b[inBD*2-1:inBD*1]),
	.in2(in_0b[inBD*1-1:0]),
	.in3(in_1b[inBD*3-1:inBD*2]),
	.in4(in_1b[inBD*2-1:inBD*1]),
	.in5(in_1b[inBD*1-1:0]),
	.in6(in_2b[inBD*3-1:inBD*2]),
	.in7(in_2b[inBD*2-1:inBD*1]),
	.in8(in_2b[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_cb)
);
cnn#(.BD(BD)) cnn_ac(
	.in0(in_0c[inBD*3-1:inBD*2]),
	.in1(in_0c[inBD*2-1:inBD*1]),
	.in2(in_0c[inBD*1-1:0]),
	.in3(in_1c[inBD*3-1:inBD*2]),
	.in4(in_1c[inBD*2-1:inBD*1]),
	.in5(in_1c[inBD*1-1:0]),
	.in6(in_2c[inBD*3-1:inBD*2]),
	.in7(in_2c[inBD*2-1:inBD*1]),
	.in8(in_2c[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_ac)
);
cnn#(.BD(BD)) cnn_bc(
	.in0(in_0c[inBD*3-1:inBD*2]),
	.in1(in_0c[inBD*2-1:inBD*1]),
	.in2(in_0c[inBD*1-1:0]),
	.in3(in_1c[inBD*3-1:inBD*2]),
	.in4(in_1c[inBD*2-1:inBD*1]),
	.in5(in_1c[inBD*1-1:0]),
	.in6(in_2c[inBD*3-1:inBD*2]),
	.in7(in_2c[inBD*2-1:inBD*1]),
	.in8(in_2c[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_bc)
);
cnn#(.BD(BD)) cnn_cc(
	.in0(in_0c[inBD*3-1:inBD*2]),
	.in1(in_0c[inBD*2-1:inBD*1]),
	.in2(in_0c[inBD*1-1:0]),
	.in3(in_1c[inBD*3-1:inBD*2]),
	.in4(in_1c[inBD*2-1:inBD*1]),
	.in5(in_1c[inBD*1-1:0]),
	.in6(in_2c[inBD*3-1:inBD*2]),
	.in7(in_2c[inBD*2-1:inBD*1]),
	.in8(in_2c[inBD*1-1:0]),
	.w0(18'd1),
	.w1(18'd1),
	.w2(18'd1),
	.w3(18'd1),
	.w4(18'd1),
	.w5(18'd1),
	.w6(18'd1),
	.w7(18'd1),
	.w8(18'd1),
	.result(r_cc)
);

wire [1:0] a,b,c;
wire bias_a = 18'd0;
wire bias_b = 18'd0;
wire bias_c = 18'd0;
paral_add4 add_a(
	.data0x		(r_aa),
	.data1x		(r_ba),
	.data2x		(r_ca),
	.data3x		(bias_a),
	.result		({a,qa})
);
paral_add4 add_b(
	.data0x		(r_ab),
	.data1x		(r_bb),
	.data2x		(r_cb),
	.data3x		(bias_b),
	.result		({b,qb})
);
paral_add4 add_c(
	.data0x		(r_ac),
	.data1x		(r_bc),
	.data2x		(r_cc),
	.data3x		(bias_c),
	.result		({c,qc})
);

//assign wren0 = (bram_num==2'd0)? wren : 1'b0;
//assign wren1 = (bram_num==2'd1)? wren : 1'b0;
//assign wren2 = (bram_num==2'd2)? wren : 1'b0;
//assign wren3 = (bram_num==2'd3)? wren : 1'b0;

endmodule
