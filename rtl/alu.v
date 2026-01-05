`timescale 1ns/1ps

// 4-bit ALU supporting basic arithmetic, logic, and SLT operations
// Flags: carry_out, overflow, zero 
module alu (
    input  wire [3:0] a,         // 4-bit operand A
    input  wire [3:0] b,         // 4-bit operand B
    input  wire [2:0] op,        // Operation selector
    output reg  [3:0] y,         // 4-bit result
    output reg        carry_out, // Carry-out flag (unsigned arithmetic) 
    output reg        overflow,  // Overflow flag (signed arithmetic)
    output wire       zero       // Zero flag (high if result is zero)
);

    always @(*) begin
        // Default assignments
        y = 4'b0000;
        carry_out = 1'b0;
        overflow = 1'b0;
        
        case(op)
            3'b000: begin // ADD
                {carry_out, y} = a + b;
                overflow = ~(a[3] ^ b[3]) & (y[3] ^ a[3]);
            end
            
            3'b001: begin // SUB
                y = a - b;
                carry_out = (a >= b) ? 1'b1 : 1'b0; // 1 = no borrow
                overflow = (a[3] ^ b[3]) & (y[3] ^ a[3]);
            end
            
            3'b010: y = a & b;  // AND
            3'b011: y = a | b;  // OR
            3'b100: y = a ^ b;  // XOR
            
            3'b101: // SLT (set less than, signed)
                y = ($signed(a) < $signed(b)) ? 4'b0001 : 4'b0000;
            
            default: y = 4'b0000;
        endcase 
    end

    // Zero flag: high if result is zero
    assign zero = (y == 4'b0000);

endmodule