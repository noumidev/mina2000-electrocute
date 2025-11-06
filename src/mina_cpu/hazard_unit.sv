/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/hazard_unit.sv - Hazard detection unit
 */

import types::regaddr_t;
import types::mem_op_e;
import types::MEM_OP_LOAD;

module hazard_unit(
    // From ID
    input mem_op_e  mem_op,
    input regaddr_t ra_addr_id,
    input regaddr_t rb_addr_id,

    // From ID/EX
    input regaddr_t rd_addr_id_ex,

    // To multiple stages
    output logic load_hazard
);

    always_comb begin
        // If any of the source registers in ID reference a register that has yet to be read
        // from memory, we stall IA and IF/ID and insert a NOP into ID/EX

        load_hazard = (mem_op == MEM_OP_LOAD) && ((ra_addr_id == rd_addr_id_ex) || (rb_addr_id == rd_addr_id_ex));
    end

endmodule
