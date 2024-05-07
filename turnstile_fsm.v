module turnstile_fsm(
	input clk,
	input reset_n,
	input validate_code,
	input [3:0] access_code,
	output reg open_access_door,
	output [1:0] state_out
);

	parameter IDLE = 2'b00;
	parameter CHECK_CODE = 2'b01;
	parameter ACCESS_GRANTED = 2'b10;
	
	reg [1:0] state;		// SEQUENTIAL LOGIC
	reg [1:0] next_state;	// COMBINATIONAL LOGIC
	
	reg [3:0] timer;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) 
			state <= IDLE;
			
		else
			state <= next_state;
		
	end

	assign state_out = state;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			timer <= 0;
		
		else if( state == ACCESS_GRANTED )
			timer <= timer + 1'b1;
			
		else	
			timer <= 0;
	
	end

	always@(*) begin
	
		next_state = IDLE;
		open_access_door = 0;
		
		case(state) 
		
			IDLE: begin
			
				if(validate_code) 
					next_state = CHECK_CODE;
			
			end
				
			CHECK_CODE: begin
			
				if((access_code >= 4'd4) && (access_code <= 4'd11))
					next_state = ACCESS_GRANTED;
			
			end
		
			ACCESS_GRANTED: begin
			
				open_access_door = 1;
			
				if(timer == 4'hF)
					next_state = IDLE;
				
				else
					next_state = ACCESS_GRANTED;
			
			end
		
			default: next_state = IDLE;
		
		endcase
	
	end

endmodule

module turnstile_fsm_tb();

	reg clk = 0;
	reg reset_n;
	reg [3:0] access_code;
	reg validate_code; 
	wire open_access_door;
	wire [1:0] state_out;
	
turnstile_fsm FSM(
	.clk(clk),
	.reset_n(reset_n),
	.access_code(access_code),
	.validate_code(validate_code),
	.open_access_door(open_access_door),
	.state_out(state_out)
);
	
	always begin #1 clk = ~clk; end
	
	initial begin
	
		$monitor($time, " access_code = %4b, state_out = %2b, open_access_door = %b", access_code, state_out, open_access_door);
		
		reset_n = 0;
		
		#2.5 reset_n = 1; validate_code = 0; access_code = 0;
		
		@(posedge clk); validate_code = 1; access_code = 0;
		
		@(posedge clk); validate_code = 1; access_code = 0;
		
		@(posedge clk); validate_code = 1; access_code = 9;
		
		@(posedge clk); validate_code = 0; access_code = 9;
		
		#40 $stop;
		
	end

endmodule