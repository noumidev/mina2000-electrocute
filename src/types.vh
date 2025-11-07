/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * defines.vh - Various definitions
 */

`ifndef TYPES_VH_
`define TYPES_VH_

package types;

    // Common
    typedef logic[ 7:0] u8_t;
    typedef logic[31:0] u32_t;
    typedef logic[ 3:0] led_t;

    // Registers
    typedef logic[4:0] regaddr_t;

    // Memory
    typedef logic[3:0] wrstb_t;

    // Immediate operations
    typedef logic[1:0] shift_t;

    // Operand selection
    typedef enum logic[1:0] {
        SEL_ZERO   = 2'b00,
        SEL_IA_IMM = 2'b01,
        SEL_REG    = 2'b10
    } sel_e;

    typedef enum logic[1:0] {
        FW_SEL_ID_EX  = 2'b00,
        FW_SEL_EX_MEM = 2'b01,
        FW_SEL_MEM_WB = 2'b10
    } fw_sel_e;

    // ALU operations
    typedef enum logic[3:0] {
        ALU_OP_ADD = 4'b0000,
        ALU_OP_SUB = 4'b0001,
        ALU_OP_AND = 4'b0100,
        ALU_OP_OR  = 4'b0101,
        ALU_OP_XOR = 4'b0110,
        ALU_OP_CEQ = 4'b1000,
        ALU_OP_CHS = 4'b1001,
        ALU_OP_CGE = 4'b1010
    } alu_op_e;

    typedef enum logic[1:0] {
        T_OP_AND = 2'b00,
        T_OP_OR  = 2'b01,
        T_OP_XOR = 2'b10,
        T_OP_SET = 2'b11
    } t_op_e;

    // Memory operations
    typedef enum logic[1:0] {
        MEM_OP_NONE  = 2'b00,
        MEM_OP_LOAD  = 2'b01,
        MEM_OP_STORE = 2'b10
    } mem_op_e;

    // Pipeline
    typedef struct packed {
        u32_t ia_plus_4;

        sel_e a_sel; // 0 -> 0, 1 ->  IA, 2 -> RA
        sel_e b_sel; // 0 -> 0, 1 -> IMM, 2 -> RB

        // Register addresses/operands
        regaddr_t ra_addr;
        u32_t     ra_data;
        regaddr_t rb_addr;
        u32_t     rb_data;
        regaddr_t rd_addr;

        u32_t   imm;
        shift_t shift;

        alu_op_e alu_op;
        logic    invert_b;
        t_op_e   t_op;
        logic    invert_t;

        logic branch;
        logic cond_branch;

        mem_op_e mem_op;
    } ex_params_t;

    typedef struct packed {
        regaddr_t rd_addr;
        u32_t     rd_data;

        mem_op_e mem_op;
        u32_t    mem_data;
    } mem_params_t;

    typedef struct packed {
        regaddr_t rd_addr;
        u32_t     rd_data;
    } wb_params_t;

endpackage

`endif
