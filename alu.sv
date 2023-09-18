module alu(en, in1, in2, ctrl, out);
	input en;
	input[31:0] in1, in2;
	input[3:0] ctrl;
	output reg [31:0] out;
	//output zero;
	
	//assign zero = (out == 32'b0);
	
	always @ (*) begin
		if(en) begin		
			case (ctrl)
				//AND
				4'b0000: out = in1 & in2;
				
				//OR
				4'b0001: out = in1 | in2;
				
				//ADD
				4'b0010: out = in1 + in2;
				
				//SUB
				4'b0110: out = in1 - in2;

				//XOR
				4'b1111: out = in1 ^ in2;

				//SRA
				4'b1110: out = in1 >> in2;
			endcase
		end else begin
			out = 32'b0;
		end
	end

endmodule