/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/ex_mem.sv - Intermediary EX/MEM register
 */

`include "types.vh"

import types::u32_t;
import types::wrstb_t;
import types::MEM_OP_NONE;
import types::MEM_OP_LOAD;
import types::MEM_OP_STORE;
import types::mem_params_t;

module ex_mem(
    input logic clk,
    input logic rst_n,

    // From EX
    input mem_params_t mem_params_in,
    input logic        t_in,

    // To MEM
    output mem_params_t mem_params_out,

    // To DMEM
    output u32_t   dmem_addr,
    output u32_t   dmem_wrdata,
    output wrstb_t dmem_wrstb,

    // To EX
    output logic t_out
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mem_params_out.rd_addr <= '0;
            mem_params_out.rd_data <= '0;

            mem_params_out.mem_op   <= MEM_OP_NONE;
            mem_params_out.mem_data <= '0;

            dmem_addr   <= '0;
            dmem_wrdata <= '0;
            dmem_wrstb  <= '0;

            t_out <= 0;
        end else begin
            mem_params_out <= mem_params_in;

            // Launch memory operation
            if (mem_params_in.mem_op != MEM_OP_NONE) begin
                dmem_addr   <= mem_params_in.rd_data;
                dmem_wrdata <= mem_params_in.mem_op == MEM_OP_LOAD ? '0 : mem_params_in.mem_data;
                dmem_wrstb  <= mem_params_in.mem_op == MEM_OP_LOAD ? '0 : '1;
            end else begin
                dmem_addr   <= '0;
                dmem_wrdata <= '0;
                dmem_wrstb  <= '0;
            end

            t_out <= t_in;
        end
    end

endmodule
