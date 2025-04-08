module pipelined_processor_tb;

  // Inputs to the DUT (Device Under Test)
  reg clk;
  reg reset;
  reg [31:0] instruction_in;

  // Outputs from the DUT
  wire [31:0] result_out;

  // Instantiate the pipelined_processor DUT
  pipelined_processor dut (
    .clk(clk),
    .reset(reset),
    .instruction_in(instruction_in),
    .result_out(result_out)
  );

  // Generate clock signal
  always #5 clk = ~clk; // Toggle clock every 5 time units

  // Stimulus and initialization
  initial begin
    // Initialize the inputs
    clk = 0;
    reset = 1;
    instruction_in = 32'b0;

    // Apply reset
    #10;
    reset = 0;

    // Apply instructions for testing
    // Test: ADD operation (R1 = R2 + R3)
    instruction_in = 32'b000000_00001_00010_00011_0000000000000000; // ADD R1, R2, R3
    #10;
    
    // Test: SUB operation (R4 = R1 - R5)
    instruction_in = 32'b000001_00100_00001_00101_0000000000000000; // SUB R4, R1, R5
    #10;

    // Test: LOAD operation (R6 = Mem[R7 + immediate])
    instruction_in = 32'b000010_00110_00111_0000000001100100; // LOAD R6, 100(R7)
    #10;

    // Test: ADD operation again (R8 = R6 + R4)
    instruction_in = 32'b000000_01000_00110_00100_0000000000000000; // ADD R8, R6, R4
    #100; // Run the simulation for a longer period to observe results

    // End the simulation after some time
    $finish;
  end

  // Monitor the outputs and display results
  initial begin
    $monitor("Time=%0t, Instruction=%b, result_out=%d", $time, instruction_in, result_out);
  end

endmodule
