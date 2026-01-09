`timescale 1ns/1ps
/*
Control Unit for Mini 4-bit RISC-V CPU
Decodes 16-bit instructions and generates 7 control signals for the datapath.

Supported Instructions and Opcodes:
    - ADD (R-type):     opcode = 4'b0000
        rd = rs1 + rs2

    - ADDI (I-type):    opcode = 4'b0001
        rd = rs1 + immediate

    - LD (I-type):      opcode = 4'b0010
        rd = memory[rs1 + immediate]

    - SW (S-type):      opcode = 4'b0011
        memory[rs1 + immediate] = rs2

Control Signals:
    - ImmSel  : Immediate selection (for ALU B input)
                0 = ignore immediate (use rs2), 1 = use immediate
    - RegWEn  : Register write enable
                1 = write to rd, 0 = do not write
    - BSel    : ALU B input select (0 = rs2, 1 = immediate)
    - ALUSel  : ALU operation code
                3'b000 = ADD
    - MemRW   : Memory read/write
                0 = read memory, 1 = write memory
    - WBsel   : Write-back select
                0 = write memory data to register
                1 = write ALU result to register

Instruction Format (16 bits):
    - R-type (ADD):
        [15:12] opcode
        [11:9]  rd
        [8:6]   rs1
        [5:3]   rs2
        [2:0]   unused
    - I-type (ADDI, LD):
        [15:12] opcode
        [11:9]  rd
        [8:6]   rs1
        [5:0]   immediate
    - S-type (SW):
        [15:12] opcode
        [11:9]  rs2 (data to store)
        [8:6]   rs1 (base address)
        [5:0]   immediate (offset)
*/

module control(
    input  wire [15:0] inst,       // Full 16-bit instruction
    output reg        ImmSel,      // ALU B source select (0=rs2, 1=imm)
    output reg        RegWEn,      // Register write enable
    output reg        BSel,        // ALU B input select (0=rs2, 1=imm)
    output reg  [2:0] ALUSel,      // ALU operation
    output reg        MemRW,       // Memory read/write (0=read, 1=write)
    output reg        WBsel        // Write-back select (0=memory, 1=ALU)
);

    wire [3:0] opcode;
    assign opcode = inst[15:12];

    always @(*) begin
        // Defaults
        ImmSel  = 1'b0;
        RegWEn  = 1'b0;
        BSel    = 1'b0;
        ALUSel  = 3'b000;
        MemRW   = 1'b0;  // 0 = read, 1 = write
        WBsel   = 1'b1;  // Default to ALU (1)

        case (opcode)
            // ADD
            4'b0000: begin
                RegWEn  = 1'b1;   // write to rd
                ImmSel  = 1'b0;
                BSel    = 1'b0;   // rs2
                ALUSel  = 3'b000; // ADD
                MemRW   = 1'b0;
                WBsel   = 1'b1;   // ALU result
            end

            // ADDI
            4'b0001: begin
                RegWEn  = 1'b1;
                ImmSel  = 1'b1;   // use immediate
                BSel    = 1'b1;
                ALUSel  = 3'b000; // ADD
                MemRW   = 1'b0;
                WBsel   = 1'b1;   // ALU result
            end

            // LD: Load
            4'b0010: begin
                RegWEn  = 1'b1;
                ImmSel  = 1'b1;   // ALU B = imm for address
                BSel    = 1'b1;
                ALUSel  = 3'b000; // ADD (address calculation)
                MemRW   = 1'b0;   // read memory
                WBsel   = 1'b0;   // write-back from memory
            end

            // SW: Store
            4'b0011: begin
                RegWEn  = 1'b0;   // don't write to reg
                ImmSel  = 1'b1;   // ALU B = imm for address calc
                BSel    = 1'b1;
                ALUSel  = 3'b000; // ADD (compute address)
                MemRW   = 1'b1;   // write memory
                WBsel   = 1'b1;   // irrelevant (won't write back)
            end

            // Default: NOP
            default: begin
                RegWEn  = 1'b0;
                ImmSel  = 1'b0;
                BSel    = 1'b0;
                ALUSel  = 3'b000;
                MemRW   = 1'b0;
                WBsel   = 1'b1;   // default to ALU
            end
        endcase
    end

endmodule
