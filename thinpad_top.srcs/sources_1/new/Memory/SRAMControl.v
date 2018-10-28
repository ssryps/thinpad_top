`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 06:41:43 PM
// Design Name: 
// Module Name: SRAMControl
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
`include "MemoryUtils.v"

`define SRAMCONTROL_INIT            3'b001
`define SRAMCONTROL_WRITE_PHASE1    3'b010
`define SRAMCONTROL_WRITE_PHASE2    3'b011
`define SRAMCONTROL_READ_PHASE1     3'b100
`define SRAMCONTROL_READ_PHASE2     3'b101

// the input clk should below 120M hz
module SRAMControl(
    input wire clk,
    input wire rst,
    input wire enabled,
    input wire[`SRAMCONTROL_OP_LEN - 1:0]  operation,
    input wire[31:0] data, 
    input wire[`SRAMCONTROL_ADDR_LEN - 1:0] address,
    
    // output to upper devices
    output wire[31:0] result,

    // control signal to sram
    output wire ram1_ce,
    output wire ram1_oe,
    output wire ram1_we,    
    output wire[3:0]  ram1_be,
    inout wire[31:0] ram1_data,
    output wire[`SRAM_ADDR_LEN - 1:0] ram1_addr, 
    
    output wire ram2_ce,
    output wire ram2_oe,
    output wire ram2_we,    
    output wire[3:0]  ram2_be,
    inout wire[31:0] ram2_data,
    output wire[`SRAM_ADDR_LEN - 1:0] ram2_addr

    );
    
    reg[2:0] cur_state;
    

    assign ram1_be =  4'b0000;
    assign ram1_ce =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)  
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ))
                   ;
    assign ram1_we =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 1)
                        ))
                   ; 
    assign ram1_oe =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        )) 
                  ;


    assign ram2_be =  4'b0000;
    assign ram2_ce =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)  
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ))
                   ;
    assign ram2_we =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 1)
                        ))
                   ; 
    assign ram2_oe =  (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)
                   || (address[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        )) 
                  ;



    assign ram1_data  = ((cur_state == `SRAMCONTROL_WRITE_PHASE1 || cur_state == `SRAMCONTROL_WRITE_PHASE2 ) ? data: `SRAMCONTROL_DEFAULT_DATA); 
    assign ram2_data  = ((cur_state == `SRAMCONTROL_WRITE_PHASE1 || cur_state == `SRAMCONTROL_WRITE_PHASE2 ) ? data: `SRAMCONTROL_DEFAULT_DATA); 

    assign ram1_addr  = (cur_state == `SRAMCONTROL_INIT? `SRAMCONTROL_DEFALUT_ADDR:address[`SRAM_ADDR_LEN - 1:0]);
    assign ram2_addr  = (cur_state == `SRAMCONTROL_INIT? `SRAMCONTROL_DEFALUT_ADDR:address[`SRAM_ADDR_LEN - 1:0]);

    assign result     = (cur_state == `SRAMCONTROL_READ_PHASE2? (address[`SRAMCONTROL_ADDR_LEN - 1] == 0 ? ram1_data: ram2_data): `SRAMCONTROL_DEFAULT_DATA); 

      //currently just use baseram, seems that extram will be used later
    always @(posedge clk) begin
        if(rst == 1 || enabled == 0) begin
            cur_state <= `SRAMCONTROL_INIT;
        end else begin
            // cur_state is init or write2 or read2
            if(cur_state == `SRAMCONTROL_INIT || cur_state == `SRAMCONTROL_WRITE_PHASE2 || cur_state == `SRAMCONTROL_READ_PHASE2) begin        
                if(operation == `SRAMCONTROL_OP_WRITE) begin
                    cur_state <= `SRAMCONTROL_WRITE_PHASE1;
                end 
                if(operation == `SRAMCONTROL_OP_READ) begin
                    cur_state <=  `SRAMCONTROL_READ_PHASE1;
                end
            end
            // cur_state is write1
            if(cur_state == `SRAMCONTROL_WRITE_PHASE1) begin        
               cur_state <= `SRAMCONTROL_WRITE_PHASE2;
            end     
            // cur_state is read1
            if(cur_state == `SRAMCONTROL_READ_PHASE1) begin        
               cur_state <= `SRAMCONTROL_READ_PHASE2;
            end     
        end        
    end
endmodule
