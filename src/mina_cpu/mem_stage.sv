/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mem_stage.sv - Memory stage
 */

`include "types.vh"

import types::u32_t;
import types::wrstb_t;
import types::mem_params_t;
import types::wb_params_t;
import types::MEM_OP_LOAD;
import types::MEM_OP_STORE;

module mem_stage(
    // From EX/MEM
    input mem_params_t mem_params,

    // To MEM/WB
    output wb_params_t wb_params
);

    always_comb begin
        wb_params.rd_addr = mem_params.rd_addr;
        wb_params.rd_data = mem_params.rd_data;
        wb_params.mem_op  = mem_params.mem_op;
    end

endmodule
