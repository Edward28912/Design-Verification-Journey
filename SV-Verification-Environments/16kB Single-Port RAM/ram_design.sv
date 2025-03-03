module ram(
		input clk,
		input rstn,
		input we,
		input [13:0] addr,
		input [7:0] wdata,
		output reg [7:0] rdata
);

	localparam int DEPTH = 2**14;
	reg [7:0] ram [0:DEPTH-1];
	integer i;
	
	always@(posedge clk, negedge rstn) begin
		if(!rstn)
			for (i = 0; i<DEPTH; i=i+1)begin
				ram[i] <= 0;
				rdata <= 0;
			end
		else if(we)
			ram[addr] <= wdata;
		else
			rdata <= ram[addr];
	end

endmodule
