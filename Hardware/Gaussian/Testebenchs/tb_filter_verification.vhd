library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;


entity tb_filter_verification is
end entity;

architecture arch of tb_filter_verification is
    constant period : time := 10 ps;
    signal cycles   : integer := 0;
    signal rst      : std_logic := '1';
    signal clk      : std_logic := '0';
    file fil_in     : text;
    file fil_out    : text;

    signal start    : std_logic := '1';
    signal pix_rdy  : std_logic := '0';
    signal done     : std_logic := '0';

    signal pix_in   : fixed;
    signal pix_out  : fixed;

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

  p_INPUT : process
    variable count : fixed := "000000000000000000";
  begin
    wait for period;
    while done = '0' loop
      pix_in <= count;
      count := count + "000000000000000001";
      wait for period;

    end loop;
    wait;
  end process;

-- IMG = 512 + (KERNEL-1)

Top_Gaussian_i : Top_Gaussian
generic map (
  p_KERNEL_HEIGHT    => 5,    -- Virtual Board  = 1 Col at Start + 1 Col at End
  p_KERNEL_WIDTH     => 5,    --                  1 Lin at Start + 1 Lin at End
  p_INPUT_IMG_WIDTH  => 10,  -- img [512x512] with virtual board
  p_INPUT_IMG_HEIGHT => 10
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_VALID_PIXEL => '1',
  i_INPUT_PIXEL => pix_in,
  o_PIX_RDY     => pix_rdy,
  o_DONE        => done,
  o_OUT_PIXEL   => pix_out
);

end architecture;
