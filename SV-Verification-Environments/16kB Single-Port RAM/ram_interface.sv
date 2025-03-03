interface ram_intf(
  input logic clk
);
	logic rstn;
	logic we;
  logic [13:0] addr;
  logic [7:0] wdata;
  logic [7:0] rdata;
endinterface: ram_intf
