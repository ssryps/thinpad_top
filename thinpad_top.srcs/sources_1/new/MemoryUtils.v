
// definition for RegisterFile
// result of register read if not enabled
`define REGISTER_NOT_ENABLED 	32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx


// definition for MemControl
// memcontrol parameters
`define MEMCONTROL_ADDR_LEN		32
`define MEMCONTROL_DEFAULT_DATA 32'bzzzzzzzz_zzzzzzzz_zzzzzzzz_zzzzzzzz

// input to memcontrol 
// operation
`define MEMCONTROL_OP_LEN		3
`define MEMCONTROL_OP_NOP   	3'b000
`define MEMCONTROL_OP_READ  	3'b001
`define MEMCONTROL_OP_WRITE 	3'b010

// operation data length
`define MEMECONTROL_OP_WORD				5'b11111
`define MEMECONTROL_OP_HALF_WORD		5'b01111
`define MEMECONTROL_OP_BYTE				5'b00111


// definition used between memcontrol and sramcontrol 
`define SRAMCONTROL_ADDR_LEN	21
`define SRAM_ADDR_LEN           20



`define SRAMCONTROL_OP_LEN		2
`define SRAMCONTROL_DATA_LEN	32
`define SRAMCONTROL_OP_NOP   	2'b00
`define SRAMCONTROL_OP_READ  	2'b01
`define SRAMCONTROL_OP_WRITE 	2'b10

`define SRAMCONTROL_DEFALUT_ADDR 20'bzzzzz_zzzzz_zzzzz_zzzzz
`define SRAMCONTROL_DEFAULT_DATA 32'bzzzzzzzz_zzzzzzzz_zzzzzzzz_zzzzzzzz

// definition used between memcontrol and serialcontrol
`define SERIALCONTROL_ADDR_LEN	3
`define SERIALCONTROL_OP_LEN	2
`define SERIALCONTROL_DATA_LEN	8
`define SERIALCONTROL_OP_NOP   	2'b00
`define SERIALCONTROL_OP_READ  	2'b01
`define SERIALCONTROL_OP_WRITE 	2'b10
