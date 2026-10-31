import definitions::*;

`default_nettype none
`timescale 1ns/1ns

module register_file_tb;

    logic clk;
    logic rst_n;
    logic chip_en;
    logic [BW-1:0] data_in;
    logic [$clog2(DEPTH)-1:0] write_addr;
    logic write_en_n;
    logic [$clog2(DEPTH)-1:0] read_addr_1;
    logic [$clog2(DEPTH)-1:0] read_addr_2;
    logic [BW-1:0] data_out_1;
    logic [BW-1:0] data_out_2;

    register_file dut (
        .clk(clk),
        .rst_n(rst_n),
        .chip_en(chip_en),
        .data_in(data_in),
        .write_addr(write_addr),
        .write_en_n(write_en_n),
        .read_addr_1(read_addr_1),
        .read_addr_2(read_addr_2),
        .data_out_1(data_out_1),
        .data_out_2(data_out_2)
    );

    logic [BW-1:0] registers [DEPTH-1:0];
    integer i;

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; chip_en = 0;
        #20; 
        rst_n = 1; chip_en = 1;

        for (int j = 0; j < DEPTH; j++) begin
            registers[j] = '0;
        end

        for (i = 0; i < 100000; i++) begin

            @(negedge clk);

            data_in = $urandom;
            write_addr = $urandom_range(0, DEPTH-1);
            write_en_n = $urandom_range(0, 1);
            read_addr_1 = $urandom_range(0, DEPTH-1);
            read_addr_2 = $urandom_range(0, DEPTH-1);

            #1;

            if (chip_en) begin
                if (read_addr_1 != 0) begin
                    assert(registers[read_addr_1] == data_out_1) else $fatal(1, "Read failed at time %0t: data_out_1=%0h, expected=%0h", $time, data_out_1, registers[read_addr_1]);
                end
                else begin
                    assert(registers[read_addr_1] == '0) else $fatal(1, "Read failed at time %0t: data_out_1=%0h, register=%0h, expected=%0h", $time, data_out_1, registers[read_addr_1], '0);
                end
                if (read_addr_2 != 0) begin
                    assert(registers[read_addr_2] == data_out_2) else $fatal(1, "Read failed at time %0t: data_out_2=%0h, expected=%0h", $time, data_out_2, registers[read_addr_2]);
                end
                else begin
                    assert(registers[read_addr_2] == '0) else $fatal(1, "Read failed at time %0t: data_out_2=%0h, register=%0h, expected=%0h", $time, data_out_2, registers[read_addr_2], '0);
                end
            end

            if (!write_en_n && chip_en && write_addr != 0) begin
                registers[write_addr] = data_in;
            end
        end

        $display("SUCCESS: All register_file tests passed");
        $stop;
    end

endmodule