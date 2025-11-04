/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * dmem.sv - Data memory
 */

import types::u8_t;
import types::u32_t;
import types::wrstb_t;

module dmem(
    input logic clk,
    input logic rst_n,

    input  u32_t   addr,
    input  u32_t   wrdata,
    input  wrstb_t wrstb,
    output u32_t   rddata
);

    localparam SIZE = 1024;

    u8_t mem[0:SIZE - 1];

    initial mem = '{SIZE{8'b0}};

    // Writes
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Do nothing
        end else begin
            if (wrstb[0])
                mem[{addr[9:2], 2'b00}] <= wrdata[7:0];

            if (wrstb[1])
                mem[{addr[9:2], 2'b01}] <= wrdata[15:8];

            if (wrstb[2])
                mem[{addr[9:2], 2'b10}] <= wrdata[23:16];

            if (wrstb[3])
                mem[{addr[9:2], 2'b11}] <= wrdata[31:24];
        end
    end

    // Reads
    always_comb begin
        if (!rst_n)
            rddata = '0;
        else
            rddata = mem[{addr[9:2], 2'b00}];
    end

endmodule