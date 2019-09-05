library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_operation_MO1 is
end entity;

architecture arch of tb_operation_MO1 is

constant period : time := 20 ps;
signal dout_ero : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal dout_dil : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
signal kernel : t_KERNEL(0 to 9) := (x"F0", x"05", x"F2", x"08", x"66",
                                     x"00", x"02", x"FF", x"D5", x"C6");

begin
    
    kernel(5) <= x"1F" after 215 ps;
    kernel(7) <= x"D4" after 215 ps;

    operation_MO1_0 : entity work.operation_MO1(erode)
    generic map (
      c_WIDTH       => c_WIDTH_DATA_MO1,
      c_KERNEL_SIZE => 10
    )
    port map (
      i_W    => kernel,
      o_DOUT => dout_ero
    );

    operation_MO1_1 : entity work.operation_MO1(dilate)
    generic map (
      c_WIDTH       => c_WIDTH_DATA_MO1,
      c_KERNEL_SIZE => 10
    )
    port map (
      i_W    => kernel,
      o_DOUT => dout_dil
    );



end architecture;
