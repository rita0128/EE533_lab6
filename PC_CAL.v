module PC_CAL(
    input [31: 0] pc,
    input [31: 0] imm32,
    input [31: 0] rs1_data,

    output reg [31: 0] pcImm,
    output reg [31: 0] rs1Imm
);

always @(*) begin
    pcImm = pc + imm32;
    rs1Imm = rs1_data + imm32;
end
endmodule