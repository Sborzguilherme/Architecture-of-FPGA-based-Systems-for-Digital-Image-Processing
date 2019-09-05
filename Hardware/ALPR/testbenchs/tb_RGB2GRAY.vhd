library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_RGB2GRAY is
end entity;

architecture arch of tb_RGB2GRAY is
    constant period     : time      := 10 ps;
    signal   cycles     : integer   :=  0;
    signal   rst        : std_logic := '1';
    signal   clk        : std_logic := '0';
    file     fil_in     : text;
    file     fil_out    : text;

    signal start    : std_logic := '1';
    signal pix_rdy  : std_logic := '1';
    signal done     : std_logic := '1';

    signal pix_in   : std_logic_vector(23 downto 0);
    signal pix_out  : std_logic_vector(7 downto 0);

begin

p_READ : process
    variable v_line : line;
    variable v_data : std_logic_vector(23 downto 0);

    begin
    wait for period;
    file_open(fil_in, "../../Data/MKE-6858_RGB.txt", READ_MODE);
    while not endfile(fil_in) loop
      readline(fil_in, v_LINE);
      read(v_LINE, v_data);
      pix_in <= v_data;
      wait for period*2;
    end loop;
    wait;
  end process;

p_WRITE : process
  variable v_line : line;
begin
  wait for period;
  file_open(fil_out, "../../Data/MKE-6858_GRAY_VHDL.txt", WRITE_MODE);
        write(v_line, pix_out);
        writeline(fil_out, v_line);
   wait for period;

  --wait;
end process;

RGB2GRAY_i : RGB2GRAY
generic map (
  c_WIDTH_INPUT_DATA  => 24,
  c_WIDTH_OUTPUT_DATA => 8
)
port map (
  --i_CLK         => clk,
  --i_RST         => rst,
  i_INPUT_PIXEL => pix_in,
  o_OUT_PIXEL   => pix_out
);

end architecture;
