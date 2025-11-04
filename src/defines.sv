package types;

    // Common
    typedef logic[ 7:0] u8_t;
    typedef logic[31:0] u32_t;

    // Memory
    typedef logic[3:0] wrstb_t;

    // Pipeline
    typedef struct packed {
        u32_t ia_plus_4;
        u32_t ir;
    } if_params_t;

endpackage
