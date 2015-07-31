-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
-- Date        : Sat Jun 27 21:27:43 2015
-- Host        : lain running 64-bit Gentoo Base System release 2.2
-- Command     : write_vhdl -force -mode synth_stub
--               /tmp/v/parviv/parallella_7020_headless_gpiose_elink2.srcs/sources_1/ip/ila_0/ila_0_stub.vhdl
-- Design      : ila_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 35 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 35 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 35 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 35 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end ila_0;

architecture stub of ila_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[35:0],probe1[35:0],probe2[35:0],probe3[35:0],probe4[15:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2014.4";
begin
end;
