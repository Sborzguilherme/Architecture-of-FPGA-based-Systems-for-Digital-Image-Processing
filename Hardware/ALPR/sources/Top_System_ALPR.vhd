-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/03/2019
-- File:    Top_System_ALPR.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_System_ALPR is
    generic(
      c_WIDTH_INPUT_PIXEL : integer := 24;  -- RGB   24 bits
      c_WIDTH_GRAY_PIXEL  : integer := 8;   -- GRAY  8 bits
      c_KERNEL_HEIGHT_MO1 : integer := c_KERNEL_HEIGHT_MO1;
      c_KERNEL_WIDTH_MO1  : integer := c_KERNEL_WIDTH_MO1;
      c_KERNEL_HEIGHT_MO2 : integer := c_KERNEL_HEIGHT_MO2;
      c_KERNEL_WIDTH_MO2  : integer := c_KERNEL_WIDTH_MO2;
      c_KERNEL_HEIGHT_MC  : integer := c_KERNEL_HEIGHT_MC;
      c_KERNEL_WIDTH_MC   : integer := c_KERNEL_WIDTH_MC;
      c_INPUT_IMG_HEIGHT  : integer := c_INPUT_IMG_WIDTH_MO1;
      c_INPUT_IMG_WIDTH   : integer := c_INPUT_IMG_WIDTH_MO1;
      c_SIZE_MEM_OTSU     : integer := 256
    );
    port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_START       : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_INPUT_PIXEL : in std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out std_logic
    );
end Top_System_ALPR;

architecture arch of Top_System_ALPR is

  signal w_PIX_RDY_MO1 : std_logic;
  signal w_DONE_BLOCK1 : std_logic;

  signal w_PIX_RDY_BLOCK2   : std_logic;
  signal w_OUT_PIXEL_BLOCK2 : std_logic;
  signal w_DONE_BLOCK2      : std_logic;
  signal w_OUT_REG          : std_logic;

  signal w_OUT_PIXEL_BLOCK1 : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

begin

  Top_Block1_i : Top_Block1
  generic map (
    c_WIDTH_INPUT_PIXEL => c_WIDTH_INPUT_PIXEL,
    c_WIDTH_GRAY_PIXEL  => c_WIDTH_GRAY_PIXEL,
    c_KERNEL_HEIGHT_MO1 => c_KERNEL_HEIGHT_MO1,
    c_KERNEL_WIDTH_MO1  => c_KERNEL_WIDTH_MO1,
    c_INPUT_IMG_HEIGHT  => c_INPUT_IMG_HEIGHT,
    c_INPUT_IMG_WIDTH   => c_INPUT_IMG_WIDTH
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_START       => i_START,
    i_VALID_PIXEL => i_VALID_PIXEL,
    i_INPUT_PIXEL => i_INPUT_PIXEL,
    o_PIX_RDY     => w_PIX_RDY_MO1,
    o_DONE        => w_DONE_BLOCK1,
    o_OUT_PIXEL   => w_OUT_PIXEL_BLOCK1
  );

  Top_Block2_i : Top_Block2
  generic map (
    c_WIDTH_GRAY_PIXEL => c_WIDTH_GRAY_PIXEL,
    c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MO2,
    c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MO2
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_START       => w_PIX_RDY_MO1,
    i_VALID_PIXEL => w_PIX_RDY_MO1,
    i_DONE_BLOCK1 => w_DONE_BLOCK1,
    i_INPUT_PIXEL => w_OUT_PIXEL_BLOCK1,
    o_PIX_RDY     => w_PIX_RDY_BLOCK2,
    o_DONE        => w_DONE_BLOCK2,
    o_OUT_PIXEL   => w_OUT_PIXEL_BLOCK2
  );

  FF_i : Flip_Flop
  port map (
    i_CLK  => i_CLK,
    i_RST  => i_RST,
    i_ENA  => w_PIX_RDY_BLOCK2,
    i_CLR  => '0',
    i_DIN  => w_OUT_PIXEL_BLOCK2,
    o_DOUT => w_OUT_REG
  );


  Top_Block3_i : Top_Block3
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
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_VALID_PIXEL => w_PIX_RDY_BLOCK2,
  i_PIX_RDY_SUB => w_PIX_RDY_BLOCK2,
  i_INPUT_PIXEL => w_OUT_REG,
  o_PIX_RDY     => o_PIX_RDY,
  o_DONE        => o_DONE,
  o_OUT_PIXEL   => o_OUT_PIXEL
);


end architecture;
