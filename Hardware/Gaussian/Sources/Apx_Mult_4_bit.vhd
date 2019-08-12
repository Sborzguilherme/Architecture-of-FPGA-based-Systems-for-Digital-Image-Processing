-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 12/08/2019
-- File: Apx_Mult_4_bit.vhd

-- 4 bits multiplier
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Apx_Mult_4_bit is
  port(
    i_A     : in  std_logic_vector(3 downto 0);
    i_B     : in  std_logic_vector(3 downto 0);
    o_MULT  : out std_logic_vector(7 downto 0)
  );
end entity Apx_Mult_4_bit;

architecture arch of Apx_Mult_4_bit is

  signal w_A_HIGH : std_logic_vector(1 downto 0);
  signal w_A_LOW  : std_logic_vector(1 downto 0);
  signal w_B_HIGH : std_logic_vector(1 downto 0);
  signal w_B_LOW  : std_logic_vector(1 downto 0);

  signal w_RES_AL_XL : std_logic_vector(2 downto 0);
  signal w_RES_AH_XL : std_logic_vector(2 downto 0);
  signal w_RES_AL_XH : std_logic_vector(2 downto 0);
  signal w_RES_AH_XH : std_logic_vector(2 downto 0);

  signal w_AUX_AL_XL : std_logic_vector(7 downto 0);
  signal w_AUX_AH_XL : std_logic_vector(7 downto 0);
  signal w_AUX_AL_XH : std_logic_vector(7 downto 0);
  signal w_AUX_AH_XH : std_logic_vector(7 downto 0);

  signal w_SHF_AL_XL : std_logic_vector(7 downto 0);
  signal w_SHF_AH_XL : std_logic_vector(7 downto 0);
  signal w_SHF_AL_XH : std_logic_vector(7 downto 0);
  signal w_SHF_AH_XH : std_logic_vector(7 downto 0);

begin

  w_A_HIGH  <= i_A(3 downto 2);
  w_A_LOW   <= i_A(1 downto 0);
  w_B_HIGH  <= i_B(3 downto 2);
  w_B_LOW   <= i_B(1 downto 0);

  Apx_Mult_2_AL_XL : Apx_Mult_2_bit
  port map (
    i_A    => w_A_LOW,
    i_B    => w_B_LOW,
    o_MULT => w_RES_AL_XL
  );

  Apx_Mult_2_AH_XL : Apx_Mult_2_bit
  port map (
    i_A    => w_A_HIGH,
    i_B    => w_B_LOW,
    o_MULT => w_RES_AH_XL
  );

  Apx_Mult_2_AL_XH : Apx_Mult_2_bit
  port map (
    i_A    => w_A_LOW,
    i_B    => w_B_HIGH,
    o_MULT => w_RES_AL_XH
  );

  Apx_Mult_2_AH_XH : Apx_Mult_2_bit
  port map (
    i_A    => w_A_HIGH,
    i_B    => w_B_HIGH,
    o_MULT => w_RES_AH_XH
  );

  w_AUX_AL_XL <= std_logic_vector(resize(unsigned(w_RES_AL_XL), 8)); -- Output size
  w_AUX_AH_XL <= std_logic_vector(resize(unsigned(w_RES_AH_XL), 8));
  w_AUX_AL_XH <= std_logic_vector(resize(unsigned(w_RES_AL_XH), 8));
  w_AUX_AH_XH <= std_logic_vector(resize(unsigned(w_RES_AH_XH), 8));

  w_SHF_AL_XL <= w_AUX_AL_XL; -- Output size
  w_SHF_AH_XL <= std_logic_vector(shift_left(unsigned(w_AUX_AH_XL), 2));
  w_SHF_AL_XH <= std_logic_vector(shift_left(unsigned(w_AUX_AL_XH), 2));
  w_SHF_AH_XH <= std_logic_vector(shift_left(unsigned(w_AUX_AH_XH), 4));


  o_MULT <= w_SHF_AL_XL + w_SHF_AH_XL + w_SHF_AL_XH + w_SHF_AH_XH;

end architecture;
