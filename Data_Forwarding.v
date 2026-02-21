module Data_Forwarding(
    
    //from MEM_WB
    input mem_reg_we, wb_reg_we,
    input [4: 0] mem_rd, wb_rd,

    //from EX_MEM
    input [4: 0] ex_rs1, ex_rs2,
    input [4: 0] mem_rs2,

    // signal for mux
    output reg [1: 0] fwd_a_sel, fwd_b_sel,
    output reg fwd_c_sel
);

always @(*) begin
    
    fwd_a_sel = 2'b00;
    fwd_b_sel  = 2'b00;
    fwd_c_sel = 1'b0;

    //forward to rs1
    if(mem_reg_we && (mem_rd != 5'd0) && (mem_rd == ex_rs1)) begin
        fwd_a_sel = 2'b01; // from MEM
    end else if (wb_reg_we && (wb_rd != 5'd0) && (wb_rd == ex_rs1)) begin
        fwd_a_sel = 2'b10; // from WB
    end else begin
        fwd_a_sel = 2'b00;  // no forward, using the original data
    end

    //forward to rs2
    if(mem_reg_we && (mem_rd != 5'd0) && (mem_rd == ex_rs2)) begin
        fwd_b_sel = 2'b01;
    end else if (wb_reg_we && (wb_rd != 5'd0) && (wb_rd == ex_rs2)) begin
        fwd_b_sel = 2'b10; 
    end else begin
        fwd_b_sel = 2'b00;  // no forward, using the original data
    end

    // lw followed by sw hazard
    if(wb_reg_we && (wb_rd != 5'd0) && (wb_rd == me_rs2)) begin
        fwd_c_sel = 1'b1;
    end
end


endmodule
