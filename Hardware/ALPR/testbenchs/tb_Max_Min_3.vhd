library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_Max_Min_3 is
end entity;

architecture arch of tb_Max_Min_3 is

constant period : time := 20 ps;
signal dout_ero : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal dout_dil : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal kernel : t_KERNEL(0 to 2) := (x"02", x"05", x"F2");

begin

    kernel(0) <= x"FF" after 215 ps;    -- biggest value possible (considering unsigned values)
    kernel(1) <= x"7F" after 215 ps;    -- biggest value possible (considering signed values)

    Max_Min_3_d : entity work.Max_Min_3(max)
    generic map (
        c_WIDTH => c_WIDTH_DATA_MO1
    )
    port map (
        i_INPUT => kernel,
        o_DOUT  => dout_dil
    );

    Max_Min_3_e : entity work.Max_Min_3(min)
    generic map (
        c_WIDTH => c_WIDTH_DATA_MO1
    )
    port map (
        i_INPUT => kernel,
        o_DOUT  => dout_ero
    );


end architecture;
