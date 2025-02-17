`timescale 1ns / 1ps
`include "seq_detection_intf.sv"
`include "seq_detection_env.sv"
module seq_detection_tb();
  bit clk;
  mailbox #(seq_detection_seq_item) seq_mbox;
  mailbox #(seq_detection_seq_item) drv_mbox;
  mailbox #(seq_detection_seq_item) mon_mbox;
  mailbox #(seq_detection_seq_item) sco_mbox;
  seq_detection_env env;
  seq_detection_reset_sequence reset_sequence;
  seq_detection_constant_sequence one_sequence;
  seq_detection_101_sequence onezeroone_sequence;

  seq_detection_intf my_intf(clk);
    
  seq_detection DUT(
    .clk        (my_intf.clk),
    .rstn       (my_intf.rstn),
    .seq_in     (my_intf.seq_in),
    .detected   (my_intf.detected),
    .no_of_seq  (my_intf.no_of_seq)
  );
    
	initial begin
		clk = 0;
		forever begin
			clk = ~clk;
			#5;
		end
	end
  
  initial begin
    drv_mbox = new();
    seq_mbox = new();
    mon_mbox = new();
    sco_mbox = new();
    env = new(my_intf);
//    reset_sequence = new(seq_mbox);
//    one_sequence = new(seq_mbox, 1);
    onezeroone_sequence = new(seq_mbox, my_intf);
    onezeroone_sequence.vif = my_intf;
    env.agt.drv_mbox = drv_mbox;
    env.agt.seq_mbox = seq_mbox;
    env.agt.mon_mbox = mon_mbox;
    env.agt.drv.drv_mbox = drv_mbox;
    env.agt.sequencer.drv_mbox = drv_mbox;
    env.agt.sequencer.seq_mbox = seq_mbox;
    env.agt.sequencer.sco_mbox = sco_mbox;
    env.agt.mon.mon_mbox = mon_mbox;
    env.sco.mon_mbox = mon_mbox;
    env.sco.seq_mbox = sco_mbox;
  end
  
  initial begin 
  	my_intf.rstn = 0;
  	#20;
  	my_intf.rstn = 1;
    #5;
  	fork
//  		one_sequence.body();
//  		reset_sequence.body();
			onezeroone_sequence.body();
  		env.run();
    join_none
  	
  	#4999; $stop;
  	
  end
    
endmodule