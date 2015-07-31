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
//   Convert from SI data width > MI datawidth.
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
module axi_vdma_v6_2_axis_dwidth_converter_v1_0_axisc_downsizer #
(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
   parameter         C_FAMILY             = "virtex7",
   parameter integer C_S_AXIS_TDATA_WIDTH = 96,
   parameter integer C_M_AXIS_TDATA_WIDTH = 32,
   parameter integer C_AXIS_TID_WIDTH     = 1,
   parameter integer C_AXIS_TDEST_WIDTH   = 1,
   parameter integer C_S_AXIS_TUSER_WIDTH = 3,
   parameter integer C_M_AXIS_TUSER_WIDTH = 1,
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
   parameter integer C_RATIO = 3   // Should always be C_RATIO:1 (downsizer)
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
localparam P_S_AXIS_TSTRB_WIDTH = C_S_AXIS_TDATA_WIDTH/8;
localparam P_M_AXIS_TSTRB_WIDTH = C_M_AXIS_TDATA_WIDTH/8;
localparam P_RATIO_WIDTH = f_clogb2(C_RATIO);
// State Machine possible states.
localparam SM_RESET          = 3'b000;
localparam SM_IDLE           = 3'b001;
localparam SM_ACTIVE         = 3'b010;
localparam SM_END           = 3'b011;
localparam SM_END_TO_ACTIVE = 3'b110;

////////////////////////////////////////////////////////////////////////////////
// Wires/Reg declarations
////////////////////////////////////////////////////////////////////////////////
reg    [2:0]                    state;

wire [C_RATIO-1:0]              is_null;
wire [C_RATIO-1:0]              r0_is_end;

wire [C_M_AXIS_TDATA_WIDTH-1:0] data_out; 
wire [P_M_AXIS_TSTRB_WIDTH-1:0] strb_out;
wire [P_M_AXIS_TSTRB_WIDTH-1:0] keep_out;
wire                            last_out;
wire [C_AXIS_TID_WIDTH-1:0]     id_out;
wire [C_AXIS_TDEST_WIDTH-1:0]   dest_out;
wire [C_M_AXIS_TUSER_WIDTH-1:0] user_out;

reg  [C_S_AXIS_TDATA_WIDTH-1:0] r0_data;
reg  [P_S_AXIS_TSTRB_WIDTH-1:0] r0_strb;
reg  [P_S_AXIS_TSTRB_WIDTH-1:0] r0_keep;
reg                             r0_last;
reg  [C_AXIS_TID_WIDTH-1:0]     r0_id;
reg  [C_AXIS_TDEST_WIDTH-1:0]   r0_dest;
reg  [C_S_AXIS_TUSER_WIDTH-1:0] r0_user;
reg  [C_RATIO-1:0]              r0_is_null_r;

wire                            r0_load;

reg  [C_M_AXIS_TDATA_WIDTH-1:0] r1_data;
reg  [P_M_AXIS_TSTRB_WIDTH-1:0] r1_strb;
reg  [P_M_AXIS_TSTRB_WIDTH-1:0] r1_keep;
reg                             r1_last;
reg  [C_AXIS_TID_WIDTH-1:0]     r1_id;
reg  [C_AXIS_TDEST_WIDTH-1:0]   r1_dest;
reg  [C_M_AXIS_TUSER_WIDTH-1:0] r1_user;

wire                            r1_load;

reg  [P_RATIO_WIDTH-1:0]        r0_out_sel_r;
wire [P_RATIO_WIDTH-1:0]        r0_out_sel_ns;
wire                            sel_adv;
reg  [P_RATIO_WIDTH-1:0]        r0_out_sel_next_r;
wire [P_RATIO_WIDTH-1:0]        r0_out_sel_next_ns;
reg                             xfer_is_end;
reg                             next_xfer_is_end;

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
      
      // No transactions
      SM_IDLE: begin
        if (S_AXIS_TVALID) begin
          state <= SM_ACTIVE;
        end
        else begin
          state <= SM_IDLE;
        end
      end

      // Active entry in holding register r0
      SM_ACTIVE: begin
        if (M_AXIS_TREADY & r0_is_end[0]) begin
          state <= SM_IDLE;
        end
        else if (M_AXIS_TREADY & next_xfer_is_end) begin
          state <= SM_END;
        end
        else begin
          state <= SM_ACTIVE;
        end
      end

      // Entry in last transfer register r1.
      SM_END: begin
        if (M_AXIS_TREADY & S_AXIS_TVALID) begin
          state <= SM_ACTIVE;
        end
        else if (M_AXIS_TREADY & ~S_AXIS_TVALID) begin
          state <= SM_IDLE;
        end
        else if (~M_AXIS_TREADY & S_AXIS_TVALID) begin
          state <= SM_END_TO_ACTIVE;
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

// Algorithm to figure out which beat is the last non-null transfer. Split into 2 steps.
// 1) Figuring out which output transfers are null before storing in r0.
//    (cycle steal to reduce critical path).
// 2) For transfer X, if transfer X+1 to transfer C_RATIO-1 is null, then transfer
//    X is the new END transfer for the split. Transfer C_RATIO-1 is always marked
//    as END.
genvar i; 
generate
  if (C_AXIS_SIGNAL_SET[G_INDX_SS_TKEEP]) begin : gen_tkeep_is_enabled
    for (i = 0; i < C_RATIO-1; i = i + 1) begin : gen_is_null 
      // 1)
      assign is_null[i] = ~(|S_AXIS_TKEEP[i*P_M_AXIS_TSTRB_WIDTH +: P_M_AXIS_TSTRB_WIDTH]);
      // 2)
      assign r0_is_end[i] =  (&r0_is_null_r[C_RATIO-1:i+1]);
    end
    assign is_null[C_RATIO-1] = ~(|S_AXIS_TKEEP[(C_RATIO-1)*P_M_AXIS_TSTRB_WIDTH +: P_M_AXIS_TSTRB_WIDTH]);
    assign r0_is_end[C_RATIO-1] = 1'b1;
  end
  else begin : gen_tkeep_is_disabled
    assign is_null = {C_RATIO{1'b0}};
    assign r0_is_end = {1'b1, {C_RATIO-1{1'b0}}};
  end
endgenerate

assign M_AXIS_TDATA = data_out[0+:C_M_AXIS_TDATA_WIDTH];
assign M_AXIS_TSTRB = strb_out[0+:P_M_AXIS_TSTRB_WIDTH];
assign M_AXIS_TKEEP = keep_out[0+:P_M_AXIS_TSTRB_WIDTH];
assign M_AXIS_TLAST = last_out;
assign M_AXIS_TID   = id_out[0+:C_AXIS_TID_WIDTH];
assign M_AXIS_TDEST = dest_out[0+:C_AXIS_TDEST_WIDTH];
assign M_AXIS_TUSER = user_out[0+:C_M_AXIS_TUSER_WIDTH];

// Select data output by shifting data right, upper most datum is always from r1
assign data_out = {r1_data, r0_data[0+:C_M_AXIS_TDATA_WIDTH*(C_RATIO-1)]} >> (C_M_AXIS_TDATA_WIDTH*r0_out_sel_r);
assign strb_out = {r1_strb, r0_strb[0+:P_M_AXIS_TSTRB_WIDTH*(C_RATIO-1)]} >> (P_M_AXIS_TSTRB_WIDTH*r0_out_sel_r);
assign keep_out = {r1_keep, r0_keep[0+:P_M_AXIS_TSTRB_WIDTH*(C_RATIO-1)]} >> (P_M_AXIS_TSTRB_WIDTH*r0_out_sel_r);
assign last_out = (state == SM_END || state == SM_END_TO_ACTIVE) ? r1_last : r0_last & r0_is_end[0];
assign id_out   = (state == SM_END || state == SM_END_TO_ACTIVE) ? r1_id : r0_id;
assign dest_out = (state == SM_END || state == SM_END_TO_ACTIVE) ? r1_dest : r0_dest;
assign user_out = {r1_user, r0_user[0+:C_M_AXIS_TUSER_WIDTH*(C_RATIO-1)]} >> (C_M_AXIS_TUSER_WIDTH*r0_out_sel_r);

// First register stores the incoming transfer.
always @(posedge ACLK) begin
  if (ACLKEN) begin
    r0_data    <= r0_load ? S_AXIS_TDATA : r0_data;
    r0_strb    <= r0_load ? S_AXIS_TSTRB : r0_strb;
    r0_keep    <= r0_load ? S_AXIS_TKEEP : r0_keep;
    r0_last    <= r0_load ? S_AXIS_TLAST : r0_last;
    r0_id      <= r0_load ? S_AXIS_TID   : r0_id  ;
    r0_dest    <= r0_load ? S_AXIS_TDEST : r0_dest;
    r0_user    <= r0_load ? S_AXIS_TUSER : r0_user;
  end
end

// r0_is_null_r must always be set to known values to avoid x propagations.
always @(posedge ACLK) begin
  if (ARESET) begin
    r0_is_null_r <= {C_RATIO{1'b0}};
  end
  else if (ACLKEN) begin
    r0_is_null_r <= r0_load & S_AXIS_TVALID ? is_null : r0_is_null_r;
  end
end

assign r0_load = (state == SM_IDLE) || (state == SM_END);
// Second register only stores a single slice of r0.
always @(posedge ACLK) begin
  if (ACLKEN) begin
    r1_data    <= r1_load ? r0_data >> (C_M_AXIS_TDATA_WIDTH*r0_out_sel_next_r) : r1_data;
    r1_strb    <= r1_load ? r0_strb >> (P_M_AXIS_TSTRB_WIDTH*r0_out_sel_next_r) : r1_strb;
    r1_keep    <= r1_load ? r0_keep >> (P_M_AXIS_TSTRB_WIDTH*r0_out_sel_next_r) : r1_keep;
    r1_last    <= r1_load ? r0_last : r1_last;
    r1_id      <= r1_load ? r0_id   : r1_id  ;
    r1_dest    <= r1_load ? r0_dest : r1_dest;
    r1_user    <= r1_load ? r0_user >> (C_M_AXIS_TUSER_WIDTH*r0_out_sel_next_r) : r1_user;
  end
end

assign r1_load = (state == SM_ACTIVE);

// Counter to select which datum to send.
always @(posedge ACLK) begin
  if (ARESET) begin
    r0_out_sel_r <= {P_RATIO_WIDTH{1'b0}};
  end else if (ACLKEN) begin
    r0_out_sel_r <= r0_out_sel_ns;
 end
end

assign r0_out_sel_ns = (xfer_is_end & sel_adv) || (state == SM_IDLE) ? {P_RATIO_WIDTH{1'b0}} 
                       : next_xfer_is_end & sel_adv ? C_RATIO[P_RATIO_WIDTH-1:0]-1'b1 
                       : sel_adv ? r0_out_sel_next_r : r0_out_sel_r; 

assign sel_adv = M_AXIS_TREADY;


// Count ahead to the next value
always @(posedge ACLK) begin
  if (ARESET) begin
    r0_out_sel_next_r <= {P_RATIO_WIDTH{1'b0}} + 1'b1;
  end else if (ACLKEN) begin
    r0_out_sel_next_r <= r0_out_sel_next_ns;
 end
end

assign r0_out_sel_next_ns = (xfer_is_end & sel_adv) || (state == SM_IDLE) ? {P_RATIO_WIDTH{1'b0}} + 1'b1
                            : ~next_xfer_is_end & sel_adv ? r0_out_sel_next_r + 1'b1
                            : r0_out_sel_next_r;

always @(*) begin
  xfer_is_end = r0_is_end[r0_out_sel_r];
end

always @(*) begin
  next_xfer_is_end = r0_is_end[r0_out_sel_next_r];
end

endmodule // axisc_downsizer

`default_nettype wire
