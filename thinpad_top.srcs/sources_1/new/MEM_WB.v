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

    //Stall singal from CTRL
    input wire [`StallBus] stall_i,

    output reg [`RegAddrBus] wb_wd_o,
    output reg wb_wreg_o,
    output reg [`RegBus] wb_wdata_o,

    output reg[`RegBus] wb_hi,
    output reg[`RegBus] wb_lo,
    output reg wb_whilo,


    
    input wire cp0_reg_we_i,
    input wire[4:0] cp0_reg_write_addr_i,
    input wire[31:0] cp0_reg_data_i,
    output wire cp0_reg_we_o,
    output wire[4:0] cp0_reg_write_addr_o,
    output wire[31:0] cp0_reg_data_o,

    input flush


    );

    reg[4:0] cp0_reg_write_addr_o_reg;
    reg cp0_reg_we_o_reg;
    reg[31:0] cp0_reg_data_o_reg;
    assign cp0_reg_we_o = cp0_reg_we_o_reg;
    assign cp0_reg_write_addr_o = cp0_reg_write_addr_o_reg;
    assign cp0_reg_data_o = cp0_reg_data_o_reg;



    always @ (posedge clk) begin
        if (rst==`RstEnable || flush == 1) begin
            wb_wd_o<=`NOPRegAddr;
            wb_wreg_o<=`WriteDisable;
            wb_wdata_o<=`ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;

            cp0_reg_write_addr_o_reg <= 5'b00000;
            cp0_reg_we_o_reg <= `WriteDisable;
            cp0_reg_data_o_reg <= 32'b00000000_00000000_00000000_00000000;
        end else if (stall_i[4]==`Stall&&stall_i[5]==`NotStall) begin
            wb_wd_o<=`NOPRegAddr;
            wb_wreg_o<=`WriteDisable;
            wb_wdata_o<=`ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            
            cp0_reg_write_addr_o_reg <= 5'b00000;
            cp0_reg_we_o_reg <= `WriteDisable;
            cp0_reg_data_o_reg <= 32'b00000000_00000000_00000000_00000000;
        end else if (stall_i[4]==`NotStall) begin
            wb_wd_o<=mem_wd_i;
            wb_wreg_o<=mem_wreg_i;
            wb_wdata_o<=mem_wdata_i;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;

            cp0_reg_data_o_reg <= cp0_reg_data_i;
            cp0_reg_write_addr_o_reg <= cp0_reg_write_addr_i;
            cp0_reg_we_o_reg <= cp0_reg_we_i;
        end
    end
endmodule
