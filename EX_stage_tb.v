`timescale 1ns/1ps
// Save as: tb_EX_Stage.v
module EX_Stage_tb;
    reg [31:0] RD1, RD2, ImmExt, PC;
    reg ALUSrc, PCtoALU;
    reg [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire Zero, Negative, Less_signed, Less_unsigned;
    wire Carry, Overflow;

    // Local copy of reg_init for convenience (so EX TB "uses reginit")
    reg [31:0] reg_init_vals [0:31];
    integer idx;

    EX_Stage dut (
        .RD1(RD1),
        .RD2(RD2),
        .ImmExt(ImmExt),
        .PC(PC),
        .ALUSrc(ALUSrc),
        .PCtoALU(PCtoALU),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .Negative(Negative),
        .Carry(Carry),
        .Overflow(Overflow),
        .Less_signed(Less_signed),
        .Less_unsigned(Less_unsigned)
    );

    initial begin
//        $dumpfile("sim_EX_Stage.vcd");
//        $dumpvars(0, tb_EX_Stage);

        // Load register initial values to use as operands
        $readmemh("reg_init.mem", reg_init_vals);

        // Prepare operands from reg_init
        RD1 = reg_init_vals[10]; // example use registers x10, x11
        RD2 = reg_init_vals[11];
        PC = 32'h00000000;
        ImmExt = 32'h0;
        ALUSrc = 0; PCtoALU = 0;

        // ADD
        ALUControl = 4'b0000; #5;
        $display("ADD: A=%0d B=%0d => R=%0d Zero=%b Neg=%b", RD1, RD2, ALUResult, Zero, Negative);

        // SUB
        ALUControl = 4'b0001; #5;
        $display("SUB => R=%0d Zero=%b", ALUResult, Zero);

        // AND
        ALUControl = 4'b0010; #5; $display("AND => %08h", ALUResult);

        // OR
        ALUControl = 4'b0011; #5; $display("OR => %08h", ALUResult);

        // XOR
        ALUControl = 4'b0100; #5; $display("XOR => %08h", ALUResult);

        // SLL
        RD2 = 32'd2; ALUControl = 4'b0101; #5; $display("SLL => %08h", ALUResult);

        // SRL
        ALUControl = 4'b0110; #5; $display("SRL => %08h", ALUResult);

        // SRA
        ALUControl = 4'b0111; #5; $display("SRA => %08h", ALUResult);

        // SLT
        ALUControl = 4'b1000; RD1 = -5; RD2 = 3; #5; $display("SLT => %08h Less_signed=%b", ALUResult, Less_signed);

        // SLTU
        ALUControl = 4'b1001; RD1 = 32'hFFFFFFF0; RD2 = 32'h00000010; #5; $display("SLTU => %08h Less_unsigned=%b", ALUResult, Less_unsigned);

        // PASS_B / LUI
        ALUSrc = 1; ImmExt = 32'hABCD0000; ALUControl = 4'b1111; #5; $display("PASS_B => %08h", ALUResult);

        #10 $finish;
    end
endmodule