module MEM_WB(
    input clk, rst,

    //FROM MEM
    input mem_to_reg, // selec signal 0=ALU, 1=MEM
    input mem_to_we, // Wright enable
    input [31: 0] mem_outMem, // data from memory 
    input [31: 0] mem_outAlu, // data from ALU
    input [4: 0] mem_rd,

    // FROM WB
    output reg wb_to_reg,
    output reg wb_reg_we,
    output reg [31: 0] wb_outMem,
    output reg [31: 0] wb_outAlu,
    output reg [4: 0] wb_rd
);

always @(posedge clk) begin
    if(rst) begin
        wb_to_reg <= 1'b0;
        wb_reg_we <= 1'b0;
        wb_outMem = 32'd0;
        wb_outAlu = 32'd0;
        wb_rd = 5'd0;
    end else begin
        wb_to_reg <= mem_to_reg;
        wb_reg_we <= mem_to_we;
        wb_outMem <= mem_outMem;
        wb_outAlu <= mem_outAlu;
        wb_rd <= mem_rd;
    end
end

endmodule