`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_sequencer extends uvm_sequencer #(ram_seq_item);

  `uvm_component_utils(ram_sequencer)

  function new (string name="ram_sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void start_of_simulation_phase (uvm_phase phase);
		`uvm_info (get_type_name(), $sformatf(" Executing start of simulation phase: SEQUENCER"), UVM_NONE);
  endfunction: start_of_simulation_phase

endclass: ram_sequencer