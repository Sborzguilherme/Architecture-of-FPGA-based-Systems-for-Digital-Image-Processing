library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ARM_Communication_Package.all;

entity tb_Test_Communication is
end entity;

architecture arch of tb_Test_Communication is

  constant period : time := 10 ps;
  constant input_data : t_array := (
    0 => x"05",
    1 => x"10",
    2 => x"15",
    3 => x"20",
    4 => x"25"
  );

  signal clock                : std_logic := '0';
  signal reset                : std_logic := '1';
  signal valid_input          : std_logic := '0';
  signal ack_input            : std_logic;
  signal ack_output           : std_logic := '0';
  signal current_input_data   : std_logic_vector(7 downto 0);
  signal valid_output         : std_logic;
  signal current_output_data  : std_logic_vector(7 downto 0);
  signal index_input          : integer := 0;
  signal index_output         : integer := 0;

  signal data_output          : t_array;

begin

  clock <= not clock after period/2;
  reset <= '0' after period;

  u_write: process
  begin
    if(index_input = 5 ) then
      wait;
    else
      current_input_data <= input_data(index_input);
      valid_input <= '1';
      index_input <= index_input + 1;
      wait until ack_input = '1';
      valid_input <= '0';
      wait until ack_input = '0';
    end if;
  end process;

  u_read : process
  begin
    if(index_output = 5) then
        wait;
    else
      ack_output <= '0';  -- ARM sending ctrl signal to the coprocessor (no value received yet)
      wait until valid_output = '1';
      ack_output <= '1';  -- ARM informing that the data sended from the coprocess is already saved
      wait until falling_edge(clock);
      data_output(index_output) <= current_output_data;
      index_output <= index_output + 1;
      wait until valid_output = '0';
    end if;
  end process;

-- component instatiation
Test_Communication_i : Test_Communication
generic map (
  p_DATA_SIZE => 8
)
port map (
  i_CLK   => clock,
  i_RST   => reset,
  i_DATA  => current_input_data,
  i_VALID => valid_input,
  i_ACK   => ack_output,
  o_ACK   => ack_input,
  o_VALID => valid_output,
  o_DATA  => current_output_data
);

end architecture;
