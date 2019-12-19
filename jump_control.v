module jump_control(
input [31:0] rs1,
input [31:0] imm,
input [31:0] pc,
input [31:0] instr,
output reg [31:0] jmp_addr,
output reg jmp_sel,
output reg j_stall);

always @*
begin
if (instr[6:2] == 5'b11011) //JAL
begin
	jmp_addr = pc+imm;
	jmp_sel = 1;
	j_stall = 1;
end
else if (instr[6:2] == 5'b11001) //JALR
begin
	jmp_addr = rs1+imm;
	jmp_sel = 1;
	j_stall = 1;
end
else begin
	jmp_sel = 0;
	j_stall = 0;
end
end

endmodule
