module inst_fetch(clk, pc, out1, out2, endOfFile);

	input[31:0] pc;
	input clk;
	output reg[31:0] out1, out2;
	output reg endOfFile = 0;
	
	parameter NUM_INSTRUCTIONS = 12;
	parameter NUM_BYTES = 4 * NUM_INSTRUCTIONS;
	
	reg [7:0] data [0:1023];
	
	initial begin
		for(integer i = 0; i < 1024; i = i + 1) begin
			data[i] = 8'b0;
		end
		$readmemh("C:/Users/tim/Documents/Quartus/M116C/inst_fetch/evaluation-hex.txt", data);
		out1 = 32'b0;
		out2 = 32'b0;
	end
	
	
	//NEED TO TEST EOF SIGNAL
	always @ (posedge clk) begin
		if(pc > NUM_BYTES) begin
			endOfFile = 1'b1;
			out1 = 32'b0;
			out2 = 32'b0;
		end else begin
			endOfFile = 1'b0;
			out1 = {data[pc], data[pc+1], data[pc+2], data[pc+3]};
			out2 = {data[pc+4], data[pc+5], data[pc+6], data[pc+7]};
		end
	end

 endmodule