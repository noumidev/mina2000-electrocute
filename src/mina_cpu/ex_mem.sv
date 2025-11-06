/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/ex_mem.sv - Intermediary EX/MEM register
 */

import types::MEM_OP_NONE;
import types::mem_params_t;

module ex_mem(
    input logic clk,
    input logic rst_n,

    // From EX
    input mem_params_t mem_params_in,
    input logic        t_in,

    // To MEM
    output mem_params_t mem_params_out,

    // To EX
    output logic t_out
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mem_params_out.rd_addr <= '0;
            mem_params_out.rd_data <= '0;

            mem_params_out.mem_op   <= MEM_OP_NONE;
            mem_params_out.mem_data <= '0;

            t_out <= 0;
        end else begin
            mem_params_out <= mem_params_in;

            t_out <= t_in;
        end
    end

endmodule
