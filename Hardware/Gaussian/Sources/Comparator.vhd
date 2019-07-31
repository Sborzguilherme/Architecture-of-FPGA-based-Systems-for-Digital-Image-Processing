-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    29/09/2018
-- File:    comparator.vhd

-- Compare inputs i_A and i_B -> Enable output when inputs are equal
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Comparator is
	 port(
         i_A  : in  integer;
         i_B  : in  integer;
         o_EQ : out std_logic
	 );
end Comparator;

architecture arch1 of Comparator is

begin
     o_EQ <= '1' when (i_A=i_B) else '0';

end arch1;
