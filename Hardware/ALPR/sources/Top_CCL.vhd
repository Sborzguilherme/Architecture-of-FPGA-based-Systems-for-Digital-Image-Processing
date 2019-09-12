----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    09/09/2019
-- File:    Top_MC_Pipeline.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_CCL is
generic(
    p_KERNEL_HEIGHT    : integer := c_MASK_HEIGHT;
    p_KERNEL_WIDTH     : integer := c_MASK_WIDTH;
    p_INPUT_IMG_WIDTH  : integer := c_INPUT_IMG_WIDTH_CCL;
    p_INPUT_IMG_HEIGHT : integer := c_INPUT_IMG_HEIGHT_CCL
);
port(
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_START       : in  std_logic;
    i_VALID_PIXEL : in  std_logic;
    i_INPUT_PIXEL : in  std_logic;
    o_DONE        : out std_logic;
    o_COORD_X     : out std_logic_vector(15 downto 0);
    o_COORD_Y     : out std_logic_vector(15 downto 0)
);
end Top_CCL;

architecture arch of Top_CCL is

  signal w_ENA_WRI_KER     : std_logic;
  signal w_ENA_CNT_BUF_FIL : std_logic;
  signal w_CLR_CNT_BUF_FIL : std_logic;
  signal w_ENA_CNT_KER_TOT : std_logic;
  signal w_CLR_CNT_KER_TOT : std_logic;
  signal w_ENA_CNT_KER_ROW : std_logic;
  signal w_CLR_CNT_KER_ROW : std_logic;
  signal w_ENA_CNT_INV_KER : std_logic;
  signal w_CLR_CNT_INV_KER : std_logic;
  signal w_BUFFERS_FILLED  : std_logic;
  signal w_MAX_KER_TOT     : std_logic;
  signal w_MAX_KER_ROW     : std_logic;
  signal w_MAX_INV_KER     : std_logic;

begin

  Datapath_CCL_i : Datapath_CCL
  generic map (
    p_KERNEL_HEIGHT    => p_KERNEL_HEIGHT,
    p_KERNEL_WIDTH     => p_KERNEL_WIDTH,
    p_INPUT_IMG_HEIGHT => p_INPUT_IMG_HEIGHT,
    p_INPUT_IMG_WIDTH  => p_INPUT_IMG_WIDTH
  )
  port map (
    i_CLK             => i_CLK,
    i_RST             => i_RST,
    i_START           => i_START,
    i_VALID_PIXEL     => i_VALID_PIXEL,
    i_INPUT_PIXEL     => i_INPUT_PIXEL,
    i_ENA_WRI_KER     => w_ENA_WRI_KER,
    i_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
    i_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
    i_ENA_CNT_KER_TOT => w_ENA_CNT_KER_TOT,
    i_CLR_CNT_KER_TOT => w_CLR_CNT_KER_TOT,
    i_ENA_CNT_KER_ROW => w_ENA_CNT_KER_ROW,
    i_CLR_CNT_KER_ROW => w_CLR_CNT_KER_ROW,
    i_ENA_CNT_INV_KER => w_ENA_CNT_INV_KER,
    i_CLR_CNT_INV_KER => w_CLR_CNT_INV_KER,
    o_BUFFERS_FILLED  => w_BUFFERS_FILLED,
    o_MAX_KER_TOT     => w_MAX_KER_TOT,
    o_MAX_KER_ROW     => w_MAX_KER_ROW,
    o_MAX_INV_KER     => w_MAX_INV_KER,
    o_COORD_X         => o_COORD_X,
    o_COORD_Y         => o_COORD_Y
  );

  Control_CCL_i : Control_CCL
  port map (
    i_CLK             => i_CLK,
    i_RST             => i_RST,
    i_START           => i_START,
    i_BUFFERS_FILLED  => w_BUFFERS_FILLED,
    i_MAX_KER_TOT     => w_MAX_KER_TOT,
    i_MAX_KER_ROW     => w_MAX_KER_ROW,
    i_MAX_INV_KER     => w_MAX_INV_KER,
    o_ENA_WRI_KER     => w_ENA_WRI_KER,
    o_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
    o_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
    o_ENA_CNT_KER_TOT => w_ENA_CNT_KER_TOT,
    o_CLR_CNT_KER_TOT => w_CLR_CNT_KER_TOT,
    o_ENA_CNT_KER_ROW => w_ENA_CNT_KER_ROW,
    o_CLR_CNT_KER_ROW => w_CLR_CNT_KER_ROW,
    o_ENA_CNT_INV_KER => w_ENA_CNT_INV_KER,
    o_CLR_CNT_INV_KER => w_CLR_CNT_INV_KER,
    o_DONE            => o_DONE
  );

end architecture;
