module cpu_data_Memory(clk,reset,Addr,WriteData,MemRd,MemWr,ReadData,led,AN,
              digital,IRQ,UART_TXD,RX_DATA,TX_EN,TX_STATUS,RX_STATUS,An,Digital);
  input clk,reset,MemRd,MemWr,RX_STATUS,TX_STATUS;
  input[7:0] RX_DATA;//
  input[31:0] Addr,WriteData;//Addr ALU数据输出，WriteData写入数据
  output reg[31:0] ReadData;
  output reg[3:0] AN;
  output reg[7:0] digital,led,UART_TXD;
  output [7:0] An,Digital;
  output IRQ;//中断信号
  output reg TX_EN;
	reg[31:0] RAMDATA[255:0];
	reg[31:0] TH,TL;
	reg[15:0] cache;//
	reg[7:0] UART_RXD,temp;
	reg[4:0] UART_CON;
	reg[2:0] TCON;
	reg write,read;
	assign Digital=cache[15:8];
	assign An=cache[7:0];
	initial 
	 begin
	  TH<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
    TL<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
    TCON<=3'b000;
	  led<=8'b0;
	  AN<=4'b1111;
	  digital<=8'b11111111;
	  ReadData<=32'b0;
	  cache<=16'b0;
	  UART_RXD<=8'b0;
	  write<=1'b1;
	  read<=1'b0;
	  UART_CON<=5'b0;
	end
	assign IRQ=TCON[2]; //中断状态
always@(posedge RX_STATUS,negedge reset)
 begin 
 if(~reset) cache<=16'b0;
		else    if(write) begin cache[7:0]=RX_DATA;temp=RX_DATA; write<=1'b0; end
        else begin cache<={RX_DATA,cache[7:0]}; write<=1'b1; end
end  	
  always @(posedge clk,negedge reset) 
   begin
		if(~reset)
		 begin 
		  TH<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
      TL<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
      TCON<=3'b000;
      UART_CON<=5'b00000;
      TX_EN<=1'b0;
      
      UART_RXD<=8'b0;
		 end
		else
		 begin	
     	if(MemRd&&(Addr==32'h4000001c))
		  begin 
	     if(read) 
	      begin UART_RXD=cache[7:0]; read=1'b0;end
		   else 
		    begin UART_RXD=cache[15:8]; read=1'b1; end
	     end
	   if(MemWr)
	     begin
	     casez(Addr)
	     32'b0000_0000_0000_0000_0000_00??_????_??00: RAMDATA[Addr[31:2]]<=WriteData;
       32'h40000000: TH<=WriteData;
       32'h40000004: TL<=WriteData;
       32'h40000008: TCON<=WriteData[2:0];
       32'h4000000c: led<=WriteData[7:0]; 
       32'h40000014: begin AN<=WriteData[11:8]; digital<=WriteData[7:0];end 
       32'h40000018:	begin UART_TXD<=WriteData[7:0];if(TX_STATUS) TX_EN<=1'b1; end
       32'h40000020: UART_CON<=WriteData[4:0];
       default: ;
       endcase
      end                                                                                                                    
     if(TCON[0])
		    begin
		     if(TL==32'hffffffff) TL<=TH;
			   else TL<=TL+32'h00000001;
		    end
	   if(TCON[1]&&TCON[0]&&(TL==32'hffffffff)) TCON<=3'b111;
	end
end	     	
always @(*)
   begin
    if(~MemRd) ReadData=32'b0;
    else
     begin
      casez(Addr)
       32'b0000_0000_0000_0000_0000_00??_????_??00: ReadData<=RAMDATA[Addr[31:2]];
       32'b0100_0000_0000_0000_0000_0000_0000_0000: ReadData<=TH;
       32'b0100_0000_0000_0000_0000_0000_0000_0100: ReadData<=TL;
       32'b0100_0000_0000_0000_0000_0000_0000_1000: ReadData<={29'b0,TCON};
       32'b0100_0000_0000_0000_0000_0000_0000_1100: ReadData<={24'b0,led};
       32'b0100_0000_0000_0000_0000_0000_0001_0100: ReadData<={20'b0,AN,digital};
       32'b0100_0000_0000_0000_0000_0000_0001_1000: ReadData<={24'b0,UART_TXD};
       32'b0100_0000_0000_0000_0000_0000_0001_1100: ReadData<={24'b0,UART_RXD};
       32'b0100_0000_0000_0000_0000_0000_0010_0000: ReadData<={27'b0,UART_CON}; 
       default: ReadData<=32'b0;
      endcase
     end
   end
endmodule