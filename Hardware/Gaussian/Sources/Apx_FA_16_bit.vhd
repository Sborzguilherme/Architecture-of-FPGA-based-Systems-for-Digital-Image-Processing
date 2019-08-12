-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 12/08/2019
-- File: Apx_FA_16_bit.vhd

-- Approximated full-adder 16 bit
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Apx_FA_16_bit is
  port(
    i_A     : in  fixed;
    i_B     : in  fixed;
    o_SUM   : out fixed
  );
end entity Apx_FA_16_bit;

architecture arch of Apx_FA_16_bit is

  signal w_COUT : std_logic_vector(15 downto 0);

begin

  Apx_FA_1_bit_b0 : Apx_FA_1_bit
  port map (
    i_A    => i_A(0),
    i_B    => i_B(0),
    i_Cin  => '0',
    o_SUM  => o_SUM(0),
    o_Cout => w_COUT(0)
  );

  g_adders_1_15 : for i in 1 to 15 generate
    Apx_FA_1_bit_b0 : Apx_FA_1_bit
    port map (
      i_A    => i_A(i),
      i_B    => i_B(i),
      i_Cin  => w_COUT(i-1),
      o_SUM  => o_SUM(i),
      o_Cout => w_COUT(i)
    );
  end generate;

end architecture;
