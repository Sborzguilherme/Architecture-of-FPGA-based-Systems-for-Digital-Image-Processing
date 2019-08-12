-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 12/08/2019
-- File: Apx_FA_1_bit.vhd

-- Approximated full-adder 1 bit
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Apx_FA_1_bit is
  port(
    i_A     : in  std_logic;
    i_B     : in  std_logic;
    i_Cin   : in  std_logic;
    o_SUM   : out std_logic;
    o_Cout  : out std_logic
  );
end entity Apx_FA_1_bit;

architecture arch of Apx_FA_1_bit is

begin
  o_Cout <= i_A;
  o_SUM <=  i_Cin AND ((not i_A) or i_B);
end architecture;
