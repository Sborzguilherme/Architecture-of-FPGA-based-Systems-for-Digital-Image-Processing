----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/03/2018
-- File:    Datapath_Block2.vhd

-- Blocks implemented:
-- RAM_SUB: stores value from previous subtraction
-- OTSU: Finds optime threshold value
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_Block2 is
    generic(
        c_WIDTH_GRAY_PIXEL  : integer;  -- GRAY  8 bits
        c_INPUT_IMG_WIDTH   : integer;
        c_INPUT_IMG_HEIGHT  : integer
    );
    port(
        i_CLK                 : in  std_logic;
        i_RST                 : in  std_logic;
        i_START               : in  std_logic;
        i_VALID_PIXEL         : in  std_logic;
        i_INPUT_PIXEL         : in  std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);
        i_ENA_CNT_R_ADDR_SUB  : in  std_logic;
        i_CLR_CNT_R_ADDR_SUB  : in  std_logic;
        i_ENA_CNT_W_ADDR_SUB  : in  std_logic;
        i_CLR_CNT_W_ADDR_SUB  : in  std_logic;
        o_DONE_OTSU           : out std_logic;
        o_MAX_PIX             : out std_logic;
        o_OUT_PIXEL           : out std_logic
    );
end Datapath_Block2;

architecture arch of Datapath_Block2 is

  constant c_IMG_SIZE : integer := (c_INPUT_IMG_WIDTH * c_INPUT_IMG_HEIGHT);

--------------------------- SIGNALS -------------------------------------
  -- RAM SUB signals
  signal w_R_ADDR_RAM_SUB       : std_logic_vector(16 downto 0); -- Size of addr ram port = 17
  signal w_R_ADDR_RAM_SUB_INT   : integer;
  signal w_W_ADDR_RAM_SUB       : std_logic_vector(16 downto 0);
  signal w_W_ADDR_RAM_SUB_INT   : integer;
  signal w_RAM_SUB_OUT          : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

  -- OTSU signal
  signal w_THRESHOLD  : std_logic_vector(c_WIDTH_GRAY_PIXEL-1 downto 0);

begin

-------- Memorys
  -- RAM SUB
  RAM_SUB : RAM_2_PORT
  port map (
    clock     => i_CLK,
    data      => i_INPUT_PIXEL,
    rdaddress => w_R_ADDR_RAM_SUB,
    wraddress => w_W_ADDR_RAM_SUB,
    wren      => i_VALID_PIXEL,
    q         => w_RAM_SUB_OUT
  );

-------- Counters
-- Counter read address for RAM SUB
CNT_R_ADDR_SUB : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_ENA_CNT_R_ADDR_SUB,
  i_CLR => i_CLR_CNT_R_ADDR_SUB,
  o_Q   => w_R_ADDR_RAM_SUB_INT
);

w_R_ADDR_RAM_SUB <= std_logic_vector(to_unsigned(w_R_ADDR_RAM_SUB_INT, w_R_ADDR_RAM_SUB'length));

-- Counter write address for RAM SUB
CNT_W_ADDR_SUB : Counter
port map (
  i_CLK => i_CLK,
  i_RST => i_RST,
  i_ENA => i_VALID_PIXEL,
  i_CLR => i_CLR_CNT_W_ADDR_SUB,
  o_Q   => w_W_ADDR_RAM_SUB_INT
);

w_W_ADDR_RAM_SUB <= std_logic_vector(to_unsigned(w_W_ADDR_RAM_SUB_INT, w_W_ADDR_RAM_SUB'length));

-- Otsu
Top_OTSU_i : Top_OTSU
generic map (
  c_SIZE_MEM    => 256,
  c_WIDTH_PIXEL => c_WIDTH_GRAY_PIXEL,
  c_WIDTH_VAR   => 32                   -- Floating point 32 bits
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => i_START,
  i_VALID_PIXEL => i_VALID_PIXEL,
  i_PIXEL       => i_INPUT_PIXEL,
  o_DONE        => o_DONE_OTSU,
  o_THRESHOLD   => w_THRESHOLD
);

o_MAX_PIX <= '1' when w_R_ADDR_RAM_SUB_INT > c_IMG_SIZE else '0';

-- Binarization
o_OUT_PIXEL <= '1' when w_RAM_SUB_OUT > w_THRESHOLD else '0';


end architecture;
