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
    
    //input from DIV
    input wire [`DoubleRegBus] div_result_i,
    input wire div_ready_i,

    //output to ex_mem
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    //output to ex_mem
    output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o,
	output reg whilo_o,
    
    //output to CTRL
    output reg stallreq_o,
    
    //output to DIV
    output reg signed_div_o,
    output reg [`RegBus] div_op1_o,
    output reg [`RegBus] div_op2_o,
    output reg div_start_o
);

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    reg[`RegBus] moveout;
    reg[`RegBus] HI;
    reg[`RegBus] LO;

    //basic arithmetic opeartion
    wire reg1_eq_reg2;
    wire reg1_lt_reg2;
    wire ov_sum;
    reg[`RegBus] arithmetic_result;
    wire[`RegBus] reg2_i_mux;// reg2 2's complement
    wire[`RegBus] reg1_i_not;// reg1 1's complement
    wire[`RegBus] result_sum;
    wire[`RegBus] operand1_mult;
    wire[`RegBus] operand2_mult;
    wire[`DoubleRegBus] hilo_temp;
    reg[`DoubleRegBus] mulres; // result of  multiplication

    //DIV
    reg stallreq_for_div;

    assign reg2_i_mux=((aluop_i==`EXE_SUB_OP)||(aluop_i==`EXE_SUBU_OP)||
        (aluop_i==`EXE_SLT_OP))?(~reg2_i)+1:reg2_i;
    assign result_sum=reg1_i+reg2_i_mux;
    assign ov_sum=((!reg1_i[31] && !reg2_i_mux[31])&&result_sum[31])||
        ((reg1_i[31]&&reg2_i_mux[31])&&(!result_sum[31]));
    assign reg1_lt_reg2=(aluop_i==`EXE_SLT_OP)?(reg1_i[31]&&!reg2_i[31])||
        (!reg1_i[31]&&!reg2_i[31]&&result_sum[31])||
        (reg1_i[31]&&reg2_i[31]&&result_sum[31]):
        reg1_i<reg2_i;
    assign reg1_i_not=~reg1_i;

    //arithmetic result
    always @(*) begin
        if (rst==`RstEnable) begin
            arithmetic_result<=`ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT_OP,`EXE_SLTU_OP: begin
                    arithmetic_result<=reg1_lt_reg2;
                end
                `EXE_ADD_OP,`EXE_ADDU_OP,//`EXE_ADDI_OP,`EXE_ADDIU_OP,
                    `EXE_SUB_OP,`EXE_SUBU_OP: begin
                    arithmetic_result<=result_sum;
                end
                `EXE_CLZ_OP: begin
					arithmetic_result<=reg1_i[31]?0:
					reg1_i[30]?1:
					reg1_i[29]?2:
					reg1_i[28]?3:
					reg1_i[27]?4:
					reg1_i[26]?5:
					reg1_i[25]?6:
					reg1_i[24]?7:
					reg1_i[23]?8:
					reg1_i[22]?9:
					reg1_i[21]?10:
					reg1_i[20]?11:
					reg1_i[19]?12:
					reg1_i[18]?13:
					reg1_i[17]?14:
					reg1_i[16]?15:
					reg1_i[15]?16:
					reg1_i[14]?17:
					reg1_i[13]?18:
					reg1_i[12]?19:
					reg1_i[11]?20:
					reg1_i[10]?21:
					reg1_i[9]?22:
					reg1_i[8]?23:
					reg1_i[7]?24:
					reg1_i[6]?25:
					reg1_i[5]?26:
					reg1_i[4]?27:
					reg1_i[3]?28:
					reg1_i[2]?29:
					reg1_i[1]?30:
					reg1_i[0]?31:32;
             	end
                `EXE_CLO_OP: begin
					arithmetic_result<=reg1_i_not[31]?0:
					reg1_i_not[30]?1:
					reg1_i_not[29]?2:
					reg1_i_not[28]?3:
					reg1_i_not[27]?4:
					reg1_i_not[26]?5:
					reg1_i_not[25]?6:
					reg1_i_not[24]?7:
					reg1_i_not[23]?8:
					reg1_i_not[22]?9:
					reg1_i_not[21]?10:
					reg1_i_not[20]?11:
					reg1_i_not[19]?12:
					reg1_i_not[18]?13:
					reg1_i_not[17]?14:
					reg1_i_not[16]?15:
					reg1_i_not[15]?16:
					reg1_i_not[14]?17:
					reg1_i_not[13]?18:
					reg1_i_not[12]?19:
					reg1_i_not[11]?20:
					reg1_i_not[10]?21:
					reg1_i_not[9]?22:
					reg1_i_not[8]?23:
					reg1_i_not[7]?24:
					reg1_i_not[6]?25:
					reg1_i_not[5]?26:
					reg1_i_not[4]?27:
					reg1_i_not[3]?28:
					reg1_i_not[2]?29:
					reg1_i_not[1]?30:
					reg1_i_not[0]?31:32;
             	end
                `EXE_DIV_OP,`EXE_DIVU_OP: begin
                    if (div_ready_i==`Disable) begin
                        div_op1_o<=reg1_i;
                        div_op2_o<=reg2_i;
                        div_start_o<=`Enable;
                        stallreq_for_div<=`Enable;
                        signed_div_o<=(aluop_i==`EXE_DIV_OP)?1'b1:1'b0;
                    end else begin
                        div_op1_o<=reg1_i;
                        div_op2_o<=reg2_i;
                        div_start_o<=`Disable;
                        stallreq_for_div<=`Disable;
                        signed_div_o<=(aluop_i==`EXE_DIV_OP)?1'b1:1'b0;
                    end
                    //TODO: else???
                end
				default: begin
					arithmetic_result<=`ZeroWord;
				end
			endcase
        end
    end

	// multiplication
	assign operand1_mult=((aluop_i==`EXE_MUL_OP||aluop_i==`EXE_MULT_OP)&&reg1_i[31]==1'b1)?
		(~reg1_i+1):reg1_i;
	assign operand2_mult=((aluop_i==`EXE_MUL_OP||aluop_i==`EXE_MULT_OP)&&reg2_i[31]==1'b1)?
		(~reg2_i+1):reg2_i;
	assign hilo_temp=operand1_mult*operand2_mult;

	always @(*) begin
		if (rst==`RstEnable) begin
            mulres<=64'b0;
        end else if ((aluop_i==`EXE_MULT_OP||(aluop_i==`EXE_MUL_OP))) begin
            if (reg1_i[31]^reg2_i[31]==1'b1) begin
                mulres<=~hilo_temp+1;
            end else begin
                mulres<=hilo_temp;
            end
        end else begin
            mulres<=hilo_temp;
        end
	end

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
        if (((aluop_i==`EXE_ADD_OP)||(aluop_i==`EXE_SUB_OP))&&(ov_sum==1'b1)) begin
            wreg_o<=`WriteDisable;
        end else begin
            wreg_o <= wreg_i;
        end
    
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
            `EXE_RES_ARITHMETIC: begin
                wdata_o <= arithmetic_result;
            end
            `EXE_RES_MUL: begin
                wdata_o <= mulres[31:0];
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
        end else if ((aluop_i==`EXE_MULT_OP)|| (aluop_i==`EXE_MULTU_OP)) begin
            whilo_o<=`WriteEnable;
            hi_o<=mulres[63:32];
            lo_o<=mulres[31:0];
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end else if(aluop_i == `EXE_DIV_OP||aluop_i == `EXE_DIVU_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= div_result_i[63:32];
			lo_o <= div_result_i[31:0];
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
        end			
	end	

    always @ (*) begin
        stallreq_o<=stallreq_for_div;
    end

endmodule
