/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/if_id.sv - Intermediary IF/ID register
 */

import types::if_params_t;

module if_id(
    input logic clk,
    input logic rst_n,

    // From IF
    input if_params_t if_params_in,

    // To ID
    output if_params_t if_params_out
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if_params_out.ia_plus_4 <= '0;
            if_params_out.ir        <= '0;
        end else begin
            if_params_out <= if_params_in;
        end
    end

endmodule
