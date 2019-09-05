library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_small_img_MO1 is
end entity;

architecture arch of tb_small_img_MO1 is
    constant period     : time      := 10 ps;
    signal   cycles     : integer   :=  0;
    signal   rst        : std_logic := '1';
    signal   clk        : std_logic := '0';
    file     fil_in     : text;
    file     fil_out    : text;

    signal start    : std_logic := '1';
    signal pix_rdy  : std_logic := '1';
    signal done     : std_logic := '1';

    signal pix_in   : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
    signal pix_out  : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);

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

p_WRITE : process
  variable v_line : line;
begin
  wait for period;
  file_open(fil_out, "../../Data/B_test_MO1_out.txt", WRITE_MODE);
  while done = '0' loop
    if pix_rdy = '1' then
        write(v_line, pix_out);
        writeline(fil_out, v_line);
   end if;
   wait for period;
  end loop;

  wait;
end process;

-- Top_MO1_i : Top_MO1
-- generic map (
--   c_WIDTH_DATA       => 8,
--   c_KERNEL_HEIGHT    => 3,
--   c_KERNEL_WIDTH     => 3,
--   c_KERNEL_SIZE      => 9,
--   c_ROW_BUF_SIZE_ERO => 3,
--   c_ROW_BUF_SIZE_DIL => 1,
--   c_ADDR_RAM_SIZE    => c_ADDR_RAM_SIZE_MO1
-- )
-- port map (
--   i_CLK         => clk,
--   i_RST         => rst,
--   i_START       => start,
--   i_INPUT_PIXEL => pix_in,
--   o_PIX_RDY     => pix_rdy,
--   o_DONE        => done,
--   o_OUT_PIXEL   => pix_out
-- );

-- EROSION : Top_Operation
-- generic map (
--   c_WIDTH_DATA       => 8,
--   c_KERNEL_HEIGHT    => 3,
--   c_KERNEL_WIDTH     => 3,
--   c_INPUT_IMG_WIDTH  => 9,
--   c_INPUT_IMG_HEIGHT => 6,
--   s_SEL_OPERATION    => 0
-- )
-- port map (
--   i_CLK         => clk,
--   i_RST         => rst,
--   i_START       => start,
--   i_VALID_PIXEL => '1',
--   i_INPUT_PIXEL => pix_in,
--   o_PIX_RDY     => pix_rdy,
--   o_DONE        => done,
--   o_OUT_PIXEL   => pix_out
-- );

Top_Operation_MO1_i : Top_MO1_Pipeline
generic map (
  c_WIDTH_DATA       => 8,
  c_KERNEL_HEIGHT    => 3,
  c_KERNEL_WIDTH     => 3,
  c_INPUT_IMG_WIDTH  => 9,
  c_INPUT_IMG_HEIGHT => 6
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_INPUT_PIXEL => pix_in,
  o_PIX_RDY     => pix_rdy,
  o_DONE        => done,
  o_OUT_PIXEL   => pix_out
);


end architecture;
