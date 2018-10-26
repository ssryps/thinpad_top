`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 06:05:08 AM
// Design Name: 
// Module Name: test_id_ex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//global
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define ZeroWord 32'h0

//instructions
`define EXE_ORI 6'b001101
`define EXE_NOP 6'b000000

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
module test_id_ex;
wire my_clk_50M, my_clk_11M0592;
reg rst;
reg[`RegBus] pc;
reg[`RegBus] inst;
reg[`RegBus] reg1;
reg[`RegBus] reg2;

wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[`AluOpBus] aluop;
wire[`AluSelBus] alusel;
wire[`RegBus] reg1_o;
wire[`RegBus] reg2_o;
wire[`RegAddrBus] wd;
wire wreg;

wire[`AluOpBus] ex_aluop;
wire[`AluSelBus] ex_alusel;
wire[`RegBus] ex_reg1;
wire[`RegBus] ex_reg2;
wire[`RegAddrBus] ex_wd;
wire ex_wreg;

wire[`RegAddrBus] wd_o;
wire wreg_o;
wire[`RegBus] wdata_o;

wire[`RegAddrBus] mem_wd;
wire mem_wreg;
wire[`RegBus] mem_wdata;

initial begin
  rst = 1;
  #20;
  rst = 0;
  reg1 = 32'h55555555;
  reg2 = 32'h55555555;
  inst = 32'h34220000;
  #40;
  reg1 = 32'h55555555;
  inst = 32'h3422aaaa;
end

clock osc0 (
    .clk_11M0592(my_clk_11M0592),
    .clk_50M    (my_clk_50M)
);

id id0 (
    .rst(rst),
    .pc_i(pc),
    .inst_i(inst),
    .reg1_data_i(reg1),
    .reg2_data_i(reg2),
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    .aluop_o(aluop),
    .alusel_o(alusel),
    .reg1_o(reg1_o),
    .reg2_o(reg2_o),
    .wd_o(wd),
    .wreg_o(wreg)
);

id_ex id_ex0(
    .rst(rst),
    .clk(my_clk_50M),
    .id_aluop(aluop),
    .id_alusel(alusel),
    .id_reg1(reg1_o),
    .id_reg2(reg2_o),
    .id_wd(wd),
    .id_wreg(wreg),
    .ex_aluop(ex_aluop),
    .ex_alusel(ex_alusel),
    .ex_reg1(ex_reg1),
    .ex_reg2(ex_reg2),
    .ex_wd(ex_wd),
    .ex_wreg(ex_wreg)
);

ex ex_0(
    .rst(rst),
    .aluop_i(ex_aluop),
    .alusel_i(ex_alusel),
    .reg1_i(ex_reg1),
    .reg2_i(ex_reg2),
    .wd_i(ex_wd),
    .wreg_i(ex_wreg),
    .wd_o(wd_o),
    .wreg_o(wreg_o),
    .wdata_o(wdata_o)
);

ex_mem ex_mem0(
    .clk(my_clk_50M),
    .rst(rst),
    .ex_wd(wd_o),
    .ex_wreg(wreg_o),
    .ex_wdata(wdata_o),
    .mem_wd(mem_wd),
    .mem_wreg(mem_wreg),
    .mem_wdata(mem_wdata)
);

endmodule
