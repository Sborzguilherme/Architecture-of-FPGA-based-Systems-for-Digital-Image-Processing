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

entity Control_Block3 is
  port (
    i_CLK                 : in  std_logic;
    i_RST                 : in  std_logic;
    i_PIX_RDY_SUB         : in  std_logic;
    i_DONE_MO2            : in  std_logic;
    i_DONE_MC             : in  std_logic;
    o_VALID_MO2           : out std_logic;
    o_VALID_MC            : out std_logic;
    o_DONE                : out std_logic
  );
end Control_Block3;

architecture arch of Control_Block3 is
  type state_type is (
    s_IDLE,
    s_MO2,
    s_MC,
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

  p_next_state : process (r_state_reg, i_PIX_RDY_SUB, i_DONE_MO2, i_DONE_MC)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_PIX_RDY_SUB = '1') then
          r_next_state <= s_MO2;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_MO2 =>
        if (i_DONE_MO2 = '1') then
            r_next_state <= s_MC;
        else
            r_next_state <= s_MO2;
        end if;

      when s_MC =>
        if(i_DONE_MC = '1') then
          r_next_state <= s_END;
        else
          r_next_state <= s_MC;
        end if;

      when s_END =>
          r_next_state <= s_END;

    end case;
  end process;

  o_VALID_MO2 <= '1' when r_state_reg = s_MO2 else '0';
  o_VALID_MC  <= '1' when r_state_reg = s_MC  else '0';
  o_DONE      <= '1' when r_state_reg = s_END else '0';

end arch;
