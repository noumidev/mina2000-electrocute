/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/id_stage.sv - Instruction Decode stage
 */

import types::u32_t;
import types::regaddr_t;
import types::sel_e;
import types::SEL_ZERO;
import types::SEL_IA_IMM;
import types::SEL_REG;
import types::ALU_OP_ADD;
import types::ALU_OP_SUB;
import types::ALU_OP_AND;
import types::ALU_OP_OR;
import types::ALU_OP_XOR;
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

    enum logic[6:0] {
        OPC_ARITH = 7'bx000000,
        OPC_LOGIC = 7'bx000001,
        OPC_MOVH  = 7'b1111100,
        OPC_ADR   = 7'b1111101
    } opcode_e;

    enum logic[9:0] {
        ARITH_ADD = 10'b000,
        ARITH_SUB = 10'b100
    } arith_e;

    enum logic[9:0] {
        LOGIC_AND  = 10'b00x,
        LOGIC_OR   = 10'b01x,
        LOGIC_XOR  = 10'b10x
    } logic_e;

    regfile regfile0(
        .clk(clk),
        .rst_n(rst_n),
        .ra_addr(ex_params.ra_addr),
        .ra_data(ex_params.ra_data),
        .rb_addr(ex_params.rb_addr),
        .rb_data(ex_params.rb_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    opcode_t opcode;
    secopc_t secopc;

    assign opcode = id_params.ir[ 6: 0];
    assign secopc = id_params.ir[26:17];

    always_comb begin
        // TODO: get source from RD for stores
        ex_params.ia_plus_4 = id_params.ia_plus_4;
        ex_params.ra_addr   = id_params.ir[16:12];
        ex_params.rb_addr   = id_params.ir[31:27];
        ex_params.rd_addr   = id_params.ir[11: 7];

        ex_params.imm   = '0;
        ex_params.shift = '0;

        // Decode operands
        unique case(opcode) inside
            7'b0xxxxxx: begin
                // R-type
                ex_params.a_sel = SEL_REG;
                ex_params.b_sel = SEL_REG;
            end
            7'b111110x: begin
                // U-type
                // opcode[0] -> MOVH, opcode[1] -> ADR
                ex_params.a_sel = opcode[0] ? SEL_IA_IMM : SEL_ZERO;
                ex_params.b_sel = SEL_IA_IMM;

                ex_params.imm = {id_params.ir[31:12], 12'b0};
            end
            7'b111111x: begin
                // D-type
                ex_params.a_sel = SEL_IA_IMM;
                ex_params.b_sel = SEL_ZERO;

                // opcode[0] -> BRA, opcode[1] -> CALL
                ex_params.rd_addr = opcode[0] ? 5'd31 : '0;

                // Special case: branch logic is handled in ID
            end
            default: begin
                // I-type
                ex_params.a_sel = SEL_REG;
                ex_params.b_sel = SEL_IA_IMM;

                // TODO: sign extension for some opcodes
                ex_params.imm = {20'b0, id_params.ir[31:20]};

                // TODO: shifts for loadstores
            end
        endcase

        ex_params.alu_op   = ALU_OP_ADD;
        ex_params.invert_b = '0;

        // Decode operation
        unique0 case(opcode) inside
            OPC_ARITH: begin
                unique0 case(secopc) inside
                    ARITH_SUB: ex_params.alu_op = ALU_OP_SUB;
                endcase
            end
            OPC_LOGIC: begin
                unique0 case(secopc) inside
                    LOGIC_AND: ex_params.alu_op = ALU_OP_AND;
                    LOGIC_OR:  ex_params.alu_op = ALU_OP_OR;
                    LOGIC_XOR: ex_params.alu_op = ALU_OP_XOR;
                endcase

                ex_params.invert_b = opcode[0];
            end
        endcase
    end

endmodule
