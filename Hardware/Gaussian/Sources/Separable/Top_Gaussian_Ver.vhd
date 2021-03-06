-----------------------------------------------------------------
-- Project: Gaussian
-- Author:  Guilherme Sborz
-- Date:    15/08/2019
-- File:    Top_Gaussian_Ver.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity Top_Gaussian_Ver is
  generic(
      p_KERNEL_HEIGHT    : integer := 3;
      p_INPUT_IMG_WIDTH  : integer := 514;
      p_INPUT_IMG_HEIGHT : integer := 514
  );
  port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_START       : in std_logic;
      i_VALID_PIXEL : in std_logic;
      i_INPUT_PIXEL : in fixed;
      o_PIX_RDY     : out std_logic;
      o_DONE        : out std_logic;
      o_OUT_PIXEL   : out fixed
  );
end Top_Gaussian_Ver;

architecture arch of Top_Gaussian_Ver is

    signal w_ENA_CNT_KER_TOT      : std_logic;
    signal w_CLR_CNT_KER_TOT      : std_logic;
    signal w_ENA_CNT_KER_ROW      : std_logic;
    signal w_CLR_CNT_KER_ROW      : std_logic;
    signal w_ENA_CNT_BUF_FIL      : std_logic;
    signal w_CLR_CNT_BUF_FIL      : std_logic;
    signal w_ENA_WRI_KER          : std_logic;
    signal w_ENA_WRI_REG          : std_logic;
    signal w_MAX_KER_TOT          : std_logic;
    signal w_MAX_KER_ROW          : std_logic;
    signal w_BUFFERS_FILLED       : std_logic;
    signal w_ENA_CNT_ADDR_FILTER  : std_logic;
    signal w_CLR_CNT_ADDR_FILTER  : std_logic;
    signal w_ENA_CNT_ADDR_BIAS    : std_logic;
    signal w_CLR_CNT_ADDR_BIAS    : std_logic;
    signal w_PIX_RDY              : std_logic;
    signal w_DONE                 : std_logic;
    signal w_BUF_DONE             : std_logic_vector(5 downto 0) := (others=>'0');
    signal w_BUF_RDY              : std_logic_vector(5 downto 0) := (others=>'0');
    signal w_LAST_VALID           : std_logic_vector(1 downto 0) := (others=>'0');
    -- Signals to test in Quartus
    -- signal r_REG_OUT				      : fixed;
	  -- signal r_IN_PIX 			        : fixed;
	  -- signal r_OUT_PIX 			        : fixed;

begin

-- registers : process(i_CLK)
--   begin
--     if rising_edge(i_CLK) then
--       r_IN_PIX <= i_INPUT_PIXEL;
--       r_OUT_PIX <= r_REG_OUT;
--     end if;
--   end process;

shift_left_signals : process(i_CLK, i_VALID_PIXEL, w_BUF_RDY, w_BUF_DONE)
  begin
      if(rising_edge(i_CLK)) then
        if(w_LAST_VALID(0) = '1') then
          w_BUF_RDY(5 downto 1) <= w_BUF_RDY(4 downto 0);
          w_BUF_DONE(5 downto 1) <= w_BUF_DONE(4 downto 0);
          w_BUF_DONE(0) <= w_DONE;
          w_BUF_RDY(0) <= w_PIX_RDY;
        end if;
        w_LAST_VALID(1) <= w_LAST_VALID(0);
        w_LAST_VALID(0) <= i_VALID_PIXEL;
      end if;
  end process;

  Datapath_Gauss_Ver_i : Datapath_Gauss_Ver
  generic map (
    p_KERNEL_HEIGHT    => p_KERNEL_HEIGHT,
    p_INPUT_IMG_WIDTH  => p_INPUT_IMG_WIDTH,
    p_INPUT_IMG_HEIGHT => p_INPUT_IMG_HEIGHT
  )
  port map (
    i_CLK             => i_CLK,
    i_RST             => i_RST,
    i_INPUT_PIXEL     => i_INPUT_PIXEL,
    i_VALID_PIXEL     => i_VALID_PIXEL,
    i_ENA_CNT_KER_TOT => w_ENA_CNT_KER_TOT,
    i_CLR_CNT_KER_TOT => w_CLR_CNT_KER_TOT,
    i_ENA_CNT_KER_ROW => w_ENA_CNT_KER_ROW,
    i_CLR_CNT_KER_ROW => w_CLR_CNT_KER_ROW,
    i_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
    i_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
    i_ENA_WRI_KER     => w_ENA_WRI_KER,
    i_ENA_WRI_REG     => w_ENA_WRI_REG,
    o_MAX_KER_TOT     => w_MAX_KER_TOT,
    o_MAX_KER_ROW     => w_MAX_KER_ROW,
    o_BUFFERS_FILLED  => w_BUFFERS_FILLED,
    o_OUT_PIXEL         => o_OUT_PIXEL
  );

    Control_Convolution_i : Control_Ver
    port map (
      i_CLK             => i_CLK,
      i_RST             => i_RST,
      i_START           => i_START,
      i_VALID_PIXEL     => i_VALID_PIXEL,
      i_BUFFERS_FILLED  => w_BUFFERS_FILLED,
      i_MAX_KER_TOT     => w_MAX_KER_TOT,
      i_MAX_KER_ROW     => w_MAX_KER_ROW,
      o_ENA_CNT_KER_TOT => w_ENA_CNT_KER_TOT,
      o_CLR_CNT_KER_TOT => w_CLR_CNT_KER_TOT,
      o_ENA_CNT_KER_ROW => w_ENA_CNT_KER_ROW,
      o_CLR_CNT_KER_ROW => w_CLR_CNT_KER_ROW,
      o_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
      o_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
      o_ENA_WRI_KER     => w_ENA_WRI_KER,
      o_ENA_WRI_REG     => w_ENA_WRI_REG,
      o_PIX_RDY         => w_PIX_RDY,
      o_DONE            => w_DONE
    );

    g_output_singals : if p_KERNEL_HEIGHT = 3 generate
        o_PIX_RDY <= w_BUF_RDY(1) and w_LAST_VALID(0);
        o_DONE    <= w_BUF_DONE(1) and w_LAST_VALID(0);

    elsif p_KERNEL_HEIGHT = 5 generate
       o_PIX_RDY <= w_BUF_RDY(2) and w_LAST_VALID(1);
       o_DONE    <= w_BUF_DONE(2) and w_LAST_VALID(1);

    else generate
       o_PIX_RDY <= w_BUF_RDY(2) and w_LAST_VALID(1);
       o_DONE    <= w_BUF_DONE(2) and w_LAST_VALID(1);
    end generate;

end architecture;
