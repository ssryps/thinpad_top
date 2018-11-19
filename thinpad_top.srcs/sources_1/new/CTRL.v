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
    output reg [`StallBus] stall_o,

    input wire[`RegBus] excp_type_i,
    input wire[`RegBus] cp0_ebase_i,
    input wire[`RegBus] cp0_epc_i,
    output reg flush,
    output reg recovery,
    output reg[`RegBus] new_pc
    );
    always @(*) begin
        if (rst_i==`RstEnable) begin
            stall_o<=6'b000000;
            flush <= 0;
            new_pc <= `ZeroWord;
        end else if(excp_type_i != `ZeroWord) begin 
            flush <= 1;
            recovery <= 0;
            if(excp_type_i[`EXCP_SYSCALL] == 1) begin 
//                new_pc <= 32'h0000_0040;
               new_pc <= cp0_ebase_i + 32'h0000_0180;
            end

            if(excp_type_i[`EXCP_BREAK] == 1) begin 
            //                new_pc <= 32'h0000_0040;
               new_pc <= cp0_ebase_i + 32'h0000_0180;
            end


            if(excp_type_i[`EXCP_INVALID_INST] == 1) begin 
                new_pc <= cp0_ebase_i + 32'h0000_0180;
      
            end

            if(excp_type_i[`EXCP_OVERFLOW] == 1) begin 
                new_pc <= cp0_ebase_i + 32'h0000_0180;
            end

            if(excp_type_i[`EXCP_BAD_LOAD_ADDR] == 1) begin 
                new_pc <= cp0_ebase_i + 32'h0000_0180;
            end

            if(excp_type_i[`EXCP_BAD_STORE_ADDR] == 1) begin 
                new_pc <= cp0_ebase_i + 32'h0000_0180;
            end

            if(excp_type_i[`EXCP_BAD_PC_ADDR] == 1) begin 
                new_pc <= cp0_ebase_i + 32'h0000_0180;
            end

            if(excp_type_i[`EXCP_ERET] == 1) begin 
                new_pc <= cp0_epc_i;      
          //      recovery <= 1;
            end
      

        end else if (stall_from_mem_i==`Stall) begin
            stall_o<=6'b011111;    
            flush <= 0;
        end else if (stall_from_ex_i==`Stall) begin
            stall_o<=6'b001111;
            flush <= 0;
        end else if (stall_from_id_i==`Stall) begin
            stall_o<=6'b000111;
            flush <= 0;
        end else begin
            flush <= 0;
            stall_o<=6'b000000;
        end
    end
endmodule
