/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * top.sv - Top level module
 */

`include "types.vh"

import types::u8_t;
import types::u32_t;
import types::led_t;
import types::wrstb_t;

module top(
    input logic clk,
    input logic rst_n,
    
    output led_t leds
);

    localparam CLOCK_FREQUENCY = 27_000_000;

    // Debug
    led_t dmem_leds;

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
        .rddata(dmem_rddata),
        .leds(dmem_leds)
    );

    imem imem0(
        .clk(clk),
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

    // Debug
    u32_t counter;

    always_ff @(posedge clk) begin
        if (!rst_n)
            counter <= CLOCK_FREQUENCY / 2;
        else begin
            if (counter == 0) begin
                leds    <= ~dmem_leds;
                counter <= CLOCK_FREQUENCY / 2;
            end else
                counter <= counter - 32'b1;
        end
    end

endmodule
