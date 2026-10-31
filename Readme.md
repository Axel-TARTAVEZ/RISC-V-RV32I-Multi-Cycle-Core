# RISC-V RV32I Core - Physical Implementation Summary

**Target Device:** AMD Xilinx Spartan-7 (xc7s50csga324-1) [Urbana FPGA Board]
**Architecture:** 32-bit RISC-V (RV32I Base Integer Instruction Set), Von Neumann Architecture, Multi-cycle FSM.

## Hardware Architecture & Schematics

![RISC-V Top Architecture](RISC-V_Top.pdf)
*Figure 1: Top-level architecture and datapath integration.*

![Finite State Machine Schematics](FSM.pdf)
*Figure 2: Multi-cycle controller state transitions and control signal generation.*

## Implementation Metrics

| Category | Metric | Value | Details / Utilization |
| :--- | :--- | :--- | :--- |
| **Hardware** | Target Device (FPGA) | xc7s50csga324-1 | Urbana Board (Spartan-7) |
| | Target Clock | 100 MHz | 10 ns period |
| **Performance** | Setup Slack (WNS) | +5.643 ns | Constraints met (0 errors) |
| | Hold Slack (WHS) | +0.226 ns | Constraints met (0 errors) |
| | Max SoC Freq (F_max) | ~229.5 MHz | Calculated from WNS |
| | Max CPU Freq (F_max) | ~81.6 MHz | Evaluated via isolated run |
| **Resources (Global SoC)** | LUTs (Logic) | 1496 | 4.59% (Total available: 32600) |
| | Flip-Flops (Registers) | 1173 | 1.80% (Total available: 65200) |
| | Block RAM (RAMB36E1) | 16 | 21.33% (Total available: 75) |
| | I/O Pins | 42 | 20.00% (Total available: 210) |
| **Resources (CPU Only)** | LUTs (riscv_top) | 1403 | Core + RegFile + ALU |
| | Flip-Flops (riscv_top) | 1096 | Core + RegFile + ALU |
| **Routing** | Global Status | Fully Routed | Constraints met |
| **Power** | Total Power | 94 mW | Total On-Chip Power |
| | Dynamic Power | 19 mW | Switching logic and I/O |
| | Static Power | 75 mW | Chip leakage current |