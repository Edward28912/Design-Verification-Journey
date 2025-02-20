`include "seq_detection_intf.sv"
`include "seq_detection_driver.sv"
`include "seq_detection_monitor.sv"
`include "seq_detection_sequencer.sv"

class seq_detection_agent;
	seq_detection_driver drv;
	seq_detection_sequencer sequencer;
	seq_detection_monitor mon;
	
	virtual seq_detection_intf vif;
	mailbox #(seq_detection_seq_item) drv_mbox;
	mailbox #(seq_detection_seq_item) seq_mbox;
	mailbox #(seq_detection_seq_item) mon_mbox;
	mailbox #(seq_detection_seq_item) sco_mbox;
	
	function new(virtual seq_detection_intf vif);
		this.vif = vif;
		drv_mbox = new();
		seq_mbox = new();
		mon_mbox = new();
		sco_mbox = new();
		drv = new(drv_mbox, vif);
		sequencer = new(seq_mbox, drv_mbox, sco_mbox);
		mon = new(mon_mbox, vif);
	endfunction: new
	
 	task run();
		fork
			drv.run();
			sequencer.run();
			mon.run();
		join_none
	endtask: run
	
endclass: seq_detection_agent