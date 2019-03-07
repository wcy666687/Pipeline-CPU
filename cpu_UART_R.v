module cpu_UART_R(clk,baud_rate_clk,reset,UART_RX,RX_STATUS,RX_DATA);
  input clk,baud_rate_clk, reset, UART_RX;
  output reg RX_STATUS;
  output reg[7:0] RX_DATA;
  reg  pre,enable;
  reg [7:0] count;
initial 
begin 
RX_DATA=8'b0;RX_STATUS=0;  
pre=0;enable=0;count=8'b0;
end
always @(posedge clk,negedge reset)
begin
 if(~reset) enable<=1'b0;
   else 
begin 
	pre<=UART_RX;
   if(pre==1&&UART_RX==0) enable<=1'b1;
   else if(count==8'd152) enable<=1'b0;//
end
end

always @(posedge baud_rate_clk,negedge reset)
 begin
   if(~reset) 
   begin count<=8'd0; RX_STATUS<=1'b0; end
   else if(enable)
     begin 
       case(count)
     8'd24: begin RX_DATA[0]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd40: begin RX_DATA[1]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd56: begin RX_DATA[2]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd72: begin RX_DATA[3]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd88: begin RX_DATA[4]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd104: begin RX_DATA[5]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd120: begin RX_DATA[6]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     8'd136: begin RX_DATA[7]<=UART_RX; RX_STATUS<=0;count<=count+1;end
     default: begin count<=count+1;RX_STATUS<=0;end
     endcase
    end
    else if(count==8'd152)
      begin
        RX_STATUS<=1;count<=8'd0;
      end
    else  RX_STATUS<=0;
 end
endmodule

