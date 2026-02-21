module ALU(
    input [4:0] ctrl,           // opcode of ALU
    input [31:0] a, b,         

    output reg [31:0] out,      // ressult of calculating
    output reg condition_branch // whether branch is taken
);

always @(*) begin

    condition_branch = 1'b0;
    out = 32'b0;
    
    case (ctrl)
        // calculating 
        5'b00000: out = a + b;
        5'b00001: out = a - b;
        5'b00010: out = a & b;
        5'b00011: out = a | b;
        5'b00100: out = a ^ b;
        
        // shifting(only take the last five bits of B[4:0])
        5'b00101: out = a << b[4:0];                    // SLL (left-shifting)
        5'b01000: out = a >> b[4:0];                    // SRL (right-shifting)
        5'b01001: out = $signed(a) >>> b[4:0];          // SRA 
        
        // compared
        5'b00110: out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT  signed
        5'b00111: out = (a < b) ? 32'b1 : 32'b0;                   // SLTU unsigned
        
        // for JALR
        5'b01010: begin 
            out = a + b;
            out[0] = 1'b0; // the last bit of TALR need to be zero
        end
        
        // Taken branch or untaken 
        5'b01011: condition_branch = (a == b);                      // BEQ
        5'b01100: condition_branch = (a != b);                      // BNE
        5'b01101: condition_branch = ($signed(a) < $signed(b));     // BLT
        5'b01110: condition_branch = ($signed(a) >= $signed(b));    // BGE
        5'b01111: condition_branch = (a < b);                       // BLTU
        5'b10000: condition_branch = (a >= b);                      // BGEU
        
        default:  out = 32'b0;
    endcase
end

endmodule