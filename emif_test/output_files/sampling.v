module sampling(
	input clk,
	input rst,
	input [319:0] reg0,
	input reg1,
	input reg2,
	output  reg [319:0] sampled0,
	output reg sampled1,
	output reg sampled2,
	output reg led1, led2
);



always@(clk)
begin
	if(rst)
	begin
		sampled0 <= 320'd0;
		sampled1	<= 1'b0;
		sampled2 <= 1'b0;
		
	end
	else
	begin
		sampled0 <= reg0;
		sampled1 <= reg1;
		sampled2 <= reg2;
	end
end

always@(posedge clk)
begin
	if(sampled0==320'd100)
		led2 <= 1'b1;
end


always@(posedge clk)
begin
	if(sampled1==1'd1)
		led1 <= 1'b1;
end

endmodule