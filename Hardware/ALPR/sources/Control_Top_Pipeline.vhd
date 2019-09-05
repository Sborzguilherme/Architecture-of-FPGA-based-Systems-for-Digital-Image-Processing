-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    19/02/2018
-- File:    Control_Top_Pipeline.vhd

-- FSM that controls the Top_Pipeline Operations

-- States:
-- s_IDLE: Start state where the counters are drained
-- s_1st_OP: Enables start of the firts operation (erode or dilate)
-- s_2nd_OP: State to Generate the extra cycles needed to finish the second operation
-- s_END: Indicate the end of both operations
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Control_Top_Pipeline is
  port (
    i_CLK                : in  std_logic;
    i_RST                : in  std_logic;
    i_START              : in  std_logic;
    i_DONE_1_OP          : in  std_logic;
    i_DONE_2_OP          : in  std_logic;
    o_PIX_RDY_1_OP       : out std_logic;
    o_VALID_PIXEL_1ST_OP : out std_logic;
    o_DONE               : out std_logic
  );
end Control_Top_Pipeline;

architecture arch of Control_Top_Pipeline is
  type state_type is (
    s_IDLE,
    s_1st_OP,
    s_2nd_OP,
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

  p_next_state : process (r_state_reg, i_START, i_DONE_1_OP, i_DONE_2_OP)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_1st_OP;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_1st_OP =>
        if (i_DONE_1_OP = '1') then
            r_next_state <= s_2nd_OP;
        else
            r_next_state <= s_1st_OP;
        end if;

      when s_2nd_OP =>
        if(i_DONE_2_OP = '1') then
          r_next_state <= s_END;
        else
          r_next_state <= s_2nd_OP;
        end if;

      when s_END =>
        r_next_state <= s_END;

    end case;
  end process;

o_PIX_RDY_1_OP       <= '1' when r_state_reg = s_2nd_OP else '0';

o_VALID_PIXEL_1ST_OP <= '1' when r_state_reg = s_1st_OP else '0';

o_DONE               <= '1' when r_state_reg = s_END    else '0';

end arch;
