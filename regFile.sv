module regFile(rd_reg1, rd_reg2, rd_reg3, rd_reg4, rd_reg5, rd_reg6, 
					wr_reg1, wren_reg1, wr_reg2, wren_reg2, wr_reg3, wren_reg3, 
					wr_d1, wr_d2, wr_d3, 
					rd_d1, rd_d2, rd_d3, rd_d4, rd_d5, rd_d6);
	input [5:0] rd_reg1, rd_reg2, rd_reg3, rd_reg4, rd_reg5, rd_reg6, wr_reg1, wr_reg2, wr_reg3;
	input wren_reg1, wren_reg2, wren_reg3;
	input [31:0] wr_d1, wr_d2, wr_d3;
	output [31:0] rd_d1, rd_d2, rd_d3, rd_d4, rd_d5, rd_d6;
	
	reg [31:0] registerFile [0:63];

	initial begin
		for(integer i = 0; i < 64; i++) begin
			registerFile[i] = 32'b0;
		end
	end
	
	assign rd_d1 = registerFile[rd_reg1];
	assign rd_d2 = registerFile[rd_reg2];
	assign rd_d3 = registerFile[rd_reg3];
	assign rd_d4 = registerFile[rd_reg4];
	assign rd_d5 = registerFile[rd_reg5];
	assign rd_d6 = registerFile[rd_reg6];
	
	
	always @ (*) begin
		if (wren_reg1 && wr_reg1 != 0) begin
			registerFile[wr_reg1] = wr_d1;
		end
		if (wren_reg2 && wr_reg2 != 0) begin
			registerFile[wr_reg2] = wr_d2;
		end
		if (wren_reg3 && wr_reg3 != 0) begin
			registerFile[wr_reg3] = wr_d3;
		end
		registerFile[0] = 32'b0;
	end


endmodule