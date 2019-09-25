-----------------------------------------------------------------
-- Project: ARM Communication
-- Author:  Guilherme Sborz
-- Date:    17/09/2019
-- File:    FIFO_Output_Interface.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.Package_Fixed.all;

library work;
use work.ARM_Communication_package.all;

entity FIFO_Output_Interface is
  port(
      i_CLK         : in  std_logic;
      i_RST         : in  std_logic;
      i_DATA        : in  fixed;                                    -- Data coming from ARM
      i_VALID       : in  std_logic;                                -- Ctrl signal send from Coprocessor (indicates that a valid data is being send)
      i_ACK         : in  std_logic;                                -- Ctrl signal send from ARM (indicates that the data sended previously has been saved in the ARM)
      o_VALID       : out std_logic;                                -- Ctrl signal send to ARM (indicates thar a valid data is being send)
      o_EMPTY       : out std_logic;
      o_DATA        : out fixed                                     -- Data stores in FIFO
  );
end FIFO_Output_Interface;

architecture arch of FIFO_Output_Interface is

signal w_W_REQ_FIFO : std_logic; -- Write requisition to FIFO. Signal coming from write ctrl
signal w_R_REQ_FIFO : std_logic; -- Read requisition to FIFO. Signal coming from read ctrl

-- Signals to indicate current state of FIFO
signal w_EMPTY : std_logic;

signal w_DATA_STD_IN  : std_logic_vector(15 downto 0);
signal w_DATA_STD_OUT : std_logic_vector(15 downto 0);

begin

-- CTRL OUTPUT READ
-- Controls the process of geting data from the FIFO and send to the ARM processor
  Control_FIFO_Read_Output_i : Control_FIFO_Read_Output
  port map (
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_EMPTY => w_EMPTY,
    i_ACK   => i_ACK,
    o_VALID => o_VALID,
    o_R_REQ => w_R_REQ_FIFO
  );

-- FIFO
-- Stores the values coming from the Coprocessor before the ARM processor gets them

  w_DATA_STD_IN <= i_DATA;

  FIFO_i : FIFO
  port map (
    clock => i_CLK,
    data  => w_DATA_STD_IN,
    rdreq => w_R_REQ_FIFO,
    wrreq => i_VALID,
    empty => w_EMPTY,
    q     => w_DATA_STD_OUT
  );

o_EMPTY <= w_EMPTY;
o_DATA <= fixed(w_DATA_STD_OUT);

end arch;
