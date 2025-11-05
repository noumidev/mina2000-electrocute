/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/id_ex.sv - Intermediary ID/EX register
 */

import types::SEL_ZERO;
import types::ex_params_t;

module id_ex(
    input logic clk,
    input logic rst_n,

    // From ID
    input ex_params_t ex_params_in,

    // To EX
    output ex_params_t ex_params_out
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ex_params_out.ia_plus_4 <= '0;
            ex_params_out.a_sel     <= SEL_ZERO;
            ex_params_out.a_sel     <= SEL_ZERO;
            ex_params_out.ra_addr   <= '0;
            ex_params_out.ra_data   <= '0;
            ex_params_out.rb_addr   <= '0;
            ex_params_out.rb_data   <= '0;
            ex_params_out.rd_addr   <= '0;
            ex_params_out.imm       <= '0;
            ex_params_out.shift     <= '0;
        end else begin
            ex_params_out <= ex_params_in;
        end
    end

endmodule
