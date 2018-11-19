//global
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define ZeroWord 32'h0
`define DoubleZeroWord 64'h0
`define Enable 1'b1
`define Disable 1'b0

//instructions_top_six_bits
`define EXE_SPECIAL_INST  6'b000000
`define EXE_SPECIAL2_INST  6'b011100
`define EXE_EXCEPTION_INST 6'b010000
`define EXE_REGIMM_INST 6'b000001
`define EXE_ORI 6'b001101
`define EXE_ANDI 6'b001100
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111
`define EXE_ADDI 6'b001000
`define EXE_ADDIU 6'b001001
`define EXE_SLTI 6'b001010
`define EXE_SLTIU 6'b001011
`define EXE_J  6'b000010
`define EXE_JAL  6'b000011
`define EXE_BEQ  6'b000100
`define EXE_BGTZ  6'b000111
`define EXE_BLEZ  6'b000110
`define EXE_BNE  6'b000101

`define EXE_LB  6'b100000
`define EXE_LBU  6'b100100
`define EXE_LH  6'b100001
`define EXE_LHU  6'b100101
`define EXE_LL  6'b110000
`define EXE_LW  6'b100011
`define EXE_LWL  6'b100010
`define EXE_LWR  6'b100110
`define EXE_SB  6'b101000
`define EXE_SC  6'b111000
`define EXE_SH  6'b101001
`define EXE_SW  6'b101011
`define EXE_SWL  6'b101010
`define EXE_SWR  6'b101110

//instructions_[20:16]_six_bits
`define EXE_BLTZ  5'b00000
`define EXE_BGEZ  5'b00001
`define EXE_BLTZAL  5'b10000
`define EXE_BGEZAL  5'b10001

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

`define EXE_JR  6'b001000
`define EXE_JALR  6'b001001

`define EXE_SYSCALL 6'b001100

`define EXE_BREAK 	6'b001101

// following are special2 instruction
`define EXE_MUL 6'b000010 
`define EXE_CLZ 6'b100000
`define EXE_CLO 6'b100001

// eret instrcution
`define EXE_ERET 32'b01000010000000000000000000011000

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

`define EXE_J_OP  6'b011011
`define EXE_JAL_OP  6'b011100
`define EXE_JALR_OP  6'b011101
`define EXE_JR_OP  6'b011110
`define EXE_BEQ_OP  6'b011111
`define EXE_BGEZ_OP  6'b100000
`define EXE_BGEZAL_OP  6'b100001
`define EXE_BGTZ_OP  6'b100010
`define EXE_BLEZ_OP  6'b100011
`define EXE_BLTZ_OP  6'b100100
`define EXE_BLTZAL_OP  6'b100101
`define EXE_BNE_OP  6'b100110

`define EXE_LB_OP  6'b100111
`define EXE_LBU_OP  6'b101000
`define EXE_LH_OP  6'b101001
`define EXE_LHU_OP  6'b101010
`define EXE_LL_OP  6'b101011
`define EXE_LW_OP  6'b101100
`define EXE_LWL_OP  6'b101101
`define EXE_LWR_OP  6'b101110
`define EXE_SB_OP  6'b101111
`define EXE_SC_OP  6'b110000
`define EXE_SH_OP  6'b110001
`define EXE_SW_OP  6'b110010
`define EXE_SWL_OP  6'b110011
`define EXE_SWR_OP  6'b110100

`define EXE_MFCO_OP 6'b110101
`define EXE_MTCO_OP 6'b110110

`define EXE_SYSCALL_OP 6'b110111
`define EXE_ERET_OP   6'b111000
`define EXE_BREAK_OP  6'b111001
//AluSel
`define EXE_RES_LOGIC 3'b000
`define EXE_RES_SHIFT 3'b001
`define EXE_RES_MOVE 3'b010
`define EXE_RES_ARITHMETIC 3'b011 // excluding multiplication 
`define EXE_RES_MUL 3'b100
`define EXE_RES_JUMP_BRANCH 3'b101
`define EXE_RES_LOAD_STORE 3'b110	
`define EXE_RES_NOP			3'b111

//instruction and address of instruction
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 3010710
`define InstMemNumLog2 31

//register value and address
`define RegBus 31:0
`define DoubleRegBus 63:0
`define RegAddrBus 4:0
`define StallBus 5:0

`define NOPRegAddr 5'b00000

//ALU instruction type and subtype
`define AluOpBus 5:0
`define AluSelBus 2:0

//CTRL and stall
`define Stall 1'b1
`define NotStall 1'b0

//DIV
`define DIV_FREE 2'b00
`define DIV_ON 2'b01
`define DIV_BY_ZERO 2'b10
`define DIV_END 2'b11

//branch instructions 
`define Branch 1'b1
`define NotBranch 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0

//ram parameters
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0


//current cp0 registers 
`define CP0_CAUSE 	5'b01101
`define CP0_STATUS 	5'b01100
`define CP0_EPC		5'b01110
`define CP0_EBASE	5'b01111
`define CP0_EBASE_ADDR 32'h80001000

// define exception pos in type
`define EXCP_BREAK 7
`define EXCP_SYSCALL 8
`define EXCP_ERET 12
`define EXCP_INVALID_INST 9
`define EXCP_OVERFLOW 11
