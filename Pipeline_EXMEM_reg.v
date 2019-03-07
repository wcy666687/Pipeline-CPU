module Pipeline_EXMEM_reg(clk,reset,IDEX_AddrC,IDEX_MemToReg,IDEX_con,ALU_dataB,ALUOut,EXMEM_data,EXMEM_control);
input clk,reset;
input[4:0] IDEX_AddrC;//IDEX_data[4:0]
input[1:0] IDEX_MemToReg;//IDEX_control[7:6]
input[2:0] IDEX_con;//IDEX_control[13:11]
input[31:0] ALU_dataB,ALUOut;
output reg[68:0] EXMEM_data;
output reg [4:0]EXMEM_control;

always @(posedge clk or negedge reset)
begin
 if(!reset) begin
  EXMEM_data<=69'b0;
  EXMEM_control<=5'b0;
 end
 else begin
  EXMEM_data<={IDEX_AddrC,ALU_dataB,ALUOut};
  EXMEM_control<={IDEX_con,IDEX_MemToReg};
 end
end

endmodule
