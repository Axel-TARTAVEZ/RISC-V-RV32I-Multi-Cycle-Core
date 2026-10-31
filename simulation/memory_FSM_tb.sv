import definitions::*;

`default_nettype none
`timescale 1ns/1ns

module memory_FSM_tb;

    parameter integer BW = 32;

    logic clk;
    logic rst_n;

    logic [BW-1:0] data_in;
    logic [BW-1:0] addr;
    logic [3:0] write_en;
    logic read_en;

    logic [BW-1:0] data_out;
    logic mem_ready;

    memory_FSM dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .addr(addr),
        .write_en(write_en),
        .read_en(read_en),
        .data_out(data_out),
        .mem_ready(mem_ready)
    );

    logic [13:0] addr_14B;
    assign addr_14B = addr[15:2];

    mem_state_t fsm_state_viewer;
    assign fsm_state_viewer = dut.current_state;

    logic [BW-1:0] memory [2**14-1:0];
    int action;

    always #5 clk = ~clk;

    initial begin
        clk = 0; 
        rst_n = 0; 
        data_in = '0; 
        addr = '0; 
        write_en = 4'b0000; 
        read_en = 1'b0;

        #110; 
        rst_n = 1;

        for (int i = 0; i < 2**14; i++) begin
            memory[i] = '0;

            @(negedge clk);
            read_en = 1'b0;
            write_en = 4'b1111;
            addr = i << 2;
            data_in = 32'h0;

            wait(mem_ready == 1'b1);
            
            @(posedge clk);
            
            @(negedge clk);
            write_en = 4'b0000;
        end

        for (int i = 0; i < 100000; i++) begin
            @(negedge clk);

            data_in = $urandom;
            addr = $urandom; 
            
            action = $urandom_range(0, 2);
            
            // Read
            if (action == 1) begin
                read_en = 1'b1;
                write_en = 4'b0000;
                
                wait(mem_ready == 1'b1);

                @(negedge clk);
                
                assert(data_out === memory[addr_14B]) else 
                    $fatal(1, "T=%0t: Read mismatch Addr=%0h, Expected=%0h, Got=%0h", $time, addr_14B, memory[addr_14B], data_out);
                
                @(posedge clk);
                read_en = 1'b0;
            
            // Write
            end else if (action == 2) begin
                read_en = 1'b0;
                write_en = $urandom_range(1, 15);
                
                wait(mem_ready == 1'b1);
                
                if (write_en[0]) memory[addr_14B][7:0]   = data_in[7:0];
                if (write_en[1]) memory[addr_14B][15:8]  = data_in[15:8];
                if (write_en[2]) memory[addr_14B][23:16] = data_in[23:16];
                if (write_en[3]) memory[addr_14B][31:24] = data_in[31:24];

                @(negedge clk);
                write_en = 4'b0000;

            // Idle
            end else begin
                read_en = 1'b0;
                write_en = 4'b0000;
                #1; 
                assert(mem_ready == 1'b0) else $fatal(1, "T=%0t: mem_ready asserted during IDLE state", $time);
            end

        end
        $display("SUCCESS: All memory_FSM tests passed");
        $stop;
    end
endmodule