-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    18/11/2018
-- File:    reg.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.ALPR_package.all;

entity Reg is
generic(
  c_WIDTH : integer
);
port (
	i_CLK   : in  std_logic;                              -- clock
	i_RST   : in  std_logic;					                    -- reset
	i_ENA   : in  std_logic;               		            -- enable
	i_CLR   : in  std_logic;               		            -- clear
	i_DIN   : in  std_logic_vector(c_WIDTH-1 downto 0);   -- input data
	o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)    -- output data
	);
end Reg;

architecture arch_1 of Reg is
	signal r_DATA : std_logic_vector(c_WIDTH-1 downto 0);
begin
	process(i_CLK, i_RST, i_CLR)
	begin
		if (i_RST = '1') then
			r_DATA <= (others => '0');
		elsif (rising_edge(i_CLK)) then
      if (i_CLR = '1') then
  			r_DATA <= (others => '0');
			elsif (i_ENA = '1') then
				r_DATA <= i_DIN;
			end if;
		end if;
	end process;

	o_DOUT <= r_DATA;
end arch_1;
