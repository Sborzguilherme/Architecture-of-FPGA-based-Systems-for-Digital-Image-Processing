-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 06/02/2019
-- File: Max_Min_3.vhd

-- Finds maximum or minimum (depending on the architecture) value in a array
-- Input array with 3 values
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Max_Min_3 is
    generic(
        c_WIDTH     : integer
    );
    port(
        i_INPUT : in t_KERNEL(0 to 2);
        o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
    );
end Max_Min_3;

architecture max of Max_Min_3 is

    signal w_MAX_AUX : std_logic_vector(c_WIDTH-1 downto 0) := (others=>'0');

    begin
        w_MAX_AUX <= i_INPUT(0) when (i_INPUT(0) > i_INPUT(1)) else i_INPUT(1);
        o_DOUT <= w_MAX_AUX when (w_MAX_AUX > i_INPUT(2)) else i_INPUT(2);

end architecture max;

architecture min of Max_Min_3 is

    signal w_MIN_AUX : std_logic_vector(c_WIDTH-1 downto 0) := (others=>'1');

    begin
        w_MIN_AUX <= i_INPUT(0) when (i_INPUT(0) < i_INPUT(1)) else i_INPUT(1);
        o_DOUT <= w_MIN_AUX when (w_MIN_AUX < i_INPUT(2)) else i_INPUT(2);

end architecture min;
