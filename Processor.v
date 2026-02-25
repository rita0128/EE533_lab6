`timescale 1ns / 1ps

module Processor(
    input clk,
    input rst
);

wire stall; // stall
wire flush; // flush
wire [1: 0] forwardA, forwardB; // forwording
wire forwardC; // hazard forwarding

// IF stage
wire [31: 0] PC_IF; 
wire [31: 0] PC4_IF; // pc + 4
wire [31: 0] NEXTPC_IF; 
wire [31: 0] INST_IF; 

// ID stage
wire [31: 0] PC_ID;
wire [31: 0] INST_ID;
wire [31: 0] IMM32_ID;
wire [31: 0] rs1Data_ID, rs2Data_ID;
wire [4:  0] RD_ID, RS1_ID, RS2_ID;

wire [6: 0] Opcode_ID; 
wire [2: 0] func3_ID; 
wire [6: 0] func7_ID;

wire [4:  0] ALU_OP_ID; 
wire RF_SRC_ID; 
wire ALU_A_SRC_ID; 
wire[1: 0] ALU_B_SRC_ID; //mux3 
wire REG_WE_ID;
wire [1: 0] MEM_WE_ID; 
wire [2: 0] MEM_RE_ID;
wire [2: 0] IMM_TYPE_ID;
wire [1: 0] PC_SRC_ID;

// EX stage
wire [4:  0] ALU_OP_EX; 
wire RF_SRC_EX; 
wire ALU_A_SRC_EX;
wire[1: 0] ALU_B_SRC_EX;
wire REG_WE_EX; 
wire [1: 0] MEM_WE_EX; 
wire [2: 0] MEM_RE_EX;
wire[1: 0] PC_SRC_EX; 
wire [31: 0] PC_EX; 
wire [31: 0] rs1Data_EX, rs2Data_EX;
wire [31: 0] TRUE_RS1_EX, TRUE_RS2_EX; 
wire [31: 0] IMM32_EX;
wire [4: 0] RD_EX, RS1_EX, RS2_EX;
wire [31: 0] ALU_IN_A_EX, ALU_IN_B_EX; 
wire [31: 0] PC_IMM_EX, RS1_IMM_EX; 
wire [31: 0] ALU_OUT_EX; 
wire BRANCH_EX; 

// MEM stage
wire RF_SRC_MEM;  
wire REG_WE_MEM; 
wire [1: 0] MEM_WE_MEM; 
wire [2: 0] MEM_RE_MEM; 
wire[1: 0] PC_SRC_MEM; 
wire BRANCH_MEM; 
wire [31: 0] PC_IMM_MEM, RS1_IMM_MEM; 
wire [31: 0] ALU_OUT_MEM; 
wire [31: 0] rs2Data_MEM;
wire [4: 0] RD_MEM;
wire [4: 0] RS2_MEM;
wire [31: 0] TRUE_RS2_MEM; 
wire [31: 0] MEM_OUT_MEM; 

// WB stage
wire RF_SRC_WB; 
wire REG_WE_WB; 
wire [31: 0] OUT_MEM_WB; 
wire [31: 0] OUT_ALU_WB; 
wire [31: 0] RD_DATA_WB; 
wire [4: 0] RD_WB; 


    NEXT_PC next_pc(
        .jump_sel(PC_SRC_MEM),
        .condition_branch(BRANCH_MEM),
        .pc4(PC4_IF),
        .pcImm(PC_IMM_MEM),
        .rs1Imm(RS1_IMM_MEM),
        .next_pc(NEXT_PC_IF),
        .flush(flush)
    );

    PC_ADD_4  pc_add_4(
    .pc(PC_IF),
    .pc_4(PC4_IF)
    );

    PC pc_unit(
    .clk(clk),
    .rst(rst),
	.pause(1'b0),
	.flush(flush | stall),
    // .pause(stall),
    //.flush(flush),
    .pc_next(NEXT_PC_IF),
    .pc(PC_IF)
    );

    instruction_mem INSTRUCTION_MEM(
    .pc(PC_IF),
    .instruction(INST_IF)
    );

    IF_ID if_id_reg(
    .clk(clk),
    .rst(rst),
    .pause(stall),
    .flush(flush),

    .PC_IF(PC_IF),
    .Inst_IF(INST_IF),

    .PC_ID(PC_ID),
    .Inst_ID(INST_ID),

    .opcode(Opcode_ID),
    .func3(func3_ID),
    .func7(func7_ID),
    .rd(RD_ID),
    .rs1(RS1_ID),
    .rs2(RS2_ID)
   );

   controller CONTROLLER(
    .opcode(Opcode_ID),
    .func3(func3_ID),
    .func7(func7_ID),

    .ALU_Op(ALU_OP_ID),
    .rf_src(RF_SRC_ID),
    .ALU_A(ALU_A_SRC_ID),
    .ALU_B(ALU_B_SRC_ID),
    .reg_we(REG_WE_ID),
    .mem_we(MEM_WE_ID),
    .mem_re(MEM_RE_ID),
    .imm_type(IMM_TYPE_ID),
    .pc_src(PC_SRC_ID)
);

    Reg_file REG_FILE(
        .rst(rst),
        .clk(clk),
        .reg_we(REG_WE_WB),
        .rs1(RS1_ID),
        .rs2(RS2_ID),
        .rd(RD_WB),
        .rd_data(RD_DATA_WB),

        .rs1_data(rs1Data_ID),
        .rs2_data(rs2Data_ID)
    );

    imm imm_gen(
        .instr(INST_ID),
        .extOP(IMM_TYPE_ID),
        //.extOP(3'b000),
        .imm_32(IMM32_ID)
    );

   Hazard_Detection hazard_dection(
    .ex_readMem(MEM_RE_EX),
    .ex_rd(RD_EX),
    .id_rs1(RS1_ID),
    .id_rs2(RS2_ID),

    .stall(stall)
);


ID_EX id_ex( 
    .clk(clk),
    .rst(rst),
    .pause(stall),
    .flush(flush),

    .ID_ALU_Op(ALU_OP_ID),
    .ID_RF_SRC(RF_SRC_ID),
    .ID_ALU_A(ALU_A_SRC_ID),
    .ID_ALU_B(ALU_B_SRC_ID),
    .ID_REG_WE(REG_WE_ID),
    .ID_MEM_WE(MEM_WE_ID),
    .ID_MEM_RE(MEM_RE_ID),
    .ID_pc_src(PC_SRC_ID),
    .ID_PC(PC_ID),
    .ID_rs1_DATA(rs1Data_ID),
    .ID_rs2_DATA(rs2Data_ID),
    .ID_IMM32(IMM32_ID),
    .ID_RD(RD_ID),
    .ID_rs1(RS1_ID),
    .ID_rs2(RS2_ID),

    .EX_ALU_Op(ALU_OP_EX),
    .EX_RF_SRC(RF_SRC_EX),
    .EX_ALU_A(ALU_A_SRC_EX),
    .EX_ALU_B(ALU_B_SRC_EX),
    .EX_REG_WE(REG_WE_EX),
    .EX_MEM_WE(MEM_WE_EX),
    .EX_MEM_RE(MEM_RE_EX),
    .EX_pc_src(PC_SRC_EX),
    .EX_PC(PC_EX),
    .EX_rs1_DATA(rs1Data_EX),
    .EX_rs2_DATA(rs2Data_EX),
    .EX_IMM32(IMM32_EX),
    .EX_RD(RD_EX),
    .EX_rs1(RS1_EX),
    .EX_rs2(RS2_EX)
);

MUX_3 MUX_FORWARD_A(
    .signal(forwardA),
    .a(rs1Data_EX),
    .b(ALU_OUT_MEM),
    .c(RD_DATA_WB),

    .out(TRUE_RS1_EX)
);

MUX_3 MUX_FORWARD_B(
    .signal(forwardB),
    .a(rs2Data_EX),
    .b(ALU_OUT_MEM),
    .c(RD_DATA_WB),

    .out(TRUE_RS2_EX)
);

MUX_2 MUX_EX_A(
    .signal(ALU_A_SRC_EX),
    .a(TRUE_RS1_EX),
    .b(PC_EX),

    .out(ALU_IN_A_EX)
);

MUX_3 MUX_EX_B(
    .signal(ALU_B_SRC_EX),
    .a(TRUE_RS2_EX),
    .b(IMM32_EX),
    .c(32'd4),

    .out(ALU_IN_B_EX)
);

PC_CAL pc_cal(
    .pc(PC_EX),
    .imm32(IMM32_EX),
    .rs1_data(TRUE_RS1_EX),

    .pcImm(PC_IMM_EX),
    .rs1Imm(RS1_IMM_EX)
);

ALU alu(
    .ctrl(ALU_OP_EX),
    .a(ALU_IN_A_EX),
    .b(ALU_IN_B_EX),

    .out(ALU_OUT_EX),
    .condition_branch(BRANCH_EX)
);

Data_Forwarding FORWARDING(
    .mem_reg_we(REG_WE_MEM),
    .mem_rd(RD_MEM),
    .wb_rd(RD_WB),
    .wb_reg_we(REG_WE_WB),
    .ex_rs1(RS1_EX),
    .ex_rs2(RS2_EX),
    .mem_rs2(RS2_MEM),

    .fwd_a_sel(forwardA),
    .fwd_b_sel(forwardB),
    .fwd_c_sel(forwardC)
);


EX_MEM ex_mem(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .EX_WB_SRC(RF_SRC_EX),
    .EX_REG_WE(REG_WE_MEM),
    .EX_MEM_WE(MEM_WE_EX),
    .EX_MEM_RE(MEM_RE_EX),
    .EX_PC_SRC(PC_SRC_EX),
    .EX_BRANCH(BRANCH_EX),
    .EX_PC_IMM(PC_IMM_EX),
    .EX_RS1_IMM(RS1_IMM_EX),
    .EX_ALU_OUT(ALU_OUT_EX),
    .EX_RS2_DATA(TRUE_RS2_EX),
    .EX_RD(RD_EX),
    .EX_RS2(RS2_EX),

    .MEM_WB_SRC(RF_SRC_MEM),
    .MEM_REG_WE(REG_WE_MEM),
    .MEM_MEM_WE(MEM_WE_MEM),
    .MEM_MEM_RE(MEM_RE_MEM),
    .MEM_PC_SRC(PC_SRC_MEM),
    .MEM_BRANCH(BRANCH_MEM),
    .MEM_PC_IMM(PC_IMM_MEM),
    .MEM_RS1_IMM(RS1_IMM_MEM),
    .MEM_ALU_OUT(ALU_OUT_MEM),
    .MEM_RS2_DATA(rs2Data_MEM),
    .MEM_RD(RD_MEM),
    .MEM_RS2(RS2_MEM)
);

MUX_2 MUX_WB_DATA(
    .signal(forwardC),
    .a(rs2Data_MEM),
    .b(RD_DATA_WB),

    .out(TRUE_RS2_MEM)
);

DATA_MEM data_mem(
    .clk(clk),
    .rst(rst),
    .addr(ALU_OUT_MEM),
    .din(TRUE_RS2_MEM),
    .mem_we(MEM_WE_MEM),
    .mem_re(MEM_RE_MEM),

    .dout(MEM_OUT_MEM)
);

MEM_WB mem_wb(
    .clk(clk),
    .rst(rst),
    .mem_to_reg(RF_SRC_MEM),
    .mem_to_we(REG_WE_MEM),
    .mem_outMem(MEM_OUT_MEM),
    .mem_outAlu(ALU_OUT_MEM),
    .mem_rd(RD_MEM),

    .wb_to_reg(RF_SRC_WB),
    .wb_reg_we(REG_WE_WB),
    .wb_outMem(OUT_MEM_WB),
    .wb_outAlu(OUT_ALU_WB),
    .wb_rd(RD_WB)
);

MUX_2 MUX_WB(
    .signal(RF_SRC_WB),
    .a(OUT_ALU_WB),
    .b(OUT_MEM_WB),

    .out(RD_DATA_WB)
);
endmodule

