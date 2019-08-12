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

    signal a    : std_logic_vector(7 downto 0) := (others=>'0');
    signal b    : std_logic_vector(7 downto 0) := (others=>'0');
    signal mult : std_logic_vector(15 downto 0);

begin

u_test : process is
  begin

    a <= "01010101";
    b <= "10101111";
    wait for period;

    -- a <= "0101";
    -- b <= "1111";
    -- wait for period;
    --
    -- a <= "1101";
    -- b <= "1001";
    -- wait for period;
    --
    -- a <= "1110";
    -- b <= "1110";
    -- wait for period;
    --
    -- a <= "0111";
    -- b <= "0111";
    -- wait for period;

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

  Apx_Mult_8_bit_i : Apx_Mult_8_bit
  port map (
    i_A    => a,
    i_B    => b,
    o_MULT => mult
  );


end architecture;
