-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 06/02/2019
-- File: Max_Min_19.vhd

-- Finds maximum or minimum (depending on the architecture) value in a array
-- Input array with 19 values (Kernel width)
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Max_Min_19 is
    generic(
        c_WIDTH     : integer
    );
    port(
        i_INPUT : in t_KERNEL(0 to 18);
        o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
    );
end Max_Min_19;

architecture max of Max_Min_19 is

    signal w_OUT_STG_0 : t_KERNEL(0 to 5);
    signal w_OUT_STG_1 : t_KERNEL(0 to 1);
    signal w_IN_STG_2  : t_KERNEL(0 to 2);

    begin
        -- (0 to 17) 18 -> Inputs / 6 outputs
        g_MAX_LINE_VALUE_STG_0 : for i in 0 to 5 generate
            Max_Min_3_s0_i : entity work.Max_Min_3(max)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => i_INPUT(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_0(i)
                );
        end generate;
        g_MAX_LINE_VALUE_STG_1 : for i in 0 to 1 generate
            Max_Min_3_s1_i : entity work.Max_Min_3(max)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => w_OUT_STG_0(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_1(i)
                );
        end generate;

        w_IN_STG_2(0 to 1) <= w_OUT_STG_1;
        w_IN_STG_2(2) <= i_INPUT(18);

        Max_Min_3_s2_i : entity work.Max_Min_3(max)
            generic map (
                c_WIDTH => c_WIDTH
            )
            port map (
                i_INPUT => w_IN_STG_2,
                o_DOUT  => o_DOUT
            );

end architecture max;

architecture min of Max_Min_19 is

    signal w_OUT_STG_0 : t_KERNEL(0 to 5);
    signal w_OUT_STG_1 : t_KERNEL(0 to 1);
    signal w_IN_STG_2  : t_KERNEL(0 to 2);

    begin
        -- (0 to 17) 18 -> Inputs / 6 outputs
        g_MAX_LINE_VALUE_STG_0 : for i in 0 to 5 generate
            Max_Min_3_s0_i : entity work.Max_Min_3(min)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => i_INPUT(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_0(i)
                );
        end generate;
        g_MAX_LINE_VALUE_STG_1 : for i in 0 to 1 generate
            Max_Min_3_s1_i : entity work.Max_Min_3(min)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => w_OUT_STG_0(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_1(i)
                );
        end generate;

        w_IN_STG_2(0 to 1) <= w_OUT_STG_1;
        w_IN_STG_2(2) <= i_INPUT(18);

        Max_Min_3_s2_i : entity work.Max_Min_3(min)
            generic map (
                c_WIDTH => c_WIDTH
            )
            port map (
                i_INPUT => w_IN_STG_2,
                o_DOUT  => o_DOUT
            );

end architecture min;
