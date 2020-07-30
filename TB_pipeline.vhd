


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity TBPIPE IS
end TBPIPE;
 
architecture Behavioral of  TBPIPE is

component pipelineprocessor  is
Port (
	clk : in STD_LOGIC;
	reset : in std_logic;
	noopsig: out STD_LOGIC;
	haltsig : out STD_LOGIC);

END component;

SIGNAL clk : STD_LOGIC:='0';
SIGNAL	reset :  std_logic:='1';
SIGNAL	noopsig: STD_LOGIC:='0';
SIGNAL	haltsig : STD_LOGIC:='0';

BEGIN
	UUT: pipelineprocessor port map (clk,reset,noopsig,haltsig);
	reset <= '0' after 5 ns;
	CLK <= NOT CLK AFTER 20 NS;
	

end; 