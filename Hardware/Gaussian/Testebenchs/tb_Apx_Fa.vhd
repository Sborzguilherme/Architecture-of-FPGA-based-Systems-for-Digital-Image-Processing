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

    a <= x"0101";
    b <= x"0101";
    wait for period;

    a <= x"8080";
    b <= x"4567";
    wait for period;

    a <= x"2148";
    b <= x"9635";
    wait for period;

    a <= x"1111";
    b <= x"2222";
    wait for period;

    a <= x"4525";
    b <= x"4525";
    wait for period;

  end process;

--   process is
-- begin
--   report "  11  /   2  = " & integer'image(11 / 2);
--   wait;
-- end process;

  -- Apx_FA_1_bit_i : Apx_FA_1_bit
  -- port map (
  --   i_A    => a,
  --   i_B    => b,
  --   i_Cin  => cin,
  --   o_SUM  => sum,
  --   o_Cout => cout
  -- );

  Apx_FA_16_bit_i : Apx_FA_16_bit
  port map (
    i_A   => a,
    i_B   => b,
    o_SUM => sum
  );


end architecture;
