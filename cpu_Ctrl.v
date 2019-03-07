module cpu_Ctrl(PC31,Instruct,PC,IRQ,JT,Imm16,shamt,Rd,Rt,Rs,ALUFun,PCSrc,RegDst,MemToReg,
                RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp);               
  input[31:0] Instruct;
  input [31:0]PC;
  input IRQ,PC31;
  output[2:0] PCSrc;
  output[1:0] RegDst, MemToReg;
  output[5:0] ALUFun;
  output RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;
  output[4:0]  Rs, Rt, Rd,shamt;
  output[15:0] Imm16;
  output[25:0] JT;
  wire R,I,J,nop,branch,cmp,wrong_Instruct,ILLOP,XADR;
  wire[5:0] Op, Funct;
  cpu_I_data T(Instruct,Rs,Rt,Rd,JT,Imm16,shamt,Op,Funct);
	Type_check Check(Instruct,R,I,J,Jr,nop,branch,cmp,wrong_Instruct);// instruct type
  assign ILLOP=~PC31&IRQ;
  assign XADR=~PC[31]&wrong_Instruct;//PC[31]=0,wrong enable
  //insruct control
  // PCSrc:000->PC+4 001->branch 010->J 011->Jr 100->ILLOP 101->XADR
  assign PCSrc[0]=(Jr|branch|XADR)&~ILLOP;
  assign PCSrc[1]=(Jr|J)&~ILLOP;
  assign PCSrc[2]=XADR|ILLOP;
  //RegDst:00->R; 01->I; 10:Jal/Jalr; 11->XADR;
  assign RegDst[0]=I|wrong_Instruct;
  assign RegDst[1]=(J&(Op==6'b000011))|wrong_Instruct;
  //RegWr:R/jr&I/branch/sw&Jal
  assign RegWr=(R&(Op!=6'b001000))|(I&~branch&~MemWr)|(J&Op[0])|XADR;
  //ALUSrc1: sll,srl,sra
  assign ALUSrc1=R&(Funct==6'b000000|Funct==6'b000010|Funct==6'b000011);
  //AlUSrc2:I/branch
  assign ALUSrc2=I&~branch;  
  //ALUfun[5:4]: 00->adder; 01->logic; 10->shift; 11->compare;
  assign ALUFun[5]= ALUSrc1|branch|cmp; //shift,branch,cmp               
  assign ALUFun[4]=(R&Funct[2])|branch|cmp|(I&Op==6'b001100); //logic,compare,andi
  assign ALUFun[3]=(R&(Funct[3:1]==3'b010))|(branch&(Op[1]|Op==6'b000001))|(Op==6'b001100); //and,or,bgtz,blez,bltz,andi
  assign ALUFun[2]=(R&Funct[2]&(Funct[1]^Funct[0]))|((branch|cmp)&(Op[2:1]!=2'b10));//or,xor,bgtz,blez,bltz,slt,slti,sltiu
  assign ALUFun[1]=(R&Funct[2]&(Funct[1]^Funct[0]))|(R&Funct[0]&~Funct[5])|(branch&((Op[2:0]==3'b100)|(Op[2:0]==3'b111))); //or,xor,sra,jalr,beq,bgtz
  assign ALUFun[0]=(R&Funct[1]&(~Funct[2]|Funct[0]))|branch|cmp; //sub,subi,nor,srl,sra,slt,
                                                                           //beq,bne,blez,bgtz,bltz,slt,slti,sltiu                               
  assign Sign=((R&~(Funct==6'b100001|Funct==6'b100101|Funct==6'b101011))|(I&~(Op==6'b001001|Op==6'b001011))|J|nop); //addu,subu,sltu,addiu,sltiu
  assign MemRd=(Op==6'b100011); //lw
  assign MemWr=(Op==6'b101011);  //sw
  //MemToReg: 00->ALU; 01->Load; 10: jal,jalr,XADR;
  assign MemToReg[0]=MemRd;  
  assign MemToReg[1]=((J&Op==6'b000011)|(Jr&Funct==6'b001001)|XADR); 
  assign EXTOp=Sign;
  assign LUOp=(I&(Op==6'b001111)); //lui
endmodule

module Type_check(Instruct,R,I,J,Jr,nop,branch,cmp,wrong_Instruct);//??????
  input [31:0]Instruct;
  output R,I,J,nop,Jr,branch,cmp,wrong_Instruct;
  wire[5:0] Op, Funct;
  wire[4:0]  Rs, Rt, Rd,shamt;
  wire[15:0] Imm16;
  wire[25:0] JT;
  cpu_I_data T(Instruct,Rs,Rt,Rd,JT,Imm16,shamt,Op,Funct);
  
  assign nop=(Instruct==32'b0);
  assign R=(~nop)&(Op==6'b0)&(
         (shamt==5'b0&(Funct[5:3]==3'b100|Funct[5:1]==5'b10101))//add,addu,sub,subu,and,or,xor,nor,slt,sltu
         |(Funct==6'b000000|Funct==6'b000010|Funct==6'b000011)//sll,srl,sra 
         |(Rt==5'b0&Rd==5'b0&shamt==5'b0&Funct==6'b001000)//jr
         |(Rt==5'b0&shamt==5'b0&Funct==6'b001001));//jalr
         
  assign I=((Rs==5'b0&&Op==6'b001111) //lui
            |(Op==6'b001000|Op==6'b001001|Op==6'b001010|Op==6'b001011|Op==6'b001100)//addi,addiu,andi,slti,sltiu
            |(Op==6'b100011|Op==6'b101011) //lw,sw
            |(Op==6'b000100|Op==6'b000101)//beq,bne
            |((Rt==5'b0)&(Op==6'b000111|Op==6'b000110|Op==6'b000001)));//bgtz,blez,bltz
            
  assign J=(Op[5:1]==5'b00001);////j,jal
  
  assign branch=(Op==6'b000100|Op==6'b000101)|//beq,bne
         ((Rt==5'b0)&(Op==6'b000111|Op==6'b000110|Op==6'b000001));//bgtz,blez,bltz
         
  assign Jr=((Op==6'b000000&Rt==5'b0&Rd==5'b0&shamt==5'b0&Funct==6'b001000)//jr
         |(Op==6'b000000&Rt==5'b0&shamt==5'b0&Funct==6'b001001));//jalr
         
  assign wrong_Instruct =~(R |I |J |nop);
  
  assign cmp=(R&Funct[5:1]==5'b10101)|(I&Op[5:1]==5'b00101);  //slt,slti,sltiu,sltu
endmodule

module cpu_I_data(Instruct,Rs,Rt,Rd,JT,Imm16,shamt,Op,Funct);
  input[31:0] Instruct;
  output[4:0]  Rs, Rt, Rd,shamt;
  output[15:0] Imm16;
  output[25:0] JT;
  output[5:0] Op,Funct;
  assign Rs=Instruct[25:21];    //R_Type,I_Type
  assign Rt=Instruct[20:16];    //R_Type,I_Type
  assign Rd=Instruct[15:11];    //R_Type
  assign shamt=Instruct[10:6];  //R_Type
  assign Funct=Instruct[5:0];   //R_Type
  assign Imm16=Instruct[15:0];  //I_type
  assign JT=Instruct[25:0];     //J_Type
  assign Op=Instruct[31:26];    //R_Type,I_Type,J_Type
  assign Funct=Instruct[5:0];   //R_Type
endmodule



