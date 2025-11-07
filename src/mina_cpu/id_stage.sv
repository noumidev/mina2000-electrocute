/*
 * MINA2000 "ElectroCute" is the MINAv2 reference implementation.
 * Copyright (C) 2025  noumidev
 */

/*
 * mina_cpu/id_stage.sv - Instruction Decode stage
 */

`include "types.vh"

import types::u32_t;
import types::regaddr_t;
import types::shift_t;
import types::sel_e;
import types::SEL_ZERO;
import types::SEL_IA_IMM;
import types::SEL_REG;
import types::ALU_OP_ADD;
import types::ALU_OP_SUB;
import types::ALU_OP_AND;
import types::ALU_OP_OR;
import types::ALU_OP_XOR;
import types::ALU_OP_CEQ;
import types::ALU_OP_CHS;
import types::ALU_OP_CGE;
import types::t_op_e;
import types::MEM_OP_NONE;
import types::MEM_OP_LOAD;
import types::MEM_OP_STORE;
import types::ex_params_t;

module id_stage(
    // Only for register file
    input logic clk,
    input logic rst_n,

    // From IF/ID /IMEM
    input u32_t ia_plus_4,
    input u32_t ir,

    // From WB
    input regaddr_t rd_addr,
    input u32_t     rd_data,

    // To ID/EX
    output ex_params_t ex_params,

    // From hazard unit
    input logic valid
);

    typedef logic[6:0] opcode_t;
    typedef logic[2:0] secopc_t;

    typedef enum logic[6:0] {
        OPC_ARITH = 7'b?000000,
        OPC_LOGIC = 7'b?000001,
        OPC_CMP   = 7'b?0001??,
        OPC_MEM   = 7'b100100?,
        OPC_LOAD  = 7'b1001000,
        OPC_STORE = 7'b1001001,
        OPC_MOVH  = 7'b1110110,
        OPC_ADR   = 7'b1110111,
        OPC_BRA   = 7'b1111???
    } opcode_e;

    typedef enum logic[2:0] {
        ARITH_ADD = 3'b000,
        ARITH_SUB = 3'b100
    } arith_e;

    typedef enum logic[2:0] {
        LOGIC_AND  = 3'b00?,
        LOGIC_OR   = 3'b01?,
        LOGIC_XOR  = 3'b10?
    } logic_e;

    typedef enum logic[2:0] {
        CMP_EQ = 3'b00?,
        CMP_HS = 3'b01?,
        CMP_GE = 3'b10?
    } cmp_e;

    typedef enum logic[2:0] {
        MEM_B = 3'b00?,
        MEM_H = 3'b01?,
        MEM_W = 3'b10?
    } mem_e;

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

    u32_t ir_or_0;

    opcode_t opcode;
    secopc_t secopc;

    always_comb begin
        if (valid)
            ir_or_0 = ir;
        else
            ir_or_0 = '0;

        opcode = ir_or_0[ 6: 0];
        secopc = ir_or_0[19:17];

        ex_params.ia_plus_4 = ia_plus_4;
        ex_params.ra_addr   = ir_or_0[16:12];
        ex_params.rb_addr   = (opcode == OPC_STORE) ? ir_or_0[11:7] : ir_or_0[31:27];
        ex_params.rd_addr   = (opcode != OPC_STORE) ? ir_or_0[11:7] : '0;

        ex_params.imm   = {20'b0, ir_or_0[31:20]};
        ex_params.shift = opcode[6:1] == OPC_MEM[6:1] ? shift_t'(secopc[2:1]) : '0;
        
        ex_params.branch      = '0;
        ex_params.cond_branch = '0;

        ex_params.mem_op = MEM_OP_NONE;

        if (opcode == OPC_LOAD)
            ex_params.mem_op = MEM_OP_LOAD;
        else if (opcode == OPC_STORE)
            ex_params.mem_op = MEM_OP_STORE;

        // Decode operands
        unique case(opcode) inside
            7'b0??????: begin
                // R-type
                ex_params.a_sel = SEL_REG;
                ex_params.b_sel = SEL_REG;
            end
            OPC_MOVH, OPC_ADR: begin
                // U-type
                // opcode[0] -> MOVH, opcode[1] -> ADR
                ex_params.a_sel = opcode[0] ? SEL_IA_IMM : SEL_ZERO;
                ex_params.b_sel = SEL_IA_IMM;

                ex_params.imm = {ir_or_0[31:12], 12'b0};
            end
            OPC_BRA: begin
                // D-type
                ex_params.a_sel = SEL_IA_IMM;
                ex_params.b_sel = SEL_IA_IMM;

                // opcode[0] = 0 -> BRA, opcode[0] = 1 -> CALL
                ex_params.rd_addr = opcode[0] ? 5'd31 : '0;

                ex_params.imm = {{5{ir_or_0[31]}}, ir_or_0[31:7], 2'b0};
            end
            default: begin
                // I-type
                ex_params.a_sel = SEL_REG;
                ex_params.b_sel = SEL_IA_IMM;

                // Sign extension for compares and loadstores
                if ((opcode[5:2] == OPC_CMP[5:2]) || (opcode[6:1] == OPC_MEM[6:1]))
                    ex_params.imm[31:12] = {20{ir_or_0[31]}};
            end
        endcase

        ex_params.alu_op   = ALU_OP_ADD;
        ex_params.invert_b = '0;
        ex_params.t_op     = T_OP_SET;
        ex_params.invert_t = '0;

        // Decode operation
        unique0 case(opcode) inside
            OPC_ARITH: begin
                unique0 case(secopc) inside
                    ARITH_SUB: ex_params.alu_op = ALU_OP_SUB;
                    default:   begin end
                endcase
            end
            OPC_LOGIC: begin
                unique0 case(secopc) inside
                    LOGIC_AND: ex_params.alu_op = ALU_OP_AND;
                    LOGIC_OR:  ex_params.alu_op = ALU_OP_OR;
                    LOGIC_XOR: ex_params.alu_op = ALU_OP_XOR;
                    default:   begin end
                endcase

                ex_params.invert_b = secopc[0];
            end
            OPC_CMP: begin
                unique0 case(secopc) inside
                    CMP_EQ:  ex_params.alu_op = ALU_OP_CEQ;
                    CMP_HS:  ex_params.alu_op = ALU_OP_CHS;
                    CMP_GE:  ex_params.alu_op = ALU_OP_CGE;
                    default: begin end
                endcase

                ex_params.t_op     = t_op_e'(opcode[1:0]);
                ex_params.invert_t = secopc[0];
            end
            OPC_BRA: begin
                ex_params.branch      = '1;
                ex_params.cond_branch = opcode[1];
                ex_params.invert_t    = opcode[2];
            end
            default: begin end
        endcase
    end

endmodule
