`timescale 1ns / 1ps

module fibonacci_function();

	function automatic integer fibonacci(input integer N);
	
		integer result = 0;
		
		begin
		
			if (N == 0)
				result = 0;
				
			else if (N == 1)
				result = 1;
			
			else
				result = fibonacci(N-1) + fibonacci(N-2);
				
			fibonacci = result;
		
		end
	
	endfunction
	
	integer a;
	
	initial begin
	
		#5	a = 5;
			$display($time, " a = %0d => fibonacci(%0d) = %0d", a, a, fibonacci(a));
			
		#10	a = 8;	
			$display($time, " a = %0d => fibonacci(%0d) = %0d", a, a, fibonacci(a));
		
		#10 a = 10;
			$display($time, " a = %0d => fibonacci(%0d) = %0d", a, a, fibonacci(a));
	
	end

	
endmodule
