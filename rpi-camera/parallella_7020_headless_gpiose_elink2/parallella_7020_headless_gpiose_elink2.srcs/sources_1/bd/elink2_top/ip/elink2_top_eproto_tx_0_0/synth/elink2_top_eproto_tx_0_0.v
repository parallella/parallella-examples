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


// IP VLNV: adapteva.com:Adatpeva:eproto_tx:1.0
// IP Revision: 4

(* X_CORE_INFO = "eproto_tx,Vivado 2014.4" *)
(* CHECK_LICENSE_TYPE = "elink2_top_eproto_tx_0_0,eproto_tx,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_eproto_tx_0_0 (
  emtx_rd_wait,
  emtx_wr_wait,
  emtx_ack,
  txframe_p,
  txdata_p,
  reset,
  emtx_access,
  emtx_write,
  emtx_datamode,
  emtx_ctrlmode,
  emtx_dstaddr,
  emtx_srcaddr,
  emtx_data,
  txlclk_p,
  tx_rd_wait,
  tx_wr_wait
);

(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx rd_wait" *)
output wire emtx_rd_wait;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx wr_wait" *)
output wire emtx_wr_wait;
output wire emtx_ack;
output wire [7 : 0] txframe_p;
output wire [63 : 0] txdata_p;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire reset;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx access" *)
input wire emtx_access;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx write" *)
input wire emtx_write;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx datamode" *)
input wire [1 : 0] emtx_datamode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx ctrlmode" *)
input wire [3 : 0] emtx_ctrlmode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx dstaddr" *)
input wire [31 : 0] emtx_dstaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx srcaddr" *)
input wire [31 : 0] emtx_srcaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 emtx data" *)
input wire [31 : 0] emtx_data;
input wire txlclk_p;
input wire tx_rd_wait;
input wire tx_wr_wait;

  eproto_tx inst (
    .emtx_rd_wait(emtx_rd_wait),
    .emtx_wr_wait(emtx_wr_wait),
    .emtx_ack(emtx_ack),
    .txframe_p(txframe_p),
    .txdata_p(txdata_p),
    .reset(reset),
    .emtx_access(emtx_access),
    .emtx_write(emtx_write),
    .emtx_datamode(emtx_datamode),
    .emtx_ctrlmode(emtx_ctrlmode),
    .emtx_dstaddr(emtx_dstaddr),
    .emtx_srcaddr(emtx_srcaddr),
    .emtx_data(emtx_data),
    .txlclk_p(txlclk_p),
    .tx_rd_wait(tx_rd_wait),
    .tx_wr_wait(tx_wr_wait)
  );
endmodule
