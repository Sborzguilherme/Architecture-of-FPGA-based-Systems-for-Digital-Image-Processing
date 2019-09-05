library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.ALPR_package.all;

entity tb_Delay_Row_Arch is
end entity;

architecture arch of tb_Delay_Row_Arch is

    constant period : time := 10 ps;
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal pix_in  : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0);
    signal dra_out : t_KERNEL(0 to 24);

    begin

        clk <= not clk after period/2;
        rst <= '0' after period;

        Delay_Row_Arch_i : Delay_Row_Arch
        generic map (
          c_WIDTH_DATA       => c_WIDTH_DATA_MO1,
          c_KERNEL_HEIGHT    => 5,
          c_KERNEL_WIDTH     => 5,
          c_KERNEL_SIZE      => 25,
          c_ROW_BUF_SIZE_ERO => 4,
          c_ROW_BUF_SIZE_DIL => 2
        )
        port map (
          i_CLK             => clk,
          i_RST             => rst,
          i_INPUT_PIXEL     => pix_in,
          i_ENA_WRI_KER_ERO => '1',
          i_ENA_WRI_KER_DIL => '0',
          i_SEL_OPERATION   => '0',
          o_OUT_KERNEL      => dra_out
);

    p_RES : process
        variable v_img : std_logic_vector(c_WIDTH_DATA_MO1-1 downto 0) := x"00";
      begin
         wait for period;
        v_img := v_img + 1;
        pix_in <= v_img;
        --wait;
      end process;

end architecture;
