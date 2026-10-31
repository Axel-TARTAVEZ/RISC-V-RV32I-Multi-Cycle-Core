module pc #(
    parameter integer BW = 32
) (
    input  logic clk,
    input  logic rst_n,

    input  logic pc_write_en,
    input  logic [BW-1:0] next_pc,
    
    output logic [BW-1:0] pc
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= '0;
        end 
        else if (pc_write_en) begin
            pc <= next_pc;
        end
    end

endmodule