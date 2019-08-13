library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Gaussian.all;

entity tb_Apx_Fa is
end entity;

architecture arch of tb_Apx_Fa is

    constant period : time := 10 ps;

    signal a    : fixed := x"0000";
    signal b    : fixed := x"0000";
    signal sum  : fixed;

begin

u_test : process is
  begin

    a <= x"0c17";
    b <= x"1460";
    wait for period;

    a <= x"0c06";
    b <= x"1460";
    wait for period;

    a <= x"20FC";
    b <= x"1440";
    wait for period;

    a <= x"0C06";
    b <= x"1440";
    wait for period;

  end process;

--   process is
-- begin
--   report "  11  /   2  = " & integer'image(11 / 2);
--   wait;
-- end process;

  Apx_FA_16_bit_i : Apx_FA_16_bit
  port map (
    i_A   => a,
    i_B   => b,
    o_SUM => sum
  );


end architecture;
