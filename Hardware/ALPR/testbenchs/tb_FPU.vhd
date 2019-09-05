library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity tb_FPU is
end entity;

architecture arch of tb_FPU is

constant period : time := 20 ps;
signal   clk    : std_logic := '0';
signal zero : std_logic;

signal dataa  : std_logic_vector(31 downto 0);
signal datab  : std_logic_vector(31 downto 0);
signal sum    : std_logic_vector(31 downto 0);
signal sub    : std_logic_vector(31 downto 0);
signal div    : std_logic_vector(31 downto 0);
signal mul    : std_logic_vector(31 downto 0);
signal con    : std_logic_vector(31 downto 0);

begin

    dataa <= x"40166666"; -- 2,35
    datab <= x"3FB33333"; -- 1,4

    clk   <= not clk after period/2;

    FPU_ADD : FPU_ADD_SUB
    port map (
      add_sub => '1', -- add
      clock   => clk,
      dataa   => dataa,
      datab   => datab,
      result  => sum,
      zero    => zero
    );

    FPU_SUB : FPU_ADD_SUB
    port map (
      add_sub => '0',  -- sub
      clock   => clk,
      dataa   => dataa,
      datab   => datab,
      result  => sub,
      zero    => zero
    );
    --
    FPU_DIV_i : FPU_DIV
    port map (
      clock  => clk,
      dataa  => dataa,
      datab  => datab,
      result => div
    );
    --
    FPU_MULT_i : FPU_MULT
    port map (
      clock  => clk,
      dataa  => dataa,
      datab  => datab,
      result => mul
    );

    FPU_CONVERT_i : FPU_CONVERT
    port map (
      clock  => clk,
      dataa  => x"0000002D",
      result => con
  );


end architecture;
