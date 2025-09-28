module IF_Stage(
    input wire clk,
    input wire reset,
    input wire BranchTaken,
    input wire Jal,
    input wire Jalr,
    input wire [31:0] ImmExt,
    input wire [31:0] RD1,
    output reg [31:0] PC,
    output wire [31:0] Instr,
    output wire [31:0] PC_plus4
);

    (* rom_style = "block" *) reg [31:0] InstrMem [0:1023]; // 4KB memory (1024 words)

    initial begin
        $readmemh("instructions.mem", InstrMem, 0, 46); // load instructions
    end

    wire [31:0] PC_NEXT;
    assign PC_NEXT = (Jal) ? (PC + ImmExt) :
                     (Jalr) ? ((RD1 + ImmExt) & ~32'h1) :
                     (BranchTaken) ? (PC + ImmExt) :
                     (PC + 32'd4);

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'h00000000;
        else
            PC <= PC_NEXT;
    end

    assign PC_plus4 = PC + 32'd4;
    assign Instr = InstrMem[PC[11:2]]; // 32-bit aligned addressing
endmodule
