import definitions::*;

module decoder #(
    parameter integer BW = 32
) (
    input logic [BW-1:0] i_instruction,

    output logic [4:0] o_rs1_addr,
    output logic [4:0] o_rs2_addr,
    output logic [4:0] o_rd_addr,

    output logic [BW-1:0] o_imm,

    output logic o_alu_src_a,
    output logic o_alu_src_b,
    output logic [1:0] o_result_mux,
    
    output opcode_t o_alu_opcode,

    output logic o_is_load,
    output logic o_is_store,
    output logic o_reg_write,
    output logic o_branch,
    output logic o_jump,
    output logic o_stop_tb,
    output logic [2:0] o_funct3
);

    opcode_i_t opcode;
    assign opcode = opcode_i_t'(i_instruction[6:0]);

    assign o_rs1_addr = i_instruction[19:15];
    assign o_rs2_addr = i_instruction[24:20];
    assign o_rd_addr = i_instruction[11:7];

    logic [2:0] funct3;
    assign funct3 = i_instruction[14:12];

    logic funct7; 
    assign funct7 = i_instruction[30];

    always_comb begin
        o_imm = '0;
        o_branch = 1'b0;
        o_result_mux = 2'b00;
        o_funct3 = funct3;
        o_alu_src_a = 1'b0;
        o_alu_src_b = 1'b0;
        o_reg_write = 1'b0;
        o_is_load = 1'b0;
        o_is_store = 1'b0;
        o_jump = 1'b0;
        o_stop_tb = 1'b0;
        o_alu_opcode = ADD;

        case (opcode)
            OP_R_TYPE: begin
                o_alu_src_a = 1'b0;
                o_alu_src_b = 1'b0;
                o_reg_write = 1'b1;
                case (funct3)
                    3'b000: begin
                        if (funct7) o_alu_opcode = SUB;
                        else o_alu_opcode = ADD;
                    end
                    3'b001: o_alu_opcode = SLL;
                    3'b010: o_alu_opcode = SLT;
                    3'b011: o_alu_opcode = SLTU;
                    3'b100: o_alu_opcode = XOR;
                    3'b101: begin
                        if (funct7) o_alu_opcode = SRA;
                        else o_alu_opcode = SRL;
                    end
                    3'b110: o_alu_opcode = OR;
                    3'b111: o_alu_opcode = AND;
                endcase
            end

            OP_I_TYPE: begin
                o_imm = {{20{i_instruction[31]}}, i_instruction[31:20]};
                o_alu_src_a = 1'b0;
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                case (funct3)
                    3'b000: o_alu_opcode = ADD;
                    3'b001: o_alu_opcode = SLL;
                    3'b010: o_alu_opcode = SLT;
                    3'b011: o_alu_opcode = SLTU;
                    3'b100: o_alu_opcode = XOR;
                    3'b101: begin
                        if (funct7) o_alu_opcode = SRA;
                        else o_alu_opcode = SRL;
                    end
                    3'b110: o_alu_opcode = OR;
                    3'b111: o_alu_opcode = AND;
                endcase
            end

            OP_LOAD: begin
                o_imm = {{20{i_instruction[31]}}, i_instruction[31:20]};
                o_alu_src_a = 1'b0;
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                o_result_mux = 2'b01;
                o_is_load = 1'b1;
                o_alu_opcode = ADD;
            end

            OP_STORE: begin
                o_imm = {{20{i_instruction[31]}}, i_instruction[31:25], i_instruction[11:7]};
                o_alu_src_a = 1'b0;
                o_alu_src_b = 1'b1;
                o_is_store = 1'b1;
                o_alu_opcode = ADD;
            end

            OP_BRANCH: begin 
                o_imm = {{19{i_instruction[31]}}, i_instruction[31], i_instruction[7], i_instruction[30:25], i_instruction[11:8], 1'b0};
                o_branch = 1'b1; 
                o_alu_src_a = 1'b1;
                o_alu_src_b = 1'b1;
                o_alu_opcode = ADD; 
            end

            OP_LUI: begin
                o_imm = {i_instruction[31:12], 12'b0};
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                o_alu_opcode = PASS_B;
            end

            OP_AUIPC: begin
                o_imm = {i_instruction[31:12], 12'b0};
                o_alu_src_a = 1'b1;
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                o_alu_opcode = ADD;
            end

            OP_JAL: begin
                o_imm = {{11{i_instruction[31]}}, i_instruction[31], i_instruction[19:12], i_instruction[20], i_instruction[30:21], 1'b0};
                o_alu_src_a = 1'b1;
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                o_result_mux = 2'b10;
                o_jump = 1'b1;
                o_alu_opcode = ADD;
            end

            OP_JALR: begin
                o_imm = {{20{i_instruction[31]}}, i_instruction[31:20]};
                o_alu_src_a = 1'b0;
                o_alu_src_b = 1'b1;
                o_reg_write = 1'b1;
                o_result_mux = 2'b10;
                o_jump = 1'b1;
                o_alu_opcode = ADD;
            end

            OP_SYSTEM: begin
                // 12'b0 = ECALL, 12'b1 = EBREAK
                if (i_instruction[31:20] == 12'b000000000000 || i_instruction[31:20] == 12'b000000000001) begin
                    o_stop_tb = 1'b1;
                end
            end

            OP_FENCE: begin
            end

            default: begin
            end
        endcase
    end
endmodule