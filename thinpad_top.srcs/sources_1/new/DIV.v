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

module DIV(
    input wire clk_i,
    input wire rst_i,

    input wire signed_div_i,
    input wire[`RegBus] op1_i,
    input wire[`RegBus] op2_i,
    input wire start_i,
    input wire annul_i,

    output reg [`DoubleRegBus] result_o,
    output reg ready_o 
    );
    
    wire [32:0] div_temp;
    reg [5:0] cnt;
    reg [64:0] dividend;//[63:32] is minuend, [31:0] is minuend-n 
    reg [1:0] state;
    reg [`RegBus] divisor;
    reg [`RegBus] temp_op1;
    reg [`RegBus] temp_op2;

    assign div_temp={1'b0,dividend[63:32]}-{1'b0,divisor};

    always @(posedge clk_i) begin
        if (rst_i==`RstEnable) begin
            state<=`DIV_FREE;
            result_o<=`DoubleZeroWord;
            ready_o<=`Disable;
        end else begin
            case (state)
                `DIV_FREE: begin
                    if (start_i==`Enable&&annul_i==`Disable) begin
                        if (op2_i==`ZeroWord) begin
                            state<=`DIV_BY_ZERO;
                        end else begin
                            state<=`DIV_ON;
                            cnt<=6'b000000;
                            if (signed_div_i==`Enable&&op1_i[31]==1'b1) begin
                                temp_op1=~op1_i+1;
                            end else begin
                                temp_op1=op1_i;
                            end
                            if (signed_div_i==`Enable&&op2_i[31]==1'b1) begin
                                temp_op2=~op2_i+1;
                            end else begin
                                temp_op2=op2_i;
                            end
                            dividend<=`DoubleZeroWord;
                            dividend[32:1]<=temp_op1;
                            divisor<=temp_op2;
                        end
                    end else begin
                        ready_o<=`Disable;
                        result_o<=`DoubleZeroWord;
                    end
                end
                `DIV_BY_ZERO: begin
                    state<=`DIV_END;
                    dividend<=`DoubleZeroWord;
                end
                `DIV_ON: begin
                    if (annul_i==`Enable) begin
                        state<=`DIV_FREE;
                    end else if (cnt==6'b100000) begin
                        if ((signed_div_i==1'b1)&&((op1_i[31]^op2_i[31])==1'b1)) begin
                            dividend[31:0]<=~dividend[31:0]+1;
                        end
                        // TODO: why check 64??
                        if ((signed_div_i==1'b1)&&((op1_i[31]^dividend[64])==1'b1)) begin
                            dividend[64:33]<=~dividend[64:33]+1;
                        end
                        cnt<=6'b000000;
                        state<=`DIV_END;
                    end else begin
                        if (div_temp[32]==1'b1) begin //minus result is negative
                            dividend[64:0]={dividend[63:0],1'b0};
                        end else begin
                            dividend[64:0]={div_temp[31:0],dividend[31:0],1'b1};
                        end
                        cnt<=cnt+1;
                    end
                end
                `DIV_END: begin
                    result_o<={dividend[64:33],dividend[31:0]};
                    ready_o<=`Enable;
                    if (start_i==`Disable) begin
                        state<=`DIV_FREE;
                        ready_o<=`Disable;
                        result_o<=`DoubleZeroWord;
                    end
                end
            endcase
        end
    end
endmodule
