import definitions::*;

module memory_FSM #(
    parameter integer BW = 32
) (
    input logic clk,
    input logic rst_n,

    input logic [BW-1:0] data_in,
    input logic [BW-1:0] addr,
    input logic [3:0] write_en,
    input logic read_en,

    output logic [BW-1:0] data_out,
    output logic mem_ready

);

logic [13:0] addr_14B;
assign addr_14B = addr[15:2];
logic ena;
assign ena = read_en || (write_en != 4'b0000);

data_SRAM data_SRAM (
  .clka(clk),
  .ena(ena),
  .wea(write_en),
  .addra(addr_14B),
  .dina(data_in),
  .douta(data_out)
);

mem_state_t current_state;
mem_state_t next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = current_state;
    mem_ready = 1'b0;

    case (current_state)
        IDLE: begin
            mem_ready = 1'b0;
            if (read_en) begin
                next_state = WAIT;
            end else if (write_en != 4'b0000) begin
                next_state = READY;
            end
            else begin
                next_state = IDLE;
            end
        end

        WAIT: begin
            next_state = READY;
        end

        READY: begin
            mem_ready = 1'b1;
            next_state = IDLE;
        end

        default: next_state = IDLE;
    endcase
end

endmodule