/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mem_wb.sv - Intermediary MEM/WB register
 */

`include "types.vh"

import types::wb_params_t;

module mem_wb(
    input logic clk,
    input logic rst_n,

    // From MEM
    input wb_params_t wb_params_in,

    // To WB
    output wb_params_t wb_params_out
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wb_params_out.rd_addr <= '0;
            wb_params_out.rd_data <= '0;
        end else begin
            wb_params_out <= wb_params_in;
        end
    end

endmodule
