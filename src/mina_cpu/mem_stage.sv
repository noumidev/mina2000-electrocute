/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mem_stage.sv - Memory stage
 */

import types::u32_t;
import types::wrstb_t;
import types::mem_params_t;
import types::wb_params_t;
import types::MEM_OP_LOAD;
import types::MEM_OP_STORE;

module mem_stage(
    // From EX/MEM
    input mem_params_t mem_params,

    // To/from DMEM
    output u32_t   dmem_addr,
    output u32_t   dmem_wrdata,
    output wrstb_t dmem_wrstb,
    input  u32_t   dmem_rddata,

    // To MEM/WB
    output wb_params_t wb_params
);

    always_comb begin
        dmem_addr   = mem_params.rd_data;
        dmem_wrdata = mem_params.mem_data;
        dmem_wrstb  = '0;

        wb_params.rd_addr = mem_params.rd_addr;
        wb_params.rd_data = mem_params.rd_data;

        if (mem_params.mem_op == MEM_OP_LOAD) begin
            wb_params.rd_addr = mem_params.rd_addr;
            wb_params.rd_data = dmem_rddata;
        end else if (mem_params.mem_op == MEM_OP_STORE) begin
            // TODO: support non-word writes
            dmem_wrstb = 4'b1111;

            wb_params.rd_addr = '0;
            wb_params.rd_data = '0;
        end
    end

endmodule
