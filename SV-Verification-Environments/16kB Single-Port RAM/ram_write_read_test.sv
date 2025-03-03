`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_sequence_lib.sv"
`include "ram_environment.sv"

class ram_write_read_test extends uvm_test;
  `uvm_component_utils(ram_write_read_test)

  ram_env env;
  
  function new(string name = "ram_write_read_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ram_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    ram_write_sequence write_seq;
    ram_read_sequence read_seq;
    ram_write_read_sequence write_read_seq;
    
    phase.raise_objection(this);
    
    #1; env.agent.vif.rstn = 0;
    
    #5; env.agent.vif.rstn = 1;
    `uvm_info(get_type_name(), "Starting write sequence", UVM_MEDIUM)
    
    for(int i = 0; i < 100; i++) begin
      write_read_seq = ram_write_read_sequence::type_id::create("write_read_seq", this);
      write_read_seq.is_random_b = 0;
      write_read_seq.we = 1;
      write_read_seq.addr = i;
      write_read_seq.wdata = i;
      write_read_seq.start(env.agent.sequencer);
    end
    
    for(int i = 0; i < 100; i++) begin
      write_read_seq = ram_write_read_sequence::type_id::create("write_read_seq", this);
      write_read_seq.is_random_b = 0;
      write_read_seq.we = 0;
      write_read_seq.addr = i;
      write_read_seq.start(env.agent.sequencer);
    end
    
    /*for(int i = 0; i < 150; i++) begin
      write_seq = ram_write_sequence::type_id::create("write_seq", this);
      
      write_seq.is_random_b = 0;
      write_seq.addr = i;
      write_seq.wdata = i % 255;
      write_seq.we = 1;
      write_seq.start(env.agent.sequencer);
    end
    `uvm_info(get_type_name(), "Starting read sequence", UVM_MEDIUM)
    for(int i = 0; i < 150; i++) begin
      read_seq = ram_read_sequence::type_id::create("read_seq", this);

      read_seq.is_random_b = 0;
      read_seq.addr = i;
      read_seq.we = 0;
      read_seq.start(env.agent.sequencer);    
      end*/

    phase.drop_objection(this);
  endtask

endclass: ram_test