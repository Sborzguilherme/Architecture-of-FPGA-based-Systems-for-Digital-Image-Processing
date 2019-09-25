library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ARM_Communication_package.all;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity tb_Wrapper_Gaussian is
end entity;

architecture arch of tb_Wrapper_Gaussian is

  constant period : time := 10 ps;

  file fil_in     : text;
  file fil_out    : text;

  signal clock        : std_logic := '0';
  signal reset        : std_logic := '1';
  signal start        : std_logic := '1';
  signal valid_input  : std_logic := '0';
  signal ack_input    : std_logic;
  signal ack_output   : std_logic := '0';
  signal pix_in       : fixed;
  signal pix_out      : fixed;
  signal valid_output : std_logic;
  signal done         : std_logic;

begin

  clock <= not clock after period/2;
  reset <= '0' after period;
  --start <= '0' after period*2;

  u_READ: process

  variable v_line : line;
  variable v_data : fixed;

  begin
  wait for 3*period/2;
  file_open(fil_in, "../../../Data/Input_Data/TXT/VB_2/16_bits/lena_3_8.8.txt", READ_MODE);
  while not endfile(fil_in) loop
    readline(fil_in, v_LINE);
    read(v_LINE, v_data);
    valid_input <='1';
    pix_in <= v_data;
    wait until ack_input = '1';
    valid_input <= '0';
    wait until ack_input = '0';
  end loop;
  valid_input <= '1';
  wait;
  end process;

  u_WRITE : process
    variable v_line : line;
  begin
    wait for 3*period/2;
    file_open(fil_out, "../../../Data/Output_Data/VB_2/16_bits/lena_3_Communication.txt", WRITE_MODE);
    while done = '0' loop
      ack_output <= '0';
      wait until valid_output = '1';
      wait for period/5;
      write(v_line, pix_out);
      writeline(fil_out, v_line);
      ack_output <= '1';
      wait until valid_output = '0';
    end loop;
    wait;
  end process;

-- component instatiation
Wrapper_Gaussian_i : Wrapper_Gaussian
generic map (
  p_KERNEL_HEIGHT    => 3,
  p_KERNEL_WIDTH     => 3,
  p_INPUT_IMG_WIDTH  => 514,
  p_INPUT_IMG_HEIGHT => 514
)
port map (
  i_CLK   => clock,
  i_RST   => reset,
  i_START => start,
  i_DATA  => pix_in,
  i_VALID => valid_input,
  i_ACK   => ack_output,
  o_ACK   => ack_input,
  o_VALID => valid_output,
  o_DONE  => done,
  o_DATA  => pix_out
);

end architecture;
