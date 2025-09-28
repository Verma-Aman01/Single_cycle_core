module WB_Stage(
    input  wire [31:0] ALUResult,
    input  wire [31:0] LoadData,
    input  wire [31:0] PC_plus4,
    input  wire [31:0] ImmU,
    input  wire MemToReg,
    input  wire Jal,
    input  wire Jalr,
    input  wire Lui,
    output wire [31:0] WriteData
);


    assign WriteData = (Jal || Jalr) ? PC_plus4 :
                       (Lui) ? ImmU :
                       (MemToReg) ? LoadData :
                       ALUResult;
endmodule