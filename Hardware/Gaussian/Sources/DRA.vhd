-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    01/12/2018
-- File:    Delay_Row_Arch.vhd

-- Implementation of the delay row arch to reduce the number of memory acess needed to operate over the image
-- This block have been designed considering the needed of row buffers of different sizes. This happens because the treatment give to the borders of the input image (after each operation the output img is redeced is comparison with the input img)
-- The output of this block is a array with all the values contained in the current kernel (pixels from image)
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity DRA is
generic (
	p_WIDTH_DATA			: integer := MSB+LSB;
	p_KERNEL_HEIGHT 	: integer := 5;
	p_KERNEL_WIDTH		: integer := 5;
	p_KERNEL_SIZE			: integer := 25;
  p_ROW_BUF_SIZE    : integer := 23
);
port(
    i_CLK 					: in std_logic;
    i_RST 					: in std_logic;
    i_INPUT_PIXEL 	: in fixed;
    i_ENA_WRI_KER 	: in std_logic;
	 o_OUT_KERNEL  	: out fixed_vector(p_KERNEL_SIZE-1 downto 0)
);
end DRA;

architecture arch_1 of DRA is

-- Kernel
signal w_KER_DAT : fixed_vector(p_KERNEL_SIZE-1 downto 0);

-- ROW BUFFER
signal w_ROW_BUF_IN  	 : fixed_vector(p_KERNEL_HEIGHT-2 downto 0);
signal w_ROW_BUF_OUT	 : fixed_vector(p_KERNEL_HEIGHT-2 downto 0);

begin
    -- ROW BUFFERS
	g_RB : for i in 0 to p_KERNEL_HEIGHT-2 generate
		row_buffer_i : Row_Buffer
			generic map (
			  c_SIZE  => p_ROW_BUF_SIZE,
			  c_WIDTH => p_WIDTH_DATA
			)
			port map (
			  i_CLK      => i_CLK,
			  i_RST      => i_RST,
			  i_ENA      => i_ENA_WRI_KER,
			  i_CLR      => i_RST,
			  i_DATA_IN  => w_ROW_BUF_IN(i),
			  o_DATA_OUT => w_ROW_BUF_OUT(i)
			);

		w_KER_DAT((i+1) * p_KERNEL_WIDTH) <= w_ROW_BUF_IN(i);
	end generate;

	-- KERNEL WINDOW
	g_K: for i in 0 to p_KERNEL_SIZE-2 generate

		-- START REG KERNEL LINE
		if_Start_End_Line: if (i > 0 and (i mod (p_KERNEL_WIDTH) = 0)) generate
			u_R_S : Reg
				port map (
					i_CLK  => i_CLK,
					i_RST  => i_RST,
					i_ENA  => i_ENA_WRI_KER,
					i_CLR  => i_RST,
					i_DIN  => w_KER_DAT(i+1),
					o_DOUT => w_ROW_BUF_IN((i/p_KERNEL_WIDTH)-1)
				);
		-- END REG KERNEL LINE
        elsif ((i+1) mod p_KERNEL_WIDTH = 0) generate
			u_R_E : Reg
				port map (
				  i_CLK  => i_CLK,
				  i_RST  => i_RST,
				  i_ENA  => i_ENA_WRI_KER,
				  i_CLR  => i_RST,
				  i_DIN  => w_ROW_BUF_OUT((i+1)/(p_KERNEL_WIDTH)-1),
				  o_DOUT => w_KER_DAT(i)
				);

		else generate
			u_R : Reg
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
	u_Last_Reg : Reg
		port map (
		  i_CLK  => i_CLK,
		  i_RST  => i_RST,
		  i_ENA  => i_ENA_WRI_KER,
		  i_CLR  => i_RST,
		  i_DIN  => i_INPUT_PIXEL,
		  o_DOUT => w_KER_DAT(p_KERNEL_SIZE-1)
		);

    o_OUT_KERNEL <= w_KER_DAT;

end arch_1;
