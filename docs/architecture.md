# Synchronous FIFO — Architecture

## Objective

Design a synchronous First-In, First-Out (FIFO) buffer using synthesizable Verilog HDL.

## Initial Configuration

- Data width: 8 bits
- FIFO depth: 16 entries
- Clock: Single clock domain
- Reset: Synchronous, active-high
- Storage: Register array for the initial RTL implementation

## Interface

| Signal | Direction | Purpose |
|---|---|---|
| clk | Input | Clock |
| rst | Input | Synchronous reset |
| wr_en | Input | Write request |
| rd_en | Input | Read request |
| din | Input | Input data |
| dout | Output | Output data |
| full | Output | FIFO full status |
| empty | Output | FIFO empty status |

## Main Components

1. Memory array to store data.
2. Write pointer to select the next write location.
3. Read pointer to select the next read location.
4. Occupancy counter to track stored entries.
5. Control logic for read/write operations and status flags.

## Verification Goals

- Reset behavior
- Correct data ordering
- Empty and full boundary conditions
- Pointer wraparound
- Simultaneous read/write requests

## Future Work

- Parameterize data width and depth.
- Add a self-checking testbench.
- Synthesize the design using Yosys.
- Analyze resource usage and explore ASIC physical design.