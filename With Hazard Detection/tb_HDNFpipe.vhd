
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tb_HDNFpipe IS
end tb_HDNFpipe;
 
architecture Behavioral of  tb_HDNFpipe is

component HDNFpipelineprocessor is
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
	reset <= '0' after 5 ns;
	CLK <= NOT CLK AFTER 20 NS;
	UUT: HDNFpipelineprocessor port map (clk,reset,noopsig,haltsig);

end; 