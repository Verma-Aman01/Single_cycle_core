`timescale 1ns/1ps
module Single_Cycle_Top_5stage_tb;
    parameter CLK_PERIOD = 10;
    reg clk;
    reg reset;

    // DUT outputs
    wire [31:0] PC_out, Instr_out, ALUResult_out;
    wire [4:0]  rs1_out, rs2_out, rd_out;
    wire [31:0] RD1_out, RD2_out, MemData_out;
    wire [3:0]  ALUControl_out;
    wire        RegWrite_out, MemRead_out, MemWrite_out;

    // DUT instantiation
    Single_Cycle_Top_5stage dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out),
        .Instr_out(Instr_out),
        .ALUResult_out(ALUResult_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
        .RD1_out(RD1_out),
        .RD2_out(RD2_out),
        .ALUControl_out(ALUControl_out),
        .RegWrite_out(RegWrite_out),
        .MemRead_out(MemRead_out),
        .MemWrite_out(MemWrite_out),
        .MemData_out(MemData_out)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Simulation control
    initial begin
        clk = 0;
        reset = 1;
        #(CLK_PERIOD*2);
        reset = 0;

        // Run simulation for fixed time (1,000,000 ns)
        #1000000;

        // Display final state
        $display("==== Simulation Finished (time limit reached) ====");
        $display("Final: PC=%08h Instr=%08h ALU=%08h", PC_out, Instr_out, ALUResult_out);

        // Dump register file and data memory
        $writememh("C:/Users/amanv/Desktop/single_core/reg_out.mem", dut.ID.Registers);
        $writememh("C:/Users/amanv/project_1/project_1.srcs/sim_1/new/data_out.mem", dut.MEM.Data_MEM);

        $display("Register file and data memory written to files.");
        #10 $finish;
    end

    // Trace printing each cycle
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time=%0t | PC=%08h | Instr=%08h | rs1=%0d rd1=%08h | rs2=%0d rd2=%08h | rd=%0d | alu_op=%04b | alu_result=%08h | MemRead=%0d | MemWrite=%0d | RegWrite=%0d | MemData=%08h",
                     $time, PC_out, Instr_out,
                     rs1_out, RD1_out,
                     rs2_out, RD2_out,
                     rd_out, ALUControl_out,
                     ALUResult_out,
                     MemRead_out, MemWrite_out, RegWrite_out,
                     MemData_out);
        end
    end
endmodule
