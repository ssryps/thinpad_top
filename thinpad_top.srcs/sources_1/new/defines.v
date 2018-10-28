//global
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define ZeroWord 32'h0
`define Enable 1'b1
`define Disable 0'b1
`define 

//instructions_top_six_bits
`define EXE_SPECIAL_INST  6'b000000
`define EXE_ORI 6'b001101
`define EXE_ANDI 6'b001100
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

//instructions_lowest_six_bits
`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111

`define EXE_SLL 6'b000000
`define EXE_SRL 6'b000010
`define EXE_SRA 6'b000011
`define EXE_SLLV 6'b000100
`define EXE_SRLV 6'b000110
`define EXE_SRAV 6'b000111

`define EXE_MOVN 6'b001011
`define EXE_MOVZ 6'b001010
`define EXE_MFHI 6'b010000
`define EXE_MTHI  6'b010001
`define EXE_MFLO  6'b010010
`define EXE_MTLO  6'b010011

//AluOp
`define EXE_SLL_OP 6'b000000
`define EXE_OR_OP 6'b000010
`define EXE_AND_OP 6'b000011
`define EXE_XOR_OP 6'b000100
`define EXE_NOR_OP 6'b000101

`define EXE_SLL_OP 6'b000110
`define EXE_SRL_OP 6'b000111
`define EXE_SRA_OP 6'b001000

`define EXE_MOVN_OP  6'b001001
`define EXE_MOVZ_OP  6'b001010
`define EXE_MFHI_OP  6'b001011
`define EXE_MTHI_OP  6'b001100
`define EXE_MFLO_OP  6'b001101
`define EXE_MTLO_OP  6'b001110


//AluSel
`define EXE_RES_LOGIC 3'b000
`define EXE_RES_SHIFT 3'b001
`define EXE_RES_MOVE 3'b010

//instruction and address of instruction
`define InstAddrBus 31:0
`define InstBus 31:0

//register value and address
`define RegBus 31:0
`define RegAddrBus 4:0

`define NOPRegAddr 5'b00000

//ALU instruction type and subtype
`define AluOpBus 5:0
`define AluSelBus 2:0

