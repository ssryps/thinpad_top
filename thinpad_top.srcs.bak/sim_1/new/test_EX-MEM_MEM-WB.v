`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 07:44:34 PM
// Design Name:
// Module Name: test_first_pipeline_zly
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
`include "../../sources_1/new/def.v"

module test_EX_MEM_WB;
reg rst;
// reg[31:0] rom_data_i;
// wire pc_ce;
// reg [31:0] pc;

// reg[31:0] id_pc_i;

// For IF_ID test
// reg[31:0] rom_data;
// wire [31:0]id_pc;
// wire [31:0]id_inst;

wire clk_50M, clk_11M0592;

clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);
initial begin
// net type cannot be assigned
    // pc=`ZERO;
    // pc=`ZERO;
    rst=1;
    // rom_data=32'h34011100;
    #100;
    rst=0;
    #100;
    rst=1;
    #50;
    rst=0;

    #100 $stop;
end

// PC Pc(etting

//     .rst_i(rst), .clk_i(clk_50M), .if_pc_i(pc)
// );

// IF_ID If_id(
//     .rst_i(rst), .clk_i(clk_50M), .if_pc_i(pc), .if_inst_i(rom_data),
//     .id_pc_o(id_pc) , .id_inst_o(id_inst)
// );
reg ex_wreg_i;
reg [31:0]ex_wd_i;
reg [31:0]ex_wdata_i;

initial begin
    ex_wd_i=1;
    ex_wreg_i=1;
    ex_wdata_i=1;
end


wire ex_mem_wreg_o,mem_wb_wreg_o;
wire [4:0]ex_mem_wd_o;
wire [31:0]ex_mem_wdata_o;
wire [4:0]mem_wd_o;
wire [31:0]mem_wdata_o;
wire [4:0]mem_wb_wd_o;
wire [31:0]mem_wb_wdata_o;

EX_MEM Ex_mem(
    .clk_i(clk_50M),
    .rst_i(rst),
    .ex_wd_i(ex_wd_i),
    .ex_wreg_i(ex_wreg_i),
    .ex_wdata_i(ex_wdata_i),
    .mem_wd_o(ex_mem_wd_o),
    .mem_wreg_o(ex_mem_wreg_o),
    .mem_wdata_o(ex_mem_wdata_o)
);


MEM Mem(
    .rst_i(rst),
    .wd_i(ex_mem_wd_o),
    .wreg_i(ex_mem_wreg_o),
    .wdata_i(ex_mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o)
    );

MEM_WB Mem_wb(
    .rst(rst),
    .clk(clk_50M),
    .mem_wd_i(mem_wd_o),
    .mem_wreg_i(mem_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .wb_wd_o(mem_wb_wd_o),
    .wb_wreg_o(mem_wb_wreg_o),
    .wb_wdata_o(mem_wb_wdata_o)
);

endmodule
