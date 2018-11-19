`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 10:28:24 AM
// Design Name:
// Module Name: IF_ID
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

module IF_ID(
    input wire rst_i,
    input wire clk_i,
    input wire [31:0] if_pc_i,
    input wire [31:0] if_inst_i,
    input wire [`StallBus] stall_i,

    // exception handler
    input wire flush,

    output reg [31:0] id_pc_o,
    output reg [31:0] id_inst_o
    );

    reg valid_inst;

    always @(posedge clk_i) begin
        if (rst_i==`Enable) begin
            id_pc_o<=`ZeroWord;
            id_inst_o<=`ZeroWord;
            valid_inst <= 0;
        end else if(valid_inst == 0) begin 
            id_pc_o<=`ZeroWord;
            id_inst_o<=`ZeroWord;
            valid_inst <= 1;
        end else if(flush == 1) begin 
            id_pc_o<=`ZeroWord;
            id_inst_o<=`ZeroWord;
        end else if (stall_i[1]==`Stall&&stall_i[2]==`NotStall) begin
            id_pc_o<=`ZeroWord;
            id_inst_o<=`ZeroWord;
        end else if (stall_i[1]==`NotStall) begin
            id_pc_o<=if_pc_i;
            id_inst_o<=if_inst_i;
        end
    end
endmodule
