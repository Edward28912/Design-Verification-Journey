class seq_detection_sequencer;
	mailbox #(seq_detection_seq_item) seq_mbox;
	mailbox #(seq_detection_seq_item) drv_mbox;
	mailbox #(seq_detection_seq_item) sco_mbox;
	
	function new(mailbox #(seq_detection_seq_item) seq_mbox, mailbox #(seq_detection_seq_item) drv_mbox,
		mailbox #(seq_detection_seq_item) sco_mbox);
		this.seq_mbox = seq_mbox;
		this.drv_mbox = drv_mbox;
		this.sco_mbox = sco_mbox;
	endfunction: new
	
	virtual task run();
		seq_detection_seq_item seq_item;
		forever begin
			seq_mbox.get(seq_item);
//          $display($time, " [SEQUENCER] Received: rstn=%0d, seq_in=%0d", seq_item.rstn, seq_item.seq_in);
			drv_mbox.put(seq_item);
			sco_mbox.put(seq_item);
		end
	endtask: run
	
endclass: seq_detection_sequencer