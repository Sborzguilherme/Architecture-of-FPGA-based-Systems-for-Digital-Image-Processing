-----------------------------------------------------------------
-- Project: ARM_Communication
-- Author:  Guilherme Sborz
-- Date:    20/08/2018
-- File:    Control_FIFO_Write.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Control_FIFO_Write_Input is
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_VALID : in  std_logic;
    o_W_REQ : out std_logic;
    o_ACK   : out std_logic
  );
end Control_FIFO_Write_Input;

architecture arch of Control_FIFO_Write_Input is
  type state_type is (
    s_WAIT,
    s_SAVE_VALUE,
    s_ACK
);
  signal r_state_reg  : state_type;
  signal r_next_state : state_type;

begin
  p_state_reg : process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      r_state_reg <= s_WAIT;
  elsif (rising_edge(i_CLK)) then
    r_state_reg <= r_next_state;
  end if;
  end process;

  p_next_state : process (r_state_reg, i_VALID)
  begin
    case (r_state_reg) is
      when s_WAIT =>
        if(i_VALID = '1') then
          r_next_state <= s_SAVE_VALUE;
        else
          r_next_state <= s_WAIT;
        end if;

      when s_SAVE_VALUE =>
        r_next_state <= s_ACK;

      when s_ACK =>
          r_next_state <= s_WAIT;
      end case;
  end process;

  o_W_REQ <= '1' when r_state_reg = s_SAVE_VALUE else '0';
  o_ACK   <= '1' when r_state_reg = s_ACK        else '0';

end arch;
