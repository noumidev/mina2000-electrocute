/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mina.sv - CPU glue logic
 */

import types::u32_t;
import types::wrstb_t;
import types::if_params_t;

module mina(
    input logic clk,
    input logic rst_n,

    // DMEM interface
    output u32_t   dmem_addr,
    output u32_t   dmem_wrdata,
    output wrstb_t dmem_wrstb,
    input  u32_t   dmem_rddata,

    // IMEM interface
    output u32_t imem_addr,
    input  u32_t imem_data
);

    localparam INITIAL_IA = 32'b0;

    // --- Instruction address register ---
    u32_t ia;
    u32_t ia_plus_4;

    // TODO: handle branch logic

    always_ff @(posedge clk) begin
        if (!rst_n)
            ia <= INITIAL_IA;
        else
            ia <= ia_plus_4;
    end

    always_comb begin
        ia_plus_4 = ia + 32'd4;
    end

    // --- Instruction fetch ---
    if_params_t if_params_if;
    if_params_t if_params_id;

    assign imem_addr = ia;

    assign if_params_if.ia_plus_4 = ia_plus_4;
    assign if_params_if.ir        = imem_data;

    // --- IF/ID ---
    if_id if_id0(
        .clk(clk),
        .rst_n(rst_n),
        .if_params_in(if_params_if),
        .if_params_out(if_params_id)
    );

    // --- Instruction decode ---

    // --- Memory access ---
    // TODO
    assign dmem_addr   = '0;
    assign dmem_wrdata = '0;
    assign dmem_wrstb  = '0;

endmodule
