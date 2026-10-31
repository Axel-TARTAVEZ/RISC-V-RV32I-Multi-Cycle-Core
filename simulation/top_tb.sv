`default_nettype none
`timescale 1ns/1ns

module top_tb;

    logic clk;
    logic rst_n;
    logic stop_tb;
    logic [31:0] tb_pc;
    logic [31:0] tb_data_out;
    logic [3:0] tb_write_en;
    logic tb_read_en;
    logic tb_mem_ready;

    riscv_top #(
        .BW(32)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .stop_tb(stop_tb),
        .o_pc(tb_pc),
        .o_data_out(tb_data_out),
        .o_write_en(tb_write_en),
        .o_read_en(tb_read_en),
        .o_mem_ready(tb_mem_ready)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer fd;
    string current_test_file;

    initial begin

        int timeout_counter;

        $display("Starting Automated RISC-V Compliance Test Suite...");

        fd = $fopen("C:/Users/axelt/Documents/KTH/Courses/IL2234 Digital Design/Project/RISCV/program/riscv_test/test_list.txt", "r");
        
        if (fd == 0) begin
            $display("FATAL: Cannot open test_list.txt. Check the path.");
            $finish;
        end

        while (!$feof(fd)) begin

            $fgets(current_test_file, fd);
            
            while (current_test_file.len() > 0 && 
                  (current_test_file[current_test_file.len()-1] == "\n" || 
                   current_test_file[current_test_file.len()-1] == "\r" ||
                   current_test_file[current_test_file.len()-1] == " ")) begin
                current_test_file = current_test_file.substr(0, current_test_file.len()-2);
            end

            if (current_test_file.len() == 0) continue;

            $display("\n=======================================");
            $display(" RUNNING TEST : %s", current_test_file);
            $display("=======================================");
            
            $readmemh(current_test_file, dut.memory_FSM.data_SRAM.inst.native_mem_module.blk_mem_gen_v8_4_13_inst.memory);
            
            rst_n = 0;
            #20;
            rst_n = 1;

            timeout_counter = 0;

            while (stop_tb !== 1'b1 && timeout_counter < 10000) begin
                @(posedge clk);
                timeout_counter++;
            end

            if (stop_tb == 1'b1) begin

                if (dut.register_file.registers[3] === 32'd1) begin
                    $display("PASS");
                end else begin
                    $display("FAIL at subtest #%0d", dut.register_file.registers[3] >> 1);
                    $finish;
                end

            end else begin

                $display("TIMEOUT: CPU stuck");
                $finish;
            end

            #10;
        end
        
        $display("\n=======================================");
        $display("   ALL TESTS PASSED SUCCESSFULLY       ");
        $display("=======================================");
        
        $fclose(fd);$finish;
    end

endmodule