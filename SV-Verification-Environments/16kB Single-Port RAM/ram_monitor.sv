`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_monitor extends uvm_monitor;

  `uvm_component_utils(ram_monitor)

  virtual ram_intf vif;
  uvm_analysis_port#(ram_seq_item) mon_port;
  ram_seq_item mon_item;

  covergroup ram_cov with function sample(bit [15:0] addr, bit [7:0] wdata, bit [7:0] rdata);
    option.per_instance = 1;
    addr_cp: coverpoint addr {
      bins addr[50] = {[0:16383]};
    }
    wdata_cp: coverpoint wdata {
      bins wdata[10] = {[0:255]};
    }
    rdata_cp: coverpoint rdata {
      bins rdata[10] = {[0:255]};
    }
  endgroup

  function new(string name = "ram_monitor", uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
    ram_cov = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ram_intf)::get(uvm_top, "uvm_test_top", "vif", vif)) begin
      `uvm_fatal(get_type_name(), " Couldn't get interface.")
    end
    mon_item = ram_seq_item::type_id::create("mon_item", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), " Starting the run() phase", UVM_MEDIUM)
    forever begin
      @(posedge vif.clk);
      //`uvm_info(get_type_name(), " Data access detected", UVM_NONE)
      
      mon_item.we = vif.we;
      mon_item.addr = vif.addr;
      mon_item.wdata = vif.wdata;
      if (!vif.we)
        #1;  
      mon_item.rdata = vif.rdata;

      mon_port.write(mon_item);
      ram_cov.sample(mon_item.addr, mon_item.wdata, mon_item.rdata);
    end
  endtask

  function void report_phase(uvm_phase phase);
  	super.report_phase(phase);
      	`uvm_info(get_type_name(), $sformatf("\nTotal Coverage: %.2f\n Address Coverage: %.2f\n Wdata Coverage: %.2f\n Rdata Coverage: %.2f", ram_cov.get_inst_coverage(), ram_cov.addr_cp.get_inst_coverage(),ram_cov.wdata_cp.get_inst_coverage(), ram_cov.rdata_cp.get_inst_coverage()),UVM_NONE)
  endfunction

endclass: ram_monitor
