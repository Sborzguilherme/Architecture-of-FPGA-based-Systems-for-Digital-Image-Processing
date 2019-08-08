-----------------------------------------------------------
-- Project: Gaussian Filter
-- Author: Guilherme Sborz
-- Date: 01/08/2019
-- File: Filter_7.vhd

-- Fixed-Point MAC
-- 7x7 kernel
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

entity Filter_LUT_7 is
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
end entity Filter_LUT_7;

architecture arch of Filter_LUT_7 is

  signal w_BUF_ENA_WRI : std_logic_vector(4 downto 0) := (others => '0');

  signal r_REG_0 : fixed_vector(48 downto 0);   -- 49 -> 24
  signal r_REG_1 : fixed_vector(23 downto 0);   -- 24 -> 12
  signal r_REG_2 : fixed_vector(11 downto 0);   -- 12 -> 6
  signal r_REG_3 : fixed_vector(5 downto 0);    -- 6  -> 3
  signal r_REG_4 : fixed_vector(2 downto 0);    -- 2  -> 1
  signal r_REG_5 : fixed_vector(1 downto 0);

  -- Signal 0 is not used because the weight is zero
  signal w_ADDR_1 : addr_vector(3 downto 0);
  signal w_ADDR_2 : addr_vector(7 downto 0);
  signal w_ADDR_3 : addr_vector(3 downto 0);
  signal w_ADDR_4 : addr_vector(3 downto 0);
  signal w_ADDR_5 : addr_vector(3 downto 0);
  signal w_ADDR_6 : addr_vector(0 downto 0);

  signal w_DATA_1 : fixed_vector(3 downto 0);
  signal w_DATA_2 : fixed_vector(7 downto 0);
  signal w_DATA_3 : fixed_vector(3 downto 0);
  signal w_DATA_4 : fixed_vector(3 downto 0);
  signal w_DATA_5 : fixed_vector(3 downto 0);
  signal w_DATA_6 : fixed_vector(0 downto 0);

  signal w_STAGE_1 : fixed_vector(23 downto 0);   -- 25 -> 12
  signal w_STAGE_2 : fixed_vector(11 downto 0);   -- 12 -> 6
  signal w_STAGE_3 : fixed_vector(5 downto 0);    -- 6  -> 3
  signal w_STAGE_4 : fixed_vector(2 downto 0);    -- 2  -> 1
  signal w_STAGE_5 : fixed_vector(1 downto 0);

  signal r_REG_48_S1 : fixed;
  signal r_REG_48_S2 : fixed;
  signal r_REG_48_S3 : fixed;
  signal r_REG_48_S4 : fixed;

  begin
    -- Shift signal to enable load in the barrier registers
    shift_left_signals : process(i_CLK, i_ENA_REG)
    begin
        if(rising_edge(i_CLK)) then
          w_BUF_ENA_WRI(4 downto 1) <= w_BUF_ENA_WRI(3 downto 0);
          w_BUF_ENA_WRI(0) <= i_ENA_REG;
        end if;
    end process;
--------------------------------------------------------------------------------
-- MULTIPLICATION

  g_ADDR : for i in 0 to 48 generate
      g_addr_condition : if(i=24) generate
        w_ADDR_6(0) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_6(0);

      elsif(i=8 or i=12) generate
        w_ADDR_1(i/12) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_1(i/12);
      elsif(i=36 or i=40) generate
        w_ADDR_1((i/20)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_1((i/20)+1);

      elsif(i=9 or i=11)  generate
        w_ADDR_2(i/11) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_2(i/11);
      elsif(i=9 or i=11)  generate  -- 0, 1
        w_ADDR_2(i/11) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_2(i/11);
      elsif(i=15 or i=19) generate  -- 2, 3
        w_ADDR_2((i/9)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_2((i/9)+1);
      elsif(i=29 or i=33) generate  -- 4, 5
        w_ADDR_2((i/16)+3) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_2((i/16)+3);
      elsif (i=37 or i=39) generate -- 6,7
        w_ADDR_2((i/19)+5) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_2((i/16)+5);

      elsif(i=10 or i=22) generate  -- 0, 1
        w_ADDR_3(i/22) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_3(i/22);
      elsif(i=26 or i=38) generate -- 2, 3
        w_ADDR_3((i/19)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_3((i/19)+1);

      elsif(i=16 or i=18) generate
        w_ADDR_4(i/18) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_4(i/18);
      elsif (i=30 or i=32) generate
        w_ADDR_4((i/16)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_4((i/18)+1);

      elsif(i=17 or i=23) generate
        w_ADDR_5(i/23) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_5(i/23);
      elsif (i=25 or i=31) generate
        w_ADDR_5((i/15)+1) <= i_KERNEL(i)(MSB+LSB-1 downto LSB);
        r_REG_0(i) <= w_DATA_5((i/15)+1);

      else generate
        r_REG_0(i) <= (others=>'0');
      end generate;
    end generate;

      LUT_W1 : LUT
        generic map (
          p_NUMBER_OF_PORTS => 4
        )
        port map (
          i_CLK     => i_CLK,
          i_RST     => i_RST,
          i_ENA_RD  => i_ENA_REG,
          i_CONTENT => c_Gaussian_Lut_7_W1,
          i_ADDR    => w_ADDR_1,
          o_DATA    => w_DATA_1
        );

      LUT_W2 : LUT
        generic map (
          p_NUMBER_OF_PORTS => 8
        )
        port map (
          i_CLK     => i_CLK,
          i_RST     => i_RST,
          i_ENA_RD  => i_ENA_REG,
          i_CONTENT => c_Gaussian_Lut_7_W2,
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
          i_CONTENT => c_Gaussian_Lut_7_W3,
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
          i_CONTENT => c_Gaussian_Lut_7_W4,
          i_ADDR    => w_ADDR_4,
          o_DATA    => w_DATA_4
        );

      LUT_W5 : LUT
        generic map (
          p_NUMBER_OF_PORTS => 4
        )
        port map (
          i_CLK     => i_CLK,
          i_RST     => i_RST,
          i_ENA_RD  => i_ENA_REG,
          i_CONTENT => c_Gaussian_Lut_7_W5,
          i_ADDR    => w_ADDR_5,
          o_DATA    => w_DATA_5
        );

        LUT_W6 : LUT
          generic map (
            p_NUMBER_OF_PORTS => 1
          )
          port map (
            i_CLK     => i_CLK,
            i_RST     => i_RST,
            i_ENA_RD  => i_ENA_REG,
            i_CONTENT => c_Gaussian_Lut_7_W6,
            i_ADDR    => w_ADDR_6,
            o_DATA    => w_DATA_6
          );

    -- g_STAGE_0 : for i in 0 to 48 generate
    --   w_STAGE_0(i) <= i_KERNEL(i) * i_WEIGHTS(i);
    --
		-- 	Reg_S0 : Reg
		-- 	port map (
		-- 	  i_CLK  => i_CLK,
		-- 	  i_RST  => i_RST,
		-- 	  i_ENA  => i_ENA_REG,
		-- 	  i_CLR  => '0',
		-- 	  i_DIN  => w_STAGE_0(i),
		-- 	  o_DOUT => r_REG_0(i)
		-- 	);
    -- end generate;
--------------------------------------------------------------------------------
-- ADDER TREE
    -- FIRST STAGE
    g_STAGE_1 : for i in 0 to 23 generate
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
      i_DIN  => r_REG_0(48),
      o_DOUT => r_REG_48_S1
    );
--------------------------------------------------------------------------------
    -- SECOND STAGE
    g_STAGE_2 : for i in 0 to 11 generate
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
      i_DIN  =>r_REG_48_S1,
      o_DOUT => r_REG_48_S2
    );
--------------------------------------------------------------------------------
  -- THIRD STAGE
  g_STAGE_3 : for i in 0 to 5 generate
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
    i_DIN  => r_REG_48_S2,
    o_DOUT => r_REG_48_S3
  );
--------------------------------------------------------------------------------
  -- FOURTH STAGE
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

  Reg_8_S4 : Reg
  port map (
    i_CLK  => i_CLK,
    i_RST  => i_RST,
    i_ENA  => w_BUF_ENA_WRI(3),
    i_CLR  => '0',
    i_DIN  => r_REG_48_S3,
    o_DOUT => r_REG_48_S4
  );
--------------------------------------------------------------------------------
  -- FIFTH STAGE
    w_STAGE_5(0) <= r_REG_4(0)  + r_REG_4(1);
    w_STAGE_5(1) <= r_REG_4(2) + r_REG_48_S4;

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
--------------------------------------------------------------------------------
    o_RESULT <= r_REG_5(0) + r_REG_5(1);

end architecture;
