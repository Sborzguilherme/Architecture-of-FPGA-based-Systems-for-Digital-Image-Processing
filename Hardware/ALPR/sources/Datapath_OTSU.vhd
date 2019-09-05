-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    21/02/2018
-- File:    Datapath_OTSU.vhd

-- Block contains:
-- ACC_MEM: block that hold the image histogram
-- Registers: One for each variable used in the iterations
  -- wB:   weigth background
  -- wF:   weigth foregroung
  -- sumB: pixel_value * qtd_pixels with the same value
  -- mB:   mean background
  -- mF:   mean foregroung
  -- varBetween: result that express the current class variance
  -- varMax: greatest value assumed by varBetween (indicate the  Grateast variance verified)
  -- threshold: value of interest of the block
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;

entity Datapath_OTSU is
generic(
  c_SIZE_MEM     : integer;
  c_WIDTH_PIXEL  : integer;
  c_WIDTH_VAR    : integer
);
port(
  i_CLK                       : in  std_logic;
  i_RST                       : in  std_logic;
  i_PIXEL                     : in  std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  i_VALID_PIXEL               : in  std_logic; -- Indicate if data in the i_PIXEL port is valid
  i_SEL_MUX                   : in  std_logic;
  i_WRI_ENA                   : in  std_logic;
  i_WRI_WB                    : in  std_logic;
  i_WRI_WF                    : in  std_logic;
  i_WRI_SUM_B                 : in  std_logic;
  i_WRI_MB                    : in  std_logic;
  i_WRI_MF                    : in  std_logic;
  i_WRI_VAR_B                 : in  std_logic;
  i_WRI_VAR_MAX               : in  std_logic;
  i_WRI_TH                    : in  std_logic;
  i_WRI_CUR_HIST              : in  std_logic;
  i_WRI_AUX_SUM_B             : in  std_logic;
  i_WRI_AUX_MF                : in  std_logic;
  i_WRI_AUX_SUB_MB_MF         : in  std_logic;
  i_WRI_AUX_EXP_MB_MF         : in  std_logic;
  i_WRI_AUX_MULT_WB_WF        : in  std_logic;
  i_ENA_CNT_ADDR              : in  std_logic;
  i_CLR_CNT_ADDR              : in  std_logic;
  i_ENA_CNT_PIX               : in  std_logic;
  i_CLR_CNT_PIX               : in  std_logic;
  i_ENA_CNT_CALC_WB           : in  std_logic;
  i_CLR_CNT_CALC_WB           : in  std_logic;
  i_ENA_CNT_CALC_WF           : in  std_logic;
  i_CLR_CNT_CALC_WF           : in  std_logic;
  i_ENA_CNT_CALC_SUM_B        : in  std_logic;
  i_CLR_CNT_CALC_SUM_B        : in  std_logic;
  i_ENA_CNT_CALC_MB           : in  std_logic;
  i_CLR_CNT_CALC_MB           : in  std_logic;
  i_ENA_CNT_CALC_MF           : in  std_logic;
  i_CLR_CNT_CALC_MF           : in  std_logic;
  i_ENA_CNT_CALC_VAR_B        : in  std_logic;
  i_CLR_CNT_CALC_VAR_B        : in  std_logic;
  i_ENA_CNT_CALC_AUX_0_VAR_B  : in  std_logic;
  i_CLR_CNT_CALC_AUX_0_VAR_B  : in  std_logic;
  i_ENA_CNT_CALC_AUX_1_VAR_B  : in  std_logic;
  i_CLR_CNT_CALC_AUX_1_VAR_B  : in  std_logic;
  i_ENA_CNT_CONV              : in  std_logic;
  i_CLR_CNT_CONV              : in  std_logic;
  o_END_ADD_WB                : out std_logic;
  o_END_WF                    : out std_logic;
  o_END_ADD_SUM_B             : out std_logic;
  o_END_SUB_MF                : out std_logic;
  o_END_MF                    : out std_logic;
  o_END_AUX_0_VAR_B           : out std_logic;
  o_END_AUX_1_VAR_B           : out std_logic;
  o_END_VAR_B                 : out std_logic;
  o_CONTINUE_WB               : out std_logic;
  o_MAX_PIX                   : out std_logic;
  o_END_CONV                  : out std_logic;
  o_LAST_PIXEL                : out std_logic;
  o_TH_FOUND                  : out std_logic;
  o_THRESHOLD                 : out std_logic_vector(c_WIDTH_PIXEL-1 downto 0)
);
end Datapath_OTSU;

architecture arch of Datapath_OTSU is

  constant c_IMG_SIZE       : integer := (c_OUT_IMG_HEIGHT_MO1 * c_OUT_IMG_WIDTH_MO1);
  constant c_IMG_SIZE_CONV  : std_logic_vector(c_WIDTH_VAR-1 downto 0) := x"47788000";
  --constant c_IMG_SIZE       : integer := (6*9);
  --constant c_IMG_SIZE_CONV : std_logic_vector(c_WIDTH_VAR-1 downto 0) := x"42580000"; -- CHANGED TO 54 IEEE

  signal w_ACC_MEM_OUT    : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_ACC_MEM_CONV   : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_ACC_PIXEL      : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_ACC_PIXEL_CONV : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_MUX_OUT        : std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  signal w_CNT_ADDR_HIST  : std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  signal w_CNT_ADDR_CONV  : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_WRI_ENA        : std_logic;
  signal w_ENA_UPDATE_TH  : std_logic;
  signal w_UPDATE         : std_logic;
  signal w_CNT_PIX        : integer;
  signal w_ITERATOR       : integer;
  signal w_AUX_STD        : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  -- Signals for Cycles Counting
  signal w_CNT_CALC_WB          : integer;
  signal w_CNT_CALC_WF          : integer;
  signal w_CNT_CALC_MB          : integer;
  signal w_CNT_CALC_VAR_B       : integer;
  signal w_CNT_CONV             : integer;
  signal w_CNT_CALC_SUM_B       : integer;
  signal w_CNT_CALC_MF          : integer;
  signal w_CNT_CALC_AUX_0_VAR_B : integer;
  signal w_CNT_CALC_AUX_1_VAR_B : integer;

  -- Signals for operations
  -- signal w_RES_SUB_M      : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  -- signal w_RES_SUB_MF     : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  -- signal w_RES_MUL_SUM_B  : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  -- signal w_RES_MUL_0      : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  -- signal w_RES_MUL_1      : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_ZERO_WB        : std_logic;
  signal w_ZERO_WF        : std_logic;
  signal w_ZERO_SUM_B     : std_logic;
  signal w_ZERO_MF        : std_logic;
  signal w_ZERO_VAR_B     : std_logic;

  -- Variables signals
  signal w_WB_IN          : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_WB_OUT         : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_WF_IN          : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_WF_OUT         : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_SUM_B_IN       : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_SUM_B_OUT      : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_MB_IN          : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_MB_OUT         : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_MF_IN          : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_MF_OUT         : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_VAR_B_IN       : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_VAR_B_OUT      : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_VAR_MAX_IN     : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_VAR_MAX_OUT    : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_TH_IN          : std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
  signal w_TH_OUT         : std_logic_vector(c_WIDTH_PIXEL-1 downto 0);

  signal w_CURRENT_HIST   : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_AUX_SUM_B_IN   : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_AUX_SUM_B_OUT  : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_AUX_MF_IN      : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_AUX_MF_OUT     : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_AUX_SUB_MB_MF_IN  : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_AUX_SUB_MB_MF_OUT : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_AUX_EXP_MB_MF_IN  : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_AUX_EXP_MB_MF_OUT : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_AUX_MULT_WB_WF_IN  : std_logic_vector(c_WIDTH_VAR-1 downto 0);
  signal w_AUX_MULT_WB_WF_OUT : std_logic_vector(c_WIDTH_VAR-1 downto 0);

  signal w_ENA_CNT_PIX        : std_logic;

begin

  w_WRI_ENA <= i_VALID_PIXEL and i_WRI_ENA;
  w_UPDATE  <= w_ENA_UPDATE_TH and (i_WRI_TH or i_WRI_VAR_MAX);

  w_ENA_CNT_PIX <= i_ENA_CNT_PIX and i_VALID_PIXEL;


-- ACC_MEM (Stores img histogram)
  ACC_MEM_i : ACC_MEM
  generic map (
    c_SIZE_MEM   => c_SIZE_MEM,
    c_WIDTH_DATA => c_WIDTH_VAR,
    c_WIDTH_ADDR => c_WIDTH_PIXEL
  )
  port map (
    i_CLK     => i_CLK,
    i_RST     => i_RST,
    i_WRI_ENA => w_WRI_ENA,
    i_ADDR    => w_MUX_OUT,
    o_ACC     => w_ACC_MEM_OUT
  );

-- MUX 2x1 (Select i_ADDR data for ACC_MEM block)
  Mux_2_1_i : Mux_2_1
  generic map (
    p_WIDTH => c_WIDTH_PIXEL
  )
  port map (
    i_SEL  => i_SEL_MUX,
    i_DIN0 => i_PIXEL,
    i_DIN1 => w_CNT_ADDR_HIST,
    o_DOUT => w_MUX_OUT
  );

-- Acc (Stores sum of all input pixels)
  ACC_PIXEL : ACC
generic map (
  c_WIDTH_INPUT_DATA  => c_WIDTH_PIXEL,
  c_WIDTH_OUTPUT_DATA => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_WRI_ENA,
  i_CLR  => '0',
  i_DATA => i_PIXEL,
  o_Q    => w_ACC_PIXEL
);

Greater_than_i : Greater_than
generic map (
  c_WIDTH_DATA => c_WIDTH_VAR
)
port map (
  i_A  => w_VAR_B_OUT,
  i_B  => w_VAR_MAX_OUT,
  o_GT => w_ENA_UPDATE_TH
);
------------------------- Counters --------------------------------
-- CNT_ADDR_HIST
CNT_ADDR_HIST : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_ADDR,
  i_CLR => i_CLR_CNT_ADDR,
  o_Q   => w_ITERATOR
  );

w_CNT_ADDR_HIST <= std_logic_vector(to_unsigned(w_ITERATOR, c_WIDTH_PIXEL));

-- CYCLES COUNTER
-- s_HIST
CNT_PIX : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_CNT_PIX,
  i_CLR => i_CLR_CNT_PIX,
  o_Q   => w_CNT_PIX
);

-- s_CONV_HIST
  CNT_CONV : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CONV,
    i_CLR => i_CLR_CNT_CONV,
    o_Q   => w_CNT_CONV
    );

  -- s_CALC_WB
  CNT_CALC_WB : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_WB,
    i_CLR => i_CLR_CNT_CALC_WB,
    o_Q   => w_CNT_CALC_WB
);

  -- s_CALC_WF
  CNT_CALC_WF : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_WF,
    i_CLR => i_CLR_CNT_CALC_WF,
    o_Q   => w_CNT_CALC_WF
  );

  -- s_CALC_SUM_B
  CNT_CALC_SUM_B : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_SUM_B,
    i_CLR => i_CLR_CNT_CALC_SUM_B,
    o_Q   => w_CNT_CALC_SUM_B
  );

  -- s_CALC_MB
  CNT_CALC_MB : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_MB,
    i_CLR => i_CLR_CNT_CALC_MB,
    o_Q   => w_CNT_CALC_MB
  );

  -- s_CALC_MF
  CNT_CALC_MF : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_MF,
    i_CLR => i_CLR_CNT_CALC_MF,
    o_Q   => w_CNT_CALC_MF
  );

  -- s_CALC_AUX_SUB_MB_MF
  CNT_CALC_AUX_0_VAR_B : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_AUX_0_VAR_B,
    i_CLR => i_CLR_CNT_CALC_AUX_0_VAR_B,
    o_Q   => w_CNT_CALC_AUX_0_VAR_B
  );
-- s_CALC_EXP_MB_MF
  CNT_CALC_AUX_1_VAR_B : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_AUX_1_VAR_B,
    i_CLR => i_CLR_CNT_CALC_AUX_1_VAR_B,
    o_Q   => w_CNT_CALC_AUX_1_VAR_B
  );

  -- s_CALC_VAR_B
  CNT_CALC_VAR_B : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => i_ENA_CNT_CALC_VAR_B,
    i_CLR => i_CLR_CNT_CALC_VAR_B,
    o_Q   => w_CNT_CALC_VAR_B
  );

------------------------- Comparators --------------------------------
-- Cycles counting comparers
-- s_HIST
IMG_SIZE : Comparator
port map (
  i_A  => w_CNT_PIX,
  i_B  => c_IMG_SIZE-1,
  o_EQ => o_MAX_PIX
);

-- s_CONV_HIST
COMP_CONV : Comparator
port map (
  i_A  => w_CNT_CONV,
  i_B  => c_CNT_CYCLES_CONV+1,
  o_EQ => o_END_CONV
);

-- s_CALC_WB
COMP_WB : Comparator
port map (
  i_A  => w_CNT_CALC_WB,
  i_B  => (c_CNT_CYCLES_ADD_SUB)-1,
  o_EQ => o_END_ADD_WB
);

-- s_CALC_WF
COMP_WF : Comparator
port map (
  i_A  => w_CNT_CALC_WF,
  i_B  => (c_CNT_CYCLES_ADD_SUB),
  o_EQ => o_END_WF
);

-- s_CALC_SUM_B
COMP_SUM_B : Comparator
port map (
  i_A  => w_CNT_CALC_SUM_B,
  i_B  => (c_CNT_CYCLES_ADD_SUB),
  o_EQ => o_END_ADD_SUM_B
);

-- s_CALC_MB
COMP_MB : Comparator
port map (
  i_A  => w_CNT_CALC_MB,
  i_B  => (c_CNT_CYCLES_ADD_SUB),   -- MB AND AUX MF VALUES
  o_EQ => o_END_SUB_MF
);

-- s_CALC_MF
COMP_MF : Comparator
port map (
  i_A  => w_CNT_CALC_MF,
  i_B  => (c_CNT_CYCLES_DIV),     -- FINAL MF VALUE
  o_EQ => o_END_MF
);

-- s_CALC_AUX_SUB_MB_MF
COMP_AUX_0_VB : Comparator
port map (
  i_A  => w_CNT_CALC_AUX_0_VAR_B,
  i_B  => (c_CNT_CYCLES_ADD_SUB),
  o_EQ => o_END_AUX_0_VAR_B
);

-- s_CALC_EXP_MB_MF
COMP_AUX_1_VB : Comparator
port map (
  i_A  => w_CNT_CALC_AUX_1_VAR_B,
  i_B  => (c_CNT_CYCLES_MULT),
  o_EQ => o_END_AUX_1_VAR_B
);

-- s_CALC_VAR_B
COMP_VAR_B : Comparator
port map (
  i_A  => w_CNT_CALC_VAR_B,
  i_B  => (c_CNT_CYCLES_MULT),
  o_EQ => o_END_VAR_B
);

-- Check if all positions from histogram have been verified
LAST_PIXEL : Comparator
port map (
  i_A  => w_ITERATOR,  -- Iterator
  i_B  => 255,
  o_EQ => o_LAST_PIXEL
);

------------------------- Converter --------------------------------
CONVERT_ACC_MEM : FPU_CONVERT
port map (
  clock  => i_CLK,
  dataa  => w_ACC_MEM_OUT,
  result => w_ACC_MEM_CONV
);

w_AUX_STD <= x"000000" & w_CNT_ADDR_HIST; -- 8 bits to 32

CONVERT_CNT_ADDR : FPU_CONVERT
port map (
  clock  => i_CLK,
  dataa  => w_AUX_STD,
  result => w_CNT_ADDR_CONV
);

CONVERT_ACC_PIX : FPU_CONVERT
port map (
  clock  => i_CLK,
  dataa  => w_ACC_PIXEL,
  result => w_ACC_PIXEL_CONV
);

------------------------- Variables --------------------------------
wB : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_WB,
  i_CLR  => '0',
  i_DIN  => w_WB_IN,
  o_DOUT => w_WB_OUT
);

wF : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_WF,
  i_CLR  => '0',
  i_DIN  => w_WF_IN,
  o_DOUT => w_WF_OUT
);

sumB : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_SUM_B,
  i_CLR  => '0',
  i_DIN  => w_SUM_B_IN,
  o_DOUT => w_SUM_B_OUT
);

mB : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_MB,
  i_CLR  => '0',
  i_DIN  => w_MB_IN,
  o_DOUT => w_MB_OUT
);

mF : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_MF,
  i_CLR  => '0',
  i_DIN  => w_MF_IN,
  o_DOUT => w_MF_OUT
);

varBetween : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_VAR_B,
  i_CLR  => '0',
  i_DIN  => w_VAR_B_IN,
  o_DOUT => w_VAR_B_OUT
);

varMax : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_UPDATE,
  i_CLR  => '0',
  i_DIN  => w_VAR_MAX_IN,
  o_DOUT => w_VAR_MAX_OUT
);

threshold : Reg
generic map (
  c_WIDTH => c_WIDTH_PIXEL
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_UPDATE,
  i_CLR  => '0',
  i_DIN  => w_TH_IN,
  o_DOUT => w_TH_OUT
);

------------------------------- Auxiliar Variables ----------------------------
Current_Hist : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_CUR_HIST,
  i_CLR  => '0',
  i_DIN  => w_ACC_MEM_CONV,
  o_DOUT => w_CURRENT_HIST
);

Aux_Sum_B : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_AUX_SUM_B,
  i_CLR  => '0',
  i_DIN  => w_AUX_SUM_B_IN,
  o_DOUT => w_AUX_SUM_B_OUT
);

Aux_mF : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_AUX_MF,
  i_CLR  => '0',
  i_DIN  => w_AUX_MF_IN,
  o_DOUT => w_AUX_MF_OUT
);

Aux_sub_mb_mf : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_AUX_SUB_MB_MF,
  i_CLR  => '0',
  i_DIN  => w_AUX_SUB_MB_MF_IN,
  o_DOUT => w_AUX_SUB_MB_MF_OUT
);

Aux_exp_mb_mf : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_AUX_EXP_MB_MF,
  i_CLR  => '0',
  i_DIN  => w_AUX_EXP_MB_MF_IN,
  o_DOUT => w_AUX_EXP_MB_MF_OUT
);

Aux_mult_aux : Reg
generic map (
  c_WIDTH => c_WIDTH_VAR
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => i_WRI_AUX_MULT_WB_WF,
  i_CLR  => '0',
  i_DIN  => w_AUX_MULT_WB_WF_IN,
  o_DOUT => w_AUX_MULT_WB_WF_OUT
);

------------------------- Operations --------------------------------
  -- wB
    -- SUM
    FPU_ADD_WB : FPU_ADD_SUB
    port map (
      add_sub => '1', -- add
      clock   => i_CLK,
      dataa   => w_CURRENT_HIST,
      datab   => w_WB_OUT,
      result  => w_WB_IN,
      zero    => w_ZERO_WB
    );

  -- wF
    -- sub
  FPU_SUB_WF : FPU_ADD_SUB
  port map (
    add_sub => '0', -- sub
    clock   => i_CLK,
    dataa   => c_IMG_SIZE_CONV,
    datab   => w_WB_OUT,
    result  => w_WF_IN,
    zero    => w_ZERO_WF
  );

-- sumB
  -- Mult
  FPU_MULT_i : FPU_MULT
  port map (
    clock  => i_CLK,
    dataa  => w_CNT_ADDR_CONV,
    datab  => w_CURRENT_HIST,
    result => w_AUX_SUM_B_IN
  );

  -- Sum
  FPU_ADD_SUM_B : FPU_ADD_SUB
  port map (
    add_sub => '1', -- add
    clock   => i_CLK,
    dataa   => w_AUX_SUM_B_OUT,
    datab   => w_SUM_B_OUT,
    result  => w_SUM_B_IN,
    zero    => w_ZERO_SUM_B
  );

-- mB
  -- div
  FPU_DIV_SUM_B : FPU_DIV
  port map (
    clock  => i_CLK,
    dataa  => w_SUM_B_OUT,
    datab  => w_WB_OUT,
    result => w_MB_IN
  );

-- mF
  -- sub
  FPU_SUB_MF : FPU_ADD_SUB
  port map (
    add_sub => '0', -- sub
    clock   => i_CLK,
    dataa   => w_ACC_PIXEL_CONV,
    datab   => w_SUM_B_OUT,
    result  => w_AUX_MF_IN,
    zero    => w_ZERO_MF
  );
  -- div
  FPU_DIV_MF : FPU_DIV
  port map (
    clock  => i_CLK,
    dataa  => w_AUX_MF_OUT,
    datab  => w_WF_OUT,
    result => w_MF_IN
  );

  -- varBetween
  -- sub
  FPU_SUB_VAR_B : FPU_ADD_SUB
  port map (
    add_sub => '0', -- sub
    clock   => i_CLK,
    dataa   => w_MB_OUT,
    datab   => w_MF_OUT,
    result  => w_AUX_SUB_MB_MF_IN,
    zero    => w_ZERO_VAR_B
  );

  FPU_MULT_SUB_M : FPU_MULT
  port map (
    clock  => i_CLK,
    dataa  => w_AUX_SUB_MB_MF_OUT,
    datab  => w_AUX_SUB_MB_MF_OUT,
    result => w_AUX_EXP_MB_MF_IN
  );

  FPU_MULT_WF_WB : FPU_MULT
  port map (
    clock  => i_CLK,
    dataa  => w_WB_OUT,
    datab  => w_WF_OUT,
    result => w_AUX_MULT_WB_WF_IN
  );

  FPU_MULT_VAR_B : FPU_MULT
  port map (
    clock  => i_CLK,
    dataa  => w_AUX_MULT_WB_WF_OUT,
    datab  => w_AUX_EXP_MB_MF_OUT,
    result => w_VAR_B_IN
  );

  -- varMax
  w_VAR_MAX_IN <= w_VAR_B_OUT;

  -- threshold
  w_TH_IN <= w_CNT_ADDR_HIST;
  o_THRESHOLD <= w_TH_OUT;

  o_TH_FOUND <= w_ZERO_WF;
  o_CONTINUE_WB <= w_ZERO_WB;


end architecture;
