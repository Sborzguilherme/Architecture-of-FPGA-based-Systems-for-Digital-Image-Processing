-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    18/11/2018
-- File:    reg.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Flip_Flop is
port (
	i_CLK   : in  std_logic;   -- clock
	i_RST   : in  std_logic;	 -- reset
	i_ENA   : in  std_logic;   -- enable
	i_CLR   : in  std_logic;   -- clear
	i_DIN   : in  std_logic;   -- input data
	o_DOUT  : out std_logic    -- output data
	);
end Flip_Flop;

architecture arch_1 of Flip_Flop is
	signal r_DATA : std_logic;
begin
	process(i_CLK, i_RST, i_CLR)
	begin
		if (i_RST = '1') then
			r_DATA <= '0';
		elsif (rising_edge(i_CLK)) then
      if (i_CLR = '1') then
  			r_DATA <= '0';
			elsif (i_ENA = '1') then
				r_DATA <= i_DIN;
			end if;
		end if;
	end process;

	o_DOUT <= r_DATA;
end arch_1;
