class seq_detection_scoreboard;
	mailbox #(seq_detection_seq_item) mon_mbox;
	mailbox #(seq_detection_seq_item) seq_mbox;
	bit [1:0] prev_bits;
	bit [7:0] exp_no_of_seq;
	bit exp_detected;
	bit detected_flag;
	bit no_of_seq_flag;
	
	function new();
		this.prev_bits = 2'b00;
		this.exp_no_of_seq = 8'b0000_0000;
		this.exp_detected = 1'b0;
		this.detected_flag = 0;
		this.no_of_seq_flag = 0;
	endfunction: new
	
	task run();
		seq_detection_seq_item exp_item, act_item;
		forever begin
			mon_mbox.get(act_item);
			seq_mbox.get(exp_item);
			exp_detected = 0;
			
			if(no_of_seq_flag) begin
				exp_no_of_seq += 1;
				no_of_seq_flag = 0;
			end
			
			if (detected_flag) begin
				no_of_seq_flag = 1;
				exp_detected = 1'b1;
				detected_flag = 1'b0;
			end
			
			if({prev_bits, exp_item.seq_in} == 3'b101)
				detected_flag = 1'b1;
				
			prev_bits = {prev_bits[0], exp_item.seq_in};	
			if((exp_detected !== act_item.detected) || (exp_no_of_seq !== act_item.no_of_seq)) begin
				$display($time, " [SCO] MISMATCH: Expected (detected=%0b, no_of_seq=%0d), Got (detected=%0b, no_of_seq=%0d)", 
               exp_detected, exp_no_of_seq, act_item.detected, act_item.no_of_seq);
      end else begin
        $display($time, " [SCO] MATCH: detected=%0b, no_of_seq=%0d", 
               act_item.detected, act_item.no_of_seq);
			end 
		end
	endtask: run
	
endclass: seq_detection_scoreboard