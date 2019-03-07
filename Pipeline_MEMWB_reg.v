module Pipeline_MEMWB_reg(clk,reset,ReadData,EXMEM_ALUOut,EXMEM_AddrC,EXMEM_con,MEMWB_data,MEMWB_RegWr,MEMWB_MemToReg);
input clk,reset;
input[31:0] ReadData,EXMEM_ALUOut; //EXMEM_data[31:0]
input [4:0]EXMEM_AddrC;//EXMEM_data[68:64]
input [2:0]EXMEM_con;
output reg[68:0] MEMWB_data;
output reg [1:0]MEMWB_MemToReg;
output reg MEMWB_RegWr;

always @(posedge clk or negedge reset)
 begin
  if(!reset)
   begin
	MEMWB_data<=68'b0;
	MEMWB_MemToReg<=2'b0;
	MEMWB_RegWr<=1'b0;
   end
  else
   begin
 	MEMWB_data<={EXMEM_AddrC,ReadData,EXMEM_ALUOut};
	MEMWB_MemToReg<=EXMEM_con[1:0];
	MEMWB_RegWr<=EXMEM_con[2];
	 end
 end

endmodule
