`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ram_agent.sv"
`include "ram_scoreboard.sv"

class ram_env extends uvm_env;
	`uvm_component_utils(ram_env)

  ram_agent agent;
  ram_scoreboard scoreboard;

  function new(string name = "vpc_dig_ram_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = ram_agent::type_id::create("ram_agent", this);
    scoreboard = ram_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
		scoreboard.p_env = this;
		agent.monitor.mon_port.connect(scoreboard.sb_port);
  endfunction
	
endclass: ram_env
