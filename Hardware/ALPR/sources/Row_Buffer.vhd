-----------------------------------------------------------------
-- Project: Convolutional Neural Network
-- Author:  Guilherme Sborz
-- Date:    20/11/2018
-- File:    row_buffer.vhd
-----------------------------------------------------------------
	library ieee;
	use ieee.std_logic_1164.all;

	entity row_buffer is
	generic (
		c_SIZE 	: integer; -- shift register size
    	c_WIDTH : integer  -- data size
	);
	port(
		i_CLK 			: in  std_logic;
		i_RST 			: in  std_logic;
		i_ENA 			: in  std_logic;				  --  ENA SHIFT
		i_CLR   		: in  std_logic;               	  --  CLEAR
		i_DATA_IN 		: in  std_logic_vector(c_WIDTH-1 downto 0);
		o_DATA_OUT		: out std_logic_vector(c_WIDTH-1 downto 0)
	);
	end row_buffer;

	architecture arch_1 of row_buffer is
		type RB is array (0 to c_SIZE-1) of std_logic_vector(c_WIDTH-1 downto 0);
		signal byte_shift_reg : RB;
		begin

		process(i_CLK, i_RST, i_CLR, i_ENA)
		begin
			if ((i_RST = '1') or  (i_CLR = '1')) then
				--r_DATA <= (others => '0');
				byte_shift_reg <= (others=>(others=>'0'));
			elsif (rising_edge(i_CLK) and i_ENA = '1') then
				byte_shift_reg(1 to c_SIZE-1) <= byte_shift_reg(0 to c_SIZE-2);
          		byte_shift_reg(0) <= i_DATA_IN;
       end if;
      end process;

		o_DATA_OUT <= byte_shift_reg(c_SIZE-1);

	end arch_1;
