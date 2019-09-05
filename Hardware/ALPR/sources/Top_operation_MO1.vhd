-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    28/01/2019
-- File:    Top_Operation.vhd

-- Block that implements Erode or dilate operation, depending on the s_SEL_OPERATION values
-- 0 = Erode, 1 = Dilate
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_Operation_MO1 is
    generic(
        c_WIDTH_DATA       : integer;
        c_KERNEL_HEIGHT    : integer;
        c_KERNEL_WIDTH     : integer;
        c_INPUT_IMG_WIDTH  : integer;
        c_INPUT_IMG_HEIGHT : integer;
        s_SEL_OPERATION    : integer
    );
    port(
        i_CLK         : in std_logic;
        i_RST         : in std_logic;
        i_START       : in std_logic;
        i_VALID_PIXEL : in std_logic;
        i_INPUT_PIXEL : in std_logic_vector(c_WIDTH_DATA-1 downto 0);
        o_PIX_RDY     : out std_logic;
        o_DONE        : out std_logic;
        o_OUT_PIXEL   : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
    );
end Top_Operation_MO1;

architecture arch of Top_Operation_MO1 is

    signal w_ENA_CNT_KER_TOT : std_logic;
    signal w_CLR_CNT_KER_TOT : std_logic;
    signal w_ENA_CNT_KER_ROW : std_logic;
    signal w_CLR_CNT_KER_ROW : std_logic;
    signal w_ENA_CNT_INV_KER : std_logic;
    signal w_CLR_CNT_INV_KER : std_logic;
    signal w_ENA_CNT_BUF_FIL : std_logic;
    signal w_CLR_CNT_BUF_FIL : std_logic;
    signal w_ENA_WRI_KER     : std_logic;
    signal w_MAX_KER_TOT     : std_logic;
    signal w_MAX_KER_ROW     : std_logic;
    signal w_MAX_INV_KER     : std_logic;
    signal w_BUFFERS_FILLED  : std_logic;
    signal w_PIX_RDY         : std_logic;

begin

    Datapath_Operation_i : Datapath_MO1
    generic map (
        c_WIDTH_DATA       => c_WIDTH_DATA,
        c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT,
        c_KERNEL_WIDTH     => c_KERNEL_WIDTH,
        c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH,
        c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT,
        s_SEL_OPERATION    => s_SEL_OPERATION
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
        i_ENA_CNT_INV_KER => w_ENA_CNT_INV_KER,
        i_CLR_CNT_INV_KER => w_CLR_CNT_INV_KER,
        i_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
        i_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
        i_ENA_WRI_KER     => w_ENA_WRI_KER,
        o_MAX_KER_TOT     => w_MAX_KER_TOT,
        o_MAX_KER_ROW     => w_MAX_KER_ROW,
        o_MAX_INV_KER     => w_MAX_INV_KER,
        o_BUFFERS_FILLED  => w_BUFFERS_FILLED,
        o_OUT_PIXEL       => o_OUT_PIXEL
    );

        Control_0 : entity work.Control_2_Stages
        port map (
          i_CLK             => i_CLK,
          i_RST             => i_RST,
          i_START           => i_START,
          i_BUFFERS_FILLED  => w_BUFFERS_FILLED,
          i_MAX_KER_TOT     => w_MAX_KER_TOT,
          i_MAX_KER_ROW     => w_MAX_KER_ROW,
          i_MAX_INV_KER     => w_MAX_INV_KER,
          o_ENA_CNT_KER_TOT => w_ENA_CNT_KER_TOT,
          o_CLR_CNT_KER_TOT => w_CLR_CNT_KER_TOT,
          o_ENA_CNT_KER_ROW => w_ENA_CNT_KER_ROW,
          o_CLR_CNT_KER_ROW => w_CLR_CNT_KER_ROW,
          o_ENA_CNT_INV_KER => w_ENA_CNT_INV_KER,
          o_CLR_CNT_INV_KER => w_CLR_CNT_INV_KER,
          o_ENA_CNT_BUF_FIL => w_ENA_CNT_BUF_FIL,
          o_CLR_CNT_BUF_FIL => w_CLR_CNT_BUF_FIL,
          o_ENA_WRI_KER     => w_ENA_WRI_KER,
          o_PIX_RDY         => w_PIX_RDY,
          o_DONE            => o_DONE
        );

o_PIX_RDY <= w_PIX_RDY and i_VALID_PIXEL;


end architecture;
