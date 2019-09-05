-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/03/2019
-- File:    Top_Block2.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_Block3 is
    generic(
    c_KERNEL_HEIGHT_MO2     : integer := c_KERNEL_HEIGHT_MO2;
    c_KERNEL_WIDTH_MO2      : integer := c_KERNEL_WIDTH_MO2;
    c_INPUT_IMG_HEIGHT_MO2  : integer := c_INPUT_IMG_HEIGHT_MO2;
    c_INPUT_IMG_WIDTH_MO2   : integer := c_INPUT_IMG_WIDTH_MO2;
    c_KERNEL_HEIGHT_MC      : integer := c_KERNEL_HEIGHT_MC;
    c_KERNEL_WIDTH_MC       : integer := c_KERNEL_WIDTH_MC;
    c_INPUT_IMG_HEIGHT_MC   : integer := c_INPUT_IMG_HEIGHT_MC;
    c_INPUT_IMG_WIDTH_MC    : integer := c_INPUT_IMG_WIDTH_MC
    );
    port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_PIX_RDY_SUB : in std_logic;
      i_INPUT_PIXEL : in std_logic;
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out std_logic
    );
end Top_Block3;

architecture arch of Top_Block3 is

  signal w_DONE_MO2  : std_logic;
  signal w_DONE_MC   : std_logic;
  signal w_VALID_MO2 : std_logic;
  signal w_VALID_MC  : std_logic;

begin

  Datapath_Block3_i : Datapath_Block3
generic map (
  c_KERNEL_HEIGHT_MO2    => c_KERNEL_HEIGHT_MO2,
  c_KERNEL_WIDTH_MO2     => c_KERNEL_WIDTH_MO2,
  c_INPUT_IMG_HEIGHT_MO2 => c_INPUT_IMG_HEIGHT_MO2,
  c_INPUT_IMG_WIDTH_MO2  => c_INPUT_IMG_WIDTH_MO2,
  c_KERNEL_HEIGHT_MC     => c_KERNEL_HEIGHT_MC,
  c_KERNEL_WIDTH_MC      => c_KERNEL_WIDTH_MC,
  c_INPUT_IMG_HEIGHT_MC  => c_INPUT_IMG_HEIGHT_MC,
  c_INPUT_IMG_WIDTH_MC   => c_INPUT_IMG_WIDTH_MC
)
port map (
  i_CLK             => i_CLK,
  i_RST             => i_RST,
  i_PIX_RDY_SUB     => i_PIX_RDY_SUB,
  i_VALID_PIXEL_MO2 => w_VALID_MO2,
  i_VALID_PIXEL_MC  => w_VALID_MC,
  i_INPUT_PIXEL     => i_INPUT_PIXEL,
  o_DONE_MO2        => w_DONE_MO2,
  o_DONE_MC         => w_DONE_MC,
  o_PIX_RDY         => o_PIX_RDY,
  o_OUT_PIXEL       => o_OUT_PIXEL
);

  Control_Block3_i : Control_Block3
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_PIX_RDY_SUB => i_PIX_RDY_SUB,
  i_DONE_MO2    => w_DONE_MO2,
  i_DONE_MC     => w_DONE_MC,
  o_VALID_MO2   => w_VALID_MO2,
  o_VALID_MC    => w_VALID_MC,
  o_DONE        => o_DONE
);


end architecture;
