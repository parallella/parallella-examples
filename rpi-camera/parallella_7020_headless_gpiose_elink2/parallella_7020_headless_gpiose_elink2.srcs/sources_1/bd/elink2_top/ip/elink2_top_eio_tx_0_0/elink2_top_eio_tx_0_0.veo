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

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
elink2_top_eio_tx_0_0 your_instance_name (
  .TX_LCLK_P(TX_LCLK_P),                  // output wire TX_LCLK_P
  .TX_LCLK_N(TX_LCLK_N),                  // output wire TX_LCLK_N
  .reset(reset),                          // input wire reset
  .ioreset(ioreset),                      // input wire ioreset
  .TX_FRAME_P(TX_FRAME_P),                // output wire TX_FRAME_P
  .TX_FRAME_N(TX_FRAME_N),                // output wire TX_FRAME_N
  .TX_DATA_P(TX_DATA_P),                  // output wire [7 : 0] TX_DATA_P
  .TX_DATA_N(TX_DATA_N),                  // output wire [7 : 0] TX_DATA_N
  .tx_wr_wait(tx_wr_wait),                // output wire tx_wr_wait
  .tx_rd_wait(tx_rd_wait),                // output wire tx_rd_wait
  .TX_WR_WAIT_P(TX_WR_WAIT_P),            // input wire TX_WR_WAIT_P
  .TX_WR_WAIT_N(TX_WR_WAIT_N),            // input wire TX_WR_WAIT_N
  .TX_RD_WAIT_P(TX_RD_WAIT_P),            // input wire TX_RD_WAIT_P
  .TX_RD_WAIT_N(TX_RD_WAIT_N),            // input wire TX_RD_WAIT_N
  .txlclk_p(txlclk_p),                    // input wire txlclk_p
  .txlclk_s(txlclk_s),                    // input wire txlclk_s
  .txlclk_out(txlclk_out),                // input wire txlclk_out
  .txframe_p(txframe_p),                  // input wire [7 : 0] txframe_p
  .txdata_p(txdata_p),                    // input wire [63 : 0] txdata_p
  .ecfg_tx_enable(ecfg_tx_enable),        // input wire ecfg_tx_enable
  .ecfg_tx_gpio_mode(ecfg_tx_gpio_mode),  // input wire ecfg_tx_gpio_mode
  .ecfg_tx_clkdiv(ecfg_tx_clkdiv),        // input wire [3 : 0] ecfg_tx_clkdiv
  .ecfg_dataout(ecfg_dataout)            // input wire [10 : 0] ecfg_dataout
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

