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
    output reg wreg_o
);
    //wire[5:0] op = inst_i[31:26];
    //wire[4:0] op2 = inst_i[10:6];
    //wire[5:0] op3 = inst_i[5:0];
    //wire[4:0] op4 = inst_i[20:16];
    wire[5:0] op = inst_i[31:26];
    wire[4:0] rs = inst_i[25:21];
    wire[4:0] rt = inst_i[20:16];
    wire[4:0] rd = inst_i[15:11];
    wire[4:0] sa = inst_i[10:6];
    wire[5:0] fn = inst_i[5:0];
    wire[25:0] target = ins_i[25:0];
    wire[15:0] imm = ins_i[15:0];// 

    reg[`RegBus] eimm;
    reg instvalid;

    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
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
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o <= inst_i[15:11];
            wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            eimm <= `ZeroWord;
            case (op)
                //TODO: add first special instruction
                `EXE_SPECIAL_OP: begin
                    wreg_o <= `WriteEnable;
                    wd_o <= `rt;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    reg2_o<=reg2_data_i;
                    // add case ....
                end
                `EXE_ORI: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_OR_OP;
                    alusel_o <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    eimm <= {16'h0, imm};
                    wd_o <= inst_i[20:16];
                    instvalid <= `InstValid;
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
