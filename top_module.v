module top_module(input clk);
// Tin hieu giua cac khoi
wire [31:0] pc_in, pc_out;
wire [31:0] pc_plus4_outD, pc_plus4_outM;
wire [4:0] rs1, rs2, rd, rdE, rdM, rdW;
wire [31:0] rs1D, rs2D, rs1E, rs2E, rs2M;
wire [31:0] instrF, instrD, instrE;
wire [31:0] pcD, pcE, pcM;
wire [31:0] immD, immE;
wire [31:0] alumux1_out, alumux2_out;
wire [31:0] alu_out, dmem_out, wb_out, alu_outM, wb_outW;
//---pipeline add
wire [31:0] branch_target;
wire [31:0] jump_target;
wire miss_predict;
wire jump_sel;
wire bubble;
wire flushw;
wire stall_lw, stall_j;
wire not_update_pc;
// Tin hieu tu khoi control toi cac khoi con lai
wire [2:0] imm_sel;
wire [1:0] sw_sel;
wire [31:0] rs2_mux_out;
wire [31:0] rs2_memE, rs2_memM;
wire [1:0] branch_dhazardD, branch_dhazardE;
wire reg_writeD, reg_writeE, reg_writeM, reg_writeW;
wire [1:0] opAD, opAE;
wire [1:0] opBD, opBE;
wire [3:0] aluopD, aluopE;
wire dmem_selD, dmem_selE, dmem_selM;
wire [1:0] wbmux_selD, wbmux_selE, wbmux_selM;

// 20bit bus
wire [10:0] ctrl_out;


// Ket noi cac module
// FETCHING SATGE
pc_mux 	PCmux(.out(pc_in), .in0(pc_plus4_outD), .in1(branch_target), 
		.in2(jump_target), .miss_predict(miss_predict), .jmp_sel(jump_sel));

pc 	PC(.in(pc_in), .clk(clk), .not_update_pc(not_update_pc), .out(pc_out));

add_4	ADD4FT(.in(pc_out), .out(pc_plus4_outD));

IMEM	InstrMem(.inst(instrF), .PC(pc_out));

// DECODING STAGE

shiftRegF end_fetching(.instr(instrF),.pc(pc_out),.bubble(bubble),.clear(flushw),.clk(clk),.outIn(instrD),.outPC(pcD));

decoder bigDecoder(.instr(instrD), .stall(stall_lw), .sw_sel(sw_sel), .branch_dhazard(branch_dhazardD), .opA(opAD), .opB(opBD), .data_out(ctrl_out));

assign imm_sel = ctrl_out[10:8];
assign reg_writeD = ctrl_out[7];
assign aluopD = ctrl_out[6:3];
assign dmem_selD = ctrl_out[2];
assign wbmux_selD = ctrl_out[1:0];


reg_decoder regDecode(.instr(instrD), .rd(rd), .rs1(rs1), .rs2(rs2));

regfile RegFile(.clk(clk), .reset(), .write(reg_writeW), .wrAddrD(rdW), .rdAddrA(rs1), 
		.rdAddrB(rs2), .wrDataD(wb_outW), .rdDataA(rs1D), .rdDataB(rs2D));

wbmux	RS2_MUX(.out(rs2_mux_out), .in0(rs2D), .in1(alu_out), .in2(alu_outM), .sel(sw_sel));

ImmGen	ImmGen(.immSel(imm_sel), .instr(instrD), .imm(immD));

jump_control jumpUnit(.rs1(rs1D), .imm(immD), .pc(pcD), .instr(instrD), 
			.jmp_addr(jump_target), .jmp_sel(jump_sel), .j_stall(stall_j));

stall_handle_unit stallUnit( .stall_lw(stall_lw), .stall_j(stall_j), .clock(clk), .ff_stop_update(bubble), .pc_stop_update(not_update_pc));

// EXECUTING STAGE  

shiftRegD  end_decoding( .instr(instrD), .pc(pcD), .rs1(rs1D), .rs2(rs2D), .rs2_mem(rs2_mux_out), 
			.imm(immD), .opA(opAD), .opB(opBD), .rd(rd), 
			.ALUsel(aluopD), .WBsel(wbmux_selD), .branch_dhazard(branch_dhazardD), .RegWEn(reg_writeD), 
			.memRW(dmem_selD), .clear(flushw), .clk(clk), .outIn(instrE),
			.outPC(pcE), .outRs1(rs1E), .outALUsel(aluopE),
			.outRs2(rs2E), .outRs2_mem(rs2_memE), .outOpA(opAE), .outOpB(opBE), 
			.outWBsel(wbmux_selE), .outBranch_dhazard(branch_dhazardE), .outRegWEn(reg_writeE), 
			.outMemRW(dmem_selE), .outRd(rdE), .outImm(immE)); 

opt_mux	ALUmux1(.op0(rs1E), .op1(pcE), .op2(alu_outM), .op3(wb_outW), .op_sel(opAE), .out(alumux1_out));

opt_mux	ALUmux2(.op0(rs2E), .op1(immE), .op2(alu_outM), .op3(wb_outW), .op_sel(opBE), .out(alumux2_out));

ALU	ALU(.alu_sel(aluopE), .dataA(alumux1_out), .dataB(alumux2_out), .alu_out(alu_out));

branch_unit branch_check( .rs1(rs1E), .rs2(rs2E), .instr(instrE), .address(alu_out), .alu_fb(alu_outM), .branch_dhazard(branch_dhazardE), .clk(clk), .flush(flushw), 
	      .miss_predict(miss_predict), .target(branch_target));

// MEMORY STAGE

shiftRegE end_exEcuting( .alu(alu_out), .pc(pcE), .rs2(rs2_memE), .rd(rdE), .WBsel(wbmux_selE), 
			.RegWEn(reg_writeE), .memRW(dmem_selE), .clear(), .clk(clk), 
			.outALU(alu_outM), .outPC(pcM), .outRs2(rs2_memM), .outRd(rdM), 
			.outWBsel(wbmux_selM), .outRegWEn(reg_writeM), .outMemRW(dmem_selM));

DMEM	DataMem(.Addr(alu_outM), .DataW(rs2_memM), .DataR(dmem_out), .MemRW(dmem_selM), .clk(clk));

add_4	ADD4WB(.in(pcM), .out(pc_plus4_outM));

wbmux	WBMux(.out(wb_out), .in0(dmem_out), .in1(alu_outM), .in2(pc_plus4_outM), .sel(wbmux_selM));


// WRITEBACK STAGE

shiftRegW end_memory( .wb(wb_out), .rd(rdM), .RegWEn(reg_writeM), .clear(), .clk(clk), 
			.outWB(wb_outW), .outRd(rdW), .outRegWEn(reg_writeW));


endmodule 