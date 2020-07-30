
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEMORY is
   port(
	clk: in std_logic;
	reset: in std_logic;
	wr_en: in std_logic;
	re_en: in std_logic;
	wr_add: in std_logic_vector(9 downto 0);
	re_add: in std_logic_vector(9 downto 0);
	wr_data: in std_logic_vector(31 downto 0);
	re_data: out std_logic_vector(31 downto 0));
end MEMORY;

architecture behave of MEMORY is

   type memory_type is array(1023 downto 0) of std_logic_vector(7 downto 0);
   signal state_reg,state_next: memory_type;
   signal en1,en2:std_logic_vector(1023 downto 0);

begin
	
   process(CLK,reset)
   begin
      if(reset = '1') then
	 for i in 0 to 1023 loop
 	   state_reg(i) <= (others => '0');
	 end loop;
      elsif(clk'event and clk = '1') then
	for i in 0 to 1023 loop
	   state_reg(i) <= state_next(i);
	end loop;
      end if;
   end process;
   process(state_reg,wr_en,wr_add)
   begin

      if (wr_en = '1') then
         en1 <= (to_integer(unsigned(wr_add)) => '1',others => '0');
      else
	 en1 <= (others => '0');
      end if; 
     
   end process;
   process(en1,wr_data)
   begin
      for i in 0 to 1023 loop
         state_next(i) <= state_reg(i);
      end loop;
      if (en1(to_integer(unsigned(wr_add))) = '1') then 
	 state_next(to_integer(unsigned(wr_add))) <= wr_data(7 DOWNTO 0);
	 state_next(to_integer(unsigned(wr_add))+1) <= wr_data(15 DOWNTO 8);
	 state_next(to_integer(unsigned(wr_add))+2) <= wr_data(23 DOWNTO 16);
	 state_next(to_integer(unsigned(wr_add))+3) <= wr_data(31 DOWNTO 24);
      end if;
   end process;

process(state_reg,re_en,re_add)
   begin

      if (re_en = '1') then
         en2 <= (to_integer(unsigned(re_add)) => '1',others => '0');
      else
	 en2 <= (others => '0');
      end if; 
     
   end process;
   process(en2)
   begin
      if (en2(to_integer(unsigned(re_add))) = '1') then 
	 re_data(7 DOWNTO 0) <= state_reg(to_integer(unsigned(re_add)));
	 re_data(15 DOWNTO 8) <= state_reg(to_integer(unsigned(re_add))+1);
	 re_data(23 DOWNTO 16) <= state_reg(to_integer(unsigned(re_add))+2);
	 re_data(31 DOWNTO 24) <= state_reg(to_integer(unsigned(re_add))+3);
      end if;
   end process;

end behave;