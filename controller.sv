module controller(opcode, memrd, memtoreg, aluop, memwr, alusrc, regwr);
	input[6:0] opcode;
	output reg memrd, memtoreg, memwr, alusrc, regwr;
	output reg [1:0] aluop;
	
	always @ (*) begin
		case (opcode)
			//R-TYPE
			7'b0110011: begin
				//br = 0;
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b10;
				memwr = 0;
				alusrc = 0;
				regwr = 1;
			end
			
			//S-TYPE
			7'b0100011: begin
				//br = 0;
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b00;
				memwr = 1;
				alusrc = 1;
				regwr = 0;
			end
			
			//B-TYPE
			/*7'b1100011: begin
				br = 1;
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b01;
				memwr = 0;
				alusrc = 0;
				regwr = 0;
			end*/
			
			//ADDI / ANDI
			7'b0010011: begin
				//br = 0;
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b11; //11 = addi / andi
				memwr = 0;
				alusrc = 1;
				regwr = 1;
			end
			
			//JALR
			//need to figure out how to get control signal for memtoreg to access PC+4
			7'b1100111: begin
				//br = 1;
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b00;
				memwr = 0;
				alusrc = 1;
				regwr = 1;
			end
			
			//LW
			7'b0000011: begin
				//br = 0;
				memrd = 1;
				memtoreg = 1;
				aluop = 2'b00;
				memwr = 0;
				alusrc = 1;
				regwr = 1;
			end
			default: begin
				memrd = 0;
				memtoreg = 0;
				aluop = 2'b00;
				memwr = 0;
				alusrc = 0;
				regwr = 0;
			end
		endcase
	end
	
	
endmodule