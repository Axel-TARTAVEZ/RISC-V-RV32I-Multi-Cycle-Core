import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal=%0h, expected=%0h", $time, signal, value); \
        $finish; \
    end

module alu_tb;

    logic [BW-1:0] in_a;
    logic [BW-1:0] in_b;
    logic [3:0] opcode;
    logic [BW-1:0] out;
    logic [2:0] flags;

    alu dut (
        .in_a(in_a),
        .in_b(in_b),
        .opcode(opcode),
        .out(out),
        .flags(flags)
    );

    integer i;
    logic [BW-1:0] expected_out;

    initial begin
        for (i = 0; i < 100000; i++) begin
            in_a = $urandom;
            in_b = $urandom;
            opcode = $urandom_range(0, 15);

            #1;

            case (opcode)
                ADD: expected_out = in_a + in_b;
                SUB: expected_out = in_a - in_b;
                SLL: expected_out = in_a << in_b[$clog2(BW)-1:0];
                SLT: expected_out = ($signed(in_a) < $signed(in_b)) ? 1 : 0;
                SLTU: expected_out = ($unsigned(in_a) < $unsigned(in_b)) ? 1 : 0;
                XOR: expected_out = in_a ^ in_b;
                SRL: expected_out = in_a >> in_b[$clog2(BW)-1:0];
                SRA: expected_out = $signed(in_a) >>> in_b[$clog2(BW)-1:0];
                OR: expected_out = in_a | in_b;
                AND: expected_out = in_a & in_b;
                PASS_B: expected_out = in_b;
                default: expected_out = 0;
            endcase

            `check(out, expected_out);

            // Flag Zero
            if (out == 0) assert(flags[0] == 1) else $fatal(1, "Wrong zero flag for out = %h", out);
            if (out != 0) assert(flags[0] == 0) else $fatal(1, "Wrong zero flag for out = %h", out);

            // Flag Négatif
            assert(flags[1] == out[BW-1]) else $fatal(1, "Wrong negative flag for out = %h", out);

            // Flag Overflow (ADD et SUB)
            if (opcode == ADD) 
                assert(flags[2] == ((in_a[BW-1] == in_b[BW-1]) && (out[BW-1] != in_a[BW-1]))) 
                else $fatal(1, "Wrong overflow ADD");
                
            if (opcode == SUB) 
                assert(flags[2] == ((in_a[BW-1] != in_b[BW-1]) && (out[BW-1] != in_a[BW-1]))) 
                else $fatal(1, "Wrong overflow SUB");
        end
        $display("SUCCESS: All alu tests passed");
        $stop;
    end
endmodule