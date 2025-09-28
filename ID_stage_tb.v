`timescale 1ns/1ps
module ID_Stage_tb;
    parameter CLK_PERIOD = 10;
    reg clk;
    reg reset;
    reg [31:0] Instr;
    reg [31:0] WriteData;
    wire [31:0] RD1, RD2, ImmExt;
    wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc;
    wire Branch, Jal, Jalr, Lui, Auipc, PCtoALU;
    wire [3:0] ALUControl;

    // DUT instance
    ID_Stage dut (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .WriteData(WriteData),
        .RD1(RD1),
        .RD2(RD2),
        .ImmExt(ImmExt),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jal(Jal),
        .Jalr(Jalr),
        .Lui(Lui),
        .Auipc(Auipc),
        .PCtoALU(PCtoALU),
        .ALUControl(ALUControl)
    );

    // Instruction memory for test
    reg [31:0] instrs [0:12];
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        Instr = 32'b0;
        WriteData = 32'hA5A5A5A5;

        // Reset phase
        #(CLK_PERIOD * 2);
        reset = 0;

        // Sample instructions (adjust to your ISA)
        instrs[0]  = 32'h00e383b3; // R-type add
        instrs[1]  = 32'h00500093; // addi
        instrs[2]  = 32'h0000a103; // lw
        instrs[3]  = 32'h0020a023; // sw
        instrs[4]  = 32'h0020a063; // beq
        instrs[5]  = 32'h000000b7; // lui
        instrs[6]  = 32'h00000097; // auipc
        instrs[7]  = 32'h0000006f; // jal
        instrs[8]  = 32'h00100113; // addi
        instrs[9]  = 32'h00000000; // nop
        instrs[10] = 32'h00b50533; // another R-type
        instrs[11] = 32'h00000000; // nop
//        instrs[12] = 32'h00410133; // add x2,x2,x4
        instrs[12] = 32'h406282b3; // sub x5, x5, x6
//        instrs[14] = 32'h00130313; // addi x6,x6,1
//        instrs[15] = 32'hfe521ae3; // bne x4,x5,offset
//        instrs[16] = 32'h00c000ef; // jal x1, 12
//        instrs[17] = 32'h00a40433; // add x8,x8,x10
//        instrs[18] = 32'h00000013; // nop


        // Apply each instruction
        for (i = 0; i < 13; i = i + 1) begin
            Instr = instrs[i];
            WriteData = 32'h1000 + i;

            // First cycle (decode)
            #(CLK_PERIOD);

            // Second cycle (write commit)
            #(CLK_PERIOD);

            // Print state
            $display("t=%0t Instr=%08h RD1=%08h RD2=%08h Imm=%08h RegW=%b ALUCtrl=%b",
                     $time, Instr, RD1, RD2, ImmExt, RegWrite, ALUControl);

       
        end

        // Extra wait
        #(CLK_PERIOD * 4);

        // Final dump
        $writememh("reg_out.mem", dut.Registers);
        $display("ID Stage finished - final reg_out.mem written.");
        #10 $finish;
    end

    // Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // Monitor register writes (optional debug)
//    always @(posedge clk) begin
//        if (dut.write_enable && dut.write_addr != 0) begin
//            $display("t=%0t WRITE x%0d <= %08h", 
//                     $time, dut.write_addr, WriteData);
//        end
//    end
endmodule


