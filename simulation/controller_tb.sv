import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal %s = %0b, expected = %0b", \
                 $time, `"signal`", signal, value); \
    end

module controller_tb;

    logic clk;
    logic rst_n;

    logic i_is_load;
    logic i_is_store;
    logic i_reg_write;
    logic i_mem_ready;

    logic o_rf_write_en_n;
    logic o_mem_read_en;
    logic o_mem_write_en;
    logic o_addr_mux_sel;
    logic o_pc_write_en;
    
    controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .i_is_load(i_is_load),
        .i_is_store(i_is_store),
        .i_reg_write(i_reg_write),
        .i_mem_ready(i_mem_ready),
        .o_rf_write_en_n(o_rf_write_en_n),
        .o_mem_read_en(o_mem_read_en),
        .o_mem_write_en(o_mem_write_en),
        .o_addr_mux_sel(o_addr_mux_sel),
        .o_pc_write_en(o_pc_write_en)
    );

    ctrl_state_t fsm_state_viewer;
    assign fsm_state_viewer = dut.current_state;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Starting controller FSM tests");

        // Init inputs
        i_is_load = 0; i_is_store = 0; i_reg_write = 0;
        i_mem_ready = 0; 
        
        rst_n = 0;
        #17; 
        rst_n = 1; // FSM starts in FETCH




        // Test 1: Standard instruction (e.g. ADD) with delayed fetch
        @(negedge clk);
        i_is_load = 0; i_is_store = 0; i_reg_write = 1; 
        i_mem_ready = 0; // Simulate memory delay
        
        #1;
        `check(o_mem_read_en, 1'b1);
        
        @(posedge clk); // FSM should hold in FETCH since ready=0
        
        @(negedge clk);
        i_mem_ready = 1; // Memory is ready
        
        // Move to EXECUTE_1
        @(posedge clk); #1;
        `check(o_rf_write_en_n, 1'b0); 
        `check(o_pc_write_en, 1'b1);   
        i_mem_ready = 0; // Clear for next instruction




        // Test 2: STORE instruction stalling in EXECUTE_2
        @(posedge clk); 
        
        @(negedge clk);
        i_is_store = 1; i_reg_write = 0;
        i_mem_ready = 1; 
        
        // Move to EXECUTE_1
        @(posedge clk); #1;
        `check(o_pc_write_en, 1'b0); 

        // Clear mem_ready to force a wait state
        @(negedge clk);
        i_mem_ready = 0; 

        // Move to EXECUTE_2 (wait state)
        @(posedge clk); #1;
        `check(o_mem_write_en, 1'b1);
        `check(o_pc_write_en, 1'b0);

        // EXECUTE_2 completion
        @(posedge clk); 
        @(negedge clk);
        i_mem_ready = 1; 
        #1;
        `check(o_pc_write_en, 1'b1); 




        // Test 3: LOAD instruction stalling in EXECUTE_2
        @(posedge clk); 
        
        @(negedge clk);
        i_is_load = 1; i_is_store = 0; i_reg_write = 1;
        i_mem_ready = 1; 

        // Move to EXECUTE_1
        @(posedge clk); #1;
        `check(o_rf_write_en_n, 1'b1); 

        // Force wait state
        @(negedge clk);
        i_mem_ready = 0; 

        // Move to EXECUTE_2 (wait state)
        @(posedge clk); #1;
        `check(o_mem_read_en, 1'b1);  
        `check(o_rf_write_en_n, 1'b1); 

        // EXECUTE_2 completion
        @(posedge clk);
        @(negedge clk);
        i_mem_ready = 1; 
        #1;
        `check(o_rf_write_en_n, 1'b0); 
        `check(o_pc_write_en, 1'b1);

        $display("SUCCESS: All controller tests passed");
        $finish;
    end

endmodule