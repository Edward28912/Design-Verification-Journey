`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_driver.sv"
`include "ram_monitor.sv"
`include "ram_sequencer.sv"

class ram_agent extends uvm_agent;
	
	`uvm_component_utils(ram_agent)

  ram_driver driver;
  ram_monitor monitor;
  ram_sequencer sequencer;
  virtual ram_intf vif;

  function new(string name = "ram_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ram_intf)::get(uvm_top, "uvm_test_top", "vif", vif)) begin
      `uvm_fatal(get_type_name(), " Couldn't get interface.")
    end
    driver = ram_driver::type_id::create("driver", this);
    monitor = ram_monitor::type_id::create("monitor", this);
		sequencer = ram_sequencer::type_id::create("sequencer", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
		driver.seq_item_port.connect(sequencer.seq_item_export);
    driver.vif = vif;
    monitor.vif = vif;
  endfunction: connect_phase

endclass: ram_agent
