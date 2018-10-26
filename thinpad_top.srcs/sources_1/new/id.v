`include "defines.v"

module id(
    input wire                  rst,
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    //input from registers
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,

    //output to registers
    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,

    //output to ex
    output reg[`AluOpBus]       aluop_o,
    output reg[`AluSelBus]      alusel_o,
    output reg[`RegBus]         reg1_o,
    output reg[`RegBus]         reg2_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o
);

