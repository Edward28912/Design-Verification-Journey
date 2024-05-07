module prng(
	input reset_n,
	input clk,
	input load_seed,
	input encrypt_en,
	input [7:0] seed_in,
	output reg [7:0] prng
);

	localparam SEED = 8'hCD;
	
	wire feedback;
	assign feedback = prng[7] ^ prng [5] ^ prng[4] ^ prng[3];
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			prng <= SEED;
			
		else if (load_seed)
			prng <= seed_in;
			
		else if (encrypt_en)
			prng <= {prng[6:0], feedback};
	
	end

endmodule

module top_encrypt(
	input reset_n,
	input clk,
	input load_seed,
	input [7:0] seed_in,
	input encrypt_en,	
	input [7:0] data_in,
	output reg [7:0] data_out
);

	reg encrypt_en_delay;
	reg [7:0] data_in_delay;
	wire [7:0] prng;
	
	prng PRNG(
		.reset_n		(reset_n),
		.clk			(clk),
		.load_seed		(load_seed),
		.seed_in		(seed_in),
		.encrypt_en		(encrypt_en),
		.prng			(prng)
	);

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
		
			encrypt_en_delay <= 0;
			data_in_delay <= 0;
		
		end
	
		else begin
		
			encrypt_en_delay <= encrypt_en;
			data_in_delay <= data_in;
		
		end
	
	end

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			data_out <= 0;
			
		else if (encrypt_en_delay)
			data_out <= prng ^ data_in_delay;
	
	end

endmodule

module top_encrypt_golden(
	input reset_n,
	input clk,
	input load_seed,
	input [7:0] seed_in,
	input encrypt_en,
	input [7:0] data_in,
	output reg [7:0] data_out
);

	localparam SEED = 8'hCD;
	
	reg encrypt_en_delay;
	reg [7:0] data_in_delay;
	reg [7:0] prng;
	
	function [7:0] poly(input [7:0] data_in);
		
		reg feedback;
		
		begin
		
			feedback = data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[3];
			poly = {data_in[6:0], feedback};
		
		end
	
	endfunction
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			prng <= SEED;
		
		else if (load_seed)
			prng <= seed_in;
			
		else if (encrypt_en)
			prng <= poly(prng);
	
	end
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
			
			encrypt_en_delay <= 0;
			data_in_delay <= 0;
			data_out <= 0;
		end
	
		else begin
		
			encrypt_en_delay <= encrypt_en;
			data_in_delay <= data_in; 
		
			if(encrypt_en_delay)
				data_out <= prng ^ data_in_delay;
		
		end
	
	end
	
endmodule

`timescale 1ns / 1ps

module encrypt_tb();

	reg clk = 0;
	reg reset_n;
	
	reg load_seed;
	reg [7:0] seed_in;
	reg [7:0] data_in;
	reg encrypt_en;
	
	wire [7:0] data_out;
	wire [7:0] data_out_ref;
	
	integer success_count = 0, error_count = 0, test_count = 0;
	integer i;

top_encrypt ENCRYPT_MODULE(
	.clk			(clk),
	.reset_n		(reset_n),
	.load_seed		(load_seed),
	.seed_in		(seed_in),
	.encrypt_en		(encrypt_en),
	.data_in		(data_in),
	.data_out		(data_out)
);

top_encrypt_golden ENCRYPT_MODULE_REF(
	.clk			(clk),
	.reset_n		(reset_n),
	.load_seed		(load_seed),
	.seed_in		(seed_in),
	.encrypt_en		(encrypt_en),
	.data_in		(data_in),
	.data_out		(data_out_ref)
);

	always begin #0.5 clk = ~clk; end
	
	initial begin
	
		reset_n = 0;
		load_seed = 0;
		seed_in = 0;
		data_in = 0;
		encrypt_en = 0;
		
		#20; reset_n = 1;
		
		@(posedge clk);
		encrypt_data("D"); validate_data();
		encrypt_data("r"); validate_data();
		encrypt_data("i"); validate_data();
		encrypt_data("s"); validate_data();
		encrypt_data("t"); validate_data();
		encrypt_data("i"); validate_data();
		encrypt_data("n"); validate_data();
		encrypt_data("a"); validate_data();
		
		#20;
		
		@(posedge clk);
		$display($time, " TEST RESULTS: test_count = %0d, success_count = %0d, error_count = %0d", test_count, success_count, error_count);
		#5 $stop;
	
	end
	
	task encrypt_data(input [7:0] data_to_encrypt);
	
		begin
		
			@(posedge clk);
			encrypt_en = 1;
			data_in = data_to_encrypt;
			// $display($time, " data_wr = %s", data_in);
			@(posedge clk);
			encrypt_en = 0;
			
		end
	
	endtask

	task load_new_seed(input [7:0] new_seed);
	
		begin
		
			@(posedge clk);
			load_seed = 1;
			seed_in = new_seed;
			// $display($time, " seed = %s", seed_in);
			@(posedge clk);
			load_seed = 0;
		
		end
	
	endtask

	task validate_data();
	
		begin
		
			@(posedge clk);
			@(negedge clk);
			
			test_count = test_count + 1;
			if (data_out === data_out_ref) begin
			
				$display($time, " test_count=%d PASS, data_out_ref=%x, data_out=%x", test_count, data_out_ref, data_out); 
				success_count = success_count + 1;
			
			end
		
			else begin
			
				$display($time, " test_count=%d FAIL, data_out_ref=%x, data_out=%x", test_count, data_out_ref, data_out); 
				error_count	= error_count + 1;
			
			end
		
		end
	
	endtask

endmodule