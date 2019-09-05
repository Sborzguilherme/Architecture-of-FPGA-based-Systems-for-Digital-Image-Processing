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

entity Top_Block2 is
    generic(
      c_WIDTH_GRAY_PIXEL  : integer := 8;  -- GRAY  8 bits
      c_INPUT_IMG_HEIGHT  : integer := c_INPUT_IMG_WIDTH_MO1;
      c_INPUT_IMG_WIDTH   : integer := c_INPUT_IMG_WIDTH_MO1
    );
    port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_START       : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_DONE_BLOCK1 : in std_logic;
      i_INPUT_PIXEL : in std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out std_logic
    );
end Top_Block2;

architecture arch of Top_Block2 is

signal w_ENA_CNT_R_ADDR_SUB  : std_logic;
signal w_CLR_CNT_R_ADDR_SUB  : std_logic;
signal w_ENA_CNT_W_ADDR_SUB  : std_logic;
signal w_CLR_CNT_W_ADDR_SUB  : std_logic;
signal w_DONE_OTSU           : std_logic;
signal w_MAX_PIX             : std_logic;
signal w_PIX_RDY             : std_logic;

begin

  Datapath_Block2_i : Datapath_Block2
  generic map (
    c_WIDTH_GRAY_PIXEL => c_WIDTH_GRAY_PIXEL,
    c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH,
    c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT
  )
  port map (
    i_CLK                => i_CLK,
    i_RST                => i_RST,
    i_START              => i_START,
    i_VALID_PIXEL        => i_VALID_PIXEL,
    i_INPUT_PIXEL        => i_INPUT_PIXEL,
    i_ENA_CNT_R_ADDR_SUB => w_ENA_CNT_R_ADDR_SUB,
    i_CLR_CNT_R_ADDR_SUB => w_CLR_CNT_R_ADDR_SUB,
    i_ENA_CNT_W_ADDR_SUB => w_ENA_CNT_W_ADDR_SUB,
    i_CLR_CNT_W_ADDR_SUB => w_CLR_CNT_W_ADDR_SUB,
    o_DONE_OTSU          => w_DONE_OTSU,
    o_MAX_PIX            => w_MAX_PIX,
    o_OUT_PIXEL          => o_OUT_PIXEL
  );

  Control_Block2_i : Control_Block2
port map (
  i_CLK                => i_CLK,
  i_RST                => i_RST,
  i_START              => i_START,
  i_DONE_BLOCK1        => i_DONE_BLOCK1,
  i_DONE_OTSU          => w_DONE_OTSU,
  i_MAX_PIX            => w_MAX_PIX,
  o_ENA_CNT_R_ADDR_SUB => w_ENA_CNT_R_ADDR_SUB,
  o_CLR_CNT_R_ADDR_SUB => w_CLR_CNT_R_ADDR_SUB,
  o_ENA_CNT_W_ADDR_SUB => w_ENA_CNT_W_ADDR_SUB,
  o_CLR_CNT_W_ADDR_SUB => w_CLR_CNT_W_ADDR_SUB,
  o_PIX_RDY            => w_PIX_RDY,
  o_DONE               => o_DONE
);


Flip_Flop_i : Flip_Flop
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_PIX_RDY,
  i_CLR  => '0',
  i_DIN  => w_PIX_RDY,
  o_DOUT => o_PIX_RDY
);

end architecture;
