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

`include "defines.v"
module closemips(
	input wire clk,
	input wire rst,
	input wire[`RegBus] rom_data_i,

	output wire[`RegBus] rom_addr_o,
	output wire rom_ce_o
);
 
wire[`RegBus] pc;//pc is generated by PC
// reg[`RegBus] inst;
// fake instruction from ROM
// reg[31:0] rom_data_i;
// IF_ID to ID
wire [31:0]id_pc;
wire [31:0]id_inst;
// Return value to ID from RegFile
wire[`RegBus] reg1;
wire[`RegBus] reg2;

// ID request to RegFile
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
// ID write to RegFile
wire[`RegAddrBus] wd;
wire wreg;

wire[`AluOpBus] aluop;
wire[`AluSelBus] alusel;
wire[`RegBus] reg1_o;
wire[`RegBus] reg2_o;

wire[`AluOpBus] ex_aluop;
wire[`AluSelBus] ex_alusel;
wire[`RegBus] ex_reg1;
wire[`RegBus] ex_reg2;
wire[`RegAddrBus] ex_wd;
wire ex_wreg;

wire[`RegBus] hi;
wire[`RegBus] lo;

wire[`RegBus] wb_hi;
wire[`RegBus] wb_lo;
wire wb_whilo;

wire[`RegBus] mem_hi;
wire[`RegBus] mem_lo;
wire mem_whilo;

wire[`RegAddrBus] wd_o;
wire wreg_o;
wire[`RegBus] wdata_o;

wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;

wire[`RegAddrBus] mem_wd;
wire mem_wreg;
wire[`RegBus] mem_wdata;

// EX_MEM output
wire ex_mem_wreg_o;
wire [4:0]ex_mem_wd_o;
wire [31:0]ex_mem_wdata_o;

// MEM output
wire [4:0]mem_wd_o;
wire [31:0]mem_wdata_o;
wire mem_wreg_o;
// MEM_WB output
wire mem_wb_wreg_o;
wire [4:0]mem_wb_wd_o;
wire [31:0]mem_wb_wdata_o;

//HILO
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;

//Stall singal from CTRL
wire [`StallBus] stall_ctrl_o;
wire stallreq_id_o;
wire stallreq_ex_o;

//DIV
wire signed_div_ex_o;
wire [`RegBus] div_op1_ex_o;
wire [`RegBus] div_op2_ex_o;
wire start_ex_o;
wire annul_ex_o;
wire [`DoubleRegBus] result_div_o;
wire ready_div_o;

PC Pc(
    .rst_i(rst), .clk_i(clk), .stall_i(stall_ctrl_o), .pc_o(pc), .ce_o(rom_ce_o) 
);
assign rom_addr_o = pc;


IF_ID If_id(
    .rst_i(rst), .clk_i(clk), .if_pc_i(pc), .if_inst_i(rom_data_i), .stall_i(stall_ctrl_o),
    .id_pc_o(id_pc) , .id_inst_o(id_inst)
);

id id0 (
    .rst(rst),
    .pc_i(pc),
    .inst_i(rom_data_i),
    .reg1_data_i(reg1),
    .reg2_data_i(reg2),
    .ex_wdata_i(wdata_o),
    .ex_wd_i(wd_o),
    .ex_wreg_i(wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),
    .mem_wreg_i(mem_wreg_o),
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    .aluop_o(aluop),
    .alusel_o(alusel),
    .reg1_o(reg1_o),
    .reg2_o(reg2_o),
    .wd_o(wd),
    .wreg_o(wreg),
    .stallreq_o(stallreq_id_o)
);

id_ex id_ex0(
    .rst(rst),
    .clk(clk),
    .id_aluop(aluop),
    .id_alusel(alusel),
    .id_reg1(reg1_o),
    .id_reg2(reg2_o),
    .id_wd(wd),
    .id_wreg(wreg),
    .stall_i(stall_ctrl_o),
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
    .hi_i(hi),
    .lo_i(lo),
    .wb_hi_i(wb_hi),
    .wb_lo_i(wb_lo),
    .wb_whilo_i(wb_whilo),
    .mem_hi_i(mem_hi),
    .mem_lo_i(mem_lo),
    .mem_whilo_i(mem_whilo),
    .div_result_i(result_div_o),
    .div_ready_i(ready_div_o),
    
    .wd_o(wd_o),
    .wreg_o(wreg_o),
    .wdata_o(wdata_o),
    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .whilo_o(ex_whilo_o),
    .stallreq_o(stallreq_ex_o),
    .signed_div_o(signed_div_ex_o),
    .div_op1_o(div_op1_ex_o),
    .div_op2_o(div_op2_ex_o),
    .div_start_o(start_ex_o)
);

ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    .ex_wd(wd_o),
    .ex_wreg(wreg_o),
    .ex_wdata(wdata_o),
    .ex_hi(ex_hi_o),
    .ex_lo(ex_lo_o),
    .ex_whilo(ex_whilo_o),
    .stall_i(stall_ctrl_o),
    .mem_wd(ex_mem_wd_o),
    .mem_wreg(ex_mem_wreg_o),
    .mem_wdata(ex_mem_wdata_o),
    .mem_hi(mem_hi),
    .mem_lo(mem_lo),
    .mem_whilo(mem_whilo)
);
// 交接
MEM mem0(
    .rst_i(rst),
    .wd_i(ex_mem_wd_o),
    .wreg_i(ex_mem_wreg_o),
    .wdata_i(ex_mem_wdata_o),
    .hi_i(mem_hi),
    .lo_i(mem_lo),
    .whilo_i(mem_whilo),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    .hi_o(mem_hi_o),
    .lo_o(mem_lo_o),
    .whilo_o(mem_whilo_o)
);

MEM_WB Mem_wb(
    .rst(rst),
    .clk(clk),
    .mem_wd_i(mem_wd_o),
    .mem_wreg_i(mem_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .mem_whilo(mem_whilo_o),
    .stall_i(stall_ctrl_o),
    .wb_wd_o(mem_wb_wd_o),
    .wb_wreg_o(mem_wb_wreg_o),
    .wb_wdata_o(mem_wb_wdata_o),
    .wb_hi(wb_hi),
    .wb_lo(wb_lo),
    .wb_whilo(wb_whilo)
);

hilo hilo0(
    .clk(clk),
    .rst(rst),
    .writeEnable_i(wb_whilo),
    .writeHi_i(wb_hi),
    .writeLo_i(wb_lo),
    .dataHi_o(hi),
    .dataLo_o(lo)
);

RegisterFile regisetrfile0(
    .clk(clk),
    .rst(rst),
    .read_addr_1(reg1_addr),
    .read_enable_1(reg1_read),
    .read_addr_2(reg2_addr),
    .read_enable_2(reg2_read),
    .write_addr(mem_wb_wd_o),
    .write_enable(mem_wb_wreg_o),
    .write_data(mem_wb_wdata_o),

    .result1(reg1),
    .result2(reg2)

);

CTRL Ctrl(
    .rst_i(rst),
    .stall_from_id_i(stallreq_id_o),
    .stall_from_ex_i(stallreq_ex_o),
    .stall_o(stall_ctrl_o)
);

DIV div(
    .clk_i(clk),
    .rst_i(rst),
    .signed_div_i(signed_div_ex_o),
    .op1_i(div_op1_ex_o),
    .op2_i(div_op2_ex_o),
    .start_i(start_ex_o),
    // No annul at present
    .annul_i(1'b0),
    //.annul_i(annul_ex_o),
    
    .result_o(result_div_o),
    .ready_o(ready_div_o)
);

endmodule
