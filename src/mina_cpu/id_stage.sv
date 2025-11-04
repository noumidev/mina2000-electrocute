/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/id_stage.sv - Instruction Decode stage
 */

import types::u32_t;
import types::regaddr_t;
import types::id_params_t;
import types::ex_params_t;

module id_stage(
    // Only for register file
    input logic clk,
    input logic rst_n,

    // From IF/ID
    input id_params_t id_params,

    // From WB
    input regaddr_t rd_addr,
    input u32_t     rd_data,

    // To ID/EX
    output ex_params_t ex_params
);

    typedef logic[6:0] opcode_t;
    typedef logic[9:0] secopc_t;

    typedef logic[11:0] imm_t;
    typedef logic[19:0] uimm_t;
    typedef logic[24:0] disp_t;

    typedef struct packed {
        opcode_t opcode;
        secopc_t secopc;

        imm_t  imm;
        uimm_t uimm;
        disp_t disp;

        regaddr_t rd_addr;
        regaddr_t ra_addr;
        regaddr_t rb_addr;
    } instr_t;

    instr_t instr;

    // ID <-> regfile
    regaddr_t ra_addr;
    regaddr_t rb_addr;
    u32_t     ra_data;
    u32_t     rb_data;

    regfile regfile0(
        .clk(clk),
        .rst_n(rst_n),
        .ra_addr(ra_addr),
        .ra_data(ra_data),
        .rb_addr(rb_addr),
        .rb_data(rb_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    always_comb begin
        // Decode instruction fields
        instr.opcode  = id_params.ir[ 6: 0];
        instr.secopc  = id_params.ir[26:17];
        instr.imm     = id_params.ir[31:20];
        instr.uimm    = id_params.ir[31:12];
        instr.disp    = id_params.ir[31: 7];
        instr.ra_addr = id_params.ir[16:12];
        instr.rb_addr = id_params.ir[31:27];
        instr.rd_addr = id_params.ir[11: 7];

        // Decode operands
        unique case(instr.opcode) inside
            7'b0xxxxxx: begin
                // R-type
                ra_addr = instr.ra_addr;
                rb_addr = instr.rb_addr;

                ex_params.op_a    = ra_data;
                ex_params.op_b    = rb_data;
                ex_params.rd_addr = instr.rd_addr;
            end
            7'b111110x: begin
                // U-type
                ra_addr = '0;
                rb_addr = '0;

                if (instr.opcode[0]) begin
                    // ADR
                    ex_params.op_a = id_params.ia_plus_4;
                end else begin
                    // MOVH
                    ex_params.op_a = '0;
                end
                
                ex_params.op_b    = {instr.uimm, 12'b0};
                ex_params.rd_addr = instr.rd_addr;
            end
            7'b111111x: begin
                // D-type
                ra_addr = '0;
                rb_addr = '0;

                ex_params.op_a = '0;
                ex_params.op_b = id_params.ia_plus_4;

                if (instr.opcode[0]) begin
                    // CALL
                    ex_params.rd_addr = 5'd31;
                end else begin
                    ex_params.rd_addr = '0;
                end
            end
            default: begin
                // I-type
                ra_addr = instr.ra_addr;
                rb_addr = '0;

                ex_params.op_a    = ra_data;
                ex_params.op_b    = {20'b0, instr.imm};
                ex_params.rd_addr = instr.rd_addr;
            end
        endcase
    end

endmodule
