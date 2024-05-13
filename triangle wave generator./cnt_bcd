module cnt_bcd(
	input clk,
	input reset_n,
	input cen,
	input dir,
	output reg [3:0] value
);

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			value <= 0;
			
		else if(cen) begin
		
			if(dir)
				value <= value - 1'b1;
				
			else 
				value <= value + 1'b1;
		
		end
	
	end

endmodule
