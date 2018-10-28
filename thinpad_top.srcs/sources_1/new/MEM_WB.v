`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 12:37:35 PM
// Design Name:
// Module Name: MEM_WB
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

module MEM_WB(
    input wire rst,
    input wire clk,
    input wire [`RegAddrBus] mem_wd_i,
    input wire mem_wreg_i,
    input wire [`RegBus] mem_wdata_i,

    input wire[`RegBus] mem_hi,
    input wire[`RegBus] mem_lo,
    input wire mem_whilo,

    output reg [`RegAddrBus] wb_wd_o,
    output reg wb_wreg_o,
    output reg [`RegBus] wb_wdata_o,

    output reg[`RegBus] wb_hi,
    output reg[`RegBus] wb_lo,
    output reg wb_whilo
    );

    always @ (posedge clk) begin
        if (rst==`RstEnable) begin
            wb_wd_o<=`NOPRegAddr;
            wb_wreg_o<=`WriteDisable;
            wb_wdata_o<=`ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
        end else begin
            wb_wd_o<=mem_wd_i;
            wb_wreg_o<=mem_wreg_i;
            wb_wdata_o<=mem_wdata_i;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
        end
    end
endmodule
