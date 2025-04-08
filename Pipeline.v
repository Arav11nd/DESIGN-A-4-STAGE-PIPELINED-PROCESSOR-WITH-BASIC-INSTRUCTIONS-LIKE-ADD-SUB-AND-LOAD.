module pipelined_processor (
  input clk,
  input reset,
  input [31:0] instruction_in, // Instruction input
  output reg [31:0] result_out // Result output
);

  // Instruction fields
  wire [5:0] opcode;
  wire [4:0] rd;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [15:0] immediate;

  assign opcode = instruction_in[31:26];
  assign rd = instruction_in[25:21];
  assign rs1 = instruction_in[20:16];
  assign rs2 = instruction_in[15:11];
  assign immediate = instruction_in[15:0];

  // Registers
  reg [31:0] registers [31:0];

  // Pipeline registers
  reg [31:0] if_id_instruction;
  reg [31:0] id_ex_instruction;
  reg [31:0] ex_mem_wb_instruction;

  reg [31:0] id_ex_rs1_data;
  reg [31:0] id_ex_rs2_data;
  reg [31:0] ex_mem_wb_result;
  reg [31:0] ex_mem_wb_memory_address;

  // Memory (simplified)
  reg [31:0] memory [1023:0]; // 1KB memory

  // Integer for loop counters
  integer i;

  // Stages
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      if_id_instruction <= 32'b0;
      id_ex_instruction <= 32'b0;
      ex_mem_wb_instruction <= 32'b0;
      result_out <= 32'b0;
      // Initialize memory and registers
      for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
      for (i = 0; i < 1024; i = i + 1) memory[i] <= 32'b0;
    end else begin
      // MEM/WB Stage
      if (ex_mem_wb_instruction[31:26] == 6'b000000 || ex_mem_wb_instruction[31:26] == 6'b000001 || ex_mem_wb_instruction[31:26] == 6'b000010) begin // ADD, SUB, LOAD
        registers[ex_mem_wb_instruction[25:21]] <= ex_mem_wb_result;
      end
      result_out <= registers[1]; // for example, result is in reg 1.

      // EX Stage
      case (id_ex_instruction[31:26])
        6'b000000: ex_mem_wb_result <= id_ex_rs1_data + id_ex_rs2_data; // ADD
        6'b000001: ex_mem_wb_result <= id_ex_rs1_data - id_ex_rs2_data; // SUB
        6'b000010: begin // LOAD
          ex_mem_wb_memory_address <= id_ex_rs1_data + id_ex_instruction[15:0];
          ex_mem_wb_result <= memory[ex_mem_wb_memory_address >> 2]; // Memory access (word aligned)
        end
        default: ex_mem_wb_result <= 32'b0;
      endcase
      ex_mem_wb_instruction <= id_ex_instruction;

      // ID Stage
      id_ex_rs1_data <= registers[id_ex_instruction[20:16]];
      id_ex_rs2_data <= registers[id_ex_instruction[15:11]];
      id_ex_instruction <= if_id_instruction;

      // IF Stage
      if_id_instruction <= instruction_in;
    end
  end

endmodule
