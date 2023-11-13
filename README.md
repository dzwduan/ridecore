# Introduction  

RIDECORE (RIsc-v Dynamic Execution CORE) is an Out-of-Order processor written in Verilog HDL. RIDECORE implements RISC-V, an open-source ISA that was originally designed by researchers at UC Berkeley (<http://www.riscv.org>).

RIDECORE's microarchitecture is based on "Modern Processor Design: Fundamentals of Superscalar Processors" (<https://www.waveland.com/browse.php?t=624&r=d|259>). Thus, we recommend users to read this book and our document (doc/ridecore_document.pdf) before using RIDECORE.

Our FPGA prototyping efforts have so far resulted in a prototype for Xilinx VC707 board. This prototype can operate at a clock frequency of 50MHz (Vivado 2015.2 is used for synthesizing and implementing the design).

Some of the hardware modules in RIDECORE are based on vscale (<https://github.com/ucb-bar/vscale>).

## Learn ooo processor
rv32IM 架构