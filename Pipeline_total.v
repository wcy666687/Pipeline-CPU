module Pipeline_total(clk_sys,reset,led,UART_TX,UART_RX,An,Digital);  
input clk_sys,reset,UART_RX;
output UART_TX;

output[7:0] led,An,Digital;


wire [63:0] IFID;
wire [148:0] IDEX_data;
wire [17:0] IDEX_control;
wire [68:0] EXMEM_data;
wire [4:0]EXMEM_control;
wire [68:0] MEMWB_data;
wire MEMWB_RegWr;
wire [1:0]MEMWB_MemToReg;
wire [3:0]AN;
wire [7:0]digi;
 
wire Zero,IRQ,nop,IFID_Stall,Stall_one,Stall,IDEX_Stall,TX_EN,TX_STATUS,RX_STATUS,clk_UART,PC31;
wire [1:0] forwardA,forwardB;
wire [2:0] ID_PCSrc,EX_PCSrc,PCSrc;
wire [4:0] Rs,Rt;
wire [7:0] TX_DATA,RX_DATA;	
wire [25:0] JT;
wire [31:0] ConBA,DataBusA,DataBusC;
wire clk;
cpu_baudrate brclk(clk_sys,reset,clk_UART);
cpu_clk clock(clk_sys,reset,clk);
cpu_UART_R uartr(clk_sys,clk_UART,reset,UART_RX,RX_STATUS,RX_DATA);
cpu_UART_S uartt(clk_sys,clk_UART,reset,TX_EN,TX_DATA,TX_STATUS,UART_TX );

//IFID={[63:32]ins,[31:0]PC}
 
assign PCSrc=(ID_PCSrc==3'b001||EX_PCSrc == 3'b001)? EX_PCSrc: ID_PCSrc;
assign IFID_Stall=Stall_one|Stall; 
Pipeline_IF_ID total_IF_ID(
         .clk(clk),
         .reset(reset),
         .nop(nop),
         .Stall(IFID_Stall),
         .PCSrc(PCSrc),
         .ALUOut0(Zero),
				 .JT(JT),
				 .ConBA(ConBA),
				 .DatabusA(DataBusA),
				 .IFID(IFID),
				 .PC31(PC31));

//IDEX_data={[147:116]ConBA,[115:84]LUout,[83:52]DataBusB,[51:20]DataBusA,[19:15]Shamt,[14:10]Rt,[9:5]Rs,[4:0]AddrC}
//IDEX_control<={[16]ALUSrc1,[15]ALuSrc2,[14]Sign,[13]MemWr,[12]MemRd,[11]RegWr,[10:8]PCSrc,[7:6]MemToReg,[5:0]ALUFun};
 
assign IDEX_Stall=nop|Stall;
Pipeline_ID_EX total_WB_ID_EX(
         .PC31(PC31),
         .clk(clk),
         .reset(reset),
         .IRQ(IRQ),
         .IDEX_Stall(IDEX_Stall),
				 .Stall_one(Stall_one),
				 .IFID(IFID),
				 .MEMWB_data(MEMWB_data),
				 .MEMWB_RegWr(MEMWB_RegWr),
				 .MEMWB_MemToReg(MEMWB_MemToReg),
				 .Rt(Rt),
				 .Rs(Rs),
				 .PCSrc(ID_PCSrc),
				 .JT(JT),
				 .DataBusA(DataBusA),
				 .DataBusC(DataBusC),
				 .IDEX_data(IDEX_data),
				 .IDEX_control(IDEX_control));
//EXMEM_data<={[68:64]AddrC,[63:32]ALU_dataB,[31:0]ALUOut};
//EXMEM_control<={[4]MemWr,[3]MemRd,[2]RegWr,[1:0]MemToReg};

Pipeline_EX_MEM total_EX_MEM(
         .clk(clk),
         .reset(reset),
         .forwardA(forwardA),
         .forwardB(forwardB),
         .EXMEM_Data(EXMEM_data[31:0]),
			   .MEMWB_Data(DataBusC),
			   .IDEX_data(IDEX_data),
			   .IDEX_control(IDEX_control),
			   .EXMEM_data(EXMEM_data),
			   .EXMEM_control(EXMEM_control),
			   .Zero(Zero),
			   .PCSrc(EX_PCSrc),
			   .ConBA(ConBA),
			   .Stall(Stall));


//MEMWB_data<={[68:64]EXMEM_AddrC,[63:32]ReadData,[31:0]EXMEM_ALUOut};  
Pipeline_MEM_WB total_MEM_WB(
         .clk(clk),
         .reset(reset),
         .led(led),
         .AN(AN),
         .digi(digi),
         .IRQ(IRQ),
         .EXMEM_data(EXMEM_data),
				 .EXMEM_control(EXMEM_control),
				 .MEMWB_data(MEMWB_data),
				 .MEMWB_RegWr(MEMWB_RegWr),
				 .MEMWB_MemToReg(MEMWB_MemToReg),
				 .UART_TXD(TX_DATA),
				 .RX_DATA(RX_DATA),
				 .TX_EN(TX_EN),
				 .TX_STATUS(TX_STATUS),
				 .RX_STATUS(RX_STATUS),
				 .An(An),
				 .Digital(Digital));

Pipeline_Forwarding total_Forwarding(
          .EXMEM_RegWr(EXMEM_control[2]),
          .MEMWB_RegWr(MEMWB_RegWr),
          .EXMEM_Rd(EXMEM_data[68:64]),
					.MEMWB_Rd(MEMWB_data[68:64]),
					.IDEX_Rs(IDEX_data[9:5]),
					.IDEX_Rt(IDEX_data[14:10]),
					.forwardA(forwardA),
					.forwardB(forwardB));

Pipeline_Hazard total_Hazard(
          .IDEX_MemRd(IDEX_control[12]),
          .IDEX_Rt(IDEX_data[14:10]),
          .IFID_Rs(Rs),
          .IFID_Rt(Rt),
          .nop(nop));

endmodule