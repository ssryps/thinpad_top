`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2018 08:21:54 PM
// Design Name: 
// Module Name: register
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

`define ZERO_REGISTER 5'b00000
`define ZERO_VALUE    32'h00000000
module RegisterFile(
    input wire clk,
    input wire rst, 
    input wire[4:0] read_addr_1,
    input wire read_enable_1,
    input wire[4:0] read_addr_2,
    input wire read_enable_2,
    
    //
    input wire[4:0] write_addr,
    input wire write_enable,
    input wire[31:0] write_data,
    
    output wire[31:0] result1,
    output wire[31:0] result2,

    input wire flush,
    input wire recovery,
        
    output reg[`RegBus] cnt_correct_instruction
    );
    reg [31:0] registers[31:0];

    reg [31:0] backup_registers[31:0];
    integer choice1, choice2, choice3;
    integer i;
    reg same1;
    reg same2;
    
    always @(* ) begin

        choice1 = read_addr_1;
        choice2 = read_addr_2;
        same1 = (read_addr_1 == write_addr && read_enable_1 == 1 && write_enable == 1);
        same2 = (read_addr_2 == write_addr && read_enable_2 == 1 && write_enable == 1);
    end

    assign result1 = (rst ? 0:(read_enable_1 ? (read_addr_1 == `ZERO_REGISTER? `ZERO_VALUE :(same1? write_data: registers[choice1]) ): `REGISTER_NOT_ENABLED));
    assign result2 = (rst ? 0:(read_enable_2 ? (read_addr_2 == `ZERO_REGISTER? `ZERO_VALUE :(same2? write_data: registers[choice2]) ): `REGISTER_NOT_ENABLED));
          
    always @(posedge clk) begin
        if(rst) begin
                registers[0] <= 0;
                registers[1] <= 0;
                registers[2] <= 0;
                registers[3] <= 0;
                registers[4] <= 0;
                registers[5] <= 0;
                registers[6] <= 0;
                registers[7] <= 0;
                registers[8] <= 0;
                registers[9] <= 0;
                registers[10] <= 0;
                registers[11] <= 0;
                registers[12] <= 0;
                registers[13] <= 0;
                registers[14] <= 0;
                registers[15] <= 0;
                registers[16] <= 0;
                registers[17] <= 0;
                registers[18] <= 0;
                registers[19] <= 0;
                registers[20] <= 0;
                registers[21] <= 0;
                registers[22] <= 0;
                registers[23] <= 0;
                registers[24] <= 0;
                registers[25] <= 0;
                registers[26] <= 0;
                registers[27] <= 0;
                registers[28] <= 0;
                registers[29] <= 0;
                registers[30] <= 0;
                registers[31] <= 0;
                                
        end else begin
            if((write_enable==1'b1) & (write_addr != `ZERO_REGISTER)) begin 
                registers[write_addr] = write_data; 
            end   
            if(flush == 1) begin 
                if(recovery == 0) begin 
                    backup_registers[1] <= registers[1];
                    backup_registers[2] <= registers[2];
                    backup_registers[3] <= registers[3];
                    backup_registers[4] <= registers[4];
                    backup_registers[5] <= registers[5];
                    backup_registers[6] <= registers[6];
                    backup_registers[7] <= registers[7];
                    backup_registers[8] <= registers[8];
                    backup_registers[9] <= registers[9];
                    backup_registers[10] <= registers[10];
                    backup_registers[11] <= registers[11];
                    backup_registers[12] <= registers[12];
                    backup_registers[13] <= registers[13];
                    backup_registers[14] <= registers[14];
                    backup_registers[15] <= registers[15];
                    backup_registers[16] <= registers[16];
                    backup_registers[17] <= registers[17];
                    backup_registers[18] <= registers[18];
                    backup_registers[19] <= registers[19];
                    backup_registers[20] <= registers[20];
                    backup_registers[21] <= registers[21];
                    backup_registers[22] <= registers[22];
                    backup_registers[23] <= registers[23];
                    backup_registers[24] <= registers[24];
                    backup_registers[25] <= registers[25];
                   // backup_registers[26] <= registers[0];
                   // backup_registers[27] <= registers[0];
                    backup_registers[28] <= registers[28];
                    backup_registers[29] <= registers[29];
                    backup_registers[30] <= registers[30];
                    backup_registers[31] <= registers[31];
                end else begin 
                    registers[1] <= backup_registers[1];
                    registers[2] <= backup_registers[2];
                    registers[3] <= backup_registers[3];
                    registers[4] <= backup_registers[4];
                    registers[5] <= backup_registers[5];
                    registers[6] <= backup_registers[6];
                    registers[7] <= backup_registers[7];
                    registers[8] <= backup_registers[8];
                    registers[9] <= backup_registers[9];
                    registers[10] <= backup_registers[10];
                    registers[11] <= backup_registers[11];
                    registers[12] <= backup_registers[12];
                    registers[13] <= backup_registers[13];
                    registers[14] <= backup_registers[14];
                    registers[15] <= backup_registers[15];
                    registers[16] <= backup_registers[16];
                    registers[17] <= backup_registers[17];
                    registers[18] <= backup_registers[18];
                    registers[19] <= backup_registers[19];
                    registers[20] <= backup_registers[20];
                    registers[21] <= backup_registers[21];
                    registers[22] <= backup_registers[22];
                    registers[23] <= backup_registers[23];
                    registers[24] <= backup_registers[24];
                    registers[25] <= backup_registers[25];
                   // registers[26] <= registers[0];
                   // registers[27] <= registers[0];
                    registers[28] <= backup_registers[28];
                    registers[29] <= backup_registers[29];
                    registers[30] <= backup_registers[30];
                    registers[31] <= backup_registers[31];
                end
            end
            cnt_correct_instruction<=registers[19];
        end

        
    end
endmodule
