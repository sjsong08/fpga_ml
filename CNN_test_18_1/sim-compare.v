module compare#(
	parameter BD = 18)(

	input clk, reset,
	input mpen, wincnt,
	input [BD-1:0] q0, q1,
	output reg [BD-1:0] d
);

always@(negedge clk)
begin
	if(reset)
	begin
		d <= 0;
	end
	else
	begin
		if(mpen && !wincnt)
		begin
			if(q0[BD-1]==1'b0 && q1[BD-1]==0)
			begin
				if(q0 >= q1)
					d <= q0;
				else
					d <= q1;
			end
			else if(q0[BD-1]==1'b0 && q1[BD-1]==1'b1)
			begin
				d <= q0;
			end

			else if(q0[BD-1]==1'b1 && q1[BD-1]==1'b0)
			begin
				d <= q1;
			end

			else
			begin
				if(~q0 + 1'b1 >= ~q1 + 1'b1)
					d <= q1;
				else
					d <= q0;
			end
				
		end
		else if(mpen && wincnt)
		begin

			if(d[BD-1]==1'b0)
			begin
				if(q0[BD-1]==1'b1 && q1[BD-1]==1'b1)
					d <= d;
				else if(q0[BD-1]==1'b0 && q1[BD-1]==1'b1)
				begin
					if(d >= q0)
						d <= d;
					else
						d <= q0;
				end
				else if(q0[BD-1]==1'b1 && q1[BD-1]==1'b0)
				begin
					if(d >= q1)
						d <= d;
					else
						d <= q1;
				end

				else
				begin
					if(d >= q0 && d >= q1)
					begin
						d <= d;
					end
					else if(d < q0 && q1 < q0)
					begin
						d <= q0;
					end
					else
					begin
						d <= q1;
					end
				end
			end
			else
			begin
				if(q0[BD-1]==1'b0 && q1[BD-1]==1'b1)
					d <= q0;
				else if(q0[BD-1]==1'b1 && q1[BD-1]==1'b0)
					d <= q1;
				else if(q0[BD-1]==1'b0 && q1[BD-1]==1'b0)
				begin
					if(q0 >= q1)
						d <= q0;
					else
						d <= q1;
				end
				else
				begin
					if(~d+1'b1 < ~q0+1'b1 && ~d+1'b1 < ~q1+1'b1)
					begin
						d <= d;
					end
					else if(~d+1'b1 >= ~q0+1'b1 && ~q1+1'b1 >= ~q0+1'b1)
					begin
						d <= q0;
					end
					else
					begin
						d <= q1;
					end
				end

			end

		end
		else
		begin
			d <= 0;
		end
	end
end

endmodule
