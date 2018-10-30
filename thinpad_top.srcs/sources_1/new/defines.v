//global
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define ZeroWord 32'h0
`define Enable 1'b1
`define Disable 1'b0

//instructions_top_six_bits
`define EXE_SPECIAL_INST  6'b000000
`define EXE_SPECIAL2_INST  6'b011100
`define EXE_ORI 6'b001101
`define EXE_ANDI 6'b001100
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111
`define EXE_ADDI 6'b001000
`define EXE_ADDIU 6'b001001
`define EXE_SLTI 6'b001010
`define EXE_SLTIU 6'b001011

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

`define EXE_ADD 6'b100000
`define EXE_ADDU 6'b100001
`define EXE_SUB 6'b100010
`define EXE_SUBU 6'b100011
`define EXE_SLT 6'b101010
`define EXE_SLTU 6'b101011

`define EXE_MULT 6'b011000// is special instruction
`define EXE_MULTU 6'b011001// is special instruction

`define EXE_DIV 6'b011010// is special instruction
`define EXE_DIVU 6'b011011// is special instruction

// following are special2 instruction
`define EXE_MUL 6'b000010 
`define EXE_CLZ 6'b100000
`define EXE_CLO 6'b100001

//AluOp
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

`define EXE_ADD_OP  6'b001110
`define EXE_ADDU_OP  6'b001111
`define EXE_SUB_OP  6'b010000
`define EXE_SUBU_OP  6'b010001
`define EXE_SLT_OP  6'b010010
`define EXE_SLTU_OP  6'b010011
`define EXE_MULT_OP  6'b010100
`define EXE_MULTU_OP  6'b010101

`define EXE_MUL_OP 6'b010110 
`define EXE_CLZ_OP 6'b010111
`define EXE_CLO_OP 6'b011000

`define EXE_DIV_OP 6'b011001
`define EXE_DIVU_OP 6'b011010

//AluSel
`define EXE_RES_LOGIC 3'b000
`define EXE_RES_SHIFT 3'b001
`define EXE_RES_MOVE 3'b010
`define EXE_RES_ARITHMETIC 3'b011 // excluding multiplication 
`define EXE_RES_MUL 3'b100

//instruction and address of instruction
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 31

//register value and address
`define RegBus 31:0
`define DoubleRegBus 63:0
`define RegAddrBus 4:0
`define StallBus 4:0

`define NOPRegAddr 5'b00000

//ALU instruction type and subtype
`define AluOpBus 5:0
`define AluSelBus 2:0

//CTRL and stall
`define Stall 1'b1
`define NotStall 1'b0
