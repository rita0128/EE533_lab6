// tb_fetch.v
`timescale 1ns/1ps
module tb_fetch;
  reg clk = 0;
  reg rst = 1;
  integer cycle = 0;
  reg [31:0] instr_mem [0:65535];
  reg [31:0] pc;

  wire [31:0] instr_word;
  assign instr_word = instr_mem[pc >> 2];

  always #5 clk = ~clk;

  initial begin
    $display("Loading instr.mem");
    $readmemh("instr.mem", instr_mem);
    pc = 0;
    #12 rst = 0;
    repeat (40) begin
      @(posedge clk);
      cycle = cycle + 1;
      $display("CYCLE %0d PC=0x%08h INSTR=0x%08h", cycle, pc, instr_word);
      pc = pc + 4;
    end
    $display("Done.");
    $finish;
  end
endmodule
