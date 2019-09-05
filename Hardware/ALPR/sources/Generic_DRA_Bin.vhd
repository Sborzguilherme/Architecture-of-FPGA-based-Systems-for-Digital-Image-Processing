-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    15/02/2018
-- File:    Generic_DRA_Bin.vhd

-- Implementation of the delay row arch to reduce the number of memory acess needed to operate over the image
-- This block have been designed considering the needed of row buffers of different sizes. This happens because the treatment give to the borders of the input image (after each operation the output img is redeced is comparison with the input img)
-- The output of this block is a array with all the values contained in the current kernel (pixels from image)
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;	-- Package with project types


entity Generic_DRA_Bin is
generic (
	c_KERNEL_HEIGHT 	: integer;
	c_KERNEL_WIDTH		: integer;
	c_KERNEL_SIZE			: integer;
  c_ROW_BUF_SIZE   	: integer
);
port(
  i_CLK 					: in  std_logic;
  i_RST 					: in  std_logic;
  i_INPUT_PIXEL 	: in  std_logic;
  i_ENA_WRI_KER 	: in  std_logic;
	o_OUT_KERNEL    : out std_logic_vector(0 to c_KERNEL_SIZE-1)
);
end Generic_DRA_Bin;

architecture arch_1 of Generic_DRA_Bin is

--constant c_KERNEL_SIZE : integer := c_KERNEL_WIDTH * c_KERNEL_HEIGHT

-- Kernel
signal w_KER_DAT : std_logic_vector(0 to c_KERNEL_SIZE-1);

-- ROW BUFFER
signal w_ROW_BUF_IN  	 : std_logic_vector(0 to c_KERNEL_HEIGHT-2);
signal w_ROW_BUF_OUT	 : std_logic_vector(0 to c_KERNEL_HEIGHT-2);

begin
    -- ROW BUFFERS
	g_RB : for i in 0 to c_KERNEL_HEIGHT-2 generate

		Row_Buffer_Bin_i : Row_Buffer_Bin
		generic map (
		  c_SIZE => c_ROW_BUF_SIZE
		)
		port map (
		  i_CLK      => i_CLK,
		  i_RST      => i_RST,
		  i_ENA      => i_ENA_WRI_KER,
		  i_CLR      => i_RST,
		  i_DATA_IN  => w_ROW_BUF_IN(i),
		  o_DATA_OUT => w_ROW_BUF_OUT(i)
		);

		w_KER_DAT((i+1) * c_KERNEL_WIDTH) <= w_ROW_BUF_IN(i);
	end generate;

	-- KERNEL WINDOW
	g_K: for i in 0 to c_KERNEL_SIZE-2 generate

		-- START REG KERNEL LINE
		if_Start_End_Line: if (i > 0 and (i mod (c_KERNEL_WIDTH) = 0)) generate

			FF_SE : Flip_Flop
			port map (
				i_CLK  => i_CLK,
				i_RST  => i_RST,
				i_ENA  => i_ENA_WRI_KER,
				i_CLR  => i_RST,
				i_DIN  => w_KER_DAT(i+1),
				o_DOUT => w_ROW_BUF_IN((i/c_KERNEL_WIDTH)-1)
			);

		-- END REG KERNEL LINE
    elsif ((i+1) mod c_KERNEL_WIDTH = 0) generate

			FF_E : Flip_Flop
			port map (
				i_CLK  => i_CLK,
				i_RST  => i_RST,
				i_ENA  => i_ENA_WRI_KER,
				i_CLR  => i_RST,
				i_DIN  => w_ROW_BUF_OUT((i+1)/(c_KERNEL_WIDTH)-1),
				o_DOUT => w_KER_DAT(i)
			);

		else generate

			FF_R : Flip_Flop
			port map (
				i_CLK  => i_CLK,
				i_RST  => i_RST,
				i_ENA  => i_ENA_WRI_KER,
				i_CLR  => i_RST,
				i_DIN  => w_KER_DAT(i+1),
				o_DOUT => w_KER_DAT(i)
			);

		end generate if_Start_End_Line;

	end generate g_K;

	-- KERNEL WINDOW
	FF_Last_Reg : Flip_Flop
	port map (
		i_CLK  => i_CLK,
		i_RST  => i_RST,
		i_ENA  => i_ENA_WRI_KER,
		i_CLR  => i_RST,
		i_DIN  => i_INPUT_PIXEL,
		o_DOUT => w_KER_DAT(c_KERNEL_SIZE-1)
	);

    o_OUT_KERNEL <= w_KER_DAT;

end arch_1;
