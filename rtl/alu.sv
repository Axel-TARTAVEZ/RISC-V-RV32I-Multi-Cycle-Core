import definitions::*;

module alu #(
    parameter int BW = 32
)(
    input logic [BW-1:0] in_a,
    input logic [BW-1:0] in_b,
    input logic [3:0] opcode,
    output logic [BW-1:0] out,
    output logic [2:0] flags
);

logic [$clog2(BW)-1:0] shamt;
logic zero;
logic negative;
logic overflow;

assign flags = {overflow,negative,zero};

always_comb begin
    shamt = in_b[$clog2(BW)-1:0];
    out = 0;
    zero = 0;
    negative = 0;
    overflow = 0;

    case (opcode)
        ADD: out = in_a + in_b;
        SUB: out = in_a - in_b;
        SLL: out = in_a << shamt;
        SLT: out = ($signed(in_a) < $signed(in_b)) ? 1 : 0;
        SLTU: out = ($unsigned(in_a) < $unsigned(in_b)) ? 1 : 0;
        XOR: out = in_a ^ in_b;
        SRL: out = in_a >> shamt;
        SRA: out = $signed(in_a) >>> shamt;
        OR: out = in_a | in_b;
        AND: out = in_a & in_b;
        PASS_B: out = in_b;
        default: out = 0;
    endcase

    if (out == 0) begin
        zero = 1;
    end else begin
        zero = 0;
    end

    if (out[BW-1] == 1) begin
        negative = 1;
    end else begin
        negative = 0;
    end

    if ((opcode == ADD) && (in_a[BW-1] == in_b[BW-1]) && (out[BW-1] != in_a[BW-1])) begin
        overflow = 1;
    end else if ((opcode == SUB) && (in_a[BW-1] != in_b[BW-1]) && (out[BW-1] != in_a[BW-1])) begin
        overflow = 1;
    end else begin
        overflow = 0;
    end

end

endmodule