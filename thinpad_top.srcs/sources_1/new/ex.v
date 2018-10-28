`include "defines.v"

module ex(
    input wire rst,

    //input from id_ex
    input wire[`AluOpBus] aluop_i,
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    //output to ex_mem
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o
);

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;

    //logic result
    always @ (*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end 
        else begin
            case (aluop_i)
                `EXE_OR_OP: begin  
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin 
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end

    //shift result
    always @ (*) begin
        if(rst == `RstEnable) begin
            shiftout <= `ZeroWord;
        end 
        else begin
            case (aluop_i)
                `EXE_SLL_OP: begin  
                    shiftout <= reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin  
                    shiftout <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin  
                    shiftout <= ({32{reg2_i[32]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | (reg2_i >> reg1_i[4:0]);
                end
                default: begin 
                    shiftout <= `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case ( alusel_i )
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;
            end 
            `EXE_RES_SHIFT: begin
                wdata_o <= shiftout;
            end 
            default: begin
                wdata_o <= `ZeroWord;
            end 
        endcase
    end

endmodule