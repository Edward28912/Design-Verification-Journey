`timescale 1ns / 1ps

module ram_sp_sync_read(
	input clk,
	input [7:0] data_in,
	input we,
	input [3:0] address,
	output reg [7:0] data_out
);

	reg [7:0] ram [0:15];
	reg [3:0] addr_buff;
	
	always@(posedge clk) begin
	
		if(we)
			ram[address] <= data_in;
		
		addr_buff <= address;
	end

	assign data_out = ram[addr_buff];

endmodule

module ram_sp_sync_read_tb();

	reg clk = 0;
	reg [7:0] data_in;
	reg we;
	reg [3:0] address;
	reg [7:0] wr_data;
	wire [7:0] data_out;
	
	integer success_count, error_count, test_count, i;
	reg [1:0] delay;

ram_sp_sync_read DUT(
	.clk(clk),
	.data_in(data_in),
	.we(we),
	.address(address),
	.data_out(data_out)
);

	task write_data(input [3:0] address_in, input [7:0] d_in);
	
		begin
		
			@(posedge clk);
			we = 1;
			address = address_in;
			data_in = d_in;
		
		end
	
	endtask

	task read_data(input [3:0] address_in);
	
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
		
		for(i = 0; i < 17; i = i + 1) begin
		
			wr_data = $random;
			write_data(i, wr_data);
			read_data(i);
			#0.1; 
			compare_data(i, wr_data, data_out);
			delay = $random;
			#(delay);
			
		end
		
		$display($time, " TEST RESULTS: success_count = %d, error_count = %d, test_count = %d", success_count, error_count, test_count);
		
		#10 $stop;
		
	end

endmodule