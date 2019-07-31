module ddr2bram(
input ddrclk,
input reset,
input rdbt,
input [319:0] RdData,
input readvalid,
input calend,

output reg rd,
output [24:0] addr,
output [6:0] burst,

output [23:0] bram_datain,
output [10:0] Bramaddr,
output wren0, wren1, wren2, wren3,
output reg next_st
);

reg rdst, rdst0, rdst2;
wire rdst1;
reg [4:0] Rdcnt;
reg [2:0] Valcnt;
reg [5:0] DDRHcnt;
reg [5:0] BramHcnt;
reg [10:0] Vcnt;
reg [10:0] BramVcnt;
reg [5:0] Bramcnt;
reg [959:0] RdBuf;
reg [319:0] RBuf, GBuf, BBuf;
reg wrreq;
reg [1:0] BufSel;


always@(posedge ddrclk)
begin
	if(reset)
		rdst <= 1'b0;
	else 
		rdst <= rdbt;
end

always@(posedge ddrclk)
begin
	if(reset)
		rdst0 <= 1'b0;
	else
		rdst0 <= rdst;
end

reg nextline0, nextline1;
always@(posedge ddrclk)
begin
	if(reset)
	begin
		nextline0 <= 1'b0;
		nextline1 <= 1'b0;
	end
		
	else
	begin
		nextline0 <= calend;
		nextline1 <= nextline0;
	end
end

assign rdst1 = rdst & ~rdst0;
assign nextline = nextline0 & ~nextline1;
reg wait_check, wait_nextline;
always@(posedge ddrclk)
begin
	if(reset)
		wait_nextline <= 1'b0;
	else
	begin
		if(nextline)
			wait_nextline <= 1'b1;
		else if(wait_check)
			wait_nextline <= 1'b0;
		else
			wait_nextline <= wait_nextline;
	end
end

always@(posedge ddrclk)
begin
	if(reset)
	begin
		wait_check <= 1'b0;
		rdst2 <= 1'b0;
	end
	else
	begin
		if(Vcnt <= 11'd3)
		begin
			if(Bramcnt == 6'd28)
				rdst2 <= 1'b1;
			else
				rdst2 <= 1'b0;
		end
		else
		begin
			if(DDRHcnt >= 6'd1 && Bramcnt == 6'd28)
				rdst2 <= 1'b1;
			else if(DDRHcnt == 6'd0 && wait_nextline)
			begin
				rdst2 <= 1'b1;
				wait_check <=1'b1;
			end
			else
			begin
				wait_check <= 1'b0;
				rdst2 <= 1'b0;
			end
		end
	end
end



always@(negedge ddrclk)
begin
	if(reset)
	begin
		Rdcnt <= 5'd0;
	end
	else
	begin
		if(rdst1 || rdst2)
		begin
			Rdcnt <= 5'd1;
		end
		else if(Rdcnt == 5'd18)
		begin
			Rdcnt <= 5'd0;
		end
		else if(Rdcnt > 5'd0)
		begin
			Rdcnt <= Rdcnt + 5'd1;
		end

		else
		begin
			Rdcnt <= 5'd0;
		end
	end
end

always@(negedge ddrclk)
begin
	if(reset)
		rd <= 1'b0;
	else
	begin
		if(rdst1 || rdst2)
			rd <= 1'b1;
		else
			rd <= 1'b0;
	end
end

always@(negedge ddrclk)
begin
	if(reset)
	begin
		RdBuf <= 960'd0;
		Valcnt <= 3'd0;
	end

	else
	begin
		if(readvalid)
		begin
			RdBuf[959:320] <= RdBuf[639:0];
			RdBuf[319:0] <= RdData;
			Valcnt <= Valcnt + 3'd1;
		end
		else
		begin
			RdBuf <= RdBuf;
			if(Valcnt == 3'd3)
				Valcnt <= 3'd0;
			else
				Valcnt <= Valcnt;
		end
	end
end

always@(negedge ddrclk)
begin
	if(reset)
	begin
		RBuf <= 320'd0;
		GBuf <= 320'd0;
		BBuf <= 320'd0;
	end

	else
	begin
		if(Valcnt == 3'd3 && Bramcnt == 6'd0)
		begin
			RBuf <= RdBuf[959:640];
			GBuf <= RdBuf[639:320];
			BBuf <= RdBuf[319:0];
		end
		else if (Bramcnt <= 6'd40 && Bramcnt >= 6'd1)
		begin
			RBuf[319:8] <= RBuf[311:0];
			GBuf[319:8] <= GBuf[311:0];
			BBuf[319:8] <= BBuf[311:0];
		end
		else
		begin
			RBuf <= RBuf;
			GBuf <= GBuf;
			BBuf <= BBuf;
		end
	end
end

always@(posedge ddrclk)
begin
	 if(reset)
	 begin
		  DDRHcnt <= 6'd0;
	 end
	 else
	 begin
		  if(Valcnt==3'd3)
		  begin
				if(DDRHcnt == 6'd47)
				begin
					 DDRHcnt <= 6'd0;
				end
				else
				begin
					 DDRHcnt <= DDRHcnt + 6'd1;
				end
		  end
		  else
		  begin
				DDRHcnt <= DDRHcnt;
		  end
	 end
end


always@(negedge ddrclk)
begin
	 if(reset)
	 begin
		  BramHcnt <= 6'd0;
	 end
	 else
	 begin
		  if(Bramcnt == 6'd41)
		  begin
				if(BramHcnt == 6'd47)
				begin
					 BramHcnt <= 6'd0;
				end
				else
				begin
					 BramHcnt <= BramHcnt + 6'd1;
				end
		  end

		  else
		  begin
				BramHcnt <= BramHcnt;
		  end
	 end
end

always@(posedge ddrclk)
begin
	 if(reset)
	 begin
		  Vcnt <= 11'd0;
	 end
	 else
	 begin
		  if(DDRHcnt == 6'd47 && Valcnt==3'd3)
		  begin
				if(Vcnt == 11'd1079)
				begin
					 Vcnt <= 11'd0;
				end
				else
				begin
					 Vcnt <= Vcnt + 11'd1;
				end
		  end
		  else
		  begin
				Vcnt <= Vcnt;
		  end
	 end
end


always@(posedge ddrclk)
begin
	 if(reset)
	 begin
		  BramVcnt <= 11'd0;
	 end
	 else
	 begin
		  if(BramHcnt == 6'd47 && Bramcnt == 6'd41)
		  begin
				if(BramVcnt == 11'd1079)
				begin
					 BramVcnt <= 11'd0;
				end
				else
				begin
					 BramVcnt <= BramVcnt + 11'd1;
				end
		  end
		  else
		  begin
				BramVcnt <= BramVcnt;
		  end
	 end
end





always@(negedge ddrclk)
begin
	if(reset)
	begin
		Bramcnt <= 6'd0;
		wrreq <= 1'b0;
	end
	else
	begin
		if(Valcnt == 3'd3)
		begin
			Bramcnt <= 6'd1;
			
		end

		else if(Bramcnt >= 6'd2 && Bramcnt <= 6'd40)
		begin
			Bramcnt <= Bramcnt + 6'd1;
			wrreq <= 1'b1;
		end
		
		else if(Bramcnt == 6'd1)
		begin
			Bramcnt <= 6'd2;
			wrreq <= 1'b1;
		end

		else
		begin
			Bramcnt <= 6'd0;
			wrreq <= 1'b0;
		end
	end
end

always@(negedge ddrclk)
begin
	 if(reset)
	 begin
		  BufSel <= 2'd0;
	 end
	 else
	 begin
		  if(BramHcnt == 6'd47 && Bramcnt == 6'd41)
		  begin
				BufSel <= BufSel + 2'd1;
		  end
		  else
		  begin
				BufSel <= BufSel;
		  end
	 end
end

assign addr = (rd)? Vcnt*144 +  DDRHcnt*3 : 25'hz;
assign burst = (rd)? 7'd3 : 7'hz;
assign Bramaddr = (wrreq)? BramHcnt*11'd40 + Bramcnt -11'd2 : 11'd0;
assign wren0 = (BufSel==2'd0)? wrreq : 1'b0;
assign wren1 = (BufSel==2'd1)? wrreq : 1'b0;
assign wren2 = (BufSel==2'd2)? wrreq : 1'b0;
assign wren3 = (BufSel==2'd3)? wrreq : 1'b0;

assign bram_datain = {RBuf[319:312],GBuf[319:312],BBuf[319:312]};

reg next;
always@(negedge ddrclk)
begin
	if(reset)
	begin
		next_st <= 1'b0;
		next <= 1'b0;
	end
	else
	begin
		if(BufSel==2'd2 && BramHcnt == 6'd47 && Bramcnt == 6'd41)
		begin
			next_st <= 1'b1;
			next <= 1'b1;
		end
		else if(next && BramHcnt == 6'd47 && Bramcnt == 6'd41)
		begin
			next_st <= 1'b1;
		end
		else
			next_st <= 1'b0;
	end
end




endmodule
