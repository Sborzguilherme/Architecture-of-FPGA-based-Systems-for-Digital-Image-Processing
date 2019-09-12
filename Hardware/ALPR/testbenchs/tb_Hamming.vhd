library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_Hamming is
end entity;

architecture arch of tb_Hamming is

signal data : std_logic_vector(7 downto 0) := x"A1";
signal count : std_logic_vector(15 downto 0);

begin

  Hamming_Similarity_i : Hamming_Similarity
  generic map (
    p_MASK_SIZE => 8
  )
  port map (
    i_WINDOW => data,
    o_COUNT  => count
  );

end architecture;
