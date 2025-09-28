`timescale 1ns/1ps
// Save as: tb_WB_Stage.v
module WB_stage_tb;
    reg [31:0] ALUResult, LoadData, PC_plus4, ImmU;
    reg MemToReg, Jal, Jalr, Lui;
    wire [31:0] WriteData;

    WB_Stage dut (
        .ALUResult(ALUResult),
        .LoadData(LoadData),
        .PC_plus4(PC_plus4),
        .ImmU(ImmU),
        .MemToReg(MemToReg),
        .Jal(Jal),
        .Jalr(Jalr),
        .Lui(Lui),
        .WriteData(WriteData)
    );

    initial begin
//        $dumpfile("sim_WB_Stage.vcd");
//        $dumpvars(0, tb_WB_Stage);

        ALUResult = 32'h00001111;
        LoadData = 32'hDEADBEEF;
        PC_plus4 = 32'h00001004;
        ImmU = 32'hABCD0000;

        MemToReg = 0; Jal = 0; Jalr = 0; Lui = 0; #5;
        $display("WB default => WriteData=%08h", WriteData);

        MemToReg = 1; #5;
        $display("WB MemToReg => WriteData=%08h", WriteData);

        MemToReg = 0; Jal = 1; #5;
        $display("WB Jal => WriteData=%08h", WriteData);

        Jal = 0; Jalr = 1; #5;
        $display("WB Jalr => WriteData=%08h", WriteData);

        Jalr = 0; Lui = 1; #5;
        $display("WB Lui => WriteData=%08h", WriteData);

        #10 $finish;
    end
endmodule