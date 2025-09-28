module ID_Stage(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] Instr,
    input  wire [31:0] WriteData,   // from WB stage
    output wire [31:0] RD1,
    output wire [31:0] RD2,
    output wire [31:0] ImmExt,
    output wire        RegWrite,
    output wire        MemRead,
    output wire        MemWrite,
    output wire        MemToReg,
    output wire        ALUSrc,
    output wire        Branch,
    output wire        Jal,
    output wire        Jalr,
    output wire        Lui,
    output wire        Auipc,
    output wire        PCtoALU,
    output wire [3:0]  ALUControl
);

    // ---------------- Register File ----------------
    reg [31:0] Registers [0:31];
    integer i;

    initial begin
        $readmemh("reg_init.mem", Registers, 0, 31);
    end

    wire [4:0] rs1 = Instr[19:15];
    wire [4:0] rs2 = Instr[24:20];
    wire [4:0] rd  = Instr[11:7];

    // synchronous write
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                Registers[i] <= 32'b0;
        end else if (RegWrite && rd != 5'b0) begin
            Registers[rd] <= WriteData;
        end
    end

    // asynchronous read
    assign RD1 = (rs1 == 5'b0) ? 32'b0 : Registers[rs1];
    assign RD2 = (rs2 == 5'b0) ? 32'b0 : Registers[rs2];

    // ---------------- Immediate Generator ----------------
    wire [6:0] opcode = Instr[6:0];
    reg [31:0] imm;

    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111:
                imm = {{20{Instr[31]}}, Instr[31:20]}; // I-type

            7'b0100011:
                imm = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}; // S-type

            7'b1100011:
                imm = {{19{Instr[31]}}, Instr[31], Instr[7],
                       Instr[30:25], Instr[11:8], 1'b0}; // B-type

            7'b0110111, 7'b0010111:
                imm = {Instr[31:12], 12'b0}; // U-type

            7'b1101111:
                imm = {{11{Instr[31]}}, Instr[31], Instr[19:12],
                       Instr[20], Instr[30:21], 1'b0}; // J-type
            default: imm = 32'b0;
        endcase
    end

    assign ImmExt = imm;

    // ---------------- Control Logic ----------------
    reg regwrite_r, memread_r, memwrite_r, memtoreg_r, alusrc_r;
    reg branch_r, jal_r, jalr_r, lui_r, auipc_r, pctoalu_r;
    reg [1:0] ALUOp;
    reg [3:0] alucontrol_r;

    always @(*) begin
        // defaults
        regwrite_r = 0; memread_r = 0; memwrite_r = 0; memtoreg_r = 0;
        alusrc_r   = 0; branch_r = 0; jal_r = 0; jalr_r = 0;
        lui_r = 0; auipc_r = 0; pctoalu_r = 0; ALUOp = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                regwrite_r = 1; ALUOp = 2'b10;
            end
            7'b0010011: begin // I-type ALU
                regwrite_r = 1; ALUOp = 2'b10; alusrc_r = 1;
            end
            7'b0000011: begin // Load
                regwrite_r = 1; memread_r = 1; memtoreg_r = 1; alusrc_r = 1;
            end
            7'b0100011: begin // Store
                memwrite_r = 1; alusrc_r = 1;
            end
            7'b1100011: begin // Branch
                branch_r = 1; ALUOp = 2'b01;
            end
            7'b1101111: begin // JAL
                jal_r = 1; regwrite_r = 1;
            end
            7'b1100111: begin // JALR
                jalr_r = 1; regwrite_r = 1; alusrc_r = 1;
            end
            7'b0110111: begin // LUI
                lui_r = 1; regwrite_r = 1; alusrc_r = 1; ALUOp = 2'b10;
            end
            7'b0010111: begin // AUIPC
                auipc_r = 1; regwrite_r = 1; alusrc_r = 1; pctoalu_r = 1;
            end
        endcase
    end

    // ---------------- ALU Decoder ----------------
    always @(*) begin
        if (lui_r)
            alucontrol_r = 4'b1111;
        else begin
            case (ALUOp)
                2'b00: alucontrol_r = 4'b0000; // ADD
                2'b01: alucontrol_r = 4'b0001; // SUB (branches)
                2'b10: begin
                    case (Instr[14:12])
                        3'b000: alucontrol_r = (Instr[30]) ? 4'b0001 : 4'b0000; // SUB/ADD
                        3'b001: alucontrol_r = 4'b0101; // SLL
                        3'b010: alucontrol_r = 4'b1000; // SLT
                        3'b011: alucontrol_r = 4'b1001; // SLTU
                        3'b100: alucontrol_r = 4'b0100; // XOR
                        3'b101: alucontrol_r = (Instr[30]) ? 4'b0111 : 4'b0110; // SRA/SRL
                        3'b110: alucontrol_r = 4'b0011; // OR
                        3'b111: alucontrol_r = 4'b0010; // AND
                        default: alucontrol_r = 4'b0000;
                    endcase
                end
                default: alucontrol_r = 4'b0000;
            endcase
        end
    end

    // ---------------- Outputs ----------------
    assign RegWrite   = regwrite_r;
    assign MemRead    = memread_r;
    assign MemWrite   = memwrite_r;
    assign MemToReg   = memtoreg_r;
    assign ALUSrc     = alusrc_r;
    assign Branch     = branch_r;
    assign Jal        = jal_r;
    assign Jalr       = jalr_r;
    assign Lui        = lui_r;
    assign Auipc      = auipc_r;
    assign PCtoALU    = pctoalu_r;
    assign ALUControl = alucontrol_r;

endmodule
