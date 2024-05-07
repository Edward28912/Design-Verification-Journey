`timescale 1ns / 1ps

module compare_nbit_func 

	#(parameter CMP_WIDTH = 4)
	
	(input [CMP_WIDTH - 1:0] a,
	 input [CMP_WIDTH - 1:0] b,
	 output reg greater,
	 output reg equal,
	 output reg smaller		
);

	function [2:0] compare (input [CMP_WIDTH -1:0] a, input [CMP_WIDTH -1:0] b);
	
		reg greater_local;
		reg equal_local;
		reg smaller_local;
		
		begin
		
			greater_local = (a>b);
			equal_local = (a==b);
			smaller_local = (a<b);
		
			compare = {greater_local, equal_local, smaller_local};
		
		end
	
	endfunction

	always@(*) begin
		
		{greater, equal, smaller} = compare(a,b);
		
	end

endmodule


module compare_nbit_func_tb();

	parameter CMP_WIDTH = 5;
	reg [CMP_WIDTH	-1:0] a, b;
	wire greater, equal, smaller;
	
compare_nbit_func #(.CMP_WIDTH(CMP_WIDTH)) DUT (
	.a(a),
	.b(b),
	.greater(greater),
	.equal(equal),
	.smaller(smaller)
);

	initial begin
		$monitor($time, " a = %0d, b = %0d, greater = %b, equal = %b, smaller = %b", a, b, greater, equal, smaller);
		
		#5		a = 3;	b = 2;
		#5		b = 3;
		#5		a = 9;	b = 11;
	
	end
	
	

endmodule