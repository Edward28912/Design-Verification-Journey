interface seq_detection_intf(input logic clk);
	logic rstn;
	logic seq_in;
	logic detected;
	logic [7:0] no_of_seq;
	
	clocking cb@(posedge clk);
		output rstn, seq_in;
		input detected, no_of_seq;
	endclocking: cb
	
endinterface: seq_detection_intf