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
`include "def.v"

module IF_ID(
    input wire rst_i,
    input wire clk_i,
    input wire [31:0] if_pc_i,
    input wire [31:0] if_inst_i,
    output reg [31:0] id_pc_o,
    output reg [31:0] id_inst_o
    );

    always @(posedge clk_i) begin
        if (rst_i==`ENABLE) begin
            id_pc_o<=`ZERO;
            id_inst_o<=`ZERO;
        end else begin
            id_pc_o<=if_pc_i;
            id_inst_o<=if_inst_i;
        end
    end
endmodule
