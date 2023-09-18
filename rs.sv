module rs(input [5:0] rs1_1, input [5:0] rs2_1, input [5:0] rd_1, input memRead1, input memToReg1, input memWrite1, input ALUSrc1, input regWrite1, input[31:0] imm1, input [3:0] ALUCtr1, 
          input [5:0] rs1_2, input [5:0] rs2_2, input [5:0] rd_2, input memRead2, input memToReg2, input memWrite2, input ALUSrc2, input regWrite2, input[31:0] imm2, input [3:0] ALUCtr2,
          input [3:0] rob_tail, input [5:0] rdGood1, input [5:0] rdGood2, input [5:0] rdGood3, input [31:0] rdGoodData1, input [31:0] rdGoodData2, input [31:0] rdGoodData3,
          input clk, output reg [139:0] issued [2:0], input[5:0] old_rd_1, input[5:0] old_rd_2);
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
    139-134: old rd
    */

    wire isNoOp1 = (rs1_1 == 6'b0) && (rs2_1 == 6'b0) && (rd_1 == 6'b0) && (memRead1 == 0) && (memToReg1 == 0) && (memWrite1 == 0)
                    && (ALUSrc1 == 0) && (regWrite1 == 0) && (imm1 == 32'b0) && (ALUCtr1 == 4'b0);

    reg [2:0] FUStatus; // Functional units 0 and 1 are ALU, 2 is memory, 1 means free, 0 means occupied
    reg [63:0] readyReg;
    reg [139:0] resStation [31:0]; //Create reservation station capable of holding 32 entries
    reg [3:0] rsIndex1;
    reg [3:0] rsIndex2;
    reg[3:0] robIndex = 0;

    initial begin
        FUStatus = 3'b111;
        readyReg = 64'hffffffffffffffff;
        for (integer i = 0; i < 32; i++) begin
            resStation[i] = 0;
        end
        rsIndex1 = 0;
        rsIndex2 = 0;
    end
    

    //Update the ready registers on all RS instructions, then issue up to three ready ones
    always @(posedge clk) begin
        FUStatus = 3'b111;

        for (integer i = 0; i < 32; i++) begin
            //Update the value if it matches the forwarded registers, mark to indicate forwarding
            if (resStation[i][12:7] == rdGood1 && rdGood1 != 5'b0) begin
                $display("Forwarded rdGood1 to resStation[%d][12:7]", i);
                resStation[i][100:69] = rdGoodData1;
                resStation[i][68] = 1;
            end
            else if (resStation[i][12:7] == rdGood2 && rdGood2 != 5'b0) begin
                $display("Forwarded rdGood2 to resStation[%d][12:7]", i);
                resStation[i][100:69]  = rdGoodData2;
                resStation[i][68] = 1;
            end
            else if (resStation[i][12:7] == rdGood3 && rdGood3 != 5'b0) begin
                $display("Forwarded rdGood3 to resStation[%d][12:7]", i);
                resStation[i][100:69]  = rdGoodData3;
                resStation[i][68] = 1;
            end

            if (resStation[i][19:14] == rdGood1 && rdGood1 != 5'b0) begin
                $display("Forwarded rdGood1 to resStation[%d][19:14]", i);
                resStation[i][133:102] = rdGoodData1;
                resStation[i][101] = 1;
            end
            else if (resStation[i][19:14] == rdGood2 && rdGood2 != 5'b0) begin
                $display("Forwarded rdGood2 to resStation[%d][19:14]", i);
                resStation[i][133:102] = rdGoodData2;
                resStation[i][101] = 1;
            end
            else if (resStation[i][19:14] == rdGood3 && rdGood3 != 5'b0) begin
                $display("Forwarded rdGood3 to resStation[%d][19:14]", i);
                resStation[i][133:102] = rdGoodData3;
                resStation[i][101] = 1;
            end
            
        end
        readyReg[rdGood1] = 1;
        readyReg[rdGood2] = 1;
        readyReg[rdGood3] = 1;
        for (integer i = 0; i < 32; i++) begin
            //Store whether instruction is ready to execute or not based on readyReg
            resStation[i][13] = resStation[i][0] & readyReg[resStation[i][12:7]]; 
            resStation[i][20] = resStation[i][0] & readyReg[resStation[i][19:14]];
        end
        for (integer i = 0; i < 3; i++) begin
            issued[i] = 0;
        end
        for (integer i = 0; i < 3; i++) begin
            for (integer j = 0; j < 32; j++) begin
                //Issue if there is instruction, both regs ready, FU is free
                if (resStation[j][0] && resStation[j][13] & resStation[j][20] && FUStatus[resStation[j][26:25]]) begin
                    //Places ALU0 FU into issued[0], etc
                    issued[resStation[j][26:25]] = resStation[j];
                    resStation[j][0] = 0;
                    FUStatus[resStation[j][26:25]] = 0;
                    /*for(integer k = j+1; k < 32; k++) begin
                        resStation[k] = resStation[k-1];
                    end
                    resStation[31] = 0;*/
                    break;
                end
            end
        end
    end

    //Place two new instructions into RS
    always @ (negedge clk) begin
        $display("isNoOp1: %b", isNoOp1);
        if (!(rs1_1 === 6'bx) && !(rd_1 === 6'bx) && !(isNoOp1)) begin
            //Find the next index to store the new instructions in reservation station
            for (integer i = 0; i < 32; i++) begin
                if (resStation[i][0] == 0) begin
                    rsIndex1 = i;
                    resStation[rsIndex1] = 0;
                    resStation[i][0] = 1;
                    break;
                end
            end
            for (integer i = 0; i < 32; i++) begin
                if (resStation[i][0] == 0) begin
                    rsIndex2 = i;
                    resStation[rsIndex2] = 0;
                    resStation[i][0] = 1;
                    break;
                end
            end

            readyReg[rd_1] = 0;
            readyReg[rd_2] = 0;

            //Place into Reservation Station instruction 1
            resStation[rsIndex1][6:1] = rd_1;
            resStation[rsIndex1][12:7] = rs1_1;
            resStation[rsIndex1][19:14] = rs2_1;
            /*if (memWrite1) begin

            end else begin
                resStation[rsIndex1][24:21] = (robIndex + 1) % 16;
                robIndex = robIndex + 1;
            end*/
            resStation[rsIndex1][24:21] = (robIndex + 1) % 16;
            robIndex = robIndex + 1;
            resStation[rsIndex1][26:25] = (memRead1 | memWrite1) ? 2 : ( (FUStatus[0]) ? 0 : 1);
            resStation[rsIndex1][27] = memRead1;
            resStation[rsIndex1][28] = memToReg1;
            resStation[rsIndex1][29] = memWrite1;
            resStation[rsIndex1][30] = ALUSrc1;
            resStation[rsIndex1][31] = regWrite1;
            resStation[rsIndex1][63:32] = imm1;
            resStation[rsIndex1][67:64] = ALUCtr1;
            resStation[rsIndex1][139:134] = old_rd_1;

            //Place into Reservation Station instruction 2
            
            resStation[rsIndex2][6:1] = rd_2;
            resStation[rsIndex2][12:7] = rs1_2;
            resStation[rsIndex2][19:14] = rs2_2;
            resStation[rsIndex2][24:21] = (robIndex + 1) % 16;
            robIndex = robIndex + 1;
            resStation[rsIndex2][26:25] = (memRead2 | memWrite2) ? 2 : ( (resStation[rsIndex1][26:25] > 0) ? 0 : 1);
            resStation[rsIndex2][27] = memRead2;
            resStation[rsIndex2][28] = memToReg2;
            resStation[rsIndex2][29] = memWrite2;
            resStation[rsIndex2][30] = ALUSrc2;
            resStation[rsIndex2][31] = regWrite2;
            resStation[rsIndex2][63:32] = imm2;
            resStation[rsIndex2][67:64] = ALUCtr2;
            resStation[rsIndex2][139:134] = old_rd_2;

            /*$display("First ten rows");
            for (integer i = 0; i < 10; i++) begin
                for (integer j = 0; j < 134; j++) begin
                    $write(resStation[i][j]);
                end
                $display();
            end*/
            $display($time);
            $display("reservation station:");
            $display("rd\trs1\tready\trs2\tready\trob\tfu\tmemrd\tmem2reg\tmemwr\talusrc\tregwr\timm\taluctr\trs1fw\trs1fwd\trs2fw\trs2fwd\toldrd");
            for(integer i = 0; i < 32; i++) begin
                if(resStation[i][0]) begin
                    $write("%d\t", resStation[i][6:1]);
                    $write("%d\t", resStation[i][12:7]);
                    $write("%b\t", resStation[i][13]);
                    $write("%d\t", resStation[i][19:14]);
                    $write("%b\t", resStation[i][20]);
                    $write("%d\t", resStation[i][24:21]);
                    $write("%d\t", resStation[i][26:25]);
                    $write("%b\t", resStation[i][27]);
                    $write("%b\t", resStation[i][28]);
                    $write("%b\t", resStation[i][29]);
                    $write("%b\t", resStation[i][30]);
                    $write("%b  ", resStation[i][31]);
                    $write("%d\t", resStation[i][63:32]);
                    $write("%b\t", resStation[i][67:64]);
                    $write("%b\t", resStation[i][68]);
                    $write("%d\t", resStation[i][100:69]);
                    $write("%b\t", resStation[i][101]);
                    $write("%d\t", resStation[i][133:102]);
                    $display("%d\t", resStation[i][139:134]);
                end
            end
            $display("\n");
                    

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
        end
    
    end


endmodule