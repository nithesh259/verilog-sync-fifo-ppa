# Parameterized Synchronous FIFO Design and PPA Analysis using Verilog HDL

A parameterized synchronous FIFO (First-In, First-Out) implemented in Verilog HDL, verified through simulation, and evaluated using Yosys and nextpnr for FPGA synthesis, resource utilization, and timing analysis.

## Overview

A FIFO is a fundamental digital hardware component used to temporarily store data between hardware blocks operating within a system. Data is read in the same order in which it was written.

This project implements a synchronous FIFO with configurable data width and storage depth. The design is simulated using Icarus Verilog and evaluated for different FIFO depths using the open-source FPGA toolchain.

The primary objective is to understand RTL design, functional verification, FPGA resource inference, and how FIFO depth affects implementation results.

## Features

- Parameterized FIFO data width and depth
- Synchronous, active-high reset
- Write and read enable control
- Full and empty status flags
- FIFO data ordering verification
- Boundary-condition testing
- Simultaneous read/write verification
- RTL synthesis using Yosys
- iCE40 FPGA technology mapping
- Placement and routing using nextpnr
- Resource and timing comparison across FIFO depths

## Architecture

The FIFO consists of storage memory, read and write pointers, an occupancy counter, and status logic.

```text
                 +----------------------+
    clk -------->|                      |
    rst -------->|                      |
    wr_en ------>|                      |
    rd_en ------>|     FIFO Control     |
    din -------->|                      |
                 |                      |
                 +----------+-----------+
                            |
                  +---------v----------+
                  |                    |
                  |    FIFO Memory     |
                  |                    |
                  +---------+----------+
                            |
                         dout

                    +---------------+
                    | Status Logic  |
                    |               |
                    | full / empty  |
                    +---------------+
```

### Operating principle

- **Write:** Stores incoming data when a write is accepted.
- **Read:** Returns stored data in FIFO order when a read is accepted.
- **Full:** Indicates that the FIFO has reached its configured capacity.
- **Empty:** Indicates that no data is stored.
- **Reset:** Initializes the FIFO control state.
- **Simultaneous read/write:** Supports concurrent operations according to the design's acceptance conditions.

## Parameters

The design uses the following parameters:

| Parameter | Description | Default |
|---|---|---:|
| `DATA_WIDTH` | Number of bits per data entry | 8 |
| `DEPTH` | Number of FIFO entries | 16 |
| `ADDR_WIDTH` | Width of the read/write address pointers | 4 |

For the tested configurations, the address width is matched to the FIFO depth.

| FIFO depth | Data width | Address width |
|---:|---:|---:|
| 8 | 8 bits | 3 |
| 16 | 8 bits | 4 |
| 32 | 8 bits | 5 |

The current configurations use power-of-two depths. The address width must be configured consistently with the chosen depth.

## Tools and Technologies

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL implementation |
| Icarus Verilog | RTL compilation and simulation |
| VVP | Simulation execution |
| GTKWave | Waveform inspection |
| Yosys | RTL synthesis and FPGA technology mapping |
| nextpnr-ice40 | FPGA placement, routing, and timing estimation |
| Git and GitHub | Version control and project hosting |
| OSS CAD Suite | Open-source EDA tool environment |

## Repository Structure

```text
verilog-sync-fifo-ppa/
├── rtl/
│   └── sync_fifo.v
├── tb/
│   └── tb_sync_fifo.v
├── sim/
│   └── run_tests.ps1
├── waveforms/
│   └── fifo_waveform.vcd
├── synth/
│   ├── run_synthesis.ys
│   ├── sync_fifo_synth.v
│   ├── sync_fifo_synth.json
│   ├── sync_fifo_ice40.json
│   ├── fifo_depth8.json
│   ├── fifo_depth16.json
│   └── fifo_depth32.json
├── reports/
│   ├── resource_statistics.txt
│   ├── synthesis_log.txt
│   ├── ice40_synthesis_log.txt
│   ├── depth_comparison.md
│   ├── depth8_log.txt
│   ├── depth16_log.txt
│   ├── depth32_log.txt
│   ├── depth8_timing.json
│   ├── depth16_timing.json
│   ├── depth32_timing.json
│   ├── depth8_routed.asc
│   ├── depth16_routed.asc
│   └── depth32_routed.asc
├── docs/
│   └── architecture.md
├── README.md
├── LICENSE
└── .gitignore
```

*Note: Generated simulation files, synthesis artifacts, and report filenames may vary depending on which outputs are retained in Git.*

## Simulation and Functional Verification

The testbench is located at `tb/tb_sync_fifo.v`.

It currently checks:

1. FIFO starts empty after reset.
2. Data is written and read in FIFO order.
3. FIFO becomes empty after the stored entries are read.
4. FIFO reaches full capacity at 16 entries.
5. All 16 entries are read back in the expected order.
6. Reading while empty does not change the empty status.
7. Writing while full does not overwrite the original entries.
8. Simultaneous read/write preserves the expected data ordering.
9. FIFO returns to the empty state after the tests.

The testbench prints `PASS` or `FAIL` messages and ends with an overall test result.

### Run the regression tests

Open PowerShell in the repository root.

Activate OSS CAD Suite if it is not already available in your terminal:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
. C:\eda\oss-cad-suite\environment.ps1
```

Run the regression script:

```powershell
.\sim\run_tests.ps1
```

A successful run should finish with:

```text
ALL TESTS PASSED
```

### Run the simulation manually

Compile:

```powershell
iverilog -g2012 -Wall -o .\sim\fifo_sim.vvp .\rtl\sync_fifo.v .\tb\tb_sync_fifo.v
```

Execute:

```powershell
vvp .\sim\fifo_sim.vvp
```

### Inspect the waveform

The testbench generates a VCD waveform file at `waveforms/fifo_waveform.vcd`.

Open it with GTKWave:

```powershell
gtkwave .\waveforms\fifo_waveform.vcd
```

Useful signals to inspect include `clk`, `rst`, `wr_en`, `rd_en`, `din`, `dout`, `full`, and `empty`.

## FPGA Synthesis

Yosys is used to synthesize the RTL and map it to the iCE40 FPGA architecture.

The implementation comparison uses:

- Target architecture: iCE40 HX1K
- Package: TQ144
- Data width: 8 bits
- FIFO depths: 8, 16, and 32 entries
- Requested clock constraint during placement and routing: 12 MHz

The following command performs technology mapping for the default configuration:

```powershell
yosys -p "read_verilog rtl/sync_fifo.v; synth_ice40 -top sync_fifo -json synth/sync_fifo_ice40.json; stat"
```

### Placement and routing

Example command for the default depth-16 implementation:

```powershell
nextpnr-ice40 --hx1k --package tq144 `
  --json .\synth\sync_fifo_ice40.json `
  --freq 12 `
  --pcf-allow-unconstrained `
  --report .\reports\fifo_timing_report.json `
  --asc .\reports\fifo_routed.asc
```

The `--pcf-allow-unconstrained` option allows the tool to proceed without a complete pin-constraint file. This is suitable for exploratory analysis, but the result is not a board-ready pin assignment.

## Results: FIFO Depth Comparison

The following results were obtained from the completed iCE40 placement-and-routing runs.

| FIFO depth | Logic cells | Logic utilization | Block RAMs | Reported maximum frequency |
|---:|---:|---:|---:|---:|
| 8 | 154 | 12% | 0 | 163.91 MHz |
| 16 | 68 | 5% | 1 | 166.39 MHz |
| 32 | 78 | 6% | 1 | 171.38 MHz |

Target device: iCE40 HX1K. The reported maximum frequencies are tool estimates, not measurements from physical hardware.

### Observations

- The depth-8 implementation used logic resources for its storage rather than a block RAM primitive.
- The depth-16 and depth-32 configurations inferred one block RAM each.
- The resource counts do not increase linearly with FIFO depth because the synthesis tool can map memory and control logic differently.
- The reported maximum frequency varied across the three configurations, with the depth-32 configuration producing the highest estimate in these runs.

These observations apply to the tested tool versions, RTL, and target architecture. They should not be interpreted as universal results for every FPGA family.

## Project Workflow

The project was developed in the following stages:

1. **RTL implementation:** Created the parameterized synchronous FIFO in Verilog.
2. **Functional simulation:** Built a testbench for reset, FIFO ordering, full/empty conditions, and boundary cases.
3. **Waveform inspection:** Generated VCD output for signal-level debugging with GTKWave.
4. **Generic synthesis:** Used Yosys to inspect the synthesized design and cell statistics.
5. **Technology mapping:** Mapped the FIFO to the iCE40 FPGA architecture.
6. **Parameter comparison:** Synthesized FIFO configurations at depths 8, 16, and 32.
7. **Placement and routing:** Ran nextpnr for each configuration and generated timing/resource reports.
8. **Result analysis:** Compared logic utilization, block RAM inference, and reported maximum frequency.

## Limitations and Future Work

The current project focuses on RTL simulation and FPGA-tool-based implementation analysis.

Potential next steps include:

- Extend automated functional verification to all three FIFO depths.
- Add randomized tests and a reference-model scoreboard.
- Add assertions for pointer, occupancy, and full/empty invariants.
- Evaluate additional data widths and FIFO depths.
- Add timing constraints and valid pin assignments for a specific FPGA development board.
- Validate the implementation on physical FPGA hardware.
- Perform power analysis using a supported power-estimation flow.

**Power consumption has not been physically measured in this project.** The reported timing and utilization results are based on the FPGA implementation tools.

## Learning Outcomes

Through this project, I explored:

- RTL design using Verilog HDL
- Synchronous digital design and reset behavior
- FIFO control and status logic
- Testbench development and functional simulation
- VCD waveform debugging
- Synthesis and technology mapping
- FPGA memory inference
- Resource utilization and timing analysis
- Parameter-based hardware design comparison

## Author

**Nithesh**

Electronics and Communication Engineering (ECE)

GitHub: [@nithesh259](https://github.com/nithesh259)

## License

This project is distributed under the license included in this repository.
