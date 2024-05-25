module chocolate(
	input clk,
	input reset_n,
	input euro,
	input cent,
	input ack,
	output [2:0] amount_out,
	output [6:0] state_out,
	output reg deliver
);

	parameter [6:0] IDLE		= 7'b0000001,
			ACC_CENT	= 7'b0000010,
			ACC_EURO	= 7'b0000100,
			VAL_CENT	= 7'b0001000,
			VAL_EURO	= 7'b0010000,
			CHOCO      	 = 7'b0100000,
			DELIVER    	 = 7'b1000000;
					
	reg [6:0] state, next_state;
	
	reg [2:0] amount;
	
	reg euro_d, cent_d;
	wire euro_p, cent_p;
	
	always@(posedge clk) begin
	
		euro_d <= euro;
		cent_d <= cent;
	
	end

	assign euro_p = ~euro & euro_d;
	assign cent_p = ~cent & cent_d;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			state <= IDLE;
			
		else
			state <= next_state;
	
	end

	assign state_out = state;

	always@(*) begin
	
		case(state)
		
			IDLE: begin
			
				deliver = 0;
			
				if(euro_p) 
					next_state = ACC_EURO;
					
				else if(cent_p)
					next_state = ACC_CENT;
					
				else
					next_state = state;
			
			end
		
			ACC_CENT: begin
			
				if(!cent_p)
					next_state = VAL_CENT;
					
				else
					next_state = state;
			
			end
		
			ACC_EURO: begin
			
				if(!euro_p)
					next_state = VAL_EURO;
					
				else
					next_state = state;
			
			end
		
			VAL_CENT: begin
			
				if(amount >= 5)
					next_state = CHOCO;
					
				else
					next_state = IDLE;
			
			end
		
			VAL_EURO: begin
			
				if(amount >= 5)
					next_state = CHOCO;
					
				else
					next_state = IDLE;
			
			end
		
			CHOCO: begin
			
				if(ack)
					next_state = DELIVER;
					
				else
					next_state = IDLE;
			
			end
		
			DELIVER: begin
			
				deliver = 1;
				next_state = IDLE;
			
			end
		
			default: next_state = IDLE;
		
		endcase
	
		if(amount >=5 && state == IDLE) begin
		
			if(ack)
				next_state = DELIVER;
		
		end
	
	end

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			amount <= 0;
			
		else if(state == ACC_EURO && !euro_p)
			amount <= amount + 2'd2;
			
		else if(state == ACC_CENT && !cent_p)
			amount <= amount + 1'd1;
			
		else if(state == DELIVER)
			amount <= amount - 3'd5;
			
		else
			amount <= amount;
	
	end

	assign amount_out = amount;

endmodule

`timescale 1ns / 1ps

module chocolate_tb();

	reg clk = 0;
	reg reset_n;
	reg euro;
	reg cent;
	reg ack;
	wire deliver;
	
	wire [6:0] state;
	wire [2:0] amount;
	
	chocolate DUT(
		.clk		(clk),
		.reset_n	(reset_n),
		.euro		(euro),
		.cent		(cent),
		.ack		(ack),
		.amount_out	(amount),
		.state_out	(state),
		.deliver	(deliver)
	);

	always begin #5 clk = ~clk; end
	
	initial begin
	
		reset_n = 0; euro = 0; cent = 0; ack = 0;
		
		#20; reset_n = 1;
		
		@(negedge clk); euro = 1;
		@(negedge clk); euro = 0;
		
		repeat(2) @(negedge clk); euro = 1;
				  @(negedge clk); euro = 0;
		
		repeat(2) @(negedge clk); cent = 1;
		          @(negedge clk); cent = 0;
		
		repeat(2) @(negedge clk); ack = 1;
		repeat(2) @(negedge clk); ack = 0;
		
		#30; $stop;
	
	end

endmodule
