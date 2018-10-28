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
`include "def.v"

module MEM_WB(
    input wire rst,
    input wire clk,
    input wire [4:0] mem_wd_i,
    input wire mem_wreg_i,
    input wire [31:0] mem_wdata_i,
    output reg [4:0] wb_wd_o,
    output reg wb_wreg_o,
    output reg [31:0] wb_wdata_o
    );

    always @ (posedge clk) begin
        if (rst==`ENABLE) begin
            wb_wd_o<=`ZERO;
            wb_wreg_o<=`ZERO;
            wb_wdata_o<=`ZERO;
        end else begin
            wb_wd_o<=mem_wd_i;
            wb_wreg_o<=mem_wreg_i;
            wb_wdata_o<=mem_wdata_i;
        end
    end
endmodule
