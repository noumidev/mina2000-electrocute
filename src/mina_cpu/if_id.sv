/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/if_id.sv - Intermediary IF/ID register
 */

import types::id_params_t;

module if_id(
    input logic clk,
    input logic rst_n,

    // From IF
    input id_params_t id_params_in,

    // To ID
    output id_params_t id_params_out,

    // From EX
    input logic valid
);

    always_ff @(posedge clk) begin
        if (!rst_n || !valid) begin
            id_params_out.ia_plus_4 <= '0;
            id_params_out.ir        <= '0;
        end else begin
            id_params_out <= id_params_in;
        end
    end

endmodule
