import definitions::*;

module controller #(
    parameter integer BW = 32
)(
    input  logic clk,
    input  logic rst_n,

    // Decoder
    input  logic i_is_load,
    input  logic i_is_store,
    input  logic i_reg_write,

    // Memory
    input logic i_mem_ready,

    // RF
    output logic o_rf_write_en_n,

    // Datapath / Memory
    output logic o_mem_read_en,
    output logic o_mem_write_en,
    output logic o_addr_mux_sel,
    output logic o_pc_write_en
);
    
    ctrl_state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= FETCH;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;

        case (current_state)
            FETCH: begin
                if (i_mem_ready) begin
                    next_state = EXECUTE_1;
                end
            end
            
            EXECUTE_1: begin
                if (i_is_load || i_is_store) begin
                    next_state = EXECUTE_2;
                end else begin
                    next_state = FETCH;
                end
            end
            
            EXECUTE_2: begin
                if (i_mem_ready) begin
                    next_state = FETCH;
                end
            end
            
            default: next_state = FETCH;
        endcase
    end

    always_comb begin
        o_rf_write_en_n = 1'b1;
        o_mem_read_en = 1'b0;
        o_mem_write_en = 1'b0;
        o_addr_mux_sel = 1'b0;
        o_pc_write_en = 1'b0;

        case (current_state)
            FETCH: begin
                o_mem_read_en = 1'b1; 
                o_addr_mux_sel = 1'b0; 
            end

            EXECUTE_1: begin
                if (!i_is_load && !i_is_store) begin
                    o_pc_write_en = 1'b1; 
                    if (i_reg_write) o_rf_write_en_n = 1'b0; 
                end
            end

            EXECUTE_2: begin
                o_addr_mux_sel = 1'b1; 

                if (i_is_load)  o_mem_read_en = 1'b1;
                if (i_is_store) o_mem_write_en = 1'b1;

                if (i_mem_ready) begin
                    o_pc_write_en  = 1'b1; 
                    if (i_is_load && i_reg_write) begin
                        o_rf_write_en_n = 1'b0;
                    end
                end
            end
        endcase
    end

endmodule