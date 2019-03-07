module Pipeline_MEM_WB(clk,reset,led,AN,digi,IRQ,EXMEM_data,EXMEM_control,
                       MEMWB_data,MEMWB_RegWr,MEMWB_MemToReg,UART_TXD,RX_DATA,TX_EN,TX_STATUS,RX_STATUS,An,Digital);
input clk,reset,TX_STATUS,RX_STATUS;
input [4:0]EXMEM_control;
input [7:0] RX_DATA;
input [68:0] EXMEM_data;
output [68:0] MEMWB_data;
output [7:0] digi,led,UART_TXD,An,Digital;
output [3:0] AN;
output [1:0]MEMWB_MemToReg;
output IRQ,TX_EN,MEMWB_RegWr;
wire[31:0] ReadData;

//数据存储器部分
cpu_data_Memory MEM_WB_RAM(
         .clk(clk),
         .reset(reset),
         .Addr(EXMEM_data[31:0]),
         .WriteData(EXMEM_data[63:32]),
         .MemRd(EXMEM_control[3]),
	       .MemWr(EXMEM_control[4]),
	       .ReadData(ReadData),
	       .led(led),
	       .AN(AN),
	       .digital(digi),
	       .IRQ(IRQ),
	       .UART_TXD(UART_TXD),
         .RX_DATA(RX_DATA),
         .TX_EN(TX_EN),
         .TX_STATUS(TX_STATUS),
         .RX_STATUS(RX_STATUS),
			.An(An),
			.Digital(Digital));

//流水寄存器部分
Pipeline_MEMWB_reg EXE_WB_reg(
         .clk(clk),
         .reset(reset),
         .ReadData(ReadData),
         .EXMEM_ALUOut(EXMEM_data[31:0]),
				 .EXMEM_AddrC(EXMEM_data[68:64]),
				 .EXMEM_con(EXMEM_control[2:0]),
				 .MEMWB_data(MEMWB_data),
				 .MEMWB_RegWr(MEMWB_RegWr),
				 .MEMWB_MemToReg(MEMWB_MemToReg));

endmodule
