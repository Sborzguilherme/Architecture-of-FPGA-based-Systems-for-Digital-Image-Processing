-----------------------------------------------------------------
-- Project: ARM_Communication
-- Author:  Guilherme Sborz
-- Date:    09/08/2018
-- File:    Control_FIFO_Write.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ARM_Communication_package.all;

entity Test_Communication is
generic(
  p_DATA_SIZE : integer := 7
);
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_DATA  : in  std_logic_vector(p_DATA_SIZE-1 downto 0);
    i_VALID : in  std_logic;                                  -- SW -> HW (INPUT)
    i_ACK   : in  std_logic;                                  -- SW -> HW (OUTPUT)
    o_ACK   : out std_logic;                                  -- HW -> SW (INPUT)
    o_VALID : out std_logic;                                  -- HW -> SW (OUTPUT)
    o_DATA  : out std_logic_vector(p_DATA_SIZE-1 downto 0)
  );
end Test_Communication;

architecture arch of Test_Communication is

  signal w_VALID_READ : std_logic;
  signal w_DATA_READ  : std_logic_vector(p_DATA_SIZE-1 downto 0);

  signal w_BUF_RDY    : std_logic_vector(0 to c_BUF_SIZE-1) := (others=>'0');
  signal w_BUF_DATA   : t_array := (others=>(others=>'0'));

begin

  -- Input interface
  FIFO_Input_Interface_i : FIFO_Input_Interface
  generic map (
    p_DATA_SIZE => p_DATA_SIZE
  )
  port map (
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_DATA  => i_DATA,
    i_VALID => i_VALID,
    o_ACK   => o_ACK,
    o_VALID => w_VALID_READ,
    o_DATA  => w_DATA_READ
  );

  -- SYSTEM (SHIFT_BUFFER)
  u_SB : process(i_CLK, w_DATA_READ, w_VALID_READ)
  begin
    if(rising_edge(i_CLK)) then
      --if(w_VALID_READ = '1') then
        w_BUF_DATA(1 to c_BUF_SIZE-1) <= w_BUF_DATA(0 to c_BUF_SIZE-2);
        w_BUF_DATA(0) <= w_DATA_READ;

        w_BUF_RDY(1 to c_BUF_SIZE-1) <= w_BUF_RDY(0 to c_BUF_SIZE-2);
        w_BUF_RDY(0) <= w_VALID_READ;
      end if;
    --end if;
  end process;

-- Output Interface
  FIFO_Output_Interface_i : FIFO_Output_Interface
  generic map (
    p_DATA_SIZE => p_DATA_SIZE
  )
  port map (
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_DATA  => w_BUF_DATA(c_BUF_SIZE-1),
    i_VALID => w_BUF_RDY(c_BUF_SIZE-1),
    i_ACK   => i_ACK,
    o_VALID => o_VALID,
    o_DATA  => o_DATA
  );

end architecture;
