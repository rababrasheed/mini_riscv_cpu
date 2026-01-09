#!/bin/bash
set -e

# Compile RTL + testbench
iverilog -g2012 \
    -o cpu_sim \
    ../rtl/*.v \
    ../tb/cpu_tb.v

# Run simulation (generates VCD)
vvp cpu_sim

