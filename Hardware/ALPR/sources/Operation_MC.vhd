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

entity operation_MC is
    generic(
        c_KERNEL_SIZE   : integer
    );
    port(
        i_INPUT : in std_logic_vector(0 to c_KERNEL_SIZE-1);
        o_DOUT  : out std_logic
    );
end operation_MC;

architecture dilate of operation_MC is

    signal w_OUT_STG_0  : std_logic_vector(0 to 36);
    signal w_OUT_STG_1  : std_logic_vector(0 to 17);
    signal w_OUT_STG_2  : std_logic_vector(0 to 8);
    signal w_OUT_STG_3  : std_logic_vector(0 to 3);
    signal w_OUT_STG_4  : std_logic_vector(0 to 1);
    signal w_AUX        : std_logic;

    begin

        g_Stage_0 : for i in 0 to 36 generate
            w_OUT_STG_0(i) <= i_INPUT(2*i) or i_INPUT(2*i + 1); -- input(0 to 73) / missing input(74)
        end generate;

        g_Stage_1 : for i in 0 to 17 generate
            w_OUT_STG_1(i) <= w_OUT_STG_0(2*i) or w_OUT_STG_0(2*i+1); -- stage_0 (0 to 35) / missing stage_0(36)
        end generate;

        g_Stage_2 : for i in 0 to 8 generate
            w_OUT_STG_2(i) <= w_OUT_STG_1(2*i) or w_OUT_STG_1(2*i+1); -- stage_1 (0 to 17)
        end generate;

        g_Stage_3 : for i in 0 to 3 generate
            w_OUT_STG_3(i) <= w_OUT_STG_2(2*i) or w_OUT_STG_2(2*i+1); -- stage_2 (0 to 7) / missing stage_2(8)
        end generate;

        g_Stage_4 : for i in 0 to 1 generate
            w_OUT_STG_4(i) <= w_OUT_STG_3(2*i) or w_OUT_STG_3(2*i+1); -- stage_3 (0 to 3)
        end generate;


        w_AUX <= i_INPUT(74) or w_OUT_STG_0(36) or w_OUT_STG_2(8);

        o_DOUT <= w_OUT_STG_4(0) or w_OUT_STG_4(1) or w_AUX;

end dilate;

architecture erode of operation_MC is
  signal w_OUT_STG_0  : std_logic_vector(0 to 36);
  signal w_OUT_STG_1  : std_logic_vector(0 to 17);
  signal w_OUT_STG_2  : std_logic_vector(0 to 8);
  signal w_OUT_STG_3  : std_logic_vector(0 to 3);
  signal w_OUT_STG_4  : std_logic_vector(0 to 1);
  signal w_AUX        : std_logic;

  begin

      g_Stage_0 : for i in 0 to 36 generate
          w_OUT_STG_0(i) <= i_INPUT(2*i) and i_INPUT(2*i + 1); -- input(0 to 73) / missing input(74)
      end generate;

      g_Stage_1 : for i in 0 to 17 generate
          w_OUT_STG_1(i) <= w_OUT_STG_0(2*i) and w_OUT_STG_0(2*i+1); -- stage_0 (0 to 35) / missing stage_0(36)
      end generate;

      g_Stage_2 : for i in 0 to 8 generate
          w_OUT_STG_2(i) <= w_OUT_STG_1(2*i) and w_OUT_STG_1(2*i+1); -- stage_1 (0 to 17)
      end generate;

      g_Stage_3 : for i in 0 to 3 generate
          w_OUT_STG_3(i) <= w_OUT_STG_2(2*i) and w_OUT_STG_2(2*i+1); -- stage_2 (0 to 7) / missing stage_2(8)
      end generate;

      g_Stage_4 : for i in 0 to 1 generate
          w_OUT_STG_4(i) <= w_OUT_STG_3(2*i) and w_OUT_STG_3(2*i+1); -- stage_3 (0 to 3)
      end generate;

      w_AUX <= i_INPUT(74) and w_OUT_STG_0(36) and w_OUT_STG_2(8);

      o_DOUT <= w_OUT_STG_4(0) and w_OUT_STG_4(1) and w_AUX;

end erode;
