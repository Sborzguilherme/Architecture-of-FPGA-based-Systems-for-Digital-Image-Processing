library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_ACC is
end entity;

architecture arch of tb_ACC is
    constant period     : time      := 10 ps;
    signal   rst        : std_logic := '1';
    signal   clk        : std_logic := '0';
    file     fil_in     : text;
    file     fil_out    : text;

    signal pix_in   : std_logic_vector(7 downto 0) := x"00";
    signal pix_out  : std_logic_vector(31 downto 0);
    signal done : std_logic :=  '0';

begin
    clk   <= not clk after period/2;
    rst   <= '0' after period*2;
    
  change_value_pix_in : process
    variable v_pix : std_logic_vector(7 downto 0) := x"00";
  begin
    wait for 50 ps;
    pix_in <= v_pix;
    v_pix := v_pix + x"01";
  end process;

  ACC_i : ACC
  generic map (
    c_WIDTH_INPUT_DATA  => 8,
    c_WIDTH_OUTPUT_DATA => 32
  )
  port map (
    i_CLK  => clk,
    i_RST  => rst,
    i_ENA  => '1',
    i_CLR  => '0',
    i_DATA => pix_in,
    o_Q    => pix_out
  );

end architecture;
