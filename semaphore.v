`timescale 1ns / 1ps

module semaphore_fsm(
	input clk,
	input enable,
	input reset_n,
	output reg red,
	output reg yellow,
	output reg green,
	output [3:0] state_out
);

	parameter [3:0]	OFF		= 4'b0001,
					RED 	= 4'b0010,
					YELLOW 	= 4'b0100,
					GREEN 	= 4'b1000;

	reg [3:0] state;
	reg [3:0] next_state;
	
	reg [5:0] timer;
	reg clear_timer;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			state <= OFF;
			
		else
			state <= next_state;
	
	end

	assign state_out = state;

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			timer <= 0;
			
		else if ((clear_timer == 1) || (!enable))
			timer <= 0;
			
		else if (state != OFF)
			timer <= timer + 1'b1;
		
	end


	always@(*) begin
	
		next_state = OFF;
		red = 0;
		yellow = 0;
		green = 0;
		clear_timer = 0;
	
		case(state)
		
			OFF: begin
			
				if(enable)
					next_state = RED;
			
			end
		
			RED: begin
			
				red = 1;
				
				if(timer == 6'd50) begin
				
					next_state = YELLOW;
					clear_timer = 1;
				
				end
				
				else	
					next_state = RED;
				
			end
		
			YELLOW: begin
			
				yellow = 1;
				
				if(timer == 6'd10) begin
				
					next_state = GREEN;
					clear_timer	= 1;
				
				end
			
				else
					next_state = YELLOW;
			
			end
		
			GREEN: begin
			
				green = 1;
				
				if(timer == 6'd30) begin
				
					next_state = RED;
					clear_timer = 1;
				
				end
				
				else
					next_state = GREEN;
			
			end
			
			default: next_state = OFF;
			
		endcase
	
	if(!enable) 
		next_state = OFF;

	
	end

endmodule

module semaphore_fsm_tb();

	parameter [3:0] OFF 	= 4'b0001,
					RED  	= 4'b0010,
					YELLOW 	= 4'b0100,
					GREEN 	= 4'b1000;
	
	reg clk = 0;
	reg reset_n;
	reg enable;
	wire red;
	wire yellow;
	wire green;
	wire [3:0] state_out;

semaphore_fsm DUT(
	.clk(clk),
	.reset_n(reset_n),
	.enable(enable),
	.red(red),
	.yellow(yellow),
	.green(green),
	.state_out(state_out)
);

	always begin #1 clk = ~clk; end
	
	initial begin
	
		$monitor($time, " enable = %b, red = %b, yellow = %b, green = %b", enable, red, yellow, green);
	
		reset_n = 0;
		
		#2.5; reset_n = 1; enable = 0;
		
		repeat(10) @(posedge clk); enable = 1;
		
		repeat(2) begin
		
			wait (state_out === GREEN);
			@(state_out);
		
		end
		
		wait (state_out === YELLOW);
		@(posedge clk); enable = 0;
		
		repeat(10) @(posedge clk); 
		@(posedge clk); enable = 1;
		
		#40 $stop;
	
	end

endmodule