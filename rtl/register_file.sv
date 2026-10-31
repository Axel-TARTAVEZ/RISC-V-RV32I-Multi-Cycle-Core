import definitions::*;

module register_file #(
    parameter integer BW = 32,
    parameter integer DEPTH = 32
) (
    input logic clk,
    input logic rst_n,
    input logic chip_en,

    input logic [BW-1:0] data_in,
    input logic [$clog2(DEPTH)-1:0] write_addr,
    input logic write_en_n,

    input logic [$clog2(DEPTH)-1:0] read_addr_1,
    input logic [$clog2(DEPTH)-1:0] read_addr_2,

    output logic [BW-1:0] data_out_1,
    output logic [BW-1:0] data_out_2
);

logic [BW-1:0] registers [DEPTH-1:0];

always_comb begin
    if (chip_en) begin
        data_out_1 = registers[read_addr_1];
        data_out_2 = registers[read_addr_2];
    end else begin
        data_out_1 = '0;
        data_out_2 = '0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < DEPTH; i++) begin
            registers[i] <= '0;
        end
    end else if (!write_en_n && chip_en && write_addr != 0) begin
        registers[write_addr] <= data_in;
    end
end

endmodule