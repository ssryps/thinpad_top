`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    //input from registers
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    //input from EX
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,
    input wire ex_wreg_i,
    //input from MEM 
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,
    input wire mem_wreg_i,

    //Stall singal from CTRL
    input wire [`StallBus] stall_i,

    //output to registers
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    //output to ex
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,

    //output to CTRL
    output reg stallreq_o
);
    wire[5:0] op = inst_i[31:26];
    wire[4:0] rs = inst_i[25:21];
    wire[4:0] rt = inst_i[20:16];
    wire[4:0] rd = inst_i[15:11];
    wire[4:0] sa = inst_i[10:6];
    wire[5:0] fn = inst_i[5:0];
    wire[25:0] target = inst_i[25:0];
    wire[15:0] imm = inst_i[15:0];// 
    wire[32:0] zeroImm = {16'h0, imm};
    wire[32:0] upperImm = {imm, 16'h0};
    wire[32:0] shiftImm = {27'h0, sa};
    reg[`RegBus] eimm;
    reg instvalid;

    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o <= `EXE_SLL_OP;
            alusel_o <= `EXE_RES_SHIFT;
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            instvalid <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            eimm <= `ZeroWord;
            end 
        else begin
            aluop_o <= `EXE_SLL_OP;
            alusel_o <= `EXE_RES_SHIFT;
            wd_o <= rd;
            wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= rs;
            reg2_addr_o <= rt;
            eimm <= `ZeroWord;
            case (op)
                `EXE_SPECIAL_INST: begin
                    case(fn)
                        `EXE_AND: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            //ex
                            aluop_o <= `EXE_AND_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_OR: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            //ex
                            aluop_o <= `EXE_OR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_XOR: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            //ex
                            aluop_o <= `EXE_XOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_NOR: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_NOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_SLL: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b1; 
                            eimm <= shiftImm;
                            //ex
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_SRL: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b1; 
                            eimm <= shiftImm;
                            //ex
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_SRA: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b1; 
                            eimm <= shiftImm;
                            //ex
                            aluop_o <= `EXE_SRA_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_SLLV: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_SRLV: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_SRAV: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SRA_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_MOVN: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_MOVN_OP;
                            alusel_o <= `EXE_RES_MOVE;
                            //mem
                            if(reg2_o != `ZeroWord) begin 
                                wreg_o <= `WriteEnable;
                            end else begin 
                                wreg_o <= `WriteDisable;
                            end

                            instvalid <= `InstValid;
                        end 
                        `EXE_MOVZ: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_MOVZ_OP;
                            alusel_o <= `EXE_RES_MOVE;
                            //mem
                            if(reg2_o == `ZeroWord) begin 
                                wreg_o <= `WriteEnable;
                            end else begin 
                                wreg_o <= `WriteDisable;
                            end

                            instvalid <= `InstValid;
                        end 
                        `EXE_MFHI: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_MFHI_OP;
                            alusel_o <= `EXE_RES_MOVE;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_MFLO: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_MFLO_OP;
                            alusel_o <= `EXE_RES_MOVE;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_MTHI: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_MTHI_OP;
                            //no alusel_o
                            //mem
                            wreg_o <= `WriteDisable;

                            instvalid <= `InstValid;
                        end 
                        `EXE_MTLO: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_MTLO_OP;
                            //no alusel_o
                            //mem
                            wreg_o <= `WriteDisable;

                            instvalid <= `InstValid;
                        end
                        //TODO: changes start from here
                        `EXE_ADD: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_ADD_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_ADDU: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_SUB: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SUB_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_SUBU: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_SLT: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SLT_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_SLTU: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_SLTU_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_MULT: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_MULT_OP;
                            // TODO:why no sel???
                            //alusel_o<=`EXE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_MULTU: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_MULTU_OP;
                            //alusel_o<=E`XE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteEnable;

                            instvalid <= `InstValid;
                        end
                        `EXE_DIV: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_DIV_OP;
                            //alusel_o<=E`XE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteDisable;

                            instvalid <= `InstValid;
                        end
                        `EXE_DIVU: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1; 
                            //ex
                            aluop_o <= `EXE_DIVU_OP;
                            //alusel_o<=E`XE_RES_ARITHMETIC;
                            //mem
                            wreg_o <= `WriteDisable;

                            instvalid <= `InstValid;
                        end
                    endcase  
                end
                `EXE_ORI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= zeroImm;
                    //ex
                    aluop_o <= `EXE_OR_OP;
                    alusel_o <= `EXE_RES_LOGIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_ANDI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= zeroImm;
                    //ex
                    aluop_o <= `EXE_AND_OP;
                    alusel_o <= `EXE_RES_LOGIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_XORI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= zeroImm;
                    //ex
                    aluop_o <= `EXE_XOR_OP;
                    alusel_o <= `EXE_RES_LOGIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_LUI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= upperImm;
                    //ex
                    aluop_o <= `EXE_OR_OP;
                    alusel_o <= `EXE_RES_LOGIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                //TODO: start from here
                `EXE_SLTI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                    //ex
                    aluop_o <= `EXE_SLT_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_SLTIU: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                    //ex
                    aluop_o <= `EXE_SLTU_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_ADDI: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                    //ex
                    aluop_o <= `EXE_ADD_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_ADDIU: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                    //ex
                    aluop_o <= `EXE_ADDU_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    //mem
                    wd_o <= rt;
                    wreg_o <= `WriteEnable;

                    instvalid <= `InstValid;
                end
                `EXE_SPECIAL2_INST: begin
                    case (fn)
                        `EXE_CLZ: begin
                        //registers
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b0;
                        //eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                        //ex
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        //mem
                        //wd_o <= rt;
                        wreg_o <= `WriteEnable;

                        instvalid <= `InstValid;
                        end

                        `EXE_CLO: begin
                        //registers
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b0;
                        //eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                        //ex
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        //mem
                        //wd_o <= rt;
                        wreg_o <= `WriteEnable;

                        instvalid <= `InstValid;
                        end

                        `EXE_MUL: begin
                        //registers
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        //eimm <= {{16{inst_i[15]}},inst_i[15:0]};
                        //ex
                        aluop_o <= `EXE_MUL_OP;
                        alusel_o <= `EXE_RES_MUL;
                        //mem
                        //wd_o <= rt;
                        wreg_o <= `WriteEnable;

                        instvalid <= `InstValid;
                        end
                    default: begin
                    end
                    endcase
                end

                default: begin 
                end 
            endcase 
        end //if
    end //always

    always @ (*) begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if (reg1_read_o==`Enable && ex_wreg_i==`Enable && reg1_addr_o==ex_wd_i) begin
            reg1_o <= ex_wdata_i;
        end else if (reg1_read_o==`Enable && mem_wreg_i==`Enable && reg1_addr_o==mem_wd_i) begin
            reg1_o <= mem_wdata_i;
        end else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if(reg1_read_o == 1'b0) begin
            reg1_o <= eimm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if (reg2_read_o==`Enable && ex_wreg_i==`Enable && reg2_addr_o==ex_wd_i) begin
            reg2_o <= ex_wdata_i;
        end else if (reg2_read_o==`Enable && mem_wreg_i==`Enable && reg2_addr_o==mem_wd_i) begin
            reg2_o <= mem_wdata_i;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if(reg2_read_o == 1'b0) begin
            reg2_o <= eimm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end

endmodule
