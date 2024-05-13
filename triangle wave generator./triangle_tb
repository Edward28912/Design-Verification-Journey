`timescale 1ns / 1ps

module triangle_tb();

	reg clk = 0;
	reg reset_n;
	reg [3:0] din;
	reg push;
	
	wire [3:0] bcd;
	
	triangle DUT(
		.clk		(clk),
		.reset_n	(reset_n),
		.din		(din),
		.push		(push),
		.bcd		(bcd)
	);

	always begin #1 clk = ~clk; end
	
	initial begin
	
		$monitor($time, " bcd = %0d", bcd);
	
		reset_n = 0;
		
		#50; reset_n = 1;
		
		repeat(10) @(negedge clk); push = 1; din = 4'd6;
		
		@(negedge clk); push = 0;
		
		repeat(5) @(negedge clk); push = 1; din = 4'd9;
		
		#350 $stop;
	
	end

endmodule
