-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/03/2019
-- File:    Control_Block2.vhd

-- States:

-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Control_Block2 is
  port (
    i_CLK                 : in  std_logic;
    i_RST                 : in  std_logic;
    i_START               : in  std_logic;
    i_DONE_BLOCK1         : in  std_logic;
    i_DONE_OTSU           : in  std_logic;
    i_MAX_PIX             : in  std_logic;
    o_ENA_CNT_R_ADDR_SUB  : out std_logic;
    o_CLR_CNT_R_ADDR_SUB  : out std_logic;
    o_ENA_CNT_W_ADDR_SUB  : out std_logic;
    o_CLR_CNT_W_ADDR_SUB  : out std_logic;
    o_PIX_RDY             : out std_logic;
    o_DONE                : out std_logic
  );
end Control_Block2;

architecture arch of Control_Block2 is
  type state_type is (
    s_IDLE,
    s_SAVE_SUB,
    s_OTSU,
    s_BINARIZATION,
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

  p_next_state : process (r_state_reg, i_START, i_DONE_BLOCK1, i_DONE_OTSU, i_MAX_PIX)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_SAVE_SUB;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_SAVE_SUB =>
        if (i_DONE_BLOCK1 = '1') then
            r_next_state <= s_OTSU;
        else
            r_next_state <= s_SAVE_SUB;
        end if;

      when s_OTSU =>
        if (i_DONE_OTSU = '1') then
            r_next_state <= s_BINARIZATION;
        else
            r_next_state <= s_OTSU;
        end if;

      when s_BINARIZATION =>
        if(i_MAX_PIX = '1') then
          r_next_state <= s_END;
        else
          r_next_state <= s_BINARIZATION;
        end if;

      when s_END =>
          r_next_state <= s_END;

    end case;
  end process;


  o_ENA_CNT_R_ADDR_SUB  <= '1' when r_next_state = s_BINARIZATION  else '0';
  o_CLR_CNT_R_ADDR_SUB  <= '1' when r_next_state = s_IDLE          else '0';
  o_ENA_CNT_W_ADDR_SUB  <= '1' when r_next_state = s_SAVE_SUB      else '0';
  o_CLR_CNT_W_ADDR_SUB  <= '1' when r_next_state = s_IDLE          else '0';
  o_PIX_RDY             <= '1' when r_next_state = s_BINARIZATION  else '0';
  o_DONE                <= '1' when r_next_state = s_END           else '0';

end arch;
