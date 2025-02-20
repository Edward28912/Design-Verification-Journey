//`include "seq_detection_seq_item.sv"
class seq_detection_driver;
	virtual seq_detection_intf vif;
	mailbox #(seq_detection_seq_item) drv_mbox;
	
	function new(mailbox #(seq_detection_seq_item) drv_mbox, virtual seq_detection_intf vif);
		this.drv_mbox = drv_mbox;
		this.vif = vif;
	endfunction: new
	
	virtual task run();
		seq_detection_seq_item drv_item;
		forever begin
			drv_mbox.get(drv_item);
			vif.rstn = drv_item.rstn;
			vif.seq_in = drv_item.seq_in;
			$display($time, " [DRV] Driving rstn = %0d, seq_in = %0d", drv_item.rstn, drv_item.seq_in);
		end
	endtask: run
	
endclass: seq_detection_driver