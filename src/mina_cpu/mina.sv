/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mina.sv - CPU glue logic
 */

import types::u32_t;
import types::wrstb_t;

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

endmodule
