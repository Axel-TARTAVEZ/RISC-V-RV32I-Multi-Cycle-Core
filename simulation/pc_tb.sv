import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal=%0h, expected=%0h", $time, signal, value); \
    end

module pc_tb;

    parameter int BW = 32;

    logic clk;
    logic rst_n;
    logic pc_write_en;
    logic [BW-1:0] next_pc;
    logic [BW-1:0] pc;

    logic [BW-1:0] expected_pc;

    pc #(
        .BW(BW)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_write_en(pc_write_en),
        .next_pc(next_pc),
        .pc(pc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        rst_n = 0;
        pc_write_en = 0;
        next_pc = 0;
        expected_pc = 0;

        #15; 
        rst_n = 1;
        
        `check(pc, 32'b0);

        for (int i = 0; i < 10000; i++) begin
            
            @(negedge clk);
            pc_write_en = $urandom_range(0, 1);
            next_pc = $urandom;

            if (pc_write_en) begin
                expected_pc = next_pc;
            end

            @(posedge clk);
            #1;
            `check(pc, expected_pc);
        end
        
        $display("SUCCESS: All pc tests passed");
        $finish;
    end
endmodule