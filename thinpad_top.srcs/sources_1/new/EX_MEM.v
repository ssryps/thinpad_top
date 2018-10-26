`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 12:08:31 PM
// Design Name:
// Module Name: EX_MEM
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

module EX_MEM(
    input wire clk_i,
    input wire rst_i,
    input wire [4:0] ex_wd_i,
    input wire ex_wreg_i,
    input wire [31:0] ex_wdata_i,
    output reg [4:0] mem_wd_o,
    output reg mem_wreg_o,
    output reg [31:0] mem_wdata_o
    );

    always @(posedge clk_i) begin
        if (rst_i==`ENABLE) begin
            mem_wd_o<=`ZERO;
            mem_wreg_o<=`ZERO;
            mem_wdata_o<=`ZERO;
        end else begin
            mem_wd_o<=ex_wd_i;
            mem_wreg_o<=ex_wreg_i;
            mem_wdata_o<=ex_wdata_i;
        end
    end
endmodule
