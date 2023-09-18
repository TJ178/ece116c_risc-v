module rob(rd_1, rd_2, rd_3, old_rd_1, old_rd_2, old_rd_3, rd_d1, rd_d2, rd_d3, rob_idx_1, rob_idx_2, rob_idx_3, rob_tail,
            rd1_free, rd1_free_valid, rd1_wb, rd1_data, rd2_free, rd2_free_valid, rd2_wb, rd2_data, r_valid1, r_valid2, r_valid3);
    input[5:0] rd_1, rd_2, rd_3, old_rd_1, old_rd_2, old_rd_3;     //input rd values
    input[31:0] rd_d1, rd_d2, rd_d3; //data for rd1, rd2, rd3;
    input[3:0] rob_idx_1, rob_idx_2, rob_idx_3;
    output reg [3:0] rob_tail = 4'b0;
    output reg [31:0] rd1_data, rd2_data;
    output reg [5:0] rd1_wb, rd2_wb, rd1_free, rd2_free;
    output reg rd1_free_valid, rd2_free_valid;
    input r_valid1, r_valid2, r_valid3;

    reg [44:0] robTable [15:0];
    initial begin
        for(integer i = 0; i < 16; i++) begin
            robTable[i] = 45'b0;
        end
        rd1_data = 0;
        rd2_data = 0;
        rd1_wb = 0;
        rd2_wb = 0;
        rd1_free = 0;
        rd2_free = 0;
        rd1_free_valid = 0;
        rd2_free_valid = 0;
    end

    /* robTable
        5:0 rd
        11:6 old_rd
        43:12 rd_data
        44: valid
    */

    reg [3:0] rob_head = 1;

    always @ (*) begin
        if(r_valid1) begin
            robTable[rob_idx_1][5:0] = rd_1;
            robTable[rob_idx_1][11:6] = old_rd_1;
            robTable[rob_idx_1][43:12] = rd_d1;
            robTable[rob_idx_1][44] = 1'b1;
            rob_tail = (rob_tail+1)%16;
        end
        if(r_valid2) begin
            robTable[rob_idx_2][5:0] = rd_2;
            robTable[rob_idx_2][11:6] = old_rd_2;
            robTable[rob_idx_2][43:12] = rd_d2;
            robTable[rob_idx_2][44] = 1'b1;
            rob_tail = (rob_tail+1)%16;
        end
        if(r_valid3) begin
            robTable[rob_idx_3][5:0] = rd_3;
            robTable[rob_idx_3][11:6] = old_rd_3;
            robTable[rob_idx_3][43:12] = rd_d3;
            robTable[rob_idx_3][44] = 1'b1;
            rob_tail = (rob_tail+1)%16;
        end

        //retire
        if(robTable[rob_head][44] != 0) begin
            rd1_wb = robTable[rob_head][5:0];
            rd1_free = robTable[rob_head][11:6];
            rd1_data = robTable[rob_head][43:12];
            rd1_free_valid = 1;
            robTable[rob_head] = 45'b0;
            rob_head = (rob_head + 1) % 16;
        end
        if(robTable[rob_head][44] != 0) begin
            rd2_wb = robTable[rob_head][5:0];
            rd2_free = robTable[rob_head][11:6];
            rd2_data = robTable[rob_head][43:12];
            rd2_free_valid = 1;
            robTable[rob_head] = 45'b0;
            rob_head = (rob_head + 1) % 16;
        end

        $display("rob");
        $display("idx\trd\told rd\tdata");
        //for(integer i = 0; i < 16; i = i + 1) begin
        $display("%d\t%d\t%d\t%d\t%b", rob_head, robTable[rob_head][5:0], robTable[rob_head][11:6], robTable[rob_head][43:12], robTable[rob_head][44]);
        for(integer i = rob_head+1; i != rob_head; i = (i + 1) % 16) begin
            $display("%d\t%d\t%d\t%d\t%b", i, robTable[i][5:0], robTable[i][11:6], robTable[i][43:12], robTable[i][44]);
        end
    end

endmodule