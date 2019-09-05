-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    11/03/2019
-- File:    Top_System_ALPR.vhd
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_Block1 is
    generic(
      c_WIDTH_INPUT_PIXEL : integer := 24;  -- RGB   24 bits
      c_WIDTH_GRAY_PIXEL  : integer := 8;  -- GRAY  8 bits
      c_KERNEL_HEIGHT_MO1 : integer := c_KERNEL_HEIGHT_MO1;
      c_KERNEL_WIDTH_MO1  : integer := c_KERNEL_WIDTH_MO1;
      c_INPUT_IMG_HEIGHT  : integer := c_INPUT_IMG_WIDTH_MO1;
      c_INPUT_IMG_WIDTH   : integer := c_INPUT_IMG_WIDTH_MO1
    );
    port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_START       : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_INPUT_PIXEL : in std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0)
    );
end Top_Block1;

architecture arch of Top_Block1 is

signal w_ENA_CNT_R_ADDR_GRAY  : std_logic;
signal w_CLR_CNT_R_ADDR_GRAY  : std_logic;
signal w_ENA_CNT_W_ADDR_GRAY  : std_logic;
signal w_CLR_CNT_W_ADDR_GRAY  : std_logic;
signal w_DONE_MO1             : std_logic;
signal w_PIX_RDY_MO1          : std_logic;
signal w_DONE                 : std_logic;


begin

  Datapath_Block1_i : Datapath_Block1
generic map (
  c_WIDTH_INPUT_PIXEL => c_WIDTH_INPUT_PIXEL,
  c_WIDTH_GRAY_PIXEL  => c_WIDTH_GRAY_PIXEL,
  c_KERNEL_HEIGHT_MO1 => c_KERNEL_HEIGHT_MO1,
  c_KERNEL_WIDTH_MO1  => c_KERNEL_WIDTH_MO1,
  c_INPUT_IMG_HEIGHT  => c_INPUT_IMG_HEIGHT,
  c_INPUT_IMG_WIDTH   => c_INPUT_IMG_WIDTH
)
port map (
  i_CLK                 => i_CLK,
  i_RST                 => i_RST,
  i_START               => i_START,
  i_VALID_PIXEL         => i_VALID_PIXEL,
  i_INPUT_PIXEL         => i_INPUT_PIXEL,
  i_ENA_CNT_R_ADDR_GRAY => w_ENA_CNT_R_ADDR_GRAY,
  i_CLR_CNT_R_ADDR_GRAY => w_CLR_CNT_R_ADDR_GRAY,
  i_ENA_CNT_W_ADDR_GRAY => w_ENA_CNT_W_ADDR_GRAY,
  i_CLR_CNT_W_ADDR_GRAY => w_CLR_CNT_W_ADDR_GRAY,
  o_DONE                => w_DONE,
  o_PIX_RDY             => w_PIX_RDY_MO1,
  o_OUT_PIXEL           => o_OUT_PIXEL
);

Control_Block1_i : Control_Block1
port map (
  i_CLK                 => i_CLK,
  i_RST                 => i_RST,
  i_START               => i_START,
  i_PIX_RDY_MO1         => w_PIX_RDY_MO1,
  i_DONE_MO1            => w_DONE,
  o_ENA_CNT_R_ADDR_GRAY => w_ENA_CNT_R_ADDR_GRAY,
  o_CLR_CNT_R_ADDR_GRAY => w_CLR_CNT_R_ADDR_GRAY,
  o_ENA_CNT_W_ADDR_GRAY => w_ENA_CNT_W_ADDR_GRAY,
  o_CLR_CNT_W_ADDR_GRAY => w_CLR_CNT_W_ADDR_GRAY,
  o_DONE                => o_DONE
);

o_PIX_RDY <= w_PIX_RDY_MO1;

end architecture;
