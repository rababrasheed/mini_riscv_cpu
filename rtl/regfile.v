`timescale 1ns/1ps
/*
 RISC-V Register File (4-bit mini implementation)
 This module implements the register file for a mini RISC-V CPU with:
   - 8 registers (x0-x7), each 4 bits wide
   - 2 asynchronous read ports (for rs1 and rs2)
   - 1 synchronous write port (for rd)
   - Hardware enforcement of x0 = 0 (RISC-V requirement)
*/

module regfile(
    input  wire       clk,       // Clock signal for synchronous writes
    input  wire       rst,       // Synchronous reset
    input  wire       we,        // Write enable: 1 = write rd_data to rd_addr
    input  wire [2:0] rd_addr,   // Destination register address (0-7)
    input  wire [2:0] rs1_addr,  // Source register 1 address (0-7)
    input  wire [2:0] rs2_addr,  // Source register 2 address (0-7)
    input  wire [3:0] rd_data,   // Data to write to destination register
    output wire [3:0] rs1_data,  // Data read from source register 1
    output wire [3:0] rs2_data   // Data read from source register 2
);

// Register file: 8 registers, 4 bits each
    reg [3:0] regs [7:0];
    integer i;
    
// Combinational logic
// Register 0 is hardwired to 0 
    assign rs1_data = (rs1_addr == 0) ? 4'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 4'b0 : regs[rs2_addr];
    
// WRITE + RESET: Sequential logic (synchronous reset)
    always @(posedge clk) begin
        if (rst) begin
            // Reset: Clear all registers to 0
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 4'b0;
        end
        else if (we && rd_addr != 0) begin
            // Write: Only write if enabled and not writing to register 0
            regs[rd_addr] <= rd_data;
        end
    end
endmodule