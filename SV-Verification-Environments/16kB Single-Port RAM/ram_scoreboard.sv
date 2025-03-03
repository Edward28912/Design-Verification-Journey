typedef ram_env;
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_environment.sv"

class ram_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(ram_scoreboard)
	
	uvm_analysis_imp#(ram_seq_item, ram_scoreboard) sb_port;
	ram_env p_env;
	
	localparam int DEPTH = 2**14;
	reg [7:0] golden_ram [0:DEPTH-1];
	
  function new(string name = "ram_scoreboard", uvm_component parent);
    super.new(name, parent);
      sb_port = new("sb_port", this);
  endfunction: new
	
	virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i<DEPTH; i++) begin
      golden_ram[i] = 8'b0000_0000;
    end
  endfunction: build_phase
	
	task golden_model(ram_seq_item tx);
      if (tx.we) 
        golden_ram[tx.addr] = tx.wdata;
 	  else begin
        if (golden_ram[tx.addr] !== tx.rdata)
          `uvm_error(get_type_name(), $sformatf( " Mismatch at address %0d: Expected=%0d, Observed=%0d", tx.addr, golden_ram[tx.addr], tx.rdata))
        else
          `uvm_info(get_type_name(), $sformatf(" Match at address %0d: Expected=%0d, Observed=%0d", tx.addr, golden_ram[tx.addr], tx.rdata), UVM_NONE)
      end
  endtask: golden_model 
	
	virtual function void write(ram_seq_item tx);
    	golden_model(tx);
  endfunction
	
endclass: ram_scoreboard