`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_seq_item extends uvm_sequence_item;

	`uvm_object_utils(ram_seq_item)
	
	rand bit we;
	bit rstn;
	rand bit [13:0] addr;
	rand bit [7:0] wdata;
	bit [7:0] rdata;
	
	function new (string name="ram_seq_item");
		super.new(name);
  endfunction: new

endclass: ram_seq_item