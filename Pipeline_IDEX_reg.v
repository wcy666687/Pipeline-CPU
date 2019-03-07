module Pipeline_IDEX_reg(clk,reset,Stall,Rs,Rt,AddrC,Shamt,LUout,ConBA,DataBusA,DataBusB,
		ALUSrc1,ALUSrc2,PCSrc,ALUFun,Sign,MemWr,MemRd,RegWr,MemToReg,
		IDEX_data,IDEX_control);
input clk,reset,Stall,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,RegWr;
input [1:0] MemToReg; 
input[2:0] PCSrc;
input[4:0] Rs,Rt,Shamt,AddrC;
input[5:0] ALUFun;
input[31:0] LUout,ConBA,DataBusA,DataBusB;
output reg[148:0] IDEX_data;
output reg[17:0] IDEX_control;
 
always @(posedge clk or negedge reset) 
begin
   if(!reset) 
   begin//����IDEX_StallΪ1�����Ĵ�����Ҫ����
	IDEX_data<=148'b0;
	IDEX_control<=17'b0;
   end
	else if(Stall)begin
	IDEX_data<=148'b0;
	IDEX_control<=17'b0;
	end
   else 
   begin
	IDEX_data<={ConBA,LUout,DataBusB,DataBusA,Shamt,Rt,Rs,AddrC};
	IDEX_control<={ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,RegWr,PCSrc,MemToReg,ALUFun};
   end
end

endmodule
