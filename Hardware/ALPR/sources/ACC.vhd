-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 22/02/2019
-- File: ACC.vhd

-- Accumulator
-- When i_ENA is high the input data is added to the previous stored value
-- i_CLR enable the count value to be reseted if needed
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ACC is
	generic(
		c_WIDTH_INPUT_DATA : integer;
		c_WIDTH_OUTPUT_DATA : integer
	);
	port (
	i_CLK  :  in  std_logic;
	i_RST  :  in  std_logic;
	i_ENA  :  in  std_logic;
	i_CLR  :  in  std_logic;
  i_DATA :  in std_logic_vector(c_WIDTH_INPUT_DATA-1 downto 0);
	o_Q    :  out std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0)
	);
end ACC;

architecture arch_1 of ACC is
  signal w_Q : integer := 0;

begin
process ( i_CLK, i_RST, i_CLR, i_DATA)
	begin
		if (i_RST = '1') or (i_CLR = '1') then
			w_Q <= 0;
		elsif (rising_edge(i_CLK)) then
			if (i_ENA = '1') then
				w_Q <= w_Q + (to_integer(unsigned(i_DATA))) ;
			else
				w_Q <= w_Q ;
			end if ;
		end if ;
end process ;

	o_Q <= std_logic_vector(to_unsigned(w_Q, c_WIDTH_OUTPUT_DATA));

end arch_1 ;
