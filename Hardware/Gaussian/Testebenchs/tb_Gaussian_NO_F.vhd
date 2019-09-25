library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity tb_Gaussian_NO_F is
end entity;

architecture arch of tb_Gaussian_NO_F is
    constant period : time := 10 ps;
    signal cycles   : integer := 0;
    signal rst      : std_logic := '1';
    signal clk      : std_logic := '0';
    file fil_in     : text;
    file fil_out    : text;

    signal start    : std_logic := '1';
    signal pix_rdy  : std_logic := '0';
    signal done     : std_logic := '0';
    signal valid    : std_logic := '1';
    signal pix_in   : fixed;
    signal pix_out  : fixed;

begin
    clk   <= not clk after period/2;
    rst   <= '0' after period;
    start <= '0' after period*2;
    valid <= not valid after 1.2*period;
    --valid <='1';
p_CNT_CYCLES: process
    variable v_cycles : integer := 0;
    variable v_pix    : fixed := x"0001";
    begin
        wait for 3*period/2;
        while done = '0' loop
            cycles <= v_cycles;
            v_cycles := v_cycles + 1;

            pix_in <= v_pix;
            v_pix := v_pix + x"0001";

            wait until valid = '1';
        end loop;
end process;

-- p_READ : process
--     variable v_line : line;
--     variable v_data : fixed;
--
--     begin
--     wait for period*2;
--     file_open(fil_in, "../../../Data/Input_Data/TXT/VB_2/16_bits/lena_3_8.8.txt", READ_MODE);
--     while not endfile(fil_in) loop
--       wait until valid = '1' and falling_edge(clk);
--       readline(fil_in, v_LINE);
--       read(v_LINE, v_data);
--         pix_in <= v_data;
--       --wait for period;
--     end loop;
--     wait;
--   end process;
--
-- p_WRITE : process
--   variable v_line : line;
-- begin
--   wait for period;
--   file_open(fil_out, "../../../Data/Output_Data/VB_2/16_bits/lena_3_Valid.txt", WRITE_MODE);
--   while done = '0' loop
--     if pix_rdy = '1' then
--         write(v_line, pix_out);
--         writeline(fil_out, v_line);
--    end if;
--    wait for period;
--   end loop;
--
--   wait;
-- end process;

-- IMG = 512 + (KERNEL-1)

Top_Gaussian_i : Top_Gaussian
generic map (
  p_KERNEL_HEIGHT    => 3,    -- Virtual Board  = 1 Col at Start + 1 Col at End
  p_KERNEL_WIDTH     => 3,    --                  1 Lin at Start + 1 Lin at End
  p_INPUT_IMG_WIDTH  => 15,  -- img [512x512] with virtual board
  p_INPUT_IMG_HEIGHT => 15
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_VALID_PIXEL => valid,
  i_INPUT_PIXEL => pix_in,
  o_PIX_RDY     => pix_rdy,
  o_DONE        => done,
  o_OUT_PIXEL   => pix_out
);

end architecture;
