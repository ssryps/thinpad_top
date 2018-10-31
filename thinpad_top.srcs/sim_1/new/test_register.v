`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2018 09:33:27 PM
// Design Name: 
// Module Name: test_register
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


module test_register;
wire clk_50M, clk_11M0592;
reg rst;
reg[4:0] read_addr_1;
reg read_enable_1;
reg[4:0] read_addr_2;
reg read_enable_2;
reg[4:0] write_addr;
reg write_enable;
reg[31:0] write_data;
wire[31:0] result1;
wire[31:0] result2;
initial begin
    rst = 1;
    #20;
    rst = 0;
    read_enable_1 = 1;
    read_enable_2 = 1;
    read_addr_1 = 5'b00000;
    read_addr_2 = 5'b00001;
    #5;
    write_addr = 5'b00001;
    write_data = 32'hFFFFFFFF;
    write_enable = 1;
    #20;
    read_enable_1 = 1;
    read_enable_2 = 1;
    read_addr_1 = 5'b00000;
    read_addr_2 = 5'b00001;
    #10
    write_addr = 5'b00000;
    write_data = 32'hFFFFFFFF;
    write_enable = 1;
    #20
    read_enable_1 = 0;
    read_enable_2 = 1;
    read_addr_1 = 5'b00000;
    read_addr_2 = 5'b00001;
    #20    
    read_enable_1 = 0;
    read_enable_2 = 0;
    read_addr_1 = 5'b00000;
    read_addr_2 = 5'b00001;

end

clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);

RegisterFile registe_file (
    .clk(clk_50M),
    .rst (rst),
    .read_addr_1(read_addr_1),
    .read_enable_1(read_enable_1),
    .read_addr_2(read_addr_2),
    .read_enable_2(read_enable_2),
    .write_addr(write_addr),
    .write_enable(write_enable),
    .write_data(write_data),
    .result1(result1),
    .result2(result2)
);
endmodule
