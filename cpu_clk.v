module cpu_clk(system_clk,reset,clk);
input system_clk,reset;
output reg clk;
reg [4:0] count;
initial 
 begin
  count<=5'b0;
  clk<=1'b1;
 end
always @(posedge system_clk or negedge reset) 
 begin
  if(~reset)
   begin
    count<=5'b0;
    clk<=1'b1;
   end
  else
   begin
    if(count==5'b10000)
     begin 
	    clk<=~clk; 
	    count<=5'b0;
	   end
    else
     begin
      count<=count+1; 
     end
   end
 end
endmodule
