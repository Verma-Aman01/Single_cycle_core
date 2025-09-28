module MEM_Stage(
    input  wire clk,
    input  wire [31:0] ALUResult,
    input  wire [31:0] RD2,
    input  wire MemWrite,
    input  wire MemRead,
    input  wire Branch,
    input  wire [2:0]  funct3,
    input  wire Zero,
    input  wire Less_signed,
    input  wire Less_unsigned,
    output reg  [31:0] LoadData,
    output wire BranchTaken
);

    // Data memory (combinational read, sync write)
    reg [31:0] Data_MEM [0:1023];

    initial begin
        $readmemh("data_mem.mem", Data_MEM, 0, 255); // preload data
    end

    assign BranchTaken = (Branch && (
                          (funct3 == 3'b000 && Zero)         || // BEQ
                          (funct3 == 3'b001 && !Zero)        || // BNE
                          (funct3 == 3'b100 && Less_signed)  || // BLT
                          (funct3 == 3'b101 && !Less_signed) || // BGE
                          (funct3 == 3'b110 && Less_unsigned)|| // BLTU
                          (funct3 == 3'b111 && !Less_unsigned)  // BGEU
                          ));

    // **Combinational read**
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: LoadData = {{24{Data_MEM[ALUResult][7]}},  Data_MEM[ALUResult][7:0]};   // LB
                3'b001: LoadData = {{16{Data_MEM[ALUResult][15]}}, Data_MEM[ALUResult][15:0]};  // LH
                3'b010: LoadData = Data_MEM[ALUResult];                                         // LW
                3'b100: LoadData = {24'b0, Data_MEM[ALUResult][7:0]};                           // LBU
                3'b101: LoadData = {16'b0, Data_MEM[ALUResult][15:0]};                          // LHU
                default: LoadData = 32'b0;
            endcase
        end else
            LoadData = 32'b0;
    end

    // **Synchronous write**
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: Data_MEM[ALUResult][7:0]   <= RD2[7:0];   // SB
                3'b001: Data_MEM[ALUResult][15:0]  <= RD2[15:0];  // SH
                3'b010: Data_MEM[ALUResult]        <= RD2;        // SW
            endcase
        end
    end

endmodule
