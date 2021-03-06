
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pipelineprocessor is
Port (
	clk : in STD_LOGIC;
	reset : in std_logic;
	noopsig: out STD_LOGIC;
	haltsig : out STD_LOGIC);

end pipelineprocessor;
 
architecture Behavioral of  pipelineprocessor is

component MEMORY is
   port(
	clk: in std_logic;
	reset: in std_logic;
	wr_en: in std_logic;
	re_en: in std_logic;
	wr_add: in std_logic_vector(9 downto 0);
	re_add: in std_logic_vector(9 downto 0);
	wr_data: in std_logic_vector(31 downto 0);
	re_data: out std_logic_vector(31 downto 0));
END component;

component alucontrol is
Port (	OP : in STD_LOGIC_VECTOR( 2 DOWNTO 0);
	OPout : out STD_LOGIC_VECTOR( 1 DOWNTO 0);
	Anot : OUT STD_LOGIC;
	Bnot : OUT STD_LOGIC);
END component;

component control is
Port (
	OP : in STD_LOGIC_VECTOR( 3 DOWNTO 0);
	ALUSrc : OUT STD_LOGIC;
	RegRT : OUT STD_LOGIC;
	RegW : out STD_LOGIC;
	MemWrite : out STD_LOGIC;
	MemRead : out STD_LOGIC;
	MemToReg : OUT STD_LOGIC;
	Branch : OUT STD_LOGIC;
	Jalr : out STD_LOGIC;
	Lui : out STD_LOGIC;
	extend : out STD_LOGIC;
	jump : out STD_LOGIC;
	halt : out STD_LOGIC;
	noop : out STD_LOGIC;
	ALUOP : out STD_LOGIC_VECTOR(2 DOWNTO 0));
END component;

component alu is
Port (
	A : in STD_LOGIC_VECTOR( 31 DOWNTO 0);
	B : in STD_LOGIC_VECTOR( 31 DOWNTO 0);
	Anot : in STD_LOGIC;
	Bnot : in STD_LOGIC;
	op : in STD_LOGIC_VECTOR( 1 DOWNTO 0);
	result : out STD_LOGIC_VECTOR( 31 DOWNTO 0);
	overflow : out STD_LOGIC;
	zero : out STD_LOGIC;
	cout : out STD_LOGIC);

end component;

component registerFileGeneric is
   port(
	clk: in std_logic;
	reset: in std_logic;
	wr_en: in std_logic;
	wr_add: in std_logic_vector(3 downto 0);
	re_add1: in std_logic_vector(3 downto 0);
	re_add2: in std_logic_vector(3 downto 0);
	wr_data: in std_logic_vector(31 downto 0);
	re_data1: out std_logic_vector(31 downto 0);
	re_data2: out std_logic_vector(31 downto 0));
END component;


SIGNAL OPcode :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
SIGNAL	ALUSrc :  STD_LOGIC;
SIGNAL	RegRT :  STD_LOGIC;
SIGNAL	RegWrite :  STD_LOGIC;
SIGNAL	MemWrite :  STD_LOGIC;
SIGNAL	MemRead :  STD_LOGIC;
SIGNAL	MemToReg :  STD_LOGIC;
SIGNAL	Branch : STD_LOGIC;
SIGNAL	Jalr :  STD_LOGIC;
SIGNAL	Lui :  STD_LOGIC;
SIGNAL	halt :  STD_LOGIC;
SIGNAL extend : STD_LOGIC;
signal jump : std_logic;
SIGNAL	noop :  STD_LOGIC;
SIGNAL	ALUOPInp :  STD_LOGIC_VECTOR(2 DOWNTO 0);

--SIGNAL	wr_en:  std_logic;
SIGNAL	WriteRegAdd:  std_logic_vector(3 downto 0);
SIGNAL	ReadRegAdd1:  std_logic_vector(3 downto 0);
SIGNAL	ReadRegAdd2:  std_logic_vector(3 downto 0);
SIGNAL	WriteRegData:  std_logic_vector(31 downto 0);
SIGNAL	ReadRegData1:  std_logic_vector(31 downto 0);
SIGNAL	ReadRegData2:  std_logic_vector(31 downto 0);

SIGNAL ALUData1 :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	ALUData2 :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	Anot :  STD_LOGIC;
SIGNAL	Bnot :  STD_LOGIC;
SIGNAL	ALUOP :  STD_LOGIC_VECTOR( 1 DOWNTO 0);
SIGNAL	ALUOutput :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	overflow :  STD_LOGIC;
SIGNAL	zero :  STD_LOGIC;
SIGNAL	cout :  STD_LOGIC;

SIGNAL	WriteMemAdd:  std_logic_vector(9 downto 0);
SIGNAL	ReadMemAdd:  std_logic_vector(9 downto 0);
SIGNAL	WriteMemData:  std_logic_vector(31 downto 0);
SIGNAL	ReadMemData: std_logic_vector(31 downto 0);
SIGNAL	MemReadCon :  STD_LOGIC;
--SIGNAL	instruction :  STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	sourcereg :  STD_LOGIC_vector(3 downto 0);
--SIGNAL	targetreg :  STD_LOGIC_vector(3 downto 0);
--SIGNAL	destreg :  STD_LOGIC_vector(3 downto 0);
SIGNAL	offset :  STD_LOGIC_vector(15 downto 0);
--SIGNAL	signedOffset :  STD_LOGIC_vector(31 downto 0);
--SIGNAL	ZeroOffset :  STD_LOGIC_vector(31 downto 0);
--SIGNAL	LuiOut :  STD_LOGIC_vector(31 downto 0);
--SIGNAL	jalrOut :  STD_LOGIC_vector(31 downto 0);
signal waitneeded : std_logic;
signal PCSrc : std_logic;
SIGNAL textsection :std_logic_vector(9 downto 0):="0011001000";
signal codemode : std_logic;
signal memWritecon : std_logic;
--signal memReadcon : std_logic;
signal memWritepro : std_logic;
signal memReadpro : std_logic;
signal regWritecon : std_logic;
--signal memReadcon : std_logic;
signal regWritepro : std_logic;
signal writeIns : std_logic;
signal insmem_regwrite: std_logic;
signal REGwr: std_logic:='0';

SIGNAL	writeData :  STD_LOGIC_vector(31 downto 0);
--signal i : integer:=0;
type romtype is array(15 downto 0) of std_logic_vector(31 downto 0);
   signal rom: romtype:=("00001000000000100000000000001111",
			 "00000101000000010000000000010100",
			"00001110000000000000000000000000",
			"00001110000000000000000000000000",
			"00001010000000100000000000001100",
			"00001010000000010000000000010000",
			"00000100000100100001000000000000",
			"00001110000000000000000000000000",
			"00001110000000000000000000000000",
			"00001001000001000000000000001100",
			"00000101001000100000000000000001",
			"00001110000000000000000000000000",
			"00001110000000000000000000000000",
			"00001110000000000000000000000000",
			"00000011001001000011000000000000",
			"00001111000000000000000000000000");

--"00000101000000010000000000000000",
			--"00000110000001010000000100101100",
			--"00000101000001000000000000000001",
			--"00000101000000100000000000001100",
			--"00000111000100110000000001100100",
			--"00000001010100010101000000000000",
			--"00000000000101000001000000000000",
			--"00001010001000010000000000000100",
			--"00001011010000111111111111101100",
			--"00001110000000000000000000000000",
			--"00001110000000000000000000000000",
			--"00001110000000000000000000000000",
			--"00001111000000000000000000000000");
SIGNAL	PC_reg,pc_next, pc_before:  STD_LOGIC_vector(9 downto 0):="0000000000";

TYPE STATE IS (codeapplysig,codeapply,Idle,memIns,halti,continue,waits, datamem,delay);
signal cpustates : state := codeapplysig ;

SIGNAL	OPCode23:  STD_LOGIC_vector(3 downto 0);
SIGNAL	OPCode34:  STD_LOGIC_vector(3 downto 0);
SIGNAL	OPCode45:  STD_LOGIC_vector(3 downto 0);

----------------------first stage ------------------------------------------------

SIGNAL	PCPLUSFOUR1:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	instruction1:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";


----------------------IF/ID REGISTERS ------------------------------------------------

SIGNAL	PCPLUSFOUR12:  STD_LOGIC_vector(9 downto 0):="1111111100";
SIGNAL	instruction12:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";

SIGNAL	RegReadData1_2:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	RegReadData2_2:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	SignedExtendedOffset2:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	ZeroExtendedOffset2:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL  LuiOut2 : STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	destReg2:  STD_LOGIC_vector(3 downto 0):="0000";
SIGNAL	targetReg2:  STD_LOGIC_vector(3 downto 0):="0000";

---------------------ID/EXE Registers-------------------------------------------------
------CONTROL--------

signal EXEcontrol2 : STD_LOGIC_vector(9 downto 0):="0000000000";
signal MEMcontrol2 : STD_LOGIC_vector(4 downto 0):="00000";
signal WBcontrol2 : STD_LOGIC_vector(5 downto 0):="000000";

signal EXEcontrol23 : STD_LOGIC_vector(9 downto 0):="0000000000";
signal MEMcontrol23 : STD_LOGIC_vector(4 downto 0):="00000";
signal WBcontrol23 : STD_LOGIC_vector(5 downto 0):="000000";

------DATA-----------

SIGNAL	PCPLUSFOUR23:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	RegReadData1_23:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	RegReadData2_23:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	SignedExtendedOffset23:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	ZeroExtendedOffset23:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL  LuiOut23 : STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	destReg23:  STD_LOGIC_vector(3 downto 0):="0000";
SIGNAL	targetReg23:  STD_LOGIC_vector(3 downto 0):="0000";
SIGNAL	BeqAddress3:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	ALUResult3:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	Zero3: STD_LOGIC:='0';
SIGNAL	RegWriteAdd3:  STD_LOGIC_vector(3 downto 0):="0000";
---------------------

---------------------EXE/MEM Registers-------------------------------------------------
------CONTROL--------

signal MEMcontrol34 : STD_LOGIC_vector(4 downto 0):="00000";
signal WBcontrol34 : STD_LOGIC_vector(5 downto 0):="000000";

------DATA-----------

SIGNAL	PCPLUSFOUR34:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	BeqAddress34:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	ALUResult34:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	Zero34: STD_LOGIC:='0';
SIGNAL	RegReadData2_34:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	RegWriteAdd34:  STD_LOGIC_vector(3 downto 0):="0000";
SIGNAL  LuiOut34 : STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	MemReadData4:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
---------------------

---------------------MEM/WB Registers-------------------------------------------------
------CONTROL--------

signal WBcontrol45 : STD_LOGIC_vector(5 downto 0):="000000";

------DATA-----------

SIGNAL	PCPLUSFOUR45:  STD_LOGIC_vector(9 downto 0):="0000000000";
SIGNAL	ALUResult45:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	MemReadData45:  STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
SIGNAL	RegWriteAdd45:  STD_LOGIC_vector(3 downto 0):="0000";
SIGNAL  LuiOut45 : STD_LOGIC_vector(31 downto 0):="00000000000000000000000000000000";
---------------------


begin


uutControl : control port map (OPcode,ALUSrc,RegRT,RegWritecon,MemWritecon,MemReadcon ,MemToReg,Branch,Jalr ,Lui,extend,jump, halt,noop,ALUOPInp);

uutALU : alu port map (ALUData1,ALUData2,Anot,Bnot,ALUOP,ALUOutput,Overflow,Zero,Cout);

uutRegisterFile : registerFileGeneric port map (clk,reset,RegWrite,WriteRegAdd,ReadRegAdd1,ReadRegAdd2,WriteRegData,ReadRegData1,ReadRegData2);

uutALUControl : alucontrol port map (EXEcontrol23(5 downto 3),ALUOP,Anot,Bnot);

uutMemory : MEMORY port map (clk,reset,MemWrite,MemRead,WriteMemAdd,ReadMemAdd,WriteMemData,ReadMemData);


------------------------------------------------codemode
memWrite<=  memWritepro or MEMcontrol34(0);
memRead<=  memReadpro or MEMcontrol34(1);
RegWrite<=WBcontrol45(0) WHEN REGwr='1' else
		'0'; --Regwritepro when waitneeded='1' else
	  
---------------------------------------------
OPcode<= instruction12(27 downto 24);


sourceReg <= instruction12(23 downto 20);
targetReg2 <= instruction12(19 downto 16);
destReg2 <= instruction12(15 downto 12);
offset <= instruction12(15 downto 0);
ZeroExtendedOffset2<='0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'& offset;
signedExtendedOffset2 <=offset(15)& offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset;
LuiOut2 <= offset &'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0';
ReadRegAdd1 <= (sourceReg);
ReadRegAdd2 <= (targetReg2);
RegReadData1_2 <= ReadRegData1;
RegReadData2_2 <= ReadRegData2;
------------------------------------------------------------

EXEcontrol2(0)<=ALUSrc;
EXEcontrol2(1)<=Jalr;
EXEcontrol2(2)<=RegRT;
EXEcontrol2(5 downto 3)<=ALUOPInp;
EXEcontrol2(6)<=jump;
EXEcontrol2(7)<=halt;
EXEcontrol2(8)<=noop;
EXEcontrol2(9)<=extend;

BeqAddress3<= std_logic_vector(signed(pcplusfour23)+ 4 + signed(signedExtendedOffset23(9 downto 0)));
ALUData1 <=RegReadData1_23;
ALUData2 <=RegReadData2_23 when EXEcontrol23(0)='0' else
	   signedExtendedOffset23 when EXEcontrol23(9)='1' else
	   ZeroExtendedOffset23;
--ALUOPInp<=execontrol23;
zero3<=zero;
ALUResult3<= ALUOutput;
RegWriteAdd3<=(destReg23) when EXEcontrol23(2)='1' else 
		(targetReg23);

---------------------------------------------------------------


MEMcontrol2(0)<=MemWritecon;
MEMcontrol2(1)<=MemReadcon;
MEMcontrol2(2)<=branch;
MEMcontrol2(3)<=halt;
MEMcontrol2(4)<=noop;

PCSrc<= MEMcontrol34(2) and zero34;

PCPLUSFOUR1<=PCPLUSFOUR12 when (codemode='1' or MEMcontrol34(1)='1' OR MEMcontrol34(0)='1' or EXEcontrol2(7)='1' ) else
	ZeroExtendedOffset23(9 downto 0) when EXEcontrol23(6)='1' else------stage2
	 RegReadData1_23(9 downto 0) when EXEcontrol23(1)='1' else
	BeqAddress34 when PCSrc='1' else
	STD_LOGIC_vector(unsigned(PCPLUSFOUR12)+4) ;

MemReadData4<=ReadMemData WHEN (MEMcontrol34(1)='1' OR MEMcontrol34(0)='1')ELSE
		MemReadData4;-------------------------codemode
instruction1<=ReadMemData WHEN (MEMcontrol34(1)='0' and MEMcontrol34(0)='0')ELSE
		instruction1;-------------------------codemode


ReadMemAdd <= std_logic_vector(unsigned(PCPLUSFOUR1) + unsigned(TEXTSECTION)) when (MEMcontrol34(1)='0' and MEMcontrol34(0)='0') else
		(ALUResult34(9 downto 0));
WriteMemAdd <= std_logic_vector(unsigned(PCPLUSFOUR1) + unsigned(TEXTSECTION)) when codemode='1' else
		(ALUResult34(9 downto 0));
WriteMemData <= RegReadData2_34 when codemode = '0' else
		writeData;
---------------------------------------------------
WBcontrol2(0)<=RegWritecon;
WBcontrol2(1)<=Jalr;
WBcontrol2(2)<=Lui;
WBcontrol2(3)<=MemToReg;
WBcontrol2(4)<=halt;
WBcontrol2(5)<=noop;

WriteRegAdd <= RegWriteAdd45;
WriteRegData <= luiOut45 when WBcontrol45(2)='1' else
		'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&pcplusfour45 when WBcontrol45(1)='1' else
		ALUResult45 when WBcontrol45(3)='1' else
	    	MemReadData45;

-------------------------------------------------------------

PROCESS(CLK,RESET)
variable finished: std_logic:='0';
variable i : integer:=15;
BEGIN

	if( reset='1') then
		pc_reg<="0000000000";
		CPUSTATES<=codeapplysig;
		i:=15;
	elsif( clk'event and clk='1') then
		noopsig<='0';
		haltsig<='0';
		regWR<='0';
		
-------------------------------------------------------------------------------
		if(MEMcontrol34(1)='1' OR MEMcontrol34(0)='1')then           --structural hazard checking
		
			--pcplusfour12<= "1111111100";
			instruction12<="00001110000000000000000000000000";
		else
			pcplusfour12<=pcplusfour1 ;
			instruction12<=instruction1;
		end if;
		--if(codemode='1')then 
		
			--pcplusfour12<= "1111111100";
		--else
		
			--pcplusfour12<=pcplusfour1 ;
--
		--end if;

		pcplusfour12<=pcplusfour1 ;
		pcplusfour23<=pcplusfour12 ;
		pcplusfour34<=pcplusfour23 ;
		pcplusfour45<=pcplusfour34 ;

		opcode23<=opcode;
		opcode34<=opcode23;	
		opcode45<= opcode45;
	
		EXEcontrol23<=EXEcontrol2;

		MEMcontrol23<=MEMcontrol2;
		MEMcontrol34<=MEMcontrol23;

		WBcontrol23<=WBcontrol2 ;
		WBcontrol34<=WBcontrol23 ;
		WBcontrol45<=WBcontrol34 ;

		RegReadData1_23<=RegReadData1_2;
		RegReadData2_23<=RegReadData2_2;
		signedExtendedOffset23<= signedExtendedOffset2;
		zeroExtendedOffset23<= zeroExtendedOffset2;
		destReg23<=destReg2;
		targetReg23<=targetReg2;
		LuiOut23<=LuiOut2;

		beqAddress34<= beqAddress3;
		ALUResult34<= ALUResult3;
		zero34<= zero3;
		RegReadData2_34<=RegReadData2_23;
		RegWriteAdd34<=RegWriteAdd3;
		LuiOut34<=LuiOut23;

		ALUResult45<= ALUResult34;
		MemReadData45<=MemReadData4;
		RegWriteAdd45<=RegWriteAdd34;
		LuiOut45<=LuiOut34;
		
		
	case cpustates is 	
		when codeapplysig => 
			MemWritepro<= '1';
			codemode<='1';
			cpustates<=codeapply;
			writeData<= rom(i);
			--writeIns<='1';
 		when codeapply => 
			MemWritepro<= '0';
			codemode<='1';
			textsection<=std_logic_vector(unsigned( textsection)+4);
			i:=i-1;
			cpustates<=codeapplysig;
			if(i=-1) then
				finished:='1';
				i:=15;
			end if;

			if(finished = '1') then
				textsection<="0011001000";
				pcplusfour12<= "1111111100";
				cpustates<=waits;
				--writeIns<='0';
				MemReadpro <= '1';
				codemode<='0';
			end if;
		when waits =>	
			MemReadpro <= '1';
		--	codeMode<='1';
			cpustates<=waits;
			IF( halt='1') then
				cpustates<=halti;
			end if;
			--instruction1<= ReadMemData;
			--waitneeded<='0';
		when halti => 
			--	waitneeded<='0';
			haltsig<='1';
		when others => 
		
		end case;
	elsif( clk'event and clk='0') then
		regWR<='1';
	end if;
	end process;


end;
