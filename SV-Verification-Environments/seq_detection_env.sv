`include "seq_detection_agent.sv"
`include "seq_detection_scoreboard.sv"

class seq_detection_env;
	seq_detection_agent agt;
	seq_detection_scoreboard sco;
	
	function new(virtual seq_detection_intf vif);
		agt = new(vif);
		sco = new();
	endfunction: new
	
	task run();
		agt.run();
		sco.run();
	endtask: run
	
endclass: seq_detection_env