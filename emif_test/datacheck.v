module datacheck(
	input clk, rst,
	input bt1,
	input amm_rddatavalid,
	input [19:0] cnt,
	
	input [319:0] amm_rddata,
	
	output reg [319:0] amm_wrdata,
	
	output reg check
);

parameter burstlength = 144;

reg [319:0] wr0, wr1, wr2, wr3, wr4, wr5, wr6, wr7;
always@(negedge clk)
begin
	if(rst)
	begin
		wr0 <= 320'd0579;
		wr1 <= 320'd1749;
		wr2 <= 320'd2164;
		wr3 <= 320'd3571;
		wr4 <= 320'd4962;
		wr5 <= 320'd5912;
		wr6 <= 320'd6751;
		wr7 <= 320'd7958;
	end
	else
	begin
		if(bt1)
		begin
		/*
		    case(cnt)
		    20'd1: amm_wrdata <= wr0;
		    20'd2: amm_wrdata <= wr1;
		    20'd3: amm_wrdata <= wr2;
		    20'd4: amm_wrdata <= wr3;
		    20'd5: amm_wrdata <= wr4;
		    20'd6: amm_wrdata <= wr5;
		    20'd7: amm_wrdata <= wr6;
		    20'd8: amm_wrdata <= wr7;
			 default: amm_wrdata <= 320'd0;
			 endcase
			 */
			 amm_wrdata <= amm_wrdata + 320'd100;
		end
		
		else
		begin
			amm_wrdata <= 320'd0;
		end
	end
end

reg [319:0] rd0, rd1, rd2, rd3, rd4, rd5, rd6, rd7;
always@(posedge clk)
begin
	if(rst)
	begin
		rd0 <= 320'd0;
		rd1 <= 320'd0;
		rd2 <= 320'd0;
		rd3 <= 320'd0;
		rd4 <= 320'd0;
		rd5 <= 320'd0;
		rd6 <= 320'd0;
		rd7 <= 320'd0;
	end
	
	else
	begin
		if(amm_rddatavalid)
		begin
			rd7 <= amm_rddata;
			rd6 <= rd7;
			rd5 <= rd6;
			rd4 <= rd5;
			rd3 <= rd4;
			rd2 <= rd3;
			rd1 <= rd2;
			rd0 <= rd1;
		end
		
		else
		begin
			rd0 <= rd0;
			rd1 <= rd1;
			rd2 <= rd2;
			rd3 <= rd3;
			rd4 <= rd4;
			rd5 <= rd5;
			rd6 <= rd6;
			rd7 <= rd7;
		end
	end
end

always@(posedge clk)
begin
	if(rst)
	begin
		check <= 1'b0;
	end
	
	else
	begin
		if(rd7 == wr7 && rd6 == wr6 && rd5 == wr5 && rd4 == wr4 && rd3 == wr3 && rd2 == wr2 && rd1 == wr1 && rd0 == wr0)
		check <= 1'b1;
	end
end

endmodule
