module ID_EX(
    input clk, 
    input rst, 
    input pause, 
    input flush,

    //  ID Stage inputs 
    input [4:0]   ID_ALU_Op,
    input         ID_RF_SRC,
    input         ID_ALU_A,
    input [1:0]   ID_ALU_B,
    input         ID_REG_WE,
    input [1:0]   ID_MEM_WE,
    input [2:0]   ID_MEM_RE,
    input [2:0]   ID_IMM_TYPE,
    input [1:0]   ID_pc_src,

    input [31:0]  ID_PC,
    input [31:0]  ID_rs1_DATA,
    input [31:0]  ID_rs2_DATA,
    input [31:0]  ID_IMM32,
    input [4:0]   ID_RD,
    input [4:0]   ID_rs1,
    input [4:0]   ID_rs2,

    // EX Stage outputs 
    output reg [4:0]   EX_ALU_Op,
    output reg         EX_RF_SRC,
    output reg         EX_ALU_A,
    output reg [1:0]   EX_ALU_B,
    output reg         EX_REG_WE,
    output reg [1:0]   EX_MEM_WE,
    output reg [2:0]   EX_MEM_RE,
    output reg [2:0]   EX_IMM_TYPE,
    output reg [1:0]   EX_pc_src,

    output reg [31:0]  EX_PC,
    output reg [31:0]  EX_rs1_DATA,
    output reg [31:0]  EX_rs2_DATA,
    output reg [31:0]  EX_IMM32,
    output reg [4:0]   EX_RD,
    output reg [4:0]   EX_rs1,
    output reg [4:0]   EX_rs2
);

always @(posedge clk) begin
    if (rst || flush) begin
        EX_ALU_Op   <= 5'b00000;
        EX_RF_SRC   <= 1'b0;
        EX_ALU_A    <= 1'b0;
        EX_ALU_B    <= 2'b01;
        EX_REG_WE   <= 1'b0;
        EX_MEM_WE   <= 2'b00;
        EX_MEM_RE   <= 3'b000;
        EX_IMM_TYPE <= 3'b000;
        EX_pc_src   <= 2'b00;

        EX_PC       <= 32'b0;
        EX_rs1_DATA <= 32'b0;
        EX_rs2_DATA <= 32'b0;
        EX_IMM32    <= 32'b0;
        EX_RD       <= 5'b0;
        EX_rs1      <= 5'b0;
        EX_rs2      <= 5'b0;
    end 
    else if (!pause) begin
        // ---------- Normal pipeline latch ----------
        EX_ALU_Op   <= ID_ALU_Op;
        EX_RF_SRC   <= ID_RF_SRC;
        EX_ALU_A    <= ID_ALU_A;
        EX_ALU_B    <= ID_ALU_B;
        EX_REG_WE   <= ID_REG_WE;
        EX_MEM_WE   <= ID_MEM_WE;
        EX_MEM_RE   <= ID_MEM_RE;
        EX_IMM_TYPE <= ID_IMM_TYPE;
        EX_pc_src   <= ID_pc_src;

        EX_PC       <= ID_PC;
        EX_rs1_DATA <= ID_rs1_DATA;
        EX_rs2_DATA <= ID_rs2_DATA;
        EX_IMM32    <= ID_IMM32;
        EX_RD       <= ID_RD;
        EX_rs1      <= ID_rs1;
        EX_rs2      <= ID_rs2;
    end
    // pause = 1 → hold the previous EX_* values
end

endmodule

