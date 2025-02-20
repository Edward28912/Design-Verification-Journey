`timescale 1ns / 1ps

module seq_detection(
	input logic clk,
	input logic rstn,
	input logic seq_in,
	output logic detected,
	output logic [7:0] no_of_seq
);
    
	typedef enum logic [1:0] {S0, S1, S10, S101} state_t;
	state_t state, next_state;
	
	reg [7:0] counter;
	
	always_ff@(posedge clk, negedge rstn) begin
		if(!rstn)
			state <= S0;
		else
			state <= next_state;
	end
    
  always_ff@(posedge clk, negedge rstn) begin
  	if(!rstn) begin
  		counter <= 0;
  		no_of_seq <= 0;
  	end
  	else if(detected)
  		counter <= counter + 1'b1;
  end
   
	always_comb begin
		case(state)
			S0: begin
				if(seq_in == 1'b1)
					next_state = S1;
				else
					next_state = S0;
			end
			S1: begin
				if(seq_in == 1'b0)
					next_state = S10;
				else
					next_state = S1;
			end
			S10: begin
				if(seq_in == 1'b1) begin
					next_state = S101;
					detected = 1'b1;
				end
				else
					next_state = S0;
			end
			S101: begin
				if(seq_in == 1'b1)
					next_state = S1;
				else if(seq_in == 1'b0)
					next_state = S10;
				else
					next_state = S0;
			end
			default: next_state = S0;			
		endcase
	end   
	
  assign detected = (state == S101);
  assign no_of_seq = counter;
    
endmodule
