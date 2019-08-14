-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 13/08/2019
-- File: Filter_Apx_3.vhd

-- Fixed-Point MAC - With approximated operators
-- 3x3 kernel
-- pipeline
-- No reorganization on multipliers
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Filter_Apx_3 is
  generic(
    p_FILTER_SIZE : integer -- Kernel Height * Kernel width
  );
  port(
    i_CLK			: in std_logic;
  	i_RST			: in std_logic;
    i_ENA_REG : in std_logic;
    i_KERNEL 	: in fixed_vector(p_FILTER_SIZE-1 downto 0);
    i_WEIGHTS : in fixed_vector(p_FILTER_SIZE-1 downto 0);
  	o_RESULT 	: out fixed
  );
  end entity Filter_Apx_3;

architecture arch of Filter_Apx_3 is

  signal w_BUF_ENA_WRI : std_logic_vector(2 downto 0) := (others => '0');

  signal r_REG_0 : fixed_vector(8 downto 0);
  signal r_REG_1 : fixed_vector(3 downto 0);
  signal r_REG_2 : fixed_vector(1 downto 0);
  signal r_REG_3 : fixed;

  --signal w_STAGE_0 : array_vector(8 downto 0);  -- Kernel * weights
  signal w_STAGE_0 : fixed_vector(8 downto 0);
  signal w_STAGE_1 : fixed_vector(3 downto 0);  -- w_STAGE_0(0 to 7) - 8 -> 4 // w_STAGE_0(8) not used
  signal w_STAGE_2 : fixed_vector(1 downto 0);  -- w_STAGE_1(0 to 3) - 4 -> 2 // w_STAGE_0(24 not used)
  signal w_STAGE_3 : fixed;

  signal r_REG_8_S1 : fixed;
  signal r_REG_8_S2 : fixed;
  signal r_REG_8_S3 : fixed;

  begin
    -- Shift signal to enable load in the barrier registers
    shift_left_signals : process(i_CLK, i_ENA_REG)
    begin
        if(rising_edge(i_CLK)) then
          w_BUF_ENA_WRI(2 downto 1) <= w_BUF_ENA_WRI(1 downto 0);
          w_BUF_ENA_WRI(0) <= i_ENA_REG;
        end if;
    end process;

    -- MULTIPLICATION
------------------------------ STAGE 0 -----------------------------------------
    g_STAGE_0 : for i in 0 to 8 generate

      -- Apx_Mult_16_bit_s0 : Apx_Mult_16_bit
      -- port map (
      --   i_A    => std_logic_vector(i_WEIGHTS(i)),
      --   i_B    => std_logic_vector(i_KERNEL(i)),
      --   o_MULT => w_STAGE_0(i)
      -- );

      w_STAGE_0(i) <= i_WEIGHTS(i) * i_KERNEL(i);

			Reg_S0 : Reg
			port map (
			  i_CLK  => i_CLK,
			  i_RST  => i_RST,
			  i_ENA  => i_ENA_REG,
			  i_CLR  => '0',
			  --i_DIN  => fixed(w_STAGE_0(i)),
        i_DIN  => w_STAGE_0(i),
			  o_DOUT => r_REG_0(i)
			);
    end generate;
------------------------------ STAGE 1 -----------------------------------------
      g_STAGE_1 : for i in 0 to 3 generate

        Apx_FA_16_bit_s1 : Apx_FA_16_bit
        port map (
          i_A   => r_REG_0(2*i),
          i_B   => r_REG_0((2*i)+1),
          o_SUM => w_STAGE_1(i)
        );

        Reg_S1 : Reg
        port map (
          i_CLK  => i_CLK,
          i_RST  => i_RST,
          i_ENA  => w_BUF_ENA_WRI(0),
          i_CLR  => '0',
          i_DIN  => w_STAGE_1(i),
          o_DOUT => r_REG_1(i)
        );
    end generate;

        Reg_8_S1 : Reg
        port map (
          i_CLK  => i_CLK,
          i_RST  => i_RST,
          i_ENA  => w_BUF_ENA_WRI(0),
          i_CLR  => '0',
          i_DIN  => r_REG_0(8),
          o_DOUT => r_REG_8_S1
        );

------------------------------ STAGE 2 -----------------------------------------
    g_STAGE_2 : for i in 0 to 1 generate

      Apx_FA_16_bit_s2 : Apx_FA_16_bit
      port map (
        i_A   => r_REG_1(2*i),
        i_B   => r_REG_1((2*i)+1),
        o_SUM => w_STAGE_2(i)
      );

      Reg_S2 : Reg
      port map (
        i_CLK  => i_CLK,
        i_RST  => i_RST,
        i_ENA  => w_BUF_ENA_WRI(1),
        i_CLR  => '0',
        i_DIN  => w_STAGE_2(i),
        o_DOUT => r_REG_2(i)
      );
    end generate;

      Reg_8_S2 : Reg
      port map (
        i_CLK  => i_CLK,
        i_RST  => i_RST,
        i_ENA  => w_BUF_ENA_WRI(1),
        i_CLR  => '0',
        i_DIN  => r_REG_8_S1,
        o_DOUT => r_REG_8_S2
      );

------------------------------ STAGE 3 -----------------------------------------
    Apx_FA_16_bit_s3 : Apx_FA_16_bit
    port map (
      i_A   => r_REG_2(0),
      i_B   => r_REG_2(1),
      o_SUM => w_STAGE_3
    );

    Reg_S3 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(2),
      i_CLR  => '0',
      i_DIN  => w_STAGE_3,
      o_DOUT => r_REG_3
    );

    Reg_8_S3 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(2),
      i_CLR  => '0',
      i_DIN  => r_REG_8_S2,
      o_DOUT => r_REG_8_S3
    );

    Apx_FA_16_bit_i : Apx_FA_16_bit
    port map (
      i_A   => r_REG_3,
      i_B   => r_REG_8_S3,
      o_SUM => o_RESULT
    );

end architecture;
