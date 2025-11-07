/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/if_id.sv - Intermediary IF/ID register
 */

`include "types.vh"

import types::u32_t;

module if_id(
    input logic clk,
    input logic rst_n,

    // From IF
    input u32_t ia_plus_4_in,

    // To ID
    output u32_t ia_plus_4_out,

    // From EX
    input logic valid,

    // From hazard unit
    input logic stall
);

    always_ff @(posedge clk) begin
        if (!rst_n || !valid) begin
            ia_plus_4_out <= '0;
        end else if (!stall)
            ia_plus_4_out <= ia_plus_4_in;
    end

endmodule
