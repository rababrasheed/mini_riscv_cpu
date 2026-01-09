`timescale 1ns/1ps

module tb_cpu;

    // Clock & Reset Signals
    reg clk;       // System clock
    reg reset;     // Active-high reset

    // DUT (Device Under Test) Outputs
    // Exposed output from the CPU used for monitoring execution
    wire [3:0] pc_out;   // Program Counter value

    // Instantiate the CPU (DUT)
    cpu dut (
        .clk(clk),       // Drive CPU clock
        .reset(reset),   // Drive CPU reset
        .pc_out(pc_out)  // Observe PC value
    );

    // Clock Generation
    // Clock toggles every 5ns
    // 10ns clock period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset Sequence
    initial begin
        reset = 1;   // Assert reset
        #12;         // Hold reset long enough to cross a clock edge
        reset = 0;   // Deassert reset, CPU begins execution
    end

    // Generate waveform dump for viewing in GTKWave
    initial begin
        $dumpfile("../results/cpu_tb.vcd");
        $dumpvars(0, tb_cpu);
    end

    // Execution Monitor
    initial begin
        $display("Time | PC | Instr | x1 x2 x3 x4 x5 | DMEM[2] DMEM[3]");

        forever begin
            @(posedge clk); // Wait for rising edge of clock (instruction completes)

            #1; // Small delay to allow combinational logic to settle

            // Display current CPU state
            $display(
                "%4t | %2d | %h |  %d  %d  %d  %d  %d |    %d       %d",
                $time,                         // Simulation time
                pc_out,                        // Program counter
                dut.instruction,               // Current instruction
                dut.register_file.regs[1],     // x1
                dut.register_file.regs[2],     // x2
                dut.register_file.regs[3],     // x3
                dut.register_file.regs[4],     // x4
                dut.register_file.regs[5],     // x5
                dut.data_memory.mem[2],        // Data memory addr 2
                dut.data_memory.mem[3]         // Data memory addr 3
            );

            // Stop simulation after program finishes (PC > last valid instruction)
            if (pc_out == 4'd7) begin
                $display("Program finished.");
                $finish;
            end
        end
    end

endmodule
