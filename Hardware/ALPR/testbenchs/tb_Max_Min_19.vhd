library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_Max_Min_19 is
end entity;

architecture arch of tb_Max_Min_19 is

constant period : time := 20 ps;
signal dout_ero : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal dout_dil : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal kernel : t_KERNEL(0 to 18) := (x"F0", x"01", x"02", x"03", x"04", x"05",
                                      x"06", x"07", x"08", x"09", x"10", x"11",
                                      x"12", x"13", x"14", x"15", x"16", x"17", x"18");

begin

    kernel(15) <= x"00" after 215 ps;
    kernel(18) <= x"F4" after 215 ps;


    Max_Min_19_d : entity work.Max_Min_19(max)
    generic map (
      c_WIDTH => c_WIDTH_DATA_MO1
    )
    port map (
      i_INPUT => kernel,
      o_DOUT  => dout_dil
    );

    Max_Min_19_e : entity work.Max_Min_19(min)
    generic map (
      c_WIDTH => c_WIDTH_DATA_MO1
    )
    port map (
      i_INPUT => kernel,
      o_DOUT  => dout_ero
    );

end architecture;
