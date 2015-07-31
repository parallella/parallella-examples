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


// IP VLNV: adapteva.com:Adapteva:eio_rx:1.0
// IP Revision: 9

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_eio_rx_0_0 (
  RX_WR_WAIT_P,
  RX_WR_WAIT_N,
  RX_RD_WAIT_P,
  RX_RD_WAIT_N,
  rxlclk_p,
  rxframe_p,
  rxdata_p,
  ecfg_datain,
  RX_LCLK_P,
  RX_LCLK_N,
  reset,
  ioreset,
  RX_FRAME_P,
  RX_FRAME_N,
  RX_DATA_P,
  RX_DATA_N,
  rx_wr_wait,
  rx_rd_wait,
  ecfg_rx_enable,
  ecfg_rx_gpio_mode,
  ecfg_rx_loopback_mode,
  ecfg_dataout,
  tx_wr_wait,
  tx_rd_wait,
  txlclk_p,
  loopback_data,
  loopback_frame
);

(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX wr_wait_p" *)
output wire RX_WR_WAIT_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX wr_wait_n" *)
output wire RX_WR_WAIT_N;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX rd_wait_p" *)
output wire RX_RD_WAIT_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX rd_wait_n" *)
output wire RX_RD_WAIT_N;
output wire rxlclk_p;
output wire [7 : 0] rxframe_p;
output wire [63 : 0] rxdata_p;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg datain" *)
output wire [10 : 0] ecfg_datain;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX lclk_p" *)
input wire RX_LCLK_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX lclk_n" *)
input wire RX_LCLK_N;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire reset;
input wire ioreset;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX frame_p" *)
input wire RX_FRAME_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX frame_n" *)
input wire RX_FRAME_N;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX data_p" *)
input wire [7 : 0] RX_DATA_P;
(* X_INTERFACE_INFO = "adapteva.com:interface:eLink:1.0 RX data_n" *)
input wire [7 : 0] RX_DATA_N;
input wire rx_wr_wait;
input wire rx_rd_wait;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg rx_enable" *)
input wire ecfg_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg rx_gpio_mode" *)
input wire ecfg_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg rx_loopback_mode" *)
input wire ecfg_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg dataout" *)
input wire [10 : 0] ecfg_dataout;
input wire tx_wr_wait;
input wire tx_rd_wait;
input wire txlclk_p;
input wire [63 : 0] loopback_data;
input wire [7 : 0] loopback_frame;

  eio_rx #(
    .IOSTD_ELINK("LVDS_25")
  ) inst (
    .RX_WR_WAIT_P(RX_WR_WAIT_P),
    .RX_WR_WAIT_N(RX_WR_WAIT_N),
    .RX_RD_WAIT_P(RX_RD_WAIT_P),
    .RX_RD_WAIT_N(RX_RD_WAIT_N),
    .rxlclk_p(rxlclk_p),
    .rxframe_p(rxframe_p),
    .rxdata_p(rxdata_p),
    .ecfg_datain(ecfg_datain),
    .RX_LCLK_P(RX_LCLK_P),
    .RX_LCLK_N(RX_LCLK_N),
    .reset(reset),
    .ioreset(ioreset),
    .RX_FRAME_P(RX_FRAME_P),
    .RX_FRAME_N(RX_FRAME_N),
    .RX_DATA_P(RX_DATA_P),
    .RX_DATA_N(RX_DATA_N),
    .rx_wr_wait(rx_wr_wait),
    .rx_rd_wait(rx_rd_wait),
    .ecfg_rx_enable(ecfg_rx_enable),
    .ecfg_rx_gpio_mode(ecfg_rx_gpio_mode),
    .ecfg_rx_loopback_mode(ecfg_rx_loopback_mode),
    .ecfg_dataout(ecfg_dataout),
    .tx_wr_wait(tx_wr_wait),
    .tx_rd_wait(tx_rd_wait),
    .txlclk_p(txlclk_p),
    .loopback_data(loopback_data),
    .loopback_frame(loopback_frame)
  );
endmodule
