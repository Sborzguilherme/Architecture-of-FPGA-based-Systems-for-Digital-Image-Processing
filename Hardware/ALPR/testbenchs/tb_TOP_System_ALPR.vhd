library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_Top_System_ALPR is
end entity;

architecture arch of tb_Top_System_ALPR is
    constant period : time := 10 ps;
    signal cycles   : integer := 0;
    signal rst      : std_logic := '1';
    signal clk      : std_logic := '0';
    file fil_in     : text;
    file fil_out    : text;

    signal start    : std_logic := '1';
    --signal pix_rdy  : std_logic := '0';
    signal done     : std_logic := '0';
    signal valid_pixel : std_logic := '0';
    signal pix_in   : std_logic_vector(23 downto 0);
    signal coord_x : std_logic_vector(15 downto 0);
    signal coord_y : std_logic_vector(15 downto 0);
    --signal pix_out  : std_logic;

begin
    clk   <= not clk after period/2;
    rst   <= '0' after period;
    start <= '0' after period*2;
    valid_pixel <= '1' after period*2;

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
    variable v_data : std_logic_vector(23 downto 0);

    begin
    wait for period*2;
    file_open(fil_in, "../../../Data/Input_Data/TXT/ALPR/MKE-6858_RGB.txt", READ_MODE);
    while not endfile(fil_in) loop
      readline(fil_in, v_LINE);
      read(v_LINE, v_data);
      pix_in <= v_data;
      wait for period;
    end loop;
    wait;
  end process;

-- p_WRITE : process
--   variable v_line : line;
-- begin
--   wait for period;
--   file_open(fil_out, "../../../Data/Output_Data/ALPR/MKE-6858_Result.txt", WRITE_MODE);
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

-- Top_System_ALPR_i : Top_System_ALPR
-- generic map (
--   c_WIDTH_INPUT_PIXEL => 24,
--   c_WIDTH_GRAY_PIXEL  => 8,
--   c_KERNEL_HEIGHT_MO1 => c_KERNEL_HEIGHT_MO1,
--   c_KERNEL_WIDTH_MO1  => c_KERNEL_WIDTH_MO1,
--   c_KERNEL_HEIGHT_MO2 => c_KERNEL_HEIGHT_MO2,
--   c_KERNEL_WIDTH_MO2  => c_KERNEL_WIDTH_MO2,
--   c_KERNEL_HEIGHT_MC  => c_KERNEL_HEIGHT_MC,
--   c_KERNEL_WIDTH_MC   => c_KERNEL_WIDTH_MC,
--   c_INPUT_IMG_HEIGHT  => c_INPUT_IMG_HEIGHT_MO1,
--   c_INPUT_IMG_WIDTH   => c_INPUT_IMG_WIDTH_MO1,
--   c_SIZE_MEM_OTSU     => 256
-- )
-- port map (
--   i_CLK         => clk,
--   i_RST         => rst,
--   i_START       => start,
--   i_VALID_PIXEL => valid_pixel,
--   i_INPUT_PIXEL => pix_in,
--   o_PIX_RDY     => pix_rdy,
--   o_DONE        => done,
--   o_OUT_PIXEL   => pix_out
-- );

Top_System_ALPR_i : Top_System_ALPR
generic map (
  c_WIDTH_INPUT_PIXEL => 24,
  c_WIDTH_GRAY_PIXEL  => 8,
  c_KERNEL_HEIGHT_MO1 => c_KERNEL_HEIGHT_MO1,
  c_KERNEL_WIDTH_MO1  => c_KERNEL_WIDTH_MO1,
  c_KERNEL_HEIGHT_MO2 => c_KERNEL_HEIGHT_MO2,
  c_KERNEL_WIDTH_MO2  => c_KERNEL_WIDTH_MO2,
  c_KERNEL_HEIGHT_MC  => c_KERNEL_HEIGHT_MC,
  c_KERNEL_WIDTH_MC   => c_KERNEL_WIDTH_MC,
  c_INPUT_IMG_HEIGHT  => c_INPUT_IMG_HEIGHT_MO1,
  c_INPUT_IMG_WIDTH   => c_INPUT_IMG_WIDTH_MO1,
  c_SIZE_MEM_OTSU     => 256
)
port map (
  i_CLK         => clk,
  i_RST         => rst,
  i_START       => start,
  i_VALID_PIXEL => valid_pixel,
  i_INPUT_PIXEL => pix_in,
  o_DONE        => done,
  o_COORD_X     => coord_x,
  o_COORD_Y     => coord_y
);



end architecture;
