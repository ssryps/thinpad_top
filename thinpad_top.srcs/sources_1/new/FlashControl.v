`timescale 1ns / 1ns
`include "MemoryUtils.v"

`define Flash_INIT      3'b000
`define Flash_READ_1    3'b001
`define Flash_READ_2    3'b010
`define Flash_READ_3    3'b011

module FlashControl(
    input wire clock,
    input wire rst,
    input wire enabled_i,
    input wire op_i,
    input wire[`FLASHCONTROL_ADDR_LEN - 1:0] addr_i,
    output wire[31:0] result_o,
    output wire pause_from_flash,
    
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1
);

    reg[2:0] cur_state;
    reg[15:0] flash_data;
    reg flash_oe = 1'b0;
    reg flash_we = 1'b0;
    reg pause;
    reg[15:0] saved_data = 16'bz;

    assign pause_from_flash = pause;
    assign result_o = {16'b0, saved_data};
    assign flash_d = flash_data;
    assign flash_a = {2'b0, addr_i[`FLASHCONTROL_ADDR_LEN - 1:1]};
    
    assign flash_rp_n = 1'b1;
    assign flash_vpen = 1'b1;
    assign flash_ce_n = 1'b0;
    assign flash_oe_n = flash_oe;
    assign flash_we_n = flash_we;
    assign flash_byte_n = 1'b1;
    
    always @(posedge clock) begin
        if(rst == 1 || enabled_i == 1'b0 || op_i == `FLASHCONTROL_OP_NOP) begin
                cur_state <= `Flash_INIT;
                flash_oe <= 1'b1;
                flash_we <= 1'b1;
                flash_data <= 16'bz;
                pause <= 1'b0;
            end
            else begin
                case(cur_state)
                    `Flash_INIT: begin
                        cur_state <= `Flash_READ_1;
                        flash_we <= 1'b0;
                        flash_data <= 16'h00ff;
                        pause <= 1'b1;
                    end
                    `Flash_READ_1: begin
                        cur_state <= `Flash_READ_2;
                        flash_we <= 1'b1;
                    end    
                    `Flash_READ_2: begin
                        cur_state <= `Flash_READ_3;
                        flash_oe <= 1'b0;
                        flash_data <= 16'bz;
                    end  
                    `Flash_READ_3: begin
                        cur_state <= 3'b100;
                    end    
                    default: begin//`Flash_READ_4
                        cur_state <= `Flash_INIT;
                        saved_data <= flash_d;
                        flash_oe <= 1'b1;
                        pause <= 1'b0;
                    end    
                endcase
            end
   end
   
   /*always @(*) begin
           if(rst == 1 || enabled_i == 1'b0 || op_i == `FLASHCONTROL_OP_NOP ) begin
                       pause <= 1'b0;
           end
           else begin
                        pause <= 1'b1;
           end
   end*/
    
endmodule
