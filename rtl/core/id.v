// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : id.v
// Module Name  : id
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 
// Called By    :
// Description  : instruction decode
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-10   Deilt           1.0                     Original
//  
// *********************************************************************************
`include "defines.v"
module id(
    input                       clk             ,
    input                       rstn            ,
    //from if_id
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,
    //from regs
    output[`RegBus]             rs1_data_i      ,
    output[`RegBus]             rs2_data_i      ,
    //to regs
    output[`RegAddrBus]         rs1_addr_o      ,
    output[`RegAddrBus]         rs2_addr_o      ,
    //to id_ex
    output[`InstBus]            inst_o          ,
    output[`InstAddrBus]        instaddr_o      ,
    output[`RegBus]             op1_o           ,
    output[`RegBus]             op2_o           ,
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       
);

    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];
    wire [4:0]  rs1    = inst_i[19:15];
    wire [4:0]  rs2    = inst_i[24:20]; //rs2 or shamt,they'r equal
    //wire [4:0]  shamt  = inst_i[24:20]; //rs2 or shamt,they'r equal
    wire [4:0]  rd     = inst_i[11:7];
    wire [11:0] imm    = inst_i[31:20];
    wire [31:0] sign_expd_imm = {{20{inst_i[31]}},inst_i[31:20]};
    wire [6:0]  funct7 = inst_i[31:25];

    reg [`InstBus]              inst_o;
    reg [`InstAddrBus]          instaddr_o;
    reg [`RegAddrBus]           rs1_addr_o;
    reg [`RegAddrBus]           rs2_addr_o;
    reg [`RegBus]               op1_o;
    reg [`RegBus]               op2_o;
    reg                         regs_wen_o;
    reg [`RegAddrBus]           rd_addr_o;

    //decode
    always @(*)begin
        inst_o = inst_i;
        instaddr_o = instaddr_i;
        rs1_addr_o = `ZeroRegAddr;
        rs2_addr_o = `ZeroRegAddr;

        op1_o = `ZeroWord;
        op2_o = `ZeroWord;
        regs_wen_o = `WriteDisable;
        rd_addr_o = `ZeroReg;

        case(opcode)
            `INST_TYPE_I:begin
                case(funct3)
                    `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI:begin
                        rs1_addr_o = rs1;
                        //rs2_addr_o = `ZeroRegAddr;
                        op1_o = rs1_data_i ;
                        op2_o = sign_expd_imm;
                        regs_wen_o = `WriteEnable;
                        rd_addr_o = rd;
                    end
                    `INST_SLLI,`INST_SRLI,`INST_SRAI:begin
                        rs1_addr_o = rs1;
                        //rs2_addr_o = `ZeroRegAddr;
                        op1_o = rs1_data_i ;
                        op2_o = {{27'h0},rs2}; //(shamt) shamt = rs2
                        regs_wen_o = `WriteEnable;
                        rd_addr_o = rd;
                    end
                endcase
            end
            default:begin
                rs1_addr_o = `ZeroRegAddr;
                rs2_addr_o = `ZeroRegAddr;
                op1_o = `ZeroWord ;
                op2_o =  `ZeroWord;
                regs_wen_o = `WriteDisable;    
            end
        endcase
    end








endmodule