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

// IP VLNV: adapteva.com:Adapteva:emesh_split:1.0
// IP Revision: 2

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
elink2_top_emesh_split_0_0 your_instance_name (
  .ems_rd_wait(ems_rd_wait),      // output wire ems_rd_wait
  .ems_wr_wait(ems_wr_wait),      // output wire ems_wr_wait
  .emm0_access(emm0_access),      // output wire emm0_access
  .emm0_write(emm0_write),        // output wire emm0_write
  .emm0_datamode(emm0_datamode),  // output wire [1 : 0] emm0_datamode
  .emm0_ctrlmode(emm0_ctrlmode),  // output wire [3 : 0] emm0_ctrlmode
  .emm0_dstaddr(emm0_dstaddr),    // output wire [31 : 0] emm0_dstaddr
  .emm0_srcaddr(emm0_srcaddr),    // output wire [31 : 0] emm0_srcaddr
  .emm0_data(emm0_data),          // output wire [31 : 0] emm0_data
  .emm1_access(emm1_access),      // output wire emm1_access
  .emm1_write(emm1_write),        // output wire emm1_write
  .emm1_datamode(emm1_datamode),  // output wire [1 : 0] emm1_datamode
  .emm1_ctrlmode(emm1_ctrlmode),  // output wire [3 : 0] emm1_ctrlmode
  .emm1_dstaddr(emm1_dstaddr),    // output wire [31 : 0] emm1_dstaddr
  .emm1_srcaddr(emm1_srcaddr),    // output wire [31 : 0] emm1_srcaddr
  .emm1_data(emm1_data),          // output wire [31 : 0] emm1_data
  .ems_access(ems_access),        // input wire ems_access
  .ems_write(ems_write),          // input wire ems_write
  .ems_datamode(ems_datamode),    // input wire [1 : 0] ems_datamode
  .ems_ctrlmode(ems_ctrlmode),    // input wire [3 : 0] ems_ctrlmode
  .ems_dstaddr(ems_dstaddr),      // input wire [31 : 0] ems_dstaddr
  .ems_srcaddr(ems_srcaddr),      // input wire [31 : 0] ems_srcaddr
  .ems_data(ems_data),            // input wire [31 : 0] ems_data
  .emm0_rd_wait(emm0_rd_wait),    // input wire emm0_rd_wait
  .emm0_wr_wait(emm0_wr_wait)    // input wire emm0_wr_wait
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

