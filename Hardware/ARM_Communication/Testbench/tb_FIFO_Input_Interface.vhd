library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ARM_Communication_Package.all;

entity tb_FIFO_Input_Interface is
end entity;

architecture arch of tb_FIFO_Input_Interface is

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
  signal ack_output           : std_logic;
  signal current_input_data   : std_logic_vector(7 downto 0);
  signal current_output_data  : std_logic_vector(7 downto 0);
  signal index_input          : integer := 0;
  signal valid_output         : std_logic;

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
      wait until ack_output = '1';
      valid_input <= '0';
      wait until ack_output = '0';
    end if;
  end process;

-- component instatiation
FIFO_Input_Interface_i : FIFO_Input_Interface
generic map (
  p_DATA_SIZE => 8
)
port map (
  i_CLK   => clock,
  i_RST   => reset,
  i_DATA  => current_input_data,
  i_VALID => valid_input,
  o_ACK   => ack_output,
  o_VALID => valid_output,
  o_DATA  => current_output_data
);

end architecture;
