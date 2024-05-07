`timescale 1ns / 1ps

module ram_dp_async_read2 # (parameter WIDTH = 8, parameter DEPTH = 16, parameter DEPTH_LOG = $clog2(DEPTH)) (

		input clk,
		input we_n,
		input [DEPTH_LOG -1:0] addr_wr,
		input [DEPTH_LOG -1:0] addr_rd,
		input [WIDTH -1:0] data_wr,
		output [WIDTH -1:0] data_rd
);

	reg [WIDTH -1:0] ram [0: DEPTH - 1];
	
	always@(posedge clk) begin
	
		if(we_n)
			ram[addr_wr] <= data_wr;
	
	end

	assign data_rd = ram [addr_rd];

endmodule

module ram_dp_async_read2_tb();

	parameter WIDTH = 8;
	parameter DEPTH = 16;
	parameter DEPTH_LOG = $clog2(DEPTH);
	
	reg clk = 0;
	reg we_n; 
	reg [DEPTH_LOG - 1:0] addr_wr;
	reg [DEPTH_LOG - 1:0] addr_rd;
	reg [WIDTH - 1:0] data_wr;
	wire [WIDTH - 1:0] data_rd;

	reg [DEPTH_LOG -1:0] rand_addr_wr;
	
	integer i = 0;
	integer success_count = 0;
	integer error_count = 0;
	integer test_count = 0; 
	integer num_tests = 0;

ram_dp_async_read2 #(.WIDTH(WIDTH), .DEPTH(DEPTH)) DUT (
	.clk(clk),
	.we_n(we_n),
	.addr_wr(addr_wr),
	.addr_rd(addr_rd),
	.data_wr(data_wr),
	.data_rd(data_rd)
);
	
	task write_data(input [DEPTH_LOG -1 :0] address_in, input [WIDTH - 1:0] data_in);
	
		begin
		
			@(posedge clk);
			we_n = 1;
			data_wr = data_in;
			addr_wr = address_in;
		
		end
	
	endtask
	
	task read_data(input [DEPTH_LOG - 1:0] address_in);
	
		begin
		
			@(posedge clk);
			we_n = 0;
			addr_rd = address_in;
		
		end
	
	endtask
	
	task compare_data(input [DEPTH_LOG - 1:0] address, input [WIDTH - 1:0] expected_data, input [WIDTH - 1:0] observed_data);
	
		begin
		
			if(expected_data === observed_data) begin
			
				$display($time, "SUCCES, address = %0d, expected_data = %0x, observed_data = %0x", address, expected_data, observed_data);
				success_count = success_count + 1;
			
			end
		
			else begin
			
				$display($time, "ERROR, address = %0d, expected_data = %0x, observed_data = %0x", address, expected_data, observed_data);
				error_count = error_count + 1;
			
			end
		
			test_count = test_count + 1;
		
		end
	
	endtask
	
	always begin #0.5 clk = ~clk; end
	
	initial begin
	
		#1 success_count = 0; error_count = 0; test_count = 0; num_tests = DEPTH;
		
		#1.3 
		
		$display($time,  " TEST 1 STARTING NOW. ");
		
		for(i = 0; i < num_tests**2; i = i + 1) begin
		
			data_wr = $random;
			write_data(i, data_wr);
			read_data(i);
			#0.1;
			compare_data(i, data_wr, data_rd);
		
		end
		
		$display($time, " TEST 2 STARTING NOW. ");
		
		for(i = 0; i < num_tests**2; i = i + 1) begin
		
			rand_addr_wr = $random % DEPTH;
			data_wr = (rand_addr_wr << 4) | ((rand_addr_wr % 2) ? 4'hA : 4'h5); 
		
			write_data(rand_addr_wr, data_wr);
			read_data(rand_addr_wr);
			#0.1;
			compare_data(rand_addr_wr, data_wr, data_rd);
		
		end
		
		$display($time, " THE TESTS RESULTS ARE THE FOLLOWING: success_count = %0d, error_count = %0d, test_count = %0d", success_count, error_count, test_count);
		#50 $stop;
		
	end
	
endmodule