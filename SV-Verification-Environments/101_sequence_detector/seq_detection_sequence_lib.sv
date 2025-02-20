`include "seq_detection_seq_item.sv"
//RESET SEQUENCE
class seq_detection_reset_sequence;
	seq_detection_seq_item seq_item;
	mailbox #(seq_detection_seq_item) seq_mbox;
	
	function new(mailbox #(seq_detection_seq_item) seq_mbox);
		this.seq_mbox = seq_mbox;
	endfunction: new
	
	virtual task body();
		seq_item = new();
		seq_item.rstn = 0;
      $display($time, " [SEQ]: Sending rstn = %0d", seq_item.rstn);
		seq_mbox.put(seq_item);
		#20;
		seq_item = new();
		seq_item.rstn = 1;
      $display($time, " [SEQ]: Sending rstn = %0d", seq_item.rstn);
		seq_mbox.put(seq_item);	
	endtask: body
endclass: seq_detection_reset_sequence

//0 SAU 1 IN FUNCTIE DE PREFERINTA
class seq_detection_constant_sequence;
	bit seq_value;
	seq_detection_seq_item seq_item;
	mailbox#(seq_detection_seq_item) seq_mbox;
	
	function new(mailbox#(seq_detection_seq_item) seq_mbox, bit seq_value);
		this.seq_mbox = seq_mbox;
		this.seq_value = seq_value;
	endfunction: new
	
	virtual task body();
		for(int i = 0; i<100; i++) begin
			seq_item = new();
			seq_item.seq_in = seq_value;
			seq_item.rstn = 1;
			seq_mbox.put(seq_item);
			#5;
		end
	endtask: body
	
endclass: seq_detection_constant_sequence

//101 SEQUENCE
class seq_detection_101_sequence;
	seq_detection_seq_item seq_item;
	mailbox#(seq_detection_seq_item) seq_mbox;
	virtual seq_detection_intf vif;
	
	function new(mailbox#(seq_detection_seq_item) seq_mbox, virtual seq_detection_intf vif);
		this.seq_mbox = seq_mbox;
		this.vif = vif;
	endfunction: new
	
	virtual task body();
		$display($time, " Starting 101 sequence.");
		for(int i = 1; i<=100; i++) begin
			@(negedge vif.clk);
			seq_item = new();
			if(i % 2 == 0) begin
				seq_item.seq_in = 0;
				seq_item.rstn = 1;
				seq_mbox.put(seq_item);
				#5;
			end
			else begin
				seq_item.seq_in = 1;
				seq_item.rstn = 1;
				seq_mbox.put(seq_item);
				#5;
			end
		end
		$display($time, " Finished 101 sequence.");
	endtask: body
	
endclass: seq_detection_101_sequence

//RANDOM SEQUENCE
class seq_detection_rand_sequence;
	seq_detection_seq_item seq_item;
	mailbox#(seq_detection_seq_item) seq_mbox;
	
	function new(mailbox#(seq_detection_seq_item) seq_mbox);
		this.seq_mbox = seq_mbox;
	endfunction: new
	
	virtual task body();
		for(int i = 0; i<50; i++) begin
			seq_item = new();
			assert(seq_item.randomize() with {seq_item.rstn == 1;}) 
				else begin 
					$error($time, " Randomization failed!");
					$stop;
				end
			seq_mbox.put(seq_item);
			#5;
		end
	endtask: body
	
endclass: seq_detection_rand_sequence