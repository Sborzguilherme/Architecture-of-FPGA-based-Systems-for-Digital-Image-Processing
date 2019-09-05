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

entity Max_Min_9 is
    generic(
        c_WIDTH     : integer
    );
    port(
        i_CLK   : in std_logic;
        i_RST   : in std_logic;
        i_VALID_PIXEL : in std_logic;
        i_INPUT : in t_KERNEL(0 to 8);
        o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
    );
end Max_Min_9;

architecture max of Max_Min_9 is

    signal w_OUT_STG_0 : t_KERNEL(0 to 2);
    signal w_OUT_STG_1 : t_KERNEL(0 to 1);
    signal r_STG_0 : t_KERNEL(0 to 2);
    signal r_STG_1 : std_logic_vector(c_WIDTH-1 downto 0);

    begin
        g_MAX_LINE_VALUE_STG_0 : for i in 0 to 2 generate
            Max_Min_3_s0_i : entity work.Max_Min_3(max)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => i_INPUT(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_0(i)
                );

            Reg_s0 : Reg
                generic map (
                  c_WIDTH => c_WIDTH
                )
                port map (
                  i_CLK  => i_CLK,
                  i_RST  => i_RST,
                  i_ENA  => i_VALID_PIXEL,
                  i_CLR  => i_RST,
                  i_DIN  => w_OUT_STG_0(i),
                  o_DOUT => r_STG_0(i)
                );


        end generate;

        Max_Min_3_s2_i : entity work.Max_Min_3(max)
            generic map (
                c_WIDTH => c_WIDTH
            )
            port map (
                i_INPUT => r_STG_0,
                o_DOUT  => r_STG_1
            );

        Reg_s1 : Reg
            generic map (
              c_WIDTH => c_WIDTH
            )
            port map (
              i_CLK  => i_CLK,
              i_RST  => i_RST,
              i_ENA  => i_VALID_PIXEL,
              i_CLR  => i_RST,
              i_DIN  => r_STG_1,
              o_DOUT => o_DOUT
            );


end architecture max;

architecture min of Max_Min_9 is

    signal w_OUT_STG_0 : t_KERNEL(0 to 2);
    signal w_OUT_STG_1 : t_KERNEL(0 to 1);
    signal r_STG_0     : t_KERNEL(0 to 2);
    signal r_STG_1 : std_logic_vector(c_WIDTH-1 downto 0);

    begin
        g_MAX_LINE_VALUE_STG_0 : for i in 0 to 2 generate
            Max_Min_3_s0_i : entity work.Max_Min_3(min)
                generic map (
                    c_WIDTH => c_WIDTH
                )
                port map (
                    i_INPUT => i_INPUT(3*i to (3*i+2)),
                    o_DOUT  => w_OUT_STG_0(i)
                );

            Reg_s0 : Reg
                generic map (
                  c_WIDTH => c_WIDTH
                )
                port map (
                  i_CLK  => i_CLK,
                  i_RST  => i_RST,
                  i_ENA  => i_VALID_PIXEL,
                  i_CLR  => i_RST,
                  i_DIN  => w_OUT_STG_0(i),
                  o_DOUT => r_STG_0(i)
                );


        end generate;

        Max_Min_3_s2_i : entity work.Max_Min_3(min)
            generic map (
                c_WIDTH => c_WIDTH
            )
            port map (
                i_INPUT => r_STG_0,
                o_DOUT  => r_STG_1
            );

        Reg_s1 : Reg
            generic map (
              c_WIDTH => c_WIDTH
            )
            port map (
              i_CLK  => i_CLK,
              i_RST  => i_RST,
              i_ENA  => i_VALID_PIXEL,
              i_CLR  => i_RST,
              i_DIN  => r_STG_1,
              o_DOUT => o_DOUT
            );

end architecture min;
