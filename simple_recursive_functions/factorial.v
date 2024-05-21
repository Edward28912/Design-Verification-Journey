module factorial();

	function automatic integer factorial (input integer N);
	
			integer result = 0;
			
		begin
			if(N == 0)
				result = 1;
			else
				result = N * factorial(N-1);
		
			factorial = result;
		
		end
	endfunction
	
	integer a;
	
	initial begin
	
		#5 a = 10;
			$display($time, " a = %d => factorial(%0d) = %0d", a, a, factorial(a));
			
		#5 a = 3;
			$display($time, " a = %d => factorial(%0d) = %0d", a, a, factorial(a));
	
	end

endmodule
