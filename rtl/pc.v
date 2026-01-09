`timescale 1ns/1ps
/*
 Program Counter (PC) Module
 The Program Counter holds the address of the current instruction being
 executed. It updates on each clock cycle to point to the next instruction.

 Features:
   - 4-bit address space (can address 16 instruction locations: 0-15)
   - Synchronous update on clock rising edge
   - Asynchronous reset to address 0
*/

module pc(
    input  wire       clk,      // Clock signal for synchronous PC updates
    input  wire       reset,    // Asynchronous reset: sets PC to 0
    input  wire [3:0] next_pc,  // Next PC value (PC+1 for sequential)
    output reg  [3:0] pc_out    // Current PC value (instruction address)
);

    // Program Counter Register
    // Updates on rising clock edge or asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 4'b0000;  // Reset: jump to instruction address 0
        else
            pc_out <= next_pc;   // Normal operation: load next PC value
    end

endmodule