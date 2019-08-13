library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Gaussian.all;

entity tb_Apx_Mult is
end entity;

architecture arch of tb_Apx_Mult is

    constant period : time := 10 ps;
    signal a        : fixed := (others=>'0');
    signal b        : fixed := (others=>'0');
    signal a_std    : fixed := (others=>'0');
    signal b_std    : fixed := (others=>'0');
    signal mult     : fixed;

begin

  a_std <= std_logic_vector(a);
  b_std <= std_logic_vector(b);

u_test : process is
  begin

    a <= x"0220";
    b <= x"4544";
    wait for period;

    a <= x"0101";
    b <= x"1111";
    wait for period;

    a <= x"1101";
    b <= x"1001";
    wait for period;

    a <= x"1110";
    b <= x"1110";
    wait for period;

    a <= x"0111";
    b <= x"0111";
    wait for period;

  end process;

--   process is
-- begin
--   report "  11  /   2  = " & integer'image(11 / 2);
--   wait;
-- end process;


  Apx_Mult_16_bit_i : Apx_Mult_16_bit
  port map (
    i_A    => a_std,
    i_B    => b_std,
    o_MULT => mult
  );

end architecture;
