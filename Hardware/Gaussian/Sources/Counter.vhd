-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 20/11/2018
-- File: Counter.vhd

-- Counter
-- When i_ENA are seted the o_Q output is incremeted.
-- i_CLR enable the count value to be reseted if needed
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Counter is
	port (
	i_CLK  :  in  std_logic;
	i_RST  :  in  std_logic;
	i_ENA  :  in  std_logic ;
	i_CLR  :  in  std_logic;
	o_Q    :  out integer:= 0
	);
end Counter;

architecture arch_1 of Counter is
signal w_Q : integer := 0;

begin
process ( i_CLK, i_RST, i_CLR )
	begin
		if (i_RST = '1') or (i_CLR = '1') then
			w_Q <= 0;
		elsif (rising_edge(i_CLK)) then
			if (i_ENA = '1') then
				w_Q <= w_Q + 1 ;
			else
				w_Q <= w_Q ;
			end if ;
		end if ;
end process ;

	o_Q <= w_Q ;

end arch_1 ;
