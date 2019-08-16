----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 15/08/2019
-- File: Datapath_Gauss_Hor.vhd

-- Horizontal Gaussian
-- DRA replaced by a shift register
-- Filter with only three multipliers
-- Constants values change (c_BUF_FIL, c_WIN_TOT)
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;
use work.Package_Constant.all;

entity Datapath_Gauss_Hor is
  generic(
      p_KERNEL_WIDTH     : integer;
      p_INPUT_IMG_WIDTH  : integer;
      p_INPUT_IMG_HEIGHT : integer
  );
port(
  i_CLK                 : in  std_logic;
  i_RST                 : in  std_logic;
  i_INPUT_PIXEL         : in  fixed;
  i_VALID_PIXEL         : in  std_logic;
  i_ENA_CNT_KER_TOT     : in  std_logic;
  i_CLR_CNT_KER_TOT     : in  std_logic;
  i_ENA_CNT_KER_ROW     : in  std_logic;
  i_CLR_CNT_KER_ROW     : in  std_logic;
  i_ENA_CNT_INV_KER     : in  std_logic;
  i_CLR_CNT_INV_KER     : in  std_logic;
  i_ENA_CNT_BUF_FIL     : in  std_logic;
  i_CLR_CNT_BUF_FIL     : in  std_logic;
  i_ENA_WRI_KER         : in  std_logic;
  i_ENA_WRI_REG         : in  std_logic;
  o_MAX_KER_TOT         : out std_logic;
  o_MAX_KER_ROW         : out std_logic;
  o_MAX_INV_KER         : out std_logic;
  o_BUFFERS_FILLED      : out std_logic;
  o_OUT_PIXEL		        : out fixed
);
end entity Datapath_Gauss_Hor;

architecture  arch of Datapath_Gauss_Hor is
  constant c_OUT_IMG_WIDTH    : integer := p_INPUT_IMG_WIDTH - (p_KERNEL_WIDTH-1);
  constant c_OUT_IMG_HEIGHT   : integer := p_INPUT_IMG_HEIGHT;
  --constant c_ROW_BUF_SIZE     : integer := p_INPUT_IMG_WIDTH - p_KERNEL_WIDTH;
  constant c_KERNEL_SIZE      : integer := p_KERNEL_WIDTH;
  constant c_BUF_FIL          : integer := p_KERNEL_WIDTH;
  constant c_WIN_TOT          : integer := c_OUT_IMG_HEIGHT * c_OUT_IMG_WIDTH;
  constant c_WIN_ROW          : integer := c_OUT_IMG_WIDTH;
  constant c_INV_WIN          : integer := p_KERNEL_WIDTH-1;

  signal w_DRA_OUT            : fixed_vector(c_KERNEL_SIZE-1 downto 0);
  signal w_WEIGHTS            : fixed_vector(c_KERNEL_SIZE-1 downto 0);
  signal w_FILTER_OUT         : fixed;

  -- Counter signals
  signal w_CNT_BUF_FIL        : integer := 0;
  signal w_CNT_KER_TOT_OUT    : integer := 0;
  signal w_CNT_KER_ROW_OUT    : integer := 0;
  signal w_CNT_INV_KER_OUT    : integer := 0;

  signal w_ENA_WR             : std_logic;
  signal w_ENA_WK             : std_logic;
  signal w_ENA_BF             : std_logic;
  signal w_ENA_TW             : std_logic;
  signal w_ENA_RW             : std_logic;
  signal w_ENA_IW             : std_logic;

begin

  w_ENA_WR <= i_ENA_WRI_REG and i_VALID_PIXEL;
  w_ENA_WK <= i_ENA_WRI_KER and i_VALID_PIXEL;

-- Delay row buffer (becomes a shift register once the window is now an array)
  DRA_Hor_i : DRA_Hor
  generic map (
    c_SIZE      => p_KERNEL_WIDTH,
    c_DATA_SIZE => MSB+LSB
  )
  port map (
    i_CLK      => i_CLK,
    i_RST      => i_RST,
    i_ENA      => w_ENA_WK,
    i_CLR      => '0',
    i_DATA_IN  => i_INPUT_PIXEL,
    o_DATA_OUT => w_DRA_OUT
  );

-- Operation
  g_filter : if p_KERNEL_WIDTH = 3 generate
    -- Horizontal Gaussian Filter 3x3
    Filter_Sep_3_i : Filter_Sep_3
    generic map (
      p_FILTER_SIZE => c_KERNEL_SIZE
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_REG => w_ENA_WR,
      i_KERNEL  => w_DRA_OUT,
      i_WEIGHTS => c_Gaussian_Kernel_3_Hor,
      o_RESULT  => o_OUT_PIXEL
    );

  elsif p_KERNEL_WIDTH = 5 generate
    -- Horizontal Gaussian Filter 5x5
    Filter_Sep_5_i : Filter_Sep_5
    generic map (
      p_FILTER_SIZE => c_KERNEL_SIZE
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_REG => w_ENA_WR,
      i_KERNEL  => w_DRA_OUT,
      i_WEIGHTS => c_Gaussian_Kernel_5_Hor,
      o_RESULT  => o_OUT_PIXEL
    );

  else generate
    -- Horizontal Gaussian Filter 7x7
    Filter_Sep_7_i : Filter_Sep_7
    generic map (
      p_FILTER_SIZE => c_KERNEL_SIZE
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_REG => w_ENA_WR,
      i_KERNEL  => w_DRA_OUT,
      i_WEIGHTS => c_Gaussian_Kernel_7_Hor,
      o_RESULT  => o_OUT_PIXEL
    );

  end generate;
  -------------------------- COMPARERS AND COUNTERS ------------------------------
 -- Only counts when a valid pixel arrives
  w_ENA_BF          <= i_ENA_CNT_BUF_FIL      and i_VALID_PIXEL;
  w_ENA_TW          <= i_ENA_CNT_KER_TOT      and i_VALID_PIXEL;
  w_ENA_RW          <= i_ENA_CNT_KER_ROW      and i_VALID_PIXEL;
  w_ENA_IW          <= i_ENA_CNT_INV_KER      and i_VALID_PIXEL;

  CNT_BUF_FIL : Counter
  port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_BF,
  i_CLR => i_CLR_CNT_BUF_FIL,
  o_Q   => w_CNT_BUF_FIL
  );

  COMP_BUF_FIL : Comparator
  port map (
  i_A  => w_CNT_BUF_FIL,
  i_B  => c_BUF_FIL-1,
  o_EQ => o_BUFFERS_FILLED
  );

  -- Total valid windows
  CNT_TOT_VAL_WIN : Counter
  port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_TW,
  i_CLR => i_CLR_CNT_KER_TOT,
  o_Q   => w_CNT_KER_TOT_OUT
  );

  COMP_TOT_VAL_WIN : Comparator
  port map (
  i_A  => w_CNT_KER_TOT_OUT,
  i_B  => c_WIN_TOT-1,
  o_EQ => o_MAX_KER_TOT
  );

  -- Total valid windows per row
  CNT_WIN_VAL_ROW : Counter
  port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_RW,
  i_CLR => i_CLR_CNT_KER_ROW,
  o_Q   => w_CNT_KER_ROW_OUT
  );

  COMP_ROW_VAL_WIN : Comparator
  port map (
  i_A  => w_CNT_KER_ROW_OUT,
  i_B  => c_WIN_ROW-1,
  o_EQ => o_MAX_KER_ROW
  );

  -- Total invalid windows per row
  CNT_INV_WIN : Counter
  port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_IW,
  i_CLR => i_CLR_CNT_INV_KER,
  o_Q   => w_CNT_INV_KER_OUT
  );

  COMP_TOT_INV_WIN : Comparator
  port map (
  i_A  => w_CNT_INV_KER_OUT,
  i_B  => c_INV_WIN-1,
  o_EQ => o_MAX_INV_KER
  );

end architecture;
