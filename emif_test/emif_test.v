module emif_test(
			input clk50m,
			input clk100m,
			input refclk_emif_p,
			input RESET,

			//LED PB DIPSW
			output  [3:0]   user_led           , // User GPIO, LED
			input   [2:0]   user_pb            , // User GPIO, push buttons
			input   [3:0]   user_dip           , // User GPIO, DIPSWs

			//EMIF interface
			output          ddr3_ckp           , // CKp
			output          ddr3_ckn           , // CKn
			inout   [39:0]  ddr3_d             , // Data
			output  [4:0]   ddr3_dm            , // DM
			inout   [4:0]   ddr3_dqsn          , // DQSn
			inout   [4:0]   ddr3_dqsp          , // DQSp
			output  [2:0]   ddr3_ba            , // BA
			output          ddr3_casn          , // CASn
			output          ddr3_rasn          , // RASn
			output  [14:0]  ddr3_a             , // ADDR
			output  [0:0]   ddr3_cke           , // CKe
			output  [0:0]   ddr3_odt           , // ODT
			output  [0:0]   ddr3_csn           , // CSn
			output          ddr3_wen           , // WEn
			output          ddr3_rstn          , // RESETn
			input           ddr3_rzq             // RZQ
);

parameter burstlength = 6;

wire rst;


wire local_cal_success, local_cal_fail;
wire emif_usr_reset_n, emif_usr_clk;
wire amm_ready;
wire [319:0] amm_rddata;
wire amm_rddatavalild;

reg amm_rd, amm_wr;
reg [24:0] amm_addr;
//reg [319:0] amm_wrdata;
wire [319:0] amm_wrdata;// = {40{8'b0011_1111}};
reg [6:0] amm_burstcnt;
wire [39:0] amm_byteenable;
assign amm_byteenable = 40'hff_ffff_ffff;



emif emif01(
			.global_reset_n		(!rst), 	//in
			.pll_ref_clk			(refclk_emif_p),	//in
			.oct_rzqin				(ddr3_rzq),	//in
			
			.mem_ck					(ddr3_ckp),	//out
			.mem_ck_n				(ddr3_ckn),	//out
			.mem_a					(ddr3_a),	//out
			.mem_ba					(ddr3_ba),	//out
			.mem_cke					(ddr3_cke),	//out
			.mem_cs_n				(ddr3_csn),	//out
			.mem_odt					(ddr3_odt),	//out
			.mem_reset_n			(ddr3_rstn),	//out
			.mem_we_n				(ddr3_wen),	//out
			.mem_ras_n				(ddr3_rasn),	//out
			.mem_cas_n				(ddr3_casn),	//out
			.mem_dqs					(ddr3_dqsp),	//inout
			.mem_dqs_n				(ddr3_dqsn),	//inout
			.mem_dq					(ddr3_d),	//inout
			.mem_dm					(ddr3_dm),	//out
			.local_cal_success	(local_cal_success),	//out
			.local_cal_fail		(local_cal_fail),	//out
			
			
			.emif_usr_reset_n		(emif_usr_reset_n),	//out
			.emif_usr_clk			(emif_usr_clk),		//out
			.amm_ready_0			(amm_ready),	//out
			
			.amm_readdata_0		(amm_rddata),	//out
			.amm_readdatavalid_0	(amm_rddatavalid),	//out

			.amm_read_0				(amm_rd),	//in
			.amm_write_0			(amm_wr),	//in
			.amm_address_0			(amm_addr),	//in
			.amm_writedata_0		(amm_wrdata),	//in
			.amm_burstcount_0		(amm_burstcnt),	//in
			.amm_byteenable_0		(amm_byteenable)	//in
);




wire bt1, bt2;
issp		issp01(
			.source		({rst, bt1, bt2}), //2..0
			.probe		({amm_ready, amm_wr, amm_rd, amm_rddatavalid, emif_usr_reset_n, amm_rddata, amm_burstcnt, cnt})	//323..0
);


datacheck dtck01(
			.clk			(emif_usr_clk),
			.rst			(rst),
			.bt1			(bt1),
			.amm_rddatavalid	(amm_rddatavalid),
			.amm_rddata			(amm_rddata),
			.cnt					(cnt),
			
			.amm_wrdata			(amm_wrdata),
			.check				(user_led[0])
);



reg [19:0] cnt;
always@(negedge emif_usr_clk)
begin
	if(rst)
	begin
		cnt <= 20'd0;
	end
	
	else
	begin		
		
		if(bt1)
		begin
			if(amm_ready)
			begin
				if(cnt==20'd1000)
				begin
					cnt <= 20'd1001;
				end
				
				else if(cnt <= 20'd1000)
				begin
					cnt <= cnt + 20'd1;
				end
				
				else
					cnt <= cnt;
			end
		end


		else if(bt2)
		begin
			if(cnt==20'd1000)
			begin
				cnt <= 20'd1001;
			end
			
			else if(cnt <= 20'd1000)
			begin
				cnt <= cnt + 20'd1;
			end
			else
				cnt <= cnt;
		end
		
		else
		begin
			cnt <= 20'd0;
		end
	end
	
end

always@(negedge emif_usr_clk)
begin
	if(rst)
	begin
		amm_wr <= 1'b0;
		amm_rd <= 1'b0;
		amm_addr <= 25'b00000_00000_00100_00000_00000;
	end
	else
	begin
		if(bt1)
		begin
			if(cnt == 20'd1)
			begin
				amm_wr <= 1'b1;
				amm_addr <= 25'd155208;
				amm_burstcnt <= burstlength;
			end
			
			else if(cnt == 20'd2)
			begin
				amm_wr <= 1'b1;
				amm_addr <= 25'hz;
				amm_burstcnt <= 7'hz;
			end
				
			else if(cnt == burstlength+20'd1)
			begin
				amm_wr <= 1'b0;
				amm_addr <= 25'd0;
			end
			
			
			
			else if(cnt == burstlength+20'd2)
			begin
				amm_wr <= 1'b1;
				amm_addr <= 25'd155208 + burstlength;
				amm_burstcnt <= burstlength;
			end
			else if(cnt == burstlength+20'd3)
			begin
				amm_wr <= 1'b1;
				amm_addr <= 25'hz;
				amm_burstcnt <= 7'hz;
			end
			else if(cnt == burstlength*2+20'd2)
			begin
				amm_wr <= 1'b0;
				amm_addr <= 25'd0;
			end
			
			else
			begin
				amm_wr <= amm_wr;
				amm_addr <= amm_addr;
				amm_burstcnt <= amm_burstcnt;
			end
			
		end
		
		else if(bt2)
		begin
			if(cnt == 20'd1)
			begin
				amm_rd <= 1'b1;
				amm_addr <= 25'd155208;
				amm_burstcnt <= burstlength;
			end
			
			else if(cnt == 20'd2)
			begin
				amm_rd <= 1'b0;
				amm_addr <= 25'hz;
				amm_burstcnt <= 7'hz;
			end
			
			else if(cnt == 20'd11)
			begin
				amm_rd <= 1'b1;
				amm_addr <= 25'd155208 + burstlength;	
				amm_burstcnt <= burstlength;
			end
			
			else if(cnt == 20'd12)
			begin
				amm_rd <= 1'b0;
				amm_addr <= 25'hz;
				amm_burstcnt <= 7'hz;
			end
			
			else
			begin
				amm_rd <= amm_rd;
				amm_addr <= amm_addr;
				amm_burstcnt <= amm_burstcnt;
			end
		end
		
		else
		begin
			amm_wr <= amm_wr;
			amm_rd <= amm_rd;
			amm_addr <= amm_addr;
			amm_burstcnt <= amm_burstcnt;
		end
	end
end




endmodule
