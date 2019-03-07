module cpu_baudrate(sysclk,reset,baud_rate_clk);
input sysclk,reset;
output reg baud_rate_clk;
reg [8:0] count;
initial
begin 
  count<=0;
  baud_rate_clk<=0;
end
always @(posedge sysclk, negedge reset)
begin 
  if(~reset) 
  begin count<=0; baud_rate_clk<=0; end
  else 
  begin 
  if(count==9'd163)  
 begin count<=0; baud_rate_clk<=~baud_rate_clk;end
  else
  count=count+9'd1; 
  end
end
endmodule
