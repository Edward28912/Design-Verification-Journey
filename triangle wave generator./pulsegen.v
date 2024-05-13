module pulsegen(
	input clk,
	input reset_n,
	output reg pulse
);

	localparam CYCLE = 5;

	reg [2:0] timer;
	reg clear_timer;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
		
			timer <= 0;
			clear_timer <= 0;
			
		end
		
		else if (clear_timer) begin
		
			timer <= 0;
			clear_timer <= 0;
			
		end
			
		else 
			timer <= timer + 1'b1;
		
	end

	assign pulse = (timer == CYCLE);
	assign clear_timer = (timer == CYCLE);

endmodule
