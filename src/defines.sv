package types;

    // Common
    typedef logic[ 7:0] u8_t;
    typedef logic[31:0] u32_t;

    // Registers
    typedef logic[4:0] regaddr_t;

    // Memory
    typedef logic[3:0] wrstb_t;

    // Pipeline
    typedef struct packed {
        u32_t ia_plus_4;
        u32_t ir;
    } id_params_t;

    typedef struct packed {
        u32_t     op_a;
        u32_t     op_b;
        regaddr_t rd_addr;
    } ex_params_t;

endpackage
