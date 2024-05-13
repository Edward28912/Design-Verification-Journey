module fsm_cnt(
	input clk,
	input reset_n,
	input [3:0] limith,
	input [3:0] limitl,
	input [3:0] value,
	output reg dir
);

	parameter [1:0]	INCREMENT = 2'b01,
					DECREMENT = 2'b10;
					
	reg [1:0] state, next_state;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			state <= INCREMENT;

		else 
			state <= next_state;
	
	end

	always@(*) begin
	
		case(state)
		
			INCREMENT: begin
			
				if(value <= limitl)
					next_state = INCREMENT;
					
				else if(value >= limith)
					next_state = DECREMENT;
					
				else
					next_state = INCREMENT;
				
				dir = 1'b0;
			
			end
		
			DECREMENT: begin
			
				if(value <= limitl)
					next_state = INCREMENT;
					
				else if(value >= limith)
					next_state = DECREMENT;
					
				else 
					next_state = DECREMENT;
					
				dir = 1'b1;
			
			end
			
			default: next_state = INCREMENT;
			
		endcase
	
	end

endmodule
