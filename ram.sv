module ram(input [31:0] rs1, input [31:0] rs2, input [31:0] offset, input memRead, input memWrite, output reg [31:0] readMemData);

    reg [7:0] memory [4095:0];

    initial begin  
        for (integer i = 0; i < 4096; i++) begin
            memory[i] = 0;
        end
    end

    always @(*) begin

        if (memRead) begin
            readMemData[7:0] = memory[rs1 + offset];
            readMemData[15:8] = memory[rs1 + offset + 1];
            readMemData[23:16] = memory[rs1 + offset + 2];
            readMemData[31:24] = memory[rs1 + offset + 3];
        end
        else if (memWrite) begin
            memory[rs1 + offset] = rs2[7:0];
            memory[rs1 + offset + 1] = rs2[15:8];
            memory[rs1 + offset + 2] = rs2[23:16];
            memory[rs1 + offset + 3] = rs2[31:24];
        end

     end
endmodule