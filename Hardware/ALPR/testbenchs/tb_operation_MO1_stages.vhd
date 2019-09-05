library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_operation_MO1_stages is
end entity;

architecture arch of tb_operation_MO1_stages is

    constant c_KERNEL_SIZE_MO1 : integer := c_KERNEL_HEIGHT_MO1 * c_KERNEL_WIDTH_MO1;
    constant period : time := 20 ps;
    signal rst      : std_logic := '1';
    signal clk      : std_logic := '0';
    signal dout_ero : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
    signal dout_dil : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
    signal kernel : t_KERNEL(0 to c_KERNEL_SIZE_MO1-1) :=
    (x"F1", x"F1", x"F2", x"F3", x"04", x"05", x"06", x"07", x"08", x"09", x"10", x"11",
     x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"20", x"21", x"22", x"23",
     x"24", x"25", x"26", x"27", x"28", x"29", x"30", x"31", x"32", x"33", x"34", x"35",
     x"36", x"37", x"38", x"39", x"40", x"05", x"06", x"07", x"08", x"09", x"10", x"11",
     x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"20", x"21", x"22", x"23",
     x"24", x"25", x"26", x"27", x"28", x"29", x"30", x"31", x"32", x"33", x"34", x"35",
     x"F1", x"F1", x"F2", x"F3", x"F4", x"05", x"06", x"07", x"08", x"09", x"10", x"11",
     x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"20", x"21", x"22", x"23",
     x"24", x"25", x"26", x"27", x"28", x"29", x"30", x"31", x"32", x"33", x"34", x"35",
     x"36", x"37", x"38", x"39", x"40", x"05", x"06", x"07", x"08", x"09", x"10", x"11",
     x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"20", x"21", x"22", x"23",
     x"24", x"25", x"26", x"27", x"28", x"29", x"30", x"31", x"32", x"33", x"34", x"35",
     x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"20", x"21", x"22", x"23",
     x"24", x"25", x"26", x"27", x"28", x"29", x"30", x"31", x"32", x"33", x"34", x"35",
     x"33", x"34", x"35");

    begin

        kernel(54) <= x"03" after 150 ps;
        kernel(55) <= x"F5" after 150 ps;
        kernel(169) <= x"02" after 170 ps;
        kernel(170) <= x"F6" after 170 ps;

        clk   <= not clk after period/2;
        rst   <= '0' after period;

    operation_MO1_1 : entity work.operation_MO1(erode)
    generic map (
        c_WIDTH       => c_WIDTH_DATA_MO1,
        c_KERNEL_SIZE => c_KERNEL_SIZE_MO1
    )
    port map (
        i_CLK   => clk,
        i_RST   => rst,
        i_VALID_PIXEL => '1',
        i_INPUT => kernel,
        o_DOUT  => dout_ero
    );

    operation_MO1_2 : entity work.operation_MO1(dilate)
    generic map (
        c_WIDTH       => c_WIDTH_DATA_MO1,
        c_KERNEL_SIZE => c_KERNEL_SIZE_MO1
    )
    port map (
        i_CLK   => clk,
        i_RST   => rst,
        i_VALID_PIXEL => '1',
        i_INPUT => kernel,
        o_DOUT  => dout_dil
    );

end architecture;
