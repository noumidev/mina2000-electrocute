/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/ex_stage.sv - Execute/address calculation stage
 */

`include "types.vh"

import types::u32_t;
import types::SEL_IA_IMM;
import types::SEL_REG;
import types::fw_sel_e;
import types::FW_SEL_EX_MEM;
import types::FW_SEL_MEM_WB;
import types::ALU_OP_ADD;
import types::ALU_OP_SUB;
import types::ALU_OP_AND;
import types::ALU_OP_OR;
import types::ALU_OP_XOR;
import types::ALU_OP_CEQ;
import types::ALU_OP_CHS;
import types::ALU_OP_CGE;
import types::T_OP_AND;
import types::T_OP_OR;
import types::T_OP_XOR;
import types::T_OP_SET;
import types::MEM_OP_NONE;
import types::MEM_OP_STORE;
import types::ex_params_t;
import types::mem_params_t;

module ex_stage(
    // From ID/EX
    input ex_params_t ex_params,

    // From FW unit
    input fw_sel_e ra_sel,
    input fw_sel_e rb_sel,

    // From EX/MEM
    input u32_t rd_data_ex_mem,
    input logic t_in,

    // From MEM/WB
    input u32_t rd_data_mem_wb,

    // To EX/MEM
    output mem_params_t mem_params,
    output logic        t_out,

    // To IF/ID
    output logic branch_req,

    // To IA
    output u32_t branch_ia
);

    u32_t op_a;
    u32_t op_b;
    u32_t rb_data;

    u32_t result;

    logic t_cmp;

    always_comb begin
        op_a = '0;
        op_b = '0;

        result = '0;
        t_cmp  = '0;
        t_out  = t_in;
    
        // Select operand A
        if (ex_params.a_sel == SEL_IA_IMM)
            op_a = ex_params.ia_plus_4;
        else if (ex_params.a_sel == SEL_REG) begin
            op_a = ex_params.ra_data;

            if (ra_sel == FW_SEL_MEM_WB)
                op_a = rd_data_mem_wb;
            else if (ra_sel == FW_SEL_EX_MEM)
                op_a = rd_data_ex_mem;
        end

        rb_data = ex_params.rb_data;

        if (rb_sel == FW_SEL_MEM_WB)
            rb_data = rd_data_mem_wb;
        else if (rb_sel == FW_SEL_EX_MEM)
            rb_data = rd_data_ex_mem;

        // Select operand B
        if (ex_params.b_sel == SEL_IA_IMM)
            op_b = ex_params.imm << ex_params.shift;
        else if (ex_params.b_sel == SEL_REG) begin
            op_b = rb_data;
        end

        if (ex_params.invert_b)
            op_b = ~op_b;

        unique0 case(ex_params.alu_op) inside
            ALU_OP_ADD: result = op_a + op_b;
            ALU_OP_SUB: result = op_a - op_b;
            ALU_OP_AND: result = op_a & op_b;
            ALU_OP_OR:  result = op_a | op_b;
            ALU_OP_XOR: result = op_a ^ op_b;
            ALU_OP_CEQ, ALU_OP_CGE, ALU_OP_CHS: begin
                if (ex_params.alu_op == ALU_OP_CEQ)
                    t_cmp = op_a == op_b;
                else if (ex_params.alu_op == ALU_OP_CHS)
                    t_cmp = op_a >= op_b;
                else
                    t_cmp = $signed(op_a) >= $signed(op_b);
                
                if (ex_params.invert_t)
                    t_cmp = !t_cmp;
                
                unique case(ex_params.t_op) inside
                    T_OP_AND: t_out = t_cmp & t_in;
                    T_OP_OR:  t_out = t_cmp | t_in;
                    T_OP_XOR: t_out = t_cmp ^ t_in;
                    T_OP_SET: t_out = t_cmp;
                endcase
            end
        endcase

        branch_req = '0;
        branch_ia  = '0;

        mem_params.rd_addr  = ex_params.rd_addr;
        mem_params.mem_op   = ex_params.mem_op;
        mem_params.mem_data = ex_params.mem_op == MEM_OP_STORE ? rb_data : '0;

        if (ex_params.branch) begin
            branch_req = !ex_params.cond_branch || (t_in ^ ex_params.invert_t);
            branch_ia  = result;

            mem_params.rd_data = ex_params.ia_plus_4;
        end else begin
            mem_params.rd_data = result;
        end
    end

endmodule
