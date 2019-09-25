-----------------------------------------------------------------
-- Project: ARM Communication
-- Author:  Guilherme Sborz
-- Date:    17/09/2019
-- File:    ARM_Communication_package.vhd
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Package_Fixed.all;

package ARM_Communication_package is

-- Constants
--constant c_BUF_SIZE  : integer := 5;
--constant c_DATA_SIZE : integer := 8;

 -- Types
--type t_array is array(0 to c_BUF_SIZE-1) of std_logic_vector(c_DATA_SIZE-1 downto 0);

---------------------------- Components declaration ----------------------------
  component Control_FIFO_Read_Input
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_EMPTY : in  std_logic;
    o_R_REQ : out std_logic;
    o_VALID : out std_logic
  );
  end component Control_FIFO_Read_Input;

  component Control_FIFO_Read_Output
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_EMPTY : in  std_logic;
    i_ACK   : in  std_logic;
    o_VALID : out std_logic;
    o_R_REQ : out std_logic
  );
  end component Control_FIFO_Read_Output;

  component Control_FIFO_Write_Input
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_VALID : in  std_logic;
    o_W_REQ : out std_logic;
    o_ACK   : out std_logic
  );
  end component Control_FIFO_Write_Input;

  component FIFO_Input_Interface
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_DATA  : in  fixed;
    i_VALID : in  std_logic;
    o_ACK   : out std_logic;
    o_VALID : out std_logic;
    o_DATA  : out fixed
  );
  end component FIFO_Input_Interface;

  component FIFO_Output_Interface
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_DATA  : in  fixed;
    i_VALID : in  std_logic;
    i_ACK   : in  std_logic;
    o_VALID : out std_logic;
    o_EMPTY : out std_logic;
    o_DATA  : out fixed
  );
  end component FIFO_Output_Interface;

  component FIFO
  port (
    clock : IN  STD_LOGIC;
    data  : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
    rdreq : IN  STD_LOGIC;
    wrreq : IN  STD_LOGIC;
    empty : OUT STD_LOGIC;
    q     : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
  end component FIFO;

  component Test_Communication
  generic (
    p_DATA_SIZE : integer := 7
  );
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_DATA  : in  std_logic_vector(p_DATA_SIZE-1 downto 0);
    i_VALID : in  std_logic;
    i_ACK   : in  std_logic;
    o_ACK   : out std_logic;
    o_VALID : out std_logic;
    o_DATA  : out std_logic_vector(p_DATA_SIZE-1 downto 0)
  );
  end component Test_Communication;

  component Write_Input_Interface
  generic (
    p_DATA_SIZE : integer := 8
  );
  port (
    i_CLK      : in  std_logic;
    i_RST      : in  std_logic;
    i_DATA     : in  std_logic_vector(p_DATA_SIZE-1 downto 0);
    i_VALID    : in  std_logic;
    i_READ_REQ : in  std_logic;
    o_EMPTY    : out std_logic;
    o_ACK      : out std_logic;
    o_DATA     : out std_logic_vector(p_DATA_SIZE-1 downto 0)
  );
  end component Write_Input_Interface;

end ARM_Communication_package;

package body ARM_Communication_package is

end ARM_Communication_package;
