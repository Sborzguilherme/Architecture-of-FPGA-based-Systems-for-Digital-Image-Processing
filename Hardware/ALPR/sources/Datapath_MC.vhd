-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    15/02/2018
-- File:    Datapath_MO2.vhd

-- In this block the Erode operation is realized, independent from the dilate operation
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_MC is
    generic(
        c_KERNEL_HEIGHT    : integer;
        c_KERNEL_WIDTH     : integer;
        c_INPUT_IMG_WIDTH  : integer;
        c_INPUT_IMG_HEIGHT : integer;
        s_SEL_OPERATION    : integer
    );
    port(
        i_CLK             : in  std_logic;
        i_RST             : in  std_logic;
        i_INPUT_PIXEL     : in  std_logic;
        i_VALID_PIXEL     : in  std_logic;
        i_ENA_CNT_KER_TOT : in  std_logic;
        i_CLR_CNT_KER_TOT : in  std_logic;
        i_ENA_CNT_KER_ROW : in  std_logic;
        i_CLR_CNT_KER_ROW : in  std_logic;
        i_ENA_CNT_INV_KER : in  std_logic;
        i_CLR_CNT_INV_KER : in  std_logic;
        i_ENA_CNT_BUF_FIL : in  std_logic;
        i_CLR_CNT_BUF_FIL : in  std_logic;
        i_ENA_WRI_KER     : in  std_logic;
        o_MAX_KER_TOT     : out std_logic;
        o_MAX_KER_ROW     : out std_logic;
        o_MAX_INV_KER     : out std_logic;
        o_BUFFERS_FILLED  : out std_logic;
        o_OUT_PIXEL       : out std_logic
    );
end Datapath_MC;

architecture arch of Datapath_MC is

    constant c_OUT_IMG_WIDTH    : integer := c_INPUT_IMG_WIDTH - (c_KERNEL_WIDTH-1);
    constant c_OUT_IMG_HEIGHT   : integer := c_INPUT_IMG_HEIGHT - (c_KERNEL_HEIGHT-1);
    constant c_ROW_BUF_SIZE     : integer := c_INPUT_IMG_WIDTH - c_KERNEL_WIDTH;
    constant c_KERNEL_SIZE      : integer := c_KERNEL_WIDTH * c_KERNEL_HEIGHT;
    constant c_BUF_FIL          : integer := (c_INPUT_IMG_WIDTH * (c_KERNEL_HEIGHT-1) + c_KERNEL_WIDTH);
    constant c_WIN_TOT          : integer := c_OUT_IMG_HEIGHT * c_OUT_IMG_WIDTH;
    constant c_WIN_ROW          : integer := c_OUT_IMG_WIDTH;
    constant c_INV_WIN          : integer := c_KERNEL_WIDTH-1;

    signal w_DRA_OUT        : std_logic_vector(0 to c_KERNEL_SIZE-1); -- Output from kernel
    signal w_ENA_WRI_KER    : std_logic;

    -- Comparer signals
    signal w_CNT_BUF_FIL     : integer := 0;
    signal w_CNT_KER_TOT_OUT : integer := 0;
    signal w_CNT_KER_ROW_OUT : integer := 0;
    signal w_CNT_INV_KER_OUT : integer := 0;
begin

  w_ENA_WRI_KER <= i_VALID_PIXEL and i_ENA_WRI_KER;

-- Generic Delay Row
DRA_i : DRA_Bin
generic map (
  c_KERNEL_HEIGHT => c_KERNEL_HEIGHT,
  c_KERNEL_WIDTH  => c_KERNEL_WIDTH,
  c_KERNEL_SIZE   => c_KERNEL_SIZE,
  c_ROW_BUF_SIZE  => c_ROW_BUF_SIZE
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_INPUT_PIXEL => i_INPUT_PIXEL,
  i_ENA_WRI_KER => w_ENA_WRI_KER,
  o_OUT_KERNEL  => w_DRA_OUT
);

SELECT_MORPH_OP : if (s_SEL_OPERATION = 0) generate

-- Erode
  erode_op : entity work.operation_MC(erode)
  generic map (
    c_KERNEL_SIZE => c_KERNEL_SIZE
  )
  port map (
    i_INPUT => w_DRA_OUT,
    o_DOUT  => o_OUT_PIXEL
 );

else generate

-- Dilate
  dilate_op : entity work.operation_MC(dilate)
  generic map (
    c_KERNEL_SIZE => c_KERNEL_SIZE
  )
  port map (
    i_INPUT => w_DRA_OUT,
    o_DOUT  => o_OUT_PIXEL
  );
end generate;
-------------------------- COMPARERS AND COUNTERS ------------------------------
CNT_BUF_FIL : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_BUF_FIL and i_VALID_PIXEL,
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
  i_ENA => i_ENA_CNT_KER_TOT and i_VALID_PIXEL,
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
  i_ENA => i_ENA_CNT_KER_ROW and i_VALID_PIXEL,
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
  i_ENA => i_ENA_CNT_INV_KER and i_VALID_PIXEL,
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
