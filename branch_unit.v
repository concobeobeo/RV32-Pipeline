module branch_unit(
	input	[31:0] rs1,
	input	[31:0] rs2,
	input   [31:0] instr,
	input [31:0] address,
	input [31:0] alu_fb,
	input [1:0] branch_dhazard,
	input clk,
	output	reg flushF,
	output	reg flushD,
	output  reg miss_predict,
	output  reg [31:0] target);
	
	// Chu thich:
	// "flush" tich cuc muc CAO, noi voi Clear cua FLIPFLOP.
	// "mis_predict" tich cuc muc CAO, noi voi MUX truoc PC.

	// Mo ta hoat dong:
	// Luon KHONG NHAY. 
	// <=> Du doan DIEU KIEN NHAY la SAI.
	// De kiem tra dieu kien nhay thuc te, rs1 so sanh voi rs2 o stage EX.
	// => Neu thuc te dieu kien nhay DUNG.
	// => Doan sai.
	// => Neu thuc te dieu kien nhay SAI.
	// => Doan dung.

	// Neu "Doan sai", mis_predict tich cuc. FLUSH toan bo, nhay den PC moi.
	// Neu "Doan dung", PC = PC + 4, thuc hien tiep nhu binh thuong.
reg last_flush;
always @(*)
begin
if (instr[6:2] == 5'b11000)
begin
	if (branch_dhazard == 0) begin
		if (instr[14:12] == 3'b000) // Branch Equal
		begin
			if (rs1 == rs2)	
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
			else if (instr[14:12] == 3'b001) // Branch Not Equal
		begin
			if (rs1 != rs2) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b100) // Branch Less Than
		begin
			if (rs1 < rs2) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b101) // Branch Less Than Unsigned
		begin
			if ($unsigned(rs1) < $unsigned(rs2))
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else begin
			miss_predict = 0;
			flushF = 0;
			flushD = 0;
		end
		
	end	
	else if (branch_dhazard == 1) begin
		if (instr[14:12] == 3'b000) // Branch Equal
		begin
			if (alu_fb == rs2)	
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
			else if (instr[14:12] == 3'b001) // Branch Not Equal
		begin
			if (alu_fb != rs2) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b100) // Branch Less Than
		begin
			if (alu_fb < rs2) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b101) // Branch Less Than Unsigned
		begin
			if ($unsigned(alu_fb) < $unsigned(rs2))
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else begin
			miss_predict = 0;
			flushF = 0;
			flushD = 0;
		end
	end	
	else if (branch_dhazard == 2) begin
		if (instr[14:12] == 3'b000) // Branch Equal
		begin
			if (rs1 == alu_fb)	
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
			else if (instr[14:12] == 3'b001) // Branch Not Equal
		begin
			if (rs1 != alu_fb) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b100) // Branch Less Than
		begin
			if (rs1 < alu_fb) 
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else if (instr[14:12] == 3'b101) // Branch Less Than Unsigned
		begin
			if ($unsigned(rs1) < $unsigned(alu_fb))
			begin
			target = address;
			miss_predict = 1;
			flushF = 1;
			flushD = 1;
			end
		end
		else begin
			miss_predict = 0;
			flushF = 0;
			flushD = 0;
		end
	end

end
else begin
	target = 0;
	miss_predict = 0;
	last_flush = flushF;
	flushF = 0;
	flushD = 0;
end 
end
always @(negedge clk) 
begin
	if (last_flush == 1 && flushF == 1) 
	begin
		flushF = 0; 
		flushD = 0;
	end 
	last_flush = flushF;
end
endmodule 
