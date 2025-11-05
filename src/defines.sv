package types;

    // Common
    typedef logic[ 7:0] u8_t;
    typedef logic[31:0] u32_t;

    // Registers
    typedef logic[4:0] regaddr_t;

    // Memory
    typedef logic[3:0] wrstb_t;

    // Immediate operations
    typedef logic[1:0] shift_t;

    // Operand selection
    typedef enum logic[1:0] {
        SEL_ZERO   = 2'b00,
        SEL_IA_IMM = 2'b01,
        SEL_REG    = 2'b10
    } sel_t;

    // Pipeline
    typedef struct packed {
        u32_t ia_plus_4;
        u32_t ir;
    } id_params_t;

    typedef struct packed {
        u32_t ia_plus_4;

        sel_t a_sel; // 0 -> 0, 1 ->  IA, 2 -> RA
        sel_t b_sel; // 0 -> 0, 1 -> IMM, 2 -> RB

        // Register addresses/operands
        regaddr_t ra_addr;
        u32_t     ra_data;
        regaddr_t rb_addr;
        u32_t     rb_data;
        regaddr_t rd_addr;

        u32_t   imm;
        shift_t shift;
    } ex_params_t;

endpackage
