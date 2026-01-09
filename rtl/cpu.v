`timescale 1ns/1ps
/*
 Mini 4-bit RISC-V CPU - Top Level Module
 This is a simplified single-cycle 4-bit RISC-V CPU supporting the following
 instructions:
   - ADD  (R-type): rd = rs1 + rs2
   - ADDI (I-type): rd = rs1 + imm
   - LD   (I-type): rd = mem[rs1 + imm]
   - SW   (S-type): mem[rs1 + imm] = rs2

 Architecture Details:
   - 4-bit datapath, 8 general-purpose registers (x0-x7), x0 hardwired to 0
   - Single-cycle execution: each instruction completes in one clock cycle
   - 16-word instruction memory, 16-word data memory
*/

module cpu(
    input  wire       clk,      // System clock
    input  wire       reset,    // Asynchronous reset (active high)
    output wire [3:0] pc_out    // Current program counter 
);

    // Instruction Fetch Stage Signals
    wire [3:0] pc_current;      // Current PC value
    wire [3:0] pc_next;         // Next PC value (PC + 1)
    wire [15:0] instruction;    // Instruction fetched from instruction memory

    // Instruction Fetch Stage
    // Program Counter (PC)
    pc program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );

    // Sequential PC logic: PC increments by 1 each cycle
    // (No branches or jumps implemented in this simplified design)
    assign pc_next = pc_current + 4'b0001;

    // Instruction Memory: fetch instruction at PC
    imem instruction_memory (
        .addr(pc_current),
        .instr(instruction)
    );

    // Output PC for monitoring/debugging
    assign pc_out = pc_current;


    // Decode Stage Signals
    // Common
    wire [3:0] opcode;        // Instruction opcode [15:12]

    // R-type
    wire [2:0] rd_addr;       // Destination register [11:9]
    wire [2:0] rs1_addr;      // Source register 1 [8:6]
    wire [2:0] rs2_addr;      // Source register 2 [5:3]

    // I-type (ADDI, LD)
    wire [2:0] i_rd_addr;     // Destination register [11:9]
    wire [2:0] i_rs1_addr;    // Source register 1 [8:6]
    wire [3:0] i_imm;         // Immediate (from immgen)

    // S-type (SW)
    wire [2:0] sw_base;       // Base register for store address [8:6]
    wire [2:0] sw_data;       // Register containing data to store [11:9]
    wire [3:0] sw_imm;        // Immediate (from immgen)

    // Generate all control signals based on opcode
    wire ImmSel;   // Select ALU B input: 0=rs2, 1=immediate
    wire RegWEn;   // Register write enable
    wire BSel;     // ALU B input select 
    wire [2:0] ALUSel; // ALU operation
    wire MemRW;    // Memory read/write: 0=read, 1=write
    wire WBsel;    // Write-back select: 0=memory, 1=ALU

    // Register file signals
    wire [3:0] rs1_data;  // Value from source register 1
    wire [3:0] rs2_data;  // Value from source register 2 (unused for I-type)

    // Decode Stage
    // Extract instruction fields based on the opcode and type
    assign opcode = instruction[15:12];

    // R-type
    assign rd_addr  = instruction[11:9];
    assign rs1_addr = instruction[8:6];
    assign rs2_addr = instruction[5:3];

    // I-type
    assign i_rd_addr  = instruction[11:9];
    assign i_rs1_addr = instruction[8:6];

    // S-type (SW)
    assign sw_base = instruction[8:6];
    assign sw_data = instruction[11:9];

    // Immediate generation for both I-type and S-type
    immgen immediate_generator (
        .instr(instruction),
        .imm(i_imm)   // For ADDI, LD
    );

    immgen sw_immediate_generator (
        .instr(instruction),
        .imm(sw_imm)  // For SW
    );

    // Generate control signals based on instruction
    control control_unit (
    .inst(instruction),
    .ImmSel(ImmSel),
    .RegWEn(RegWEn),
    .BSel(BSel),
    .ALUSel(ALUSel),
    .MemRW(MemRW),
    .WBsel(WBsel)
    );

    // Generate register file signals 
    regfile register_file (
    .clk(clk),
    .we(RegWEn),        // Only write in write-back stage
    .rd_addr(rd_addr),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_data(write_back_data), // Data from write-back stage
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
    );


    // Execute State Signals
    // ALU Signals
    wire [3:0] alu_input_b;     // ALU B input after mux (rs2 or immediate)
    wire [3:0] alu_result;      // ALU computation result
    wire alu_carry;             // ALU carry-out (unused)
    wire alu_overflow;          // ALU overflow flag (unused)
    wire alu_zero;              // ALU zero flag (unused)

    // Execute Stage
    // ALU B input selection (rs2 or immediate)
    wire [3:0] immediate;
    assign immediate = (opcode == 4'b0011) ? sw_imm : i_imm;
    assign alu_input_b = BSel ? immediate : rs2_data;

    // ALU computation
    alu arithmetic_logic_unit (
        .a(rs1_data),
        .b(alu_input_b),
        .op(ALUSel),
        .y(alu_result),
        .carry_out(alu_carry),
        .overflow(alu_overflow),
        .zero(alu_zero)
    );


    // Memory State Signals 
    // Memory Signals
    wire [3:0] mem_read_data;   // Data read from data memory

    // Write-Back Signals
    wire [3:0] write_back_data; // Data written back to register file

    // Memory Stage
    // Data memory handles LD and SW operations
    dmem data_memory (
    .clk(clk),
    .we(MemRW),             // write enable
    .addr(alu_result),
    .write_data(rs2_data),
    .read_data(mem_read_data)
);

    
    // Write-Back Stage
    // Select write-back source: ALU result or memory data
    assign write_back_data = WBsel ? alu_result : mem_read_data;

endmodule
