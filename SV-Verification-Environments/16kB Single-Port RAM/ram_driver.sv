`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_driver extends uvm_driver #(ram_seq_item);

  `uvm_component_utils(ram_driver)

  virtual ram_intf vif;

  function new(string name = "ram_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ram_intf)::get(uvm_top, "uvm_test_top", "vif", vif)) begin
      `uvm_fatal(get_type_name(), " Couldn't get interface.")
    end
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
			
      vif.we = req.we;
      vif.addr = req.addr;
      vif.wdata = req.wdata;

      @(posedge vif.clk);
      seq_item_port.item_done();
    end
  endtask: run_phase

endclass: ram_driver