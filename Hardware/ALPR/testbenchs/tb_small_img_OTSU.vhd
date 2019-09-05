library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_small_img_OTSU is
end entity;

architecture arch of tb_small_img_OTSU is
    constant period     : time      := 10 ps;
    signal   cycles     : integer   :=  0;
    signal   rst        : std_logic := '1';
    signal   clk        : std_logic := '0';
    file     fil_in     : text;
    file     fil_out    : text;
    signal start        : std_logic := '1';

    signal pix_in   : std_logic_vector(7 downto 0);
    --signal pix_out  : std_logic_vector(31 downto 0);
    signal done : std_logic :=  '0';
    signal threshold : std_logic_vector(7 downto 0);

begin
    clk   <= not clk after period/2;
    rst   <= '0' after period;
    --start <= '0' after period*2;

  p_CNT_CYCLES: process
      variable v_cycles : integer := 0;
      begin
          wait for period;
          while done = '0' loop
              cycles <= v_cycles;
              v_cycles := v_cycles + 1;
              wait for period;
          end loop;
  end process;

p_READ : process
    variable v_line : line;
    variable v_data : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);

    begin
    wait for period*2;
    file_open(fil_in, "../../Data/B.txt", READ_MODE);
    while not endfile(fil_in) loop
      readline(fil_in, v_LINE);
      read(v_LINE, v_data);
      pix_in <= v_data;
      wait for period;
    end loop;
    wait;
  end process;

Top_OTSU_i : Top_OTSU
generic map (
  c_SIZE_MEM    => 256,
  c_WIDTH_PIXEL => 8,
  c_WIDTH_VAR   => 32
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_VALID_PIXEL => '1',
  i_PIXEL       => pix_in,
  o_DONE        => done,
  o_THRESHOLD   => threshold
);

end architecture;
