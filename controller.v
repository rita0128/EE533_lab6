module controller(
    input [6: 0] opcode,
    input [2: 0] func3,
    input [6: 0] func7,

    output reg [4: 0] ALU_Op,
    output reg rf_src, ALU_A, 
    output reg [1: 0] ALU_B,
    output reg reg_we, 
    output reg [1: 0] mem_we, 
    output reg [2: 0] mem_re,
    output reg [2: 0] imm_type,
    output reg [1: 0] pc_src
);

always @(*) begin
    case (opcode)
        // lui
        7'b0110111:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 0;
            ALU_B = 2'b01;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b00000;
            pc_src = 2'b00;
            imm_type = 3'b001;
        end
        // auipc
        7'b0010111:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 1;
            ALU_B = 2'b01;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b00000;
            pc_src = 2'b00;
            imm_type = 3'b001;
        end
        // jal
        7'b1101111:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 1;
            ALU_B = 2'b11;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b00000;
            pc_src = 2'b01;
            imm_type = 3'b100;
        end
        // jalr
        7'b1100111:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 1;
            ALU_B = 2'b11;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b01010;
            pc_src = 2'b10;
            imm_type = 3'b000;
        end
        // B-type
        7'b1100011:begin
            reg_we = 0;
            rf_src = 0;
            ALU_A = 0;
            ALU_B = 2'b00;
            mem_we = 2'b00;
            mem_re = 3'b000;
            pc_src = 2'b00;
            imm_type = 3'b011;
            case (func3)
                // beq
                3'b000:begin
                    ALU_Op = 5'b01011;
                end
                // bne
                3'b001:begin
                    ALU_Op = 5'b01100;
                end
                // blt
                3'b100: begin
                    ALU_Op = 5'b01101;
                end
                // bge
                3'b101:begin
                    ALU_Op = 5'b01110;
                end
                // bltu
                3'b110:begin
                    ALU_Op = 5'b01111;
                end
                // bgeu
                3'b111:begin
                    ALU_Op = 5'b10000;
                end
                default:begin
                    
                end
            endcase
        end
        // L-type
        7'b0000011:begin
            reg_we = 1;
            rf_src = 1;
            ALU_A = 0;
            ALU_B = 2'b01;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b00000;
            pc_src = 2'b00;
            imm_type = 3'b000;
            case (func3)
                // lw
                3'b010:begin
                    mem_re = 3'b001;
                end
                // lh
                3'b001:begin
                    mem_re = 3'b110;
                end
                // lb
                3'b000:begin
                    mem_re = 3'b111;
                end
                // lbu
                3'b100:begin
                    mem_re = 3'b011;
                end
                // lhu
                3'b101:begin
                    mem_re = 3'b010;
                end
                default: begin
                    
                end
            endcase
        end
        // S-type
        7'b0100011:begin
            reg_we = 0;
            rf_src = 0;
            ALU_A = 0;
            ALU_B = 2'b01;
            mem_we = 2'b00;
            mem_re = 3'b000;
            ALU_Op = 5'b00000;
            pc_src = 2'b00;
            imm_type = 3'b010;
            case (func3)
                // sw
                3'b010:begin
                    mem_we = 2'b01;
                end
                // sh
                3'b001:begin
                    mem_we = 2'b10;
                end
                // sb
                3'b000:begin
                    mem_we = 2'b11;
                end
                default: begin
                    
                end
            endcase
        end
        // I-type
        7'b0010011:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 0;
            ALU_B = 2'b01;
            mem_we = 2'b00;
            mem_re = 3'b000;
            pc_src = 2'b00;

            imm_type = 3'b000;
            case (func3)
                // addi
                3'b000:begin
                    ALU_Op = 5'b00000;
                end
                // slti
                3'b010:begin
                    ALU_Op = 5'b00110;
                end
                // sltiu
                3'b011:begin
                    ALU_Op = 5'b00111;
                end
                // xori
                3'b100:begin
                    ALU_Op = 5'b00100;
                end
                // ori
                3'b110:begin
                    ALU_Op = 5'b00011;
                end
                // andi
                3'b111:begin
                    ALU_Op = 5'b00010;
                end
                // slli
                3'b001:begin
                    ALU_Op = 5'b00101;
                end
                // srli, srai
                3'b101:begin
                    if(func7[5])begin
                        imm_type = 3'b101;
                        ALU_Op = 5'b01001;
                    end
                    else ALU_Op = 5'b01000;
                end
                default:begin
                    
                end
            endcase
        end
        // R-type
        7'b0110011:begin
            reg_we = 1;
            rf_src = 0;
            ALU_A = 0;
            ALU_B = 2'b00;
            mem_we = 2'b00;
            mem_re = 3'b000;
            pc_src = 2'b00;
            imm_type = 3'b111;
            case (func3)
                // sub, add
                3'b000:begin
                    if(func7[5])begin
                        ALU_Op = 5'b00001;
                    end else begin
                        ALU_Op = 5'b00000;
                    end
                end
                // or
                3'b110:begin
                    ALU_Op = 5'b00011;
                end
                // and
                3'b111:begin
                    ALU_Op = 5'b00010;
                end
                // xor
                3'b100:begin
                    ALU_Op = 5'b00100;
                end
                // sll
                3'b001:begin
                    ALU_Op = 5'b00101;
                end
                // slt
                3'b010:begin
                    ALU_Op = 5'b00110;
                end
                // sltu
                3'b011:begin
                    ALU_Op = 5'b00111;
                end
                // srl, sra
                3'b101:begin
                    if(func7[5]) ALU_Op = 5'b01001;
                    else ALU_Op = 5'b01000;
                end 
                default: begin
                    
                end
            endcase
        end
        default: begin
            
        end
    endcase
end

endmodule