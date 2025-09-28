module Single_Cycle_Top_5stage(
    input  wire clk,
    input  wire reset,
    output wire [31:0] PC_out,
    output wire [31:0] Instr_out,
    output wire [31:0] ALUResult_out,

    // Debug outputs
    output wire [4:0]  rs1_out,
    output wire [4:0]  rs2_out,
    output wire [4:0]  rd_out,
    output wire [31:0] RD1_out,
    output wire [31:0] RD2_out,
    output wire [3:0]  ALUControl_out,
    output wire        RegWrite_out,
    output wire        MemRead_out,
    output wire        MemWrite_out,
    output wire [31:0] MemData_out
);

    // Internal wires
    wire [31:0] PC, Instr, PC_plus4;
    wire [31:0] RD1, RD2, ImmExt;
    wire [31:0] ALUResult, LoadData, WriteData;
    wire Zero, Negative, Carry, Overflow, Less_signed, Less_unsigned;
    wire BranchTaken;

    wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc;
    wire Branch, Jal, Jalr, Lui, Auipc, PCtoALU;
    wire [3:0] ALUControl;

    // IF Stage
    IF_Stage IF (
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

    assign PC_out    = PC;
    assign Instr_out = Instr;

    // ID Stage
    ID_Stage ID (
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

    // EX Stage
    EX_Stage EX (
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

    assign ALUResult_out = ALUResult;

    // MEM Stage
    MEM_Stage MEM (
        .clk(clk),
        .ALUResult(ALUResult),
        .RD2(RD2),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Branch),
        .funct3(Instr[14:12]),
        .Zero(Zero),
        .Less_signed(Less_signed),
        .Less_unsigned(Less_unsigned),
        .LoadData(LoadData),
        .BranchTaken(BranchTaken)
    );

    // WB Stage
    WB_Stage WB (
        .ALUResult(ALUResult),
        .LoadData(LoadData),
        .PC_plus4(PC_plus4),
        .ImmU(ImmExt),
        .MemToReg(MemToReg),
        .Jal(Jal),
        .Jalr(Jalr),
        .Lui(Lui),
        .WriteData(WriteData)
    );

    // Debug signal hookups
    assign rs1_out        = Instr[19:15];
    assign rs2_out        = Instr[24:20];
    assign rd_out         = Instr[11:7];
    assign RD1_out        = RD1;
    assign RD2_out        = RD2;
    assign ALUControl_out = ALUControl;
    assign RegWrite_out   = RegWrite;
    assign MemRead_out    = MemRead;
    assign MemWrite_out   = MemWrite;
    assign MemData_out    = LoadData;

endmodule
