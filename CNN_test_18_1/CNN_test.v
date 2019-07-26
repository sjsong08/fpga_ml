module CNN_test(
	input clk,
	
	output resulta

);

parameter BD = 18;


wire [23:0] in0_q, in1_q, in2_q, in3_q;
wire in0_rden, in1_rden, in2_rden, in3_rden;
wire [20:0] conv1_qa, conv1_qb, conv1_qc;

wire fin_rd, de_out1;
wire [10:0] rd_addr;
wire conv1_str_wr;


conv_layer conv1(
	.clk		(clk),
	.RESET		(rst),
	.start_rd	(start_rd),
	.in0_q		(in0_q),	
	.in1_q		(in1_q),	
	.in2_q		(in2_q),	
	.in3_q		(in3_q),
	
	.in0_rden	(in0_rden),
	.in1_rden	(in1_rden),
	.in2_rden	(in2_rden),
	.in3_rden 	(in3_rden),
	.in_addr	(rd_addr),

	.start_wr	(conv1_str_wr),
	.result_0	(conv1_qa),
	.result_1	(conv1_qb),	
	.result_2	(conv1_qc),
	.fin_rd		(fin_rd),
	.de_out		(de_out1)
);

wire de_out2;
wire [20:0]	br1_qa_0;
wire [20:0]   	br1_qa_1;
wire [20:0]   	br1_qa_2;
wire [20:0]   	br1_qa_3;
wire [20:0]  	br1_qb_0;
wire [20:0]  	br1_qb_1;
wire [20:0]  	br1_qb_2;
wire [20:0]	br1_qb_3;
wire [20:0]   	br1_qc_0;
wire [20:0]  	br1_qc_1;
wire [20:0]  	br1_qc_2;
wire [20:0]   	br1_qc_3;

wire br1_fin;
mid_bram mid_bram1(
	.clk		(clk),
	.RESET		(rst),

	.start_wr	(conv1_str_wr),
	.in_a		(conv1_qa),
	.in_b		(conv1_qb),
	.in_c		(conv1_qc),
	.de_in		(de_out1),

	.fin_rd		(br1_fin),
	.in0_rden	(mp0_en),
	.in1_rden	(mp0_en),
	.in2_rden	(mp0_en),
	.in3_rden	(mp0_en),
	.rd_addr	(mp0_rd_addr),

	.de_out		(de_out2),
	.qa_0		(br1_qa_0),	
	.qa_1		(br1_qa_1),	
	.qa_2		(br1_qa_2),	
	.qa_3		(br1_qa_3),	
	.qb_0		(br1_qb_0),	
	.qb_1		(br1_qb_1),	
	.qb_2		(br1_qb_2),	
	.qb_3		(br1_qb_3),	
	.qc_0		(br1_qc_0),	
	.qc_1		(br1_qc_1),	
	.qc_2		(br1_qc_2),	
	.qc_3		(br1_qc_3),

	.bram_toggle	(bram_toggle)
	
);

wire [20:0] d0_ca = (bram_toggle) ? br1_qa_2 : br1_qa_0;
wire [20:0] d1_ca = (bram_toggle) ? br1_qa_3 : br1_qa_1;
wire [20:0] d0_cb = (bram_toggle) ? br1_qb_2 : br1_qb_0;
wire [20:0] d1_cb = (bram_toggle) ? br1_qb_2 : br1_qb_1;
wire [20:0] d0_cc = (bram_toggle) ? br1_qc_2 : br1_qc_0;
wire [20:0] d1_cc = (bram_toggle) ? br1_qc_2 : br1_qc_1;

wire mp0_en;
wire [10:0] mp0_rd_addr;
wire [10:0] mp0_wr_addr;
wire mp0_wren;
wire [1:0] mp0_bramcnt;
wire [BD-1:0] mp0_d_a, mp0_d_b, mp0_d_c;
wire mp0_next_st;
/*
maxPool #(.BD(BD)) maxPool1(
	.clk		(clk),
	.reset		(reset),
	.ready_in	(br1_fin),
	.q0_c0		(d0_ca),
	.q1_c0		(d1_ca),
	.q0_c1		(d0_cb),
	.q1_c1		(d1_cb),
	.q0_c2		(d0_cc),
	.q1_c2		(d1_cc),

	.mpen		(mp0_en),
	.rdaddr		(mp0_rd_addr),

	.wren		(mp0_wren),
	.wraddr		(mp0_wr_addr),
	.d_c0		(mp0_d_a),
	.d_c1		(mp0_d_b),
	.d_c2		(mp0_d_c),

	.bram_num	(mp0_bramcnt),
	.next_st	(mp0_next_st)
);

wire mp0_wren0 = (mp0_bramcnt==2'd0) ? mp0_wren : 1'hz;
wire mp0_wren1 = (mp0_bramcnt==2'd1) ? mp0_wren : 1'hz;
wire mp0_wren2 = (mp0_bramcnt==2'd2) ? mp0_wren : 1'hz;
wire mp0_wren3 = (mp0_bramcnt==2'd3) ? mp0_wren : 1'hz;

wire [BD-1:0] a,b,c,d,e,f,g,h,i,j,k,l;

brams_mp0_conv1 #(.BD(BD)) brams_mp0_conv1(
	.clk		(clk),
	.reset		(rst),
	.wren0		(mp0_wren0),
	.wren1		(mp0_wren1),
	.wren2		(mp0_wren2),
	.wren3		(mp0_wren3),
	.wraddr		(mp0_wr_addr),
	.d_a		(mp0_d_a),
	.d_b		(mp0_d_b),
	.d_c		(mp0_d_c),
	.q0_a		(a),
	.q0_b		(b),	
	.q0_c		(c),
	.q1_a		(d),
	.q1_b		(e),
	.q1_c		(f),
	.q2_a		(g),
	.q2_b		(h),
	.q2_c		(i),
	.q3_a		(j),
	.q3_b		(k),
	.q3_c		(l)
);
*/
endmodule
