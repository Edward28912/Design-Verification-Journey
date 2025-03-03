`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_sequence_item.sv"

class ram_write_sequence extends uvm_sequence #(ram_seq_item);
	
	`uvm_object_utils(ram_write_sequence)
	
	ram_seq_item seq_item;
	
	bit [13:0] addr;
	bit [7:0] wdata;
	bit we;
	bit is_random_b;
	
	function new(string name="");
    super.new(name);
  endfunction: new
	
	virtual task body();
	
		seq_item = ram_seq_item::type_id::create("seq_item");
		
		if(is_random_b) begin
			if(!seq_item.randomize() with { seq_item.we == 1; }) begin
				`uvm_error(get_type_name(), " Randomization failed!")
      end
		end
		else begin
			seq_item.we 	= 1;
			seq_item.addr	= addr;
			seq_item.wdata	= wdata;
			seq_item.rstn 	= 1;
		end
		
		`uvm_info(get_type_name(), $sformatf("  Executing write sequence with parameters we=%0d address=%d data=%0d", seq_item.we, seq_item.addr, seq_item.wdata), UVM_NONE)

    `uvm_send(seq_item)

    `uvm_info(get_type_name()," WRITE sequence completed ", UVM_NONE)
		
	endtask: body
	
endclass: ram_write_sequence

class ram_read_sequence extends uvm_sequence#(ram_seq_item);
	`uvm_object_utils(ram_read_sequence)
	
	ram_seq_item seq_item;
	
	bit [13:0] addr;
	bit is_random_b;
  	bit we;
	
	function new(string name="");
    super.new(name);
  endfunction: new

  virtual task body();
		seq_item = ram_seq_item::type_id::create("seq_item");
			if(is_random_b) begin
        if(!seq_item.randomize() with { seq_item.we == 0; }) begin
          `uvm_error(get_type_name(), " Randomization failed!")
        end
			end
			else begin
				seq_item.we		= 0;
				seq_item.addr	= addr;
				seq_item.rstn = 1;
			end
			
			`uvm_info(get_type_name(), $sformatf(" Executing read sequence with parameters we=%0d, address=%0d", seq_item.we, seq_item.addr), UVM_NONE)
			
			`uvm_send(seq_item)
			
			`uvm_info(get_type_name(), " READ sequence completed ", UVM_NONE)
			
  endtask: body
	
endclass: ram_read_sequence

class ram_write_read_sequence extends uvm_sequence #(ram_seq_item);
	`uvm_object_utils(ram_write_read_sequence)
	
	bit [13:0] addr;
	bit [7:0] wdata;
	bit we;
	bit is_random_b;
	
	ram_seq_item seq_item;
	
	function new(string name="ram_write_read_sequence");
    super.new(name);
  endfunction: new
	
	virtual task body ();
		seq_item = ram_seq_item::type_id::create("seq_item");
		if(we) begin
			if(is_random_b) begin
				void'(seq_item.randomize() with {
					seq_item.we == 1;
				});
			end
			else begin
				seq_item.we 	= 1;
				seq_item.addr 	= addr;
				seq_item.wdata 	= wdata;
				seq_item.rstn 	= 1;
			end
			
				`uvm_info(get_type_name(), $sformatf(" Executing write sequence with parameters we=%0d address=%d data=%0d", seq_item.we, seq_item.addr, seq_item.wdata), UVM_NONE)

    		`uvm_send(seq_item)

    		`uvm_info(get_type_name()," WRITE sequence completed ", UVM_MEDIUM)
				
			end
		else begin
			if(is_random_b) begin
				void'(seq_item.randomize() with {
					seq_item.we == 0;
				});
			end
			else begin
				seq_item.we 	= 0;
				seq_item.addr = addr;
				seq_item.rstn = 1;
			end
			
				`uvm_info(get_type_name(), $sformatf(" Executing read sequence with parameters we=%0d, address=%0d, data=%0d", seq_item.we, seq_item.addr, seq_item.wdata), UVM_NONE)
			
				`uvm_send(seq_item)
			
				`uvm_info(get_type_name(), " READ sequence completed ", UVM_MEDIUM)
				
		end
  endtask: body
	
endclass: ram_write_read_sequence