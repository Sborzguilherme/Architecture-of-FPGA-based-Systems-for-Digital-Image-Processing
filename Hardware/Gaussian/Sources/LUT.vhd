library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Package_Fixed.all;
use work.Package_Constant.all;
use work.Package_Gaussian.all;

entity LUT is
  generic(
    p_NUMBER_OF_PORTS : integer
  );
  port(
    i_CLK			: in std_logic;
  	i_RST			: in std_logic;
    i_ENA_RD  : in std_logic;                                   -- Ena read from LUT
    i_CONTENT : in fixed_vector(255 downto 0);                  -- LUT Data
    i_ADDR 	  : in addr_vector(p_NUMBER_OF_PORTS-1 downto 0);
  	o_DATA 	  : out fixed_vector(p_NUMBER_OF_PORTS-1 downto 0)
  );
end entity LUT;

architecture arch of LUT is
begin

  g_output_data : for i in 0 to p_NUMBER_OF_PORTS-1 generate
    u_READ : process(i_CLK, i_RST, i_CONTENT)
      begin
        if(i_RST = '1') then
          o_DATA(i) <= (others=>'0');
        elsif (rising_edge(i_CLK)) then
          if(i_ENA_RD = '1') then
            o_DATA(i) <= i_CONTENT(to_integer(unsigned(i_ADDR(i))));
          end if;
        end if;
    end process;
  end generate;
end architecture;
