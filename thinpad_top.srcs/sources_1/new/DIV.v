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

    input wire[`RegBus] op1_i,
    input wire[`RegBus] op2_i,
    input wire signed_div_i,
    input wire start_i,
    input wire annul_i,

    output reg [`DoubleRegBus] result_o,
    output reg ready_o 
    );
    
    wire [32:0] div_minus;
    reg [5:0] times;
    reg [64:0] dividend;//[63:32] is minuend, [31:0] is minuend-n 
    reg [1:0] state;
    reg [`RegBus] divisor;
    reg [`RegBus] t_op1;
    reg [`RegBus] t_op2;
    wire [`RegBus] dividend_m32;

    assign dividend_m32=dividend[63:32];
    assign dividend_m32=dividend[63:32];
    assign div_minus={1'b0,dividend_m32}-{1'b0,divisor};

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
                            times<=6'b000000;
                            if (signed_div_i==`Enable&&op1_i[31]==1'b1) begin
                                t_op1=~op1_i+1;
                            end else begin
                                t_op1=op1_i;
                            end
                            if (signed_div_i==`Enable&&op2_i[31]==1'b1) begin
                                t_op2=~op2_i+1;
                            end else begin
                                t_op2=op2_i;
                            end
                            dividend<=`DoubleZeroWord;
                            dividend[32:1]<=t_op1;
                            divisor<=t_op2;
                        end
                    end else begin
                        ready_o<=`Disable;
                        result_o<=`DoubleZeroWord;
                    end
                end
                `DIV_ON: begin
                    if (annul_i==`Enable) begin
                        state<=`DIV_FREE;
                    end else if (times==6'b100000) begin
                        times<=6'b000000;
                        state<=`DIV_END;
                        if ((signed_div_i==1'b1)&&((op1_i[31]^op2_i[31])==1'b1)) begin
                            dividend[31:0]<=~dividend[31:0]+1;
                        end
                        // TODO: why check 64 is necessary?
                        if ((signed_div_i==1'b1)&&((op1_i[31]^dividend[64])==1'b1)) begin
                            dividend[64:33]<=~dividend[64:33]+1;
                        end
                    end else begin
                        if (div_minus[32]==1'b0) begin //minus result is non-negative
                            dividend[64:1]={div_minus[31:0],dividend[31:0]};
                            dividend[0]=1'b1;
                        end else begin
                            dividend[64:1]=dividend[63:0];
                            dividend[0]=1'b0;
                        end
                        times<=times+1;
                    end
                end
                `DIV_BY_ZERO: begin
                    state<=`DIV_END;
                    dividend<=`DoubleZeroWord;
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
