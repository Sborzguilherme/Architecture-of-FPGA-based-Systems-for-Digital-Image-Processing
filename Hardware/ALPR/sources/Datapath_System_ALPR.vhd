----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    01/03/2018
-- File:    Datapath_System_ALPR.vhd

-- Datapath with all operations for plate localization in the image

-- Blocks implemented:
-- RGB2GRAY: Convert 24 bits RGB pixel in 8 bits grayscale pixel
-- RAM_GRAY: Stores Grayscale image
-- MO1: Morphological Opening over grayscale image
-- Subtraction: Operation between to grayscale and MO1 output, resulting in a highlighted image
-- RAM_SUB: Stores subtraction output image for Binarization
-- OTSU: Find the optimal threshold value for the image
-- Binarization: Compare the pixel value from highlighted image with the optimal threshold found. Generate a binary image in the output
-- MO2: Second Morphological Opening. This time over a binary image
-- MC: Morphological Closing over a binary image
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_System_ALPR is
    generic(
        c_WIDTH_INPUT_PIXEL : integer;  -- RGB   24 bits
        c_WIDTH_GRAY_PIXEL  : integer;  -- GRAY  8 bits
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
    port(
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
        --i_ENA_WRI_RAM_GRAY    : in  std_logic;
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
end Datapath_System_ALPR;

architecture arch of Datapath_System_ALPR is

-- Constants
-- Images size
  constant c_INPUT_IMG_WIDTH_MO2  : integer := c_INPUT_IMG_WIDTH  - (c_KERNEL_WIDTH_MO1-1);
  constant c_INPUT_IMG_HEIGHT_MO2 : integer := c_INPUT_IMG_HEIGHT - (c_KERNEL_HEIGHT_MO1-1);
  constant c_INPUT_IMG_WIDTH_MC   : integer := c_INPUT_IMG_WIDTH_MO2  - (c_KERNEL_WIDTH_MO2-1);
  constant c_INPUT_IMG_HEIGHT_MC  : integer := c_INPUT_IMG_HEIGHT_MO2 - (c_KERNEL_HEIGHT_MO2-1);

--------------------------- SIGNALS -------------------------------------
  -- RGB2GRAY signals
  signal w_INPUT_PIXEL_GRAY  : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

  -- RAM GRAY signals
  signal w_R_ADDR_RAM_GRAY      : std_logic_vector(16 downto 0); -- Size of addr ram port = 17
  signal w_R_ADDR_RAM_GRAY_INT  : integer;
  signal w_W_ADDR_RAM_GRAY      : std_logic_vector(16 downto 0);
  signal w_W_ADDR_RAM_GRAY_INT  : integer;
  signal w_RAM_GRAY_OUT         : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_ENA_WRI_RAM_GRAY     : std_logic;
  signal w_DONE_CROP            : std_logic;

  -- RAM SUB signals
  signal w_R_ADDR_RAM_SUB       : std_logic_vector(16 downto 0); -- Verify if is possible to reduce this size
  signal w_R_ADDR_RAM_SUB_INT   : integer;
  signal w_W_ADDR_RAM_SUB       : std_logic_vector(16 downto 0);
  signal w_W_ADDR_RAM_SUB_INT   : integer;
  signal w_RAM_SUB_OUT          : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_RAM_SUB_IN           : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

  -- Registers signals
  signal w_FF_MO2_MC_OUT     : std_logic;

  -- Counters signals
  signal w_CNT_LIN_GRAY_OUT  : integer;
  signal w_CNT_COL_GRAY_OUT  : integer;
  signal w_CLR_CNT_COL_GRAY  : std_logic;
  signal w_CLR_CNT_LIN_GRAY  : std_logic;

-- Morphological Operations Signals
  signal w_PIXEL_MO1_OUT     : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_REG_MO1_OUT       : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_PIX_RDY_MO1       : std_logic;
  signal w_PIXEL_MO2_IN      : std_logic;
  signal w_PIXEL_MO2_OUT     : std_logic;
  signal w_PIX_RDY_MO2       : std_logic;
  signal w_VALID_PIXEL_MC    : std_logic;

-- Binarization signal
  signal w_THRESHOLD         : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

begin

-- Intern Control
  w_VALID_PIXEL_MC <= w_PIX_RDY_MO2 or i_VALID_PIXEL_MC;

  -- RGB to GRAY
  RGB2GRAY_i : RGB2GRAY
  generic map (
    c_WIDTH_INPUT_DATA  => c_WIDTH_INPUT_PIXEL,
    c_WIDTH_OUTPUT_DATA => c_WIDTH_GRAY_PIXEL
  )
  port map (
    i_INPUT_PIXEL => i_INPUT_PIXEL,
    o_OUT_PIXEL   => w_INPUT_PIXEL_GRAY
  );

-------- Memorys
  -- RAM GRAY
  RAM_GRAY : RAM_2_PORT
  port map (
    clock     => i_CLK,
    data      => w_INPUT_PIXEL_GRAY,
    rdaddress => w_R_ADDR_RAM_GRAY,
    wraddress => w_W_ADDR_RAM_GRAY,
    wren      => w_ENA_WRI_RAM_GRAY,
    q         => w_RAM_GRAY_OUT
  );

-- RAM SUB
  RAM_SUB : RAM_2_PORT
  port map (
    clock     => i_CLK,
    data      => w_RAM_SUB_IN,
    rdaddress => w_R_ADDR_RAM_SUB,
    wraddress => w_W_ADDR_RAM_SUB,
    wren      => i_ENA_WRI_RAM_SUB,
    q         => w_RAM_SUB_OUT
  );

  -------- Crop Image
  ENA_RAM_GRAY_i : ENA_RAM_GRAY
  generic map (
    c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MO1,
    c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MO1,
    c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT,
    c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_VALID_PIXEL => i_VALID_PIXEL,
    o_DONE        => w_DONE_CROP,
    o_VALID_ADDR  => w_ENA_WRI_RAM_GRAY
  );

------- Registers Between stages
Flip_Flop_MO2_MC : Flip_Flop
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_VALID_PIXEL_MC,
  i_CLR  => '0',
  i_DIN  => w_PIXEL_MO2_OUT,
  o_DOUT => w_FF_MO2_MC_OUT
);

Reg_MO1_RAM : Reg
generic map (
  c_WIDTH => c_WIDTH_GRAY_PIXEL
)
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_PIX_RDY_MO1,
  i_CLR  => '0',
  i_DIN  => w_PIXEL_MO1_OUT,
  o_DOUT => w_REG_MO1_OUT
);

-------- Counters
-- Counter read address for RAM GRAY
CNT_R_ADDR_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_R_ADDR_GRAY,
  i_CLR => i_CLR_CNT_R_ADDR_GRAY,
  o_Q   => w_R_ADDR_RAM_GRAY_INT
);

w_R_ADDR_RAM_GRAY <= std_logic_vector(to_unsigned(w_R_ADDR_RAM_GRAY_INT, w_R_ADDR_RAM_GRAY'length));

-- Counter write address for RAM GRAY
CNT_W_ADDR_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_W_ADDR_GRAY,
  i_CLR => i_CLR_CNT_W_ADDR_GRAY,
  o_Q   => w_W_ADDR_RAM_GRAY_INT
);

w_W_ADDR_RAM_GRAY <= std_logic_vector(to_unsigned(w_W_ADDR_RAM_GRAY_INT, w_W_ADDR_RAM_GRAY'length));

-- Counter read address for RAM GRAY
CNT_R_ADDR_SUB : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_R_ADDR_SUB,
  i_CLR => i_CLR_CNT_R_ADDR_SUB,
  o_Q   => w_R_ADDR_RAM_SUB_INT
);

w_R_ADDR_RAM_SUB <= std_logic_vector(to_unsigned(w_R_ADDR_RAM_SUB_INT, w_R_ADDR_RAM_SUB'length));

-- Counter write address for RAM GRAY
CNT_W_ADDR_SUB : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_W_ADDR_SUB,
  i_CLR => i_CLR_CNT_W_ADDR_SUB,
  o_Q   => w_W_ADDR_RAM_SUB_INT
);

w_W_ADDR_RAM_SUB <= std_logic_vector(to_unsigned(w_W_ADDR_RAM_SUB_INT, w_W_ADDR_RAM_SUB'length));

-- Counters to control write in RAM GRAY MEmory
-- Invalid collumns and lines should not be written to the RAM
CNT_COL_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_W_ADDR_SUB,
  i_CLR => w_CLR_CNT_COL_GRAY,
  o_Q   => w_CNT_COL_GRAY_OUT
);

CNT_LIN_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_W_ADDR_SUB,
  i_CLR => w_CLR_CNT_LIN_GRAY,
  o_Q   => w_CNT_LIN_GRAY_OUT
);

-------- Morphological Operations

-- Morphological Opening 1
MO1 : Top_MO1_Pipeline
generic map (
  c_WIDTH_DATA       => c_WIDTH_GRAY_PIXEL,
  c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MO1,
  c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MO1,
  c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH,
  c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => i_START,
  i_VALID_PIXEL => i_VALID_PIXEL,         -- First Operation always receive a valid pixel from input
  i_INPUT_PIXEL => w_INPUT_PIXEL_GRAY,
  o_PIX_RDY     => w_PIX_RDY_MO1,
  o_DONE        => o_DONE_MO1,
  o_OUT_PIXEL   => w_PIXEL_MO1_OUT
);

-- Morphological Opening 2
MO2 : Top_MO2_Pipeline
generic map (
  c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MO2,
  c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MO2,
  c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MO2,
  c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MO2
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => i_START_MO2,
  i_VALID_PIXEL => i_VALID_PIXEL_MO2,
  i_INPUT_PIXEL => w_PIXEL_MO2_IN,
  o_PIX_RDY     => w_PIX_RDY_MO2,
  o_DONE        => o_DONE_MO2,
  o_OUT_PIXEL   => w_PIXEL_MO2_OUT
);

-- Morphological Closing
Top_MC_Pipeline_i : Top_MC_Pipeline
generic map (
  c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MC,
  c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MC,
  c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MC,
  c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MC
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => w_PIX_RDY_MO2,
  i_VALID_PIXEL => w_VALID_PIXEL_MC,
  i_INPUT_PIXEL => w_FF_MO2_MC_OUT,
  o_PIX_RDY     => o_PIX_RDY,
  o_DONE        => o_DONE_MC,
  o_OUT_PIXEL   => o_OUT_PIXEL
);

-------- Binarization
OTSU : Top_OTSU
generic map (
  c_SIZE_MEM    => c_SIZE_MEM_OTSU,
  c_WIDTH_PIXEL => c_WIDTH_GRAY_PIXEL,
  c_WIDTH_VAR   => 32                   -- 32 bits floating point
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => i_START,
  i_VALID_PIXEL => i_VALID_PIXEL_OTSU,
  i_PIXEL       => w_RAM_SUB_OUT,
  o_DONE        => o_DONE_OTSU,
  o_THRESHOLD   => w_THRESHOLD
);

-- Logic and arithmetic Operations

  -- Binarization
  w_PIXEL_MO2_IN <= '1' when w_RAM_SUB_OUT >= w_THRESHOLD else '0';

  -- Subtraction
  w_RAM_SUB_IN <= w_RAM_GRAY_OUT - w_REG_MO1_OUT;

-------- Outputs
  o_PIX_RDY_MO1 <= w_PIX_RDY_MO1;

end architecture;
