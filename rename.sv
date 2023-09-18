module rename(clk, regFree1, regFree1_valid, regFree2, regFree2_valid, rs1_1, rs2_1, rd_1, p1_1, p2_1, pd_1,
										 rs1_2, rs2_2, rd_2, p1_2, p2_2, pd_2, old_pd_1, old_pd_2);
	input[4:0] rs1_1, rs2_1, rd_1, rs1_2, rs2_2, rd_2;
	input[5:0] regFree1, regFree2;
	input regFree1_valid, regFree2_valid, clk;
	output reg [5:0] p1_1, p1_2, p2_1, p2_2;
	output reg [5:0] pd_1, pd_2, old_pd_1, old_pd_2;
	
	//array of 32 64-bit elements
	reg[5:0] rat [0:31];
	
	//bit is high if that physical reg is free
	reg[63:0] free;
	
	
	integer i;
	initial begin
		//start with top bits high to indicate p32->p63 are free
		free = 64'hFFFFFFFF00000000;
		
		//RAT starts with all x1->x
		for(i = 0; i < 32; i++) begin
			rat[i] = i;
		end
	end
	
	integer j;
	always @ (posedge clk) begin
		p1_1 = rat[rs1_1];
		p2_1 = rat[rs2_1];
		
		if(regFree1_valid) begin
			free[regFree1] = 1'b1;
		end
		if(regFree2_valid) begin
			free[regFree2] = 1'b1;
		end
		
		if(rd_1 != 5'b0) begin
			for(j = 1; j < 64; j++) begin
				if(free[j]) begin
					break;
				end
			end
			
			old_pd_1 = rat[rd_1];
			pd_1 = j;
			free[j] = 1'b0;
			rat[rd_1] = j;
			
		end else begin
			pd_1 = 0;
		end
		
		if(rd_2 != 5'b0) begin
			for(j = 1; j < 64; j++) begin
				if(free[j]) begin
					break;
				end
			end
			
			old_pd_2 = rat[rd_2];
			pd_2 = j;
			free[j] = 1'b0;
			rat[rd_2] = j;
			
		end else begin
			pd_2 = 0;
		end

		p1_2 = rat[rs1_2];
		p2_2 = rat[rs2_2];
	end
	
endmodule