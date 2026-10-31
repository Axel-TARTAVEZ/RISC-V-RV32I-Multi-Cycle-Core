module urbana_top (
    input  logic CLK_100MHZ,
    input  logic [15:0] SW,
    output logic [15:0] LED,
    output logic [7:0] D1_SEG,
    output logic [3:0] D1_AN,
    output logic [7:0] D0_SEG,
    output logic [3:0] D0_AN
);
    logic rst_n;
    logic clk_cpu;

    logic stop_tb;
    logic [31:0] pc;
    logic [31:0] cpu_data_out;
    logic [3:0]  write_en;
    logic read_en;
    logic mem_ready;

    logic [15:0] display_data;

    // 1. Reset Assigned to a Switch
    assign rst_n = SW[0];

    // 2. Diagnostic LED Mapping
    assign LED[4:0] = {mem_ready, |write_en, read_en, rst_n, clk_cpu};
    assign LED[15:5] = '0; // Éteindre les LEDs inutilisées

    // 3. Clock Slowdown
    clock_divider #(.DIVISOR(428571)) clk_div_inst (
        .rst_n(rst_n),
        .clk_in(CLK_100MHZ),
        .clk_out(clk_cpu)
    );

    // 4. Processor
    riscv_top CPU (
        .clk(clk_cpu),
        .rst_n(rst_n),
        .stop_tb(),
        .o_pc(pc),
        .o_data_out(cpu_data_out),
        .o_write_en(write_en),
        .o_read_en(read_en),
        .o_mem_ready(mem_ready)
    );

    // 5. Capture of the last written data
    registers #(.WIDTH(16)) display_register (
        .clk(clk_cpu),
        .rst_n(rst_n),
        .load(|write_en), 
        .data_in(cpu_data_out[15:0]),
        .data_out(display_data)
    );

    // 6. Left Display: Program Counter (16 bits)
    kw4281_driver driver_left (
        .rst_n(1'b1), 
        .clk(CLK_100MHZ), 
        .input_bcd({pc[15:12], pc[11:8], pc[7:4], pc[3:0]}), 
        .input_dots(4'b0000),
        .an(D0_AN), 
        .seg(D0_SEG)
    );
    
    // 7. Right Display: Last data written (16 bits)
    kw4281_driver driver_right (
        .rst_n(1'b1), 
        .clk(CLK_100MHZ), 
        .input_bcd({display_data[15:12], display_data[11:8], display_data[7:4], display_data[3:0]}), 
        .input_dots(4'b0000),
        .an(D1_AN), 
        .seg(D1_SEG)
    );

endmodule
