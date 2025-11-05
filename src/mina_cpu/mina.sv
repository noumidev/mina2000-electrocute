/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/mina.sv - CPU glue logic
 */

import types::u32_t;
import types::regaddr_t;
import types::wrstb_t;
import types::fw_sel_e;
import types::id_params_t;
import types::ex_params_t;
import types::mem_params_t;
import types::wb_params_t;

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
    input  u32_t imem_data,

    output u32_t wb_out
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
    id_params_t id_params_if;
    id_params_t id_params_id;

    assign imem_addr = ia;

    assign id_params_if.ia_plus_4 = ia_plus_4;
    assign id_params_if.ir        = imem_data;

    // --- IF/ID ---
    if_id if_id0(
        .clk(clk),
        .rst_n(rst_n),
        .id_params_in(id_params_if),
        .id_params_out(id_params_id)
    );

    // --- Instruction decode ---
    ex_params_t ex_params_id;
    ex_params_t ex_params_ex;

    regaddr_t rd_addr_wb;
    u32_t     rd_data_wb;

    id_stage id_stage0(
        .clk(clk),
        .rst_n(rst_n),
        .rd_addr(rd_addr_wb),
        .rd_data(rd_data_wb),
        .id_params(id_params_id),
        .ex_params(ex_params_id)
    );

    // --- ID/EX ---
    id_ex id_ex0(
        .clk(clk),
        .rst_n(rst_n),
        .ex_params_in(ex_params_id),
        .ex_params_out(ex_params_ex)
    );

    // --- Forwarding unit ---
    regaddr_t rd_addr_ex_mem;
    regaddr_t rd_addr_mem_wb;

    fw_sel_e ra_sel;
    fw_sel_e rb_sel;

    fw_unit fw_unit0(
        .ra_addr_id_ex(ex_params_ex.ra_addr),
        .rb_addr_id_ex(ex_params_ex.rb_addr),
        .rd_addr_ex_mem(rd_addr_ex_mem),
        .rd_addr_mem_wb(rd_addr_mem_wb),
        .ra_sel(ra_sel),
        .rb_sel(rb_sel)
    );

    // --- Execute stage ---
    mem_params_t mem_params_ex;
    mem_params_t mem_params_mem;

    u32_t rd_data_ex_mem;
    u32_t rd_data_mem_wb;

    ex_stage ex_stage0(
        .ex_params(ex_params_ex),
        .ra_sel(ra_sel),
        .rb_sel(rb_sel),
        .rd_data_ex_mem(rd_data_ex_mem),
        .rd_data_mem_wb(rd_data_mem_wb),
        .mem_params(mem_params_ex)
    );

    // --- EX/MEM ---
    ex_mem ex_mem0(
        .clk(clk),
        .rst_n(rst_n),
        .mem_params_in(mem_params_ex),
        .mem_params_out(mem_params_mem)
    );

    assign rd_addr_ex_mem = mem_params_mem.rd_addr;
    assign rd_data_ex_mem = mem_params_mem.rd_data;

    // --- Memory access ---
    wb_params_t wb_params_mem;
    wb_params_t wb_params_wb;

    mem_stage mem_stage0(
        .mem_params(mem_params_mem),
        .dmem_addr(dmem_addr),
        .dmem_wrdata(dmem_wrdata),
        .dmem_wrstb(dmem_wrstb),
        .dmem_rddata(dmem_rddata),
        .wb_params(wb_params_mem)
    );

    // --- MEM/WB ---
    mem_wb mem_wb0(
        .clk(clk),
        .rst_n(rst_n),
        .wb_params_in(wb_params_mem),
        .wb_params_out(wb_params_wb)
    );

    assign rd_addr_mem_wb = wb_params_wb.rd_addr;
    assign rd_data_mem_wb = wb_params_wb.rd_data;

    // --- Write-back ---
    assign rd_addr_wb = wb_params_wb.rd_addr;
    assign rd_data_wb = wb_params_wb.rd_data;

    assign wb_out = wb_params_wb.rd_data;

endmodule
