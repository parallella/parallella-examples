// (c) Copyright 1995-2015 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: adapteva.com:Adapteva:eclock:1.0
// IP Revision: 7

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_eclock_0_0 (
  CCLK_P,
  CCLK_N,
  lclk_s,
  lclk_out,
  lclk_p,
  clkin,
  reset,
  ecfg_cclk_en,
  ecfg_cclk_div,
  ecfg_cclk_pllcfg
);

output wire CCLK_P;
output wire CCLK_N;
output wire lclk_s;
output wire lclk_out;
output wire lclk_p;
input wire clkin;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eClockCfg:1.0 ecfg_cclk en" *)
input wire ecfg_cclk_en;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eClockCfg:1.0 ecfg_cclk div" *)
input wire [3 : 0] ecfg_cclk_div;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eClockCfg:1.0 ecfg_cclk pllcfg" *)
input wire [3 : 0] ecfg_cclk_pllcfg;

  eclock #(
    .CLKIN_PERIOD(10),
    .CLKIN_DIVIDE(1),
    .VCO_MULT(12),
    .CCLK_DIVIDE(2),
    .LCLK_DIVIDE(4),
    .FEATURE_CCLK_DIV(1'B1),
    .IOSTD_ELINK("LVDS_25")
  ) inst (
    .CCLK_P(CCLK_P),
    .CCLK_N(CCLK_N),
    .lclk_s(lclk_s),
    .lclk_out(lclk_out),
    .lclk_p(lclk_p),
    .clkin(clkin),
    .reset(reset),
    .ecfg_cclk_en(ecfg_cclk_en),
    .ecfg_cclk_div(ecfg_cclk_div),
    .ecfg_cclk_pllcfg(ecfg_cclk_pllcfg)
  );
endmodule
