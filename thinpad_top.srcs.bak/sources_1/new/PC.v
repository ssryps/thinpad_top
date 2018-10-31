`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 09:14:37 AM
// Design Name:
// Module Name: PC
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

module PC(
    input wire rst_i,
    input wire clk_i,

    output reg [31:0] pc_o
    // output reg ce_o
    );

    always @(posedge clk_i) begin
        if (rst_i==`ENABLE) begin
            pc_o<=`ZERO;
        end else begin
            pc_o<=pc_o+4;
        end
    end
endmodule
