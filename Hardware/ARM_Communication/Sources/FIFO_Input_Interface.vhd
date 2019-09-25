-----------------------------------------------------------------
-- Project: ARM Communication
-- Author:  Guilherme Sborz
-- Date:    17/09/2019
-- File:    FIFO_Input_Interface.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.Package_Fixed.all;

library work;
use work.ARM_Communication_package.all;

entity FIFO_Input_Interface is
  port(
      i_CLK         : in std_logic;
      i_RST         : in std_logic;
      i_DATA        : in fixed;        -- Data coming from ARM
      i_VALID       : in std_logic;    -- Ctrl signal send from ARM (indicates that a valid data is being send)
      o_ACK         : out std_logic;   -- Ctrl signal send to ARM (indicates that the data sended previously has been saved)
      o_VALID       : out std_logic;   -- Ctrl signal send to Coprocessor (Indicates that a valid data is being read from the FIFO)
      o_DATA        : out fixed        -- Data stores in FIFO
  );
end FIFO_Input_Interface;

architecture arch of FIFO_Input_Interface is

signal w_W_REQ_FIFO : std_logic; -- Write requisition to FIFO. Signal coming from write ctrl
signal w_R_REQ_FIFO : std_logic; -- Read requisition to FIFO. Signal coming from read ctrl

-- Signals to indicate current state of FIFO
signal w_EMPTY        : std_logic;
--signal w_FULL         : std_logic; -- NEVER USED

signal w_DATA_STD_IN  : std_logic_vector(15 downto 0);
signal w_DATA_STD_OUT : std_logic_vector(15 downto 0);

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

-- CTRL INPUT READ
-- COntrols the process of geting data from the FIFO and sending to the Coprocessor
  Control_FIFO_Read_Input_i : Control_FIFO_Read_Input
  port map (
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_EMPTY => w_EMPTY,
    o_R_REQ => w_R_REQ_FIFO,
    o_VALID => o_VALID
  );

-- FIFO
-- Stores the values coming from ARM before the Coprocessor gets them
  FIFO_i : FIFO
  port map (
    clock => i_CLK,
    data  => w_DATA_STD_IN,
    rdreq => w_R_REQ_FIFO,
    wrreq => w_W_REQ_FIFO,
    empty => w_EMPTY,
    --full  => w_FULL,
    q     => w_DATA_STD_OUT
  );

  w_DATA_STD_IN <= std_logic_vector(i_DATA);
  o_DATA <= fixed(w_DATA_STD_OUT);

end arch;
