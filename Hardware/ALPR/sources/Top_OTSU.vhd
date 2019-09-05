-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    28/01/2019
-- File:    Top_OTSU
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Top_OTSU is
  generic(
  c_SIZE_MEM     : integer := 256;
  c_WIDTH_PIXEL  : integer := 8;
  c_WIDTH_VAR    : integer := 32
  );
  port(
    i_CLK           : in  std_logic;
    i_RST           : in  std_logic;
    i_START         : in  std_logic;
    i_VALID_PIXEL   : in  std_logic;
    i_PIXEL         : in  std_logic_vector(c_WIDTH_PIXEL-1 downto 0);
    o_DONE          : out std_logic;
    o_THRESHOLD     : out std_logic_vector(c_WIDTH_PIXEL-1 downto 0)
  );

end Top_OTSU;

architecture arch of Top_OTSU is

  signal w_SEL_MUX                  : std_logic;
  signal w_WRI_ENA                  : std_logic;
  signal w_WRI_WB                   : std_logic;
  signal w_WRI_WF                   : std_logic;
  signal w_WRI_SUM_B                : std_logic;
  signal w_WRI_MB                   : std_logic;
  signal w_WRI_MF                   : std_logic;
  signal w_WRI_VAR_B                : std_logic;
  signal w_WRI_VAR_MAX              : std_logic;
  signal w_WRI_TH                   : std_logic;
  signal w_ENA_CNT_ADDR             : std_logic;
  signal w_CLR_CNT_ADDR             : std_logic;
  signal w_ENA_CNT_PIX              : std_logic;
  signal w_CLR_CNT_PIX              : std_logic;
  signal w_MAX_PIX                  : std_logic;
  signal w_LAST_PIXEL               : std_logic;
  signal w_TH_FOUND                 : std_logic;
  signal w_END_CONV                 : std_logic;
  signal w_ENA_CNT_CALC_WB          : std_logic;
  signal w_CLR_CNT_CALC_WB          : std_logic;
  signal w_ENA_CNT_CALC_WF          : std_logic;
  signal w_CLR_CNT_CALC_WF          : std_logic;
  signal w_ENA_CNT_CALC_MB          : std_logic;
  signal w_CLR_CNT_CALC_MB          : std_logic;
  signal w_ENA_CNT_CALC_VAR_B       : std_logic;
  signal w_CLR_CNT_CALC_VAR_B       : std_logic;
  signal w_END_ADD_WB               : std_logic;
  signal w_END_ADD_MULT_SUM_B       : std_logic;
  signal w_END_SUB_DIV_MF           : std_logic;
  signal w_END_VAR_B                : std_logic;
  signal w_CONTINUE_WB              : std_logic;
  signal w_ENA_CNT_CONV             : std_logic;
  signal w_CLR_CNT_CONV             : std_logic;
  signal w_WRI_CUR_HIST             : std_logic;
  signal w_WRI_AUX_SUM_B            : std_logic;
  signal w_WRI_AUX_MF               : std_logic;
  signal w_WRI_AUX_SUB_MB_MF        : std_logic;
  signal w_WRI_AUX_EXP_MB_MF        : std_logic;
  signal w_WRI_AUX_MULT_WB_WF       : std_logic;
  signal w_ENA_CNT_CALC_SUM_B       : std_logic;
  signal w_CLR_CNT_CALC_SUM_B       : std_logic;
  signal w_ENA_CNT_CALC_MF          : std_logic;
  signal w_CLR_CNT_CALC_MF          : std_logic;
  signal w_ENA_CNT_CALC_AUX_0_VAR_B : std_logic;
  signal w_CLR_CNT_CALC_AUX_0_VAR_B : std_logic;
  signal w_ENA_CNT_CALC_AUX_1_VAR_B : std_logic;
  signal w_CLR_CNT_CALC_AUX_1_VAR_B : std_logic;
  signal w_END_SUB_MF               : std_logic;
  signal w_END_ADD_SUM_B            : std_logic;
  signal w_END_MF                   : std_logic;
  signal w_END_WF                   : std_logic;
  signal w_END_AUX_0_VAR_B          : std_logic;
  signal w_END_AUX_1_VAR_B          : std_logic;

begin

  Datapath_OTSU_i : Datapath_OTSU
  generic map (
    c_SIZE_MEM    => c_SIZE_MEM,
    c_WIDTH_PIXEL => c_WIDTH_PIXEL,
    c_WIDTH_VAR   => c_WIDTH_VAR
  )
  port map (
    i_CLK                      => i_CLK,
    i_RST                      => i_RST,
    i_PIXEL                    => i_PIXEL,
    i_VALID_PIXEL              => i_VALID_PIXEL,
    i_SEL_MUX                  => w_SEL_MUX,
    i_WRI_ENA                  => w_WRI_ENA,
    i_WRI_WB                   => w_WRI_WB,
    i_WRI_WF                   => w_WRI_WF,
    i_WRI_SUM_B                => w_WRI_SUM_B,
    i_WRI_MB                   => w_WRI_MB,
    i_WRI_MF                   => w_WRI_MF,
    i_WRI_VAR_B                => w_WRI_VAR_B,
    i_WRI_VAR_MAX              => w_WRI_VAR_MAX,
    i_WRI_TH                   => w_WRI_TH,
    i_WRI_CUR_HIST             => w_WRI_CUR_HIST,
    i_WRI_AUX_SUM_B            => w_WRI_AUX_SUM_B,
    i_WRI_AUX_MF               => w_WRI_AUX_MF,
    i_WRI_AUX_SUB_MB_MF        => w_WRI_AUX_SUB_MB_MF,
    i_WRI_AUX_EXP_MB_MF        => w_WRI_AUX_EXP_MB_MF,
    i_WRI_AUX_MULT_WB_WF       => w_WRI_AUX_MULT_WB_WF,
    i_ENA_CNT_ADDR             => w_ENA_CNT_ADDR,
    i_CLR_CNT_ADDR             => w_CLR_CNT_ADDR,
    i_ENA_CNT_PIX              => w_ENA_CNT_PIX,
    i_CLR_CNT_PIX              => w_CLR_CNT_PIX,
    i_ENA_CNT_CALC_WB          => w_ENA_CNT_CALC_WB,
    i_CLR_CNT_CALC_WB          => w_CLR_CNT_CALC_WB,
    i_ENA_CNT_CALC_WF          => w_ENA_CNT_CALC_WF,
    i_CLR_CNT_CALC_WF          => w_CLR_CNT_CALC_WF,
    i_ENA_CNT_CALC_SUM_B       => w_ENA_CNT_CALC_SUM_B,
    i_CLR_CNT_CALC_SUM_B       => w_CLR_CNT_CALC_SUM_B,
    i_ENA_CNT_CALC_MB          => w_ENA_CNT_CALC_MB,
    i_CLR_CNT_CALC_MB          => w_CLR_CNT_CALC_MB,
    i_ENA_CNT_CALC_MF          => w_ENA_CNT_CALC_MF,
    i_CLR_CNT_CALC_MF          => w_CLR_CNT_CALC_MF,
    i_ENA_CNT_CALC_VAR_B       => w_ENA_CNT_CALC_VAR_B,
    i_CLR_CNT_CALC_VAR_B       => w_CLR_CNT_CALC_VAR_B,
    i_ENA_CNT_CALC_AUX_0_VAR_B => w_ENA_CNT_CALC_AUX_0_VAR_B,
    i_CLR_CNT_CALC_AUX_0_VAR_B => w_CLR_CNT_CALC_AUX_0_VAR_B,
    i_ENA_CNT_CALC_AUX_1_VAR_B => w_ENA_CNT_CALC_AUX_1_VAR_B,
    i_CLR_CNT_CALC_AUX_1_VAR_B => w_CLR_CNT_CALC_AUX_1_VAR_B,
    i_ENA_CNT_CONV             => w_ENA_CNT_CONV,
    i_CLR_CNT_CONV             => w_CLR_CNT_CONV,
    o_END_ADD_WB               => w_END_ADD_WB,
    o_END_WF                   => w_END_WF,
    o_END_ADD_SUM_B            => w_END_ADD_SUM_B,
    o_END_SUB_MF               => w_END_SUB_MF,
    o_END_MF                   => w_END_MF,
    o_END_AUX_0_VAR_B          => w_END_AUX_0_VAR_B,
    o_END_AUX_1_VAR_B          => w_END_AUX_1_VAR_B,
    o_END_VAR_B                => w_END_VAR_B,
    o_CONTINUE_WB              => w_CONTINUE_WB,
    o_MAX_PIX                  => w_MAX_PIX,
    o_END_CONV                 => w_END_CONV,
    o_LAST_PIXEL               => w_LAST_PIXEL,
    o_TH_FOUND                 => w_TH_FOUND,
    o_THRESHOLD                => o_THRESHOLD
  );

Control_OTSU_i : Control_OTSU
port map (
  i_CLK                      => i_CLK,
  i_RST                      => i_RST,
  i_START                    => i_START,
  i_MAX_PIX                  => w_MAX_PIX,
  i_TH_FOUND                 => w_TH_FOUND,
  i_END_ADD_WB               => w_END_ADD_WB,
  i_END_WF                   => w_END_WF,
  i_END_ADD_SUM_B            => w_END_ADD_SUM_B,
  i_END_SUB_MF               => w_END_SUB_MF,
  i_END_MF                   => w_END_MF,
  i_END_AUX_0_VAR_B          => w_END_AUX_0_VAR_B,
  i_END_AUX_1_VAR_B          => w_END_AUX_1_VAR_B,
  i_END_VAR_B                => w_END_VAR_B,
  i_CONTINUE_WB              => w_CONTINUE_WB,
  i_END_CONV                 => w_END_CONV,
  i_LAST_PIXEL               => w_LAST_PIXEL,
  o_SEL_MUX                  => w_SEL_MUX,
  o_WRI_ENA                  => w_WRI_ENA,
  o_WRI_WB                   => w_WRI_WB,
  o_WRI_WF                   => w_WRI_WF,
  o_WRI_SUM_B                => w_WRI_SUM_B,
  o_WRI_MB                   => w_WRI_MB,
  o_WRI_MF                   => w_WRI_MF,
  o_WRI_VAR_B                => w_WRI_VAR_B,
  o_WRI_VAR_MAX              => w_WRI_VAR_MAX,
  o_WRI_TH                   => w_WRI_TH,
  o_WRI_CUR_HIST             => w_WRI_CUR_HIST,
  o_WRI_AUX_SUM_B            => w_WRI_AUX_SUM_B,
  o_WRI_AUX_MF               => w_WRI_AUX_MF,
  o_WRI_AUX_SUB_MB_MF        => w_WRI_AUX_SUB_MB_MF,
  o_WRI_AUX_EXP_MB_MF        => w_WRI_AUX_EXP_MB_MF,
  o_WRI_AUX_MULT_WB_WF       => w_WRI_AUX_MULT_WB_WF,
  o_ENA_CNT_ADDR             => w_ENA_CNT_ADDR,
  o_CLR_CNT_ADDR             => w_CLR_CNT_ADDR,
  o_ENA_CNT_PIX              => w_ENA_CNT_PIX,
  o_CLR_CNT_PIX              => w_CLR_CNT_PIX,
  o_ENA_CNT_CALC_WB          => w_ENA_CNT_CALC_WB,
  o_CLR_CNT_CALC_WB          => w_CLR_CNT_CALC_WB,
  o_ENA_CNT_CALC_WF          => w_ENA_CNT_CALC_WF,
  o_CLR_CNT_CALC_WF          => w_CLR_CNT_CALC_WF,
  o_ENA_CNT_CALC_SUM_B       => w_ENA_CNT_CALC_SUM_B,
  o_CLR_CNT_CALC_SUM_B       => w_CLR_CNT_CALC_SUM_B,
  o_ENA_CNT_CALC_MB          => w_ENA_CNT_CALC_MB,
  o_CLR_CNT_CALC_MB          => w_CLR_CNT_CALC_MB,
  o_ENA_CNT_CALC_MF          => w_ENA_CNT_CALC_MF,
  o_CLR_CNT_CALC_MF          => w_CLR_CNT_CALC_MF,
  o_ENA_CNT_CALC_VAR_B       => w_ENA_CNT_CALC_VAR_B,
  o_CLR_CNT_CALC_VAR_B       => w_CLR_CNT_CALC_VAR_B,
  o_ENA_CNT_CALC_AUX_0_VAR_B => w_ENA_CNT_CALC_AUX_0_VAR_B,
  o_CLR_CNT_CALC_AUX_0_VAR_B => w_CLR_CNT_CALC_AUX_0_VAR_B,
  o_ENA_CNT_CALC_AUX_1_VAR_B => w_ENA_CNT_CALC_AUX_1_VAR_B,
  o_CLR_CNT_CALC_AUX_1_VAR_B => w_CLR_CNT_CALC_AUX_1_VAR_B,
  o_ENA_CNT_CONV             => w_ENA_CNT_CONV,
  o_CLR_CNT_CONV             => w_CLR_CNT_CONV,
  o_DONE                     => o_DONE
);


end architecture;
