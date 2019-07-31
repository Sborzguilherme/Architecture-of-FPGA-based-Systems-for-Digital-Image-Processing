library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;

entity tb_fixed_operations is
end entity;

architecture arch of tb_fixed_operations is

constant period : time := 10 ps;

signal a : fixed := (others=>'0');
signal b : fixed := (others=>'0');

signal sum            : fixed;
signal mult           : fixed;
signal small          : std_logic;
signal small_eq       : std_logic;
signal great          : std_logic;
signal great_eq       : std_logic;
signal shift_left_w   : fixed;
signal shift_right_w  : fixed;

begin

  process
  begin

    a <= x"0010";
    b <= x"0011";
    wait for period;

    a <= x"1100";
    b <= x"0005";
    wait for period;

    a <= x"35FE";
    b <= x"4444";
    wait for period;

    a <= x"2187";
    b <= x"CAFE";
    wait for period;

    a <= x"EDDE";
    b <= x"FCA0";

    wait;
  end process;

    sum <= a + b;
    mult <= a*b;
    small <= '1' when a < b else '0';
    small_eq <= '1' when a <= b else '0';
    great <= '1' when a > b else '0';
    great_eq <= '1' when a >= b else '0';
    shift_left_w <= shift_left(a,2);
    shift_right_w <= shift_right(a,2);

end architecture;
