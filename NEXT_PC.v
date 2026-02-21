module NEXT_PC(
    input [1: 0] jump_sel,
    input condition_branch,
    input [31: 0] pc4, pcImm, rs1Imm,

    output reg [31: 0] next_pc,
    output reg flush
);

parameter END_PC_ADDR = 32'h13c;

always @(*) begin
    if(jump_sel == 2'b01) begin // JAL
        next_pc = pcImm;
        flush = 1'b1; // taken jump == flush the pipeline
    end else if(jump_sel == 2'b10) begin // JALR 
        next_pc = rs1Imm;
        flush = 1'b1; // taken jump == flush the pipeline
    end else if(condition_branch) begin //BEQ OR BNE
        next_pc = pcImm;
        flush = 1'b1; // taken branch == flush the pipeline
    end else if(pc4 == END_PC_ADDR) begin 
        next_pc = END_PC_ADDR; // the end of tnistuctions
        flush = 1'b0;
    end else begin 
        next_pc = pc4; // there are no jump or branch means next pc4
        flush = 1'b0;
    end
end

endmodule