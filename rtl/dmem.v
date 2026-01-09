`timescale 1ns/1ps
/*
 Data Memory (DMEM) - Mini RISC-V

 Read/Write memory for load and store instructions.

 Design Parameters:
   - 16 memory locations (4-bit address space)
   - 4-bit data width (matches register width)
   - Synchronous write (on clock edge)
   - Asynchronous read (combinational)
*/

module dmem(
    input  wire       clk,        // Clock for synchronous writes
    input  wire       we,         // Write enable: 1 = write, 0 = read
    input  wire [3:0] addr,       // Memory address (0-15)
    input  wire [3:0] write_data, // Data to write (from register)
    output reg  [3:0] read_data   // Data read from memory
);

    // Memory array: 16 locations x 4 bits
    reg [3:0] mem [0:15];
    integer i;

    // Initialize memory with demo data
    initial begin
        // Initialize all memory to zero
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 4'b0000;

        mem[0] = 4'b0011;  // 3
        mem[1] = 4'b0111;  // 7
        mem[2] = 4'b1010;  // 10
        mem[3] = 4'b0101;  // 5
        mem[4] = 4'b1111;  // 15
        mem[5] = 4'b0001;  // 1
    end

    // Asynchronous read: always output the current memory value
    always @(*) begin
        read_data = mem[addr];
    end

    // Synchronous write: occurs on rising edge of clk
    always @(posedge clk) begin
        if (we)
            mem[addr] <= write_data;
    end

endmodule
