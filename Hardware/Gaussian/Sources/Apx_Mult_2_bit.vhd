-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 12/08/2019
-- File: Apx_Mult_2_bit.vhd

-- 2 bits multiplier
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Apx_Mult_2_bit is
  port(
    i_A     : in  std_logic_vector(1 downto 0);
    i_B     : in  std_logic_vector(1 downto 0);
    o_MULT  : out std_logic_vector(2 downto 0)
  );
end entity Apx_Mult_2_bit;

architecture arch of Apx_Mult_2_bit is

begin
  o_MULT(0) <= i_A(0) and i_B(0);
  o_MULT(1) <= (i_A(1) and i_B(0)) or (i_A(0) and i_B(1));
  o_MULT(2) <= i_A(1) and i_B(1);

end architecture;
