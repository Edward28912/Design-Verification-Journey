interface ram_intf(
  input logic clk
);
	logic rstn;
	logic we;
  logic [13:0] addr;
  logic [7:0] wdata;
  logic [7:0] rdata;

  clocking cb @(posedge clk);
		default input #1step output #1step;
			input rstn;
			input rdata;
			output we;
			output addr;
			output wdata;
    endclocking
endinterface: ram_intf