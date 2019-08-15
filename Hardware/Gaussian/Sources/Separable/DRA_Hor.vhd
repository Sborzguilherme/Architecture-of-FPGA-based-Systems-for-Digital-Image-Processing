-----------------------------------------------------------------
-- Project: Gaussian Filter
-- Author:  Guilherme Sborz
-- Date:    15/08/2019
-- File:    DRA_Hor.vhd
-----------------------------------------------------------------
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

	library work;
	use work.Package_Fixed.all;

	entity DRA_Hor is
	generic (
		c_SIZE 	    : integer; -- shift register size
    c_DATA_SIZE : integer  -- data size
	);
	port(
		i_CLK 			: in  std_logic;
		i_RST 			: in  std_logic;
		i_ENA 			: in  std_logic;				  --  ENA SHIFT
		i_CLR   		: in  std_logic;          --  CLEAR
		i_DATA_IN 	: in  fixed;
		o_DATA_OUT	: out fixed_vector(c_SIZE-1 downto 0)
	);
	end DRA_Hor;

	architecture arch_1 of DRA_Hor is
	  signal w_MEM : fixed_vector(c_SIZE-1 downto 0);
		begin

		process(i_CLK, i_RST, i_CLR, i_ENA, i_DATA_IN, w_MEM)
		begin
			if ((i_RST = '1') or  (i_CLR = '1')) then
				w_MEM <= (others=>(others=>'0'));
			elsif (rising_edge(i_CLK) and i_ENA = '1') then
				w_MEM(c_SIZE-2 downto 0) <= w_MEM(c_SIZE-1 downto 1);
        w_MEM(c_SIZE-1) <= i_DATA_IN;
       end if;
      end process;

		o_DATA_OUT <= w_MEM;

	end arch_1;
