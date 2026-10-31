import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal=%0b, expected=%0b (funct3=%b, addr=%b)", \
                 $time, signal, value, i_funct3, i_addr_alu); \
    end

module load_unit_tb;

    parameter int BW = 32;

    logic [2:0] i_funct3;
    logic [1:0] i_addr_alu;
    logic [BW-1:0] i_data_out;
    logic [BW-1:0] o_data_load;

    load_unit #(
        .BW(BW)
    ) dut (
        .i_funct3(i_funct3),
        .i_addr_alu(i_addr_alu),
        .i_data_out(i_data_out),
        .o_data_load(o_data_load)
    );

logic [BW-1:0]  exp_data_load;
    
    logic [2:0] valid_funct3 [0:4] = '{3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
    int random_index;

    initial begin
        
        for (int i = 0; i < 10000; i++) begin
            random_index = $urandom_range(0, 4);
            i_funct3   = valid_funct3[random_index]; 
            i_addr_alu = $urandom_range(0, 3);
            i_data_out = $urandom;

            #1; 

            case (i_funct3)
                3'b000: begin // LB
                    logic [7:0] byte_val;
                    byte_val = i_data_out >> (i_addr_alu * 8);
                    exp_data_load = {{24{byte_val[7]}}, byte_val};
                end 
                3'b001: begin // LH
                    logic [15:0] half_val;
                    half_val = i_data_out >> (i_addr_alu[1] * 16);
                    exp_data_load = {{16{half_val[15]}}, half_val};
                end 
                3'b010: begin // LW
                    exp_data_load = i_data_out;
                end 
                3'b100: begin // LBU
                    logic [7:0] byte_val;
                    byte_val = i_data_out >> (i_addr_alu * 8);
                    exp_data_load = {24'b0, byte_val};
                end 
                3'b101: begin // LHU
                    logic [15:0] half_val;
                    half_val = i_data_out >> (i_addr_alu[1] * 16);
                    exp_data_load = {16'b0, half_val};
                end
                default: exp_data_load = i_data_out;
            endcase

            `check(o_data_load, exp_data_load);
        end

        $display("SUCCESS: All load_unit tests passed");
        $finish;
    end
endmodule