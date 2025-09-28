`timescale 1ns/1ps
// Save as: tb_MEM_Stage.v
module MEM_stage_tb;
    parameter CLK_PERIOD = 10;
    reg clk;
    reg [31:0] ALUResult;
    reg [31:0] RD2;
    reg MemWrite;
    reg MemRead;
    reg Branch;
    reg [2:0] funct3;
    reg Zero;
    reg Less_signed, Less_unsigned;
    wire [31:0] LoadData;
    wire BranchTaken;

    MEM_Stage dut (
        .clk(clk),
        .ALUResult(ALUResult),
        .RD2(RD2),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Branch),
        .funct3(funct3),
        .Zero(Zero),
        .Less_signed(Less_signed),
        .Less_unsigned(Less_unsigned),
        .LoadData(LoadData),
        .BranchTaken(BranchTaken)
    );

    initial begin
//        $dumpfile("sim_MEM_Stage.vcd");
//        $dumpvars(0, tb_MEM_Stage);
        clk = 0;

        // Wait for memory initialization (module reads data_mem.mem internally)
        #20;

        // LW (word read) at address 0
        MemRead = 1; MemWrite = 0; funct3 = 3'b010; ALUResult = 32'd0;
        #20 $display("LW Addr=0 => data = %08h BranchTaken=%b", LoadData, BranchTaken);

        // LB (signed byte) at address 1
        funct3 = 3'b000; ALUResult = 32'd1;
        #20 $display("LB Addr=1 => data = %08h", LoadData);

        // LBU (unsigned byte)
        funct3 = 3'b100; ALUResult = 32'd1;
        #20 $display("LBU Addr=1 => data = %08h", LoadData);

        // LH
        funct3 = 3'b001; ALUResult = 32'd2;
        #20 $display("LH Addr=2 => data = %08h", LoadData);

        // SW (word write) at address 16
        MemRead = 0; MemWrite = 1; funct3 = 3'b010;
        ALUResult = 32'd16; RD2 = 32'hCAFEBABE;
        #20; // sample on posedge inside module
        MemWrite = 0;

        // Read back word
        MemRead = 1; funct3 = 3'b010; ALUResult = 32'd16;
        #20 $display("After SW: Addr=16 => data = %08h", LoadData);

        // Branch tests
        MemRead = 0; MemWrite = 0; Branch = 1;
        Zero = 1; Less_signed = 0; Less_unsigned = 0; funct3 = 3'b000; // BEQ (Zero=1) -> true
        #10 $display("BEQ Zero=1 => BranchTaken=%b", BranchTaken);

        Zero = 0; Less_signed = 1; funct3 = 3'b100; // BLT (Less_signed=1) -> true
        #10 $display("BLT Less_signed=1 => BranchTaken=%b", BranchTaken);

        // Wait a couple cycles then write out final data memory
        # (CLK_PERIOD * 4);
        $writememh("C:/Users/amanv/project_1/project_1.srcs/sim_1/new/data_out.mem", dut.Data_MEM);

        $display("MEM Stage finished - data_out.mem written.");
        #10 $finish;
    end

    always #(CLK_PERIOD/2) clk = ~clk;
endmodule