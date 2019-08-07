-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 06/08/2019
-- File: SG_Filter_5.vhd

-- Fixed-Point MAC
-- 5x5 kernel
-- pipeline
-- Multipliers reorganized
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity SG_Filter_5 is
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
end entity SG_Filter_5;

architecture arch of SG_Filter_5 is

  signal w_BUF_ENA_WRI : std_logic_vector(4 downto 0) := (others => '0');

  signal w_STAGE_0 : fixed_vector(12 downto 0);
  signal w_STAGE_1 : fixed_vector(5 downto 0);
  signal w_STAGE_2 : fixed_vector(5 downto 0);
  signal w_STAGE_3 : fixed_vector(5 downto 0);
  signal w_STAGE_4 : fixed_vector(2 downto 0);
  signal w_STAGE_5 : fixed_vector(1 downto 0);

  signal r_REG_0 : fixed_vector(12 downto 0);
  signal r_REG_1 : fixed_vector(5 downto 0);
  signal r_REG_2 : fixed_vector(5 downto 0);
  signal r_REG_3 : fixed_vector(5 downto 0);
  signal r_REG_4 : fixed_vector(2 downto 0);
  signal r_REG_5 : fixed_vector(1 downto 0);

  signal r_12_S0_S1 : fixed;

  begin
    -- Shift signal to enable load in the barrier registers
    shift_left_signals : process(i_CLK, i_ENA_REG)
    begin
        if(rising_edge(i_CLK)) then
          w_BUF_ENA_WRI(4 downto 1) <= w_BUF_ENA_WRI(3 downto 0);
          w_BUF_ENA_WRI(0) <= i_ENA_REG;
        end if;
    end process;

------------------------------ STAGE 0 -----------------------------------------
-- Reordering the Filter
-- Sum values that will be multiplied by the same value
  -- i_WEIGHTS(0)
  w_STAGE_0(0) <= i_KERNEL(0)   + i_KERNEL(4);
  w_STAGE_0(1) <= i_KERNEL(20)  + i_KERNEL(24);

  -- i_WEIGHTS(1)
  w_STAGE_0(2) <= i_KERNEL(1)   + i_KERNEL(3);
  w_STAGE_0(3) <= i_KERNEL(5)   + i_KERNEL(9);
  w_STAGE_0(4) <= i_KERNEL(15)  + i_KERNEL(19);
  w_STAGE_0(5) <= i_KERNEL(21)  + i_KERNEL(23);

  -- i_WEIGHTS(2)
  w_STAGE_0(6)  <= i_KERNEL(2)   + i_KERNEL(10);
  w_STAGE_0(7)  <= i_KERNEL(14)  + i_KERNEL(22);

  -- i_WEIGHTS(6)
  w_STAGE_0(8)  <= i_KERNEL(6)   + i_KERNEL(8);
  w_STAGE_0(9)  <= i_KERNEL(16)  + i_KERNEL(18);

  -- i_WEIGHTS(2)
  w_STAGE_0(10)  <= i_KERNEL(7)   + i_KERNEL(11);
  w_STAGE_0(11)  <= i_KERNEL(13)  + i_KERNEL(17);

  -- i_WEIGHTS(12)
  w_STAGE_0(12) <= i_KERNEL(12);

  g_STAGE_0 : for i in 0 to 12 generate
  	Reg_S0 : Reg
  	port map (
  	  i_CLK  => i_CLK,
  	  i_RST  => i_RST,
  	  i_ENA  => i_ENA_REG,
  	  i_CLR  => '0',
  	  i_DIN  => w_STAGE_0(i),
  	  o_DOUT => r_REG_0(i)
  	);
  end generate;
------------------------------ STAGE 1 -----------------------------------------
  g_STAGE_1 : for i in 0 to 5 generate
    w_STAGE_1(i) <= r_REG_0(2*i) + r_REG_0((2*i)+1);

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

    Reg_4_S1 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(0),
      i_CLR  => '0',
      i_DIN  => r_REG_0(12),
      o_DOUT => r_12_S0_S1
    );
------------------------------ STAGE 2 -----------------------------------------

  w_STAGE_2(0) <= r_REG_1(0);
  w_STAGE_2(1) <= r_REG_1(1) + r_REG_1(2);
  w_STAGE_2(2) <= r_REG_1(3);
  w_STAGE_2(3) <= r_REG_1(4);
  w_STAGE_2(4) <= r_REG_1(5);
  w_STAGE_2(5) <= r_12_S0_S1;

  g_STAGE_2 : for i in 0 to 5 generate
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

------------------------------ STAGE 3 -----------------------------------------
  w_STAGE_3(0) <= r_REG_2(0) * i_WEIGHTS(0);
  w_STAGE_3(1) <= r_REG_2(1) * i_WEIGHTS(1);
  w_STAGE_3(2) <= r_REG_2(2) * i_WEIGHTS(2);
  w_STAGE_3(3) <= r_REG_2(3) * i_WEIGHTS(6);
  w_STAGE_3(4) <= r_REG_2(4) * i_WEIGHTS(7);
  w_STAGE_3(5) <= r_REG_2(5) * i_WEIGHTS(12);

  g_STAGE_3 : for i in 0 to 5 generate
    Reg_S3 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(2),
      i_CLR  => '0',
      i_DIN  => w_STAGE_3(i),
      o_DOUT => r_REG_3(i)
    );
  end generate;

------------------------------ STAGE 4 -----------------------------------------
  g_STAGE_4 : for i in 0 to 2 generate
    w_STAGE_4(i) <= r_REG_3(2*i) + r_REG_3((2*i)+1);

    Reg_S4 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(3),
      i_CLR  => '0',
      i_DIN  => w_STAGE_4(i),
      o_DOUT => r_REG_4(i)
    );
  end generate;

------------------------------ STAGE 5 -----------------------------------------
  w_STAGE_5(0) <= r_REG_4(0) + r_REG_4(1);
  w_STAGE_5(1) <= r_REG_4(2);

  g_STAGE_5 : for i in 0 to 1 generate
    Reg_S5 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(4),
      i_CLR  => '0',
      i_DIN  => w_STAGE_5(i),
      o_DOUT => r_REG_5(i)
    );
  end generate;

------------------------------ RESULT -----------------------------------------
  o_RESULT <= r_REG_5(0) + r_REG_5(1);

end architecture;
