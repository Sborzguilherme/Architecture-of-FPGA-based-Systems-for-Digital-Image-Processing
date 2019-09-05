library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_Select_Ena_RAM_Gray is
end entity;

architecture arch of tb_Select_Ena_RAM_Gray is
  constant period : time := 10 ps;
  signal cycles   : integer := 0;
  signal rst      : std_logic := '1';
  signal clk      : std_logic := '0';
  file fil_in     : text;
  file fil_out    : text;

  signal valid_addr  : std_logic;
  signal done        : std_logic := '0';
  signal valid_pixel : std_logic := '0';

  signal pix_in   : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
  signal pix_out  : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);


begin
    clk   <= not clk after period/2;
    rst   <= '0' after period*2;
    valid_pixel <= '1' after period*3;

    p_CNT_CYCLES: process
        variable v_cycles : integer := 0;
        begin
            wait for period*2;
            while done = '0' loop
              if(valid_addr = '1') then
                cycles <= v_cycles;
                v_cycles := v_cycles + 1;
              end if;
                wait for period;
            end loop;
    end process;

    p_READ : process
        variable v_line : line;
        variable v_data : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);

        begin
        wait for period*2;
        file_open(fil_in, "../../Data/MKE-6858_GRAY.txt", READ_MODE);
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
      variable v_valid : std_logic := '0';
    begin
      wait for period;
      file_open(fil_out, "../../Data/Select_test.txt", WRITE_MODE);
      while done = '0' loop
        pix_out <= pix_in;
        --valid_pixel <= '1';
        if v_valid = '1' then
            write(v_line, pix_out);
            writeline(fil_out, v_line);
       end if;
       v_valid := valid_addr;
       wait for period;
      end loop;

      wait;
    end process;

  Datapath_Select_Ena_RAM_Gray_i :ENA_RAM_GRAY
  generic map (
    c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MO1,
    c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MO1,
    c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MO1,
    c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MO1
  )
  port map (
    i_CLK         => clk,
    i_RST         => rst,
    i_VALID_PIXEL => valid_pixel,
    o_DONE        => done,
    o_VALID_ADDR  => valid_addr
  );

end architecture;
