----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    12/03/2018
-- File:    Datapath_Block1.vhd

-- Blocks implemented:
-- RGB2GRAY: Convert 24 bits RGB pixel in 8 bits grayscale pixel
-- RAM_GRAY: Stores Grayscale image
-- Crop: Decides the pixels that will be stored in the RAM_Gray
-- MO1: Morphological Opening over grayscale image
-- Subtraction: Operation between to grayscale and MO1 output, resulting in a highlighted image
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_Block1 is
    generic(
        c_WIDTH_INPUT_PIXEL : integer;  -- RGB   24 bits
        c_WIDTH_GRAY_PIXEL  : integer;  -- GRAY  8 bits
        c_KERNEL_HEIGHT_MO1 : integer;
        c_KERNEL_WIDTH_MO1  : integer;
        c_INPUT_IMG_HEIGHT  : integer;
        c_INPUT_IMG_WIDTH   : integer
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
        o_DONE                : out std_logic;
        o_PIX_RDY             : out std_logic;
        o_OUT_PIXEL           : out std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0)
    );
end Datapath_Block1;

architecture arch of Datapath_Block1 is

  constant c_FIRST_PIX_SAVE : integer := (c_INPUT_IMG_WIDTH * (c_KERNEL_HEIGHT_MO1-1) + c_KERNEL_WIDTH_MO1);

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

-- Morphological Operations Signals
  signal w_PIXEL_MO1_OUT     : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_REG_MO1_OUT       : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
  signal w_PIX_RDY_MO1       : std_logic;
  signal w_DONE_RAM_GRAY     : std_logic;

  -- counter signals
  signal w_CNT_ENA_RAM       : integer;

begin

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
  i_ENA => w_PIX_RDY_MO1,
  i_CLR => i_CLR_CNT_R_ADDR_GRAY,
  o_Q   => w_R_ADDR_RAM_GRAY_INT
);

w_R_ADDR_RAM_GRAY <= std_logic_vector(to_unsigned(w_R_ADDR_RAM_GRAY_INT, w_R_ADDR_RAM_GRAY'length));

-- Counter write address for RAM GRAY
CNT_W_ADDR_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => w_ENA_WRI_RAM_GRAY,
  i_CLR => i_CLR_CNT_W_ADDR_GRAY,
  o_Q   => w_W_ADDR_RAM_GRAY_INT
);

w_W_ADDR_RAM_GRAY <= std_logic_vector(to_unsigned(w_W_ADDR_RAM_GRAY_INT, w_W_ADDR_RAM_GRAY'length));

-- Counter enable for RAM Gray
CNT_ENA_GRAY : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_VALID_PIXEL,
  i_CLR => i_RST,
  o_Q   => w_CNT_ENA_RAM
);

--w_ENA_WRI_RAM_GRAY <= '1' when w_CNT_ENA_RAM >= c_FIRST_PIX_SAVE-2 else '0';

-- CROP
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
  o_DONE        => w_DONE_RAM_GRAY,
  o_VALID_ADDR  => w_ENA_WRI_RAM_GRAY
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
  o_DONE        => o_DONE,
  o_OUT_PIXEL   => w_PIXEL_MO1_OUT
);

-- Delay Pixel Ready
Flip_Flop_i : Flip_Flop
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => '1',
  i_CLR  => '0',
  i_DIN  => w_PIX_RDY_MO1,
  o_DOUT => o_PIX_RDY
);

  -- Subtraction
  o_OUT_PIXEL <= w_RAM_GRAY_OUT - w_REG_MO1_OUT;
-------- Outputs
  --o_PIX_RDY <= w_PIX_RDY_MO1;

end architecture;
