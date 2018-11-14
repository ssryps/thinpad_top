`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 09:22:09 PM
// Design Name: 
// Module Name: SerialControl
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
`include"MemoryUtils.v"

module SerialControl(
		input wire clk,
		input wire rst,
		input wire enabled,
		input wire[`SERIALCONTROL_DATA_LEN - 1:0] data,
		input wire[`SERIALCONTROL_OP_LEN - 1: 0]  operation
		
    );
endmodule
