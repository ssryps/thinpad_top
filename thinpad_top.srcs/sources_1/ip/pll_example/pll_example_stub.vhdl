-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
<<<<<<< HEAD
-- Date        : Wed Oct 24 23:03:39 2018
-- Host        : mason running 64-bit Ubuntu 18.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/mason/CS/Code/vivado/thinpad_top/thinpad_top.srcs/sources_1/ip/pll_example/pll_example_stub.vhdl
=======
-- Date        : Fri Oct 26 05:30:10 2018
-- Host        : ubuntu running 64-bit Ubuntu 18.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/yw-zhang/Desktop/thinpad_top/thinpad_top.srcs/sources_1/ip/pll_example/pll_example_stub.vhdl
>>>>>>> chap9_1
-- Design      : pll_example
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tfgg676-2L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_example is
  Port ( 
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end pll_example;

architecture stub of pll_example is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,clk_out2,reset,locked,clk_in1";
begin
end;
