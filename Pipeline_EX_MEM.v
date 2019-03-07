module Pipeline_EX_MEM(clk,reset,forwardA,forwardB,
                     EXMEM_Data,MEMWB_Data,IDEX_data,IDEX_control,EXMEM_data,EXMEM_control,
                     Zero,PCSrc,ConBA,Stall);
input clk,reset;
input[148:0] IDEX_data;
input[17:0] IDEX_control;
input[31:0] EXMEM_Data,MEMWB_Data;
input[1:0] forwardA,forwardB;
output [68:0] EXMEM_data;
output [4:0]EXMEM_control;
output[31:0] ConBA;
output[2:0] PCSrc;
output Zero,Stall;
  
reg[31:0] ALU_dataA,ALU_A,ALU_dataB,ALU_B;
wire[31:0] ALUOut;

always @(*)
begin
  if(forwardA==2'b00) ALU_dataA<=IDEX_data[51:20];//databusA
  else if(forwardA==2'b01) ALU_dataA<=MEMWB_Data;
  else if(forwardA==2'b10) ALU_dataA<=EXMEM_Data;
end

always @(*)
begin
    if(IDEX_control[16])//ALUSrc1
      ALU_A<={27'b0,IDEX_data[19:15]};//shamt
    else ALU_A<=ALU_dataA;      
end

//�ڶ�������������ѡһ��·ѡ�������Forwarding  
always @(*)
begin
   if(forwardB==2'b00) ALU_dataB<=IDEX_data[83:52];//databusB
   else if(forwardB==2'b01) ALU_dataB<=MEMWB_Data;
   else if(forwardB==2'b10) ALU_dataB<=EXMEM_Data;
end

//�ڶ�������������ѡһ��·ѡ����  
always @(*)
begin
    if(IDEX_control[15])//ALUSrc2
      ALU_B<=IDEX_data[115:84];//luout
     else ALU_B<=ALU_dataB;      
end

//ALU����
ALU EX_MEM_ALU(
        .A(ALU_A),
        .B(ALU_B),
        .ALUFun(IDEX_control[5:0]),
		  .Sign(IDEX_control[14]),
        .OUT(ALUOut));

//��ˮ�Ĵ���
Pipeline_EXMEM_reg EX_MEM_reg(
        .clk(clk),
        .reset(reset),
        .IDEX_AddrC(IDEX_data[4:0]),
        .IDEX_MemToReg(IDEX_control[7:6]),
				.IDEX_con(IDEX_control[13:11]),
				.ALU_dataB(ALU_dataB),
				.ALUOut(ALUOut),
				.EXMEM_data(EXMEM_data),
				.EXMEM_control(EXMEM_control));
  
assign Zero=ALUOut[0];
assign PCSrc=(IDEX_control[10:8]==3'b001)?3'b001:3'b0;
assign ConBA=IDEX_data[147:116];
assign Stall=Zero&(PCSrc==3'b001);

endmodule
