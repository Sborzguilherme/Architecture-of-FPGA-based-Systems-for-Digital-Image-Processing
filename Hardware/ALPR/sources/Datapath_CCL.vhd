----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    09/09/2018
-- File:    Datapath_CCL.vhd

-- CCL -> Connected components labeling
-- Operation implemented throgh template matching algorithm
-- A mask, generated from one of the results from the Morphological Closing, is used as template
-- This template is compared with all the par
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_CCL is
    generic(
        p_KERNEL_HEIGHT     : integer;
        p_KERNEL_WIDTH      : integer;
        p_INPUT_IMG_HEIGHT  : integer;
        p_INPUT_IMG_WIDTH   : integer
    );
    port(
        i_CLK                 : in  std_logic;
        i_RST                 : in  std_logic;
        i_START               : in  std_logic;
        i_VALID_PIXEL         : in  std_logic;
        i_INPUT_PIXEL         : in  std_logic;
        i_ENA_WRI_KER         : in  std_logic;
        i_ENA_CNT_BUF_FIL     : in  std_logic;
        i_CLR_CNT_BUF_FIL     : in  std_logic;
        i_ENA_CNT_KER_TOT     : in  std_logic;
        i_CLR_CNT_KER_TOT     : in  std_logic;
        i_ENA_CNT_KER_ROW     : in  std_logic;
        i_CLR_CNT_KER_ROW     : in  std_logic;
        i_ENA_CNT_INV_KER     : in  std_logic;
        i_CLR_CNT_INV_KER     : in  std_logic;
        o_BUFFERS_FILLED      : out std_logic;
        o_MAX_KER_TOT         : out std_logic;
        o_MAX_KER_ROW         : out std_logic;
        o_MAX_INV_KER         : out std_logic;
        o_COORD_X             : out std_logic_vector(15 downto 0);
        o_COORD_Y             : out std_logic_vector(15 downto 0)
    );
end Datapath_CCL;

architecture arch of Datapath_CCL is

  -- CONSTANTS
  constant c_OUT_IMG_WIDTH    : integer := p_INPUT_IMG_WIDTH  - (p_KERNEL_WIDTH-1);
  constant c_OUT_IMG_HEIGHT   : integer := p_INPUT_IMG_HEIGHT - (p_KERNEL_HEIGHT-1);
  constant c_ROW_BUF_SIZE     : integer := p_INPUT_IMG_WIDTH  - p_KERNEL_WIDTH;
  constant c_KERNEL_SIZE      : integer := p_KERNEL_WIDTH * p_KERNEL_HEIGHT;
  constant c_BUF_FIL          : integer := (p_INPUT_IMG_WIDTH * (p_KERNEL_HEIGHT-1) + p_KERNEL_WIDTH);
  constant c_WIN_TOT          : integer := c_OUT_IMG_HEIGHT * c_OUT_IMG_WIDTH;
  constant c_WIN_ROW          : integer := c_OUT_IMG_WIDTH;
  constant c_INV_WIN          : integer := p_KERNEL_WIDTH-1;

-- SIGNALS
  -- DRA
  signal w_ENA_WRI_KER : std_logic;
  signal w_OUT_KERNEL : std_logic_vector(c_KERNEL_SIZE-1 downto 0) := (others=> '0');

  -- Hamming Distance
  signal w_COUNT : std_logic_vector(15 downto 0);

  -- Registers
    -- ctrl
  signal w_ENA_REG_MAX_VALUE : std_logic;
  --signal w_ENA_REG_LIN_VALUE : std_logic;
  --signal w_ENA_REG_COL_VALUE : std_logic;
    -- data
  signal r_MAX_VALUE : std_logic_vector(15 downto 0);
  signal r_LIN_VALUE : std_logic_vector(15 downto 0);
  signal r_COL_VALUE : std_logic_vector(15 downto 0);

  -- Counter Coordinates
  -- ctrl
  signal w_ENA_SAVE_LINE : std_logic;
  signal w_ENA_SAVE_COL  : std_logic;
  signal w_CHANGE_LINE : std_logic;
  -- data
  signal w_CNT_LINE : integer;
  signal w_CNT_COL  : integer;
  signal w_LINE_STD : std_logic_vector(15 downto 0);
  signal w_COL_STD  : std_logic_vector(15 downto 0);

  -- Counter cycles
  -- ctrl
  signal w_ENA_CNT_BUF_FIL : std_logic;
  signal w_ENA_CNT_KER_TOT : std_logic;
  signal w_ENA_CNT_KER_ROW : std_logic;
  signal w_ENA_CNT_INV_KER : std_logic;
  -- data
  signal w_CNT_BUF_FIL      : integer;
  signal w_CNT_KER_TOT_OUT  : integer;
  signal w_CNT_KER_ROW_OUT  : integer;
  signal w_CNT_INV_KER_OUT  : integer;

begin

  w_ENA_WRI_KER     <= i_ENA_WRI_KER     and i_VALID_PIXEL;
  w_ENA_CNT_BUF_FIL <= i_ENA_CNT_BUF_FIL and i_VALID_PIXEL;
  w_ENA_CNT_KER_TOT <= i_ENA_CNT_KER_TOT and i_VALID_PIXEL;
  w_ENA_CNT_KER_ROW <= i_ENA_CNT_KER_ROW and i_VALID_PIXEL;
  w_ENA_CNT_INV_KER <= i_ENA_CNT_INV_KER and i_VALID_PIXEL;

  -- DRA
  DRA_Bin_i : DRA_Bin
  generic map (
    c_KERNEL_HEIGHT => p_KERNEL_HEIGHT,
    c_KERNEL_WIDTH  => p_KERNEL_WIDTH,
    c_KERNEL_SIZE   => c_KERNEL_SIZE,
    c_ROW_BUF_SIZE  => c_ROW_BUF_SIZE
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_INPUT_PIXEL => i_INPUT_PIXEL,
    i_ENA_WRI_KER => w_ENA_WRI_KER,
    o_OUT_KERNEL  => w_OUT_KERNEL
  );

  -- Hamming Similarity
  Hamming_Similarity_i : Hamming_Similarity
  generic map (
    p_MASK_SIZE => c_KERNEL_SIZE
  )
  port map (
    i_CLK => i_CLK,
    i_WINDOW => w_OUT_KERNEL,
    o_COUNT  => w_COUNT
  );

-- Verify if the current count of ones is smaller than the result in the reg
w_ENA_REG_MAX_VALUE <= '1' when w_COUNT > r_MAX_VALUE else '0';
--w_ENA_SAVE_COL      <= '1' when w_COUNT > r_MAX_VALUE else '0';
--w_ENA_SAVE_LINE     <= '1' when w_COUNT > r_MAX_VALUE else '0';

Reg_Max_Value : Reg
generic map (
  c_WIDTH => 16
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_ENA_REG_MAX_VALUE,
  i_CLR  => '0',
  i_DIN  => w_COUNT,
  o_DOUT => r_MAX_VALUE
);

-- Counter to control the current line being verified (i)
Counter_line : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_CHANGE_LINE,
  i_CLR => '0',
  o_Q   => w_CNT_LINE
);

w_LINE_STD <= std_logic_vector(to_unsigned(w_CNT_LINE, 16));

Reg_Lin_Value : Reg
generic map (
  c_WIDTH => 16
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_ENA_REG_MAX_VALUE,
  i_CLR  => '0',
  i_DIN  => w_LINE_STD,
  o_DOUT => o_COORD_X
);

-- Counter to control the current column being verified (j)
Counter_Column : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_KER_ROW,
  i_CLR => w_CHANGE_LINE,
  o_Q   => w_CNT_COL
);

w_COL_STD <= std_logic_vector(to_unsigned(w_CNT_COL, 16));

Reg_Col_Value : Reg
generic map (
  c_WIDTH => 16
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_ENA_REG_MAX_VALUE,
  i_CLR  => '0',
  i_DIN  => w_COL_STD,
  o_DOUT => o_COORD_Y
);

-- Counters to control the number of cycles in each state of the FSM
CNT_BUF_FIL : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_BUF_FIL,
  i_CLR => i_CLR_CNT_BUF_FIL,
  o_Q   => w_CNT_BUF_FIL
);

-- Total valid windows
CNT_TOT_VAL_WIN : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_KER_TOT,
  i_CLR => i_CLR_CNT_KER_TOT,
  o_Q   => w_CNT_KER_TOT_OUT
);

-- Total valid windows per row
CNT_WIN_VAL_ROW : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_KER_ROW,
  i_CLR => i_CLR_CNT_KER_ROW,
  o_Q   => w_CNT_KER_ROW_OUT
);

-- Total invalid windows per row
CNT_INV_WIN : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_INV_KER,
  i_CLR => i_CLR_CNT_INV_KER,
  o_Q   => w_CNT_INV_KER_OUT
);

o_BUFFERS_FILLED <= '1' when w_CNT_BUF_FIL     = c_BUF_FIL-1 else '0';
o_MAX_KER_TOT    <= '1' when w_CNT_KER_TOT_OUT = c_WIN_TOT-1 else '0';
w_CHANGE_LINE    <= '1' when w_CNT_KER_ROW_OUT = c_WIN_ROW-1 else '0';
o_MAX_INV_KER    <= '1' when w_CNT_INV_KER_OUT = c_INV_WIN-1 else '0';

o_MAX_KER_ROW <= w_CHANGE_LINE;
end architecture;
