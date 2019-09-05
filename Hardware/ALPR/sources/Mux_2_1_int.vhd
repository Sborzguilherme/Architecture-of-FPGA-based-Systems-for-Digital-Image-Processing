-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    20/11/2018
-- File:    Mux_2_1_int.vhd

-- Multiplexer 2x1 with integer type for the inputs/outputs
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Mux_2_1_int is
port (
    i_SEL  : in  std_logic;               		-- selector
    i_DIN0 : in  integer;   -- data input
    i_DIN1 : in  integer;   -- data input
    o_DOUT : out integer    -- data output
);
end Mux_2_1_int;

architecture arch_1 of Mux_2_1_int is
begin
    o_DOUT <= i_DIN0 when i_SEL = '0' else i_DIN1;

end arch_1;
