`timescale 1ns/1ps
module IF_Stage_tb;
    parameter CLK_PERIOD = 10;
    reg clk;
    reg reset;
    reg BranchTaken, Jal, Jalr;
    reg [31:0] ImmExt, RD1;
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] PC_plus4;

    // Instantiate DUT
    IF_Stage dut (
        .clk(clk),
        .reset(reset),
        .BranchTaken(BranchTaken),
        .Jal(Jal),
        .Jalr(Jalr),
        .ImmExt(ImmExt),
        .RD1(RD1),
        .PC(PC),
        .Instr(Instr),
        .PC_plus4(PC_plus4)
    );

    initial begin
        //$dumpfile("sim_IF_Stage.vcd");
        //$dumpvars(0, IF_Stage_tb);
        clk = 0;
        reset = 1;
        BranchTaken = 0; Jal = 0; Jalr = 0;
        ImmExt = 32'd0; RD1 = 32'd0;
        # (CLK_PERIOD * 2);
        reset = 0;

        // Run for enough cycles to fetch instructions from instructions.mem
        # (CLK_PERIOD * 47);

        $display("IF Stage finished - final PC = %0h, Instr = %0h", PC, Instr);
        #10 $finish;
    end

    always #(CLK_PERIOD/2) clk = ~clk;

    always @(posedge clk) begin
        $display("t=%0t PC=%08h Instr=%08h PC+4=%08h", $time, PC, Instr, PC_plus4);
    end
endmodule