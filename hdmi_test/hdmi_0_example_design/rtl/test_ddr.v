module test_ddr(
	input emif_usr_clk,
	input rst,
	input bt1, bt2,
	input amm_ready,
	output reg amm_rd, amm_wr,
	output reg [24:0] amm_addr,
	output reg [6:0] amm_burstcnt
);

parameter burstlength = 6;

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
				amm_addr <= 25'd155196;
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
				amm_addr <= 25'd155196 + burstlength;
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
				amm_addr <= 25'd155196;
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
				amm_addr <= 25'd155196 + burstlength;	
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