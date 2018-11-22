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

    //from id_ex, whether last instruction is jump_branch instruction
    input wire is_in_delayslot_i,

    //input from ex to deal with load-related
    input wire[`AluOpBus] ex_aluop_i,

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
    output wire stallreq_o,

    //related to jump_branch
    output reg next_inst_in_delayslot_o,
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,       
	output reg[`RegBus] link_addr_o,
	output reg is_in_delayslot_o,
    output wire[`RegBus] inst_o,


    // exception


    output reg[`RegBus] excp_type_o,
    output reg[`RegBus] excp_inst_addr_o

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
    wire[`RegBus] pc_plus_8;
    wire[`RegBus] pc_plus_4;
    wire[`RegBus] imm_sll2_signedext;  

    //load-related
    reg stall_for_reg1_loadrelate;
    reg stall_for_reg2_loadrelate;
    wire ex_inst_is_load;

    reg is_syscall_excp, is_eret_excp, is_break_excp;
    assign ex_inst_is_load =((ex_aluop_i==`EXE_LB_OP) ||
                            (ex_aluop_i==`EXE_LBU_OP)  ||
                            (ex_aluop_i==`EXE_LH_OP)  ||
                            (ex_aluop_i==`EXE_LHU_OP) ||
                            (ex_aluop_i==`EXE_LW_OP)  ||
                            (ex_aluop_i==`EXE_LWR_OP)  ||
                            (ex_aluop_i==`EXE_LWL_OP)  ||
                            (ex_aluop_i==`EXE_LL_OP)  ||
                            (ex_aluop_i==`EXE_SC_OP)) ? 1'b1:1'b0;


    assign pc_plus_8 = pc_i + 8;
    assign pc_plus_4 = pc_i +4;
    assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  

    assign inst_o = inst_i;

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
            link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
            is_reserve_inst <= 0;
            
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
            link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			next_inst_in_delayslot_o <= `NotInDelaySlot; 
            is_eret_excp <= 0;
            is_syscall_excp <= 0;
            is_break_excp <= 0; 
            is_reserve_inst <= 0;
            

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
                        `EXE_JR: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_JR_OP;
                            alusel_o<=`EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteDisable;

                            //jump_branch
                            link_addr_o <= `ZeroWord;
                            branch_target_address_o <= reg1_o;
			            	branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;

                            instvalid <= `InstValid;
                        end
                        `EXE_JALR: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_JALR_OP;
                            alusel_o<=`EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteEnable;
                            wd_o <= rd;

                            //jump_branch
                            link_addr_o <= pc_plus_8;
                            branch_target_address_o <= reg1_o;
			            	branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;

                            instvalid <= `InstValid;
                        end

                        `EXE_SYSCALL: begin
                            //registers
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_SYSCALL_OP;
                            alusel_o<=`EXE_RES_NOP;
                            //mem
                            wreg_o <= `WriteDisable;
                            is_syscall_excp <= 1;
                            instvalid <= `InstValid;
                        end

                        `EXE_BREAK: begin 
                            reg1_read_o <= 1'b0;
                            reg2_read_o <= 1'b0; 
                            //ex
                            aluop_o <= `EXE_BREAK_OP;
                            alusel_o<=`EXE_RES_NOP;
                            //mem
                            wreg_o <= `WriteDisable;
                            is_break_excp <= 1; 
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
                    if (rs != 5'h0) begin
                        is_reserve_inst <= 1;
                    end
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
                `EXE_J: begin
                    //registers
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_J_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteDisable;
                    //jump_branch
                    link_addr_o <= `ZeroWord;
                    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;

                    instvalid <= `InstValid;
                end
                `EXE_JAL: begin
                    //registers
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_JAL_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= 5'b11111;
                    //jump_branch
                    link_addr_o <= pc_plus_8;
                    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;

                    instvalid <= `InstValid;
                end
                `EXE_BEQ: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_BEQ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteDisable;
                    //jump_branch
                    if(reg1_o == reg2_o) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                    end
                    next_inst_in_delayslot_o <= `InDelaySlot;
             
                    instvalid <= `InstValid;
                end
                `EXE_BGTZ: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_BGTZ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteDisable;
                    //jump_branch
                    if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                    end
                    next_inst_in_delayslot_o <= `InDelaySlot;
           
                    instvalid <= `InstValid;
                    if (rt != 5'h0) begin
                        is_reserve_inst <= 1;
                    end 
                end
                `EXE_BLEZ: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_BLEZ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteDisable;
                    //jump_branch
                    if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                    end
                    next_inst_in_delayslot_o <= `InDelaySlot;
         
                    instvalid <= `InstValid;
                    if (rt != 5'h0) begin
                        is_reserve_inst <= 1;
                    end
                end
                `EXE_BLEZL: begin 
                    if (rt != 5'h0) begin
                        is_reserve_inst <= 1;
                    end

                end

                `EXE_BNE: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_BNE_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH;
                    //mem
                    wreg_o <= `WriteDisable;
                    //jump_branch
                    if(reg1_o != reg2_o) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                    end
                    next_inst_in_delayslot_o <= `InDelaySlot;
                 
                    instvalid <= `InstValid;
                end
                `EXE_LB: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_LB_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;

                    instvalid <= `InstValid;
                end
                `EXE_LBU: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_LBU_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_LH: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_LH_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_LHU: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_LHU_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_LW: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    //ex
                    aluop_o <= `EXE_LW_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_LWL: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_LWL_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_LWR: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_LWR_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteEnable;
                    wd_o <= rt;
                    
                    instvalid <= `InstValid;
                end
                `EXE_SB: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_SB_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteDisable;
                    
                    instvalid <= `InstValid;
                end
                `EXE_SH: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_SH_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteDisable;
                    
                    instvalid <= `InstValid;
                end
                `EXE_SW: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_SW_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteDisable;
                    
                    instvalid <= `InstValid;
                end
                `EXE_SWL: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_SWL_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteDisable;
                    
                    instvalid <= `InstValid;
                end
                `EXE_SWR: begin
                    //registers
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    //ex
                    aluop_o <= `EXE_SWR_OP;
                    alusel_o <= `EXE_RES_LOAD_STORE;
                    //mem
                    wreg_o <= `WriteDisable;
                    
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

                `EXE_REGIMM_INST: begin
                    case (rt)
                        `EXE_BGEZ: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            //ex
                            aluop_o <= `EXE_BGEZ_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteDisable;
                            //jump_branch
                            if(reg1_o[31] == 1'b0) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                            end
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        
                            instvalid <= `InstValid;
                        end
                        `EXE_BGEZAL: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            //ex
                            aluop_o <= `EXE_BGEZAL_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteEnable;
                            wd_o <= 5'b11111;
                            //jump_branch
                            link_addr_o <= pc_plus_8;
                            if(reg1_o[31] == 1'b0) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                            end
                            next_inst_in_delayslot_o <= `InDelaySlot;
                    
                            instvalid <= `InstValid;
                        end
                        `EXE_BLTZ: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            //ex
                            aluop_o <= `EXE_BLTZ_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteDisable;
                            //jump_branch
                            if(reg1_o[31] == 1'b1) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                            end
                            next_inst_in_delayslot_o <= `InDelaySlot;
                
                            instvalid <= `InstValid;
                        end
                        `EXE_BLTZAL: begin
                            //registers
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            //ex
                            aluop_o <= `EXE_BLTZAL_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH;
                            //mem
                            wreg_o <= `WriteEnable;
                            wd_o <= 5'b11111;
                            //jump_branch
                            link_addr_o <= pc_plus_8;
                            if(reg1_o[31] == 1'b1) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= `Branch;
                            end
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        
                            instvalid <= `InstValid;
                        end

                        default:begin
                        end
                    endcase
                end

                `EXE_EXCEPTION_INST: begin
                    if(rs == 5'b00000 && inst_i[10:3] == 8'b00000000) begin
                        aluop_o <= `EXE_MFCO_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        wd_o <= inst_i[20:16];
                        wreg_o <= `WriteEnable;
                        instvalid <= `InstValid;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                    end 
                    if(rs == 5'b00100 && inst_i[10:3] == 8'b00000000) begin
                        aluop_o <= `EXE_MTCO_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        wd_o <= inst_i[20:16];
                        wreg_o <= `WriteDisable;
                        instvalid <= `InstValid;
                        reg1_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[20:16];
                        reg2_read_o <= 1'b0;
                    end
                end
                default: begin 
                end 
            endcase 

            if(inst_i == `EXE_ERET) begin
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0; 
                //ex
                aluop_o <= `EXE_ERET_OP;
                alusel_o<=`EXE_RES_NOP;
                //mem
                wreg_o <= `WriteDisable;
                instvalid <= `InstValid;
                is_eret_excp <= 1;
            end

            if(inst_i == `ZeroWord) begin 
                instvalid <= `InstValid;
            end


            if( op == 6'b010111 ||
                op == 6'b011000 || op == 6'b011001 || op == 6'b011010 || op == 6'b011011 || op == 6'b011110 || op == 6'b011111 || op == 6'b011101
              || op == 6'b100111
              || op == 6'b101100 || op == 6'b101101 
              || op == 6'b110100 || op == 6'b110111 
              || op == 6'b111011 || op == 6'b111100 || op == 6'b111111    
              ) begin 
                is_reserve_inst <= 1;
            end

            // special instruction
            if((op == 6'b000000) && (fn ==  6'b000101
            || fn == 6'b001110 
            || fn == 6'b010100 || fn == 6'b010101 || fn == 6'b010110 || fn == 6'b010111  
            || fn == 6'b101000 || fn == 6'b101001 || fn == 6'b101100 || fn == 6'b101101 || fn == 6'b101110 || fn == 6'b101111
            || fn == 6'b110101 || fn == 6'b110111
            || fn[5:3] == 3'b111  
            )) begin 
                is_reserve_inst <= 1;
            end

            // regimn instruction
            if((op == 6'b000001) && (rt[4:2] ==  3'b001
            || rt == 5'b01101 || rt == 5'b01111 
            || rt[4:2] ==  3'b101
            || rt[4:3] ==  2'b11
            )) begin 
                is_reserve_inst <= 1;
            end

            if(op == 6'b011100) begin 
                if(fn == 6'b000000 || fn == 6'b000001 || fn == 6'b000010 || fn == 6'b000100 || fn == 6'b000101
                || fn == 6'b100000 || fn == 6'b100001
                || fn == 6'b111111
                ) begin 
                    is_reserve_inst <= 0;
                end else begin 
                    is_reserve_inst <= 1;
                end

            end  

          // cp_n instruction
            if(op == 6'b010000) begin 
                if(rs ==  5'b00000 || rs == 5'b00100 || rs[4] == 1) begin 
                    is_reserve_inst <= 0;
                end else begin 
                    is_reserve_inst <= 1;
                end

            end

            if(op == 6'b010001) begin 
                if(rs ==  5'b00000 || rs == 5'b00010 || rs == 5'b00100 || rs == 5'b00110 
                  || rs == 5'b01000
                  || rs == 5'b10000 || rs == 5'b10001 || rs == 5'b10100 
                ) begin 
                    is_reserve_inst <= 0;
                end else begin 
                    is_reserve_inst <= 1;
                end

            end

            if(op == 6'b010010) begin 
                if(rs == 5'b00000 || rs == 5'b00010 || rs == 5'b00100 || rs == 5'b00110 || rs == 5'b01000) begin 
                    is_reserve_inst <= 0;
                end else begin 
                    is_reserve_inst <= 1;               
                end

            end

            if(op == 6'b010011) begin 
                if(rs == 5'b00000 || rs == 5'b00010 || rs == 5'b00100 || rs == 5'b00110 || rs == 5'b01000) begin 
                    is_reserve_inst <= 0;
                end else begin 
                    is_reserve_inst <= 1;               
                end

            end

        end //if
    end //always

    always @ (*) begin
        stall_for_reg1_loadrelate<=`Disable;
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if (ex_inst_is_load==1'b1 && ex_wd_i==reg1_addr_o&& reg1_read_o==1'b1) begin
            stall_for_reg1_loadrelate<=`Enable;
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
        stall_for_reg2_loadrelate<=`Disable;
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if (ex_inst_is_load==1'b1 && ex_wd_i==reg2_addr_o&& reg1_read_o==1'b1) begin
            stall_for_reg2_loadrelate<=`Enable;
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

    always @ (*) begin
		if(rst == `RstEnable) begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end else begin
		  is_in_delayslot_o <= is_in_delayslot_i;
	  end
	end

    reg is_reserve_inst;



    always @ (*) begin
        if(rst == `RstEnable) begin 
            excp_type_o <= `ZeroWord;
            excp_inst_addr_o <= `ZeroWord;

        end else begin     
            excp_inst_addr_o <= pc_i;
            excp_type_o <= 32'h0000_0000;
            if(is_syscall_excp) begin
                excp_type_o[`EXCP_SYSCALL] <= 1;
            end
            if(is_eret_excp) begin
                excp_type_o[`EXCP_ERET] <= 1;
            end
            if(is_break_excp) begin
                excp_type_o[`EXCP_BREAK] <= 1;
            end
            
            if(pc_i[1:0] != 2'b00) begin 
                excp_type_o[`EXCP_BAD_PC_ADDR] <= 1;
            end

            if(is_reserve_inst == 1) begin
                excp_type_o[`EXCP_INVALID_INST] <= 1;
            end
        end
    end
    
    assign stallreq_o=stall_for_reg1_loadrelate|stall_for_reg2_loadrelate;



endmodule