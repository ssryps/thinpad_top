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

module PC(
    input wire rst_i,
    input wire clk_i,
    input wire [`StallBus] stall_i,

    //input from id
    input wire branch_flag_i,
    input wire[`RegBus] branch_target_address_i,

    output reg [31:0] pc_o,
    output reg ce_o
    );
    /*reg rsted;
    always @(posedge clk_i) begin
        if (rst_i==`Enable) begin
            pc_o<=`ZeroWord;
            rsted<=`Enable;
        end else begin
            if (rsted==`Enable) begin
                rsted<=`Disable;
            end else if (stall_i[0]==`NotStall) begin
                if(branch_flag_i == `Branch) begin
                    pc_o <= branch_target_address_i;
                end else begin
                    pc_o<=pc_o+4'h4;
                end
            end
        end
    end
    
    always @ (posedge clk_i) begin
		if (rst_i==`Enable) begin
			ce_o<=`Disable;
		end else begin
			ce_o<=`Enable;
		end
	end*/
	always @ (posedge clk_i) begin
        if (ce_o == 1'b0) begin
                //pc_o <= 32'h00000000;
                pc_o <= 32'h80000000;
        end else if(stall_i[0] == 1'b0) begin
                  if(branch_flag_i == `Branch) begin
                        pc_o <= branch_target_address_i;
                    end else begin
                      pc_o <= pc_o + 4'h4;
                  end
            end
        end
        
    always @ (posedge clk_i) begin
        if (rst_i == `RstEnable) begin
            ce_o <= 1'b0;
        end else begin
            ce_o <= 1'b1;
        end
    end
endmodule
