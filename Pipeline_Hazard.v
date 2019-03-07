module Pipeline_Hazard(IDEX_MemRd,IDEX_Rt,IFID_Rs,IFID_Rt,nop);
input IDEX_MemRd;
input[4:0] IDEX_Rt,IFID_Rs,IFID_Rt;
output reg nop;

always @(*)
begin
if(IDEX_MemRd&((IDEX_Rt==IFID_Rs)|(IDEX_Rt==IFID_Rt)))   nop<=1; //´æÔÚload-useÃ°ÏÕ
else nop<=0;
end

endmodule
