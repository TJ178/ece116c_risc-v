module testbench(clk, pc);
	output reg [31:0] pc;
	output reg clk;
	
	wire eof;
	processor cpu(clk, pc, eof);
	
	initial begin
		clk = 0;
		#50;
		$stop;
	end
	
	always begin
		#1;
		clk = ~clk;
	end

	/*always begin
		if(eof) begin
			#5
			$stop;
		end
	end*/

endmodule