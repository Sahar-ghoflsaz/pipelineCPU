library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity alucontrol is
Port (	OP : in STD_LOGIC_VECTOR( 2 DOWNTO 0);
	OPout : out STD_LOGIC_VECTOR( 1 DOWNTO 0);
	Anot : OUT STD_LOGIC;
	Bnot : OUT STD_LOGIC);
end alucontrol;

architecture Behavioral of alucontrol is
 
begin 

OPout <=OP(2 DOWNTO 1);
Bnot <= OP(0);
Anot<= '0'; 

end;