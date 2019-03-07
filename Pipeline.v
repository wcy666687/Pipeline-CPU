module Pipeline(sysclk,reset,led,digi_out1,digi_out2,digi_out3,digi_out4,UART_RX,UART_TX);
  input sysclk,reset,UART_RX;
  output UART_TX;
  output[7:0] led;
  output [6:0] digi_out1,digi_out2,digi_out3,digi_out4;
  wire[7:0] An,Digital;
  
  Pipeline_total TOTAL(sysclk,reset,led,UART_TX,UART_RX,An,Digital);
  digitub_scan scan(An,Digital,digi_out1,digi_out2,digi_out3,digi_out4);
  
endmodule