module cpu_UART_S(clk,baud_rate_clk,reset,TX_EN,TX_DATA,TX_STATUS,UART_TX);
  input clk,baud_rate_clk,reset,TX_EN;
  input [7:0] TX_DATA;
  output reg TX_STATUS,UART_TX;
  reg enable;
  reg [7:0] count;
initial
begin
  TX_STATUS<=1;UART_TX<=1;
  enable<=0;count<=8'd0;
end
 always @(posedge clk,negedge reset)
  begin
    if(~reset)
      begin enable<=0;TX_STATUS<=1;end
  else if(TX_EN)
       begin enable<=1;TX_STATUS<=0;end
  else if(count==8'd160) begin enable<=0;TX_STATUS<=1;end
   end
always@(posedge baud_rate_clk,negedge reset)
begin
  if(~reset)
    begin
      count<=8'd0;UART_TX<=1;
    end
   else if(enable)
    begin
     case(count)
       8'd0: begin UART_TX<=0;count<=count+1;end
       8'd16:begin UART_TX<=TX_DATA[0];count<=count+1;end
       8'd32:begin UART_TX<=TX_DATA[1];count<=count+1;end
       8'd48:begin UART_TX<=TX_DATA[2];count<=count+1;end    
       8'd64:begin UART_TX<=TX_DATA[3];count<=count+1;end 
       8'd80:begin UART_TX<=TX_DATA[4];count<=count+1;end  
       8'd96:begin UART_TX<=TX_DATA[5];count<=count+1;end
       8'd112:begin UART_TX<=TX_DATA[6];count<=count+1;end
       8'd128:begin UART_TX<=TX_DATA[7];count<=count+1;end
       8'd144:begin UART_TX<=1;count<=count+1;end
       default: count<=count+1;
    endcase
   end
	else
	count<=8'd0;
end
endmodule


