
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity registerFileGeneric is
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
end registerFileGeneric;
architecture loop_arch of registerFileGeneric is
   type register_file_type is array(15 downto 0) of std_logic_vector(31 downto 0);
   signal state_reg,state_next: register_file_type;
   signal en,en1,en2:std_logic_vector(15 downto 0);
begin
   process(clk,reset)
   begin
      if(reset = '1') then
	 for i in 0 to 15 loop
 	   state_reg(i) <= (others => '0');
	 end loop;
      elsif(clk'event and clk = '1') then
	for i in 0 to 15 loop
	   state_reg(i) <= state_next(i);
	end loop;
      end if;
   end process;
   process(state_reg,wr_en,wr_add)
   begin
      en1 <= (others => '0');
      en2 <= (to_integer(unsigned(wr_add)) => '1',others => '0');
      if (wr_en = '1') then
         en <= en2;
      else
	 en <= en1;
      end if;      
   end process;
   process(en,wr_data)
   begin
      for i in 0 to 15 loop
         state_next(i) <= state_reg(i);
      end loop;
      if (en(to_integer(unsigned(wr_add))) = '1') then 
	 state_next(to_integer(unsigned(wr_add))) <= wr_data;
      end if;
   end process;
   re_data1 <= state_reg(to_integer(unsigned(re_add1)));
   re_data2 <= state_reg(to_integer(unsigned(re_add2)));
end loop_arch;