module cpu_Reg(clk,reset,IRQ,RegWr,MemToReg1,AddrA,AddrB,AddrC,WriteDataC,PC,ReadDataA,ReadDataB);
input clk,reset,RegWr,IRQ,MemToReg1;
input[4:0] AddrA,AddrB,AddrC;
input[31:0] WriteDataC,PC;
output[31:0] ReadDataA,ReadDataB;

wire enable;
wire[4:0] address;
reg[31:0] Reg[31:1]; //�洢ָ�������
reg [5:0]i;//����ֵ��ʱ���õ�

assign ReadDataA=(AddrA==5'b0)? 32'b0:Reg[AddrA]; //0�żĴ�������Ϊ0����ͬ
assign ReadDataB=(AddrB==5'b0)? 32'b0:Reg[AddrB];  
assign enable=~PC[31]&(IRQ|MemToReg1);//�жϻ����쳣���о�
assign address=MemToReg1? 5'b11010:5'b11111;//�ж˻����쳣��26:31

initial  for(i=0;i<31;i=i+1) Reg[i+1]=32'b0; 
  
always @(posedge clk or negedge reset)
 begin
  if(!reset) for(i=0;i<31;i=i+1) Reg[i+1]=32'b0; 
  else
   begin 
     if(RegWr&&AddrC) Reg[AddrC]<=WriteDataC;
     if(enable&&(AddrC!=address)) Reg[address]<=PC+4;//�жϻ����쳣
    end
  end

endmodule


