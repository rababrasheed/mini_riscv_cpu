`timescale 1ns/1ps
/*
Immediate Generator (IMMGEN)
Extracts and sign-extends immediate values from instructions.

 Input Format:
   - 16-bit instruction with immediate in bits [5:0]

 Output:
   - 4-bit sign-extended immediate value
*/

module immgen(
    input  wire [15:0] instr,  // Full 16-bit instruction
    output wire [3:0]  imm     // 4-bit sign-extended immediate
);
    // Extract the 6-bit immediate
    wire [5:0] imm6 = instr[5:0];

    // Take the lower 4 bits for 4-bit ALU
    assign imm = imm6[3:0];

endmodule

