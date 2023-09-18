module alu_controller(aluop, inst30, func3, aluctrl);
	input[1:0] aluop;
	input inst30;
	input[2:0] func3;
	output reg [3:0] aluctrl;
	
	always @ (*) begin
		case (aluop)
			2'b00: begin
				aluctrl = 4'b0010;
			end
			2'b01: begin
				aluctrl = 4'b0110;
			end
			2'b10: begin
				case (func3)
				//add/sub
				3'b000: aluctrl = {1'b0, inst30, 2'b10};
				
				//AND
				3'b111: aluctrl = 4'b0000;
				
				//OR
				3'b110: aluctrl = 4'b0001;
				
				//XOR
				3'b100: aluctrl = 4'b1111;
				
				//SRA
				3'b101: aluctrl = 4'b1110;
				
				default: aluctrl = 4'b0000;
				endcase
			end
			
			//ANDI/ADDI
			2'b11: begin
				if(func3[0]) begin
					//AND
					aluctrl = 4'b0000;
				end else begin
					//ADD
					aluctrl = 4'b0010;
				end
			end
			default: aluctrl = 4'b0000;
		endcase
	end

endmodule