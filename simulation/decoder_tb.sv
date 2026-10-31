import definitions::*;

`default_nettype none
`timescale 1ns/1ns

`define check(signal, value) \
    if ((signal) !== (value)) begin \
        $fatal(1, "Test failed at time %0t: signal %s = %0h, expected = %0h (instruction = %0h)", \
                 $time, `"signal`", signal, value, instruction); \
    end

module decoder_tb;

    parameter integer BW = 32;

    logic [BW-1:0] instruction;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd_addr;

    logic [BW-1:0] imm;

    logic alu_src_a;
    logic alu_src_b;
    logic [1:0] result_mux;
    
    opcode_t alu_opcode;

    logic is_load;
    logic is_store;
    logic reg_write;
    logic branch;
    logic jump;
    logic [2:0] funct3;

    decoder #(
        .BW(BW)
    ) dut (
        .i_instruction(instruction),

        .o_rs1_addr(rs1),
        .o_rs2_addr(rs2),
        .o_rd_addr(rd_addr),

        .o_imm(imm),
        
        .o_alu_src_a(alu_src_a),
        .o_alu_src_b(alu_src_b),
        .o_result_mux(result_mux),

        .o_alu_opcode(alu_opcode),

        .o_is_load(is_load),
        .o_is_store(is_store),
        .o_reg_write(reg_write),
        .o_branch(branch),
        .o_jump(jump),
        .o_funct3(funct3)
    );

    initial begin
        
        logic [6:0] op;
        logic [BW-1:0] exp_imm;

        for (int i = 0; i < 100000; i++) begin
            instruction = $urandom;
            #1;
            op = instruction[6:0];

            `check(rs1, instruction[19:15]);
            `check(rs2, instruction[24:20]);
            `check(rd_addr, instruction[11:7]);
            `check(funct3, instruction[14:12]);

            case (op)
                OP_R_TYPE: begin
                    `check(alu_src_a, 1'b0);
                    `check(alu_src_b, 1'b0);
                    `check(reg_write, 1'b1);
                    `check(is_load, 1'b0);
                    `check(is_store, 1'b0);
                    `check(branch, 1'b0);
                    `check(jump, 1'b0);
                end

                OP_I_TYPE: begin
                    exp_imm = {{20{instruction[31]}}, instruction[31:20]};
                    `check(imm, exp_imm);
                    `check(alu_src_a, 1'b0);
                    `check(alu_src_b, 1'b1);
                    `check(reg_write, 1'b1);
                end

                OP_LOAD: begin
                    exp_imm = {{20{instruction[31]}}, instruction[31:20]};
                    `check(imm, exp_imm);
                    `check(alu_src_a, 1'b0);
                    `check(alu_src_b, 1'b1);
                    `check(reg_write, 1'b1);
                    `check(result_mux, 2'b01);
                    `check(is_load, 1'b1);
                    `check(alu_opcode, ADD);
                end

                OP_STORE: begin
                    exp_imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                    `check(imm, exp_imm);
                    `check(alu_src_a, 1'b0);
                    `check(alu_src_b, 1'b1);
                    `check(is_store, 1'b1);
                    `check(reg_write, 1'b0);
                    `check(alu_opcode, ADD);
                end

                OP_BRANCH: begin
                    exp_imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    `check(imm, exp_imm);
                    `check(branch, 1'b1);
                    `check(alu_src_a, 1'b1);    
                    `check(alu_src_b, 1'b1);
                    `check(alu_opcode, ADD);
                end

                OP_LUI: begin
                    exp_imm = {instruction[31:12], 12'b0};
                    `check(imm, exp_imm);
                    `check(alu_src_b, 1'b1);
                    `check(reg_write, 1'b1);
                    `check(alu_opcode, PASS_B);
                end

                OP_AUIPC: begin
                    exp_imm = {instruction[31:12], 12'b0};
                    `check(imm, exp_imm);
                    `check(alu_src_a, 1'b1);
                    `check(alu_src_b, 1'b1);
                    `check(reg_write, 1'b1);
                    `check(alu_opcode, ADD);
                end

                OP_JAL: begin
                    exp_imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                    `check(imm, exp_imm);
                    `check(reg_write, 1'b1);
                    `check(result_mux, 2'b10);
                    `check(jump, 1'b1);
                end

                OP_JALR: begin
                    exp_imm = {{20{instruction[31]}}, instruction[31:20]};
                    `check(imm, exp_imm);
                    `check(alu_src_a, 1'b0);
                    `check(alu_src_b, 1'b1);
                    `check(reg_write, 1'b1);
                    `check(result_mux, 2'b10);
                    `check(jump, 1'b1);
                    `check(alu_opcode, ADD);
                end

                default: begin
                    `check(imm, 32'b0);
                    `check(branch, 1'b0);
                    `check(reg_write, 1'b0);
                    `check(is_load, 1'b0);
                    `check(is_store, 1'b0);
                    `check(jump, 1'b0);
                end
            endcase
        end

        $display("SUCCESS: All decoder tests passed");
        $stop;
    end

endmodule