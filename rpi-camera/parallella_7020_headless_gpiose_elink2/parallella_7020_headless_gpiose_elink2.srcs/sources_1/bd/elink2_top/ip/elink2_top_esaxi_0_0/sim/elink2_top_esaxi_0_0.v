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


// IP VLNV: adapteva.com:Adapteva:esaxi:1.0
// IP Revision: 6

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_esaxi_0_0 (
  emwr_wr_data,
  emwr_wr_en,
  emwr_full,
  emwr_prog_full,
  emrq_wr_data,
  emrq_wr_en,
  emrq_full,
  emrq_prog_full,
  emrr_rd_data,
  emrr_rd_en,
  emrr_empty,
  ecfg_tx_ctrl_mode,
  ecfg_coreid,
  s00_axi_awid,
  s00_axi_awaddr,
  s00_axi_awlen,
  s00_axi_awsize,
  s00_axi_awburst,
  s00_axi_awlock,
  s00_axi_awcache,
  s00_axi_awprot,
  s00_axi_awregion,
  s00_axi_awqos,
  s00_axi_awvalid,
  s00_axi_awready,
  s00_axi_wdata,
  s00_axi_wstrb,
  s00_axi_wlast,
  s00_axi_wvalid,
  s00_axi_wready,
  s00_axi_bid,
  s00_axi_bresp,
  s00_axi_bvalid,
  s00_axi_bready,
  s00_axi_arid,
  s00_axi_araddr,
  s00_axi_arlen,
  s00_axi_arsize,
  s00_axi_arburst,
  s00_axi_arlock,
  s00_axi_arcache,
  s00_axi_arprot,
  s00_axi_arregion,
  s00_axi_arqos,
  s00_axi_arvalid,
  s00_axi_arready,
  s00_axi_rid,
  s00_axi_rdata,
  s00_axi_rresp,
  s00_axi_rlast,
  s00_axi_rvalid,
  s00_axi_rready,
  s00_axi_aclk,
  s00_axi_aresetn
);

(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr WR_DATA" *)
output wire [102 : 0] emwr_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr WR_EN" *)
output wire emwr_wr_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr FULL" *)
input wire emwr_full;
input wire emwr_prog_full;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq WR_DATA" *)
output wire [102 : 0] emrq_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq WR_EN" *)
output wire emrq_wr_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq FULL" *)
input wire emrq_full;
input wire emrq_prog_full;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr RD_DATA" *)
input wire [102 : 0] emrr_rd_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr RD_EN" *)
output wire emrr_rd_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_read:1.0 emrr EMPTY" *)
input wire emrr_empty;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg tx_ctrl_mode" *)
input wire [3 : 0] ecfg_tx_ctrl_mode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg coreid" *)
input wire [11 : 0] ecfg_coreid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWID" *)
input wire [11 : 0] s00_axi_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWADDR" *)
input wire [29 : 0] s00_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWLEN" *)
input wire [7 : 0] s00_axi_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWSIZE" *)
input wire [2 : 0] s00_axi_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWBURST" *)
input wire [1 : 0] s00_axi_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWLOCK" *)
input wire s00_axi_awlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWCACHE" *)
input wire [3 : 0] s00_axi_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWPROT" *)
input wire [2 : 0] s00_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWREGION" *)
input wire [3 : 0] s00_axi_awregion;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWQOS" *)
input wire [3 : 0] s00_axi_awqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWVALID" *)
input wire s00_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWREADY" *)
output wire s00_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WDATA" *)
input wire [31 : 0] s00_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WSTRB" *)
input wire [3 : 0] s00_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WLAST" *)
input wire s00_axi_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WVALID" *)
input wire s00_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WREADY" *)
output wire s00_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BID" *)
output wire [11 : 0] s00_axi_bid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BRESP" *)
output wire [1 : 0] s00_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BVALID" *)
output wire s00_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BREADY" *)
input wire s00_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARID" *)
input wire [11 : 0] s00_axi_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARADDR" *)
input wire [29 : 0] s00_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARLEN" *)
input wire [7 : 0] s00_axi_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARSIZE" *)
input wire [2 : 0] s00_axi_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARBURST" *)
input wire [1 : 0] s00_axi_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARLOCK" *)
input wire s00_axi_arlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARCACHE" *)
input wire [3 : 0] s00_axi_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARPROT" *)
input wire [2 : 0] s00_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARREGION" *)
input wire [3 : 0] s00_axi_arregion;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARQOS" *)
input wire [3 : 0] s00_axi_arqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARVALID" *)
input wire s00_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARREADY" *)
output wire s00_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RID" *)
output wire [11 : 0] s00_axi_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RDATA" *)
output wire [31 : 0] s00_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RRESP" *)
output wire [1 : 0] s00_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RLAST" *)
output wire s00_axi_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RVALID" *)
output wire s00_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RREADY" *)
input wire s00_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S00_AXI_CLK CLK" *)
input wire s00_axi_aclk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S00_AXI_RST RST" *)
input wire s00_axi_aresetn;

  esaxi_v1_0 #(
    .C_S00_AXI_ID_WIDTH(12),  // Width of ID for for write address, write data, read address and read data
    .C_S00_AXI_DATA_WIDTH(32),  // Width of S_AXI data bus
    .C_S00_AXI_ADDR_WIDTH(30),  // Width of S_AXI address bus
    .C_S00_AXI_AWUSER_WIDTH(1),  // Width of optional user defined signal in write address channel
    .C_S00_AXI_ARUSER_WIDTH(1),  // Width of optional user defined signal in read address channel
    .C_S00_AXI_WUSER_WIDTH(1),  // Width of optional user defined signal in write data channel
    .C_S00_AXI_RUSER_WIDTH(1),  // Width of optional user defined signal in read data channel
    .C_S00_AXI_BUSER_WIDTH(1),  // Width of optional user defined signal in write response channel
    .C_READ_TAG_ADDR(12'H810)
  ) inst (
    .emwr_wr_data(emwr_wr_data),
    .emwr_wr_en(emwr_wr_en),
    .emwr_full(emwr_full),
    .emwr_prog_full(emwr_prog_full),
    .emrq_wr_data(emrq_wr_data),
    .emrq_wr_en(emrq_wr_en),
    .emrq_full(emrq_full),
    .emrq_prog_full(emrq_prog_full),
    .emrr_rd_data(emrr_rd_data),
    .emrr_rd_en(emrr_rd_en),
    .emrr_empty(emrr_empty),
    .ecfg_tx_ctrl_mode(ecfg_tx_ctrl_mode),
    .ecfg_coreid(ecfg_coreid),
    .s00_axi_awid(s00_axi_awid),
    .s00_axi_awaddr(s00_axi_awaddr),
    .s00_axi_awlen(s00_axi_awlen),
    .s00_axi_awsize(s00_axi_awsize),
    .s00_axi_awburst(s00_axi_awburst),
    .s00_axi_awlock(s00_axi_awlock),
    .s00_axi_awcache(s00_axi_awcache),
    .s00_axi_awprot(s00_axi_awprot),
    .s00_axi_awregion(s00_axi_awregion),
    .s00_axi_awqos(s00_axi_awqos),
    .s00_axi_awuser(1'B0),
    .s00_axi_awvalid(s00_axi_awvalid),
    .s00_axi_awready(s00_axi_awready),
    .s00_axi_wdata(s00_axi_wdata),
    .s00_axi_wstrb(s00_axi_wstrb),
    .s00_axi_wlast(s00_axi_wlast),
    .s00_axi_wuser(1'B0),
    .s00_axi_wvalid(s00_axi_wvalid),
    .s00_axi_wready(s00_axi_wready),
    .s00_axi_bid(s00_axi_bid),
    .s00_axi_bresp(s00_axi_bresp),
    .s00_axi_buser(),
    .s00_axi_bvalid(s00_axi_bvalid),
    .s00_axi_bready(s00_axi_bready),
    .s00_axi_arid(s00_axi_arid),
    .s00_axi_araddr(s00_axi_araddr),
    .s00_axi_arlen(s00_axi_arlen),
    .s00_axi_arsize(s00_axi_arsize),
    .s00_axi_arburst(s00_axi_arburst),
    .s00_axi_arlock(s00_axi_arlock),
    .s00_axi_arcache(s00_axi_arcache),
    .s00_axi_arprot(s00_axi_arprot),
    .s00_axi_arregion(s00_axi_arregion),
    .s00_axi_arqos(s00_axi_arqos),
    .s00_axi_aruser(1'B0),
    .s00_axi_arvalid(s00_axi_arvalid),
    .s00_axi_arready(s00_axi_arready),
    .s00_axi_rid(s00_axi_rid),
    .s00_axi_rdata(s00_axi_rdata),
    .s00_axi_rresp(s00_axi_rresp),
    .s00_axi_rlast(s00_axi_rlast),
    .s00_axi_ruser(),
    .s00_axi_rvalid(s00_axi_rvalid),
    .s00_axi_rready(s00_axi_rready),
    .s00_axi_aclk(s00_axi_aclk),
    .s00_axi_aresetn(s00_axi_aresetn)
  );
endmodule
