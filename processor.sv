module processor(clk, pc, f_eof);

	input clk;
	output reg [31:0] pc = 32'b0;
	output f_eof;
	
	//fetch
	
	wire[31:0] f_inst1, f_inst2;
	wire f_eof;
	reg[31:0] fr_inst1, fr_inst2;
	reg fr_eof = 0;
	
	inst_fetch fetch(clk, pc, f_inst1, f_inst2, f_eof);
	
	//decode
	
	wire[4:0] d_rs1_1, d_rs2_1, d_rd_1, d_rs1_2, d_rs2_2, d_rd_2;
	wire[31:0] d_imm1, d_imm2;
	wire[3:0] d_aluctrl1, d_aluctrl2;
	wire d_memrd1, d_memtoreg1, d_memwr1, d_alusrc1, d_regwr1;
	wire d_memrd2, d_memtoreg2, d_memwr2, d_alusrc2, d_regwr2;
	
	reg[4:0] dr_rs1_1, dr_rs2_1, dr_rd_1, dr_rs1_2, dr_rs2_2, dr_rd_2;
	reg[31:0] dr_imm1, dr_imm2;
	reg[3:0] dr_aluctrl1, dr_aluctrl2;
	reg dr_memrd1, dr_memtoreg1, dr_memwr1, dr_alusrc1, dr_regwr1;
	reg dr_memrd2, dr_memtoreg2, dr_memwr2, dr_alusrc2, dr_regwr2;
	
	inst_decode decode(fr_inst1, fr_inst2, d_rs1_1, d_rs2_1, d_rd_1, d_imm1, d_aluctrl1, d_memrd1, d_memtoreg1, d_memwr1, d_alusrc1, d_regwr1,
														d_rs1_2, d_rs2_2, d_rd_2, d_imm2, d_aluctrl2, d_memrd2, d_memtoreg2, d_memwr2, d_alusrc2, d_regwr2);
											
											
	//rename
	
	wire[5:0] r_p1_1, r_p2_1, r_pd_1, r_p1_2, r_p2_2, r_pd_2, r_old_pd_1, r_old_pd_2;
	wire[5:0] reg_free_1, reg_free_2; //placeholder
	wire free_valid_1, free_valid_2; //placeholder
	
	reg[5:0] rr_p1_1, rr_p2_1, rr_pd_1, rr_p1_2, rr_p2_2, rr_pd_2, rr_old_pd_1, rr_old_pd_2;
	
	reg[31:0] rr_imm1, rr_imm2;
	reg[3:0] rr_aluctrl1, rr_aluctrl2;
	reg rr_memrd1, rr_memtoreg1, rr_memwr1, rr_alusrc1, rr_regwr1;
	reg rr_memrd2, rr_memtoreg2, rr_memwr2, rr_alusrc2, rr_regwr2;
	
	rename rn(clk, reg_free_1, free_valid_1, reg_free_2, free_valid_2, dr_rs1_1, dr_rs2_1, dr_rd_1, r_p1_1, r_p2_1, r_pd_1,
										dr_rs1_2, dr_rs2_2, dr_rd_2, r_p1_2, r_p2_2, r_pd_2, r_old_pd_1, r_old_pd_2);
	
	//reservation station
	
	reg [5:0] regFw1, regFw2, regFw3;
	reg [31:0] regFWData1, regFWData2, regFWData3;
	wire[3:0] rob_tail;
	reg [139:0] issued[2:0];

	reg[31:0] re_imm1, re_imm2;
	reg[3:0] re_aluctrl1, re_aluctrl2;
	reg re_memrd1, re_memtoreg1, re_memwr1, re_alusrc1, re_regwr1;
	reg re_memrd2, re_memtoreg2, re_memwr2, re_alusrc2, re_regwr2;
	
	/*
    Reservation Station Mapping
    0: Use Bit
    6-1: rd
    12-7: rs1
    13: rs1 ready
    19-14: rs2
    20: rs2 ready
    24-21: ROB index
    26-25: FU index
    27: memRead
    28: memToReg
    29: memWrite
    30: ALUSrc
    31: regWrite
    63-32: immediate
    67-64: ALUCtr 
    68 : Forwarded Data Indicator rs1
    100-69: Forwarded Data rs1
    101: Forwarded Data Indictor rs2
    133-102: Forwarded Data rs2
    */
	
	rs reservationStation(rr_p1_1, rr_p2_1, rr_pd_1, rr_memrd1, rr_memtoreg1, rr_memwr1, rr_alusrc1, rr_regwr1, rr_imm1, rr_aluctrl1,  
						  rr_p1_2, rr_p2_2, rr_pd_2, rr_memrd2, rr_memtoreg2, rr_memwr2, rr_alusrc2, rr_regwr2, rr_imm2, rr_aluctrl2,
						  rob_tail, regFw1, regFw2, regFw3, regFWData1, regFWData2, regFWData3, clk, issued, rr_old_pd_1, rr_old_pd_2);
						  
	wire [5:0] alu1_s1, alu1_s2, alu1_dest, alu2_s1, alu2_s2, alu2_dest, mem_s1, mem_s2, mem_dest;
	wire[31:0] alu1_s1_d, alu1_s2_d, alu2_s1_d, alu2_s2_d, mem_s1_d, mem_s2_d;
	wire alu1_en, alu2_en;
	
	wire wren_reg1, wren_reg2, wren_reg3;
	wire [31:0] wr_d1, wr_d2, wr_d3;
	wire [5:0] wr_reg1, wr_reg2, wr_reg3;
	
	regFile RegFile(alu1_s1, alu1_s2, alu2_s1, alu2_s2, mem_s1, mem_s2, 
					wr_reg1, free_valid_1, wr_reg2, free_valid_2, wr_reg3, 1'b0, 
					wr_d1, wr_d2, wr_d3, 
					alu1_s1_d, alu1_s2_d, alu2_s1_d, alu2_s2_d, mem_s1_d, mem_s2_d);
	
	
	//always @ (posedge clk) begin
		assign alu1_s1 = issued[0][12:7];
		assign alu1_s2 = issued[0][19:14];
		assign alu1_en = issued[0][0];
		//rfrd_1  = issued[0][6:1];
		assign alu2_s1 = issued[1][12:7];
		assign alu2_s2 = issued[1][19:14];
		assign alu2_en = issued[1][0];
		//rfrd_2  = issued[1][6:1];
		assign mem_s1 = issued[2][12:7];
		assign mem_s2 = issued[2][19:14];
		//rfrd_3  = issued[2][6:1];
	//end
	

	reg[5:0] ra_old_rd1, ra_old_rd2, ra_old_rd3;
	reg[5:0] ra_rd1, ra_rd2, ra_rd3;
	reg[3:0] ra_rob_idx1, ra_rob_idx2, ra_rob_idx3;

	wire[31:0] alu1_d1, alu1_d2, alu2_d1, alu2_d2, mem_d1, mem_d2;

	assign alu1_d1 = issued[0][68] ? issued[0][100:69] : alu1_s1_d;
	//ALUSrc 0 is register, 1 is immediate. Check if forwarded, if not, either immediate or register
	assign alu1_d2 = issued[0][101] ? issued[0][133:102] : ( (issued[0][30]) ? issued[0][63:32] : alu1_s2_d);
	wire fwd_alu1_d2 = issued[0][101] && issued[0][30];

	assign alu2_d1 = issued[1][68] ? issued[1][100:69] : alu2_s1_d;
	//ALUSrc 0 is register, 1 is immediate. Check if forwarded, if not, either immediate or register
	assign alu2_d2 = issued[1][101] ? issued[1][133:102] : ( (issued[1][30]) ? issued[1][63:32] : alu2_s2_d);

	assign mem_d1 = issued[2][68] ? issued[2][100:69] : mem_s1_d;
	//ALUSrc 0 is register, 1 is immediate. Check if forwarded, if not, either immediate or register
	assign mem_d2 = issued[2][101] ? issued[2][133:102] :  mem_s2_d;

	wire[31:0] alu1_out, alu2_out, mem_out;

	alu alu1(alu1_en, alu1_d1, alu1_d2, issued[0][67:64], alu1_out);
	alu alu2(alu2_en, alu2_d1, alu2_d2, issued[1][67:64], alu2_out);
	ram mem(mem_d1, mem_d2, issued[2][63:32], issued[2][27], issued[2][29], mem_out);

	//buffer between FU's and complete
	reg[31:0] r_alu1_out, r_alu2_out, r_mem_out;
	reg[3:0] r_rob_idx1, r_rob_idx2, r_rob_idx3;
	reg[3:0] re_rob_idx1, re_rob_idx2, re_rob_idx3;
	reg[5:0] r_rd1, r_rd2, r_rd3, r_old_rd1, r_old_rd2, r_old_rd3;
	reg r_valid1, r_valid2, r_valid3;


	//complete


	//retire 

	rob reorderbuffer(r_rd1, r_rd2, r_rd3, r_old_rd1, r_old_rd2, r_old_rd3, r_alu1_out, r_alu2_out, r_mem_out, r_rob_idx1, r_rob_idx2, r_rob_idx3, rob_tail,
            reg_free_1, free_valid_1, wr_reg1, wr_d1, reg_free_2, free_valid_2, wr_reg2, wr_d2, r_valid1, r_valid2, r_valid3);



always @ (posedge clk) begin
		//update pc
		if(~fr_eof) pc = pc + 8;
		
		//fetch stage
		fr_inst1 = f_inst1;
		fr_inst2 = f_inst2;
		fr_eof = f_eof;


		// RS -> ALU
		rr_imm1 = re_imm1;
		rr_imm2 = re_imm2;
		rr_aluctrl1 = re_aluctrl1;
		rr_aluctrl2 = re_aluctrl2;
		rr_memrd1 = re_memrd1;
		rr_memrd2 = re_memrd2;
		rr_memtoreg1 = re_memtoreg1;
		rr_memtoreg2 = re_memtoreg2;
		rr_memwr1 = re_memwr1;
		rr_memwr2 = re_memwr2;
		rr_alusrc1 = re_alusrc1;
		rr_alusrc2 = re_alusrc2;
		rr_regwr1 = re_regwr1;
		rr_regwr2 = re_regwr2;

		// RN -> RS
		re_imm1 = dr_imm1;
		re_imm2 = dr_imm2;
		re_aluctrl1 = dr_aluctrl1;
		re_aluctrl2 = dr_aluctrl2;
		re_memrd1 = dr_memrd1;
		re_memrd2 = dr_memrd2;
		re_memtoreg1 = dr_memtoreg1;
		re_memtoreg2 = dr_memtoreg2;
		re_memwr1 = dr_memwr1;
		re_memwr2 = dr_memwr2;
		re_alusrc1 = dr_alusrc1;
		re_alusrc2 = dr_alusrc2;
		re_regwr1 = dr_regwr1;
		re_regwr2 = dr_regwr2;
		rr_old_pd_1 = r_old_pd_1;
		rr_old_pd_2 = r_old_pd_2;
		
		//decode -> RN
		dr_rs1_1 = d_rs1_1;
		dr_rs1_2 = d_rs1_2;
		dr_rs2_1 = d_rs2_1;
		dr_rs2_2 = d_rs2_2;
		dr_rd_1 = d_rd_1;
		dr_rd_2 = d_rd_2;
		dr_imm1 = d_imm1;
		dr_imm2 = d_imm2;
		dr_aluctrl1 = d_aluctrl1;
		dr_aluctrl2 = d_aluctrl2;
		dr_memrd1 = d_memrd1;
		dr_memrd2 = d_memrd2;
		dr_memtoreg1 = d_memtoreg1;
		dr_memtoreg2 = d_memtoreg2;
		dr_memwr1 = d_memwr1;
		dr_memwr2 = d_memwr2;
		dr_alusrc1 = d_alusrc1;
		dr_alusrc2 = d_alusrc2;
		dr_regwr1 = d_regwr1;
		dr_regwr2 = d_regwr2;
		
		//RN -> RS
		
		rr_p1_1 = r_p1_1;
		rr_p1_2 = r_p1_2;
		rr_p2_1 = r_p2_1;
		rr_p2_2 = r_p2_2;
		rr_pd_1 = r_pd_1;
		rr_pd_2 = r_pd_2;


		//ALU-> RETIRE
	 	r_alu1_out = alu1_out;
		r_alu2_out = alu2_out;
		r_mem_out = mem_out;
		
		//re_rob_idx1 = ra_rob_idx1;
		//re_rob_idx2 = ra_rob_idx2;
		//re_rob_idx3 = ra_rob_idx3;
		r_rd1 = issued[0][6:1];
		r_rd2 = issued[1][6:1];
		r_rd3 = issued[2][6:1];
		r_valid1 = issued[0][0];
		r_valid2 = issued[1][0];
		r_valid3 = issued[2][0];
		r_old_rd1 = ra_old_rd1;
		r_old_rd2 = ra_old_rd2;
		r_old_rd3 = ra_old_rd3;
		

		//RS-> ALU
		ra_old_rd1 = issued[0][139:134];
		ra_old_rd2 = issued[1][139:134];
		ra_old_rd3 = issued[2][139:134];
		ra_rob_idx1 = issued[0][24:21];
		ra_rob_idx2 = issued[1][24:21];
		ra_rob_idx3 = issued[2][24:21];
		ra_rd1 = issued[0][6:1];
		ra_rd2 = issued[1][6:1];
		ra_rd3 = issued[2][6:1];
		r_rob_idx1 = ra_rob_idx1;
		r_rob_idx2 = ra_rob_idx2;
		r_rob_idx3 = ra_rob_idx3;

		regFw1 = r_rd1;
		regFw2 = r_rd2;
		regFw3 = r_rd3;

		regFWData1 = r_alu1_out;
		regFWData2 = r_alu2_out;
		regFWData3 = r_mem_out;

		$display($time);
            $display("issued:");
            $display("rd\trs1\tready\trs2\tready\trob\tfu\tmemrd\tmem2reg\tmemwr\talusrc\tregwr\timm\taluctr\trs1fw\trs1fwd\trs2fw\trs2fwd\toldrd");
            for(integer i = 0; i < 3; i++) begin
				$write("%d\t", issued[i][6:1]);
				$write("%d\t", issued[i][12:7]);
				$write("%b\t", issued[i][13]);
				$write("%d\t", issued[i][19:14]);
				$write("%b\t", issued[i][20]);
				$write("%d\t", issued[i][24:21]);
				$write("%d\t", issued[i][26:25]);
				$write("%b\t", issued[i][27]);
				$write("%b\t", issued[i][28]);
				$write("%b\t", issued[i][29]);
				$write("%b\t", issued[i][30]);
				$write("%b  ", issued[i][31]);
				$write("%d\t", issued[i][63:32]);
				$write("%b\t", issued[i][67:64]);
				$write("%b\t", issued[i][68]);
				$write("%d\t", issued[i][100:69]);
				$write("%b\t", issued[i][101]);
				$write("%d\t", issued[i][133:102]);
				$display("%d\t", issued[i][139:134]);
            end
            $display("\n");
		
	end

endmodule