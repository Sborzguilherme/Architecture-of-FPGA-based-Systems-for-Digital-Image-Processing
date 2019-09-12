----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    09/09/2018
-- File:    Hamming_Similarity.vhd

-- Find how different is the mask from the current window being verified
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Hamming_Similarity is
generic (
	  p_MASK_SIZE : integer
);
port (
  i_CLK : std_logic;
  i_WINDOW  : in std_logic_vector(p_MASK_SIZE-1 downto 0);
  o_COUNT   : out std_logic_vector(15 downto 0) -- Size defined to allow count of ones up to 65536
);
end Hamming_Similarity;

architecture arch of Hamming_Similarity is

  signal w_RES : std_logic_vector(p_MASK_SIZE-1 downto 0);
	--signal w_TEST : std_logic_vector(p_MASK_SIZE-1 downto 0) := "01101110";

begin
  -- Vector w_RES receives 1 for each bit with the same value in the mask and the window
  w_RES <= i_WINDOW xnor c_TEMPLATE_MASK;

  Count_Ones_i : Count_Ones
  generic map (
    p_DATA_SIZE => p_MASK_SIZE
  )
  port map (
		i_CLK => i_CLK,
    i_DATA  => w_RES,
    o_COUNT => o_COUNT
  );
end architecture;
