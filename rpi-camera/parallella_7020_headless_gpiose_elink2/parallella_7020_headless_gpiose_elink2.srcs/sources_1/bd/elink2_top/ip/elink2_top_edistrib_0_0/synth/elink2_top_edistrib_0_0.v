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


// IP VLNV: adapteva.com:Adapteva:edistrib:1.0
// IP Revision: 5

(* X_CORE_INFO = "edistrib,Vivado 2014.4" *)
(* CHECK_LICENSE_TYPE = "elink2_top_edistrib_0_0,edistrib,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module elink2_top_edistrib_0_0 (
  ems_dir_rd_wait,
  ems_dir_wr_wait,
  emwr_wr_data,
  emwr_wr_en,
  emrq_wr_data,
  emrq_wr_en,
  emrr_wr_data,
  emrr_wr_en,
  rxlclk,
  ems_dir_access,
  ems_dir_write,
  ems_dir_datamode,
  ems_dir_ctrlmode,
  ems_dir_dstaddr,
  ems_dir_srcaddr,
  ems_dir_data,
  ems_mmu_access,
  ems_mmu_write,
  ems_mmu_datamode,
  ems_mmu_ctrlmode,
  ems_mmu_dstaddr,
  ems_mmu_srcaddr,
  ems_mmu_data,
  emwr_full,
  emwr_prog_full,
  emrq_full,
  emrq_prog_full,
  emrr_full,
  emrr_prog_full,
  ecfg_rx_enable,
  ecfg_rx_mmu_mode
);

(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir rd_wait" *)
output wire ems_dir_rd_wait;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir wr_wait" *)
output wire ems_dir_wr_wait;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr WR_DATA" *)
output wire [102 : 0] emwr_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr WR_EN" *)
output wire emwr_wr_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq WR_DATA" *)
output wire [102 : 0] emrq_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq WR_EN" *)
output wire emrq_wr_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrr WR_DATA" *)
output wire [102 : 0] emrr_wr_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrr WR_EN" *)
output wire emrr_wr_en;
input wire rxlclk;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir access" *)
input wire ems_dir_access;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir write" *)
input wire ems_dir_write;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir datamode" *)
input wire [1 : 0] ems_dir_datamode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir ctrlmode" *)
input wire [3 : 0] ems_dir_ctrlmode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir dstaddr" *)
input wire [31 : 0] ems_dir_dstaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir srcaddr" *)
input wire [31 : 0] ems_dir_srcaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_dir data" *)
input wire [31 : 0] ems_dir_data;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu access" *)
input wire ems_mmu_access;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu write" *)
input wire ems_mmu_write;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu datamode" *)
input wire [1 : 0] ems_mmu_datamode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu ctrlmode" *)
input wire [3 : 0] ems_mmu_ctrlmode;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu dstaddr" *)
input wire [31 : 0] ems_mmu_dstaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu srcaddr" *)
input wire [31 : 0] ems_mmu_srcaddr;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eMesh:1.0 ems_mmu data" *)
input wire [31 : 0] ems_mmu_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emwr FULL" *)
input wire emwr_full;
input wire emwr_prog_full;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrq FULL" *)
input wire emrq_full;
input wire emrq_prog_full;
(* X_INTERFACE_INFO = "xilinx.com:interface:fifo_write:1.0 emrr FULL" *)
input wire emrr_full;
input wire emrr_prog_full;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg rx_enable" *)
input wire ecfg_rx_enable;
(* X_INTERFACE_INFO = "adapteva.com:Adapteva:eConfig:1.0 ecfg rx_mmu_mode" *)
input wire ecfg_rx_mmu_mode;

  edistrib #(
    .C_READ_TAG_ADDR(12'H810),
    .C_REMAP_BITS(7),
    .C_REMAP_ADDR(32'H3E000000)
  ) inst (
    .ems_dir_rd_wait(ems_dir_rd_wait),
    .ems_dir_wr_wait(ems_dir_wr_wait),
    .emwr_wr_data(emwr_wr_data),
    .emwr_wr_en(emwr_wr_en),
    .emrq_wr_data(emrq_wr_data),
    .emrq_wr_en(emrq_wr_en),
    .emrr_wr_data(emrr_wr_data),
    .emrr_wr_en(emrr_wr_en),
    .rxlclk(rxlclk),
    .ems_dir_access(ems_dir_access),
    .ems_dir_write(ems_dir_write),
    .ems_dir_datamode(ems_dir_datamode),
    .ems_dir_ctrlmode(ems_dir_ctrlmode),
    .ems_dir_dstaddr(ems_dir_dstaddr),
    .ems_dir_srcaddr(ems_dir_srcaddr),
    .ems_dir_data(ems_dir_data),
    .ems_mmu_access(ems_mmu_access),
    .ems_mmu_write(ems_mmu_write),
    .ems_mmu_datamode(ems_mmu_datamode),
    .ems_mmu_ctrlmode(ems_mmu_ctrlmode),
    .ems_mmu_dstaddr(ems_mmu_dstaddr),
    .ems_mmu_srcaddr(ems_mmu_srcaddr),
    .ems_mmu_data(ems_mmu_data),
    .emwr_full(emwr_full),
    .emwr_prog_full(emwr_prog_full),
    .emrq_full(emrq_full),
    .emrq_prog_full(emrq_prog_full),
    .emrr_full(emrr_full),
    .emrr_prog_full(emrr_prog_full),
    .ecfg_rx_enable(ecfg_rx_enable),
    .ecfg_rx_mmu_mode(ecfg_rx_mmu_mode)
  );
endmodule
