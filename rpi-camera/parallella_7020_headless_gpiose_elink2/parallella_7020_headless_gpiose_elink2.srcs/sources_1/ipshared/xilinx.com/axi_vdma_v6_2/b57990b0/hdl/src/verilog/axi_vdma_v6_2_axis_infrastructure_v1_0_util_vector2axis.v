//  (c) Copyright 2011-2013 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES. 
//-----------------------------------------------------------------------------
//
// axis to vector
//   A generic module to unmerge all axis 'data' signals from payload.
//   This is strictly wires, so no clk, reset, aclken, valid/ready are required.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axis_infrastructure_v1_0_util_vector2axis
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module axi_vdma_v6_2_axis_infrastructure_v1_0_util_vector2axis #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter integer C_TDATA_WIDTH = 32,
   parameter integer C_TID_WIDTH   = 1,
   parameter integer C_TDEST_WIDTH = 1,
   parameter integer C_TUSER_WIDTH = 1,
   parameter integer C_TPAYLOAD_WIDTH = 44,
   parameter [31:0]  C_SIGNAL_SET  = 32'hFF
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   )
  (
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // outputs
   input  wire [C_TPAYLOAD_WIDTH-1:0] TPAYLOAD,

   // inputs
   output wire [C_TDATA_WIDTH-1:0]   TDATA,
   output wire [C_TDATA_WIDTH/8-1:0] TSTRB,
   output wire [C_TDATA_WIDTH/8-1:0] TKEEP,
   output wire                       TLAST,
   output wire [C_TID_WIDTH-1:0]     TID,
   output wire [C_TDEST_WIDTH-1:0]   TDEST,
   output wire [C_TUSER_WIDTH-1:0]   TUSER
   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axi_vdma_v6_2_axis_infrastructure_v1_0_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_TDATA_INDX = f_get_tdata_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TSTRB_INDX = f_get_tstrb_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TKEEP_INDX = f_get_tkeep_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TLAST_INDX = f_get_tlast_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TID_INDX   = f_get_tid_indx  (C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TDEST_INDX = f_get_tdest_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
localparam P_TUSER_INDX = f_get_tuser_indx(C_TDATA_WIDTH, C_TID_WIDTH,
                                           C_TDEST_WIDTH, C_TUSER_WIDTH, 
                                           C_SIGNAL_SET);
////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////
generate
  if (C_SIGNAL_SET[G_INDX_SS_TDATA]) begin : gen_tdata
    assign TDATA = TPAYLOAD[P_TDATA_INDX+:C_TDATA_WIDTH]  ;
  end
  if (C_SIGNAL_SET[G_INDX_SS_TSTRB]) begin : gen_tstrb
    assign TSTRB = TPAYLOAD[P_TSTRB_INDX+:C_TDATA_WIDTH/8];
  end
  if (C_SIGNAL_SET[G_INDX_SS_TKEEP]) begin : gen_tkeep
    assign TKEEP = TPAYLOAD[P_TKEEP_INDX+:C_TDATA_WIDTH/8];
  end
  if (C_SIGNAL_SET[G_INDX_SS_TLAST]) begin : gen_tlast
    assign TLAST = TPAYLOAD[P_TLAST_INDX+:1]              ;
  end
  if (C_SIGNAL_SET[G_INDX_SS_TID]) begin : gen_tid
    assign TID   = TPAYLOAD[P_TID_INDX+:C_TID_WIDTH]      ;
  end
  if (C_SIGNAL_SET[G_INDX_SS_TDEST]) begin : gen_tdest
    assign TDEST = TPAYLOAD[P_TDEST_INDX+:C_TDEST_WIDTH]  ;
  end
  if (C_SIGNAL_SET[G_INDX_SS_TUSER]) begin : gen_tuser
    assign TUSER = TPAYLOAD[P_TUSER_INDX+:C_TUSER_WIDTH]  ;
  end
endgenerate
endmodule 

`default_nettype wire
