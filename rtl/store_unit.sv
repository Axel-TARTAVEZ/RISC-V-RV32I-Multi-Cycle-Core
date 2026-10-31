module store_unit #(
    parameter integer BW = 32
)(
    input  logic [2:0] i_funct3,
    input  logic [1:0] i_addr_alu,
    input  logic i_mem_write_en,
    input  logic [BW-1:0] i_rs2_data,

    output logic [3:0] o_write_en,
    output logic [BW-1:0] o_mem_data
);

    always_comb begin

        o_write_en = 4'b0000;
        o_mem_data = i_rs2_data; 

        if (i_mem_write_en) begin
            case (i_funct3)
                
                3'b000: begin 

                    o_mem_data = {4{i_rs2_data[7:0]}}; 

                    case (i_addr_alu)
                        2'b00: o_write_en = 4'b0001;
                        2'b01: o_write_en = 4'b0010;
                        2'b10: o_write_en = 4'b0100;
                        2'b11: o_write_en = 4'b1000;
                    endcase
                end
                
                3'b001: begin

                    o_mem_data = {2{i_rs2_data[15:0]}};

                    if (i_addr_alu[1] == 1'b0) begin
                        o_write_en = 4'b0011;
                    end else begin
                        o_write_en = 4'b1100;
                    end
                end
                
                3'b010: begin
                    o_mem_data = i_rs2_data;
                    o_write_en = 4'b1111;
                end
                
                default: begin
                    o_write_en = 4'b0000;
                end
            endcase
        end
    end
endmodule