-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    12/03/2019
-- File:    Control_System_ALPR.vhd

-- FSM that controls the Datapath_System_ALPR

-- States:
-- s_IDLE: Start state where the counters are drained
-- s_START_MO1: Starts MO1 operation(Erosion), and filling RAM gray with values
-- s_VALID_MO1: MO1 generates valid pixels in the output That values are stored into the RAM SUB, after subtraction with the RAM Gray values.
-- s_OTSU: Starts to look for the optimized threshold in the image stored in the RAM sub memory
-- s_MO2: After Otsu find the optimized value, the MO2 operation is aplied in the generated binary image
-- s_MC: MC operation applied over the MO2 output
-- s_END: Indicate that the all operations have finished
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Control_Block1 is
  port (
    i_CLK                 : in  std_logic;
    i_RST                 : in  std_logic;
    i_START               : in  std_logic;
    i_PIX_RDY_MO1         : in  std_logic;
    i_DONE_MO1            : in  std_logic;
    o_ENA_CNT_R_ADDR_GRAY : out std_logic;
    o_CLR_CNT_R_ADDR_GRAY : out std_logic;
    o_ENA_CNT_W_ADDR_GRAY : out std_logic;
    o_CLR_CNT_W_ADDR_GRAY : out std_logic;
    o_DONE                : out std_logic
  );
end Control_Block1;

architecture arch of Control_Block1 is
  type state_type is (
    s_IDLE,
    s_START_MO1,
    s_VALID_MO1,
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

  p_next_state : process (r_state_reg, i_START, i_PIX_RDY_MO1, i_DONE_MO1)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_START_MO1;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_START_MO1 =>
        if (i_PIX_RDY_MO1 = '1') then
            r_next_state <= s_VALID_MO1;
        else
            r_next_state <= s_START_MO1;
        end if;

      when s_VALID_MO1 =>
        if (i_DONE_MO1 = '1') then
            r_next_state <= s_END;
        else
            r_next_state <= s_VALID_MO1;
        end if;

      when s_END =>
          r_next_state <= s_END;

    end case;
  end process;


  o_ENA_CNT_R_ADDR_GRAY   <= '1' when r_state_reg = s_VALID_MO1     else '0';

  o_CLR_CNT_R_ADDR_GRAY   <= '1' when r_state_reg = s_IDLE          else '0';

  o_ENA_CNT_W_ADDR_GRAY   <= '1' when r_state_reg = s_START_MO1 or
                                      r_state_reg = s_VALID_MO1     else '0';

  o_CLR_CNT_W_ADDR_GRAY   <= '1' when r_state_reg = s_IDLE          else '0';

  o_DONE                  <= '1' when r_state_reg = s_END           else '0';

end arch;
