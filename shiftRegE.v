module shiftRegE(
input [31:0] alu,
input [31:0] pc,
input [31:0] rs2,
input [4:0] rd,
input [1:0] WBsel,
input RegWEn,
input memRW,
input clear,
input clk,
output reg [31:0] outALU,
output reg [31:0] outPC,
output reg [31:0] outRs2,
output reg [4:0] outRd,
output reg [1:0] outWBsel,
output reg outRegWEn,
output reg outMemRW
);

always @(posedge clk) begin
if (clear) begin
	outALU = 0;
	outPC = 0;
	outRs2 = 0;
	outRd = 0;
	outWBsel = 0;
	outRegWEn = 0;
	outMemRW = 0;
end
else begin
	outALU = alu;
	outPC = pc;
	outRs2 = rs2;
	outRd = rd;
	outWBsel = WBsel;
	outRegWEn = RegWEn;
	outMemRW = memRW;
end
end
endmodule 