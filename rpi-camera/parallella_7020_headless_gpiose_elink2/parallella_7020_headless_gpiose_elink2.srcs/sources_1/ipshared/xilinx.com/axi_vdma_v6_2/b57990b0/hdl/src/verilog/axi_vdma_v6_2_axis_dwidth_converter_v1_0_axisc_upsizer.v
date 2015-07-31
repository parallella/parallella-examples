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
// axisc_downsizer
//   Convert from SI data width < MI datawidth.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module axi_vdma_v6_2_axis_dwidth_converter_v1_0_axisc_upsizer #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY             = "virtex7",
   parameter integer C_S_AXIS_TDATA_WIDTH = 32,
   parameter integer C_M_AXIS_TDATA_WIDTH = 96,
   parameter integer C_AXIS_TID_WIDTH     = 1,
   parameter integer C_AXIS_TDEST_WIDTH   = 1,
   parameter integer C_S_AXIS_TUSER_WIDTH = 1,
   parameter integer C_M_AXIS_TUSER_WIDTH = 3,
   parameter [31:0]  C_AXIS_SIGNAL_SET    = 32'hFF ,
   // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
   //   [0] => TREADY present
   //   [1] => TDATA present
   //   [2] => TSTRB present, TDATA must be present
   //   [3] => TKEEP present, TDATA must be present
   //   [4] => TLAST present
   //   [5] => TID present
   //   [6] => TDEST present
   //   [7] => TUSER present
   parameter integer C_RATIO = 3   // Should always be 1:C_RATIO (upsizer)
   )
  (
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire ACLK,
   input wire ARESET,
   input wire ACLKEN,

   // Slave side
   input  wire                              S_AXIS_TVALID,
   output wire                              S_AXIS_TREADY,
   input  wire [C_S_AXIS_TDATA_WIDTH-1:0]   S_AXIS_TDATA,
   input  wire [C_S_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TSTRB,
   input  wire [C_S_AXIS_TDATA_WIDTH/8-1:0] S_AXIS_TKEEP,
   input  wire                              S_AXIS_TLAST,
   input  wire [C_AXIS_TID_WIDTH-1:0]       S_AXIS_TID,
   input  wire [C_AXIS_TDEST_WIDTH-1:0]     S_AXIS_TDEST,
   input  wire [C_S_AXIS_TUSER_WIDTH-1:0]   S_AXIS_TUSER,

   // Master side
   output wire                              M_AXIS_TVALID,
   input  wire                              M_AXIS_TREADY,
   output wire [C_M_AXIS_TDATA_WIDTH-1:0]   M_AXIS_TDATA,
   output wire [C_M_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TSTRB,
   output wire [C_M_AXIS_TDATA_WIDTH/8-1:0] M_AXIS_TKEEP,
   output wire                              M_AXIS_TLAST,
   output wire [C_AXIS_TID_WIDTH-1:0]       M_AXIS_TID,
   output wire [C_AXIS_TDEST_WIDTH-1:0]     M_AXIS_TDEST,
   output wire [C_M_AXIS_TUSER_WIDTH-1:0]   M_AXIS_TUSER
   );

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
`include "axi_vdma_v6_2_axis_infrastructure_v1_0_axis_infrastructure.vh"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam P_READY_EXIST = C_AXIS_SIGNAL_SET[0];
localparam P_DATA_EXIST  = C_AXIS_SIGNAL_SET[1];
localparam P_STRB_EXIST  = C_AXIS_SIGNAL_SET[2];
localparam P_KEEP_EXIST  = C_AXIS_SIGNAL_SET[3];
localparam P_LAST_EXIST  = C_AXIS_SIGNAL_SET[4];
localparam P_ID_EXIST    = C_AXIS_SIGNAL_SET[5];
localparam P_DEST_EXIST  = C_AXIS_SIGNAL_SET[6];
localparam P_USER_EXIST  = C_AXIS_SIGNAL_SET[7];
localparam P_S_AXIS_TSTRB_WIDTH = C_S_AXIS_TDATA_WIDTH/8;
localparam P_M_AXIS_TSTRB_WIDTH = C_M_AXIS_TDATA_WIDTH/8;

// State Machine possible states. Bits 1:0 used to encode output signals.
//                                     /--- M_AXIS_TVALID state
//                                     |/-- S_AXIS_TREADY state
localparam SM_RESET              = 3'b000; // De-assert Ready during reset
localparam SM_IDLE               = 3'b001; // R0 reg is empty
localparam SM_ACTIVE             = 3'b101; // R0 reg is active
localparam SM_END                = 3'b011; // R0 reg is empty and ACC reg is active
localparam SM_END_TO_ACTIVE      = 3'b010; // R0/ACC reg are both active.

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
reg  [2:0]                      state;

reg  [C_M_AXIS_TDATA_WIDTH-1:0] acc_data;
reg  [P_M_AXIS_TSTRB_WIDTH-1:0] acc_strb;
reg  [P_M_AXIS_TSTRB_WIDTH-1:0] acc_keep;
reg                             acc_last;
reg  [C_AXIS_TID_WIDTH-1:0]     acc_id;
reg  [C_AXIS_TDEST_WIDTH-1:0]   acc_dest;
reg  [C_M_AXIS_TUSER_WIDTH-1:0] acc_user;

wire [C_RATIO-1:0]              acc_reg_en;
reg  [C_RATIO-1:0]              r0_reg_sel;
wire                            next_xfer_is_end;

reg  [C_S_AXIS_TDATA_WIDTH-1:0] r0_data;
reg  [P_S_AXIS_TSTRB_WIDTH-1:0] r0_strb;
reg  [P_S_AXIS_TSTRB_WIDTH-1:0] r0_keep;
reg                             r0_last;
reg  [C_AXIS_TID_WIDTH-1:0]     r0_id;
reg  [C_AXIS_TDEST_WIDTH-1:0]   r0_dest;
reg  [C_S_AXIS_TUSER_WIDTH-1:0] r0_user;

wire                            id_match;
wire                            dest_match;
wire                            id_dest_mismatch;

////////////////////////////////////////////////////////////////////////////////
// BEGIN RTL
////////////////////////////////////////////////////////////////////////////////

// S Ready/M Valid outputs are encoded in the current state.
assign S_AXIS_TREADY = state[0];
assign M_AXIS_TVALID = state[1];

// State machine controls M_AXIS_TVALID and S_AXIS_TREADY, and loading
always @(posedge ACLK) begin
  if (ARESET) begin
    state <= SM_RESET;
  end else if (ACLKEN) begin
    case (state)
      SM_RESET: begin
        state <= SM_IDLE;
      end
      
      SM_IDLE: begin
        if (S_AXIS_TVALID & id_dest_mismatch & ~r0_reg_sel[0]) begin
          state <= SM_END_TO_ACTIVE;
        end
        else if (S_AXIS_TVALID & next_xfer_is_end) begin
          state <= SM_END;
        end
        else if (S_AXIS_TVALID) begin
          state <= SM_ACTIVE;
        end
        else begin
          state <= SM_IDLE;
        end
      end

      SM_ACTIVE: begin 
        if (S_AXIS_TVALID & (id_dest_mismatch | r0_last)) begin
          state <= SM_END_TO_ACTIVE;
        end
        else if ((~S_AXIS_TVALID & r0_last) | (S_AXIS_TVALID & next_xfer_is_end)) begin
          state <= SM_END;
        end
        else if (S_AXIS_TVALID & ~next_xfer_is_end) begin
          state <= SM_ACTIVE;
        end
        else begin 
          state <= SM_IDLE;
        end
      end

      SM_END: begin
        if (M_AXIS_TREADY & S_AXIS_TVALID) begin
          state <= SM_ACTIVE;
        end
        else if ( ~M_AXIS_TREADY & S_AXIS_TVALID) begin
          state <= SM_END_TO_ACTIVE;
        end
        else if ( M_AXIS_TREADY & ~S_AXIS_TVALID) begin 
          state <= SM_IDLE;
        end
        else begin
          state <= SM_END;
        end
      end

      SM_END_TO_ACTIVE: begin
        if (M_AXIS_TREADY) begin
          state <= SM_ACTIVE;
        end
        else begin
          state <= SM_END_TO_ACTIVE;
        end
      end

      default: begin
        state <= SM_IDLE;
      end

    endcase // case (state)
  end
end 


assign M_AXIS_TDATA = acc_data;
assign M_AXIS_TSTRB = acc_strb;
assign M_AXIS_TKEEP = acc_keep;
assign M_AXIS_TUSER = acc_user;

generate 
  genvar i;
  // DATA/USER/STRB/KEEP accumulators
  always @(posedge ACLK) begin
    if (ACLKEN) begin
      acc_data[0*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH] <= acc_reg_en[0] ? r0_data
        : acc_data[0*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH];
      acc_user[0*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH] <= acc_reg_en[0] ? r0_user
        : acc_user[0*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH];
      acc_strb[0*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= acc_reg_en[0] ? r0_strb
        : acc_strb[0*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
      acc_keep[0*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= acc_reg_en[0] ? r0_keep
        : acc_keep[0*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
    end
  end
  for (i = 1; i < C_RATIO-1; i = i + 1) begin : gen_data_accumulator
    always @(posedge ACLK) begin
      if (ACLKEN) begin
        acc_data[i*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH] <= acc_reg_en[i] ? r0_data
          : acc_data[i*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH];
        acc_user[i*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH] <= acc_reg_en[i] ? r0_user
          : acc_user[i*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH];
        acc_strb[i*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= acc_reg_en[0] ? {P_S_AXIS_TSTRB_WIDTH{1'b0}} 
          : acc_reg_en[i] ? r0_strb : acc_strb[i*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
        acc_keep[i*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= acc_reg_en[0] ? {P_S_AXIS_TSTRB_WIDTH{1'b0}} 
          : acc_reg_en[i] ? r0_keep : acc_keep[i*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
      end
    end
  end
  always @(posedge ACLK) begin
    if (ACLKEN) begin
      acc_data[(C_RATIO-1)*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH] <= (state == SM_IDLE) | (state == SM_ACTIVE) 
        ? S_AXIS_TDATA : acc_data[(C_RATIO-1)*C_S_AXIS_TDATA_WIDTH+:C_S_AXIS_TDATA_WIDTH];
      acc_user[(C_RATIO-1)*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH] <= (state == SM_IDLE) | (state == SM_ACTIVE) 
        ? S_AXIS_TUSER : acc_user[(C_RATIO-1)*C_S_AXIS_TUSER_WIDTH+:C_S_AXIS_TUSER_WIDTH];
      acc_strb[(C_RATIO-1)*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= (acc_reg_en[0] && C_RATIO > 2) | (state == SM_ACTIVE & r0_last) | (id_dest_mismatch & (state == SM_ACTIVE | state == SM_IDLE))
        ? {P_S_AXIS_TSTRB_WIDTH{1'b0}} : (state == SM_IDLE) | (state == SM_ACTIVE) 
        ? S_AXIS_TSTRB : acc_strb[(C_RATIO-1)*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
      acc_keep[(C_RATIO-1)*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH] <= (acc_reg_en[0] && C_RATIO > 2) | (state == SM_ACTIVE & r0_last) | (id_dest_mismatch & (state == SM_ACTIVE| state == SM_IDLE))
        ? {P_S_AXIS_TSTRB_WIDTH{1'b0}} : (state == SM_IDLE) | (state == SM_ACTIVE) 
        ? S_AXIS_TKEEP : acc_keep[(C_RATIO-1)*P_S_AXIS_TSTRB_WIDTH+:P_S_AXIS_TSTRB_WIDTH];
    end
  end

endgenerate

assign acc_reg_en = (state == SM_ACTIVE) ? r0_reg_sel : {C_RATIO{1'b0}};

// Accumulator selector (1 hot left barrel shifter)
always @(posedge ACLK) begin
  if (ARESET) begin
    r0_reg_sel[0] <= 1'b1;
    r0_reg_sel[1+:C_RATIO-1] <= {C_RATIO{1'b0}};
  end else if (ACLKEN) begin
    r0_reg_sel[0]            <= M_AXIS_TVALID & M_AXIS_TREADY ? 1'b1              
        : (state == SM_ACTIVE) ? 1'b0 : r0_reg_sel[0];
    r0_reg_sel[1+:C_RATIO-1] <= M_AXIS_TVALID & M_AXIS_TREADY ? {C_RATIO-1{1'b0}} 
        : (state == SM_ACTIVE) ? r0_reg_sel[0+:C_RATIO-1] : r0_reg_sel[1+:C_RATIO-1];
  end
end

assign next_xfer_is_end  = (r0_reg_sel[C_RATIO-2] && (state == SM_ACTIVE)) | r0_reg_sel[C_RATIO-1];

always @(posedge ACLK) begin 
  if (ACLKEN) begin
    r0_data <= S_AXIS_TREADY ? S_AXIS_TDATA : r0_data;
    r0_strb <= S_AXIS_TREADY ? S_AXIS_TSTRB : r0_strb;
    r0_keep <= S_AXIS_TREADY ? S_AXIS_TKEEP : r0_keep;
    r0_last <= (!P_LAST_EXIST) ? 1'b0 : S_AXIS_TREADY ? S_AXIS_TLAST : r0_last;
    r0_id   <= (S_AXIS_TREADY & S_AXIS_TVALID) ? S_AXIS_TID   : r0_id;
    r0_dest <= (S_AXIS_TREADY & S_AXIS_TVALID) ? S_AXIS_TDEST : r0_dest;
    r0_user <= S_AXIS_TREADY ? S_AXIS_TUSER : r0_user;
  end
end

assign M_AXIS_TLAST = acc_last;

always @(posedge ACLK) begin
  if (ACLKEN) begin
    acc_last <= (state == SM_END | state == SM_END_TO_ACTIVE) ? acc_last : 
                (state == SM_ACTIVE & r0_last ) ? 1'b1 :
                (id_dest_mismatch & (state == SM_IDLE)) ? 1'b0 : 
                (id_dest_mismatch & (state == SM_ACTIVE)) ? r0_last :
                 S_AXIS_TLAST;
  end
end

assign M_AXIS_TID   = acc_id;
assign M_AXIS_TDEST = acc_dest;

always @(posedge ACLK) begin
  if (ACLKEN) begin
    acc_id <= acc_reg_en[0] ? r0_id : acc_id;
    acc_dest <= acc_reg_en[0] ? r0_dest : acc_dest;
  end
end

assign id_match = P_ID_EXIST ? (S_AXIS_TID == r0_id) : 1'b1;
assign dest_match = P_DEST_EXIST ?  (S_AXIS_TDEST == r0_dest) : 1'b1;

assign id_dest_mismatch = (~id_match | ~dest_match) ? 1'b1 : 1'b0;

endmodule // axisc_upsizer

`default_nettype wire
