module Pipeline_PC(nop,clk,reset,PCSrc,ALUOut0,ConBA,JT,Databus_A,PC);
  input clk,reset,ALUOut0,nop;
  input [31:0]ConBA,Databus_A;
  input [2:0] PCSrc;
  input [25:0] JT;
  output reg [31:0]PC;
  wire [31:0] PC_Next;
  
  
assign PC_Next=nop?PC:{PC[31],PC[30:0]+31'b000_0000_0000_0000_0000_0000_0000_0100};
  parameter ILLOP_add=32'h80000004;
  parameter XADR_add=32'h80000008;
  initial
  begin PC=32'h80000000;end
  always @(posedge clk,negedge reset)
  if(~reset)
    begin  PC=32'h80000000; end
  else
  begin
    case(PCSrc)
    3'b000:PC<=PC_Next;
    3'b001:PC<=(ALUOut0==1'b1)? ConBA:PC_Next;
    3'b010:PC<={PC[31:28],JT,2'b00};
    3'b011:PC<=Databus_A;
    3'b100:PC<=ILLOP_add;
    3'b101:PC<=XADR_add;
    endcase
  end
endmodule
  

