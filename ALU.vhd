library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity alu is
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

end alu;
 
architecture Behavioral of alu is
 
component Carry_Look_Ahead32 is
port(
         A      :  IN   STD_LOGIC_VECTOR(31 DOWNTO 0);
         B      :  IN   STD_LOGIC_VECTOR(31 DOWNTO 0);
         Cin  :  IN   STD_LOGIC;
         S       :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
         Cout :  OUT  STD_LOGIC;
	 overflow :  OUT  STD_LOGIC
        );
END component;

signal add : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sub : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal nandr : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal orr : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal less : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal RealA : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal RealB : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin

uut1 : Carry_Look_Ahead32 port map( RealA,RealB,Bnot,add,cout,overflow);

less <= "0000000000000000000000000000000" & add(31);
zero <= '1' when add = "00000000000000000000000000000000" else
	'0';

RealA <= A when Anot ='0' else
	NOT A;

RealB <= B when Bnot ='0' else
	NOT B;

nandr<= A nand B;
orr<= A or B;

result <= add when op= "00" else
	  nandr when op= "01" else
	  orr when op= "10" else
	  less;
 
end Behavioral;
