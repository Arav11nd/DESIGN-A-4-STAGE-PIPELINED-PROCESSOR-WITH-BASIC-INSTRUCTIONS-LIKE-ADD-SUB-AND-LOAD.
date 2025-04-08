// pipelined_processor_tb.v
module pipelined_processor_tb;

  reg clk;
  reg reset;
  reg [31:0] instruction_in;
  wire [31:0] result_out;

  pipelined_processor dut (
    .clk(clk),
    .reset(reset),
    .instruction_in(instruction_in),
    .result_out(result_out)
  );

  initial begin
    clk = 1;
    reset = 1;

    #10;
    reset = 0;

    // Example Instructions (ADD, SUB, LOAD)
    instruction_in = 32'b000000_00001_00010_00011_0000000000000000; // ADD R1, R2, R3
    #10;
    instruction_in = 32'b000001_00100_00001_00101_0000000000000000; // SUB R4, R1, R5
    #10;
    instruction_in = 32'b000010_00110_00111_0000000001100100; // LOAD R6, 100(R7)
    #10;
    instruction_in = 32'b000000_01000_00110_00100_0000000000000000; // ADD R8, R6, R4
    #100;
    $finish;
  end

  always #5 clk = ~clk;

  initial begin
    // Initialize registers and memory
    dut.registers[2] = 32'd20;
    dut.registers[3] = 32'd10;
    dut.registers[5] = 32'd5;
    dut.registers[7] = 32'd0;
    dut.memory[25] = 32'd100; // memory address 100/4 = 25
  end

  initial begin
    $monitor("Time=%0t, result_out=%d, R1=%d, R4=%d, R6=%d, R8=%d", $time, result_out, dut.registers[1], dut.registers[4], dut.registers[6], dut.registers[8]);
  end

endmodule
