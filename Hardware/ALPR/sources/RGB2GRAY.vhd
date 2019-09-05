-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 20/02/2019
-- File: RGB2GRAY.vhd

-- OpenCV Function to convert RGB image to grayscale
-- Y = (0.299 * R) + (0.587*G) + (0.144*B)
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.ALPR_package.all;	-- Package with project types


entity RGB2GRAY is
generic (
    c_WIDTH_INPUT_DATA  : integer;
    c_WIDTH_OUTPUT_DATA : integer
);
port(
    --i_CLK           : in std_logic;
    --i_RST           : in std_logic;
    i_INPUT_PIXEL 	: in  std_logic_vector(c_WIDTH_INPUT_DATA-1  downto 0);
    o_OUT_PIXEL   	: out std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0)
);
end RGB2GRAY;

architecture arch of RGB2GRAY is

  -- Separeted channels
  signal w_RED   : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0);
  signal w_GREEN : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0);
  signal w_BLUE  : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0);

  -- Multiplication result
  signal w_MULT_RESUL : std_logic_vector((c_WIDTH_OUTPUT_DATA*2)-1 downto 0);

  -- Constants that multiplies each channel
  constant c_R   : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0) := x"4D";
  constant c_G   : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0) := x"96";
  constant c_B   : std_logic_vector(c_WIDTH_OUTPUT_DATA-1 downto 0) := x"1D";

begin
  -- input(24 downto 16)
  w_RED   <= i_INPUT_PIXEL(c_WIDTH_INPUT_DATA-1 downto c_WIDTH_INPUT_DATA-c_WIDTH_OUTPUT_DATA);
  w_GREEN <= i_INPUT_PIXEL((c_WIDTH_INPUT_DATA-c_WIDTH_OUTPUT_DATA)-1 downto c_WIDTH_OUTPUT_DATA);
  w_BLUE  <= i_INPUT_PIXEL(c_WIDTH_OUTPUT_DATA-1 downto 0);

  --calc : process(i_CLK, i_RST)
  --begin
    --if (i_RST = '1') then
      --w_MULT_RESUL <= (others=>'0');
    --elsif (rising_edge(i_CLK)) then
      w_MULT_RESUL <= (w_RED * c_R) + (w_GREEN * c_G) + (w_BLUE * c_B);
    --end if;
  --end process;

  o_OUT_PIXEL <= w_MULT_RESUL((c_WIDTH_OUTPUT_DATA*2)-1 downto c_WIDTH_OUTPUT_DATA);

end architecture;
