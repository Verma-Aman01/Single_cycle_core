# Single_Cycle_Core

A **Verilog** implementation of a **single-cycle processor** (5-stage design) for FPGA deployment.  
This repository contains modules covering each pipeline stage (IF, ID, EX, MEM, WB), accompanying test benches, and memory initialization files.

---

## 📁 Repository Structure

| File / Folder | Description |
|---|---|
| `Single_Cycle_Top_5Stage.v` | Top-level module that connects all pipeline stages |
| `Single_Cycle_Top_5Stage_tb.v` | Testbench for the top-level design |
| `IF.v`, `IF_stage_tb.v` | Instruction Fetch stage & its testbench |
| `ID.v`, `ID_stage_tb.v` | Instruction Decode / Register Fetch stage & testbench |
| `EX.v`, `EX_stage_tb.v` | Execute (ALU, branch, etc.) stage & testbench |
| `MEM.v`, `MEM_stage_tb.v` | Memory access stage & testbench |
| `WB.v`, `WB_stage_tb.v` | Write-back stage & testbench |
| `Basys3_Top_5stage.v` | FPGA board top wrapper (for Basys3) |
| `data_mem.mem` | Data memory initialization file |
| `instructions.mem` | Instruction memory (program) file |
| `reg_inint.mem`, `reg_out.mem` | Register input / output memory initialization files |
| `README.md` | This file |

---

## 🧠 Design Overview

This is a 5-stage single-cycle architecture:

1. **IF (Instruction Fetch)**  
   - Fetches instruction from instruction memory using PC  
   - Increments PC  

2. **ID (Instruction Decode / Register Fetch)**  
   - Decodes the instruction  
   - Reads register operands  
   - Sign-extends immediates  

3. **EX (Execute / ALU)**  
   - Performs arithmetic or logic operations  
   - Calculates branch target, compares for branch decisions  

4. **MEM (Memory Access)**  
   - For `lw` / `sw`, reads or writes data memory  

5. **WB (Write Back)**  
   - Writes results back to the register file  

The **top-level module** wires all these stages together and handles the clock, reset, and inter-stage control.

Test benches for individual stages and for the full design help validate correctness.

Memory files (`*.mem`) are used to initialize instruction and data memory contents for simulation.

The `Basys3_Top_5stage.v` file is a board wrapper, intended for deployment on **Basys3 FPGA** (Artix-7) with appropriate I/O mapping.

---

## 🧪 Running Simulations & Synthesis

### Simulation (Behavioral)

1. Load the top-level testbench `Single_Cycle_Top_5Stage_tb.v` in your simulator (e.g. ModelSim, Vivado Simulator).
2. Ensure memory initialization files are in path.
3. Run simulation and observe waveforms, check correctness of pipeline behavior.

### FPGA Deployment (Basys3)

- Use `Basys3_Top_5stage.v` as the top module.
- Map I/O pins in your FPGA constraints file (XDC) accordingly.
- Synthesize and generate bitstream.
- Program the Basys3 board and test the core with real inputs / outputs or through simulation-controlled memory content.

---

## 🚀 How to Use / Steps

1. Edit or write your instruction sequence in `instructions.mem`.
2. Provide initial data in `data_mem.mem` (if needed).
3. Run simulation or program FPGA.
4. Observe correct execution via waveforms or board I/O / LEDs / outputs.
5. To extend or test further, you can add new instructions or modules.

---

## 🔍 Possible Extensions & Future Work

- Add support for more instructions (e.g. `jal`, `jr`, `addi` etc)
- Introduce hazard detection, forwarding, stalling for pipelining
- Add branching, jump, and control instructions
- Support interrupts or I/O peripherals
- Increase performance, or convert to a pipelined or multi-cycle design

---

## 📄 License

MIT License  

Copyright (c) 2023 Govardhan  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

