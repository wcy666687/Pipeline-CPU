module Pipeline_IF_ID(clk,reset,nop,Stall,PCSrc,ALUOut0,JT,ConBA,DatabusA,IFID,PC31);
input clk,reset,nop,ALUOut0,Stall;
input[2:0] PCSrc;
input[25:0] JT;
input[31:0] DatabusA,ConBA;
output[63:0] IFID;
output PC31;
wire[31:0] PC,Ins;
assign PC31=PC[31];
Pipeline_PC IF_ID_PC(
       .nop(nop),
       .clk(clk),
       .reset(reset),
       .PCSrc(PCSrc),
       .ALUOut0(ALUOut0),
       .ConBA(ConBA),
       .JT(JT),
       .Databus_A(DatabusA),
       .PC(PC));

Pipeline_InsMem IF_ID_InsMem(
       .reset(reset),
       .nop(nop),
       .PC_82(PC[8:2]),
       .Ins(Ins));

Pipeline_IFID_reg IF_ID_reg(
       .clk(clk),
       .reset(reset),
       .nop(nop),
       .Stall(Stall),
       .PC(PC),
       .Ins(Ins),
       .IFID(IFID));

endmodule
