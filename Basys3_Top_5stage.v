module Basys3_Top(
    input  wire clk,
    input  wire reset,
    // LEDs
    output wire [15:0] led,
    // 7-segment display
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an,
    // Switches to select ALUResult upper/lower
    input  wire sw0
);

    // CPU internal signals
    wire [31:0] PC_out;
    wire [31:0] Instr_out;
    wire [31:0] ALUResult_out;

    // LEDs display PC lower 16 bits
    assign led = PC_out[15:0];

    // Instantiate CPU with BRAM for instructions/data
    Single_Cycle_Top_5stage CPU (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out),
        .Instr_out(Instr_out),
        .ALUResult_out(ALUResult_out),
        .rs1_out(), .rs2_out(), .rd_out(),
        .RD1_out(), .RD2_out(),
        .ALUControl_out(),
        .RegWrite_out(), .MemRead_out(), .MemWrite_out(),
        .MemData_out()
    );

    // Select upper/lower 16 bits of ALUResult
    wire [15:0] display_value;
    assign display_value = sw0 ? ALUResult_out[31:16] : ALUResult_out[15:0];

    // 7-segment display multiplexing
    reg [3:0] hex_digit;
    reg [1:0] anode_sel;
    reg [16:0] refresh_counter;

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        anode_sel <= refresh_counter[16:15];
    end

    always @(*) begin
        case(anode_sel)
            2'b00: hex_digit = display_value[3:0];
            2'b01: hex_digit = display_value[7:4];
            2'b10: hex_digit = display_value[11:8];
            2'b11: hex_digit = display_value[15:12];
        endcase
    end

    assign an = ~(1 << anode_sel); // active low
    assign dp = 1'b1;             // decimal point off

    // 7-segment decoder (common cathode)
    assign seg = (hex_digit == 4'h0) ? 7'b1000000 :
                 (hex_digit == 4'h1) ? 7'b1111001 :
                 (hex_digit == 4'h2) ? 7'b0100100 :
                 (hex_digit == 4'h3) ? 7'b0110000 :
                 (hex_digit == 4'h4) ? 7'b0011001 :
                 (hex_digit == 4'h5) ? 7'b0010010 :
                 (hex_digit == 4'h6) ? 7'b0000010 :
                 (hex_digit == 4'h7) ? 7'b1111000 :
                 (hex_digit == 4'h8) ? 7'b0000000 :
                 (hex_digit == 4'h9) ? 7'b0010000 :
                 (hex_digit == 4'hA) ? 7'b0001000 :
                 (hex_digit == 4'hB) ? 7'b0000011 :
                 (hex_digit == 4'hC) ? 7'b1000110 :
                 (hex_digit == 4'hD) ? 7'b0100001 :
                 (hex_digit == 4'hE) ? 7'b0000110 :
                 (hex_digit == 4'hF) ? 7'b0001110 : 7'b1111111;

endmodule