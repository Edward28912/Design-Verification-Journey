`timescale 1ns / 1ps

module ram_sp_async_read(
	input clk,
	input [7:0] data_in,
	input [3:0] address,
	input we,
	output [7:0] data_out
);

	reg [7:0] ram [0:15];
	
	always@(posedge clk) begin
		
		if(we)
			ram[address] <= data_in;
		
	end

	assign data_out = ram[address];

endmodule

module ram_sp_async_read_tb();

	reg clk = 0;
	reg [7:0] data_in;
	reg [3:0] address;
	reg we;
	wire [7:0] data_out;
	reg [1:0] delay;
	
	reg [7:0] wr_data;
	integer success_count, error_count, test_count, i;

ram_sp_async_read RAM0(
	.clk(clk),
	.data_in(data_in),
	.address(address),
	.we(we),
	.data_out(data_out)   
);

	task write_data (input [3:0] address_in, input [7:0] d_in);
	
		begin
		
			@(posedge clk);
			we = 1;
			address = address_in;
			data_in = d_in;
			
		end
	
	endtask

	task read_data (input [3:0] address_in);
	
		begin
		
			@(posedge clk);
			we = 0;
			address = address_in;
		
		end
	
	endtask

	task compare_data(input [3:0] address, input [7:0] expected_data, input [7:0] observed_data);
	
		begin
		
			if (expected_data === observed_data) begin
			
				$display($time, " SUCCESS, address = %0d, expected_data = %2x, observed_data = %2x", address, expected_data, observed_data);
				success_count = success_count + 1;
			
			end
		
			else begin
			
				$display($time, " ERROR, address = %0d, expected_data = %2x, observed_data = %2x", address, expected_data, observed_data);
				error_count = error_count + 1;
			
			end
		
			test_count = test_count + 1;
		
		end
	
	endtask

	always begin #0.5 clk = ~clk; end
	
	initial begin
	
		#1 success_count = 0; error_count = 0; test_count = 0;
	
		#1.3

		for(i = 0; i < 17; i = i + 1) begin
		
			wr_data = $random;
			write_data(i, wr_data);
			read_data(i);
			#0.1;
			compare_data(i, wr_data, data_out);
			delay = $random;
			#(delay);
			
		end
		
		read_data(7);
		read_data(8);
		
		$display($time, " TESTS RESULTS: success_count = %d, error_count = %d, test_count = %d", success_count, error_count, test_count);
		#10 $stop;
	
	end

endmodule	