module EX_MEM(
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,      
    input  wire        flush,      

    // EX stage 
    input         EX_WB_SRC,       // 0 = ALU, 1 = Load
    input         EX_REG_WE,       // RF write-enable
    input         EX_BRANCH,       // branch condition
    input [1:0]   EX_MEM_WE,       // store type
    input [2:0]   EX_MEM_RE,       // load type
    input [1:0]   EX_PC_SRC,       // next-PC selection
    

    input [31:0]  EX_PC_IMM,       // PC+imm
    input [31:0]  EX_RS1_IMM,      // Rs1 + Imm
    input [31:0]  EX_ALU_OUT,      // ALU output
    input [31:0]  EX_RS2_DATA,     // stor data
    input [4:0]   EX_RD,           // destination register
    input [4:0]   EX_RS2,          // rs2 index(store)

    //  MEM stage 
    output reg        MEM_WB_SRC,
    output reg        MEM_REG_WE,
    output reg        MEM_BRANCH,
    output reg [1:0]  MEM_MEM_WE,
    output reg [2:0]  MEM_MEM_RE,
    output reg [1:0]  MEM_PC_SRC,
    
    output reg [31:0] MEM_PC_IMM,
    output reg [31:0] MEM_RS1_IMM,
    output reg [31:0] MEM_ALU_OUT,
    output reg [31:0] MEM_RS2_DATA,
    output reg [4:0]  MEM_RD,
    output reg [4:0]  MEM_RS2
);

//==============================================================
//  EX/MEM Register behavior
//==============================================================
always @(posedge clk) begin
    if (rst || flush) begin
        MEM_Thread_ID <= 2'b00;

        MEM_WB_SRC    <= 1'b0;
        MEM_REG_WE    <= 1'b0; 
        MEM_MEM_WE    <= 2'b00;
        MEM_MEM_RE    <= 3'b000;
        MEM_PC_SRC    <= 2'b00;
        MEM_BRANCH    <= 1'b0;

        MEM_PC_IMM    <= 32'd0;
        MEM_RS1_IMM   <= 32'd0;
        MEM_ALU_OUT   <= 32'd0;
        MEM_RS2_DATA  <= 32'd0;
        MEM_RD        <= 5'd0;
        MEM_RS2       <= 5'd0;
    end 
    else if (!pause) begin
        MEM_Thread_ID <= EX_Thread_ID;

        MEM_WB_SRC    <= EX_WB_SRC;
        MEM_REG_WE    <= EX_REG_WE;
        MEM_MEM_WE    <= EX_MEM_WE;
        MEM_MEM_RE    <= EX_MEM_RE;
        MEM_PC_SRC    <= EX_PC_SRC;
        MEM_BRANCH    <= EX_BRANCH;

        MEM_PC_IMM    <= EX_PC_IMM;
        MEM_RS1_IMM   <= EX_RS1_IMM;
        MEM_ALU_OUT   <= EX_ALU_OUT;
        MEM_RS2_DATA  <= EX_RS2_DATA;
        MEM_RD        <= EX_RD;
        MEM_RS2       <= EX_RS2;
    end
end

endmodule