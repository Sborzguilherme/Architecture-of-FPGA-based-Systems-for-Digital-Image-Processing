----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    09/09/2018
-- File:    Count_Ones.vhd

-- Count the number of bits equal to 1
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Count_Ones is
generic (
	  p_DATA_SIZE : integer
);
port (
	i_CLK : std_logic;
  i_DATA  : in std_logic_vector(p_DATA_SIZE-1 downto 0);
  o_COUNT : out std_logic_vector(15 downto 0) -- Size defined to allow count of ones up to 65536
);
end Count_Ones;

architecture arch of Count_Ones is
begin

-- INCLUIR VERIFICAÇÂO DE RISING EDGE
-- INVERTER DIREÇÂO DA CONSTANTE DO TEMPLATE

  u_COUNT : process(i_DATA, i_CLK)
    variable v_count : std_logic_vector(15 downto 0) := x"0000";

  begin
		if(rising_edge(i_CLK)) then
			v_count := x"0000";
			if(i_DATA /= "XXXXXXXXX") then												-- Avoid sum with non valid values
		    for i in 0 to p_DATA_SIZE-1 loop
		      v_count := v_count + (x"000" & "000" & i_DATA(i));
		    end loop;
			end if;
		end if;

    o_COUNT <= v_count;
  end process;
end architecture;
