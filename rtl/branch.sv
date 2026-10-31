module branch #(
    parameter integer BW = 32
) (
    input logic i_branch,
    input logic [2:0] i_funct3,
    input logic [BW-1:0] i_a,
    input logic [BW-1:0] i_b,
    
    output logic o_take
);

    always_comb begin
        o_take = 1'b0;
        
        if (i_branch) begin
            case(i_funct3)  
                3'b000: o_take = (i_a == i_b); // BEQ
                3'b001: o_take = (i_a != i_b); // BNE
                3'b100: o_take = ($signed(i_a) < $signed(i_b)); // BLT
                3'b101: o_take = ($signed(i_a) >= $signed(i_b)); // BGE
                3'b110: o_take = (i_a < i_b); // BLTU
                3'b111: o_take = (i_a >= i_b); // BGEU
                default : o_take = 1'b0;
            endcase
        end 
    end

endmodule