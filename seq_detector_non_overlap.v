module seq_detector_non_overlap(
	input clk,
	input reset_n,
	input seq_in,
	output reg detected,
	output [1:0] state_out,
	output [3:0] number_correct_seq
);

	parameter [2:0] S1		= 3'b001,
					S10		= 3'b010,
					S101	= 3'b100;

	reg [2:0] state;
	reg [2:0] next_state;
	reg [3:0] counter;
	
	always@(posedge clk, negedge reset_n) begin

		if(!reset_n)
			state <= S1;
		
		else
			state <= next_state;

	end

	assign state_out = state;
	
	always@(*) begin
	
		detected = 1'b0;
		
		case(state)
		
			S1:	begin
			
				if(seq_in == 1'b1)
					next_state = S10;
					
				else
					next_state = S1;
			
			end
		
			S10: begin
			
				if(seq_in == 1'b0)
					next_state = S101;
					
				else
					next_state = S10;
			
			end
			
			S101: begin
			
				if(seq_in == 1'b1)
					detected = 1;
					
				next_state = S1;
			
			end
			
			default: next_state = S1;
			
		endcase
	
	end

	always@(posedge clk, negedge reset_n) begin
		
		if(!reset_n)
			counter <= 0;
			
		else if (detected)
			counter <= counter + 1'b1;
		
	end
	
	assign number_correct_seq = counter;

endmodule

module seq_detector_non_overlap_tb();

	reg clk = 0;
	reg reset_n;
	reg seq_in;
	wire detected;
	wire [1:0] state_out;
	wire [3:0] number_correct_seq;
	
	reg [0:13] test_vector = 14'b00_1100_0101_0101;
	integer i;

seq_detector_non_overlap DUT(
	.clk(clk),
	.reset_n(reset_n),
	.seq_in(seq_in),
	.detected(detected),
	.state_out(state_out),
	.number_correct_seq(number_correct_seq)
);

	always begin #1 clk = ~clk; end

	initial begin
	
		$monitor($time, " seq_in = %b, detected = %b", seq_in, detected);
		
		reset_n = 0;
		
		#2.5; reset_n = 1;
		
		repeat(2) @(posedge clk); 
		
		for(i = 0; i < 14; i = i + 1) begin
		
			seq_in = test_vector[i];
			@(posedge clk);
		
		end
		
		for(i = 0; i < 15; i = i+1) begin
		
			seq_in = $random;
			@(posedge clk);
		
		end
		
		repeat(10) @(posedge clk);
		$display($time, " NUMBER OF CORRECT SEQUENCES: %d", number_correct_seq);
		
		#10 $stop;
		
	end

endmodule