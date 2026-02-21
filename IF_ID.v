module IF_ID(
    input clk, rst, pause, flush;
    //IF stage
    input [31:0] PC_IF;
    input [31:0] Inst_IF;
    // output for ex stage
    output reg  [31:0] PC_ID,
    output reg  [31:0] Inst_ID,

    output wire [6:0]  func7,
    output wire [4:0]  rs2,
    output wire [4:0]  rs1,
    output wire [2:0]  func3,
    output wire [4:0]  rd,
    output wire [6:0]  opcode
);

assign func7  = Inst_ID[31:25];
assign rs2    = Inst_ID[24:20];
assign rs1    = Inst_ID[19:15];
assign func3  = Inst_ID[14:12];
assign rd     = Inst_ID[11:7];
assign opcode = Inst_ID[6:0];


always@(posedge clk) begin
  if (rst || flush) begin 
    PC_ID <= 32'd0;
    Inst_ID <= 32'h00000013;
  end else if (!pause) begin
    PC_ID <= PC_IF;
    Inst_ID <= Inst_IF;
end


