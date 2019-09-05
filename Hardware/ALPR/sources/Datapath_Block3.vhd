----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/03/2018
-- File:    Datapath_Block3.vhd

-- Blocks implemented:
-- MO2:
-- MC:
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.ALPR_package.all;	-- Package with project types

entity Datapath_Block3 is
    generic(
        c_KERNEL_HEIGHT_MO2     : integer;
        c_KERNEL_WIDTH_MO2      : integer;
        c_INPUT_IMG_HEIGHT_MO2  : integer;
        c_INPUT_IMG_WIDTH_MO2   : integer;
        c_KERNEL_HEIGHT_MC      : integer;
        c_KERNEL_WIDTH_MC       : integer;
        c_INPUT_IMG_HEIGHT_MC   : integer;
        c_INPUT_IMG_WIDTH_MC    : integer

    );
    port(
        i_CLK                 : in  std_logic;
        i_RST                 : in  std_logic;
        i_PIX_RDY_SUB         : in  std_logic;
        i_VALID_PIXEL_MO2     : in  std_logic;
        i_VALID_PIXEL_MC      : in  std_logic;
        i_INPUT_PIXEL         : in  std_logic;
        o_DONE_MO2            : out std_logic;
        o_DONE_MC             : out std_logic;
        o_PIX_RDY             : out std_logic;
        o_OUT_PIXEL           : out std_logic
    );
end Datapath_Block3;

architecture arch of Datapath_Block3 is

signal w_MO2_OUT        : std_logic;
signal w_PIX_RDY_MO2    : std_logic;
signal w_VALID_PIXEL_MC : std_logic;
signal w_OUT_REG        : std_logic;

begin

w_VALID_PIXEL_MC <= i_VALID_PIXEL_MC or w_PIX_RDY_MO2;


  Top_MO2_Pipeline_i : Top_MO2_Pipeline
generic map (
  c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MO2,
  c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MO2,
  c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MO2,
  c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MO2
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => i_PIX_RDY_SUB,
  i_VALID_PIXEL => i_VALID_PIXEL_MO2,
  i_INPUT_PIXEL => i_INPUT_PIXEL,
  o_PIX_RDY     => w_PIX_RDY_MO2,
  o_DONE        => o_DONE_MO2,
  o_OUT_PIXEL   => w_MO2_OUT
);


Top_MC_Pipeline_i : Top_MC_Pipeline
generic map (
  c_KERNEL_HEIGHT    => c_KERNEL_HEIGHT_MC,
  c_KERNEL_WIDTH     => c_KERNEL_WIDTH_MC,
  c_INPUT_IMG_WIDTH  => c_INPUT_IMG_WIDTH_MC,
  c_INPUT_IMG_HEIGHT => c_INPUT_IMG_HEIGHT_MC
)
port map (
  i_CLK         => i_CLK,
  i_RST         => i_RST,
  i_START       => w_PIX_RDY_MO2,
  i_VALID_PIXEL => w_VALID_PIXEL_MC,
  i_INPUT_PIXEL => w_OUT_REG,
  o_PIX_RDY     => o_PIX_RDY,
  o_DONE        => o_DONE_MC,
  o_OUT_PIXEL   => o_OUT_PIXEL
);

FF_i : Flip_Flop
port map (
  i_CLK  => i_CLK,
  i_RST  => i_RST,
  i_ENA  => w_VALID_PIXEL_MC,
  i_CLR  => '0',
  i_DIN  => w_MO2_OUT,
  o_DOUT => w_OUT_REG
);

end architecture;
