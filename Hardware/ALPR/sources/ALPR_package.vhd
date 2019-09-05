-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    05/02/2019
-- File:    ALPR_package.vhd

-- This package contains the constants, types ans components needed for the ALPR operations implemented
-- ALPR operations implemented:
-- Morphological Opening 1 - Aplied to a 320x240 grayscale image | Kernel size used - [9x19] -- Done
-- Morphological Opening 2 - Aplied to a 284x224 binay Image     | Kernel size used - [3x3]
-- Morphological Closing   - Aplied to a 280x220 binay Image     | Kernel size used - [5x15]
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ALPR_package is
---------------------------- Integer Constants ---------------------------------
----------------------- Morphological Opening 1 Constants ----------------------
-- Width Data
constant c_WIDTH_DATA_MO1 : integer := 8;          -- Grayscale image

-- Input Image size
constant c_INPUT_IMG_HEIGHT_MO1   : integer := 240;
constant c_INPUT_IMG_WIDTH_MO1    : integer := 320;
-- Ram size
constant c_ADDR_RAM_SIZE_MO1 : integer := 17;

-- Kernel
constant c_KERNEL_HEIGHT_MO1 : integer := 9;
constant c_KERNEL_WIDTH_MO1  : integer := 19;

-- Output image MO1
constant c_ERODED_IMG_HEIGHT_MO1 : integer := c_INPUT_IMG_HEIGHT_MO1  - (c_KERNEL_HEIGHT_MO1 - 1); -- 302
constant c_ERODED_IMG_WIDTH_MO1  : integer := c_INPUT_IMG_WIDTH_MO1   - (c_KERNEL_WIDTH_MO1  - 1); -- 232
constant c_OUT_IMG_HEIGHT_MO1    : integer := c_ERODED_IMG_HEIGHT_MO1 - (c_KERNEL_HEIGHT_MO1 - 1); -- 284
constant c_OUT_IMG_WIDTH_MO1     : integer := c_ERODED_IMG_WIDTH_MO1  - (c_KERNEL_WIDTH_MO1  - 1); -- 224

-- Row buffer size (Image Width - Kernel Width)
--constant c_ROW_BUF_SIZE_MO1_ERO  : integer := c_INPUT_IMG_WIDTH_MO1 - c_KERNEL_WIDTH_MO1;   -- 301
--constant c_ROW_BUF_SIZE_MO1_DIL  : integer := c_ERODED_IMG_WIDTH_MO1 - c_KERNEL_WIDTH_MO1;  -- 283

-- Cycles Counting
--constant c_INV_KER_MAX_MO1 	    : integer := c_KERNEL_WIDTH_MO1 - 1; -- 18

  -- Erosion -> Input image 320 x 240 / Output image 302 x 232
--constant c_KER_TOT_MAX_MO1_ERO 	: integer := c_ERODED_IMG_HEIGHT_MO1 * c_ERODED_IMG_WIDTH_MO1;  --70064; -- Out_Img_height * Out_Img_width
--constant c_KER_ROW_MAX_MO1_ERO 	: integer := c_INPUT_IMG_WIDTH_MO1 - (c_KERNEL_WIDTH_MO1 - 1);  --302;   -- Input_Img_width - kernel_width
--constant c_BUF_FIL_MAX_MO1_ERO 	: integer := (c_INPUT_IMG_WIDTH_MO1 * (c_KERNEL_HEIGHT_MO1-1) + c_KERNEL_WIDTH_MO1);    --2579;  -- (Input_Img_width * n_row_buffers) + kernel_width --> n_row_buffers = kernel_height - 1

  -- Dilation -> Input image 302 x 232 / Output image 284 x 224
--constant c_KER_TOT_MAX_MO1_DIL 	: integer := c_OUT_IMG_HEIGHT_MO1 * c_OUT_IMG_WIDTH_MO1;         --63616;
--constant c_KER_ROW_MAX_MO1_DIL 	: integer := c_ERODED_IMG_WIDTH_MO1 - (c_KERNEL_WIDTH_MO1 - 1);  --284;
--constant c_BUF_FIL_MAX_MO1_DIL 	: integer := (c_ERODED_IMG_WIDTH_MO1 * (c_KERNEL_HEIGHT_MO1-1) + c_KERNEL_WIDTH_MO1);  --2435;

------------------------- Morphological Opening 2 Constants --------------------
-- Input Image 224 x 284 / Output Image 220 x 280 (61600)

-- Width Data
constant c_WIDTH_DATA_MO2 : integer := 1;          -- Binary image

-- Input Image size
constant c_INPUT_IMG_WIDTH_MO2    : integer := c_OUT_IMG_WIDTH_MO1;
constant c_INPUT_IMG_HEIGHT_MO2   : integer := c_OUT_IMG_HEIGHT_MO1;

-- Kernel
constant c_KERNEL_HEIGHT_MO2 : integer := 3;
constant c_KERNEL_WIDTH_MO2  : integer := 3;

constant c_OUT_IMG_HEIGHT_MO2 : integer := c_INPUT_IMG_HEIGHT_MO2 - ((c_KERNEL_HEIGHT_MO2 - 1)*2);
constant c_OUT_IMG_WIDTH_MO2  : integer := c_INPUT_IMG_WIDTH_MO2  - ((c_KERNEL_WIDTH_MO2  - 1)*2);

------------------------- Morphological Closing Constants --------------------
-- Input Image 220 x 280 / Output Image 212 x 252 (53424)
 constant c_WIDTH_DATA_MC     : integer := 1;       -- Binary image
 constant c_KERNEL_HEIGHT_MC  : integer := 5;
 constant c_KERNEL_WIDTH_MC   : integer := 15;

-- Input Image size
constant c_INPUT_IMG_WIDTH_MC    : integer := c_OUT_IMG_WIDTH_MO2;
constant c_INPUT_IMG_HEIGHT_MC   : integer := c_OUT_IMG_HEIGHT_MO2;

------------------------- OTSU Constants --------------------
--constant c_WIDTH_DATA_ACC_MEM : integer := 32;
--constant c_IMG_SIZE_CONV : std_logic_vector(31 downto 0) := x"47788000"; -- 63616.0
  -- FPU Constants
constant c_CNT_CYCLES_ADD_SUB : integer := 7;
constant c_CNT_CYCLES_DIV     : integer := 6;
constant c_CNT_CYCLES_CONV    : Integer := 6;
constant c_CNT_CYCLES_MULT    : integer := 5;
---------------------------- Subtypes -----------------------------
type t_KERNEL is array(integer range<>) of std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0); -- Type to hold the current kernel data
type t_RB is array(integer range<>) of std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);     -- Type for row_buffers
type t_ACC_MEM is array(integer range<>) of integer;
---------------------------- Components ------------------

-- Block used for the hw implementation of OTSU algorithm
component ACC_MEM
generic (
  c_SIZE_MEM   : integer;
  c_WIDTH_DATA : integer;
  c_WIDTH_ADDR : integer
);
port (
  i_CLK     : in  std_logic;
  i_RST     : in  std_logic;
  i_WRI_ENA : in  std_logic;
  i_ADDR    : in  std_logic_vector(c_WIDTH_ADDR-1 downto 0);
  o_ACC     : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
);
end component ACC_MEM;

component ACC
generic (
  c_WIDTH_INPUT_DATA  : integer;
  c_WIDTH_OUTPUT_DATA : integer
);
port (
  i_CLK  : in  std_logic;
  i_RST  : in  std_logic;
  i_ENA  : in  std_logic;
  i_CLR  : in  std_logic;
  i_DATA : in  std_logic_vector(c_WIDTH_INPUT_DATA-1 downto 0);
  o_Q    : out std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0)
);
end component ACC;


-- Enable output when inputs are equal
component Comparator
port (
  i_A  : in  integer;
  i_B  : in  integer;
  o_EQ : out std_logic
);
end component Comparator;

component Control_0_Stages
port (
  i_CLK             : in  std_logic;
  i_RST             : in  std_logic;
  i_START           : in  std_logic;
  i_BUFFERS_FILLED  : in  std_logic;
  i_MAX_KER_TOT     : in  std_logic;
  i_MAX_KER_ROW     : in  std_logic;
  i_MAX_INV_KER     : in  std_logic;
  o_ENA_CNT_KER_TOT : out std_logic;
  o_CLR_CNT_KER_TOT : out std_logic;
  o_ENA_CNT_KER_ROW : out std_logic;
  o_CLR_CNT_KER_ROW : out std_logic;
  o_ENA_CNT_INV_KER : out std_logic;
  o_CLR_CNT_INV_KER : out std_logic;
  o_ENA_CNT_BUF_FIL : out std_logic;
  o_CLR_CNT_BUF_FIL : out std_logic;
  o_ENA_WRI_KER     : out std_logic;
  o_PIX_RDY         : out std_logic;
  o_DONE            : out std_logic
);
end component Control_0_Stages;

component Control_2_Stages
port (
  i_CLK             : in  std_logic;
  i_RST             : in  std_logic;
  i_START           : in  std_logic;
  i_BUFFERS_FILLED  : in  std_logic;
  i_MAX_KER_TOT     : in  std_logic;
  i_MAX_KER_ROW     : in  std_logic;
  i_MAX_INV_KER     : in  std_logic;
  o_ENA_CNT_KER_TOT : out std_logic;
  o_CLR_CNT_KER_TOT : out std_logic;
  o_ENA_CNT_KER_ROW : out std_logic;
  o_CLR_CNT_KER_ROW : out std_logic;
  o_ENA_CNT_INV_KER : out std_logic;
  o_CLR_CNT_INV_KER : out std_logic;
  o_ENA_CNT_BUF_FIL : out std_logic;
  o_CLR_CNT_BUF_FIL : out std_logic;
  o_ENA_WRI_KER     : out std_logic;
  o_PIX_RDY         : out std_logic;
  o_DONE            : out std_logic
);
end component Control_2_Stages;

component Control_Block1
port (
  i_CLK                 : in  std_logic;
  i_RST                 : in  std_logic;
  i_START               : in  std_logic;
  i_PIX_RDY_MO1         : in  std_logic;
  i_DONE_MO1            : in  std_logic;
  o_ENA_CNT_R_ADDR_GRAY : out std_logic;
  o_CLR_CNT_R_ADDR_GRAY : out std_logic;
  o_ENA_CNT_W_ADDR_GRAY : out std_logic;
  o_CLR_CNT_W_ADDR_GRAY : out std_logic;
  o_DONE                : out std_logic
);
end component Control_Block1;


component Control_Block2
port (
  i_CLK                : in  std_logic;
  i_RST                : in  std_logic;
  i_START              : in  std_logic;
  i_DONE_BLOCK1        : in  std_logic;
  i_DONE_OTSU          : in  std_logic;
  i_MAX_PIX            : in  std_logic;
  o_ENA_CNT_R_ADDR_SUB : out std_logic;
  o_CLR_CNT_R_ADDR_SUB : out std_logic;
  o_ENA_CNT_W_ADDR_SUB : out std_logic;
  o_CLR_CNT_W_ADDR_SUB : out std_logic;
  o_PIX_RDY            : out std_logic;
  o_DONE               : out std_logic
);
end component Control_Block2;

component Control_Block3
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_PIX_RDY_SUB : in  std_logic;
  i_DONE_MO2    : in  std_logic;
  i_DONE_MC     : in  std_logic;
  o_VALID_MO2   : out std_logic;
  o_VALID_MC    : out std_logic;
  o_DONE        : out std_logic
);
end component Control_Block3;


component Control_OTSU
port (
  i_CLK                      : in  std_logic;
  i_RST                      : in  std_logic;
  i_START                    : in  std_logic;
  i_MAX_PIX                  : in  std_logic;
  i_TH_FOUND                 : in  std_logic;
  i_END_ADD_WB               : in  std_logic;
  i_END_WF                   : in  std_logic;
  i_END_ADD_SUM_B            : in  std_logic;
  i_END_SUB_MF               : in  std_logic;
  i_END_MF                   : in  std_logic;
  i_END_AUX_0_VAR_B          : in  std_logic;
  i_END_AUX_1_VAR_B          : in  std_logic;
  i_END_VAR_B                : in  std_logic;
  i_CONTINUE_WB              : in  std_logic;
  i_END_CONV                 : in  std_logic;
  i_LAST_PIXEL               : in  std_logic;
  o_SEL_MUX                  : out std_logic;
  o_WRI_ENA                  : out std_logic;
  o_WRI_WB                   : out std_logic;
  o_WRI_WF                   : out std_logic;
  o_WRI_SUM_B                : out std_logic;
  o_WRI_MB                   : out std_logic;
  o_WRI_MF                   : out std_logic;
  o_WRI_VAR_B                : out std_logic;
  o_WRI_VAR_MAX              : out std_logic;
  o_WRI_TH                   : out std_logic;
  o_WRI_CUR_HIST             : out std_logic;
  o_WRI_AUX_SUM_B            : out std_logic;
  o_WRI_AUX_MF               : out std_logic;
  o_WRI_AUX_SUB_MB_MF        : out std_logic;
  o_WRI_AUX_EXP_MB_MF        : out std_logic;
  o_WRI_AUX_MULT_WB_WF       : out std_logic;
  o_ENA_CNT_ADDR             : out std_logic;
  o_CLR_CNT_ADDR             : out std_logic;
  o_ENA_CNT_PIX              : out std_logic;
  o_CLR_CNT_PIX              : out std_logic;
  o_ENA_CNT_CALC_WB          : out std_logic;
  o_CLR_CNT_CALC_WB          : out std_logic;
  o_ENA_CNT_CALC_WF          : out std_logic;
  o_CLR_CNT_CALC_WF          : out std_logic;
  o_ENA_CNT_CALC_SUM_B       : out std_logic;
  o_CLR_CNT_CALC_SUM_B       : out std_logic;
  o_ENA_CNT_CALC_MB          : out std_logic;
  o_CLR_CNT_CALC_MB          : out std_logic;
  o_ENA_CNT_CALC_MF          : out std_logic;
  o_CLR_CNT_CALC_MF          : out std_logic;
  o_ENA_CNT_CALC_VAR_B       : out std_logic;
  o_CLR_CNT_CALC_VAR_B       : out std_logic;
  o_ENA_CNT_CALC_AUX_0_VAR_B : out std_logic;
  o_CLR_CNT_CALC_AUX_0_VAR_B : out std_logic;
  o_ENA_CNT_CALC_AUX_1_VAR_B : out std_logic;
  o_CLR_CNT_CALC_AUX_1_VAR_B : out std_logic;
  o_ENA_CNT_CONV             : out std_logic;
  o_CLR_CNT_CONV             : out std_logic;
  o_DONE                     : out std_logic
);
end component Control_OTSU;

component Control_System_ALPR
port (
  i_CLK                 : in  std_logic;
  i_RST                 : in  std_logic;
  i_START               : in  std_logic;
  i_PIX_RDY_MO1         : in  std_logic;
  i_DONE_MO1            : in  std_logic;
  i_DONE_OTSU           : in  std_logic;
  i_PIX_RDY_MO2         : in  std_logic;
  i_DONE_MC             : in  std_logic;
  o_ENA_CNT_R_ADDR_GRAY : out std_logic;
  o_CLR_CNT_R_ADDR_GRAY : out std_logic;
  o_ENA_CNT_W_ADDR_GRAY : out std_logic;
  o_CLR_CNT_W_ADDR_GRAY : out std_logic;
  o_ENA_CNT_R_ADDR_SUB  : out std_logic;
  o_CLR_CNT_R_ADDR_SUB  : out std_logic;
  o_ENA_CNT_W_ADDR_SUB  : out std_logic;
  o_CLR_CNT_W_ADDR_SUB  : out std_logic;
  o_ENA_WRI_RAM_SUB     : out std_logic;
  o_START_MO2           : out std_logic;
  o_VALID_PIXEL_OTSU    : out std_logic;
  o_VALID_PIXEL_MO2     : out std_logic;
  o_VALID_PIXEL_MC      : out std_logic;
  o_DONE                : out std_logic
);
end component Control_System_ALPR;

component Control_Top_Pipeline
port (
  i_CLK                : in  std_logic;
  i_RST                : in  std_logic;
  i_START              : in  std_logic;
  i_DONE_1_OP          : in  std_logic;
  i_DONE_2_OP          : in  std_logic;
  o_PIX_RDY_1_OP       : out std_logic;
  o_VALID_PIXEL_1ST_OP : out std_logic;
  o_DONE               : out std_logic
);
end component Control_Top_Pipeline;


-- component Control_Operation_MO2
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_START           : in  std_logic;
--   i_VALID_PIXEL     : in  std_logic;
--   i_BUFFERS_FILLED  : in  std_logic;
--   i_MAX_KER_TOT     : in  std_logic;
--   i_MAX_KER_ROW     : in  std_logic;
--   i_MAX_INV_KER     : in  std_logic;
--   o_ENA_CNT_KER_TOT : out std_logic;
--   o_CLR_CNT_KER_TOT : out std_logic;
--   o_ENA_CNT_KER_ROW : out std_logic;
--   o_CLR_CNT_KER_ROW : out std_logic;
--   o_ENA_CNT_INV_KER : out std_logic;
--   o_CLR_CNT_INV_KER : out std_logic;
--   o_ENA_CNT_BUF_FIL : out std_logic;
--   o_CLR_CNT_BUF_FIL : out std_logic;
--   o_ENA_WRI_KER     : out std_logic;
--   o_PIX_RDY         : out std_logic;
--   o_DONE            : out std_logic
-- );
-- end component Control_Operation_MO2;
--
--
-- component Control_Operation
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_START           : in  std_logic;
--   i_VALID_PIXEL     : in  std_logic;
--   i_BUFFERS_FILLED  : in  std_logic;
--   i_MAX_KER_TOT     : in  std_logic;
--   i_MAX_KER_ROW     : in  std_logic;
--   i_MAX_INV_KER     : in  std_logic;
--   o_ENA_CNT_KER_TOT : out std_logic;
--   o_CLR_CNT_KER_TOT : out std_logic;
--   o_ENA_CNT_KER_ROW : out std_logic;
--   o_CLR_CNT_KER_ROW : out std_logic;
--   o_ENA_CNT_INV_KER : out std_logic;
--   o_CLR_CNT_INV_KER : out std_logic;
--   o_ENA_CNT_BUF_FIL : out std_logic;
--   o_CLR_CNT_BUF_FIL : out std_logic;
--   o_ENA_WRI_KER     : out std_logic;
--   o_PIX_RDY         : out std_logic;
--   o_DONE            : out std_logic
-- );
-- end component Control_Operation;

-- FSM for the MO1
-- component Control
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_START           : in  std_logic;
--   i_BUFFERS_FILLED  : in  std_logic;
--   i_MAX_KER_TOT     : in  std_logic;
--   i_MAX_KER_ROW     : in  std_logic;
--   i_MAX_INV_KER     : in  std_logic;
--   i_LAST_OP         : in  std_logic;
--   o_ENA_CNT_KER_TOT : out std_logic;
--   o_CLR_CNT_KER_TOT : out std_logic;
--   o_ENA_CNT_KER_ROW : out std_logic;
--   o_CLR_CNT_KER_ROW : out std_logic;
--   o_ENA_CNT_INV_KER : out std_logic;
--   o_CLR_CNT_INV_KER : out std_logic;
--   o_ENA_CNT_BUF_FIL : out std_logic;
--   o_CLR_CNT_BUF_FIL : out std_logic;
--   o_ENA_WRI_KER     : out std_logic;
--   o_CHANGE_OP       : out std_logic;
--   o_PIX_RDY         : out std_logic;
--   o_DONE            : out std_logic
-- );
-- end component Control;

-- When i_ENA is active the o_Q signal is incremented
component Counter
port (
  i_CLK : in  std_logic;
  i_RST : in  std_logic;
  i_ENA : in  std_logic;
  i_CLR : in  std_logic;
  o_Q   : out integer
);
end component Counter;

component Datapath_Block1
generic (
  c_WIDTH_INPUT_PIXEL : integer;
  c_WIDTH_GRAY_PIXEL  : integer;
  c_KERNEL_HEIGHT_MO1 : integer;
  c_KERNEL_WIDTH_MO1  : integer;
  c_INPUT_IMG_HEIGHT  : integer;
  c_INPUT_IMG_WIDTH   : integer
);
port (
  i_CLK                 : in  std_logic;
  i_RST                 : in  std_logic;
  i_START               : in  std_logic;
  i_VALID_PIXEL         : in  std_logic;
  i_INPUT_PIXEL         : in  std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
  i_ENA_CNT_R_ADDR_GRAY : in  std_logic;
  i_CLR_CNT_R_ADDR_GRAY : in  std_logic;
  i_ENA_CNT_W_ADDR_GRAY : in  std_logic;
  i_CLR_CNT_W_ADDR_GRAY : in  std_logic;
  o_DONE                : out std_logic;
  o_PIX_RDY             : out std_logic;
  o_OUT_PIXEL           : out std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0)
);
end component Datapath_Block1;

component Datapath_Block2
generic (
  c_WIDTH_GRAY_PIXEL : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer
);
port (
  i_CLK                : in  std_logic;
  i_RST                : in  std_logic;
  i_START              : in  std_logic;
  i_VALID_PIXEL        : in  std_logic;
  i_INPUT_PIXEL        : in  std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  i_ENA_CNT_R_ADDR_SUB : in  std_logic;
  i_CLR_CNT_R_ADDR_SUB : in  std_logic;
  i_ENA_CNT_W_ADDR_SUB : in  std_logic;
  i_CLR_CNT_W_ADDR_SUB : in  std_logic;
  o_DONE_OTSU          : out std_logic;
  o_MAX_PIX            : out std_logic;
  o_OUT_PIXEL          : out std_logic
);
end component Datapath_Block2;

component Datapath_Block3
generic (
  c_KERNEL_HEIGHT_MO2    : integer;
  c_KERNEL_WIDTH_MO2     : integer;
  c_INPUT_IMG_HEIGHT_MO2 : integer;
  c_INPUT_IMG_WIDTH_MO2  : integer;
  c_KERNEL_HEIGHT_MC     : integer;
  c_KERNEL_WIDTH_MC      : integer;
  c_INPUT_IMG_HEIGHT_MC  : integer;
  c_INPUT_IMG_WIDTH_MC   : integer
);
port (
  i_CLK             : in  std_logic;
  i_RST             : in  std_logic;
  i_PIX_RDY_SUB     : in  std_logic;
  i_VALID_PIXEL_MO2 : in  std_logic;
  i_VALID_PIXEL_MC  : in  std_logic;
  i_INPUT_PIXEL     : in  std_logic;
  o_DONE_MO2        : out std_logic;
  o_DONE_MC         : out std_logic;
  o_PIX_RDY         : out std_logic;
  o_OUT_PIXEL       : out std_logic
);
end component Datapath_Block3;


-- -- Datapath for the MO1
-- component Datapath_MO1
-- generic (
--   c_WIDTH_DATA       : integer;
--   c_KERNEL_HEIGHT    : integer;
--   c_KERNEL_WIDTH     : integer;
--   c_KERNEL_SIZE      : integer;
--   c_ROW_BUF_SIZE_ERO : integer;
--   c_ROW_BUF_SIZE_DIL : integer;
--   c_ADDR_RAM_SIZE    : integer
-- );
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_INPUT_PIXEL     : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
--   i_ENA_CNT_KER_TOT : in  std_logic;
--   i_CLR_CNT_KER_TOT : in  std_logic;
--   i_ENA_CNT_KER_ROW : in  std_logic;
--   i_CLR_CNT_KER_ROW : in  std_logic;
--   i_ENA_CNT_INV_KER : in  std_logic;
--   i_CLR_CNT_INV_KER : in  std_logic;
--   i_ENA_CNT_BUF_FIL : in  std_logic;
--   i_CLR_CNT_BUF_FIL : in  std_logic;
--   i_ENA_WRI_KER     : in  std_logic;
--   i_CHANGE_OP       : in  std_logic;
--   o_LAST_OP         : out std_logic;
--   o_MAX_KER_TOT     : out std_logic;
--   o_MAX_KER_ROW     : out std_logic;
--   o_MAX_INV_KER     : out std_logic;
--   o_BUFFERS_FILLED  : out std_logic;
--   o_OUT_PIXEL       : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
-- );
-- end component Datapath_MO1;

component Datapath_MC
generic (
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
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
end component Datapath_MC;


-- component Datapath_Operation_MO1
-- generic (
--   c_WIDTH_DATA       : integer;
--   c_KERNEL_HEIGHT    : integer;
--   c_KERNEL_WIDTH     : integer;
--   c_INPUT_IMG_WIDTH  : integer;
--   c_INPUT_IMG_HEIGHT : integer;
--   s_SEL_OPERATION    : integer
-- );
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_INPUT_PIXEL     : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
--   i_VALID_PIXEL     : in  std_logic;
--   i_ENA_CNT_KER_TOT : in  std_logic;
--   i_CLR_CNT_KER_TOT : in  std_logic;
--   i_ENA_CNT_KER_ROW : in  std_logic;
--   i_CLR_CNT_KER_ROW : in  std_logic;
--   i_ENA_CNT_INV_KER : in  std_logic;
--   i_CLR_CNT_INV_KER : in  std_logic;
--   i_ENA_CNT_BUF_FIL : in  std_logic;
--   i_CLR_CNT_BUF_FIL : in  std_logic;
--   i_ENA_WRI_KER     : in  std_logic;
--   o_MAX_KER_TOT     : out std_logic;
--   o_MAX_KER_ROW     : out std_logic;
--   o_MAX_INV_KER     : out std_logic;
--   o_BUFFERS_FILLED  : out std_logic;
--   o_OUT_PIXEL       : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
-- );
-- end component Datapath_Operation_MO1;

component Datapath_MO1
generic (
  c_WIDTH_DATA       : integer;
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
  i_CLK             : in  std_logic;
  i_RST             : in  std_logic;
  i_INPUT_PIXEL     : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
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
  o_OUT_PIXEL       : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
);
end component Datapath_MO1;


component Datapath_MO2
generic (
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
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
end component Datapath_MO2;

component Datapath_OTSU
generic (
  c_SIZE_MEM    : integer;
  c_WIDTH_PIXEL : integer;
  c_WIDTH_VAR   : integer
);
port (
  i_CLK                      : in  std_logic;
  i_RST                      : in  std_logic;
  i_PIXEL                    : in  std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  i_VALID_PIXEL              : in  std_logic;
  i_SEL_MUX                  : in  std_logic;
  i_WRI_ENA                  : in  std_logic;
  i_WRI_WB                   : in  std_logic;
  i_WRI_WF                   : in  std_logic;
  i_WRI_SUM_B                : in  std_logic;
  i_WRI_MB                   : in  std_logic;
  i_WRI_MF                   : in  std_logic;
  i_WRI_VAR_B                : in  std_logic;
  i_WRI_VAR_MAX              : in  std_logic;
  i_WRI_TH                   : in  std_logic;
  i_WRI_CUR_HIST             : in  std_logic;
  i_WRI_AUX_SUM_B            : in  std_logic;
  i_WRI_AUX_MF               : in  std_logic;
  i_WRI_AUX_SUB_MB_MF        : in  std_logic;
  i_WRI_AUX_EXP_MB_MF        : in  std_logic;
  i_WRI_AUX_MULT_WB_WF       : in  std_logic;
  i_ENA_CNT_ADDR             : in  std_logic;
  i_CLR_CNT_ADDR             : in  std_logic;
  i_ENA_CNT_PIX              : in  std_logic;
  i_CLR_CNT_PIX              : in  std_logic;
  i_ENA_CNT_CALC_WB          : in  std_logic;
  i_CLR_CNT_CALC_WB          : in  std_logic;
  i_ENA_CNT_CALC_WF          : in  std_logic;
  i_CLR_CNT_CALC_WF          : in  std_logic;
  i_ENA_CNT_CALC_SUM_B       : in  std_logic;
  i_CLR_CNT_CALC_SUM_B       : in  std_logic;
  i_ENA_CNT_CALC_MB          : in  std_logic;
  i_CLR_CNT_CALC_MB          : in  std_logic;
  i_ENA_CNT_CALC_MF          : in  std_logic;
  i_CLR_CNT_CALC_MF          : in  std_logic;
  i_ENA_CNT_CALC_VAR_B       : in  std_logic;
  i_CLR_CNT_CALC_VAR_B       : in  std_logic;
  i_ENA_CNT_CALC_AUX_0_VAR_B : in  std_logic;
  i_CLR_CNT_CALC_AUX_0_VAR_B : in  std_logic;
  i_ENA_CNT_CALC_AUX_1_VAR_B : in  std_logic;
  i_CLR_CNT_CALC_AUX_1_VAR_B : in  std_logic;
  i_ENA_CNT_CONV             : in  std_logic;
  i_CLR_CNT_CONV             : in  std_logic;
  o_END_ADD_WB               : out std_logic;
  o_END_WF                   : out std_logic;
  o_END_SUB_MF               : out std_logic;
  o_END_ADD_SUM_B            : out std_logic;
--  o_END_SUB_MF               : out std_logic;
  o_END_MF                   : out std_logic;
  o_END_AUX_0_VAR_B          : out std_logic;
  o_END_AUX_1_VAR_B          : out std_logic;
  o_END_VAR_B                : out std_logic;
  o_CONTINUE_WB              : out std_logic;
  o_MAX_PIX                  : out std_logic;
  o_END_CONV                 : out std_logic;
  o_LAST_PIXEL               : out std_logic;
  o_TH_FOUND                 : out std_logic;
  o_THRESHOLD                : out std_logic_vector(c_WIDTH_PIXEL-1 downto 0)
);
end component Datapath_OTSU;

component Datapath_System_ALPR
generic (
  c_WIDTH_INPUT_PIXEL : integer;
  c_WIDTH_GRAY_PIXEL  : integer;
  c_KERNEL_HEIGHT_MO1 : integer;
  c_KERNEL_WIDTH_MO1  : integer;
  c_KERNEL_HEIGHT_MO2 : integer;
  c_KERNEL_WIDTH_MO2  : integer;
  c_KERNEL_HEIGHT_MC  : integer;
  c_KERNEL_WIDTH_MC   : integer;
  c_INPUT_IMG_HEIGHT  : integer;
  c_INPUT_IMG_WIDTH   : integer;
  c_SIZE_MEM_OTSU     : integer
);
port (
  i_CLK                 : in  std_logic;
  i_RST                 : in  std_logic;
  i_START               : in  std_logic;
  i_VALID_PIXEL         : in  std_logic;
  i_INPUT_PIXEL         : in  std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
  i_ENA_CNT_R_ADDR_GRAY : in  std_logic;
  i_CLR_CNT_R_ADDR_GRAY : in  std_logic;
  i_ENA_CNT_W_ADDR_GRAY : in  std_logic;
  i_CLR_CNT_W_ADDR_GRAY : in  std_logic;
  i_ENA_CNT_R_ADDR_SUB  : in  std_logic;
  i_CLR_CNT_R_ADDR_SUB  : in  std_logic;
  i_ENA_CNT_W_ADDR_SUB  : in  std_logic;
  i_CLR_CNT_W_ADDR_SUB  : in  std_logic;
  i_ENA_WRI_RAM_SUB     : in  std_logic;
  i_START_MO2           : in  std_logic;
  i_VALID_PIXEL_OTSU    : in  std_logic;
  i_VALID_PIXEL_MO2     : in  std_logic;
  i_VALID_PIXEL_MC      : in  std_logic;
  o_DONE_MO1            : out std_logic;
  o_DONE_OTSU           : out std_logic;
  o_DONE_MO2            : out std_logic;
  o_DONE_MC             : out std_logic;
  o_PIX_RDY_MO1         : out std_logic;
  o_PIX_RDY_MO2         : out std_logic;
  o_PIX_RDY             : out std_logic;
  o_OUT_PIXEL           : out std_logic
);
end component Datapath_System_ALPR;

component ENA_RAM_GRAY
generic (
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_HEIGHT : integer;
  c_INPUT_IMG_WIDTH  : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  o_DONE        : out std_logic;
  o_VALID_ADDR  : out std_logic
);
end component ENA_RAM_GRAY;

component DRA_Bin
generic (
  c_KERNEL_HEIGHT : integer;
  c_KERNEL_WIDTH  : integer;
  c_KERNEL_SIZE   : integer;
  c_ROW_BUF_SIZE  : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  i_ENA_WRI_KER : in  std_logic;
  o_OUT_KERNEL  : out std_logic_vector(0 to c_KERNEL_SIZE-1)
);
end component DRA_Bin;

component DRA
generic (
  c_WIDTH_DATA    : integer;
  c_KERNEL_HEIGHT : integer;
  c_KERNEL_WIDTH  : integer;
  c_KERNEL_SIZE	  : integer;
  c_ROW_BUF_SIZE  : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
  i_ENA_WRI_KER : in  std_logic;
  o_OUT_KERNEL  : out t_KERNEL(0 to c_KERNEL_SIZE-1)
);
end component DRA;


-- component Datapath_Operation_MO2
-- generic (
--   c_KERNEL_HEIGHT    : integer;
--   c_KERNEL_WIDTH     : integer;
--   c_INPUT_IMG_WIDTH  : integer;
--   c_INPUT_IMG_HEIGHT : integer;
--   s_SEL_OPERATION    : integer
-- );
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_INPUT_PIXEL     : in  std_logic;
--   i_VALID_PIXEL     : in  std_logic;
--   i_ENA_CNT_KER_TOT : in  std_logic;
--   i_CLR_CNT_KER_TOT : in  std_logic;
--   i_ENA_CNT_KER_ROW : in  std_logic;
--   i_CLR_CNT_KER_ROW : in  std_logic;
--   i_ENA_CNT_INV_KER : in  std_logic;
--   i_CLR_CNT_INV_KER : in  std_logic;
--   i_ENA_CNT_BUF_FIL : in  std_logic;
--   i_CLR_CNT_BUF_FIL : in  std_logic;
--   i_ENA_WRI_KER     : in  std_logic;
--   o_MAX_KER_TOT     : out std_logic;
--   o_MAX_KER_ROW     : out std_logic;
--   o_MAX_INV_KER     : out std_logic;
--   o_BUFFERS_FILLED  : out std_logic;
--   o_OUT_PIXEL       : out std_logic
-- );
-- end component Datapath_Operation_MO2;

-- Outputs the kernel values | i_SEL_OPERATION select which one of the operation is being used
--i_SEL_OPERATION is needed to select which row_buffer is being used (2 row buffers with different sizes)
-- component Delay_Row_Arch
-- generic (
--   c_WIDTH_DATA       : integer;
--   c_KERNEL_HEIGHT    : integer;
--   c_KERNEL_WIDTH     : integer;
--   c_KERNEL_SIZE      : integer;
--   c_ROW_BUF_SIZE_ERO : integer;
--   c_ROW_BUF_SIZE_DIL : integer
-- );
-- port (
--   i_CLK             : in  std_logic;
--   i_RST             : in  std_logic;
--   i_INPUT_PIXEL     : in  std_logic_vector;
--   i_ENA_WRI_KER_ERO : in  std_logic;
--   i_ENA_WRI_KER_DIL : in  std_logic;
--   i_SEL_OPERATION   : in  std_logic;
--   o_OUT_KERNEL      : out t_KERNEL(0 to c_KERNEL_SIZE-1)
-- );
-- end component Delay_Row_Arch;

component Flip_Flop
port (
  i_CLK  : in  std_logic;
  i_RST  : in  std_logic;
  i_ENA  : in  std_logic;
  i_CLR  : in  std_logic;
  i_DIN  : in  std_logic;
  o_DOUT : out std_logic
);
end component Flip_Flop;

component FPU_ADD_SUB
port (
  add_sub : IN  STD_LOGIC;
  clock   : IN  STD_LOGIC;
  dataa   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  datab   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  result  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
  zero    : OUT STD_LOGIC
);
end component FPU_ADD_SUB;

component FPU_CONVERT
port (
  clock  : IN  STD_LOGIC;
  dataa  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
end component FPU_CONVERT;

component FPU_DIV
port (
  clock  : IN  STD_LOGIC;
  dataa  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  datab  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
end component FPU_DIV;

component FPU_MULT
port (
  clock  : IN  STD_LOGIC;
  dataa  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  datab  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
  result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
end component FPU_MULT;

component Greater_than
generic (
  c_WIDTH_DATA : integer
);
port (
  i_A  : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
  i_B  : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
  o_GT : out std_logic
);
end component Greater_than;

component Max_Min_3
generic (
  c_WIDTH : integer
);
port (
  i_INPUT : in  t_KERNEL(0 to 2);
  o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component Max_Min_3;

component Max_Min_9
generic (
  c_WIDTH : integer
);
port (
  i_CLK   : in std_logic;
  i_RST   : in std_logic;
  i_VALID_PIXEL : in std_logic;
  i_INPUT : in  t_KERNEL(0 to 8);
  o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component Max_Min_9;


component Max_Min_19
generic (
  c_WIDTH : integer
);
port (
  i_INPUT : in  t_KERNEL(0 to 18);
  o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component Max_Min_19;

-- Mux with integer as inputs/outputs
component Mux_2_1_int
port (
  i_SEL  : in  std_logic;
  i_DIN0 : in  integer;
  i_DIN1 : in  integer;
  o_DOUT : out integer
);
end component Mux_2_1_int;

-- Mux with std_logic_vector as inputs/outputs
component Mux_2_1
generic (
  p_WIDTH : integer
);
port (
  i_SEL  : in  std_logic;
  i_DIN0 : in  std_logic_vector(p_WIDTH-1 downto 0);
  i_DIN1 : in  std_logic_vector(p_WIDTH-1 downto 0);
  o_DOUT : out std_logic_vector(p_WIDTH-1 downto 0)
);
end component Mux_2_1;

component operation_MC
generic (
  c_KERNEL_SIZE : integer
);
port (
  i_INPUT : in  std_logic_vector(0 to c_KERNEL_SIZE-1);
  o_DOUT  : out std_logic
);
end component operation_MC;

component operation_MO1
generic (
  c_WIDTH       : integer;
  c_KERNEL_SIZE : integer
);
port (
  i_CLK   : in  std_logic;
  i_RST   : in  std_logic;
  i_VALID_PIXEL :in std_logic;
  i_INPUT : in  t_KERNEL(0 to c_KERNEL_SIZE-1);
  o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component operation_MO1;

-- -- Do the erode or dilation operation (has 2 architectures)
-- component operation_MO1
-- generic (
--   c_WIDTH       : integer;
--   c_KERNEL_SIZE : integer
-- );
-- port (
--   i_W    : in  t_KERNEL(0 to c_KERNEL_SIZE-1);
--   o_DOUT : out std_logic_vector (c_WIDTH-1 downto 0)
-- );
-- end component operation_MO1;

component operation_MO2
generic (
  c_KERNEL_SIZE : integer
);
port (
  i_INPUT : in  std_logic_vector(0 to c_KERNEL_SIZE-1);
  o_DOUT  : out std_logic
);
end component operation_MO2;

component RAM_2_PORT
port (
  clock     : IN  STD_LOGIC  := '1';
  data      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
  rdaddress : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
  wraddress : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
  wren      : IN  STD_LOGIC  := '0';
  q         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
end component RAM_2_PORT;

-- -- RAM that hold the eroded image (int the MO1 operation) | Output port does not have register (output avaiable in the same clk cycle)
-- component RAM_WR
-- port (
--   address : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
--   clock   : IN  STD_LOGIC;
--   data    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
--   rden    : IN  STD_LOGIC;
--   wren    : IN  STD_LOGIC;
--   q       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
-- );
-- end component RAM_WR;

-- Register
component Reg
generic (
  c_WIDTH : integer
);
port (
  i_CLK  : in  std_logic;
  i_RST  : in  std_logic;
  i_ENA  : in  std_logic;
  i_CLR  : in  std_logic;
  i_DIN  : in  std_logic_vector(c_WIDTH-1 downto 0);
  o_DOUT : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component Reg;

component RGB2GRAY
generic (
  c_WIDTH_INPUT_DATA  : integer;
  c_WIDTH_OUTPUT_DATA : integer
);
port (
  --i_CLK         : in  std_logic;
  --i_RST         : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_INPUT_DATA-1  downto 0);
  o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0)
);
end component RGB2GRAY;

component Row_Buffer_Bin
generic (
  c_SIZE : integer
);
port (
  i_CLK      : in  std_logic;
  i_RST      : in  std_logic;
  i_ENA      : in  std_logic;
  i_CLR      : in  std_logic;
  i_DATA_IN  : in  std_logic;
  o_DATA_OUT : out std_logic
);
end component Row_Buffer_Bin;

-- Shift register
component row_buffer
generic (
  c_SIZE  : integer;
  c_WIDTH : integer
);
port (
  i_CLK      : in  std_logic;
  i_RST      : in  std_logic;
  i_ENA      : in  std_logic;
  i_CLR      : in  std_logic;
  i_DATA_IN  : in  std_logic_vector(c_WIDTH-1 downto 0);
  o_DATA_OUT : out std_logic_vector(c_WIDTH-1 downto 0)
);
end component row_buffer;

component Top_Block1
generic (
  c_WIDTH_INPUT_PIXEL : integer := 24;
  c_WIDTH_GRAY_PIXEL  : integer := 8;
  c_KERNEL_HEIGHT_MO1 : integer := c_KERNEL_HEIGHT_MO1;
  c_KERNEL_WIDTH_MO1  : integer := c_KERNEL_WIDTH_MO1;
  c_INPUT_IMG_HEIGHT  : integer := c_INPUT_IMG_WIDTH_MO1;
  c_INPUT_IMG_WIDTH   : integer := c_INPUT_IMG_WIDTH_MO1
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0)
);
end component Top_Block1;

component Top_Block2
generic (
  c_WIDTH_GRAY_PIXEL : integer := 8;
  c_INPUT_IMG_HEIGHT : integer := c_INPUT_IMG_WIDTH_MO1;
  c_INPUT_IMG_WIDTH  : integer := c_INPUT_IMG_WIDTH_MO1
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_DONE_BLOCK1 : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_Block2;

component Top_Block3
generic (
  c_KERNEL_HEIGHT_MO2    : integer := c_KERNEL_HEIGHT_MO2;
  c_KERNEL_WIDTH_MO2     : integer := c_KERNEL_WIDTH_MO2;
  c_INPUT_IMG_HEIGHT_MO2 : integer := c_INPUT_IMG_HEIGHT_MO2;
  c_INPUT_IMG_WIDTH_MO2  : integer := c_INPUT_IMG_WIDTH_MO2;
  c_KERNEL_HEIGHT_MC     : integer := c_KERNEL_HEIGHT_MC;
  c_KERNEL_WIDTH_MC      : integer := c_KERNEL_WIDTH_MC;
  c_INPUT_IMG_HEIGHT_MC  : integer := c_INPUT_IMG_HEIGHT_MC;
  c_INPUT_IMG_WIDTH_MC   : integer := c_INPUT_IMG_WIDTH_MC
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_PIX_RDY_SUB : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_Block3;

-- -- Morphological Opening 1 (MO1)
-- component Top_MO1
-- generic (
--   c_WIDTH_DATA       : integer;
--   c_KERNEL_HEIGHT    : integer;
--   c_KERNEL_WIDTH     : integer;
--   c_KERNEL_SIZE      : integer;
--   c_ROW_BUF_SIZE_ERO : integer;
--   c_ROW_BUF_SIZE_DIL : integer;
--   c_ADDR_RAM_SIZE    : integer
-- );
-- port (
--   i_CLK         : in  std_logic;
--   i_RST         : in  std_logic;
--   i_START       : in  std_logic;
--   i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
--   o_PIX_RDY     : out std_logic;
--   o_DONE        : out std_logic;
--   o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
-- );
-- end component Top_MO1;

component Top_MC_Pipeline
generic (
  c_KERNEL_HEIGHT    : integer := c_KERNEL_HEIGHT_MC;
  c_KERNEL_WIDTH     : integer := c_KERNEL_WIDTH_MC;
  c_INPUT_IMG_WIDTH  : integer := c_INPUT_IMG_WIDTH_MC;
  c_INPUT_IMG_HEIGHT : integer := c_INPUT_IMG_HEIGHT_MC
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_MC_Pipeline;


component Top_MO1_Pipeline
generic (
  c_WIDTH_DATA       : integer;
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
);
end component Top_MO1_Pipeline;

component Top_MO2_Pipeline
generic (
  c_KERNEL_HEIGHT    : integer := c_KERNEL_HEIGHT_MO2;
  c_KERNEL_WIDTH     : integer := c_KERNEL_WIDTH_MO2;
  c_INPUT_IMG_WIDTH  : integer := c_INPUT_IMG_WIDTH_MO2;
  c_INPUT_IMG_HEIGHT : integer := c_INPUT_IMG_HEIGHT_MO2
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_MO2_Pipeline;

component Top_Operation_MC
generic (
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_Operation_MC;

component Top_Operation_MO1
generic (
  c_WIDTH_DATA       : integer;
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_DATA-1 downto 0);
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
);
end component Top_Operation_MO1;

component Top_Operation_MO2
generic (
  c_KERNEL_HEIGHT    : integer;
  c_KERNEL_WIDTH     : integer;
  c_INPUT_IMG_WIDTH  : integer;
  c_INPUT_IMG_HEIGHT : integer;
  s_SEL_OPERATION    : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic;
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_Operation_MO2;

component Top_OTSU
generic (
  c_SIZE_MEM    : integer;
  c_WIDTH_PIXEL : integer;
  c_WIDTH_VAR   : integer
);
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_PIXEL       : in  std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  o_DONE        : out std_logic;
  o_THRESHOLD   : out std_logic_vector(c_WIDTH_PIXEL-1 downto 0)
);
end component Top_OTSU;

component Top_System_ALPR
generic (
  c_WIDTH_INPUT_PIXEL : integer := 24;
  c_WIDTH_GRAY_PIXEL  : integer := 8;
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
port (
  i_CLK         : in  std_logic;
  i_RST         : in  std_logic;
  i_START       : in  std_logic;
  i_VALID_PIXEL : in  std_logic;
  i_INPUT_PIXEL : in  std_logic_vector(c_WIDTH_INPUT_PIXEL-1 downto 0);
  o_PIX_RDY     : out std_logic;
  o_DONE        : out std_logic;
  o_OUT_PIXEL   : out std_logic
);
end component Top_System_ALPR;

end ALPR_package;

package body ALPR_package is

end ALPR_package;
