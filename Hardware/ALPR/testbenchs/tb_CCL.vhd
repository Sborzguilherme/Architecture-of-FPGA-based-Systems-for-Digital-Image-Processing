library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;

  -- 0.6us to simulate
entity tb_CCL is
end entity;

architecture arch of tb_CCL is
    constant period : time := 10 ps;
    signal cycles   : integer := 0;
    signal rst      : std_logic := '1';
    signal clk      : std_logic := '0';
    file fil_in     : text;
    file fil_out    : text;

    signal start    : std_logic := '1';
    signal pix_rdy  : std_logic := '0';
    signal done     : std_logic := '0';

    signal pix_in   : std_logic;
    signal coord_x : std_logic_vector(15 downto 0);
    signal coord_y : std_logic_vector(15 downto 0);

begin
    clk   <= not clk after period/2;
    rst   <= '0' after period;
    start <= '0' after period*2;

p_CNT_CYCLES: process
    variable v_cycles : integer := 0;
    begin
        wait for period*2;
        while done = '0' loop
            cycles <= v_cycles;
            v_cycles := v_cycles + 1;
            wait for period;
        end loop;
end process;

p_READ : process
    variable v_line : line;
    variable v_data : std_logic;

    begin
    wait for period*2;
    file_open(fil_in, "../../../Data/Output_Data/ALPR/MKE-6858_Result.txt", READ_MODE);
    while not endfile(fil_in) loop
      readline(fil_in, v_LINE);
      read(v_LINE, v_data);
      pix_in <= v_data;
      wait for period;
    end loop;
    wait;
  end process;

Top_CCL_i : Top_CCL
generic map (
  p_KERNEL_HEIGHT    => c_MASK_HEIGHT,
  p_KERNEL_WIDTH     => c_MASK_WIDTH,
  p_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_CCL,
  p_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_CCL
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_VALID_PIXEL => '1',
  i_INPUT_PIXEL => pix_in,
  o_DONE        => done,
  o_COORD_X     => coord_x,
  o_COORD_Y     => coord_y
);

end architecture;
