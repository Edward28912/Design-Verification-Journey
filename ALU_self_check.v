`timescale 1ns / 1ps

module ALU #(parameter BUS_WIDTH = 8) (
	input [BUS_WIDTH -1:0] a,
	input [BUS_WIDTH -1:0] b,
	input carry_in,
	input [3:0] opcode,
	output reg [BUS_WIDTH -1:0] y,
	output reg carry_out,
	output reg borrow,
	output zero, 
	output parity,
	output reg invalid_op
);

	localparam OP_ADD		= 1;
	localparam OP_ADD_CARRY = 2;
	localparam OP_SUB		= 3;
	localparam OP_INC		= 4;
	localparam OP_DEC		= 5;
	localparam OP_AND		= 6;
	localparam OP_NOT		= 7;
	localparam OP_ROL		= 8;
	localparam OP_ROR		= 9;
	
	always@(*) begin
	
		y = 0; carry_out = 0;	borrow = 0;	invalid_op = 0;
	
		case(opcode)
		
			OP_ADD		:	y = a + b;
			OP_ADD_CARRY:	{carry_out, y} = a + b + carry_in;
			OP_SUB		:	{borrow, y} = a - b;
			OP_INC		:	{carry_out, y} = a + 1'b1;
			OP_DEC		:	{borrow, y}	= a - 1'b1;
			OP_AND		:	y = a & b;
			OP_NOT		: 	y = ~a;
			OP_ROL		:	y = {a[BUS_WIDTH -2:0], a[BUS_WIDTH-1]};
			OP_ROR 		:	y = {a[0], a[BUS_WIDTH -1:1]};
			default		:	begin invalid_op = 1;	y = 0;	borrow = 0;	carry_out = 0; end
		
		endcase
	
	end

	assign zero = (y == 0);
	assign parity = ^y;

endmodule


module ALU_tb();

	parameter BUS_WIDTH = 8;
	reg [3:0] opcode;
	reg [BUS_WIDTH -1:0] a, b;
	reg carry_in;
	wire [BUS_WIDTH -1:0] y;
	wire carry_out;
	wire borrow;
	wire invalid_op;
	wire zero;
	wire parity;

	localparam OP_ADD		= 1;
	localparam OP_ADD_CARRY = 2;
	localparam OP_SUB		= 3;
	localparam OP_INC		= 4;
	localparam OP_DEC		= 5;
	localparam OP_AND		= 6;
	localparam OP_NOT		= 7;
	localparam OP_ROL		= 8;
	localparam OP_ROR		= 9;

	integer success_count = 0, error_count = 0, test_count = 0, i = 0;

ALU #(.BUS_WIDTH(BUS_WIDTH)) DUT (
	.a(a),
	.b(b),
	.carry_in(carry_in),
	.carry_out(carry_out),
	.opcode(opcode),
	.borrow(borrow),
	.zero(zero),
	.parity(parity),
	.invalid_op(invalid_op),
	.y(y)
);

	function [BUS_WIDTH +4:0] ALU_model(
		input [BUS_WIDTH -1:0] a,
		input [BUS_WIDTH -1:0] b,
		input carry_in,
		input [3:0] opcode
	);
	
		reg [BUS_WIDTH -1:0] y;
		reg borrow;
		reg zero;
		reg parity;
		reg invalid_op;
		reg carry_out;
		
		begin
		
			y = 0; carry_out = 0;	borrow = 0;	invalid_op = 0;
	
		case(opcode)
		
			OP_ADD		:	{carry_out, y} = a + b;
			OP_ADD_CARRY:	{carry_out, y} = a + b + carry_in;
			OP_SUB		:	{borrow, y} = a - b;
			OP_INC		:	{carry_out, y} = a + 1'b1;
			OP_DEC		:	{borrow, y}	= a - 1'b1;
			OP_AND		:	y = a & b;
			OP_NOT		: 	y = ~a;
			OP_ROL		:	y = {a[BUS_WIDTH -2:0], a[BUS_WIDTH-1]};
			OP_ROR 		:	y = {a[0], a[BUS_WIDTH -1:1]};
			default		:	begin invalid_op = 1;	y = 0;	borrow = 0;	carry_out = 0; end
		
		endcase
		
		assign zero = (y == 0);
		assign parity = ^y;
		
		ALU_model = {invalid_op, parity, zero, borrow, carry_out, y};
		
		end
	
	endfunction

	task compare_data(input [BUS_WIDTH+4:0] ALU_expected, input [BUS_WIDTH+4:0] ALU_observed);
	
		begin
		
			if (ALU_expected === ALU_observed) begin
			
				$display($time, " SUCCESS \t EXPECTED invalid_op=%0b, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b", 
									ALU_expected[BUS_WIDTH+4], ALU_expected[BUS_WIDTH+3], ALU_expected[BUS_WIDTH+2], ALU_expected[BUS_WIDTH+1], ALU_expected[BUS_WIDTH], ALU_expected[BUS_WIDTH-1:0]);
				$display($time, " \t OBSERVED invalid_op=%0b, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b",
									ALU_observed[BUS_WIDTH+4], ALU_observed[BUS_WIDTH+3], ALU_observed[BUS_WIDTH+2], ALU_observed[BUS_WIDTH+1], ALU_observed[BUS_WIDTH], ALU_observed[BUS_WIDTH-1:0]);
				success_count = success_count + 1;
			
			end
		
			else begin
			
				$display($time, " ERROR \t EXPECTED invalid_op=%0b, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b",
									ALU_expected[BUS_WIDTH+4], ALU_expected[BUS_WIDTH+3], ALU_expected[BUS_WIDTH+2], ALU_expected[BUS_WIDTH+1], ALU_expected[BUS_WIDTH], ALU_expected[BUS_WIDTH-1:0]);
				$display($time, " \t OBSERVED invalid_op=%0b, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b",
									ALU_observed[BUS_WIDTH+4], ALU_observed[BUS_WIDTH+3], ALU_observed[BUS_WIDTH+2], ALU_observed[BUS_WIDTH+1], ALU_observed[BUS_WIDTH], ALU_observed[BUS_WIDTH-1:0]);
				error_count = error_count + 1;
			end
			
		test_count = test_count + 1;
		
		end
	
	endtask

	initial begin
	
		for(i = 0; i < 500; i = i + 1) begin
		
			opcode 	= $random % 10'd11;
			a 		= $random;
			b 		= $random;
			carry_in= $random;
		
			#1; 	$display($time, " TEST%0d opcode = %d, a = %d, b = %d, carry_in = %d", i, opcode, a, b, carry_in);
					compare_data(ALU_model(a, b, carry_in, opcode), {invalid_op, parity, zero, borrow, carry_out, y});
		
			#2;
			
		end
	
		$display($time, " TESTS DONE: %d, success_count = %d, error_count = %d", i, success_count, error_count);
		#10 $stop;
	
	end

endmodule