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
use work.Package_Gaussian.all;
use work.Package_Fixed.all;

entity Wrapper_Gaussian is
generic(
  p_KERNEL_HEIGHT     : integer;
  p_KERNEL_WIDTH      : integer;
  p_INPUT_IMG_WIDTH   : integer;
  p_INPUT_IMG_HEIGHT  : integer
);
  port (
    i_CLK   : in  std_logic;
    i_RST   : in  std_logic;
    i_START : in  std_logic;
    i_DATA  : in  fixed;
    i_VALID : in  std_logic;                                  -- SW -> HW (INPUT)
    i_ACK   : in  std_logic;                                  -- SW -> HW (OUTPUT)
    o_ACK   : out std_logic;                                  -- HW -> SW (INPUT)
    o_VALID : out std_logic;                                  -- HW -> SW (OUTPUT)
    o_DONE  : out std_logic;
    o_DATA  : out fixed
  );
end Wrapper_Gaussian;

architecture arch of Wrapper_Gaussian is

  signal w_VALID_READ : std_logic;
  signal w_DATA_READ  : fixed;

  signal w_PIX_RDY : std_logic;
  signal w_DONE    : std_logic;
  signal w_EMPTY   : std_logic;
  signal w_OUT_PIX : fixed;

begin

  -- Input interface
  FIFO_Input_Interface_i : FIFO_Input_Interface
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
  Top_Gaussian_i : Top_Gaussian
  generic map (
    p_KERNEL_HEIGHT    => p_KERNEL_HEIGHT,
    p_KERNEL_WIDTH     => p_KERNEL_WIDTH,
    p_INPUT_IMG_WIDTH  => p_INPUT_IMG_WIDTH,
    p_INPUT_IMG_HEIGHT => p_INPUT_IMG_HEIGHT
  )
  port map (
    i_CLK         => i_CLK,
    i_RST         => i_RST,
    i_START       => i_START,
    i_VALID_PIXEL => w_VALID_READ,
    i_INPUT_PIXEL => w_DATA_READ,
    o_PIX_RDY     => w_PIX_RDY,
    o_DONE        => w_DONE,
    o_OUT_PIXEL   => w_OUT_PIX
  );

-- Output Interface
  FIFO_Output_Interface_i : FIFO_Output_Interface
  port map (
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_DATA  => w_OUT_PIX,
    i_VALID => w_PIX_RDY,
    i_ACK   => i_ACK,
    o_VALID => o_VALID,
    o_EMPTY => w_EMPTY,
    o_DATA  => o_DATA
  );

  o_DONE <= w_DONE and w_EMPTY;

end architecture;
