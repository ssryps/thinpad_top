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
//`include "def.v"

`include "defines.v"

module CTRL(
    input wire rst_i,
    input wire stall_from_id_i,
    input wire stall_from_ex_i,
    input wire stall_from_mem_i,
    output reg [`StallBus] stall_o
    );
    always @(*) begin
        if (rst_i==`RstEnable) begin
            stall_o<=6'b000000;
        end else if (stall_from_mem_i==`Stall) begin
            stall_o<=6'b111111;    
        end else if (stall_from_ex_i==`Stall) begin
            stall_o<=6'b001111;
        end else if (stall_from_id_i==`Stall) begin
            stall_o<=6'b000111;
        end else begin
            stall_o<=6'b000000;
        end
    end
endmodule
