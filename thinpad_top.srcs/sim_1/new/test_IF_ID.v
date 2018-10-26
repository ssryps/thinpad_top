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

module test_IF_ID;
reg rst;
reg[31:0] rom_data_i;
// wire pc_ce;
reg [31:0] pc;
// reg[31:0] id_pc_i;

reg[31:0] rom_data;
wire [31:0]id_pc;
wire [31:0]id_inst;

wire clk_50M, clk_11M0592;

clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);
initial begin
// net type cannot be assigned
    // pc=`ZERO;
    pc=`ZERO;
    rst=1;
    rom_data=32'h34011100;
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

IF_ID If_id(
    .rst_i(rst), .clk_i(clk_50M), .if_pc_i(pc), .if_inst_i(rom_data),
    .id_pc_o(id_pc) , .id_inst_o(id_inst)
);


endmodule
