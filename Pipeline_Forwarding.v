module Pipeline_Forwarding(EXMEM_RegWr,MEMWB_RegWr,EXMEM_Rd,MEMWB_Rd,IDEX_Rs,IDEX_Rt,forwardA,forwardB);
input EXMEM_RegWr,MEMWB_RegWr;
input[4:0] EXMEM_Rd,MEMWB_Rd,IDEX_Rs,IDEX_Rt; 
output reg[1:0] forwardA;
output reg[1:0] forwardB;

//对于forwardA  
always @(*)
begin
   if((EXMEM_RegWr)&&(|EXMEM_Rd)&&(EXMEM_Rd==IDEX_Rs)) //EX/MEM Hazard
       forwardA<=2'b10;
   else if((MEMWB_RegWr)&&(|MEMWB_Rd)&&((|EXMEM_RegWr)||(EXMEM_Rd!=IDEX_Rs))&&(MEMWB_Rd==IDEX_Rs)) //MEM/WB Hazard.
       forwardA<=2'b01; 
   else forwardA<=2'b0;
end

//对于forwardB
always @(*)
begin
  if((EXMEM_RegWr)&&(|EXMEM_Rd)&&(EXMEM_Rd==IDEX_Rt))  //EX/MEM Hazard
      forwardB<=2'b10;
  else if((MEMWB_RegWr)&&(|MEMWB_Rd)&&((|EXMEM_RegWr)||(EXMEM_Rd!=IDEX_Rt))&&(MEMWB_Rd==IDEX_Rt))  //MEM/WB Hazard.
        forwardB<=2'b01;
  else forwardB<=2'b0;   
end

endmodule
