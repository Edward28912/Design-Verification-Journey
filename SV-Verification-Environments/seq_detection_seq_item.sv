class seq_detection_seq_item;
	//INPUT SIGNALS
	bit rstn;
	rand bit seq_in;
	//OUTPUT SIGNALS
	logic detected;	
	logic [7:0] no_of_seq;	
	
endclass: seq_detection_seq_item