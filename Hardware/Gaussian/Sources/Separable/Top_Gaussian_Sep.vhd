-----------------------------------------------------------------
-- Project: Gaussian
-- Author:  Guilherme Sborz
-- Date:    15/08/2019
-- File:    Top_Gaussian_Sep.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity Top_Gaussian_Sep is
  generic(
      p_KERNEL_HEIGHT    : integer := 5;
      p_KERNEL_WIDTH     : integer := 5;
      p_INPUT_IMG_WIDTH  : integer := 516;
      p_INPUT_IMG_HEIGHT : integer := 516
  );
  port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_START       : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_INPUT_PIXEL : in fixed;
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out fixed
  );
end Top_Gaussian_Sep;

architecture arch of Top_Gaussian_Sep is

  constant c_VER_IMG_WIDTH : integer := p_INPUT_IMG_WIDTH - (p_KERNEL_WIDTH-1);

    signal w_DONE_HOR     : std_logic;
    signal w_PIX_HOR      : fixed;
    signal w_VALID_VER    : std_logic;
    signal w_PIX_RDY_HOR  : std_logic;

    -- Signals to test in Quartus
    signal r_REG_OUT		  : fixed;
	  signal r_IN_PIX 			: fixed;
	  signal r_OUT_PIX 			: fixed;

begin

-- registers : process(i_CLK)
--   begin
--     if rising_edge(i_CLK) then
--       r_IN_PIX <= i_INPUT_PIXEL;
--       r_OUT_PIX <= r_REG_OUT;
--     end if;
--   end process;

  Top_Gaussian_Hor_i : Top_Gaussian_Hor
  generic map (
    p_KERNEL_WIDTH    => p_KERNEL_WIDTH,
    p_INPUT_IMG_WIDTH  => p_INPUT_IMG_WIDTH,
    p_INPUT_IMG_HEIGHT => p_INPUT_IMG_HEIGHT
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_START       => i_START,
    i_VALID_PIXEL => i_VALID_PIXEL,
    i_INPUT_PIXEL => i_INPUT_PIXEL,
    --i_INPUT_PIXEL     => r_IN_PIX,
    o_PIX_RDY     => w_PIX_RDY_HOR,
    o_DONE        => w_DONE_HOR,
    o_OUT_PIXEL   => w_PIX_HOR
  );

  Top_Gaussian_Ver_i : Top_Gaussian_Ver
  generic map (
    p_KERNEL_HEIGHT    => p_KERNEL_HEIGHT,
    p_INPUT_IMG_WIDTH  => c_VER_IMG_WIDTH,
    p_INPUT_IMG_HEIGHT => p_INPUT_IMG_HEIGHT
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_START       => i_START,
    i_VALID_PIXEL => w_VALID_VER,
    i_INPUT_PIXEL => w_PIX_HOR,
    o_PIX_RDY     => o_PIX_RDY,
    o_DONE        => o_DONE,
    --o_OUT_PIXEL   => r_REG_OUT
    o_OUT_PIXEL         => o_OUT_PIXEL
  );

  w_VALID_VER <= w_PIX_RDY_HOR or w_DONE_HOR;
  --o_OUT_PIXEL <= r_OUT_PIX;

end architecture;
