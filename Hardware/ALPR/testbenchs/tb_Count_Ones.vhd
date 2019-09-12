library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_Count_Ones is
end entity;

architecture arch of tb_Count_Ones is

signal data : std_logic_vector(7 downto 0) := x"A1";
signal count : std_logic_vector(15 downto 0);

begin

  Count_Ones_i : Count_Ones
  generic map (
    p_DATA_SIZE => 8
  )
  port map (
    i_DATA  => data,
    o_COUNT => count
  );

end architecture;
