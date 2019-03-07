module ALU(A,B,ALUFun,Sign,OUT);
	input [31:0]A;
	input [31:0]B;
	input [5:0]ALUFun;
	input Sign;
	output wire[31:0]OUT;
  wire Z;
	wire V;
	wire N;
	wire [31:0]A,B,ADDOUT,SUBOUT,LOGICOUT,ShiftOUT,CMPOUT,ADDV,SUBV,LOGICV,CMPV,ShiftV;
	wire sign;
	
	ADD uadd(.ADDA(A),.ADDB(B),.ADDOUT(ADDOUT),.ADDV(ADDV),.Sign(Sign));
	SUB usub(.SUBA(A),.SUBB(B),.SUBOUT(SUBOUT),.SUBV(SUBV),.Sign(Sign));
	LOGIC ulogic(.LOGICA(A),.LOGICB(B),.LOGICOUT(LOGICOUT),.LOGICV(LOGICV),.ALUFun(ALUFun[3:0]));
	CMP ucmp(.CMPA(A),.CMPB(B),.CMPOUT(CMPOUT),.Sign(Sign),.V(CMPV),.Z(Z),.N(N),.ALUFun(ALUFun[3:1]));
	Shift ushift(.ShiftA(A),.ShiftB(B),.ShiftOUT(ShiftOUT),.ALUFun(ALUFun[1:0]),.ShiftV(ShiftV));
	assign Z = (OUT==32'd0);
	assign N = (Sign==1&&OUT[31]==1);
	assign OUT=(ALUFun==6'b000000)?ADDOUT:
			   (ALUFun==6'b000001)?SUBOUT:
			   (ALUFun[5:4]==2'b01)?LOGICOUT:
			   (ALUFun[5:4]==2'b11)?CMPOUT:
			   (ALUFun[5:4]==2'b10)?ShiftOUT:
			   32'd0;
	assign V=(ALUFun==6'b000000)?ADDV:
			 (ALUFun==6'b000001)?SUBV:
			 (ALUFun[5:4]==2'b01)?LOGICV:
			 (ALUFun[5:4]==2'b11)?CMPV:
			 (ALUFun[5:4]==2'b10)?ShiftV:
			 0;
endmodule

module ADD(ADDA,ADDB,ADDOUT,ADDV,Sign);
	input [31:0]ADDA,ADDB;
	input Sign;
	output [31:0]ADDOUT;
	output ADDV;
	assign ADDOUT = ADDA+ADDB;
	assign ADDV = (ADDA[31]==ADDB[31]&&ADDA[31]!=ADDOUT[31])||((~Sign)&&(ADDA[31]||ADDB[31])&&(~ADDOUT[31]));//Overflow: Both A and B are positive but OUT is negative;or A B neg but OUT pos
endmodule

module SUB(SUBA,SUBB,SUBOUT,SUBV,Sign);
	input[31:0]SUBA,SUBB;
	input Sign;
	output [31:0]SUBOUT;
	wire [31:0]SUBA;
	wire [31:0]ADDB;
	output SUBV;
	assign ADDB=~SUBB+1;
	ADD uadd(.ADDA(SUBA),.ADDB(ADDB),.ADDOUT(SUBOUT),.ADDV(SUBV),.Sign(Sign));
endmodule

module LOGIC(LOGICA,LOGICB,LOGICOUT,LOGICV,ALUFun);
	input[31:0] LOGICA,LOGICB;
	input[3:0]ALUFun;
	output[31:0]LOGICOUT;
	output LOGICV;
	assign LOGICOUT =(ALUFun==4'b1000)?LOGICA&LOGICB:
					 (ALUFun==4'b1110)?LOGICA|LOGICB:
					 (ALUFun==4'b0110)?LOGICA^LOGICB:
					 (ALUFun==4'b0001)?~(LOGICA|LOGICB):
					 (ALUFun==4'b1010)?LOGICA:
					 32'd0;
	assign LOGICV=0;
endmodule

module CMP(CMPA,CMPB,CMPOUT,Sign,V,Z,N,ALUFun);
	input[31:0] CMPA,CMPB;
	input[2:0]ALUFun;
	input Sign,Z,N;
	output[31:0] CMPOUT;
	output wire V;
	//SUB sub1(.SUBA(CMPA),.SUBB(CMPB),.SUBV(V),.Sign(Sign));
	assign CMPOUT=(ALUFun==3'b001)?(CMPA==CMPB):
				  (ALUFun==3'b000)?(CMPA!=CMPB):
				  (ALUFun==3'b010)?(CMPA<CMPB)||(Sign&&(CMPA[31]==1&&CMPB[31]==0)):
				  (ALUFun==3'b110)?((Sign&&CMPA[31]==1)||CMPA==32'd0):
				  (ALUFun==3'b101)?(Sign&&CMPA[31]==1):
				  (ALUFun==3'b111)?((Sign&&CMPA[31]==0)||(~Sign&&CMPA!=32'd0)):
				  32'd0;
endmodule

module Shift(ShiftA,ShiftB,ShiftOUT,ALUFun,ShiftV);
	input[31:0] ShiftA,ShiftB;
	input[1:0]ALUFun;
	output[31:0] ShiftOUT;
	output ShiftV;
	assign ShiftOUT=(ALUFun==2'b00)?ShiftB<<ShiftA[4:0]:
					(ALUFun==2'b01)?ShiftB>>ShiftA[4:0]:
					(ALUFun==2'b11)?({{32{ShiftB[31]}},ShiftB} >> ShiftA[4:0]):
					32'd0;
	assign ShiftV=0;
endmodule
