/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/ex_stage.sv - Execute/address calculation stage
 */

import types::u32_t;
import types::SEL_IA_IMM;
import types::SEL_REG;
import types::fw_sel_t;
import types::FW_SEL_EX_MEM;
import types::FW_SEL_MEM_WB;
import types::MEM_OP_NONE;
import types::ex_params_t;
import types::mem_params_t;

module ex_stage(
    // From ID/EX
    input ex_params_t ex_params,

    // From FW unit
    input fw_sel_t ra_sel,
    input fw_sel_t rb_sel,

    // From EX/MEM
    input u32_t rd_data_ex_mem,

    // From MEM/WB
    input u32_t rd_data_mem_wb,

    // To EX/MEM
    output mem_params_t mem_params
);

    u32_t op_a;
    u32_t op_b;

    always_comb begin
        op_a = '0;
        op_b = '0;
    
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

        // Select operand B
        if (ex_params.b_sel == SEL_IA_IMM)
            op_b = ex_params.ia_plus_4;
        else if (ex_params.b_sel == SEL_REG) begin
            op_b = ex_params.rb_data;

            if (rb_sel == FW_SEL_MEM_WB)
                op_b = rd_data_mem_wb;
            else if (rb_sel == FW_SEL_EX_MEM)
                op_b = rd_data_ex_mem;
        end

        // TODO: perform ALU operation

        mem_params.rd_addr = ex_params.rd_addr;
        mem_params.rd_data = '0;

        mem_params.mem_op   = MEM_OP_NONE;
        mem_params.mem_data = '0;
    end

endmodule
