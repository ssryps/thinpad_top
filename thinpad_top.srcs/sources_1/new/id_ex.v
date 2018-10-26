`include "defines.v"

module id_ex(
    input wire rst,
    input wire clk,
    
    //input from id
    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,
    input reg[`RegBus] id_reg1,
    input reg[`RegBus] id_reg2,
    input reg[`RegAddrBus] id_wd,
    input reg id_wreg,

    //output to ex
    output wire[`AluOpBus] ex_aluop,
    output wire[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
        end
        else begin
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;		
        end
    end

end module