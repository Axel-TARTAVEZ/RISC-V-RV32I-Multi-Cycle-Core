import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal=%0b, expected=%0b (funct3=%0b, a=%0h, b=%0h)", \
                 $time, signal, value, i_funct3, i_a, i_b); \
        $finish; \
    end

module branch_tb;

    logic i_branch;
    logic [2:0] i_funct3;
    logic [BW-1:0] i_a;
    logic [BW-1:0] i_b;
    logic o_take;

    branch dut (
        .i_branch(i_branch),
        .i_funct3(i_funct3),
        .i_a(i_a),
        .i_b(i_b),
        .o_take(o_take)
    );

    initial begin
        i_branch = 1'b0;
        for (int i = 0; i < 8; i++) begin
            i_funct3 = i[2:0];
            i_a = $urandom;
            i_b = $urandom;
            #1;
            `check(o_take, 1'b0)
        end

        i_branch = 1'b1;
        for (int i = 0; i < 8; i++) begin
            i_funct3 = i[2:0];
            for (int j = 0; j < 1000; j++) begin
                if (j % 5 == 0) begin
                    i_a = $urandom;
                    i_b = i_a;
                end else begin
                    i_a = $urandom;
                    i_b = $urandom;
                end

                #1;

                case (i_funct3)
                    3'b000: `check(o_take, (i_a == i_b))
                    3'b001: `check(o_take, (i_a != i_b))
                    3'b100: `check(o_take, ($signed(i_a) < $signed(i_b)))
                    3'b101: `check(o_take, ($signed(i_a) >= $signed(i_b)))
                    3'b110: `check(o_take, (i_a < i_b))
                    3'b111: `check(o_take, (i_a >= i_b))
                    default: `check(o_take, 1'b0)
                endcase
            end
        end

        $display("SUCCESS: All branch tests passed");
        $stop;
    end

endmodule