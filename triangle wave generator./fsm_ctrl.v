module fsm_ctrl(
	input clk,
	input reset_n,
	input push,
	input [3:0] din, 
	output reg [3:0] limith,
	output reg [3:0] limitl
);

	reg [2:0] SET_LIMITL = 3'b001,
			  SET_LIMITH = 3'b010,
			  DONE		 = 3'b100;
			  
	reg [2:0] state, next_state;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
		
			state <= SET_LIMITL;
		
		end
	
		else
			state <= next_state;
	
	end

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
		
			limitl <= 0;
			limith <= 9;
		
		end
			
		else begin
		
			if(state == SET_LIMITL)
				limitl <= din;
				
			else if (state == SET_LIMITH)
				limith <= din;
				
			else begin
			
				limitl <= limitl;
				limith <= limith;
			
			end
		
		end
	
	end

	always@(*) begin
	
		case(state)
		
			SET_LIMITL: begin
			
				if(push) 
					next_state = SET_LIMITH;
			
				else
					next_state = SET_LIMITL;
			
			end
		
			SET_LIMITH: begin
			
				if(push)				
					next_state = DONE;
			
				else
					next_state = SET_LIMITH;
			
			end
		
			DONE: begin
			
				if(!reset_n)
					next_state = SET_LIMITL;
			
			end
		
			default: next_state = SET_LIMITL;
		
		endcase
	
	end

endmodule
