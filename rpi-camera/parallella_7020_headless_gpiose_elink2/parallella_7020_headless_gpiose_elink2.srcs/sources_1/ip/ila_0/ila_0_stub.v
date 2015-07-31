// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
// Date        : Sat Jun 27 21:27:43 2015
// Host        : lain running 64-bit Gentoo Base System release 2.2
// Command     : write_verilog -force -mode synth_stub
//               /tmp/v/parviv/parallella_7020_headless_gpiose_elink2.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2014.4" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[35:0],probe1[35:0],probe2[35:0],probe3[35:0],probe4[15:0]" */;
  input clk;
  input [35:0]probe0;
  input [35:0]probe1;
  input [35:0]probe2;
  input [35:0]probe3;
  input [15:0]probe4;
endmodule
