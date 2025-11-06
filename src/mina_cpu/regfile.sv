/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/regfile.sv - Register file
 */

`include "types.vh"

import types::u32_t;
import types::regaddr_t;

module regfile(
    input logic clk,
    input logic rst_n,

    // RA/RS (read port)
    input  regaddr_t ra_addr,
    output u32_t     ra_data,

    // RB (read port)
    input  regaddr_t rb_addr,
    output u32_t     rb_data,

    // RD (write port)
    input regaddr_t rd_addr,
    input u32_t     rd_data
);

    localparam NUM = 32;

    u32_t regs[0:NUM - 1];

    initial regs = '{NUM{32'b0}};

    // Writes
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Do nothing
        end else begin
            if (rd_addr != '0)
                regs[rd_addr] <= rd_data;
        end
    end

    // Reads
    always_comb begin
        ra_data = regs[ra_addr];
        rb_data = regs[rb_addr];
    end

endmodule
