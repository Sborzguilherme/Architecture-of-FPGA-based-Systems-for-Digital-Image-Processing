-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    21/02/2018
-- File:    Control_OTSU.vhd

-- FSM that controls the OTSU algorithm

-- States:
-- s_IDLE: Start state where the counters are drained
-- s_HIST: do image histogram (counts the number of pixels for each one of the 256 possible values)
-- s_CALC_WB: Enable update in the wB (weigth background) variable
-- s_CALC_WF: Enable update in the wF (weigth foregroung) and sumB (pixel * qtd_pixels with the same value) variables
-- s_CALC_MB: Enable update in the mB (mean background) and mF (mean foregroung) values
-- s_CALC_VAR_B: Enable update in the varBetween (Class Variance)
-- s_UPDATE_TH: Enable update in threshold value and varMax (Maximum variance) variable, if necessary
-- s_END: Final state. Indicate that the optimized threshold have been found
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Control_OTSU is
  port (
    i_CLK                       : in  std_logic;
    i_RST                       : in  std_logic;
    i_START                     : in  std_logic;
    i_MAX_PIX                   : in  std_logic;
    i_TH_FOUND                  : in  std_logic;
    i_END_ADD_WB                : in  std_logic;
    i_END_WF                    : in  std_logic;
    i_END_ADD_SUM_B             : in  std_logic;
    i_END_SUB_MF                : in  std_logic;
    i_END_MF                    : in  std_logic;
    i_END_AUX_0_VAR_B           : in  std_logic;
    i_END_AUX_1_VAR_B           : in  std_logic;
    i_END_VAR_B                 : in  std_logic;
    i_CONTINUE_WB               : in  std_logic;
    i_END_CONV                  : in  std_logic;
    i_LAST_PIXEL                : in  std_logic;
    o_SEL_MUX                   : out std_logic;
    o_WRI_ENA                   : out std_logic;
    o_WRI_WB                    : out std_logic;
    o_WRI_WF                    : out std_logic;
    o_WRI_SUM_B                 : out std_logic;
    o_WRI_MB                    : out std_logic;
    o_WRI_MF                    : out std_logic;
    o_WRI_VAR_B                 : out std_logic;
    o_WRI_VAR_MAX               : out std_logic;
    o_WRI_TH                    : out std_logic;
    o_WRI_CUR_HIST              : out std_logic;
    o_WRI_AUX_SUM_B             : out std_logic;
    o_WRI_AUX_MF                : out std_logic;
    o_WRI_AUX_SUB_MB_MF         : out std_logic;
    o_WRI_AUX_EXP_MB_MF         : out std_logic;
    o_WRI_AUX_MULT_WB_WF        : out std_logic;
    o_ENA_CNT_ADDR              : out std_logic;
    o_CLR_CNT_ADDR              : out std_logic;
    o_ENA_CNT_PIX               : out std_logic;
    o_CLR_CNT_PIX               : out std_logic;
    o_ENA_CNT_CALC_WB           : out std_logic;
    o_CLR_CNT_CALC_WB           : out std_logic;
    o_ENA_CNT_CALC_WF           : out std_logic;
    o_CLR_CNT_CALC_WF           : out std_logic;
    o_ENA_CNT_CALC_SUM_B        : out std_logic;
    o_CLR_CNT_CALC_SUM_B        : out std_logic;
    o_ENA_CNT_CALC_MB           : out std_logic;
    o_CLR_CNT_CALC_MB           : out std_logic;
    o_ENA_CNT_CALC_MF           : out std_logic;
    o_CLR_CNT_CALC_MF           : out std_logic;
    o_ENA_CNT_CALC_VAR_B        : out std_logic;
    o_CLR_CNT_CALC_VAR_B        : out std_logic;
    o_ENA_CNT_CALC_AUX_0_VAR_B  : out std_logic;
    o_CLR_CNT_CALC_AUX_0_VAR_B  : out std_logic;
    o_ENA_CNT_CALC_AUX_1_VAR_B  : out std_logic;
    o_CLR_CNT_CALC_AUX_1_VAR_B  : out std_logic;
    o_ENA_CNT_CONV              : out std_logic;
    o_CLR_CNT_CONV              : out std_logic;
    o_DONE                      : out std_logic
  );
end Control_OTSU;

architecture arch of Control_OTSU is
  type state_type is (
    s_IDLE,
    s_HIST,
    s_CONV_HIST,
    s_CALC_WB,
    s_SAVE_WB,
    s_CALC_WF,
    s_CALC_SUM_B,
    s_SAVE_SUM_B,
    s_CALC_MB,
    s_CALC_MF,
    s_CALC_AUX_SUB_MB_MF,
    s_CALC_EXP_MB_MF,
    s_CALC_VAR_B,
    s_UPDATE_TH,
    s_END
);
  signal r_state_reg : state_type;
  signal r_next_state : state_type;

begin
  p_state_reg : process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      r_state_reg <= s_IDLE; -- idle
  elsif (rising_edge(i_CLK)) then
      r_state_reg <= r_next_state;
    end if;
  end process;

  p_next_state : process (r_state_reg, i_START, i_MAX_PIX, i_TH_FOUND, i_END_ADD_WB, i_END_WF,
  i_END_ADD_SUM_B, i_END_SUB_MF, i_END_MF, i_END_AUX_0_VAR_B, i_END_AUX_1_VAR_B, i_END_VAR_B,
  i_CONTINUE_WB, i_END_CONV, i_LAST_PIXEL)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_HIST;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_HIST =>
        if(i_MAX_PIX = '1') then -- Verify if all pixels from input image have been considered
          r_next_state <= s_CONV_HIST;
        else
          r_next_state <= s_HIST;
        end if;

      when s_CONV_HIST =>
        if(i_END_CONV = '1') then
          r_next_state <= s_CALC_WB;
        else
          r_next_state <= s_CONV_HIST;
        end if;

      when s_CALC_WB =>
        if(i_END_ADD_WB = '1') then
          r_next_state <= s_SAVE_WB;
        else
          r_next_state <= s_CALC_WB;
        end if;

      when s_SAVE_WB =>
        r_next_state <= s_CALC_WF;

      when s_CALC_WF =>
        if(i_TH_FOUND = '1') then -- Ends operation when the optimzed threshold value has been found
          r_next_state <= s_END;
        elsif(i_CONTINUE_WB = '1') then
            r_next_state <= s_UPDATE_TH;
        elsif(i_END_WF = '1') then
          r_next_state <= s_CALC_SUM_B;
        else
          r_next_state <= s_CALC_WF;
        end if;

      when s_CALC_SUM_B =>
        if(i_END_ADD_SUM_B = '1') then
          r_next_state <= s_SAVE_SUM_B;
        else
          r_next_state <= s_CALC_SUM_B;
        end if;

      when s_SAVE_SUM_B =>
        r_next_state <= s_CALC_MB;

      when s_CALC_MB =>
        if(i_END_SUB_MF = '1') then
          r_next_state <= s_CALC_MF;
        else
          r_next_state <= s_CALC_MB;
        end if;

      when s_CALC_MF =>
        if(i_END_MF = '1') then
          r_next_state <= s_CALC_AUX_SUB_MB_MF;
        else
          r_next_state <= s_CALC_MF;
        end if;

      when s_CALC_AUX_SUB_MB_MF =>
        if(i_END_AUX_0_VAR_B = '1') then
          r_next_state <= s_CALC_EXP_MB_MF;
        else
          r_next_state <= s_CALC_AUX_SUB_MB_MF;
        end if;

      when s_CALC_EXP_MB_MF =>
        if(i_END_AUX_1_VAR_B = '1') then
          r_next_state <= s_CALC_VAR_B;
        else
          r_next_state <= s_CALC_EXP_MB_MF;
        end if;

      when s_CALC_VAR_B =>
        if(i_END_VAR_B = '1') then
          r_next_state <= s_UPDATE_TH;
        else
          r_next_state <= s_CALC_VAR_B;
        end if;

      when s_UPDATE_TH =>
        if(i_LAST_PIXEL = '1') then
          r_next_state <= s_END;
        else
        r_next_state <= s_CONV_HIST;
        --r_next_state <= s_CALC_WB;
      end if;

      when s_END =>
        r_next_state <= s_END;

    end case;
  end process;


  o_SEL_MUX            <= '0' when r_state_reg = s_HIST       else '1';

  o_WRI_ENA            <= '1' when r_state_reg = s_HIST       else '0';

  o_WRI_WB             <= '1' when r_state_reg = s_SAVE_WB    else '0';

  o_WRI_WF             <= '1' when r_state_reg = s_CALC_WF    else '0';

  o_WRI_SUM_B          <= '1' when r_state_reg = s_SAVE_SUM_B    else '0';

  o_WRI_MB             <= '1' when r_state_reg = s_CALC_MB    else '0';

  o_WRI_MF             <= '1' when r_state_reg = s_CALC_MF    else '0';

  o_WRI_VAR_B          <= '1' when r_state_reg = s_CALC_VAR_B else '0';

  o_WRI_VAR_MAX        <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_WRI_TH             <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_ENA_CNT_ADDR       <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_CLR_CNT_ADDR       <= '1' when r_state_reg = s_HIST       else '0';

  o_ENA_CNT_PIX        <= '1' when r_state_reg = s_HIST       else '0';

  o_CLR_CNT_PIX        <= '1' when r_state_reg = s_IDLE       else '0';

  o_ENA_CNT_CALC_WB    <= '1' when r_state_reg = s_CALC_WB    else '0';

  o_CLR_CNT_CALC_WB    <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_ENA_CNT_CALC_WF    <= '1' when r_state_reg = s_CALC_WF    else '0';

  o_CLR_CNT_CALC_WF    <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_ENA_CNT_CALC_MB    <= '1' when r_state_reg = s_CALC_MB    else '0';

  o_CLR_CNT_CALC_MB    <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_ENA_CNT_CALC_VAR_B <= '1' when r_state_reg = s_CALC_VAR_B else '0';

  o_CLR_CNT_CALC_VAR_B <= '1' when r_state_reg = s_UPDATE_TH  else '0';

  o_ENA_CNT_CONV       <= '1' when r_state_reg = s_CONV_HIST  else '0';

  o_CLR_CNT_CONV       <= '1' when r_state_reg = s_HIST or
                                   r_state_reg = s_UPDATE_TH  else '0';

  o_DONE               <= '1' when r_state_reg = s_END        else '0';

  o_WRI_CUR_HIST       <= '1' when r_state_reg = s_CONV_HIST else '0';

  o_WRI_AUX_SUM_B      <= '1' when r_state_reg = s_CALC_WF else '0';

  o_WRI_AUX_MF         <= '1' when r_state_reg = s_CALC_MB else '0';

  o_WRI_AUX_SUB_MB_MF  <= '1' when r_state_reg = s_CALC_AUX_SUB_MB_MF else '0';

  o_WRI_AUX_EXP_MB_MF  <= '1' when r_state_reg = s_CALC_EXP_MB_MF else '0';

  o_WRI_AUX_MULT_WB_WF <= '1' when r_state_reg = s_CALC_AUX_SUB_MB_MF else '0';

  o_ENA_CNT_CALC_SUM_B <= '1' when r_state_reg = s_CALC_SUM_B else '0';

  o_CLR_CNT_CALC_SUM_B <= '1' when r_state_reg = s_UPDATE_TH else '0';

  o_ENA_CNT_CALC_MF    <= '1' when r_state_reg = s_CALC_MF else '0';

  o_CLR_CNT_CALC_MF    <= '1' when r_state_reg = s_UPDATE_TH else '0';

  o_ENA_CNT_CALC_AUX_0_VAR_B  <= '1' when r_state_reg = s_CALC_AUX_SUB_MB_MF else '0';

  o_CLR_CNT_CALC_AUX_0_VAR_B  <= '1' when r_state_reg = s_UPDATE_TH else '0';

  o_ENA_CNT_CALC_AUX_1_VAR_B  <= '1' when r_state_reg = s_CALC_EXP_MB_MF else '0';

  o_CLR_CNT_CALC_AUX_1_VAR_B  <= '1' when r_state_reg = s_UPDATE_TH else '0';

end arch;
