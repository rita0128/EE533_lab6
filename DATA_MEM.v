module DATA_MEM(
    input clk, rst, 
    input [1: 0] mem_we, 
    input [2: 0] mem_re,

    input [31: 0] addr, din,

    output reg [31: 0] dout
);

reg [7: 0] data [127: 0];

wire [31:0] val0 = {data[3], data[2], data[1], data[0]};
wire [31:0] val1 = {data[7], data[6], data[5], data[4]};
wire [31:0] val2 = {data[11], data[10], data[9], data[8]};
wire [31:0] val3 = {data[15], data[14], data[13], data[12]};
wire [31:0] val4 = {data[19], data[18], data[17], data[16]};
wire [31:0] val5 = {data[23], data[22], data[21], data[20]};
wire [31:0] val6 = {data[27], data[26], data[25], data[24]};
wire [31:0] val7 = {data[31], data[30], data[29], data[28]};
wire [31:0] val8 = {data[35], data[34], data[33], data[32]};
wire [31:0] val9 = {data[39], data[38], data[37], data[36]};

always @(*) begin
    case (mem_re[1: 0])
        2'b00:begin
            dout = 32'b0;
        end
        2'b01:begin
            dout = {data[addr + 3], data[addr + 2], data[addr + 1], data[addr]};
        end
        2'b10:begin
            if(mem_re[2]) dout = {{16{data[addr + 1][7]}}, data[addr + 1], data[addr]};
            else dout = {16'b0, data[addr + 1], data[addr]};
        end
        2'b11:begin
            if(mem_re[2]) dout = {{24{data[addr][7]}}, data[addr]};
            else dout = {24'b0, data[addr]};
        end 
        default:begin
            dout = 32'b0;
        end
    endcase
end

always @(posedge clk) begin
    case (mem_we)
        2'b01:begin
            data[addr + 3] = din[31: 24];
            data[addr + 2] = din[23: 16];
            data[addr + 1] = din[15: 8];
            data[addr] = din[7: 0];
        end
        2'b10:begin
            data[addr + 1] = din[15: 8];
            data[addr] = din[7: 0];
        end
        2'b11:begin
            data[addr] = din[7: 0];
        end 
        default: begin
            
        end
    endcase
end

initial begin
    // num:323 (0x00000143) - store at data[0]~data[3]
    data[0]  = 8'h43;  
    data[1]  = 8'h01;
    data[2]  = 8'h00;
    data[3]  = 8'h00; 
    
    // num 123 (0x0000007B) - store at data[4]~data[7]
    data[4]  = 8'h7B;
    data[5]  = 8'h00;
    data[6]  = 8'h00;
    data[7]  = 8'h00;
    
    // num -455 (0xFFFFFE39) - store at data[8]~data[11]
    data[8]  = 8'h39;
    data[9]  = 8'hFE;
    data[10] = 8'hFF;
    data[11] = 8'hFF;
    
    // num 2 (0x00000002) - store at data[12]~data[15]
    data[12] = 8'h02;
    data[13] = 8'h00;
    data[14] = 8'h00;
    data[15] = 8'h00;
    
    // num 98 (0x00000062) - store at data[16]~data[19]
    data[16] = 8'h62;
    data[17] = 8'h00;
    data[18] = 8'h00;
    data[19] = 8'h00;
    
    // num 125 (0x0000007D) - store at data[20]~data[23]
    data[20] = 8'h7D;
    data[21] = 8'h00;
    data[22] = 8'h00;
    data[23] = 8'h00;
    
    // num 10 (0x0000000A) - store at data[24]~data[27]
    data[24] = 8'h0A;
    data[25] = 8'h00;
    data[26] = 8'h00;
    data[27] = 8'h00;
    
    // num 65 (0x00000041) - store at data[28]~data[31]
    data[28] = 8'h41;
    data[29] = 8'h00;
    data[30] = 8'h00;
    data[31] = 8'h00;
    
    // num -56 (0xFFFFFFC8) - store at data[32]~data[35]
    data[32] = 8'hC8;
    data[33] = 8'hFF;
    data[34] = 8'hFF;
    data[35] = 8'hFF;
    
    // num 0 (0x00000000) - store data[36]~data[39]
    data[36] = 8'h00;
    data[37] = 8'h00;
    data[38] = 8'h00;
    data[39] = 8'h00;
end
endmodule