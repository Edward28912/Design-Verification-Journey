`timescale 1ns / 1ps

module FSM_chocolate_machine(
	input clk,
	input cents,
	input euro,
	input ack,
	input reset_n,
	output reg deliver
);

	localparam STATE_0 = 3'd0;
	localparam STATE_0_5 = 3'd1;
	localparam STATE_1 = 3'd2;
	localparam STATE_1_5 = 3'd3;
	localparam STATE_2 = 3'd4;
	localparam STATE_2_5 = 3'd5;
	localparam STATE_DELIVER = 3'd6;
	
	reg [2:0] state;
	
	reg cents_d;
	reg cents_p;
	
	reg euro_d;
	reg euro_p;
	
	real amount; 
	
	always@(posedge clk) begin
	
		euro_d <= euro;
		cents_d <= cents;
	
	end

	assign cents_p = cents_d & ~cents;
	assign euro_p = euro_d & ~euro;

	always@(posedge clk, negedge reset_n) begin
	
		if (!reset_n) begin
		
			state <= STATE_0;
			deliver <= 0;
			amount <= 0;
		
		end
	
		else begin
		
			case(state)
			
				STATE_0: begin

          deliver <= 0;
          
					if(cents_p) begin
					
						state <= STATE_0_5;
						amount <= amount + 0.5;
					
					end
					
					else if (euro_p) begin
					
						state <= STATE_1;
						amount <= amount + 1;
					
					end
					
				end
			
				STATE_0_5: begin

          deliver <= 0;
          
					if(cents_p) begin
					
						state <= STATE_1;
						amount <= amount + 0.5;
					
					end
				
					else if(euro_p) begin
					
						state <= STATE_1_5;
						amount <= amount + 1;
					
					end
				
				end
			
				STATE_1: begin
				
					if(cents_p) begin
					
						state <= STATE_1_5;
						amount <= amount + 0.5;
					
					end
				
					else if (euro_p) begin
					
						state <= STATE_2;
						amount <= amount + 1;
					
					end
				
				end
			
				STATE_1_5: begin
				
					if (cents_p) begin
					
						state <= STATE_2;
						amount <= amount + 0.5;
					
					end
				
					else if (euro_p) begin
					
						state <= STATE_2_5;
						amount <= amount + 1;
						
					end
				
				end
			
				STATE_2: begin
				
					if (cents_p) begin
					
						state <= STATE_2_5;
						amount <= amount + 0.5;
					
					end
				
					else if (euro_p) begin
					
						state <= STATE_DELIVER;
						amount <= amount + 1;
					
					end
				
				end
			
				STATE_2_5: begin
				
					if (cents_p) begin
					
						state <= STATE_DELIVER;
						amount <= amount + 0.5;
					
					end
				
          else if (euro_p) begin
					
						state <= STATE_DELIVER;
						amount <= amount + 1;
					
					end
				
				end
			
				STATE_DELIVER: begin
				
					if (ack) begin
					
						amount <= amount - 2.5;
						deliver <= 1;
						state <= (amount == 0.5) ? STATE_0_5 : STATE_0;
					
					end
				
					else
						state <= STATE_DELIVER;
				
				end
			
				default: begin
				
					state <= STATE_0;
					amount <= 0;
					deliver <= 0;
				
				end
			
			endcase
		
		end
	
	end

endmodule

module FSM_chocolate_machine_tb();

	reg clk = 0;
	reg cents;
	reg euro;
	reg reset_n;
	reg ack;
	wire deliver;

  FSM_chocolate_machine DUT (
	.clk(clk),
	.cents(cents),
	.euro(euro),
	.reset_n(reset_n),
	.ack(ack),
	.deliver(deliver)
);

  always begin #10 clk = ~clk; end

	initial begin
	
		reset_n = 1;
		
		@(negedge clk); reset_n = 0;

    @(negedge clk); reset_n = 1;
		
		@(negedge clk); cents = 1;
		
		@(negedge clk);	cents = 0;
		
		@(negedge clk); euro = 1;
		
		@(negedge clk); euro  = 0;

		@(negedge clk); euro = 1;

		@(negedge clk); euro = 0;

		@(negedge clk); cents = 1;

		@(negedge clk); cents = 0;

		@(negedge clk); ack = 1;

		@(negedge clk); ack = 0;
		
		#150 $stop;

	end

endmodule
