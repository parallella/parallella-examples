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

// IP VLNV: adapteva.com:Adapteva:eCfg:1.0
// IP Revision: 7

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
elink2_top_eCfg_0_0 your_instance_name (
  .mi_dout(mi_dout),                              // output wire [31 : 0] mi_dout
  .ecfg_sw_reset(ecfg_sw_reset),                  // output wire ecfg_sw_reset
  .ecfg_reset(ecfg_reset),                        // output wire ecfg_reset
  .ecfg_tx_enable(ecfg_tx_enable),                // output wire ecfg_tx_enable
  .ecfg_tx_mmu_mode(ecfg_tx_mmu_mode),            // output wire ecfg_tx_mmu_mode
  .ecfg_tx_gpio_mode(ecfg_tx_gpio_mode),          // output wire ecfg_tx_gpio_mode
  .ecfg_tx_ctrl_mode(ecfg_tx_ctrl_mode),          // output wire [3 : 0] ecfg_tx_ctrl_mode
  .ecfg_tx_clkdiv(ecfg_tx_clkdiv),                // output wire [3 : 0] ecfg_tx_clkdiv
  .ecfg_rx_enable(ecfg_rx_enable),                // output wire ecfg_rx_enable
  .ecfg_rx_mmu_mode(ecfg_rx_mmu_mode),            // output wire ecfg_rx_mmu_mode
  .ecfg_rx_gpio_mode(ecfg_rx_gpio_mode),          // output wire ecfg_rx_gpio_mode
  .ecfg_rx_loopback_mode(ecfg_rx_loopback_mode),  // output wire ecfg_rx_loopback_mode
  .ecfg_cclk_en(ecfg_cclk_en),                    // output wire ecfg_cclk_en
  .ecfg_cclk_div(ecfg_cclk_div),                  // output wire [3 : 0] ecfg_cclk_div
  .ecfg_cclk_pllcfg(ecfg_cclk_pllcfg),            // output wire [3 : 0] ecfg_cclk_pllcfg
  .ecfg_coreid(ecfg_coreid),                      // output wire [11 : 0] ecfg_coreid
  .ecfg_dataout(ecfg_dataout),                    // output wire [10 : 0] ecfg_dataout
  .mi_clk(mi_clk),                                // input wire mi_clk
  .mi_rst(mi_rst),                                // input wire mi_rst
  .mi_en(mi_en),                                  // input wire mi_en
  .mi_we(mi_we),                                  // input wire mi_we
  .mi_addr(mi_addr),                              // input wire [11 : 0] mi_addr
  .mi_din(mi_din),                                // input wire [31 : 0] mi_din
  .hw_reset(hw_reset),                            // input wire hw_reset
  .ecfg_datain(ecfg_datain)                      // input wire [10 : 0] ecfg_datain
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

