module Reg_file(
    input rst_n, clk, reg_we,
    input [4: 0] rs1, rs2, rd,
    input [31: 0] rd_data,

    output reg [31: 0] rs1_data,
    output reg [31: 0] rs2_data
);

reg [31: 0] regs[31: 0];

always @(posedge clk) begin
    if(reg_we && (rd != 5'h0)) regs[rd] = rd_data;
end

integer i;

initial begin
    for (i = 0; i < 32; i = i + 1) begin
        regs[i] = 32'd0;
    end
    regs[5'd2] = 32'd128;
    
end

always @(*) begin
    if(rs1 == 5'h0)begin
        rs1_data = 32'h0000_0000;
    end else begin
        if(rs1 == rd)begin
            rs1_data = rd_data;
        end else begin
            rs1_data = regs[rs1];
        end
    end
end

always @(*) begin
    if(rs2 == 5'h0)begin
        rs2_data = 32'h0000_0000;
    end else begin
        if(rs2 == rd)begin
            rs2_data = rd_data;
        end else begin
            rs2_data = regs[rs2];
        end
    end
end

endmodule