`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2018 12:34:00 PM
// Design Name: 
// Module Name: sram_control
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


module test_sram_control;

wire clk_50M, clk_11M0592;

reg rst;
reg enabled;
reg[1:0]  operation;
reg[31:0] data;
reg[20:0] address;
wire[31:0] result;

wire[31:0] ram1_data; //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] ram1_addr; //BaseRAM地址
wire ram1_ce_n;       //BaseRAM片选，低有效
wire ram1_oe_n;       //BaseRAM读使能，低有效
wire ram1_we_n;       //BaseRAM写使能，低有效
wire[3:0] ram1_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0

wire[31:0] ram2_data; //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] ram2_addr; //BaseRAM地址
wire ram2_ce_n;       //BaseRAM片选，低有效
wire ram2_oe_n;       //BaseRAM读使能，低有效
wire ram2_we_n;       //BaseRAM写使能，低有效
wire[3:0] ram2_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0

initial begin
    rst = 1;
    enabled = 1;
    #30;
    rst  = 0;
    operation = 2'b10;
    address   = 21'h111111;
    data = 32'h88888888;
    #20;
    operation = 2'b00;
    #20 ;
    rst  = 0;
    operation = 2'b10;
    address   = 21'h011111;
    data = 32'h11111111;
    #40;
    operation = 2'b01;
    address   = 21'h011111;
    #40 ;   
    operation = 2'b01;
    address   = 21'h111111;

end


clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);


SRAMControl sram_control(
            .clk(clk_50M),
            .rst(rst),
            .enabled_i(enabled),
            .op_i(operation),
            .data_i(data), 
            .addr_i(address),
            .result_o(result), 
    // control signal to sram
            .ram1_data(ram1_data),
            .ram1_addr(ram1_addr),
            .ram1_ce(ram1_ce_n),
            .ram1_oe(ram1_oe_n),
            .ram1_we(ram1_we_n),
            .ram1_be(ram1_be_n),
            .ram2_data(ram2_data),
            .ram2_addr(ram2_addr),
            .ram2_ce(ram2_ce_n),
            .ram2_oe(ram2_oe_n),
            .ram2_we(ram2_we_n),
            .ram2_be(ram2_be_n)
    );

sram_model base1(/*autoinst*/
            .DataIO(ram1_data[15:0]),
            .Address(ram1_addr[19:0]),
            .OE_n(ram1_oe_n),
            .CE_n(ram1_ce_n),
            .WE_n(ram1_we_n),
            .LB_n(ram1_be_n[0]),
            .UB_n(ram1_be_n[1])
            );
sram_model base2(/*autoinst*/
            .DataIO(ram1_data[31:16]),
            .Address(ram1_addr[19:0]),
            .OE_n(ram1_oe_n),
            .CE_n(ram1_ce_n),
            .WE_n(ram1_we_n),
            .LB_n(ram1_be_n[2]),
            .UB_n(ram1_be_n[3])
            );
sram_model base3(/*autoinst*/
                        .DataIO(ram2_data[15:0]),
                        .Address(ram2_addr[19:0]),
                        .OE_n(ram2_oe_n),
                        .CE_n(ram2_ce_n),
                        .WE_n(ram2_we_n),
                        .LB_n(ram2_be_n[0]),
                        .UB_n(ram2_be_n[1])
                        );
                        
sram_model base4(/*autoinst*/
            .DataIO(ram2_data[31:16]),
            .Address(ram2_addr[19:0]),
            .OE_n(ram2_oe_n),
            .CE_n(ram2_ce_n),
            .WE_n(ram2_we_n),
            .LB_n(ram2_be_n[2]),
            .UB_n(ram2_be_n[3])
            );


endmodule