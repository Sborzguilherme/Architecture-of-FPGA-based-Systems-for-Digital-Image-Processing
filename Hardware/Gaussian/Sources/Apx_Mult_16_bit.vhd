-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 12/08/2019
-- File: Apx_Mult_8_bit.vhd

-- 8 bits multiplier
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Apx_Mult_16_bit is
  port(
    i_A     : in  std_logic_vector(15 downto 0);
    i_B     : in  std_logic_vector(15 downto 0);
    o_MULT  : out std_logic_vector(15 downto 0)     -- Shifted value
  );
end entity Apx_Mult_16_bit;

architecture arch of Apx_Mult_16_bit is

  signal w_A_HIGH : std_logic_vector(7 downto 0);
  signal w_A_LOW  : std_logic_vector(7 downto 0);
  signal w_B_HIGH : std_logic_vector(7 downto 0);
  signal w_B_LOW  : std_logic_vector(7 downto 0);

  signal w_RES_AL_XL : std_logic_vector(15 downto 0);
  signal w_RES_AH_XL : std_logic_vector(15 downto 0);
  signal w_RES_AL_XH : std_logic_vector(15 downto 0);
  signal w_RES_AH_XH : std_logic_vector(15 downto 0);

  signal w_AUX_AL_XL : std_logic_vector(31 downto 0);
  signal w_AUX_AH_XL : std_logic_vector(31 downto 0);
  signal w_AUX_AL_XH : std_logic_vector(31 downto 0);
  signal w_AUX_AH_XH : std_logic_vector(31 downto 0);

  signal w_SHF_AL_XL : std_logic_vector(31 downto 0);
  signal w_SHF_AH_XL : std_logic_vector(31 downto 0);
  signal w_SHF_AL_XH : std_logic_vector(31 downto 0);
  signal w_SHF_AH_XH : std_logic_vector(31 downto 0);

  signal w_SUM_AUX   : std_logic_vector(31 downto 0);
  signal w_RESULT    : std_logic_vector(31 downto 0);

begin

  w_A_HIGH  <= i_A(15 downto 8);
  w_A_LOW   <= i_A(7 downto 0);
  w_B_HIGH  <= i_B(15 downto 8);
  w_B_LOW   <= i_B(7 downto 0);

  Apx_Mult_2_AL_XL : Apx_Mult_8_bit
  port map (
    i_A    => w_A_LOW,
    i_B    => w_B_LOW,
    o_MULT => w_RES_AL_XL
  );

  Apx_Mult_2_AH_XL : Apx_Mult_8_bit
  port map (
    i_A    => w_A_HIGH,
    i_B    => w_B_LOW,
    o_MULT => w_RES_AH_XL
  );

  Apx_Mult_2_AL_XH : Apx_Mult_8_bit
  port map (
    i_A    => w_A_LOW,
    i_B    => w_B_HIGH,
    o_MULT => w_RES_AL_XH
  );

  Apx_Mult_2_AH_XH : Apx_Mult_8_bit
  port map (
    i_A    => w_A_HIGH,
    i_B    => w_B_HIGH,
    o_MULT => w_RES_AH_XH
  );

  -- Resize the output value
  w_AUX_AL_XL <= std_logic_vector(resize(unsigned(w_RES_AL_XL), 32));     -- Output size
  w_AUX_AH_XL <= std_logic_vector(resize(unsigned(w_RES_AH_XL), 32));
  w_AUX_AL_XH <= std_logic_vector(resize(unsigned(w_RES_AL_XH), 32));
  w_AUX_AH_XH <= std_logic_vector(resize(unsigned(w_RES_AH_XH), 32));

  w_SHF_AL_XL <= w_AUX_AL_XL; -- Output size
  w_SHF_AH_XL <= std_logic_vector(shift_left(unsigned(w_AUX_AH_XL), 8));
  w_SHF_AL_XH <= std_logic_vector(shift_left(unsigned(w_AUX_AL_XH), 8));
  w_SHF_AH_XH <= std_logic_vector(shift_left(unsigned(w_AUX_AH_XH), 16));

  w_SUM_AUX <= w_SHF_AL_XL + w_SHF_AH_XL + w_SHF_AL_XH + w_SHF_AH_XH;

  w_RESULT <= std_logic_vector(shift_right(unsigned(w_SUM_AUX), 8));    -- Shift right LSB

  o_MULT <= std_logic_vector(resize(unsigned(w_RESULT), 16));

end architecture;
