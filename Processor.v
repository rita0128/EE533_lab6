`timescale 1ns / 1ps

module processor(
    input clk,
    input rst
);

wire stall; // stall
wire flush; // flush
wire [1: 0] forwardA, forwardB; // forwording
wire forwardC; // hazard forwarding

// IF stage
wire [31: 0] if_pc; // instrction
wire [31: 0] if_pc4; // pc + 4
wire [31: 0] if_nextPc; // next instruction
wire [31: 0] if_instr; 

// ID stage
wire [31: 0] id_pc;
wire [31: 0] id_instr;
wire [31: 0] id_imm32; // 32bit immediate number
wire [31: 0] id_rs1Data, id_rs2Data;
wire [4:  0] id_rd, id_rs1, id_rs2;

wire [6: 0] id_opcode; // opcode
wire [2: 0] id_func3; 
wire [6: 0] id_func7;

wire [4:  0] id_aluc; // aluctrl
wire id_aluOut_WB_memOut; //mux2
wire id_rs1Data_EX_PC; //mux2
wire[1: 0] id_rs2Data_EX_imm32_4; //mux3
wire id_writeReg;
wire [1: 0] id_writeMem; 
wire [2: 0] id_readMem;
wire [2: 0] id_extOP;
wire [1: 0] id_pcImm_NEXTPC_rs1Imm;

// EX stage
wire [4:  0] ex_aluc; 
wire ex_aluOut_WB_memOut; 
wire ex_rs1Data_EX_PC;
wire[1: 0] ex_rs2Data_EX_imm32_4;
wire ex_writeReg;
wire [1: 0] ex_writeMem;
wire [2: 0] ex_readMem;
wire[1: 0] ex_pcImm_NEXTPC_rs1Imm;
wire [31: 0] ex_pc; 
wire [31: 0] ex_rs1Data, ex_rs2Data;
wire [31: 0] ex_true_rs1Data, ex_true_rs2Data;
wire [31: 0] ex_imm32;
wire [4: 0] ex_rd, ex_rs1, ex_rs2;
wire [31: 0] ex_inAluA, ex_inAluB;
wire [31: 0] ex_pcImm, ex_rs1Imm;
wire [31: 0] ex_outAlu;
wire ex_conditionBranch;

// ME stage
wire me_aluOut_WB_memOut; 
wire me_writeReg; 
wire [1: 0] me_writeMem;
wire [2: 0] me_readMem;
wire[1: 0] me_pcImm_NEXTPC_rs1Imm;
wire me_conditionBranch;
wire [31: 0] me_pcImm, me_rs1Imm;
wire [31: 0] me_outAlu;
wire [31: 0] me_rs2Data;
wire [4: 0] me_rd;
wire [4: 0] me_rs2;
wire [31: 0] me_true_rs2Data;
wire [31: 0] me_outMem;

// WB stage
wire wb_aluOut_WB_memOut; 
wire wb_writeReg;
wire [31: 0] wb_outMem;
wire [31: 0] wb_outAlu;
wire [31: 0] wb_rdData;
wire [4: 0] wb_rd;
    // =============================
    // ==== COMPONENTS START =======
    // =============================


    NEXT_PC next_pc(
        .jump_sel(me_pcImm_NEXTPC_rs1Imm),
        .conditon_branch(me_conditionBranch),
        .pc4(if_pc4),
        .pcImm(me_rs1Imm),
        .next_pc(if_nextPc),
        .flush(flush)
    );

    PC_ADD_4  pc_add_4(
    .pc(if_pc),

    .pc_4(if_pc4)
    );

    PC pc_unit(
        .clk(clk),
        .rst(rst),
        .pause(stall),
        .flush(flush),
        .pc_next(if_nextPc),
        .pc(if_pc)
    );

    IMEM instruction_mem(
        .addr(pc_if[10:2]),
        .dout(inst_if)
    );

    Instruction_MEM INSTRUCTION_MEM(
    .pc(if_pc),
    .instruction(if_instr)
    );



    // -------- IF/ID --------
    IF_ID if_id_reg(
    .clk(clk),
    .rst(rst),
    .pause(stall),
    .flush(flush),

    .PC_IF(if_pc),
    .Inst_IF(if_instr),

    .PC_ID(id_pc),
    .Inst_ID(id_instr),

    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),
    .rd(id_rd),
    .rs1(id_rs1),
    .rs2(id_rs2)
   );

   controller CONTROLLER(
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),

    .Alu_Op(id_aluc),
    .rf_src(id_aluOut_WB_memOut),
    .ALU_A(id_rs1Data_EX_PC),
    .ALU_B(id_rs2Data_EX_imm32_4),
    .reg_we(id_writeReg),
    .mem_we(id_writeMem),
    .mem_re(id_readMem),
    .imm_type(id_extOP),
    .pc_src(id_pcImm_NEXTPC_rs1Imm)
);

    Reg_file REG_FILE(
        .rst(rst),
        .clk(clk),
        .reg_we(wb_writeReg),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(wb_rd),
        .rd_data(wb_rdData),

        .rs1_data(id_rs1Data),
        .rs2_data(id_rs2Data)
    );


    // -------- Immediate --------
    imm imm_gen(
        .instr(inst_id),
        .extOP(3'b000),
        .imm_32(imm_id)
    );

   Hazard_Detection hazard_dection(
    .ex_readMem(ex_readMem),
    .ex_rd(ex_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .stall(stall)
);


ID_EX id_ex( 
    .clk(clk),
    .rst(rst),
    .pause(stall),
    .flush(flush),

    .ID_ALU_Op(id_aluc),
    .ID_RF_SRC(id_aluOut_WB_memOut),
    .ID_ALU_A(id_rs1Data_EX_PC),
    .ID_ALU_B(id_rs2Data_EX_imm32_4),
    .ID_REG_WE(id_writeReg),
    .ID_MEM_WE(id_writeMem),
    .ID_MEM_RE(id_readMem),
    .ID_pc_src(id_pcImm_NEXTPC_rs1Imm),
    .ID_PC(id_pc),
    .ID_rs1_DATA(id_rs1Data),
    .ID_rs2_DATA(id_rs2Data),
    .ID_IMM32(id_imm32),
    .ID_RD(id_rd),
    .ID_rs1(id_rs1),
    .ID_rs2(id_rs2),

    .EX_ALU_Op(ex_aluc),
    .EX_RF_SRC(ex_aluOut_WB_memOut),
    .EX_ALU_A(ex_rs1Data_EX_PC),
    .EX_ALU_B(ex_rs2Data_EX_imm32_4),
    .EX_REG_WE(ex_writeReg),
    .EX_MEM_WE(ex_writeMem),
    .EX_MEM_RE(ex_readMem),
    .EX_pc_src(ex_pcImm_NEXTPC_rs1Imm),
    .EX_PC(ex_pc),
    .EX_rs1_DATA(ex_rs1Data),
    .EX_rs2_DATA(ex_rs2Data),
    .EX_IMM32(ex_imm32),
    .EX_RD(ex_rd),
    .EX_rs1(ex_rs1),
    .EX_rs2(ex_rs2)
);

MUX_3 MUX_FORWARD_A(
    .signal(forwardA),
    .a(ex_rs1Data),
    .b(me_outAlu),
    .c(wb_rdData),

    .out(ex_true_rs1Data)
);

MUX_3 MUX_FORWARD_B(
    .signal(forwardB),
    .a(ex_rs2Data),
    .b(me_outAlu),
    .c(wb_rdData),

    .out(ex_true_rs2Data)
);

MUX_2 MUX_EX_A(
    .signal(ex_rs1Data_EX_PC),
    .a(ex_true_rs1Data),
    .b(ex_pc),

    .out(ex_inAluA)
);

MUX_3 MUX_EX_B(
    .signal(ex_rs2Data_EX_imm32_4),
    .a(ex_true_rs2Data),
    .b(ex_imm32),
    .c(32'd4),

    .out(ex_inAluB)
);

PC_CAL pc_cal(
    .pc(ex_pc),
    .imm32(ex_imm32),
    .rs1_data(ex_true_rs1Data),

    .pcImm(ex_pcImm),
    .rs1Imm(ex_rs1Imm)
);

ALU alu(
    .ctrl(ex_aluc),
    .a(ex_inAluA),
    .b(ex_inAluB),

    .out(ex_outAlu),
    .condition_branch(ex_conditionBranch)
);

Data_Forwarding FORWARDING(
    .me_reg_we(me_writeReg),
    .meM_rd(me_rd),
    .wb_rd(wb_rd),
    .wb_reg_we(wb_writeReg),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .mem_rs2(me_rs2),

    .fwd_a_sel(forwardA),
    .fwd_b_sel(forwardB),
    .fwd_c_sel(forwardC)
);


EX_ME ex_me(
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .EX_WB_SRC(ex_aluOut_WB_memOut),
    .EX_REG_WE(ex_writeReg),
    .EX_MEM_WE(ex_writeMem),
    .EX_MEM_RE(ex_readMem),
    .EX_PC_SRC(ex_pcImm_NEXTPC_rs1Imm),
    .EX_BRANCH(ex_conditionBranch),
    .EX_PC_IMM(ex_pcImm),
    .EX_RS1_IMM(ex_rs1Imm),
    .EX_ALU_OUT(ex_outAlu),
    .EX_RS2_DATA(ex_true_rs2Data),
    .EX_RD(ex_rd),
    .EX_RS2(ex_rs2),

    .MEM_WB_SRC(me_aluOut_WB_memOut),
    .MEM_REG_WE(me_writeReg),
    .MEM_MEM_WE(me_writeMem),
    .MEM_MEM_RE(me_readMem),
    .MEM_PC_SRC(me_pcImm_NEXTPC_rs1Imm),
    .MEM_BRANCH(me_conditionBranch),
    .MEM_PC_IMM(me_pcImm),
    .MEM_RS1_IMM(me_rs1Imm),
    .MEM_ALU_OUT(me_outAlu),
    .MEM_RS2_DATA(me_rs2Data),
    .MEM_RD(me_rd),
    .MEM_RS2(me_rs2)
);

MUX_2 MUX_WB_DATA(
    .signal(forwardC),
    .a(me_rs2Data),
    .b(wb_rdData),

    .out(me_true_rs2Data)
);

DATA_MEM data_mem(
    .clk(clk),
    .rst(rst),
    .addr(me_outAlu),
    .din(me_true_rs2Data),
    .mem_we(me_writeMem),
    .mem_re(me_readMem),

    .dout(me_outMem)
);

MEM_WB mem_wb(
    .clk(clk),
    .rst(rst),
    .mem_to_reg(me_aluOut_WB_memOut),
    .mem_to_reg(me_writeReg),
    .mem_outMem(me_outMem),
    .mem_outAlu(me_outAlu),
    .mem_rd(me_rd),

    .wb_to_reg(wb_aluOut_WB_memOut),
    .wb_reg_we(wb_writeReg),
    .wb_outMem(wb_outMem),
    .wb_outAlu(wb_outAlu),
    .wb_rd(wb_rd)
);

MUX_2 MUX_WB(
    .signal(wb_aluOut_WB_memOut),
    .a(wb_outAlu),
    .b(wb_outMem),

    .out(wb_rdData)
);
endmodule