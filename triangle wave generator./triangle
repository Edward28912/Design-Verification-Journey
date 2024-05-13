module triangle(
	input clk,
	input reset_n,
	input push,
	input [3:0] din,
	output [3:0] bcd
);

	wire [3:0] limitl, limith;
	wire dir;
	wire cen;

	fsm_ctrl FSM_CTRL0(
		.clk		(clk),
		.reset_n	(reset_n),
		.push		(push),
		.din		(din),
		.limith		(limith),
		.limitl		(limitl)
	);

	fsm_cnt FSM_CNT0(
		.clk		(clk),
		.reset_n	(reset_n),
		.limith		(limith),
		.limitl		(limitl),
		.value		(bcd),	
		.dir		(dir)
	);

	pulsegen PULSEGEN0(
		.clk		(clk),
		.reset_n	(reset_n),
		.pulse		(cen)
	);

	cnt_bcd	CNT_BCD0(
		.clk		(clk),
		.reset_n	(reset_n),
		.cen		(cen),
		.dir		(dir),
		.value		(bcd)
	);

endmodule
