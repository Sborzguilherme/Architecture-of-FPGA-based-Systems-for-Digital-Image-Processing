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

entity operation_MO2 is
    generic(
        c_KERNEL_SIZE   : integer
    );
    port(
        i_INPUT : in std_logic_vector(0 to c_KERNEL_SIZE-1);
        o_DOUT  : out std_logic
    );
end operation_MO2;

architecture dilate of operation_MO2 is

    signal w_OUT_STG_0  : std_logic_vector(0 to 3);
    signal w_OUT_STG_1  : std_logic_vector(0 to 1);

    begin
        g_Stage_0 : for i in 0 to 3 generate

            w_OUT_STG_0(i) <= i_INPUT(2*i) or i_INPUT(2*i + 1);

        end generate;

        g_Stage_1 : for i in 0 to 1 generate
            w_OUT_STG_1(i) <= w_OUT_STG_0(2*i) or w_OUT_STG_0(2*i+1);
        end generate;

        o_DOUT <= w_OUT_STG_1(0) or w_OUT_STG_1(1) or i_INPUT(8);

end dilate;

architecture erode of operation_MO2 is

    signal w_OUT_STG_0  : std_logic_vector(0 to 3);
    signal w_OUT_STG_1  : std_logic_vector(0 to 1);
    --signal w_AUX        : std_logic;

    begin
        g_Stage_0 : for i in 0 to 3 generate

            w_OUT_STG_0(i) <= i_INPUT(2*i) and i_INPUT(2*i + 1);

        end generate;

        g_Stage_1 : for i in 0 to 1 generate

            w_OUT_STG_1(i) <= w_OUT_STG_0(2*i) and w_OUT_STG_0(2*i+1);

        end generate;

        --w_AUX <=
        o_DOUT <= w_OUT_STG_1(0) and w_OUT_STG_1(1) and i_INPUT(8);

end erode;
