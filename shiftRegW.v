module shiftRegW(
input [31:0] wb,
input [4:0] rd,
input RegWEn,
input clear,
input clk,
output reg [31:0] outWB,
output reg [4:0] outRd,
output reg outRegWEn
);

always @(posedge clk) begin 
if (clear) begin
	outWB = 0;
	outRd = 0;
	outRegWEn = 0;
end
else begin
	outWB = wb;
	outRd = rd;
	outRegWEn = RegWEn;
end
end

endmodule 