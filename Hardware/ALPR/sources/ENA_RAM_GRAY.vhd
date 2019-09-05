---------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    05/03/2018
-- File:    Datapath_Select_Ena_RAM_Gray.vhd

-- Datapath with counters and comparators to generate signals needed to control which pixels
-- will be written into the RAM Gray memory
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity ENA_RAM_GRAY is
    generic(
        c_KERNEL_HEIGHT     : integer;
        c_KERNEL_WIDTH      : integer;
        c_INPUT_IMG_HEIGHT  : integer;
        c_INPUT_IMG_WIDTH   : integer

    );
    port(
        i_CLK               : in  std_logic;
        i_RST               : in  std_logic;
        i_VALID_PIXEL       : in  std_logic;
        o_DONE              : out std_logic;
        o_VALID_ADDR        : out std_logic
    );
end ENA_RAM_GRAY;

architecture arch of ENA_RAM_GRAY is

    -- Comparison
    constant c_MIN_LIN   : integer := (c_KERNEL_HEIGHT-1);
    constant c_MAX_LIN   : integer := c_INPUT_IMG_HEIGHT-(c_MIN_LIN);
    constant c_MIN_COL   : integer := (c_KERNEL_WIDTH-1);
    constant c_MAX_COL   : integer := c_INPUT_IMG_WIDTH-(c_MIN_COL);

    signal  w_MIN_LIN    : std_logic;
    signal  w_MIN_COL    : std_logic;
    signal  w_MAX_LIN    : std_logic;
    signal  w_MAX_COL    : std_logic;

    signal w_CNT_COL_OUT : integer;
    signal w_CNT_LIN_OUT : integer;

    signal w_CLR_CNT_COL : std_logic;
    signal w_CLR_CNT_LIN : std_logic;
    signal w_ENA_CNT_LIN : std_logic;

begin

    CNT_COL : Counter
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_ENA => i_VALID_PIXEL,
      i_CLR => w_ENA_CNT_LIN,
      o_Q   => w_CNT_COL_OUT
    );

    CNT_LIN : Counter
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_ENA => w_ENA_CNT_LIN,
      i_CLR => w_CLR_CNT_LIN,
      o_Q   => w_CNT_LIN_OUT
    );

    w_CLR_CNT_LIN <= '0';

    UPADTE: process(i_CLK, w_CNT_COL_OUT)
    begin
        if(rising_edge(i_CLK)) then
          if(w_CNT_COL_OUT >= (c_INPUT_IMG_WIDTH-2)) then
            w_CLR_CNT_COL <= '1';
            w_ENA_CNT_LIN <= '1';
          else
            w_CLR_CNT_COL <= '0';
            w_ENA_CNT_LIN <= '0';
          end if;
        end if;
    end process;

   w_MIN_LIN <= '1' when w_CNT_LIN_OUT >= c_MIN_LIN else '0';
   w_MIN_COL <= '1' when w_CNT_COL_OUT >= c_MIN_COL else '0';

   w_MAX_LIN <= '1' when w_CNT_LIN_OUT >=  c_MAX_LIN else '0';
   w_MAX_COL <= '1' when w_CNT_COL_OUT >=  c_MAX_COL else '0';

   o_VALID_ADDR <= w_MIN_LIN and w_MIN_COL and (not w_MAX_LIN) and (not w_MAX_COL);

   o_DONE <= '1' when w_CNT_LIN_OUT >= c_INPUT_IMG_HEIGHT else '0';

end architecture;
