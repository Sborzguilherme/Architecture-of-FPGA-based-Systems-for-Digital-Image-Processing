library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.ARM_Communication_package.all;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity tb_Wrapper_No_F is
end entity;

architecture arch of tb_Wrapper_No_F is

  constant period : time := 10 ps;

  file fil_in     : text;
  file fil_out    : text;

  signal clock        : std_logic := '0';
  signal reset        : std_logic := '1';
  signal start        : std_logic := '1';
  signal valid_input  : std_logic := '0';
  signal ack_input    : std_logic;
  signal ack_output   : std_logic := '0'; -- Used only for reading data from the coprocessor
  signal pix_in       : fixed;
  signal pix_out      : fixed;
  signal cur_out      : fixed;
  signal valid_output : std_logic;
  signal done         : std_logic;

begin

  clock <= not clock after period/2;
  reset <= '0' after period;
  --start <= '0' after period*2;

  p_SEND_DATA: process
      variable v_pix : fixed := x"0001";
  begin
      wait for 3*period/2;
      while done = '0' loop
        valid_input <= '1';           -- Assert valid in 1
        pix_in <= v_pix;              -- Send data
        v_pix := v_pix + x"0001";
        wait until ack_input = '1';
        valid_input <= '0';
        wait until ack_input = '0';
      end loop;
  end process;

  p_RECEIVE_DATA : process
  begin
    ack_output <= '0';
    wait until valid_output = '1';
    cur_out <= pix_out;
    ack_output <= '1';
    wait until valid_output = '0';
  end process;

-- component instatiation
Wrapper_Gaussian_i : Wrapper_Gaussian
generic map (
  p_KERNEL_HEIGHT    => 3,
  p_KERNEL_WIDTH     => 3,
  p_INPUT_IMG_WIDTH  => 15,
  p_INPUT_IMG_HEIGHT => 15
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
