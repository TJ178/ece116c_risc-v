module inst_decode(inst1, inst2, rs1_1, rs2_1, rd_1, imm1, aluctrl1, memrd1, memtoreg1, memwr1, alusrc1, regwr1,
                                 rs1_2, rs2_2, rd_2, imm2, aluctrl2, memrd2, memtoreg2, memwr2, alusrc2, regwr2);
	input[31:0] inst1, inst2;
	output[31:0] imm1, imm2;
	output[4:0] rs1_1, rs1_2, rs2_1, rs2_2, rd_1, rd_2;
	output memrd1, memrd2, memtoreg1, memtoreg2, memwr1, memwr2, alusrc1, alusrc2, regwr1, regwr2;
	output[3:0] aluctrl1, aluctrl2;

	wire[1:0] aluop1, aluop2;
	wire[2:0] func3_1, func3_2;

	controller inst1_ctrl(inst1[6:0], memrd1, memtoreg1, aluop1, memwr1, alusrc1, regwr1);
	controller inst2_ctrl(inst2[6:0], memrd2, memtoreg2, aluop2, memwr2, alusrc2, regwr2);

	immGen inst1_immGen(inst1, imm1, rs1_1, rs2_1, rd_1, func3_1);
	immGen inst2_immGen(inst2, imm2, rs1_2, rs2_2, rd_2, func3_2);

	wire [3:0] alu_ctrl_out1, alu_ctrl_out2;

	alu_controller inst1_aluctrl(aluop1, inst1[30], func3_1, alu_ctrl_out1);
	alu_controller inst2_aluctrl(aluop2, inst2[30], func3_2, alu_ctrl_out2);
	
	assign aluctrl1 = inst1 ? alu_ctrl_out1 : 4'b0;
	assign aluctrl2 = inst2 ? alu_ctrl_out2 : 4'b0;


endmodule