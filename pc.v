// PC module
module pc(in, clk, not_update_pc, out);
input [31:0] in; 
input clk;
input not_update_pc;
output reg [31:0] out;
reg temp = 0;

reg [31:0] last_pc;

always @(posedge clk) begin
	if (temp == 0) begin
		out = temp;
		temp = 1;
	end
	else begin
		last_pc = out;
		out = in;
		if (not_update_pc == 1) out = last_pc;
	end
end
	
endmodule 