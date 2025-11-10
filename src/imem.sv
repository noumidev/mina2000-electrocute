/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * imem.sv - Instruction memory
 */

`include "types.vh"

import types::u32_t;

module imem(
    input logic clk,

    input  u32_t addr,
    output u32_t data
);

    // Same size as DMEM
    localparam SIZE = 1024 / 4;

    u32_t mem[0:SIZE - 1];

    initial begin
        mem = '{SIZE{32'b0}};

        $readmemh("imem.init", mem);
    end

    // Reads
    always @(posedge clk) begin
        data <= mem[addr[9:2]];
    end

endmodule
