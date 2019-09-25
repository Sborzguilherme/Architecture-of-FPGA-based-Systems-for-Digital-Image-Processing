-----------------------------------------------------------------
-- Project: ARM Communication
-- Author:  Guilherme Sborz
-- Date:    18/09/2019
-- File:    Write_Input_Interface.vhd

-- FIFO and Control_FIFO_Write_Input instantiated
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.ARM_Communication_package.all;

entity Write_Input_Interface is
  generic(
    p_DATA_SIZE : integer := 8
  );
  port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_DATA        : in std_logic_vector(p_DATA_SIZE-1 downto 0); -- Data coming from ARM
      i_VALID       : in std_logic;                                -- Ctrl signal send from ARM (indicates that a valid data is being send)
      i_READ_REQ    : in std_logic;
      o_EMPTY       : out std_logic;                               -- Ctrl signal send to ARM (indicates that the data sended previously has been saved)
      o_ACK         : out std_logic;                               -- Ctrl signal send to Coprocessor (Indicates that a valid data is being read from the FIFO)
      o_DATA        : out std_logic_vector(p_DATA_SIZE-1 downto 0) -- Data stores in FIFO
  );
end Write_Input_Interface;

architecture arch of Write_Input_Interface is

signal w_W_REQ_FIFO : std_logic; -- Write requisition to FIFO. Signal coming from read ctrl

-- Signals to indicate current state of FIFO
--signal w_FULL  : std_logic; -- NEVER USED

begin

-- CTRL INPUT WRITE
-- Controls the process of geting data from the ARM and store in the FIFO
  Control_FIFO_Write_Input_i : Control_FIFO_Write_Input
  port map (
  i_CLK   => i_CLK,
  i_RST   => i_RST,
  i_VALID => i_VALID,     -- INPUT SIGNAL - FROM ARM
  o_W_REQ => w_W_REQ_FIFO,
  o_ACK   => o_ACK        -- OUTPUT SIGNAL - TO ARM
  );

-- FIFO
-- Stores the values coming from ARM before the Coprocessor gets them
  FIFO_i : FIFO
  port map (
    clock => i_CLK,
    data  => i_DATA,
    rdreq => i_READ_REQ,
    wrreq => w_W_REQ_FIFO,
    empty => o_EMPTY,
    --full  => w_FULL,
    q     => o_DATA
  );

end arch;
