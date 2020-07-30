
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity control is
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

end control;
 
architecture Behavioral of control is
 

BEGIN

extend<= '1' when (op="0101" or op="0111" or op="1001" or op="1010" or op <="1011")else --sign extention
	'0';
branch <= '1' when (op="1011" ) else
	 '0';

jalr <='1' when (op="1100" ) else
	 '0';

lui <= '1' when (op="1000" ) else
	 '0';

jump <= '1' when (op="1101" ) else
	 '0';

MemToReg <='1' when (op="0000" or op="0001" or op="0010" or op="0011" or op="0100" or op="0101" or op="0110" or op="0111"or op="1000" ) else
	 '0';

MemRead <='1' when (op="1001") else
	 '0';

MemWrite <= '1' when (op="1010") else
	 '0';

RegW <= '1' when (op="0000" or op="0001" or op="0010" or op="0011" or op="0100" or op="0101"or op="0110" or op="0111"or op="1000" or op="1001" or op="1100") else
	 '0';

RegRt <= '1' when (op="0000" or op="0001" or op="0010" or op="0011" or op="0100" or op="1010") else
	 '0'; --1010, 1011,1101 don't care
  
ALUSrc <= '0' when (op="0000" or op="0001" or op="0010" or op="0011" or op="0100" or op="1011") else
	 '1';

ALUOP <= "001" when (op="0001" or op="1011") else
	 "111" when (op="0010" or op="0111" ) else
	"100" when(op="0011" or op="0110" ) else 
	"010" when (op="0100") else 
	"000" ;

halt<=  '1' when (op="1111") else
	'0';

noop<=  '1' when (op="1110") else
	'0';



end Behavioral;