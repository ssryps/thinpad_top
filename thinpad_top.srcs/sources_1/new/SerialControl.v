`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 09:22:09 PM
// Design Name: 
// Module Name: Serial
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


module Serial(
		input wire clk,
		input wire rst,
		input wire enabled,
		input wire[`SERIALCONTROL_DATA_LEN - 1:0] data,
		input wire[`SERIALCONTROL_OP_LEN - 1: 0]  operation
		
    );
endmodule
