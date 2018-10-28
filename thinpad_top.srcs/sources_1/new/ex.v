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

    //input from hilo
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //input from wb
    input wire[`RegBus] wb_hi_i,
	input wire[`RegBus] wb_lo_i,
	input wire wb_whilo_i,

    //input from mem
    input wire[`RegBus] mem_hi_i,
	input wire[`RegBus] mem_lo_i,
	input wire mem_whilo_i,

    //output to ex_mem
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    //output to ex_mem
    output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o,
	output reg whilo_o
);

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    reg[`RegBus] moveout;
    reg[`RegBus] HI;
    reg[`RegBus] LO;

    //get newest value of hi and lo
    always @(*) begin  
        if(rst == `RstEnable) begin 
            {HI, LO} <= {`ZeroWord,`ZeroWord};
        end else if(mem_whilo_i == `WriteEnable) begin
            {HI,LO} <= {mem_hi_i,mem_lo_i};
        end else if(wb_whilo_i == `WriteEnable) begin
            {HI,LO} <= {wb_hi_i,wb_lo_i};
        end else begin
            {HI,LO} <= {hi_i,lo_i};		
        end
    end 

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

    //move result
    always @(*) begin
        if(rst == `RstEnable) begin
            moveout <= `ZeroWord;
        end else begin
            moveout <= `ZeroWord;
            case(aluop_i)
                `EXE_MOVN_OP: begin
                    moveout <= reg1_i;
                end
                `EXE_MOVZ_OP: begin
                    moveout <= reg1_i;
                end 
                `EXE_MFHI_OP: begin 
                    moveout <= HI;
                end 
                `EXE_MTLO_OP: begin
                    moveout <= LO;
                end
                default: begin
                    moveout <= `ZeroWord;
                end
            endcase
        end
    end

    //overall result
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
            `EXE_RES_MOVE: begin
                wdata_o <= moveout;
            end
            default: begin
                wdata_o <= `ZeroWord;
            end 
        endcase
    end

    //specical cases for MTHI and MTLO
    always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;								
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end	

endmodule