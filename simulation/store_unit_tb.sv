import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal=%0b, expected=%0b (funct3=%b, addr=%b)", \
                 $time, signal, value, i_funct3, i_addr_alu); \
    end

module store_unit_tb;

    parameter int BW = 32;

    logic [2:0]    i_funct3;
    logic [1:0]    i_addr_alu;
    logic          i_mem_write_en;
    logic [BW-1:0] i_rs2_data;

    logic [3:0]    o_write_en;
    logic [BW-1:0] o_mem_data;

    store_unit #(
        .BW(BW)
    ) dut (
        .i_funct3(i_funct3),
        .i_addr_alu(i_addr_alu),
        .i_mem_write_en(i_mem_write_en),
        .i_rs2_data(i_rs2_data),
        .o_write_en(o_write_en),
        .o_mem_data(o_mem_data)
    );

    logic [3:0]    exp_write_en;
    logic [BW-1:0] exp_mem_data;

    initial begin

        i_mem_write_en = 0;
        i_funct3 = $urandom;
        i_addr_alu = $urandom;
        i_rs2_data = $urandom;
        #1; 
        `check(o_write_en, 4'b0000);

        i_mem_write_en = 1;
        
        for (int i = 0; i < 10000; i++) begin
            i_funct3   = $urandom_range(0, 2); 
            i_addr_alu = $urandom_range(0, 3);
            i_rs2_data = $urandom;

            #1;

            if (i_funct3 == 3'b000) begin
                exp_write_en = 4'b0001 << i_addr_alu; 
                exp_mem_data = {4{i_rs2_data[7:0]}};
            end 
            else if (i_funct3 == 3'b001) begin
                exp_write_en = (i_addr_alu[1] == 1'b0) ? 4'b0011 : 4'b1100;
                exp_mem_data = {2{i_rs2_data[15:0]}};
            end 
            else begin
                exp_write_en = 4'b1111;
                exp_mem_data = i_rs2_data;
            end

            `check(o_write_en, exp_write_en);
            `check(o_mem_data, exp_mem_data);
        end

        $display("SUCCESS: All store_unit tests passed");
        $finish;
    end

endmodule