package definitions;

    parameter int BW = 32;
    parameter int DEPTH = 32;

    typedef enum logic [3:0] {
        ADD = 4'b0000,
        SUB = 4'b0001,
        SLL = 4'b0010,
        SLT = 4'b0100,
        SLTU = 4'b0110,
        XOR = 4'b1000,
        SRL = 4'b1010,
        SRA = 4'b1011,
        OR = 4'b1100,
        AND = 4'b1110,
        PASS_B = 4'b1111
    } opcode_t;

    typedef enum logic [6:0] {
        OP_R_TYPE = 7'b0110011,
        OP_I_TYPE = 7'b0010011,
        OP_LOAD = 7'b0000011,
        OP_STORE = 7'b0100011,
        OP_BRANCH = 7'b1100011,
        OP_LUI = 7'b0110111,
        OP_AUIPC = 7'b0010111,
        OP_JAL = 7'b1101111,
        OP_JALR = 7'b1100111,
        OP_SYSTEM = 7'b1110011,
        OP_FENCE = 7'b0001111
    } opcode_i_t;

    typedef enum logic [1:0] {
        FETCH = 2'b00,
        EXECUTE_1 = 2'b01,
        EXECUTE_2 = 2'b10
    } ctrl_state_t;

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        WAIT = 2'b01,
        READY = 2'b10
    } mem_state_t;

endpackage