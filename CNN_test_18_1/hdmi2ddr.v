module hdmi2ddr(
input hdmiclk, ddrclk,
input reset,
input [1:0] DE, HS, VS,
input [95:0] RxData,
input wrbt,

output wr,
output [319:0] WrData,
output [24:0] addr,
output [6:0] burst
);




reg [1:0] ready;
reg wren;
reg [5:0] Hcnt;
reg [10:0] Vcnt;
reg [4:0] Rxcnt;
reg [2:0] Wrcnt;
reg [319:0] RxBufR, RxBufG, RxBufB;
reg [959:0] RxBuf;

always@(posedge hdmiclk or posedge reset)
begin
	if(reset)
		ready <= 2'b00;
	else if(wrbt)
	begin
		if(ready == 2'd0 && VS[1]==1'b1)
			ready <= 2'b01;
		else if(ready == 2'b01 && Vcnt == 11'd1080)
			ready <= 2'b11;
	end
	else
	begin	
		if(ready == 2'b11)
			ready <= 2'd0;
		else if(ready == 2'b01 && Vcnt == 11'd1080)
			ready <= 2'b00;
		else
			ready <= ready;
	end
end

always@(posedge hdmiclk or posedge reset)
begin
	if(reset)
	begin
		Rxcnt <= 5'd0;
	end

	else
	begin
		if(ready == 2'b01)
		begin
			if(DE[1])
			begin
				if(Rxcnt == 5'd19)
				begin
					Rxcnt <= 5'd0;
				end

				else
				begin
					Rxcnt <= Rxcnt + 5'd1;
				end

			end

			else
			begin
				Rxcnt <= 5'd0;
			end
		end
		else
		begin
			Rxcnt <= 5'd0;
		end
	end
end

always@(posedge hdmiclk or posedge reset)
begin
	if(reset)
	begin
		Hcnt <= 6'd0;
	end

	else
	begin
		if(ready == 2'b01)
		begin
			if(DE[1])
			begin
				if(Rxcnt == 6'd19)
				begin
					Hcnt <= Hcnt + 6'd1;
				end
				
				else 
				begin
					Hcnt <= Hcnt;
				end
			end

			else
			begin
				if(!wr)
				begin
					Hcnt <= 6'd0;
				end
				else
				begin
					Hcnt <= Hcnt;
				end			
			end
		end
		else
		begin
			Hcnt <= 6'd0;
		end
	end
end

always@(posedge DE[1] or posedge VS[1] or posedge reset)
begin
	if(reset)
	begin
		Vcnt <= 11'd0;
	end
	else
	begin
		if(VS[1])
		begin
			Vcnt <= 11'd0;
		end

		else
		begin
			Vcnt <= Vcnt + 11'd1;
		end
	end
end

always@(negedge hdmiclk or posedge reset)
begin
	if(reset)
	begin
		RxBufR <= 320'd0;
		RxBufG <= 320'd0;
		RxBufB <= 320'd0;
	end

	else
	begin
		if(DE[1] || DE[0])
		begin
			RxBufR[319:16] <= RxBufR[303:0];
			RxBufG[319:16] <= RxBufG[303:0];
			RxBufB[319:16] <= RxBufB[303:0];
					
			RxBufR[15:0] <= {RxData[47:40], RxData[95:88]};
			RxBufG[15:0] <= {RxData[31:24], RxData[79:72]};
			RxBufB[15:0] <= {RxData[15:8],  RxData[63:56]};
		end
		else
		begin
			RxBufR <= RxBufR;
			RxBufG <= RxBufG;
			RxBufB <= RxBufB;
		end
	end
end

always@(posedge hdmiclk or posedge reset)
begin
	if(reset)
	begin
		RxBuf <= 960'd0;
	end
	else
	begin
		if(Rxcnt == 5'd19)
		begin
			RxBuf <= {RxBufR, RxBufG, RxBufB};
		end
		else
		begin
			RxBuf <= RxBuf;
		end
	end
end

reg wren_pre;
reg [3:0] wrencnt;
always@(posedge ddrclk or posedge reset)
begin
	if(reset)
	begin
		wren <= 1'b0;
		wren_pre <= 1'b0;
		wrencnt <= 4'd0;
	end
	else
	begin
		if(Rxcnt == 5'd19)
		begin
			wren_pre <= 1'b1;
		end
		
		else if(wren)
		begin
			case(wrencnt)
			4'd0: wrencnt<=4'd1;
			4'd1: wrencnt<=4'd2;
			4'd2: wrencnt<=4'd3;
			4'd3: begin
				wrencnt<=4'd0;
				wren <= 1'b0;
				wren_pre <= 1'b0;
			end
			endcase					
		end
		
		else if(wren_pre && Rxcnt == 5'd0)
		begin
			wren <= 1'b1;
		end
		
						
	end
end

always@(negedge ddrclk or posedge reset)
begin
	if(reset)
	begin
		Wrcnt <= 3'd0;
	end
	else
	begin
		if(wren)
		begin
			if(Wrcnt == 3'd4)
			begin
				Wrcnt <= 3'd0;
			end
			else
			begin
				Wrcnt <= Wrcnt + 3'd1;
			end
		end
		else
		begin
			Wrcnt <= 3'd0;
		end
	end
end


assign wr = (Wrcnt==3'd1 || Wrcnt==3'd2 || Wrcnt==3'd3)? 1'b1 : 1'b0;
assign WrData = (Wrcnt==3'd1)? RxBuf[959:640] : (Wrcnt==3'd2)? RxBuf[639:320] : (Wrcnt==3'd3)? RxBuf[319:0] : 320'd0;
assign addr = (Wrcnt==3'd1)? (Vcnt-1)*144 + (Hcnt-1)*3 : 25'hz;
assign burst = (Wrcnt==3'd1)? 7'd3 : 7'hz;



endmodule

