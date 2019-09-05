-----------------------------------------------------------------
-- Project: Convolutional Neural Network
-- Author:  Guilherme Sborz
-- Date:    15/02/2018
-- File:    Row_Buffer_Bin.vhd
-----------------------------------------------------------------
	library ieee;
	use ieee.std_logic_1164.all;

	entity Row_Buffer_Bin is
	generic (
		c_SIZE 	: integer -- shift register size
	);
	port(
		i_CLK 			: in  std_logic;
		i_RST 			: in  std_logic;
		i_ENA 			: in  std_logic;				  --  ENA SHIFT
		i_CLR   		: in  std_logic;          --  CLEAR
		i_DATA_IN 	: in  std_logic;
		o_DATA_OUT	: out std_logic
	);
	end Row_Buffer_Bin;

	architecture arch_1 of Row_Buffer_Bin is
		type t_RowBuffer is array (0 to c_SIZE-1) of std_logic;
		signal byte_shift_reg : t_RowBuffer;
		begin

		process(i_CLK, i_RST, i_CLR, i_ENA)
		begin
			if ((i_RST = '1') or  (i_CLR = '1')) then
				--r_DATA <= (others => '0');
				byte_shift_reg <= (others=>'0');
			elsif (rising_edge(i_CLK) and i_ENA = '1') then
				byte_shift_reg(1 to c_SIZE-1) <= byte_shift_reg(0 to c_SIZE-2);
          		byte_shift_reg(0) <= i_DATA_IN;
       end if;
      end process;

		o_DATA_OUT <= byte_shift_reg(c_SIZE-1);

	end arch_1;
