module load_unit #(
    parameter integer BW = 32
)(
    input  logic [2:0] i_funct3,
    input  logic [1:0] i_addr_alu,
    input  logic [BW-1:0] i_data_out,
    output logic [BW-1:0] o_data_load
);

    logic [7:0]  extracted_byte;
    logic [15:0] extracted_half;

    always_comb begin

        case (i_addr_alu)
            2'b00: extracted_byte = i_data_out[7:0];
            2'b01: extracted_byte = i_data_out[15:8];
            2'b10: extracted_byte = i_data_out[23:16];
            2'b11: extracted_byte = i_data_out[31:24];
        endcase

        case (i_addr_alu[1]) 
            1'b0: extracted_half = i_data_out[15:0];
            1'b1: extracted_half = i_data_out[31:16];
        endcase
    end

    always_comb begin
        case (i_funct3)
            3'b000: o_data_load = {{24{extracted_byte[7]}}, extracted_byte}; // LB
            3'b001: o_data_load = {{16{extracted_half[15]}}, extracted_half}; // LH
            3'b010: o_data_load = i_data_out; // LW
            3'b100: o_data_load = {24'b0, extracted_byte}; // LBU
            3'b101: o_data_load = {16'b0, extracted_half}; // LHU
            default: o_data_load = i_data_out;
        endcase
    end

endmodule