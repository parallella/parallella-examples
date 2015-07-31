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


// IP VLNV: adapteva.com:Adapteva:earb:1.0
// IP Revision: 4

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_earb_0_0 (
  emwr_empty,
  emrq_rd_en,
  emrr_rd_en,
  emm_tx_access,
  emm_tx_write,
  emm_tx_datamode,
  emm_tx_ctrlmode,
  emm_tx_dstaddr,
  emm_tx_srcaddr,
  emm_tx_data,
  clock,
  reset,
  emwr_rd_data,
  emrq_rd_data,
  emwr_rd_en,
  emrq_empty,
  emrr_rd_data,
  emrr_empty,
  emm_tx_rd_wait,
  emm_tx_wr_wait,
  emtx_ack
);

(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emwr EMPTY" *)
input wire emwr_empty;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrq RD_EN" *)
output wire emrq_rd_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr RD_EN" *)
output wire emrr_rd_en;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx access" *)
output wire emm_tx_access;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx write" *)
output wire emm_tx_write;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx datamode" *)
output wire [1 : 0] emm_tx_datamode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx ctrlmode" *)
output wire [3 : 0] emm_tx_ctrlmode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx dstaddr" *)
output wire [31 : 0] emm_tx_dstaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx srcaddr" *)
output wire [31 : 0] emm_tx_srcaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx data" *)
output wire [31 : 0] emm_tx_data;
input wire clock;
input wire reset;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emwr RD_DATA" *)
input wire [102 : 0] emwr_rd_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrq RD_DATA" *)
input wire [102 : 0] emrq_rd_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emwr RD_EN" *)
output wire emwr_rd_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrq EMPTY" *)
input wire emrq_empty;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr RD_DATA" *)
input wire [102 : 0] emrr_rd_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr EMPTY" *)
input wire emrr_empty;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx rd_wait" *)
input wire emm_tx_rd_wait;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emm_tx wr_wait" *)
input wire emm_tx_wr_wait;
input wire emtx_ack;

  earb inst (
    .emwr_empty(emwr_empty),
    .emrq_rd_en(emrq_rd_en),
    .emrr_rd_en(emrr_rd_en),
    .emm_tx_access(emm_tx_access),
    .emm_tx_write(emm_tx_write),
    .emm_tx_datamode(emm_tx_datamode),
    .emm_tx_ctrlmode(emm_tx_ctrlmode),
    .emm_tx_dstaddr(emm_tx_dstaddr),
    .emm_tx_srcaddr(emm_tx_srcaddr),
    .emm_tx_data(emm_tx_data),
    .clock(clock),
    .reset(reset),
    .emwr_rd_data(emwr_rd_data),
    .emrq_rd_data(emrq_rd_data),
    .emwr_rd_en(emwr_rd_en),
    .emrq_empty(emrq_empty),
    .emrr_rd_data(emrr_rd_data),
    .emrr_empty(emrr_empty),
    .emm_tx_rd_wait(emm_tx_rd_wait),
    .emm_tx_wr_wait(emm_tx_wr_wait),
    .emtx_ack(emtx_ack)
  );
endmodule
