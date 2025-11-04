/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * top.sv - Top level module
 */

import types::u32_t;
import types::wrstb_t;

module top(
    input logic clk,
    input logic rst_n
);

    // DMEM signals
    u32_t   dmem_addr;
    u32_t   dmem_wrdata;
    wrstb_t dmem_wrstb;
    u32_t   dmem_rddata;

    // IMEM interface
    u32_t imem_addr;
    u32_t imem_data;

    dmem dmem0(
        .clk(clk),
        .rst_n(rst_n),
        .addr(dmem_addr),
        .wrdata(dmem_wrdata),
        .wrstb(dmem_wrstb),
        .rddata(dmem_rddata)
    );

    imem imem0(
        .rst_n(rst_n),
        .addr(imem_addr),
        .data(imem_data)
    );

    mina mina0(
        .clk(clk),
        .rst_n(rst_n),
        .dmem_addr(dmem_addr),
        .dmem_wrdata(dmem_wrdata),
        .dmem_wrstb(dmem_wrstb),
        .dmem_rddata(dmem_rddata),
        .imem_addr(imem_addr),
        .imem_data(imem_data)
    );

endmodule
