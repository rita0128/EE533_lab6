// tb_fetch.v -- minimal fetch testbench
`timescale 1ns/1ps
module tb_fetch;
  reg clk = 0;
  reg rst = 1;
  integer cycle = 0;

  // instruction memory (enough words)
  reg [31:0] instr_mem [0:65535];

  // program counter (byte-addressed)
  reg [31:0] pc;

  // fetched instruction
  wire [31:0] instr_word;
  assign instr_word = instr_mem[pc >> 2];

  // clock
  always #5 clk = ~clk;

  initial begin
    // load instruction memory from file
    $display("Loading instr.mem ...");
    $readmemh("instr.mem", instr_mem);
    // optional: print first few entries
    $display("instr_mem[0]=0x%08h instr_mem[1]=0x%08h instr_mem[2]=0x%08h", instr_mem[0], instr_mem[1], instr_mem[2]);
    // reset
    pc = 0;
    #12;
    rst = 0;
    // run some cycles
    repeat (40) begin
      @(posedge clk);
      cycle = cycle + 1;
      $display("CYCLE %0d PC=0x%08h INSTR=0x%08h", cycle, pc, instr_word);
      // simple PC update like a normal CPU fetch: increment by 4
      pc = pc + 4;
    end
    $display("Done.");
    $finish;
  end
endmodule
