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


// IP VLNV: adapteva.com:Adapteva:eio_tx:1.0
// IP Revision: 17

(* X_CORE_INFO = "eio_tx,Vivado 2014.4" *)
(* CHECK_LICENSE_TYPE = "elink2_top_eio_tx_0_0,eio_tx,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_eio_tx_0_0 (
  TX_LCLK_P,
  TX_LCLK_N,
  reset,
  ioreset,
  TX_FRAME_P,
  TX_FRAME_N,
  TX_DATA_P,
  TX_DATA_N,
  tx_wr_wait,
  tx_rd_wait,
  TX_WR_WAIT_P,
  TX_WR_WAIT_N,
  TX_RD_WAIT_P,
  TX_RD_WAIT_N,
  txlclk_p,
  txlclk_s,
  txlclk_out,
  txframe_p,
  txdata_p,
  ecfg_tx_enable,
  ecfg_tx_gpio_mode,
  ecfg_tx_clkdiv,
  ecfg_dataout
);

(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX lclk_p" *)
output wire TX_LCLK_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX lclk_n" *)
output wire TX_LCLK_N;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire reset;
input wire ioreset;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX frame_p" *)
output wire TX_FRAME_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX frame_n" *)
output wire TX_FRAME_N;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX data_p" *)
output wire [7 : 0] TX_DATA_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX data_n" *)
output wire [7 : 0] TX_DATA_N;
output wire tx_wr_wait;
output wire tx_rd_wait;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX wr_wait_p" *)
input wire TX_WR_WAIT_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX wr_wait_n" *)
input wire TX_WR_WAIT_N;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX rd_wait_p" *)
input wire TX_RD_WAIT_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 TX rd_wait_n" *)
input wire TX_RD_WAIT_N;
input wire txlclk_p;
input wire txlclk_s;
input wire txlclk_out;
input wire [7 : 0] txframe_p;
input wire [63 : 0] txdata_p;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg tx_enable" *)
input wire ecfg_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg tx_gpio_mode" *)
input wire ecfg_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg tx_clkdiv" *)
input wire [3 : 0] ecfg_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg dataout" *)
input wire [10 : 0] ecfg_dataout;

  eio_tx #(
    .IOSTD_ELINK("LVDS_25")
  ) inst (
    .TX_LCLK_P(TX_LCLK_P),
    .TX_LCLK_N(TX_LCLK_N),
    .reset(reset),
    .ioreset(ioreset),
    .TX_FRAME_P(TX_FRAME_P),
    .TX_FRAME_N(TX_FRAME_N),
    .TX_DATA_P(TX_DATA_P),
    .TX_DATA_N(TX_DATA_N),
    .tx_wr_wait(tx_wr_wait),
    .tx_rd_wait(tx_rd_wait),
    .TX_WR_WAIT_P(TX_WR_WAIT_P),
    .TX_WR_WAIT_N(TX_WR_WAIT_N),
    .TX_RD_WAIT_P(TX_RD_WAIT_P),
    .TX_RD_WAIT_N(TX_RD_WAIT_N),
    .txlclk_p(txlclk_p),
    .txlclk_s(txlclk_s),
    .txlclk_out(txlclk_out),
    .txframe_p(txframe_p),
    .txdata_p(txdata_p),
    .ecfg_tx_enable(ecfg_tx_enable),
    .ecfg_tx_gpio_mode(ecfg_tx_gpio_mode),
    .ecfg_tx_clkdiv(ecfg_tx_clkdiv),
    .ecfg_dataout(ecfg_dataout)
  );
endmodule
