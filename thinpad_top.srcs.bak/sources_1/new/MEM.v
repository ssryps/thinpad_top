`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 12:16:51 PM
// Design Name:
// Module Name: MEM
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

module MEM(
    input wire rst_i,
    input wire [4:0] wd_i,
    input wire wreg_i,
    input wire [31:0] wdata_i,
    output reg [4:0] wd_o,
    output reg wreg_o,
    output reg [31:0] wdata_o
    );

    always @(*) begin
        if (rst_i==`ENABLE) begin
            wd_o<=`ZERO;
            wreg_o=`ZERO;
            wdata_o=`ZERO;
        end else begin
            wd_o<=wd_i;
            wreg_o=wreg_i;
            wdata_o=wdata_i;
        end
    end
endmodule
