-----------------------------------------------------------------
-- Project: Convolutional Neural Network
-- Author:  Guilherme Sborz
-- Date:    20/11/2018
-- File:    Row_Buffer.vhd
-----------------------------------------------------------------
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

	library work;
	use work.Package_Fixed.all;

	entity Row_Buffer is
	generic (
		c_SIZE 	: integer; -- shift register size
    c_WIDTH : integer  -- data size
	);
	port(
		i_CLK 			: in  std_logic;
		i_RST 			: in  std_logic;
		i_ENA 			: in  std_logic;				  --  ENA SHIFT
		i_CLR   		: in  std_logic;          --  CLEAR
		i_DATA_IN 	: in  fixed;
		o_DATA_OUT	: out fixed
	);
	end Row_Buffer;

	architecture arch_1 of Row_Buffer is
	  signal w_byte_shift_reg : fixed_vector(0 to c_SIZE-1);
		begin

		process(i_CLK, i_RST, i_CLR, i_ENA)
		begin
			if ((i_RST = '1') or  (i_CLR = '1')) then
				w_byte_shift_reg <= (others=>(others=>'0'));
			elsif (rising_edge(i_CLK) and i_ENA = '1') then
				w_byte_shift_reg(1 to c_SIZE-1) <= w_byte_shift_reg(0 to c_SIZE-2);
          		w_byte_shift_reg(0) <= i_DATA_IN;
       end if;
      end process;

		o_DATA_OUT <= w_byte_shift_reg(c_SIZE-1);

	end arch_1;
