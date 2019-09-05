-----------------------------------------------------------
-- Project: ALPR
-- Author: Guilherme Sborz
-- Date: 21/02/2019
-- File: ACC_MEM.vhd

-- Block to hold the histogram from input image
-- Pixel value defines the position
-- Data stored = Current value for respective position + 1
----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;

entity ACC_MEM is generic(
  c_SIZE_MEM    : integer;
  c_WIDTH_DATA  : integer;
  c_WIDTH_ADDR  : integer
);
port(
  i_CLK     : in  std_logic;
  i_RST     : in  std_logic;
  i_WRI_ENA : in  std_logic;
  i_ADDR    : in  std_logic_vector(c_WIDTH_ADDR-1 downto 0);
  o_ACC     : out std_logic_vector(c_WIDTH_DATA-1 downto 0)
);
end ACC_MEM;

architecture arch of ACC_MEM is

   --signal w_HISTOGRAM : t_ACC_MEM(0 to c_SIZE_MEM-1) := (others=>(others=>'0'));
   signal w_ENA_ARRAY : std_logic_vector(0 to c_SIZE_MEM-1) := (others=>'0');
   signal w_ACC_OUT   : t_ACC_MEM(0 TO c_SIZE_MEM-1) := (others=>0);
 begin

g_CNT : for i in 0 to c_SIZE_MEM-1 generate

  Counter_i : Counter
  port map (
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_ENA => w_ENA_ARRAY(i),
    i_CLR => i_RST,
    o_Q   => w_ACC_OUT(i)
  );

end generate;


update_data : process(i_CLK, i_ADDR, i_RST)
  variable v_ENABLE : std_logic_vector(0 to c_SIZE_MEM-1) := (others=>'0');
begin
  if(i_RST = '1') then
    o_ACC <= (others => '0');
  elsif (rising_edge(i_CLK)) then
    v_ENABLE := (others=>'0');
    o_ACC <= std_logic_vector(to_unsigned(w_ACC_OUT(to_integer(unsigned(i_ADDR))), c_WIDTH_DATA));
    if(i_WRI_ENA = '1') then
      v_ENABLE(to_integer(unsigned(i_ADDR))) := '1';
      w_ENA_ARRAY <= v_ENABLE;
    else
      v_ENABLE(to_integer(unsigned(i_ADDR))) := '0';
      w_ENA_ARRAY <= v_ENABLE;
    end if;

  end if;
end process;


end architecture;
