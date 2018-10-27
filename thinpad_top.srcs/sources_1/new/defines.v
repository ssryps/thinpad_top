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

//instructions
`define EXE_SPECIAL_OP  6'b000000
`define EXE_ORI         6'b001101
`define EXE_NOP         6'b000000

//AluOp
`define EXE_OR_OP    8'b00100101

`define EXE_ORI_OP  8'b01011010

`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001

`define EXE_RES_NOP 3'b000

//instruction and address of instruction
`define InstAddrBus 31:0
`define InstBus 31:0

//register value and address
`define RegBus 31:0
`define RegAddrBus 4:0

`define NOPRegAddr 5'b00000

//ALU instruction type and subtype
`define AluOpBus 7:0
`define AluSelBus 2:0

