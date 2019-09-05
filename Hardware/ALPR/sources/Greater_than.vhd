-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    27/02/2018
-- File:    Greater_than.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Greater_than is
  generic(
    c_WIDTH_DATA : integer
  );
	 port(
         i_A  : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
         i_B  : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
         o_GT : out std_logic
	 );
end Greater_than;

architecture arch1 of Greater_than is

begin
     o_GT <= '1' when (i_A>i_B) else '0';

end arch1;
