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


// IP VLNV: adapteva.com:Adapteva:ecfg_split:1.0
// IP Revision: 3

(* X_CORE_INFO = "ecfg_split,Vivado 2014.4" *)
(* CHECK_LICENSE_TYPE = "elink2_top_ecfg_split_0_0,ecfg_split,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_ecfg_split_0_0 (
  slvcfg_datain,
  mcfg0_sw_reset,
  mcfg0_tx_enable,
  mcfg0_tx_mmu_mode,
  mcfg0_tx_gpio_mode,
  mcfg0_tx_ctrl_mode,
  mcfg0_tx_clkdiv,
  mcfg0_rx_enable,
  mcfg0_rx_mmu_mode,
  mcfg0_rx_gpio_mode,
  mcfg0_rx_loopback_mode,
  mcfg0_coreid,
  mcfg0_dataout,
  mcfg1_sw_reset,
  mcfg1_tx_enable,
  mcfg1_tx_mmu_mode,
  mcfg1_tx_gpio_mode,
  mcfg1_tx_ctrl_mode,
  mcfg1_tx_clkdiv,
  mcfg1_rx_enable,
  mcfg1_rx_mmu_mode,
  mcfg1_rx_gpio_mode,
  mcfg1_rx_loopback_mode,
  mcfg1_coreid,
  mcfg1_dataout,
  mcfg2_sw_reset,
  mcfg2_tx_enable,
  mcfg2_tx_mmu_mode,
  mcfg2_tx_gpio_mode,
  mcfg2_tx_ctrl_mode,
  mcfg2_tx_clkdiv,
  mcfg2_rx_enable,
  mcfg2_rx_mmu_mode,
  mcfg2_rx_gpio_mode,
  mcfg2_rx_loopback_mode,
  mcfg2_coreid,
  mcfg2_dataout,
  mcfg3_sw_reset,
  mcfg3_tx_enable,
  mcfg3_tx_mmu_mode,
  mcfg3_tx_gpio_mode,
  mcfg3_tx_ctrl_mode,
  mcfg3_tx_clkdiv,
  mcfg3_rx_enable,
  mcfg3_rx_mmu_mode,
  mcfg3_rx_gpio_mode,
  mcfg3_rx_loopback_mode,
  mcfg3_coreid,
  mcfg3_dataout,
  mcfg4_sw_reset,
  mcfg4_tx_enable,
  mcfg4_tx_mmu_mode,
  mcfg4_tx_gpio_mode,
  mcfg4_tx_ctrl_mode,
  mcfg4_tx_clkdiv,
  mcfg4_rx_enable,
  mcfg4_rx_mmu_mode,
  mcfg4_rx_gpio_mode,
  mcfg4_rx_loopback_mode,
  mcfg4_coreid,
  mcfg4_dataout,
  slvcfg_sw_reset,
  slvcfg_tx_enable,
  slvcfg_tx_mmu_mode,
  slvcfg_tx_gpio_mode,
  slvcfg_tx_ctrl_mode,
  slvcfg_tx_clkdiv,
  slvcfg_rx_enable,
  slvcfg_rx_mmu_mode,
  slvcfg_rx_gpio_mode,
  slvcfg_rx_loopback_mode,
  slvcfg_coreid,
  slvcfg_dataout,
  mcfg0_datain,
  mcfg1_datain,
  mcfg2_datain,
  mcfg3_datain,
  mcfg4_datain
);

(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg datain" *)
output wire [10 : 0] slvcfg_datain;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 sw_reset" *)
output wire mcfg0_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 tx_enable" *)
output wire mcfg0_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 tx_mmu_mode" *)
output wire mcfg0_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 tx_gpio_mode" *)
output wire mcfg0_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 tx_ctrl_mode" *)
output wire [3 : 0] mcfg0_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 tx_clkdiv" *)
output wire [3 : 0] mcfg0_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 rx_enable" *)
output wire mcfg0_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 rx_mmu_mode" *)
output wire mcfg0_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 rx_gpio_mode" *)
output wire mcfg0_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 rx_loopback_mode" *)
output wire mcfg0_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 coreid" *)
output wire [11 : 0] mcfg0_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 dataout" *)
output wire [10 : 0] mcfg0_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 sw_reset" *)
output wire mcfg1_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 tx_enable" *)
output wire mcfg1_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 tx_mmu_mode" *)
output wire mcfg1_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 tx_gpio_mode" *)
output wire mcfg1_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 tx_ctrl_mode" *)
output wire [3 : 0] mcfg1_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 tx_clkdiv" *)
output wire [3 : 0] mcfg1_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 rx_enable" *)
output wire mcfg1_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 rx_mmu_mode" *)
output wire mcfg1_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 rx_gpio_mode" *)
output wire mcfg1_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 rx_loopback_mode" *)
output wire mcfg1_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 coreid" *)
output wire [11 : 0] mcfg1_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 dataout" *)
output wire [10 : 0] mcfg1_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 sw_reset" *)
output wire mcfg2_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 tx_enable" *)
output wire mcfg2_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 tx_mmu_mode" *)
output wire mcfg2_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 tx_gpio_mode" *)
output wire mcfg2_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 tx_ctrl_mode" *)
output wire [3 : 0] mcfg2_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 tx_clkdiv" *)
output wire [3 : 0] mcfg2_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 rx_enable" *)
output wire mcfg2_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 rx_mmu_mode" *)
output wire mcfg2_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 rx_gpio_mode" *)
output wire mcfg2_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 rx_loopback_mode" *)
output wire mcfg2_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 coreid" *)
output wire [11 : 0] mcfg2_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 dataout" *)
output wire [10 : 0] mcfg2_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 sw_reset" *)
output wire mcfg3_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 tx_enable" *)
output wire mcfg3_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 tx_mmu_mode" *)
output wire mcfg3_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 tx_gpio_mode" *)
output wire mcfg3_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 tx_ctrl_mode" *)
output wire [3 : 0] mcfg3_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 tx_clkdiv" *)
output wire [3 : 0] mcfg3_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 rx_enable" *)
output wire mcfg3_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 rx_mmu_mode" *)
output wire mcfg3_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 rx_gpio_mode" *)
output wire mcfg3_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 rx_loopback_mode" *)
output wire mcfg3_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 coreid" *)
output wire [11 : 0] mcfg3_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 dataout" *)
output wire [10 : 0] mcfg3_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 sw_reset" *)
output wire mcfg4_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 tx_enable" *)
output wire mcfg4_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 tx_mmu_mode" *)
output wire mcfg4_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 tx_gpio_mode" *)
output wire mcfg4_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 tx_ctrl_mode" *)
output wire [3 : 0] mcfg4_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 tx_clkdiv" *)
output wire [3 : 0] mcfg4_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 rx_enable" *)
output wire mcfg4_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 rx_mmu_mode" *)
output wire mcfg4_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 rx_gpio_mode" *)
output wire mcfg4_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 rx_loopback_mode" *)
output wire mcfg4_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 coreid" *)
output wire [11 : 0] mcfg4_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 dataout" *)
output wire [10 : 0] mcfg4_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg sw_reset" *)
input wire slvcfg_sw_reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg tx_enable" *)
input wire slvcfg_tx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg tx_mmu_mode" *)
input wire slvcfg_tx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg tx_gpio_mode" *)
input wire slvcfg_tx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg tx_ctrl_mode" *)
input wire [3 : 0] slvcfg_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg tx_clkdiv" *)
input wire [3 : 0] slvcfg_tx_clkdiv;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg rx_enable" *)
input wire slvcfg_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg rx_mmu_mode" *)
input wire slvcfg_rx_mmu_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg rx_gpio_mode" *)
input wire slvcfg_rx_gpio_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg rx_loopback_mode" *)
input wire slvcfg_rx_loopback_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg coreid" *)
input wire [11 : 0] slvcfg_coreid;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 slvcfg dataout" *)
input wire [10 : 0] slvcfg_dataout;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg0 datain" *)
input wire [10 : 0] mcfg0_datain;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg1 datain" *)
input wire [10 : 0] mcfg1_datain;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg2 datain" *)
input wire [10 : 0] mcfg2_datain;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg3 datain" *)
input wire [10 : 0] mcfg3_datain;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 mcfg4 datain" *)
input wire [10 : 0] mcfg4_datain;

  ecfg_split inst (
    .slvcfg_datain(slvcfg_datain),
    .mcfg0_sw_reset(mcfg0_sw_reset),
    .mcfg0_tx_enable(mcfg0_tx_enable),
    .mcfg0_tx_mmu_mode(mcfg0_tx_mmu_mode),
    .mcfg0_tx_gpio_mode(mcfg0_tx_gpio_mode),
    .mcfg0_tx_ctrl_mode(mcfg0_tx_ctrl_mode),
    .mcfg0_tx_clkdiv(mcfg0_tx_clkdiv),
    .mcfg0_rx_enable(mcfg0_rx_enable),
    .mcfg0_rx_mmu_mode(mcfg0_rx_mmu_mode),
    .mcfg0_rx_gpio_mode(mcfg0_rx_gpio_mode),
    .mcfg0_rx_loopback_mode(mcfg0_rx_loopback_mode),
    .mcfg0_coreid(mcfg0_coreid),
    .mcfg0_dataout(mcfg0_dataout),
    .mcfg1_sw_reset(mcfg1_sw_reset),
    .mcfg1_tx_enable(mcfg1_tx_enable),
    .mcfg1_tx_mmu_mode(mcfg1_tx_mmu_mode),
    .mcfg1_tx_gpio_mode(mcfg1_tx_gpio_mode),
    .mcfg1_tx_ctrl_mode(mcfg1_tx_ctrl_mode),
    .mcfg1_tx_clkdiv(mcfg1_tx_clkdiv),
    .mcfg1_rx_enable(mcfg1_rx_enable),
    .mcfg1_rx_mmu_mode(mcfg1_rx_mmu_mode),
    .mcfg1_rx_gpio_mode(mcfg1_rx_gpio_mode),
    .mcfg1_rx_loopback_mode(mcfg1_rx_loopback_mode),
    .mcfg1_coreid(mcfg1_coreid),
    .mcfg1_dataout(mcfg1_dataout),
    .mcfg2_sw_reset(mcfg2_sw_reset),
    .mcfg2_tx_enable(mcfg2_tx_enable),
    .mcfg2_tx_mmu_mode(mcfg2_tx_mmu_mode),
    .mcfg2_tx_gpio_mode(mcfg2_tx_gpio_mode),
    .mcfg2_tx_ctrl_mode(mcfg2_tx_ctrl_mode),
    .mcfg2_tx_clkdiv(mcfg2_tx_clkdiv),
    .mcfg2_rx_enable(mcfg2_rx_enable),
    .mcfg2_rx_mmu_mode(mcfg2_rx_mmu_mode),
    .mcfg2_rx_gpio_mode(mcfg2_rx_gpio_mode),
    .mcfg2_rx_loopback_mode(mcfg2_rx_loopback_mode),
    .mcfg2_coreid(mcfg2_coreid),
    .mcfg2_dataout(mcfg2_dataout),
    .mcfg3_sw_reset(mcfg3_sw_reset),
    .mcfg3_tx_enable(mcfg3_tx_enable),
    .mcfg3_tx_mmu_mode(mcfg3_tx_mmu_mode),
    .mcfg3_tx_gpio_mode(mcfg3_tx_gpio_mode),
    .mcfg3_tx_ctrl_mode(mcfg3_tx_ctrl_mode),
    .mcfg3_tx_clkdiv(mcfg3_tx_clkdiv),
    .mcfg3_rx_enable(mcfg3_rx_enable),
    .mcfg3_rx_mmu_mode(mcfg3_rx_mmu_mode),
    .mcfg3_rx_gpio_mode(mcfg3_rx_gpio_mode),
    .mcfg3_rx_loopback_mode(mcfg3_rx_loopback_mode),
    .mcfg3_coreid(mcfg3_coreid),
    .mcfg3_dataout(mcfg3_dataout),
    .mcfg4_sw_reset(mcfg4_sw_reset),
    .mcfg4_tx_enable(mcfg4_tx_enable),
    .mcfg4_tx_mmu_mode(mcfg4_tx_mmu_mode),
    .mcfg4_tx_gpio_mode(mcfg4_tx_gpio_mode),
    .mcfg4_tx_ctrl_mode(mcfg4_tx_ctrl_mode),
    .mcfg4_tx_clkdiv(mcfg4_tx_clkdiv),
    .mcfg4_rx_enable(mcfg4_rx_enable),
    .mcfg4_rx_mmu_mode(mcfg4_rx_mmu_mode),
    .mcfg4_rx_gpio_mode(mcfg4_rx_gpio_mode),
    .mcfg4_rx_loopback_mode(mcfg4_rx_loopback_mode),
    .mcfg4_coreid(mcfg4_coreid),
    .mcfg4_dataout(mcfg4_dataout),
    .slvcfg_sw_reset(slvcfg_sw_reset),
    .slvcfg_tx_enable(slvcfg_tx_enable),
    .slvcfg_tx_mmu_mode(slvcfg_tx_mmu_mode),
    .slvcfg_tx_gpio_mode(slvcfg_tx_gpio_mode),
    .slvcfg_tx_ctrl_mode(slvcfg_tx_ctrl_mode),
    .slvcfg_tx_clkdiv(slvcfg_tx_clkdiv),
    .slvcfg_rx_enable(slvcfg_rx_enable),
    .slvcfg_rx_mmu_mode(slvcfg_rx_mmu_mode),
    .slvcfg_rx_gpio_mode(slvcfg_rx_gpio_mode),
    .slvcfg_rx_loopback_mode(slvcfg_rx_loopback_mode),
    .slvcfg_coreid(slvcfg_coreid),
    .slvcfg_dataout(slvcfg_dataout),
    .mcfg0_datain(mcfg0_datain),
    .mcfg1_datain(mcfg1_datain),
    .mcfg2_datain(mcfg2_datain),
    .mcfg3_datain(mcfg3_datain),
    .mcfg4_datain(mcfg4_datain)
  );
endmodule
