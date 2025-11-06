/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/fw_unit.sv - Forwarding unit
 */

import types::u32_t;
import types::regaddr_t;
import types::fw_sel_e;
import types::FW_SEL_ID_EX;
import types::FW_SEL_EX_MEM;
import types::FW_SEL_MEM_WB;

module fw_unit(
    // From ID/EX
    input regaddr_t ra_addr_id_ex,
    input regaddr_t rb_addr_id_ex,

    // From EX/MEM
    input regaddr_t rd_addr_ex_mem,

    // From MEM/WB
    input regaddr_t rd_addr_mem_wb,

    // To EX
    output fw_sel_e ra_sel,
    output fw_sel_e rb_sel
);

    always_comb begin
        ra_sel = FW_SEL_ID_EX;
        rb_sel = FW_SEL_ID_EX;

        // If any of the source registers in ID/EX reference a register that hasn't made it to WB yet,
        // we forward the values from EX/MEM or MEM/WB to it. The value in EX/MEM is more recent,
        // so we check it first

        if (rd_addr_ex_mem == ra_addr_id_ex)
            ra_sel = FW_SEL_EX_MEM;
        else if (rd_addr_mem_wb == ra_addr_id_ex)
            ra_sel = FW_SEL_MEM_WB;

        if (rd_addr_ex_mem == rb_addr_id_ex)
            rb_sel = FW_SEL_EX_MEM;
        else if (rd_addr_mem_wb == rb_addr_id_ex)
            rb_sel = FW_SEL_MEM_WB;
    end

endmodule
