-----------------------------------------------------------------
-- Project: ARM_Communication
-- Author:  Guilherme Sborz
-- Date:    20/08/2018
-- File:    Control_FIFO_Write.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Control_FIFO_Read_Output is
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_EMPTY : in  std_logic;
    i_ACK   : in  std_logic;
    o_VALID : out std_logic;
    o_R_REQ : out std_logic
  );
end Control_FIFO_Read_Output;

architecture arch of Control_FIFO_Read_Output is
  type state_type is (
    s_EMPTY,
    s_READ,
    s_WAIT_ACK
);
  signal r_state_reg  : state_type;
  signal r_next_state : state_type;

begin
  p_state_reg : process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      r_state_reg <= s_EMPTY;
  elsif (rising_edge(i_CLK)) then
    r_state_reg <= r_next_state;
  end if;
  end process;

  p_next_state : process (r_state_reg, i_EMPTY, i_ACK)
  begin
    case (r_state_reg) is
      when s_EMPTY =>
        if(i_EMPTY = '0') then
          r_next_state <= s_READ;
        else
          r_next_state <= s_EMPTY;
        end if;

      when s_READ =>
        r_next_state <= s_WAIT_ACK;

      when s_WAIT_ACK =>
        if(i_ACK = '1') then
          r_next_state <= s_EMPTY;
        else
          r_next_state <= s_WAIT_ACK;
        end if;
      end case;
  end process;

  o_R_REQ <= '1' when r_state_reg = s_READ else '0';
  o_VALID <= '1' when r_state_reg = s_WAIT_ACK else '0';

end arch;
