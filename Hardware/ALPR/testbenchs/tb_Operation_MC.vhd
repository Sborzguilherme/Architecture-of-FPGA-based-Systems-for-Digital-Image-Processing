library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;               -- Needed for shifts

library work;
use work.ALPR_package.all;

entity tb_Operation_MC is
end entity;

architecture arch of tb_Operation_MC is

constant period : time := 20 ps;
signal kernel : std_logic_vector(0 to 74) :=
"000000000000000000000000000000000000000000000000000000000000000000000000000";
signal s_dilate : std_logic;
signal s_erode : std_logic;

begin

  change_value_kernel : process
    variable v_kernel : std_logic_vector(0 to 74) := "000000000000000000000000000000000000000000000000000000000000000000000000001";
  begin
    wait for 50 ps;
    kernel <= v_kernel;
    v_kernel := v_kernel(1 to 74) & '0';
  end process;


  operation_MC_1 : entity work.operation_MC(dilate)
    generic map (
      c_KERNEL_SIZE => 75
    )
    port map (
      i_INPUT => kernel,
      o_DOUT  => s_dilate
    );

    operation_MC_2 : entity work.operation_MC(erode)
      generic map (
        c_KERNEL_SIZE => 75
      )
      port map (
        i_INPUT => kernel,
        o_DOUT  => s_erode
      );


end architecture;
