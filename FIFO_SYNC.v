module FIFO_SYNC #(parameter FIFO_DEPTH = 8, parameter DATA_WIDTH = 32) (
	input clk,
	input reset_n,
	input cs,
	input wr_en,
	input rd_en,
	input [DATA_WIDTH -1:0] data_in,
	output reg [DATA_WIDTH -1:0] data_out,
	output full,
	output empty
);

	localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);
	
	reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
	
	reg [FIFO_DEPTH_LOG:0] write_pointer;
	reg [FIFO_DEPTH_LOG:0] read_pointer;
	
	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			write_pointer <= 0;
			
		else if (cs && wr_en && !full)
			write_pointer <= write_pointer + 1'b1;
	
	end

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			read_pointer <= 0;
			
		else if (cs && rd_en && !empty)
			read_pointer <= read_pointer + 1'b1;
	
	end

	assign empty = (read_pointer == write_pointer);
	assign full  = (read_pointer == {~write_pointer[FIFO_DEPTH_LOG], write_pointer[FIFO_DEPTH_LOG-1:0]});
	
	always@(posedge clk) begin
	
		if(cs && wr_en && !full)
			fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
	
	end

	always@(posedge clk, negedge reset_n) begin
	
		if(!reset_n)
			data_out <= 0;
			
		else if (cs && rd_en && !empty)
			data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
	
	end

endmodule

`timescale 1ns/1ps
module FIFO_SYNC_tb();

	parameter DATA_WIDTH = 32;
	parameter FIFO_DEPTH = 8;

	reg clk = 0;
	reg reset_n;
	reg cs;
	reg wr_en;
	reg rd_en;
	reg [DATA_WIDTH -1:0] data_in;
	wire [DATA_WIDTH -1:0] data_out;
	wire full;
	wire empty;
	
	integer i;

FIFO_SYNC #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) DUT (
	.clk(clk),
	.reset_n(reset_n),
	.cs(cs),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.data_in(data_in),
	.data_out(data_out),
	.full(full),
	.empty(empty)
);

	task write_data(input [DATA_WIDTH -1:0] d_in);
	
		begin
		
			@(posedge clk);
			cs = 1; wr_en = 1;
			data_in = d_in;
			$display($time, " write_data data_in = %0d", data_in);
			@(posedge clk);
			cs = 1; wr_en = 0;
		
		end
	
	endtask

	task read_data();
	
		begin
		
			@(posedge clk);
			cs = 1; rd_en = 1;
			@(posedge clk);
			#0.1;
			$display($time, " read_data data_out = %0d", data_out);
			cs = 1; rd_en = 0;
		
		end
	
	endtask

	always begin #0.5 clk = ~clk; end
	
	initial begin
	
		#1;
		reset_n = 0; wr_en = 0; rd_en = 0;
		
		#1.3;
		reset_n = 1;
		$display($time, "\n SCENARIO 1");
		write_data(1);
		write_data(10);
		write_data(100);
		read_data();
		read_data();
		read_data();
		read_data();
		
		$display($time, "\n SCENARIO 2");
		for (i=0; i<FIFO_DEPTH; i=i+1) begin
		    write_data(2**i);
			read_data();        
		end

        $display($time, "\n SCENARIO 3");		
		for (i=0; i<=FIFO_DEPTH; i=i+1) begin
		    write_data(2**i);
		end
		
		for (i=0; i<FIFO_DEPTH; i=i+1) begin
			read_data();
		end
	
	
		#40 $stop;
	end

endmodule