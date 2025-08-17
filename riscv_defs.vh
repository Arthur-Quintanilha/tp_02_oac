// Common defines for the simple RISC-V (RV32I subset) single-cycle CPU
`define OPC_RTYPE  7'b0110011
`define OPC_ITYPE  7'b0010011
`define OPC_LOAD   7'b0000011
`define OPC_STORE  7'b0100011
`define OPC_BRANCH 7'b1100011

// funct3
`define F3_ADD_SUB 3'b000
`define F3_SLL     3'b001
`define F3_OR      3'b110
`define F3_ANDI    3'b111
`define F3_LH      3'b001
`define F3_SH      3'b001
`define F3_BNE     3'b001

// funct7
`define F7_ADD_SRL_SLL 7'b0000000
`define F7_SUB_SRA     7'b0100000
