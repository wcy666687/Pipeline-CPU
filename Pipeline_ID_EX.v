module Pipeline_ID_EX(PC31,clk,reset,IRQ,IDEX_Stall,Stall_one,IFID,MEMWB_data,MEMWB_RegWr,
                         MEMWB_MemToReg,Rt,Rs,PCSrc,JT,DataBusA,DataBusC,IDEX_data,IDEX_control);
input[63:0] IFID;
input[68:0] MEMWB_data;
input MEMWB_RegWr,PC31;
input [1:0]MEMWB_MemToReg;
input clk,reset,IRQ,IDEX_Stall;
output[148:0] IDEX_data;
output[17:0] IDEX_control;
output[31:0] DataBusA,DataBusC;
output[25:0] JT;
output[4:0] Rt,Rs;
output[2:0] PCSrc;
output Stall_one;

wire[31:0] Ins,PC,DataBusB,Imm32,ALUA,LUout,ConBA;
wire[15:0] Imm16;
wire[5:0] ALUFun;
wire[4:0] Rd,AddrC,Shamt;
wire[1:0] RegDst, MemToReg;
wire RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;

//控制信号产生  
cpu_Ctrl ID_EX_Control(.PC31(PC31),
                  .Instruct(IFID[63:32]),
                  .PC(IFID[31:0]),
                  .IRQ(IRQ),
                  .JT(JT),
                  .Imm16(Imm16),
                  .shamt(Shamt),
                  .Rd(Rd),
                  .Rt(Rt),
                  .Rs(Rs),
                  .ALUFun(ALUFun),
                 	.PCSrc(PCSrc),
                 	.RegDst(RegDst),
                 	.MemToReg(MemToReg),
                 	.RegWr(RegWr),
                 	.ALUSrc1(ALUSrc1),
                 	.ALUSrc2(ALUSrc2),
                 	.Sign(Sign),
                 	.MemWr(MemWr),
                 	.MemRd(MemRd),
                 	.EXTOp(EXTOp),
                 	.LUOp(LUOp));

assign DataBusC=MEMWB_MemToReg[0]?MEMWB_data[63:32]:MEMWB_data[31:0];//产生寄存器写入信号

//寄存器的写入
cpu_Reg ID_EX_Register(
                 .clk(clk),
                 .reset(reset),
                 .IRQ(IRQ),
                 .RegWr(MEMWB_RegWr),
                 .MemToReg1(MemToReg[1]),
				         .AddrA(Rs),
				         .AddrB(Rt),
				         .AddrC(MEMWB_data[68:64]),
				         .WriteDataC(DataBusC),
				         .PC(IFID[31:0]),
       	  		     .ReadDataA(DataBusA),
       	  		     .ReadDataB(DataBusB));

assign Imm32=EXTOp?{{16{Imm16[15]}},Imm16}:{16'h0000,Imm16};//符号位扩展
assign LUout=LUOp?{Imm16,16'b0}:Imm32;//是否载入高位
assign AddrC=(RegDst==0)?Rd:(RegDst==1)?Rt:(RegDst==2)?5'b1_1111:5'b1_1010;//写入位置
assign ConBA={IFID[31],{IFID[30:0]+31'd4+{Imm32[28:0],2'b00}}};//分支位置

//流水寄存器
Pipeline_IDEX_reg ID_EX_reg(
              .clk(clk),
              .reset(reset),
              .Stall(IDEX_Stall),
              .Rs(Rs),
              .Rt(Rt),
              .AddrC(AddrC),
              .Shamt(Shamt),
			        .LUout(LUout),
			        .ConBA(ConBA),
			        .DataBusA(DataBusA),
			        .DataBusB(DataBusB),
			        .ALUSrc1(ALUSrc1),
			        .ALUSrc2(ALUSrc2),
			        .PCSrc(PCSrc),
			        .ALUFun(ALUFun),
			        .Sign(Sign),
			        .MemWr(MemWr),
			        .MemRd(MemRd),
			        .RegWr(RegWr),
			        .MemToReg(MemToReg),
			        .IDEX_data(IDEX_data),
			        .IDEX_control(IDEX_control));

assign Stall_one=((PCSrc[2:1]==2'b10)||(PCSrc[2:1]==2'b01));//表示为跳转指令或者外设

endmodule
