`default_nettype none
`timescale 1ns/1ns

module firmware_tb;

    logic clk;
    logic rst_n;
    logic stop_tb;
    logic [31:0] tb_pc;
    logic [31:0] tb_data_out;
    logic [3:0] tb_write_en;
    logic tb_read_en;
    logic tb_mem_ready;
    logic [31:0] final_value = 0;

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

    always @(posedge clk) begin
        if (rst_n && (|tb_write_en) && dut.mem_addr == 32'h0000A000) begin
            final_value = tb_data_out;
        end
    end

    initial begin
        int timeout_counter = 0;
        string firmware_file = "C:/Users/axelt/Documents/KTH/Courses/IL2234 Digital Design/Project/RISCV/program/firmware.hex";
        
        while (firmware_file.len() > 0 && 
              (firmware_file[firmware_file.len()-1] == "\n" || 
               firmware_file[firmware_file.len()-1] == "\r" ||
               firmware_file[firmware_file.len()-1] == " ")) begin
            firmware_file = firmware_file.substr(0, firmware_file.len()-1);
        end
        
        $display("Starting Firmware Test...");
        $readmemh(firmware_file, dut.memory_FSM.data_SRAM.inst.native_mem_module.blk_mem_gen_v8_4_13_inst.memory);

        rst_n = 0;
        #20;
        rst_n = 1;

        while (tb_pc !== 32'h000000C8 && timeout_counter < 100000) begin
            @(posedge clk);
            timeout_counter++;
        end

        if (tb_pc == 32'h000000C8) begin
            $display("\n=======================================");
            $display("  FIRMWARE TESTS PASSED SUCCESSFULLY   ");
            $display("  Program reached the infinite loop.   ");
            $display("  FINAL RESULT: %0d (0x%h)", final_value, final_value);
            $display("=======================================\n");
        end else begin
            $display("\n=======================================");
            $display("        TIMEOUT: Program stuck.        ");
            $display("        Current PC = %h", tb_pc);
            $display("  FINAL RESULT: %0d (0x%h)", final_value, final_value);
            $display("=======================================");
        end

        $stop;
    end

endmodule