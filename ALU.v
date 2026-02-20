module ALU(
    input[4: 0] ALU_ctrl,
    input [31: 0] A, B,

    output reg [31: 0] result, 
    output reg condition_branch
);

always @(*) begin
    condition_branch = 0;
    result = 32'b0;
    case (ALU_ctrl)
        5'b00000: result = A + B;
        5'b00001: result = A - B;
        5'b00010: result = A & B;
        5'b00011: result = A | B;
        5'b00100: result = A ^ B;
        5'b00101: result = A << B;
        5'b00110: result = ($signed(a) < ($signed(b))) ? 32'b1 : 32'b0;
        5'b00111: result = (A < B) ? 32'b1 : 32'b0;
        5'b01000: result = A >> B;
        5'b01001: result = ($signed(a)) >>> B;
        5'b01010: begin 
            result = A + B;
            result[0] = 1'b0;
        end
        5'b01011: condition_branch = (A == B) ? 1'b1 : 1'b0;
        5'b01100: condition_branch = (A != B) ? 1'b1 : 1'b0;
        5'b01101: condition_branch = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
        5'b01110: condition_branch = ($signed(A) >= $signed(B)) ? 1'b1 : 1'b0;
        5'b01111: condition_branch = (A < B) ? 1'b1: 1'b0;
        5'b10000: condition_branch = (A >= B) ? 1'b1: 1'b0;
        default: result = 32'b0;
    endcase
end

endmodule