module Hazard_Detection(
    input [2: 0] ex_readMem, // read memory signal from ex stage
    input [4: 0] ex_rd, id_rs1, id_rs2,

    output stall 
);

assign stall = (ex_readMem != 3'b000) && 
               (ex_rd != 5'd0) && 
               ((ex_rd == id_rs1) || (ex_rd == id_rs2));

endmodule