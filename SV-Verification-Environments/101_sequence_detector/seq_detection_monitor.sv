class seq_detection_monitor;
  virtual seq_detection_intf vif;
  mailbox #(seq_detection_seq_item) mon_mbox;

  function new(mailbox #(seq_detection_seq_item) mon_mbox, virtual seq_detection_intf vif);
    this.mon_mbox = mon_mbox;
    this.vif = vif;
  endfunction

  task run();
    seq_detection_seq_item mon_item;

    forever begin
      @(posedge vif.clk);
				mon_item = new();
				mon_item.rstn = vif.rstn;
				mon_item.seq_in = vif.seq_in;
				mon_item.detected = vif.detected;
				mon_item.no_of_seq = vif.no_of_seq;
					
				mon_mbox.put(mon_item);
				$display($time, " [MON] Observed: rstn=%0b, seq_in=%0b, detected=%0b, no_of_seq=%0d",
					vif.rstn, vif.seq_in, vif.detected, vif.no_of_seq);
      end
  endtask
endclass
