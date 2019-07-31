library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;

package Package_Gaussian is

-- Components instantiation
  component Comparator
  port (
    i_A  : in  integer;
    i_B  : in  integer;
    o_EQ : out std_logic
  );
  end component Comparator;

  component Control_Convolution
  port (
    i_CLK             : in  std_logic;
    i_RST             : in  std_logic;
    i_START           : in  std_logic;
    i_VALID_PIXEL     : in  std_logic;
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
    o_ENA_WRI_REG     : out std_logic;
    o_PIX_RDY         : out std_logic;
    o_DONE            : out std_logic
  );
  end component Control_Convolution;

  component Datapath_Gaussian_2D
  generic (
    p_KERNEL_HEIGHT    : integer;
    p_KERNEL_WIDTH     : integer;
    p_INPUT_IMG_WIDTH  : integer;
    p_INPUT_IMG_HEIGHT : integer
  );
  port (
    i_CLK             : in  std_logic;
    i_RST             : in  std_logic;
    i_INPUT_PIXEL     : in  fixed;
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
    i_ENA_WRI_REG     : in  std_logic;
    o_MAX_KER_TOT     : out std_logic;
    o_MAX_KER_ROW     : out std_logic;
    o_MAX_INV_KER     : out std_logic;
    o_BUFFERS_FILLED  : out std_logic;
    o_OUT_PIXEL       : out fixed
  );
  end component Datapath_Gaussian_2D;

  component Counter
  port (
    i_CLK : in  std_logic;
    i_RST : in  std_logic;
    i_ENA : in  std_logic;
    i_CLR : in  std_logic;
    o_Q   : out integer:= 0
  );
  end component Counter;

  component DRA
  generic (
    p_WIDTH_DATA    : integer := MSB;
    p_KERNEL_HEIGHT : integer := 5;
    p_KERNEL_WIDTH  : integer := 5;
    p_KERNEL_SIZE   : integer := 25;
    p_ROW_BUF_SIZE  : integer := 23
  );
  port (
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_INPUT_PIXEL : in  fixed;
    i_ENA_WRI_KER : in  std_logic;
    o_OUT_KERNEL  : out fixed_vector(p_KERNEL_SIZE-1 downto 0)
  );
  end component DRA;

  component Filter_3
  generic (
    p_FILTER_SIZE : integer
  );
  port (
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_ENA_REG : in  std_logic;
    i_KERNEL  : in  fixed_vector(p_FILTER_SIZE-1 downto 0);
    i_WEIGHTS : in fixed_vector(p_FILTER_SIZE-1 downto 0);
    o_RESULT  : out fixed
  );
  end component Filter_3;

  component Filter_5
  generic (
    p_FILTER_SIZE : integer
  );
  port (
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_ENA_REG : in  std_logic;
    i_KERNEL  : in  fixed_vector(p_FILTER_SIZE-1 downto 0);
    i_WEIGHTS : in  fixed_vector(p_FILTER_SIZE-1 downto 0);
    o_RESULT  : out fixed
  );
  end component Filter_5;

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

  component Reg
  port (
    i_CLK  : in  std_logic;
    i_RST  : in  std_logic;
    i_ENA  : in  std_logic;
    i_CLR  : in  std_logic;
    i_DIN  : in  fixed;
    o_DOUT : out fixed
  );
  end component Reg;

  component Row_Buffer
  generic (
    c_SIZE  : integer;
    c_WIDTH : integer
  );
  port (
    i_CLK      : in  std_logic;
    i_RST      : in  std_logic;
    i_ENA      : in  std_logic;
    i_CLR      : in  std_logic;
    i_DATA_IN  : in  fixed;
    o_DATA_OUT : out fixed
  );
  end component Row_Buffer;

  component Top_Gaussian
  generic (
    p_KERNEL_HEIGHT    : integer := 5;
    p_KERNEL_WIDTH     : integer := 5;
    p_INPUT_IMG_WIDTH  : integer := 28;
    p_INPUT_IMG_HEIGHT : integer := 28
  );
  port (
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_START       : in  std_logic;
    i_VALID_PIXEL : in  std_logic;
    i_INPUT_PIXEL : in  fixed;
    o_PIX_RDY     : out std_logic;
    o_DONE        : out std_logic;
    o_OUT_PIXEL   : out fixed
  );
  end component Top_Gaussian;

end Package_Gaussian;
