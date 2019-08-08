-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 31/07/2019
-- File: Filter_5.vhd

-- Fixed-Point MAC
-- 5x5 kernel
-- pipeline
-- No multipliers
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity Filter_LUT_5 is
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
  end entity Filter_LUT_5;

architecture arch of Filter_LUT_5 is

  signal w_BUF_ENA_WRI : std_logic_vector(3 downto 0) := (others => '0');

  signal r_REG_0 : fixed_vector(24 downto 0);   -- 25 -> 12
  signal r_REG_1 : fixed_vector(11 downto 0);   -- 12 -> 6
  signal r_REG_2 : fixed_vector(5 downto 0);    -- 6  -> 3
  signal r_REG_3 : fixed_vector(2 downto 0);    -- 2  -> 1
  signal r_REG_4 : fixed_vector(1 downto 0);

  signal w_ADDR_0 : addr_vector(3 downto 0);
  signal w_ADDR_1 : addr_vector(7 downto 0);
  signal w_ADDR_2 : addr_vector(3 downto 0);
  signal w_ADDR_3 : addr_vector(3 downto 0);
  signal w_ADDR_4 : addr_vector(3 downto 0);
  signal w_ADDR_5 : addr_vector(0 downto 0);

  signal w_DATA_0 : fixed_vector(3 downto 0);
  signal w_DATA_1 : fixed_vector(7 downto 0);
  signal w_DATA_2 : fixed_vector(3 downto 0);
  signal w_DATA_3 : fixed_vector(3 downto 0);
  signal w_DATA_4 : fixed_vector(3 downto 0);
  signal w_DATA_5 : fixed_vector(0 downto 0);

  --signal w_STAGE_0 : fixed_vector(24 downto 0);   -- 25 -> 12
  signal w_STAGE_1 : fixed_vector(11 downto 0);     -- 12 -> 6
  signal w_STAGE_2 : fixed_vector(5 downto 0);      -- 6  -> 3
  signal w_STAGE_3 : fixed_vector(2 downto 0);      -- 2  -> 1
  signal w_STAGE_4 : fixed_vector(1 downto 0);

  signal r_REG_24_S1 : fixed;
  signal r_REG_24_S2 : fixed;
  signal r_REG_24_S3 : fixed;

  begin
    -- Shift signal to enable load in the barrier registers
    shift_left_signals : process(i_CLK, i_ENA_REG)
    begin
        if(rising_edge(i_CLK)) then
          w_BUF_ENA_WRI(3 downto 1) <= w_BUF_ENA_WRI(2 downto 0);
          w_BUF_ENA_WRI(0) <= i_ENA_REG;
        end if;
    end process;
--------------------------------------------------------------------------------
-- MULTIPLICATION
  g_ADDR : for i in 0 to 24 generate

    g_addr_condition : if (i=12) generate
      w_ADDR_5(0) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_5(0);

    elsif (i=0 or i=4)  generate  -- 0, 1
      w_ADDR_0(i/4) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_0(i/4);
    elsif(i=20 or i=24) generate  -- 2, 3
      w_ADDR_0((i/12)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_0((i/12)+1);

    elsif(i=2 or i=10) generate
      w_ADDR_2(i/10) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_2(i/10);
    elsif(i=14 or i=22) generate
      w_ADDR_2((i/11)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_2((i/11)+1);

    elsif(i=6 or i=8) generate
      w_ADDR_3(i/8) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_3(i/8);
    elsif(i=16 or i=18) generate
      w_ADDR_3((i/9)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_3((i/9)+1);

    elsif(i=7 or i=11) generate
      w_ADDR_4(i/11) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_4(i/11);
    elsif(i=13 or i=17) generate
      w_ADDR_4((i/8)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_4((i/8)+1);

    elsif(i=1 or i=3) generate  -- 0, 1
      w_ADDR_1(i/3) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_1(i/3);
    elsif(i=5 or i=9) generate  -- 2, 3
      w_ADDR_1((i/4)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_1((i/4)+1);
    elsif (i=15 or i=19) generate -- 4, 5
      w_ADDR_1((i/9)+3) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_1((i/9)+3);
    else generate -- i= 21, 23 / 6, 7
      w_ADDR_1((i/11)+5) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
      r_REG_0(i) <= w_DATA_1((i/11)+5);

    end generate;
  end generate;

  LUT_W0 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 4
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W0,
      i_ADDR    => w_ADDR_0,
      o_DATA    => w_DATA_0
    );

  LUT_W1 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 8
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W1,
      i_ADDR    => w_ADDR_1,
      o_DATA    => w_DATA_1
    );

  LUT_W2 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 4
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W2,
      i_ADDR    => w_ADDR_2,
      o_DATA    => w_DATA_2
    );

  LUT_W3 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 4
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W3,
      i_ADDR    => w_ADDR_3,
      o_DATA    => w_DATA_3
    );

  LUT_W4 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 4
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W4,
      i_ADDR    => w_ADDR_4,
      o_DATA    => w_DATA_4
    );

  LUT_W5 : LUT
    generic map (
      p_NUMBER_OF_PORTS => 1
    )
    port map (
      i_CLK     => i_CLK,
      i_RST     => i_RST,
      i_ENA_RD  => i_ENA_REG,
      i_CONTENT => c_Gaussian_Lut_5_W5,
      i_ADDR    => w_ADDR_5,
      o_DATA    => w_DATA_5
    );
--------------------------------------------------------------------------------
-- ADDER TREE
    -- FIRST STAGE
    g_STAGE_1 : for i in 0 to 11 generate
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

    Reg_8_S1 : Reg
    port map (
      i_CLK  => i_CLK,
      i_RST  => i_RST,
      i_ENA  => w_BUF_ENA_WRI(0),
      i_CLR  => '0',
      i_DIN  => r_REG_0(24),
      o_DOUT => r_REG_24_S1
    );
--------------------------------------------------------------------------------
    -- SECOND STAGE
    g_STAGE_2 : for i in 0 to 5 generate
      w_STAGE_2(i) <= r_REG_1(2*i) + r_REG_1((2*i)+1);

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
      i_DIN  =>r_REG_24_S1,
      o_DOUT => r_REG_24_S2
    );
--------------------------------------------------------------------------------
  -- THIRD STAGE
  g_STAGE_3 : for i in 0 to 2 generate
    w_STAGE_3(i) <= r_REG_2(2*i) + r_REG_2((2*i)+1);

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

  Reg_8_S3 : Reg
  port map (
    i_CLK  => i_CLK,
    i_RST  => i_RST,
    i_ENA  => w_BUF_ENA_WRI(2),
    i_CLR  => '0',
    i_DIN  => r_REG_24_S2,
    o_DOUT => r_REG_24_S3
  );
--------------------------------------------------------------------------------
  -- FOURTH STAGE
    w_STAGE_4(0) <= r_REG_3(0)  + r_REG_3(1);
    w_STAGE_4(1) <= r_REG_3(2) + r_REG_24_S3;

    g_STAGE_4 : for i in 0 to 1 generate
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
--------------------------------------------------------------------------------
    o_RESULT <= r_REG_4(0) + r_REG_4(1);

end architecture;
