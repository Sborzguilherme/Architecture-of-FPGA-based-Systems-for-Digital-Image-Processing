-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 06/02/2019
-- File: operation_MO1_stages.vhd

-- Finds maximum or minimum (depending on the architecture) value in a array
-- Input array with al values from kernel
-- COMPARER TREE

-- FIRST STAGE: 9 block comparing 19 values (find biggest value in each line)
-- SECOND STAGE: 3 block comparing 3 values each (results from stage 1)
-- THIRD STAGE: 1 block comparing 3 values from previous stage
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity operation_MO1_stages is
    generic(
        c_WIDTH         : integer;
        c_KERNEL_SIZE   : integer
    );
    port(
        i_CLK   : in std_logic;
        i_RST   : in std_logic;
        i_INPUT : in t_KERNEL(0 to c_KERNEL_SIZE-1);
        o_DOUT  : out std_logic_vector(c_WIDTH-1 downto 0)
    );
end operation_MO1_stages;

architecture dilate of operation_MO1_stages is

    signal w_OUT_STG_0  : t_KERNEL(0 to 8);
    signal r_STG_0      : t_KERNEL(0 to 8);
    signal w_OUT_STG_1  : t_KERNEL(0 to 2);
    signal r_STG_1      : t_KERNEL(0 to 2);

    begin
        g_Stage_0 : for i in 0 to 8 generate
            Max_Min_19_s0 : entity work.Max_Min_19(max)
                generic map (
                  c_WIDTH => c_WIDTH_DATA_MO1
                )
                port map (
                  i_INPUT => i_INPUT(19*i to (19*i + 18)),
                  o_DOUT  => w_OUT_STG_0(i)
                );

            Reg_s0 : Reg
                generic map (
                  c_WIDTH => c_WIDTH_DATA_MO1
                )
                port map (
                  i_CLK  => i_CLK,
                  i_RST  => i_RST,
                  i_ENA  => '1',
                  i_CLR  => i_RST,
                  i_DIN  => w_OUT_STG_0(i),
                  o_DOUT => r_STG_0(i)
                );

        end generate;

        g_Stage_1 : for i in 0 to 2 generate
            Max_Min_19_s1 : entity work.Max_Min_3(max)
                generic map (
                  c_WIDTH => c_WIDTH_DATA_MO1
                )
                port map (
                  i_INPUT => r_STG_0(3*i to (3*i + 2)),
                  o_DOUT  => w_OUT_STG_1(i)
                );

            Reg_s1 : Reg
                generic map (
                  c_WIDTH => c_WIDTH_DATA_MO1
                )
                port map (
                  i_CLK  => i_CLK,
                  i_RST  => i_RST,
                  i_ENA  => '1',
                  i_CLR  => i_RST,
                  i_DIN  => w_OUT_STG_1(i),
                  o_DOUT => r_STG_1(i)
                );

        end generate;

        Max_Min_19_s2 : entity work.Max_Min_3(max)
            generic map (
              c_WIDTH => c_WIDTH_DATA_MO1
            )
            port map (
              i_INPUT => r_STG_1,
              o_DOUT  => o_DOUT
            );
    end dilate;

    architecture erode of operation_MO1_stages is

        signal w_OUT_STG_0  : t_KERNEL(0 to 8);
        signal r_STG_0      : t_KERNEL(0 to 8);
        signal w_OUT_STG_1  : t_KERNEL(0 to 2);
        signal r_STG_1      : t_KERNEL(0 to 2);

        begin
            g_Stage_0 : for i in 0 to 8 generate
                Max_Min_19_s0 : entity work.Max_Min_19(min)
                    generic map (
                      c_WIDTH => c_WIDTH_DATA_MO1
                    )
                    port map (
                      i_INPUT => i_INPUT(19*i to (19*i + 18)),
                      o_DOUT  => w_OUT_STG_0(i)
                    );

                Reg_s0 : Reg
                    generic map (
                      c_WIDTH => c_WIDTH_DATA_MO1
                    )
                    port map (
                      i_CLK  => i_CLK,
                      i_RST  => i_RST,
                      i_ENA  => '1',
                      i_CLR  => i_RST,
                      i_DIN  => w_OUT_STG_0(i),
                      o_DOUT => r_STG_0(i)
                    );


            end generate;

            g_Stage_1 : for i in 0 to 2 generate
                Max_Min_19_s1 : entity work.Max_Min_3(min)
                    generic map (
                      c_WIDTH => c_WIDTH_DATA_MO1
                    )
                    port map (
                      i_INPUT => r_STG_0(3*i to (3*i + 2)),
                      o_DOUT  => w_OUT_STG_1(i)
                    );

                Reg_s1 : Reg
                    generic map (
                      c_WIDTH => c_WIDTH_DATA_MO1
                    )
                    port map (
                      i_CLK  => i_CLK,
                      i_RST  => i_RST,
                      i_ENA  => '1',
                      i_CLR  => i_RST,
                      i_DIN  => w_OUT_STG_1(i),
                      o_DOUT => r_STG_1(i)
                    );

            end generate;

            Max_Min_19_s2 : entity work.Max_Min_3(min)
                generic map (
                  c_WIDTH => c_WIDTH_DATA_MO1
                )
                port map (
                  i_INPUT => r_STG_1,
                  o_DOUT  => o_DOUT
                );
        end erode;
