module PC(
    input rst_n, clk, pause, flush,
    input [31: 0] pc_next,

    output reg [31: 0] pc
);

always @(posedge clk) begin
    if(rst_n) begin
        pc <= 32'h0;
    end else if(flush) begin
        pc <= pc_next;
    end else if(pause) begin
        pc <= pc;
    end else begin
        pc <= pc_next;
    end 
end

endmodule