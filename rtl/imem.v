`timescale 1ns/1ps
/*
 Instruction Memory (IMEM)
 Read-only memory that stores the program instructions for the CPU.
 
 Design Parameters:
   - 16 instruction locations (4-bit address space)
   - 16-bit instruction width
   - Read-only, combinational
   - Hardcoded program for demonstration

Instruction Format (16 bits):
    R-type (ADD):
     [15:12] opcode = 4'b0000
     [11:9]  rd     (destination register)
     [8:6]   rs1    (source register 1)
     [5:3]   rs2    (source register 2)
     [2:0]   unused

    I-type (ADDI, LD):
     [15:12] opcode = 4'b0001 (ADDI) or 4'b0010 (LD)
     [11:9]  rd     (destination register)
     [8:6]   rs1    (source register 1)
     [5:0]   imm    (6-bit signed immediate)

    S-type (SW):
     [15:12] opcode = 4'b0011
     [11:9]  rs1     (base register for address)
     [8:6]   rs2     (register to store)
     [5:0]   imm     (6-bit immediate offset)
*/

module imem(
    input  wire [3:0]  addr,    // PC address (0-15)
    output reg  [15:0] instr    // Instruction at that address
);

    // Instruction Memory Array
    // Stores up to 16 instructions, each 16 bits wide
    reg [15:0] mem [0:15];
    integer i;

    // Program Initialization
    // Hardcoded test program demonstrating ADD, ADDI, LD, and SW instructions
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 16'h0000;

        // Example program:
        // addr[0]: ADDI x1, x0, 5     -> x1 = 0 + 5 = 5
        //          opcode=0001, rd=001, rs1=000, imm=000101
        mem[0] = 16'b0001_001_000_000101;
        
        // addr[1]: ADDI x2, x0, 2     -> x2 = 0 + 2 = 2 
        //          opcode=0001, rd=010, rs1=000, imm=000010
        mem[1] = 16'b0001_010_000_000010;
        
        // addr[2]: LD x3, 0(x2)       -> x3 = mem[2+0] = mem[2]
        //          opcode=0010, rd=011, rs1=010, imm=000000
        mem[2] = 16'b0010_011_010_000000;
        
        // addr[3]: ADD x4, x1, x3     -> x4 = x1 + x3 = 5 + mem[2]
        //          opcode=0000, rd=100, rs1=001, rs2=011, unused=000
        mem[3] = 16'b0000_100_001_011_000;
        
        // addr[4]: ADD x5, x4, x1     -> x5 = x4 + x1
        //          opcode=0000, rd=101, rs1=100, rs2=001, unused=000
        mem[4] = 16'b0000_101_100_001_000;

        // addr[5]: SW x5, 1(x2)  -> store x5 to mem[x2 + 1]
        //          opcode=0011, rs1=010 (x2), rs2=101 (x5), imm=000001
        mem[5] = 16'b0011_010_101_000001;
    end
    
    // Asynchronous Read
    always @(*) begin
       instr = mem[addr];
    end

endmodule
