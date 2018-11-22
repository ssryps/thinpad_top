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
    input wire enabled_i,
    input wire[`SRAMCONTROL_OP_LEN - 1:0]  op_i,
    input wire[31:0] data_i, 
    input wire[`SRAMCONTROL_ADDR_LEN - 1:0] addr_i,
    
    // output to upper devices
    output wire[31:0] result_o,

    // control signal to sram
    output wire ram1_ce_o,
    output wire ram1_oe_o,
    output wire ram1_we_o,    
    output wire[3:0]  ram1_be,
    inout wire[31:0] ram1_data,
    output wire[`SRAM_ADDR_LEN - 1:0] ram1_addr, 
    
    output wire ram2_ce_o,
    output wire ram2_oe_o,
    output wire ram2_we_o,    
    output wire[3:0]  ram2_be,
    inout wire[31:0] ram2_data,
    output wire[`SRAM_ADDR_LEN - 1:0] ram2_addr,

    //for debug
    output wire[2:0] sram_state,
    output wire[3:0] sram_addr_i

    );
    
    
    
    wire ram1_ce, ram1_we, ram1_oe;
    wire ram2_ce, ram2_we, ram2_oe;
    reg[2:0] __cur_state;
    reg[2:0] _cur_state;
    reg[2:0] cur_state;

    assign sram_state = cur_state;
    assign sram_addr_i = addr_i[3:0];
    reg[31:0] result_o_reg;

    wire flag;

    assign flag = (addr_i == 21'h000048 && op_i == `SRAMCONTROL_OP_WRITE);

    assign ram1_ce_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram1_ce);
    assign ram1_we_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram1_we);
    assign ram1_oe_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram1_oe);
    assign ram2_ce_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram2_ce);
    assign ram2_we_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram2_we);
    assign ram2_oe_o =  ((enabled_i == 0) && 1 ) || ((enabled_i == 1) && ram2_oe);

    assign ram1_be =  4'b0000;
    assign ram1_ce =  (cur_state == `SRAMCONTROL_INIT && 1)  
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)  
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 &&
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ));
    assign ram1_we =  (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 1)
                        )); 
    assign ram1_oe =  (cur_state == `SRAMCONTROL_INIT && 1)
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 1)
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ));


    assign ram2_be =  4'b0000;
    assign ram2_ce =  (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)  
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ));
    assign ram2_we =  (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 1)
                        )); 
    assign ram2_oe =  (cur_state == `SRAMCONTROL_INIT && 1) 
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 && 1)
                   || (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 1 && 
                        (
                      (cur_state == `SRAMCONTROL_WRITE_PHASE1 && 1)
                   || (cur_state == `SRAMCONTROL_WRITE_PHASE2 && 1)
                   || (cur_state == `SRAMCONTROL_READ_PHASE1 && 0)
                   || (cur_state == `SRAMCONTROL_READ_PHASE2 && 0)
                        ));



    assign ram1_data  = ((cur_state == `SRAMCONTROL_WRITE_PHASE1 || cur_state == `SRAMCONTROL_WRITE_PHASE2 ) ? data_i: `SRAMCONTROL_DEFAULT_DATA); 
    assign ram2_data  = ((cur_state == `SRAMCONTROL_WRITE_PHASE1 || cur_state == `SRAMCONTROL_WRITE_PHASE2 ) ? data_i: `SRAMCONTROL_DEFAULT_DATA); 

    assign ram1_addr  = (cur_state == `SRAMCONTROL_INIT? `SRAMCONTROL_DEFALUT_ADDR:addr_i[`SRAM_ADDR_LEN - 1:0]);
    assign ram2_addr  = (cur_state == `SRAMCONTROL_INIT? `SRAMCONTROL_DEFALUT_ADDR:addr_i[`SRAM_ADDR_LEN - 1:0]);

    assign result_o   = (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 ? ram1_data: ram2_data);
    //result_o_reg;//(cur_state == `SRAMCONTROL_READ_PHASE2? (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 ? ram1_data: ram2_data): `SRAMCONTROL_DEFAULT_DATA); 

      //currently just use baseram, seems that extram will be used later
    always @(posedge clk or negedge enabled_i) begin
        if(rst == 1 || enabled_i == 0) begin
            _cur_state <= `SRAMCONTROL_INIT;
        end else begin
            // cur_state is init or write2 or read2
            if(cur_state == `SRAMCONTROL_INIT || cur_state == `SRAMCONTROL_WRITE_PHASE2 || cur_state == `SRAMCONTROL_READ_PHASE2) begin        
                if(op_i == `SRAMCONTROL_OP_WRITE) begin
                    _cur_state <= `SRAMCONTROL_WRITE_PHASE1;
                end 
                if(op_i == `SRAMCONTROL_OP_READ) begin
                    _cur_state <=  `SRAMCONTROL_READ_PHASE1;
                end
            end else if(cur_state == `SRAMCONTROL_WRITE_PHASE1) begin        
            // cur_state is write1
               _cur_state <= `SRAMCONTROL_WRITE_PHASE2;
            end else if(cur_state == `SRAMCONTROL_READ_PHASE1) begin        
            // cur_state is read1
               _cur_state <= `SRAMCONTROL_READ_PHASE2;
               //result_o_reg = (addr_i[`SRAMCONTROL_ADDR_LEN - 1] == 0 ? ram1_data: ram2_data);
            end     
        end        
    end

    always @(op_i) begin
      __cur_state <= 3'b000; 
      if(~rst) begin
          if(_cur_state == `SRAMCONTROL_READ_PHASE1 || _cur_state == `SRAMCONTROL_WRITE_PHASE1) begin
              if(op_i == `SRAMCONTROL_OP_WRITE) begin
                    __cur_state <= `SRAMCONTROL_WRITE_PHASE1;
                end 
                if(op_i == `SRAMCONTROL_OP_READ) begin
                    __cur_state <=  `SRAMCONTROL_READ_PHASE1;
                end
          end
      end 
    end

    always @(_cur_state or __cur_state) begin 
      if(_cur_state == `SRAMCONTROL_READ_PHASE1 || _cur_state == `SRAMCONTROL_WRITE_PHASE1) begin 
        if(__cur_state != 3'b000) begin 
          cur_state <= __cur_state;
        end else begin 
          cur_state <= _cur_state;
        end
      end else begin 
          cur_state <= _cur_state;
      end


    end
endmodule