module opt_mux(
	input 	[31:0] op0,
	input 	[31:0] op1,
	input 	[31:0] op2,
	input 	[31:0] op3,
	input 	[1:0]  op_sel,
	output	reg [31:0] out);

always @* begin
	case (op_sel)
	2'b00: out = op0;
	2'b01: out = op1;
	2'b10: out = op2;
	2'b11: out = op3;
	endcase
end
	
endmodule 