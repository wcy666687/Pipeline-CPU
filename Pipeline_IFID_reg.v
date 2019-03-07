module Pipeline_IFID_reg(clk,reset,nop,Stall,PC,Ins,IFID);
input clk,reset,nop,Stall;
input[31:0] PC,Ins;
output reg[63:0] IFID;

wire[63:0] IFID_stop;
assign IFID_stop=nop? IFID:{Ins,PC};
  
always @(posedge clk or negedge reset)
begin
  if(!reset) IFID<=64'b0;
  else IFID<=Stall? 64'b0:IFID_stop;
end    

endmodule
