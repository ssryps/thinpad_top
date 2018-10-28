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


module test_PC;
reg clk;
reg rst;
reg[31:0] rom_data_i;
// wire pc_ce;
wire [31:0] pc;
// reg[31:0] id_pc_i;

wire clk_50M, clk_11M0592;

clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);
initial begin
// net type cannot be assigned
    // pc=`ZERO;
    rst=1;
    #100;
    rst=0;
    #100
    rst=1;
    #100;
    rst=0;

    #100 $stop;
end

PC Pc(
    .rst_i(rst), .clk_i(clk_50M), .pc_o(pc)
);


endmodule
