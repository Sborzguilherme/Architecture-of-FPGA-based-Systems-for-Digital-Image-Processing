-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    20/11/2018
-- File:    Mux_2_1_int.vhd

-- Multiplexer 2x1 with std_logic_vector type for the inputs/outputs
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Mux_2_1 is
generic (
	p_WIDTH : integer
);                              							-- data width
port (
	i_SEL  : in std_logic;               					-- selector
	i_DIN0 : in std_logic_vector(p_WIDTH-1 downto 0);     	-- data input
	i_DIN1 : in std_logic_vector(p_WIDTH-1 downto 0);     	-- data input
	o_DOUT : out std_logic_vector(p_WIDTH-1 downto 0));     -- data output
end Mux_2_1;

architecture arch_1 of Mux_2_1 is
begin
	o_DOUT <=    i_DIN0 when i_SEL = '0' else i_DIN1;

end arch_1;
