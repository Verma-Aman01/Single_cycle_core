module EX_Stage(
    input  wire [31:0] RD1,
    input  wire [31:0] RD2,
    input  wire [31:0] ImmExt,
    input  wire [31:0] PC,
    input  wire ALUSrc,
    input  wire PCtoALU,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire Zero,
    output wire Negative,
    output reg  Carry,
    output reg  Overflow,
    output wire Less_signed,
    output wire Less_unsigned
);

    wire [31:0] ALU_A = (PCtoALU) ? PC : RD1;
    wire [31:0] ALU_B = (ALUSrc) ? ImmExt : RD2;
    wire signed [31:0] A_s = $signed(ALU_A);
    wire signed [31:0] B_s = $signed(ALU_B);

    assign Less_signed = (A_s < B_s);
    assign Less_unsigned = (ALU_A < ALU_B);
    assign Zero = (ALUResult == 32'b0);
    assign Negative = ALUResult[31];

    always @(*) begin
        Carry = 1'b0; Overflow = 1'b0; ALUResult = 32'b0;
        case (ALUControl)
            4'b0000: begin // ADD
                {Carry, ALUResult} = {1'b0, ALU_A} + {1'b0, ALU_B};
                Overflow = (A_s[31] == B_s[31]) && (ALUResult[31] != A_s[31]);
            end
            4'b0001: begin // SUB
                {Carry, ALUResult} = {1'b0, ALU_A} - {1'b0, ALU_B};
                Overflow = (A_s[31] != B_s[31]) && (ALUResult[31] != A_s[31]);
            end
            4'b0010: ALUResult = ALU_A & ALU_B; // AND
            4'b0011: ALUResult = ALU_A | ALU_B; // OR
            4'b0100: ALUResult = ALU_A ^ ALU_B; // XOR
            4'b0101: ALUResult = ALU_A << ALU_B[4:0]; // SLL
            4'b0110: ALUResult = ALU_A >> ALU_B[4:0]; // SRL
            4'b0111: ALUResult = $signed(ALU_A) >>> ALU_B[4:0]; // SRA
            4'b1000: ALUResult = {31'b0, Less_signed}; // SLT
            4'b1001: ALUResult = {31'b0, Less_unsigned}; // SLTU
            4'b1111: ALUResult = ALU_B; // LUI / PASS_B
            default: ALUResult = 32'b0;
        endcase
    end

endmodule