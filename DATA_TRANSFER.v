module ram_dp_async_read # (parameter WIDTH = 8, parameter DEPTH = 16, parameter DEPTH_LOG = $clog2(DEPTH)) (
	input clk,
	input we,
	input [WIDTH-1:0] data_wr,
	input [DEPTH_LOG-1:0] addr_wr,
	input [DEPTH_LOG-1:0] addr_rd,
	output [WIDTH-1:0] data_rd
);

	reg [WIDTH-1:0] ram [0:DEPTH-1];
	
	always@(posedge clk) begin
	
		if(we)
			ram[addr_wr] <= data_wr;
	
	end

	assign data_rd = ram[addr_rd];

endmodule

module top_fsm(
	input clk,
	input reset_n,
	//SIGNALS FOR THE INPUT RAM
	input ram_in_we,
	input [7:0] ram_in_data_wr,
	input [4:0] ram_in_addr_wr,
	//SIGNALS FOR THE OUTPUT RAM
	output [15:0] ram_out_data_rd,
	input [3:0] ram_out_addr_rd,
	//FSM CONTROL SIGNALS
	input opmode_in,
	output reg done_out
);

	parameter [3:0] IDLE 			= 4'b0001,
					READ_BYTE0 		= 4'b0010,
					READ_BYTE1  	= 4'b0100,
					WRITE_BYTE12	= 4'b1000;
					
	reg [3:0] state;
	reg [3:0] next_state;
	
	reg [4:0] ram_pointer; // USED TO READ THE LOCATIONS OF THE INPUT RAM || Used to read from RAM_IN and write in RAM_OUT
	
	
	//Used to read and store the data from each location of the input SRAM
	reg [4:0] fsm_mem_in_addr_rd;
	wire [7:0] fsm_mem_in_data_rd;
	reg [7:0] read_byte0_buffer, read_byte1_buffer;
	
	//Used to write the data in the output SRAM
	reg [3:0] fsm_mem_out_addr_wr;
	reg ram_out_we;
	
	ram_dp_async_read #(.WIDTH(8), .DEPTH(32)) RAM_IN (
		.clk(clk),
		.we(ram_in_we),
		.data_wr(ram_in_data_wr),
		.addr_wr(ram_in_addr_wr),
		.addr_rd(fsm_mem_in_addr_rd),
		.data_rd(fsm_mem_in_data_rd)
	);
	
	ram_dp_async_read #(.WIDTH(16), .DEPTH(16)) RAM_OUT (
		.clk(clk),
		.we(ram_out_we),
		.data_wr({read_byte1_buffer, read_byte0_buffer}),
		.addr_wr(fsm_mem_out_addr_wr),
		.addr_rd(ram_out_addr_rd),
		.data_rd(ram_out_data_rd)
	);
 	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) 
			state <= IDLE;
			
		else
			state <= next_state;
	
	end
	
	always@(*) begin
	
		next_state = IDLE;
		fsm_mem_in_addr_rd = 0;
		ram_out_we = 0;
		
		case(state)
		
			IDLE: begin
			
				if(opmode_in == 1'b1)
					next_state = READ_BYTE0;
			
			end
		
			READ_BYTE0: begin
			
				fsm_mem_in_addr_rd = ram_pointer;	
				next_state = READ_BYTE1;
			
			end
		
			READ_BYTE1: begin
			
				fsm_mem_in_addr_rd = ram_pointer;
				next_state = WRITE_BYTE12;
			
			end
		
			WRITE_BYTE12: begin
			
				if (done_out == 1'b1)
					next_state = IDLE;
					
				else
					next_state = READ_BYTE0;
					
				ram_out_we = 1;
			
			end
		
			default: next_state = IDLE;
		
		endcase
	
	end
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			ram_pointer <= 0;
			
		else if ((state == READ_BYTE0) || (state == READ_BYTE1))
			ram_pointer <= ram_pointer + 1'b1;
	
	end
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			fsm_mem_out_addr_wr <= 0;
			
		else if (state == READ_BYTE0)
			fsm_mem_out_addr_wr <= (ram_pointer >> 1);
	
	end
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			done_out <= 0;
			
		else if (opmode_in == 1'b1)
			done_out <= 0;
			
		else if (ram_pointer == 5'd31)
			done_out <= 1;
	
	end
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n) begin
		
			read_byte0_buffer <= 0;
			read_byte1_buffer <= 0;
		
		end
			
		else begin
		
			read_byte0_buffer <= fsm_mem_in_data_rd;
			read_byte1_buffer <= read_byte0_buffer;
		
		end
	
	end
	
endmodule

module top_fsm_tb();

	localparam DEPTH = 4;
	localparam WIDTH_WR = 8;
	
	reg clk = 0;
	reg reset_n;
	reg we;
	reg [4:0] addr_wr;
	reg [3:0] addr_rd;
	reg [WIDTH_WR -1:0] data_wr;
	wire [2*WIDTH_WR-1:0] data_rd;
	reg [2*WIDTH_WR-1:0] data_rd_buf;
	wire done;
	reg opmode;
	reg [2*WIDTH_WR-1:0] expected_data;
	
	integer i, no_loops;
	
	integer success_count = 0, error_count = 0, test_count = 0;

top_fsm TOP(
	.clk(clk),
	.reset_n(reset_n),
	.ram_in_we(we),
	.ram_in_addr_wr(addr_wr),
	.ram_in_data_wr(data_wr),
	.ram_out_addr_rd(addr_rd),
	.ram_out_data_rd(data_rd),
	.opmode_in(opmode),
	.done_out(done)
);

	always begin #0.5 clk = ~clk; end
	
	task write_data(input [4:0] address_in, input [WIDTH_WR-1:0] d_in);
	
		begin
		
			@(posedge clk);
			we = 1;
			data_wr = d_in;
			addr_wr = address_in;
			$display($time, " write_address = %0d, data_wr = 0x%h", addr_wr, data_wr);
			@(posedge clk);
			we = 0;
		
		end
	
	endtask

	task read_data(input [3:0] address_in);
	
		begin
		
			@(posedge clk);
			addr_rd = address_in;
			@(negedge clk);
			$display($time, " read_address = %0d, data_rd = 0x%h", addr_rd, data_rd);
			data_rd_buf = data_rd;
		
		end
	
	endtask

	task compare_data(input [2*WIDTH_WR-1:0] expected, input [2*WIDTH_WR-1:0] observed);
	
		begin
		
			test_count = test_count + 1;
			
			if (expected != observed) begin
			
				error_count = error_count + 1;
				//$display($time, " test_count = %d FAIL: expected data_out = %x, observed data_out = %x", test_count, expected, observed);
			
			end
		
			else begin
			
				success_count = success_count + 1;
				//$display($time, " test_count = %d PASS: expected data_out = %x, observed data_out = %x", test_count, expected, observed);
			
			end
		
		end
	
	endtask

	initial begin
	
		we = 0;
		addr_wr = 0;
		opmode = 0; // store data in RAM_IN
		reset_n = 0;
		
		#10 reset_n = 1;
		
		for(no_loops = 0; no_loops < 2; no_loops = no_loops + 1) begin
		
			for (i = 0; i < 32; i = i + 1) begin
			
				write_data(i, ((i % 2) << 7) + i + no_loops);
			
			end
		
			@(posedge clk); opmode = 1;
			@(posedge clk); opmode = 0;
		
			@(posedge clk); wait (done === 1);
			
			for(i = 0; i < 32; i = i + 2) begin
			
				read_data(i >> 1);
				expected_data = ((((i%2)<<7)+i+no_loops)<<8) | ((((i+1)%2)<<7)+(i+no_loops+1));
				compare_data(expected_data, data_rd_buf);
			
			end
		
		end
	
		#40; $display($time, " test_count = %d, success_count = %d, error_count = %d", test_count, success_count, error_count);
		
		$stop;
	
	end

endmodule
