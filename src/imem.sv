/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * imem.sv - Instruction memory
 */

import types::u32_t;

module imem(
    input logic rst_n,

    input  u32_t addr,
    output u32_t data
);

    // Same size as DMEM
    localparam SIZE = 1024 / 4;

    u32_t mem[0:SIZE - 1];

    initial mem = '{SIZE{32'b0}};

    // Reads
    always_comb begin
        if (!rst_n)
            data = '0;
        else
            data = mem[addr[9:2]];
    end

endmodule
