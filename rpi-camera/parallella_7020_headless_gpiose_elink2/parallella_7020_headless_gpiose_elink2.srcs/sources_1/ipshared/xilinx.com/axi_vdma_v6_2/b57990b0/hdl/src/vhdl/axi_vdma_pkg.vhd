-------------------------------------------------------------------------------
-- axi_vdma_pkg
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
--  (c) Copyright 2010-2011, 2013 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:          axi_vdma_pkg.vhd
-- Description: This package contains various constants and functions for
--              AXI VDMA operations.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_vdma.vhd
--                   |- axi_vdma_pkg.vhd
--                   |- axi_vdma_intrpt.vhd
--                   |- axi_vdma_rst_module.vhd
--                   |   |- axi_vdma_reset.vhd (mm2s)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |   |- axi_vdma_reset.vhd (s2mm)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |
--                   |- axi_vdma_reg_if.vhd
--                   |   |- axi_vdma_lite_if.vhd
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (mm2s)
--                   |- axi_vdma_vid_cdc.vhd (mm2s)
--                   |- axi_vdma_fsync_gen.vhd (mm2s)
--                   |- axi_vdma_sof_gen.vhd (mm2s)
--                   |- axi_vdma_reg_module.vhd (mm2s)
--                   |   |- axi_vdma_register.vhd (mm2s)
--                   |   |- axi_vdma_regdirect.vhd (mm2s)
--                   |- axi_vdma_mngr.vhd (mm2s)
--                   |   |- axi_vdma_sg_if.vhd (mm2s)
--                   |   |- axi_vdma_sm.vhd (mm2s)
--                   |   |- axi_vdma_cmdsts_if.vhd (mm2s)
--                   |   |- axi_vdma_vidreg_module.vhd (mm2s)
--                   |   |   |- axi_vdma_sgregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (mm2s)
--                   |   |   |- axi_vdma_blkmem.vhd (mm2s)
--                   |   |- axi_vdma_genlock_mngr.vhd (mm2s)
--                   |       |- axi_vdma_genlock_mux.vhd (mm2s)
--                   |       |- axi_vdma_greycoder.vhd (mm2s)
--                   |- axi_vdma_mm2s_linebuf.vhd (mm2s)
--                   |   |- axi_vdma_sfifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_afifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_skid_buf.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (s2mm)
--                   |- axi_vdma_vid_cdc.vhd (s2mm)
--                   |- axi_vdma_fsync_gen.vhd (s2mm)
--                   |- axi_vdma_sof_gen.vhd (s2mm)
--                   |- axi_vdma_reg_module.vhd (s2mm)
--                   |   |- axi_vdma_register.vhd (s2mm)
--                   |   |- axi_vdma_regdirect.vhd (s2mm)
--                   |- axi_vdma_mngr.vhd (s2mm)
--                   |   |- axi_vdma_sg_if.vhd (s2mm)
--                   |   |- axi_vdma_sm.vhd (s2mm)
--                   |   |- axi_vdma_cmdsts_if.vhd (s2mm)
--                   |   |- axi_vdma_vidreg_module.vhd (s2mm)
--                   |   |   |- axi_vdma_sgregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (s2mm)
--                   |   |   |- axi_vdma_blkmem.vhd (s2mm)
--                   |   |- axi_vdma_genlock_mngr.vhd (s2mm)
--                   |       |- axi_vdma_genlock_mux.vhd (s2mm)
--                   |       |- axi_vdma_greycoder.vhd (s2mm)
--                   |- axi_vdma_s2mm_linebuf.vhd (s2mm)
--                   |   |- axi_vdma_sfifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_afifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_skid_buf.vhd (s2mm)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_datamover_v3_00_a.axi_datamover.vhd (FULL)
--                   |- axi_sg_v3_00_a.axi_sg.vhd
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;

package axi_vdma_pkg is

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------
function enable_tkeep_connectivity (tdata_dwidth         : integer; tdata_width_calculated : integer; DRE_ON : integer)
            return  integer;




-- CALCULATE mm2s_tdata_width for axi_vdma
function calculated_mm2s_tdata_width (mm2s_tdata_dwidth         : integer)
            return  integer;

function calculated_s2mm_tdata_width (s2mm_tdata_dwidth         : integer)
            return  integer;




function calculated_minimum_mm2s_linebuffer_thresh (mm2s_included : integer; mm2s_tdata_dwidth         : integer; mm2s_linebuffer_depth: integer)
            return  integer;


function calculated_minimum_s2mm_linebuffer_thresh (s2mm_included : integer; s2mm_tdata_dwidth         : integer; s2mm_linebuffer_depth: integer)
            return  integer;


function find_mm2s_fsync      (use_fsync     : integer;
                               mm2s_included : integer;
                               s2mm_included : integer)
            return  integer;


function find_s2mm_fsync      (use_fsync     : integer;
                               mm2s_included : integer;
                               s2mm_included : integer)
            return  integer;

function find_s2mm_fsync_01      (use_s2mm_fsync     : integer)
            return  integer;


function find_mm2s_flush      (use_fsync         : integer;
                               mm2s_included     : integer;
                               s2mm_included     : integer;
                               flush_on_fsync    : integer)
            return  integer;


function find_s2mm_flush      (use_fsync         : integer;
                               mm2s_included     : integer;
                               s2mm_included     : integer;
                               flush_on_fsync    : integer)
            return  integer;





-- Find minimum required btt width
function required_btt_width (dwidth         : integer;
                             burst_size     : integer;
                             btt_width      : integer)
            return  integer;

-- Converts string to interger
function string2int(strngbuf: string)
            return integer;

-- Return number of registers
function get_num_registers(mode             : integer;
                           sg_num           : integer;
                           regdir_num       : integer)
    return integer;

-- Return correct hertz paramter value
function hertz_prmtr_select(included        : integer;
                            lite_frequency  : integer;
                            sg_frequency    : integer)
    return integer;

-- Return SnF enable or disable
function enable_snf (sf_enabled         : integer;
                     axi_data_width     : integer;
                     axis_tdata_width   : integer)
    return integer;

-- Return mm2s index or converted s2mm index
function convert_base_index(channel_is_mm2s : integer;
                            mm2s_index      : integer)
    return integer;

-- Return mm2s index or converted s2mm index
function convert_regdir_index(channel_is_mm2s : integer;
                              mm2s_index      : integer)
    return integer;

-- Return enable genlock bus
function enable_internal_genloc(mm2s_enabled    : integer;
				s2mm_enabled    : integer;
				internal_genlock    : integer;
                                mm2s_genlock_mode   : integer;
                                s2mm_genlock_mode   : integer)
    return integer;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AXI Responce Values
-------------------------------------------------------------------------------
constant OKAY_RESP                  : std_logic_vector(1 downto 0)  := "00";
constant EXOKAY_RESP                : std_logic_vector(1 downto 0)  := "01";
constant SLVERR_RESP                : std_logic_vector(1 downto 0)  := "10";
constant DECERR_RESP                : std_logic_vector(1 downto 0)  := "11";

-------------------------------------------------------------------------------
-- Misc Constants
-------------------------------------------------------------------------------

constant NUM_REG_TOTAL_SG           : integer := 62;
constant NUM_REG_TOTAL_REGDIR       : integer := 62;



----constant NUM_REG_TOTAL_SG           : integer := 20;
----constant NUM_REG_TOTAL_REGDIR       : integer := 59;

--constant NUM_REG_TOTAL_REGDIR       : integer := 156;
--constant NUM_REG_TOTAL_REGDIR       : integer := 123;


constant NUM_REG_PER_CHANNEL        : integer := 8;
constant NUM_DIRECT_REG_PER_CHANNEL : integer := 19;
--constant NUM_DIRECT_REG_PER_CHANNEL : integer := 67;

--constant REG_MSB_ADDR_BIT           : integer := clog2(NUM_REG_TOTAL)-1;
constant CMD_BASE_WIDTH             : integer := 40;
constant BUFFER_LENGTH_WIDTH        : integer := 23;

-- Constants Used in Desc Updates
constant DESC_STS_TYPE              : std_logic := '1';
constant DESC_DATA_TYPE             : std_logic := '0';
constant DESC_LAST                  : std_logic := '1';
constant DESC_NOT_LAST              : std_logic := '0';

-- Clock Domain Crossing Constants
constant CDC_TYPE_PULSE_P_S             : integer := 0;
constant CDC_TYPE_LEVEL_P_S             : integer := 1;
constant CDC_TYPE_PULSE_S_P             : integer := 2;
constant CDC_TYPE_LEVEL_S_P             : integer := 3;
constant CDC_TYPE_VECTR_P_S             : integer := 4;
constant CDC_TYPE_VECTR_S_P             : integer := 5;

constant CDC_TYPE_PULSE_P_S_NO_RST             : integer := 6;
constant CDC_TYPE_LEVEL_P_S_NO_RST             : integer := 7;
constant CDC_TYPE_PULSE_S_P_NO_RST             : integer := 8;
constant CDC_TYPE_LEVEL_S_P_NO_RST             : integer := 9;

constant CDC_TYPE_PULSE_P_S_LL             : integer := 10;

constant CDC_TYPE_PULSE_S_P_LL             : integer := 11;
constant CDC_TYPE_PULSE_P_S_OPEN_ENDED             : integer := 12;
constant CDC_TYPE_PULSE_S_P_OPEN_ENDED             : integer := 13;
constant CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST      : integer := 14;
constant CDC_TYPE_PULSE_S_P_OPEN_ENDED_NO_RST      : integer := 15;

constant MTBF_STAGES             : integer := 4;
constant MTBF_STAGES_LITE        : integer := 3;

-- Interrupt Coalescing
constant ZERO_THRESHOLD             : std_logic_vector(7 downto 0) := (others => '0');
constant ONE_THRESHOLD              : std_logic_vector(7 downto 0) := "00000001";
constant ZERO_DELAY                 : std_logic_vector(7 downto 0) := (others => '0');

-- Frame Store
constant NUM_FRM_STORE_WIDTH        : integer := 6;
constant FRAME_NUMBER_WIDTH         : integer := NUM_FRM_STORE_WIDTH - 1;
constant ZERO_FRAMESTORE            : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
constant ONE_FRAMESTORE             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)
                                        := std_logic_vector(to_unsigned(1,NUM_FRM_STORE_WIDTH));
constant MAX_FSTORES                : integer := 32;

-- Line Buffer
constant LINEBUFFER_THRESH_WIDTH    : integer := 17;


-- Video parameter constants
constant VSIZE_DWIDTH               : integer := 13;
constant HSIZE_DWIDTH               : integer := 16;
constant STRIDE_DWIDTH              : integer := 16;
constant FRMDLY_DWIDTH              : integer := FRAME_NUMBER_WIDTH;

constant FRMDLY_MSB                 : integer := 28;
constant FRMDLY_LSB                 : integer := 24;

constant RSVD_BITS_31TO29           : std_logic_vector(2 downto 0) := (others => '0');
constant RSVD_BITS_23TO16           : std_logic_vector(7 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- AXI Lite AXI DMA Register Offsets
-------------------------------------------------------------------------------
constant MM2S_DMACR_INDEX           : integer := 0;
constant MM2S_DMASR_INDEX           : integer := 1;
constant MM2S_CURDESC_LSB_INDEX     : integer := 2;
constant MM2S_CURDESC_MSB_INDEX     : integer := 3;
constant MM2S_TAILDESC_LSB_INDEX    : integer := 4;
constant MM2S_TAILDESC_MSB_INDEX    : integer := 5;
constant MM2S_REG_IND             : integer := 5;
constant MM2S_FRAME_STORE_INDEX     : integer := 6;
constant MM2S_THRESHOLD_INDEX       : integer := 7;
constant RESERVED_20_INDEX          : integer := 8;
constant VDMA_GLPTR_INDEX          : integer := 9;
constant VDMA_PARKPTR_INDEX         : integer := 10;
constant VDMA_VERISON_INDEX         : integer := 11;
constant S2MM_DMACR_INDEX           : integer := 12;
constant S2MM_DMASR_INDEX           : integer := 13;
constant S2MM_CURDESC_LSB_INDEX     : integer := 14;
constant S2MM_CURDESC_MSB_INDEX     : integer := 15;
constant S2MM_DMA_IRQ_MASK          : integer := 15;
constant S2MM_TAILDESC_LSB_INDEX    : integer := 16;
constant S2MM_TAILDESC_MSB_INDEX    : integer := 17;
constant S2MM_REG_IND             : integer := 17;
constant S2MM_FRAME_STORE_INDEX     : integer := 18;
constant S2MM_THRESHOLD_INDEX       : integer := 19;
-- Register direct

constant MM2S_VSIZE_INDEX           : integer := 20;
constant MM2S_HSIZE_INDEX           : integer := 21;
constant MM2S_DLYSTRD_INDEX         : integer := 22;

constant MM2S_STARTADDR1_INDEX      : integer := 23;
constant MM2S_STARTADDR2_INDEX      : integer := 24;
constant MM2S_STARTADDR3_INDEX      : integer := 25;
constant MM2S_STARTADDR4_INDEX      : integer := 26;
constant MM2S_STARTADDR5_INDEX      : integer := 27;
constant MM2S_STARTADDR6_INDEX      : integer := 28;
constant MM2S_STARTADDR7_INDEX      : integer := 29;
constant MM2S_STARTADDR8_INDEX      : integer := 30;
constant MM2S_STARTADDR9_INDEX      : integer := 31;
constant MM2S_STARTADDR10_INDEX     : integer := 32;
constant MM2S_STARTADDR11_INDEX     : integer := 33;
constant MM2S_STARTADDR12_INDEX     : integer := 34;
constant MM2S_STARTADDR13_INDEX     : integer := 35;
constant MM2S_STARTADDR14_INDEX     : integer := 36;
constant MM2S_STARTADDR15_INDEX     : integer := 37;
constant MM2S_STARTADDR16_INDEX     : integer := 38;
constant RESERVED_9C_INDEX          : integer := 39;
constant S2MM_VSIZE_INDEX           : integer := 40;
constant S2MM_HSIZE_INDEX           : integer := 41;
constant S2MM_DLYSTRD_INDEX         : integer := 42;
constant S2MM_STARTADDR1_INDEX      : integer := 43;
constant S2MM_STARTADDR2_INDEX      : integer := 44;
constant S2MM_STARTADDR3_INDEX      : integer := 45;
constant S2MM_STARTADDR4_INDEX      : integer := 46;
constant S2MM_STARTADDR5_INDEX      : integer := 47;
constant S2MM_STARTADDR6_INDEX      : integer := 48;
constant S2MM_STARTADDR7_INDEX      : integer := 49;
constant S2MM_STARTADDR8_INDEX      : integer := 50;
constant S2MM_STARTADDR9_INDEX      : integer := 51;
constant S2MM_STARTADDR10_INDEX     : integer := 52;
constant S2MM_STARTADDR11_INDEX     : integer := 53;
constant S2MM_STARTADDR12_INDEX     : integer := 54;
constant S2MM_STARTADDR13_INDEX     : integer := 55;
constant S2MM_STARTADDR14_INDEX     : integer := 56;
constant S2MM_STARTADDR15_INDEX     : integer := 57;
constant S2MM_STARTADDR16_INDEX     : integer := 58;

constant RESERVED_EC_INDEX          : integer := 59;
--constant RESERVED_F0_INDEX          : integer := 60;
constant HSIZE_AT_LLESS_ERR_F0_INDEX          : integer := 60;
--constant RESERVED_F4_INDEX          : integer := 61;
constant VSIZE_AT_FLESS_ERR_F4_INDEX          : integer := 61;
constant RESERVED_F8_INDEX          : integer := 62;
constant RESERVED_FC_INDEX          : integer := 63;
constant RESERVED_100_INDEX         : integer := 64;
constant RESERVED_104_INDEX         : integer := 65;
constant RESERVED_108_INDEX         : integer := 66;
constant RESERVED_10C_INDEX         : integer := 67;
constant RESERVED_110_INDEX         : integer := 68;
constant RESERVED_114_INDEX         : integer := 69;
constant RESERVED_118_INDEX         : integer := 70;
constant RESERVED_11C_INDEX         : integer := 71;
constant RESERVED_120_INDEX         : integer := 72;
constant RESERVED_124_INDEX         : integer := 73;
constant RESERVED_128_INDEX         : integer := 74;
constant RESERVED_12C_INDEX         : integer := 75;
constant RESERVED_130_INDEX         : integer := 76;
constant RESERVED_134_INDEX         : integer := 77;
constant RESERVED_138_INDEX         : integer := 78;
constant RESERVED_13C_INDEX         : integer := 79;
constant RESERVED_140_INDEX         : integer := 80;
constant RESERVED_144_INDEX         : integer := 81;
constant RESERVED_148_INDEX         : integer := 82;
constant RESERVED_14C_INDEX         : integer := 83;
constant RESERVED_150_INDEX         : integer := 84;
constant RESERVED_154_INDEX         : integer := 85;
constant RESERVED_158_INDEX         : integer := 86;


constant MM2S_STARTADDR17_INDEX      : integer := 87;
constant MM2S_STARTADDR18_INDEX      : integer := 88;
constant MM2S_STARTADDR19_INDEX      : integer := 89;
constant MM2S_STARTADDR20_INDEX      : integer := 90;
constant MM2S_STARTADDR21_INDEX      : integer := 91;
constant MM2S_STARTADDR22_INDEX      : integer := 92;
constant MM2S_STARTADDR23_INDEX      : integer := 93;
constant MM2S_STARTADDR24_INDEX      : integer := 94;
constant MM2S_STARTADDR25_INDEX      : integer := 95;
constant MM2S_STARTADDR26_INDEX      : integer := 96;
constant MM2S_STARTADDR27_INDEX      : integer := 97;
constant MM2S_STARTADDR28_INDEX      : integer := 98;
constant MM2S_STARTADDR29_INDEX      : integer := 99;
constant MM2S_STARTADDR30_INDEX      : integer := 100;
constant MM2S_STARTADDR31_INDEX      : integer := 101;
constant MM2S_STARTADDR32_INDEX      : integer := 102;


constant RESERVED_19C_INDEX          : integer := 103;
constant RESERVED_1A0_INDEX          : integer := 104;
constant RESERVED_1A4_INDEX          : integer := 105;
constant RESERVED_1A8_INDEX          : integer := 106;

constant S2MM_STARTADDR17_INDEX      : integer := 107;
constant S2MM_STARTADDR18_INDEX      : integer := 108;
constant S2MM_STARTADDR19_INDEX      : integer := 109;
constant S2MM_STARTADDR20_INDEX      : integer := 110;
constant S2MM_STARTADDR21_INDEX      : integer := 111;
constant S2MM_STARTADDR22_INDEX      : integer := 112;
constant S2MM_STARTADDR23_INDEX      : integer := 113;
constant S2MM_STARTADDR24_INDEX      : integer := 114;
constant S2MM_STARTADDR25_INDEX      : integer := 115;
constant S2MM_STARTADDR26_INDEX      : integer := 116;
constant S2MM_STARTADDR27_INDEX      : integer := 117;
constant S2MM_STARTADDR28_INDEX      : integer := 118;
constant S2MM_STARTADDR29_INDEX      : integer := 119;
constant S2MM_STARTADDR30_INDEX      : integer := 120;
constant S2MM_STARTADDR31_INDEX      : integer := 121;
constant S2MM_STARTADDR32_INDEX      : integer := 122;


-- READ MUX Offsets


constant MM2S_REG_INDEX_OFFSET_90      : std_logic_vector(8 downto 0)  := "000010100";  -- 14
constant S2MM_REG_INDEX_OFFSET_90      : std_logic_vector(8 downto 0)  := "001000100";  -- 44
constant MM2S_REG_INDEX_OFFSET_91      : std_logic_vector(8 downto 0)  := "100010100";  -- 14
constant S2MM_REG_INDEX_OFFSET_91      : std_logic_vector(8 downto 0)  := "101000100";  -- 44

constant MM2S_REG_INDEX_OFFSET_8      : std_logic_vector(7 downto 0)  := "00010100";  -- 14
constant S2MM_REG_INDEX_OFFSET_8      : std_logic_vector(7 downto 0)  := "01000100";  -- 44
-- }                                                                              

                                                                                  
constant MM2S_DMACR_OFFSET_SG          : std_logic_vector(7 downto 0)  := "00000000";  -- 00
constant MM2S_DMASR_OFFSET_SG          : std_logic_vector(7 downto 0)  := "00000100";  -- 04
constant MM2S_CURDESC_LSB_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00001000";  -- 08
constant MM2S_CURDESC_MSB_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00001100";  -- 0C
constant MM2S_TAILDESC_LSB_OFFSET_SG   : std_logic_vector(7 downto 0)  := "00010000";  -- 10
constant MM2S_TAILDESC_MSB_OFFSET_SG   : std_logic_vector(7 downto 0)  := "00010100";  -- 14
constant MM2S_FRAME_STORE_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00011000";  -- 18
constant MM2S_THRESHOLD_OFFSET_SG      : std_logic_vector(7 downto 0)  := "00011100";  -- 1C
constant RESERVED_20_OFFSET_SG         : std_logic_vector(7 downto 0)  := "00100000";  -- 20
constant RESERVED_24_OFFSET_SG         : std_logic_vector(7 downto 0)  := "00100100";  -- 24
constant VDMA_PARK_PTRREF_OFFSET    : std_logic_vector(7 downto 0)  := "00101000";  -- 28
constant VDMA_VERSION_OFFSET        : std_logic_vector(7 downto 0)  := "00101100";  -- 2C
constant VDMA_PARK_PTRREF_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00101000";  -- 28
constant VDMA_VERSION_OFFSET_SG        : std_logic_vector(7 downto 0)  := "00101100";  -- 2C
constant S2MM_DMACR_OFFSET_SG          : std_logic_vector(7 downto 0)  := "00110000";  -- 30
constant S2MM_DMASR_OFFSET_SG          : std_logic_vector(7 downto 0)  := "00110100";  -- 34
constant S2MM_CURDESC_LSB_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00111000";  -- 38
constant S2MM_CURDESC_MSB_OFFSET_SG    : std_logic_vector(7 downto 0)  := "00111100";  -- 3C
constant S2MM_DMA_IRQ_MASK_SG          : std_logic_vector(7 downto 0)  := "00111100";  -- 3C
constant S2MM_TAILDESC_LSB_OFFSET_SG   : std_logic_vector(7 downto 0)  := "01000000";  -- 40
constant S2MM_TAILDESC_MSB_OFFSET_SG   : std_logic_vector(7 downto 0)  := "01000100";  -- 44
constant S2MM_FRAME_STORE_OFFSET_SG    : std_logic_vector(7 downto 0)  := "01001000";  -- 48
constant S2MM_THRESHOLD_OFFSET_SG      : std_logic_vector(7 downto 0)  := "01001100";  -- 4C
------



                                                                                  
constant MM2S_DMACR_OFFSET_8          : std_logic_vector(7 downto 0)  := "00000000";  -- 00
constant MM2S_DMASR_OFFSET_8          : std_logic_vector(7 downto 0)  := "00000100";  -- 04
constant MM2S_CURDESC_LSB_OFFSET_8    : std_logic_vector(7 downto 0)  := "00001000";  -- 08
constant MM2S_CURDESC_MSB_OFFSET_8    : std_logic_vector(7 downto 0)  := "00001100";  -- 0C
constant MM2S_TAILDESC_LSB_OFFSET_8   : std_logic_vector(7 downto 0)  := "00010000";  -- 10
constant MM2S_TAILDESC_MSB_OFFSET_8   : std_logic_vector(7 downto 0)  := "00010100";  -- 14
constant MM2S_FRAME_STORE_OFFSET_8    : std_logic_vector(7 downto 0)  := "00011000";  -- 18
constant MM2S_THRESHOLD_OFFSET_8      : std_logic_vector(7 downto 0)  := "00011100";  -- 1C
constant RESERVED_20_OFFSET_8         : std_logic_vector(7 downto 0)  := "00100000";  -- 20
constant RESERVED_24_OFFSET_8         : std_logic_vector(7 downto 0)  := "00100100";  -- 24
constant VDMA_PARK_PTRREF_OFFSET_8    : std_logic_vector(7 downto 0)  := "00101000";  -- 28
constant VDMA_VERSION_OFFSET_8        : std_logic_vector(7 downto 0)  := "00101100";  -- 2C
constant S2MM_DMACR_OFFSET_8          : std_logic_vector(7 downto 0)  := "00110000";  -- 30
constant S2MM_DMASR_OFFSET_8          : std_logic_vector(7 downto 0)  := "00110100";  -- 34
constant S2MM_CURDESC_LSB_OFFSET_8    : std_logic_vector(7 downto 0)  := "00111000";  -- 38
constant S2MM_CURDESC_MSB_OFFSET_8    : std_logic_vector(7 downto 0)  := "00111100";  -- 3C
constant S2MM_DMA_IRQ_MASK_8          : std_logic_vector(7 downto 0)  := "00111100";  -- 3C
constant S2MM_TAILDESC_LSB_OFFSET_8   : std_logic_vector(7 downto 0)  := "01000000";  -- 40
constant S2MM_TAILDESC_MSB_OFFSET_8   : std_logic_vector(7 downto 0)  := "01000100";  -- 44
constant S2MM_FRAME_STORE_OFFSET_8    : std_logic_vector(7 downto 0)  := "01001000";  -- 48
constant S2MM_THRESHOLD_OFFSET_8      : std_logic_vector(7 downto 0)  := "01001100";  -- 4C
------


                                                                                  
constant MM2S_DMACR_OFFSET_90          : std_logic_vector(8 downto 0)  := "000000000";  -- 000
constant MM2S_DMASR_OFFSET_90          : std_logic_vector(8 downto 0)  := "000000100";  -- 004
constant MM2S_CURDESC_LSB_OFFSET_90    : std_logic_vector(8 downto 0)  := "000001000";  -- 008
constant MM2S_CURDESC_MSB_OFFSET_90    : std_logic_vector(8 downto 0)  := "000001100";  -- 00C
constant MM2S_TAILDESC_LSB_OFFSET_90   : std_logic_vector(8 downto 0)  := "000010000";  -- 010
constant MM2S_TAILDESC_MSB_OFFSET_90   : std_logic_vector(8 downto 0)  := "000010100";  -- 014
constant MM2S_FRAME_STORE_OFFSET_90    : std_logic_vector(8 downto 0)  := "000011000";  -- 018
constant MM2S_THRESHOLD_OFFSET_90      : std_logic_vector(8 downto 0)  := "000011100";  -- 01C
constant RESERVED_20_OFFSET_90         : std_logic_vector(8 downto 0)  := "000100000";  -- 020
constant RESERVED_24_OFFSET_90         : std_logic_vector(8 downto 0)  := "000100100";  -- 024
constant VDMA_PARK_PTRREF_OFFSET_90    : std_logic_vector(8 downto 0)  := "000101000";  -- 028
constant VDMA_VERSION_OFFSET_90        : std_logic_vector(8 downto 0)  := "000101100";  -- 02C
constant S2MM_DMACR_OFFSET_90          : std_logic_vector(8 downto 0)  := "000110000";  -- 030
constant S2MM_DMASR_OFFSET_90          : std_logic_vector(8 downto 0)  := "000110100";  -- 034
constant S2MM_CURDESC_LSB_OFFSET_90    : std_logic_vector(8 downto 0)  := "000111000";  -- 038
constant S2MM_CURDESC_MSB_OFFSET_90    : std_logic_vector(8 downto 0)  := "000111100";  -- 03C
constant S2MM_DMA_IRQ_MASK_OFFSET_90    : std_logic_vector(8 downto 0)  := "000111100";  -- 03C
constant S2MM_TAILDESC_LSB_OFFSET_90   : std_logic_vector(8 downto 0)  := "001000000";  -- 040
constant S2MM_TAILDESC_MSB_OFFSET_90   : std_logic_vector(8 downto 0)  := "001000100";  -- 044
constant S2MM_FRAME_STORE_OFFSET_90    : std_logic_vector(8 downto 0)  := "001001000";  -- 048
constant S2MM_THRESHOLD_OFFSET_90      : std_logic_vector(8 downto 0)  := "001001100";  -- 04C
------

                                                                                  
constant MM2S_DMACR_OFFSET_91          : std_logic_vector(8 downto 0)  := "100000000";  -- 100
constant MM2S_DMASR_OFFSET_91          : std_logic_vector(8 downto 0)  := "100000100";  -- 104
constant MM2S_CURDESC_LSB_OFFSET_91    : std_logic_vector(8 downto 0)  := "100001000";  -- 108
constant MM2S_CURDESC_MSB_OFFSET_91    : std_logic_vector(8 downto 0)  := "100001100";  -- 10C
constant MM2S_TAILDESC_LSB_OFFSET_91   : std_logic_vector(8 downto 0)  := "100010000";  -- 110
constant MM2S_TAILDESC_MSB_OFFSET_91   : std_logic_vector(8 downto 0)  := "100010100";  -- 114
constant MM2S_FRAME_STORE_OFFSET_91    : std_logic_vector(8 downto 0)  := "100011000";  -- 118
constant MM2S_THRESHOLD_OFFSET_91      : std_logic_vector(8 downto 0)  := "100011100";  -- 11C
constant RESERVED_20_OFFSET_91         : std_logic_vector(8 downto 0)  := "100100000";  -- 120
constant RESERVED_24_OFFSET_91         : std_logic_vector(8 downto 0)  := "100100100";  -- 124
constant VDMA_PARK_PTRREF_OFFSET_91    : std_logic_vector(8 downto 0)  := "100101000";  -- 128
constant VDMA_VERSION_OFFSET_91        : std_logic_vector(8 downto 0)  := "100101100";  -- 12C
constant S2MM_DMACR_OFFSET_91          : std_logic_vector(8 downto 0)  := "100110000";  -- 130
constant S2MM_DMASR_OFFSET_91          : std_logic_vector(8 downto 0)  := "100110100";  -- 134
constant S2MM_CURDESC_LSB_OFFSET_91    : std_logic_vector(8 downto 0)  := "100111000";  -- 138
constant S2MM_CURDESC_MSB_OFFSET_91    : std_logic_vector(8 downto 0)  := "100111100";  -- 13C
constant S2MM_DMA_IRQ_MASK_OFFSET_91    : std_logic_vector(8 downto 0)  := "100111100";  -- 13C
constant S2MM_TAILDESC_LSB_OFFSET_91   : std_logic_vector(8 downto 0)  := "101000000";  -- 140
constant S2MM_TAILDESC_MSB_OFFSET_91   : std_logic_vector(8 downto 0)  := "101000100";  -- 144
constant S2MM_FRAME_STORE_OFFSET_91    : std_logic_vector(8 downto 0)  := "101001000";  -- 148
constant S2MM_THRESHOLD_OFFSET_91      : std_logic_vector(8 downto 0)  := "101001100";  -- 14C
------







-------- Register direct READ MUX Offsets
constant MM2S_VSIZE_OFFSET_8          : std_logic_vector(7 downto 0)  := "01010000";  -- 50
constant MM2S_HSIZE_OFFSET_8          : std_logic_vector(7 downto 0)  := "01010100";  -- 54
constant MM2S_DLYSTRD_OFFSET_8        : std_logic_vector(7 downto 0)  := "01011000";  -- 58

constant MM2S_VSIZE_OFFSET_90          : std_logic_vector(8 downto 0)  := "001010000";  -- 050
constant MM2S_HSIZE_OFFSET_90          : std_logic_vector(8 downto 0)  := "001010100";  -- 054
constant MM2S_DLYSTRD_OFFSET_90        : std_logic_vector(8 downto 0)  := "001011000";  -- 058

constant MM2S_VSIZE_OFFSET_91          : std_logic_vector(8 downto 0)  := "101010000";  -- 050
constant MM2S_HSIZE_OFFSET_91          : std_logic_vector(8 downto 0)  := "101010100";  -- 054
constant MM2S_DLYSTRD_OFFSET_91        : std_logic_vector(8 downto 0)  := "101011000";  -- 058




constant MM2S_STARTADDR1_OFFSET_8     : std_logic_vector(7 downto 0)  := "01011100";  -- 5C
constant MM2S_STARTADDR2_OFFSET_8     : std_logic_vector(7 downto 0)  := "01100000";  -- 60
constant MM2S_STARTADDR3_OFFSET_8     : std_logic_vector(7 downto 0)  := "01100100";  -- 64
constant MM2S_STARTADDR4_OFFSET_8     : std_logic_vector(7 downto 0)  := "01101000";  -- 68
constant MM2S_STARTADDR5_OFFSET_8     : std_logic_vector(7 downto 0)  := "01101100";  -- 6C
constant MM2S_STARTADDR6_OFFSET_8     : std_logic_vector(7 downto 0)  := "01110000";  -- 70
constant MM2S_STARTADDR7_OFFSET_8     : std_logic_vector(7 downto 0)  := "01110100";  -- 74
constant MM2S_STARTADDR8_OFFSET_8     : std_logic_vector(7 downto 0)  := "01111000";  -- 78
constant MM2S_STARTADDR9_OFFSET_8     : std_logic_vector(7 downto 0)  := "01111100";  -- 7C
constant MM2S_STARTADDR10_OFFSET_8    : std_logic_vector(7 downto 0)  := "10000000";  -- 80
constant MM2S_STARTADDR11_OFFSET_8    : std_logic_vector(7 downto 0)  := "10000100";  -- 84
constant MM2S_STARTADDR12_OFFSET_8    : std_logic_vector(7 downto 0)  := "10001000";  -- 88
constant MM2S_STARTADDR13_OFFSET_8    : std_logic_vector(7 downto 0)  := "10001100";  -- 8C
constant MM2S_STARTADDR14_OFFSET_8    : std_logic_vector(7 downto 0)  := "10010000";  -- 90
constant MM2S_STARTADDR15_OFFSET_8    : std_logic_vector(7 downto 0)  := "10010100";  -- 94
constant MM2S_STARTADDR16_OFFSET_8    : std_logic_vector(7 downto 0)  := "10011000";  -- 98


constant MM2S_STARTADDR1_OFFSET_90     : std_logic_vector(8 downto 0)  := "001011100";  -- 05C
constant MM2S_STARTADDR2_OFFSET_90     : std_logic_vector(8 downto 0)  := "001100000";  -- 060
constant MM2S_STARTADDR3_OFFSET_90     : std_logic_vector(8 downto 0)  := "001100100";  -- 064
constant MM2S_STARTADDR4_OFFSET_90     : std_logic_vector(8 downto 0)  := "001101000";  -- 068
constant MM2S_STARTADDR5_OFFSET_90     : std_logic_vector(8 downto 0)  := "001101100";  -- 06C
constant MM2S_STARTADDR6_OFFSET_90     : std_logic_vector(8 downto 0)  := "001110000";  -- 070
constant MM2S_STARTADDR7_OFFSET_90     : std_logic_vector(8 downto 0)  := "001110100";  -- 074
constant MM2S_STARTADDR8_OFFSET_90     : std_logic_vector(8 downto 0)  := "001111000";  -- 078
constant MM2S_STARTADDR9_OFFSET_90     : std_logic_vector(8 downto 0)  := "001111100";  -- 07C
constant MM2S_STARTADDR10_OFFSET_90    : std_logic_vector(8 downto 0)  := "010000000";  -- 080
constant MM2S_STARTADDR11_OFFSET_90    : std_logic_vector(8 downto 0)  := "010000100";  -- 084
constant MM2S_STARTADDR12_OFFSET_90    : std_logic_vector(8 downto 0)  := "010001000";  -- 088
constant MM2S_STARTADDR13_OFFSET_90    : std_logic_vector(8 downto 0)  := "010001100";  -- 08C
constant MM2S_STARTADDR14_OFFSET_90    : std_logic_vector(8 downto 0)  := "010010000";  -- 090
constant MM2S_STARTADDR15_OFFSET_90    : std_logic_vector(8 downto 0)  := "010010100";  -- 094
constant MM2S_STARTADDR16_OFFSET_90    : std_logic_vector(8 downto 0)  := "010011000";  -- 098


constant MM2S_STARTADDR1_OFFSET_91     : std_logic_vector(8 downto 0)  := "101011100";  -- 15C
constant MM2S_STARTADDR2_OFFSET_91     : std_logic_vector(8 downto 0)  := "101100000";  -- 160
constant MM2S_STARTADDR3_OFFSET_91     : std_logic_vector(8 downto 0)  := "101100100";  -- 164
constant MM2S_STARTADDR4_OFFSET_91     : std_logic_vector(8 downto 0)  := "101101000";  -- 168
constant MM2S_STARTADDR5_OFFSET_91     : std_logic_vector(8 downto 0)  := "101101100";  -- 16C
constant MM2S_STARTADDR6_OFFSET_91     : std_logic_vector(8 downto 0)  := "101110000";  -- 170
constant MM2S_STARTADDR7_OFFSET_91     : std_logic_vector(8 downto 0)  := "101110100";  -- 174
constant MM2S_STARTADDR8_OFFSET_91     : std_logic_vector(8 downto 0)  := "101111000";  -- 178
constant MM2S_STARTADDR9_OFFSET_91     : std_logic_vector(8 downto 0)  := "101111100";  -- 17C
constant MM2S_STARTADDR10_OFFSET_91    : std_logic_vector(8 downto 0)  := "110000000";  -- 180
constant MM2S_STARTADDR11_OFFSET_91    : std_logic_vector(8 downto 0)  := "110000100";  -- 184
constant MM2S_STARTADDR12_OFFSET_91    : std_logic_vector(8 downto 0)  := "110001000";  -- 188
constant MM2S_STARTADDR13_OFFSET_91    : std_logic_vector(8 downto 0)  := "110001100";  -- 18C
constant MM2S_STARTADDR14_OFFSET_91    : std_logic_vector(8 downto 0)  := "110010000";  -- 190
constant MM2S_STARTADDR15_OFFSET_91    : std_logic_vector(8 downto 0)  := "110010100";  -- 194
constant MM2S_STARTADDR16_OFFSET_91    : std_logic_vector(8 downto 0)  := "110011000";  -- 198



constant RESERVED_9C_OFFSET_90         : std_logic_vector(8 downto 0)  := "010011100";  -- 9C


constant S2MM_VSIZE_OFFSET_8          : std_logic_vector(7 downto 0)  := "10100000";  -- A0
constant S2MM_HSIZE_OFFSET_8          : std_logic_vector(7 downto 0)  := "10100100";  -- A4
constant S2MM_DLYSTRD_OFFSET_8        : std_logic_vector(7 downto 0)  := "10101000";  -- A8

constant S2MM_VSIZE_OFFSET_90          : std_logic_vector(8 downto 0)  := "010100000";  -- A0
constant S2MM_HSIZE_OFFSET_90          : std_logic_vector(8 downto 0)  := "010100100";  -- A4
constant S2MM_DLYSTRD_OFFSET_90        : std_logic_vector(8 downto 0)  := "010101000";  -- A8

constant S2MM_VSIZE_OFFSET_91          : std_logic_vector(8 downto 0)  := "110100000";  -- A0
constant S2MM_HSIZE_OFFSET_91          : std_logic_vector(8 downto 0)  := "110100100";  -- A4
constant S2MM_DLYSTRD_OFFSET_91        : std_logic_vector(8 downto 0)  := "110101000";  -- A8




constant S2MM_STARTADDR1_OFFSET_8     : std_logic_vector(7 downto 0)  := "10101100";  -- AC
constant S2MM_STARTADDR2_OFFSET_8     : std_logic_vector(7 downto 0)  := "10110000";  -- B0
constant S2MM_STARTADDR3_OFFSET_8     : std_logic_vector(7 downto 0)  := "10110100";  -- B4
constant S2MM_STARTADDR4_OFFSET_8     : std_logic_vector(7 downto 0)  := "10111000";  -- B8
constant S2MM_STARTADDR5_OFFSET_8     : std_logic_vector(7 downto 0)  := "10111100";  -- BC
constant S2MM_STARTADDR6_OFFSET_8     : std_logic_vector(7 downto 0)  := "11000000";  -- C0
constant S2MM_STARTADDR7_OFFSET_8     : std_logic_vector(7 downto 0)  := "11000100";  -- C4
constant S2MM_STARTADDR8_OFFSET_8     : std_logic_vector(7 downto 0)  := "11001000";  -- C8
constant S2MM_STARTADDR9_OFFSET_8     : std_logic_vector(7 downto 0)  := "11001100";  -- CC
constant S2MM_STARTADDR10_OFFSET_8    : std_logic_vector(7 downto 0)  := "11010000";  -- D0
constant S2MM_STARTADDR11_OFFSET_8    : std_logic_vector(7 downto 0)  := "11010100";  -- D4
constant S2MM_STARTADDR12_OFFSET_8    : std_logic_vector(7 downto 0)  := "11011000";  -- D8
constant S2MM_STARTADDR13_OFFSET_8    : std_logic_vector(7 downto 0)  := "11011100";  -- DC
constant S2MM_STARTADDR14_OFFSET_8    : std_logic_vector(7 downto 0)  := "11100000";  -- E0
constant S2MM_STARTADDR15_OFFSET_8    : std_logic_vector(7 downto 0)  := "11100100";  -- E4
constant S2MM_STARTADDR16_OFFSET_8    : std_logic_vector(7 downto 0)  := "11101000";  -- E8


constant S2MM_STARTADDR1_OFFSET_90     : std_logic_vector(8 downto 0)  := "010101100";  -- 0AC
constant S2MM_STARTADDR2_OFFSET_90     : std_logic_vector(8 downto 0)  := "010110000";  -- 0B0
constant S2MM_STARTADDR3_OFFSET_90     : std_logic_vector(8 downto 0)  := "010110100";  -- 0B4
constant S2MM_STARTADDR4_OFFSET_90     : std_logic_vector(8 downto 0)  := "010111000";  -- 0B8
constant S2MM_STARTADDR5_OFFSET_90     : std_logic_vector(8 downto 0)  := "010111100";  -- 0BC
constant S2MM_STARTADDR6_OFFSET_90     : std_logic_vector(8 downto 0)  := "011000000";  -- 0C0
constant S2MM_STARTADDR7_OFFSET_90     : std_logic_vector(8 downto 0)  := "011000100";  -- 0C4
constant S2MM_STARTADDR8_OFFSET_90     : std_logic_vector(8 downto 0)  := "011001000";  -- 0C8
constant S2MM_STARTADDR9_OFFSET_90     : std_logic_vector(8 downto 0)  := "011001100";  -- 0CC
constant S2MM_STARTADDR10_OFFSET_90    : std_logic_vector(8 downto 0)  := "011010000";  -- 0D0
constant S2MM_STARTADDR11_OFFSET_90    : std_logic_vector(8 downto 0)  := "011010100";  -- 0D4
constant S2MM_STARTADDR12_OFFSET_90    : std_logic_vector(8 downto 0)  := "011011000";  -- 0D8
constant S2MM_STARTADDR13_OFFSET_90    : std_logic_vector(8 downto 0)  := "011011100";  -- 0DC
constant S2MM_STARTADDR14_OFFSET_90    : std_logic_vector(8 downto 0)  := "011100000";  -- 0E0
constant S2MM_STARTADDR15_OFFSET_90    : std_logic_vector(8 downto 0)  := "011100100";  -- 0E4
constant S2MM_STARTADDR16_OFFSET_90    : std_logic_vector(8 downto 0)  := "011101000";  -- 0E8


constant RESERVED_EC_OFFSET          : std_logic_vector(8 downto 0) := "011101100";  -- 0EC  
constant RESERVED_F0_OFFSET          : std_logic_vector(8 downto 0) := "011110000";  -- 0F0  
constant RESERVED_F4_OFFSET          : std_logic_vector(8 downto 0) := "011110100";  -- 0F4  
constant RESERVED_F8_OFFSET          : std_logic_vector(8 downto 0) := "011111000";  -- 0F8  
constant RESERVED_FC_OFFSET          : std_logic_vector(8 downto 0) := "011111100";  -- 0FC  
constant RESERVED_100_OFFSET         : std_logic_vector(8 downto 0) := "100000000";  -- 100  
constant RESERVED_104_OFFSET         : std_logic_vector(8 downto 0) := "100000100";  -- 104  
constant RESERVED_108_OFFSET         : std_logic_vector(8 downto 0) := "100001000";  -- 108  
constant RESERVED_10C_OFFSET         : std_logic_vector(8 downto 0) := "100001100";  -- 10C  
constant RESERVED_110_OFFSET         : std_logic_vector(8 downto 0) := "100010000";  -- 110  
constant RESERVED_114_OFFSET         : std_logic_vector(8 downto 0) := "100010100";  -- 114  
constant RESERVED_118_OFFSET         : std_logic_vector(8 downto 0) := "100011000";  -- 118  
constant RESERVED_11C_OFFSET         : std_logic_vector(8 downto 0) := "100011100";  -- 11C  
constant RESERVED_120_OFFSET         : std_logic_vector(8 downto 0) := "100100000";  -- 120  
constant RESERVED_124_OFFSET         : std_logic_vector(8 downto 0) := "100100100";  -- 124  
constant RESERVED_128_OFFSET         : std_logic_vector(8 downto 0) := "100101000";  -- 128  
constant RESERVED_12C_OFFSET         : std_logic_vector(8 downto 0) := "100101100";  -- 12C  
constant RESERVED_130_OFFSET         : std_logic_vector(8 downto 0) := "100110000";  -- 130  
constant RESERVED_134_OFFSET         : std_logic_vector(8 downto 0) := "100110100";  -- 134  
constant RESERVED_138_OFFSET         : std_logic_vector(8 downto 0) := "100111000";  -- 138  
constant RESERVED_13C_OFFSET         : std_logic_vector(8 downto 0) := "100111100";  -- 13C  
constant RESERVED_140_OFFSET         : std_logic_vector(8 downto 0) := "101000000";  -- 140  
constant RESERVED_144_OFFSET         : std_logic_vector(8 downto 0) := "101000100";  -- 144  
constant RESERVED_148_OFFSET         : std_logic_vector(8 downto 0) := "101001000";  -- 148  
constant RESERVED_14C_OFFSET         : std_logic_vector(8 downto 0) := "101001100";  -- 14C  
constant RESERVED_150_OFFSET         : std_logic_vector(8 downto 0) := "101010000";  -- 150  
constant RESERVED_154_OFFSET         : std_logic_vector(8 downto 0) := "101010100";  -- 154  
constant RESERVED_158_OFFSET         : std_logic_vector(8 downto 0) := "101011000";  -- 158  


constant MM2S_STARTADDR17_OFFSET_91     : std_logic_vector(8 downto 0)  := "101011100";  -- 15C
constant MM2S_STARTADDR18_OFFSET_91     : std_logic_vector(8 downto 0)  := "101100000";  -- 160
constant MM2S_STARTADDR19_OFFSET_91     : std_logic_vector(8 downto 0)  := "101100100";  -- 164
constant MM2S_STARTADDR20_OFFSET_91     : std_logic_vector(8 downto 0)  := "101101000";  -- 168
constant MM2S_STARTADDR21_OFFSET_91     : std_logic_vector(8 downto 0)  := "101101100";  -- 16C
constant MM2S_STARTADDR22_OFFSET_91     : std_logic_vector(8 downto 0)  := "101110000";  -- 170
constant MM2S_STARTADDR23_OFFSET_91     : std_logic_vector(8 downto 0)  := "101110100";  -- 174
constant MM2S_STARTADDR24_OFFSET_91     : std_logic_vector(8 downto 0)  := "101111000";  -- 178
constant MM2S_STARTADDR25_OFFSET_91     : std_logic_vector(8 downto 0)  := "101111100";  -- 17C
constant MM2S_STARTADDR26_OFFSET_91     : std_logic_vector(8 downto 0)  := "110000000";  -- 180
constant MM2S_STARTADDR27_OFFSET_91     : std_logic_vector(8 downto 0)  := "110000100";  -- 184
constant MM2S_STARTADDR28_OFFSET_91     : std_logic_vector(8 downto 0)  := "110001000";  -- 188
constant MM2S_STARTADDR29_OFFSET_91     : std_logic_vector(8 downto 0)  := "110001100";  -- 18C
constant MM2S_STARTADDR30_OFFSET_91     : std_logic_vector(8 downto 0)  := "110010000";  -- 190
constant MM2S_STARTADDR31_OFFSET_91     : std_logic_vector(8 downto 0)  := "110010100";  -- 194
constant MM2S_STARTADDR32_OFFSET_91     : std_logic_vector(8 downto 0)  := "110011000";  -- 198


constant RESERVED_19C_OFFSET         : std_logic_vector(8 downto 0)  := "110011100";  -- 19C
constant RESERVED_1A0_OFFSET         : std_logic_vector(8 downto 0)  := "110100000";  -- 1A0
constant RESERVED_1A4_OFFSET         : std_logic_vector(8 downto 0)  := "110100100";  -- 1A4
constant RESERVED_1A8_OFFSET         : std_logic_vector(8 downto 0)  := "110101000";  -- 1A8



constant S2MM_STARTADDR17_OFFSET_91     : std_logic_vector(8 downto 0)  := "110101100";  -- 1AC
constant S2MM_STARTADDR18_OFFSET_91     : std_logic_vector(8 downto 0)  := "110110000";  -- 1B0
constant S2MM_STARTADDR19_OFFSET_91     : std_logic_vector(8 downto 0)  := "110110100";  -- 1B4
constant S2MM_STARTADDR20_OFFSET_91     : std_logic_vector(8 downto 0)  := "110111000";  -- 1B8
constant S2MM_STARTADDR21_OFFSET_91     : std_logic_vector(8 downto 0)  := "110111100";  -- 1BC
constant S2MM_STARTADDR22_OFFSET_91     : std_logic_vector(8 downto 0)  := "111000000";  -- 1C0
constant S2MM_STARTADDR23_OFFSET_91     : std_logic_vector(8 downto 0)  := "111000100";  -- 1C4
constant S2MM_STARTADDR24_OFFSET_91     : std_logic_vector(8 downto 0)  := "111001000";  -- 1C8
constant S2MM_STARTADDR25_OFFSET_91     : std_logic_vector(8 downto 0)  := "111001100";  -- 1CC
constant S2MM_STARTADDR26_OFFSET_91     : std_logic_vector(8 downto 0)  := "111010000";  -- 1D0
constant S2MM_STARTADDR27_OFFSET_91     : std_logic_vector(8 downto 0)  := "111010100";  -- 1D4
constant S2MM_STARTADDR28_OFFSET_91     : std_logic_vector(8 downto 0)  := "111011000";  -- 1D8
constant S2MM_STARTADDR29_OFFSET_91     : std_logic_vector(8 downto 0)  := "111011100";  -- 1DC
constant S2MM_STARTADDR30_OFFSET_91     : std_logic_vector(8 downto 0)  := "111100000";  -- 1E0
constant S2MM_STARTADDR31_OFFSET_91     : std_logic_vector(8 downto 0)  := "111100100";  -- 1E4
constant S2MM_STARTADDR32_OFFSET_91     : std_logic_vector(8 downto 0)  := "111101000";  -- 1E8


-------------------------------------------------------------------------------
-- Register Bit Constants
-------------------------------------------------------------------------------
-- DMACR
constant DMACR_RS_BIT                   : integer := 0;
constant DMACR_CRCLPRK_BIT              : integer := 1;
constant DMACR_RESET_BIT                : integer := 2;
constant DMACR_SYNCEN_BIT               : integer := 3;
constant DMACR_FRMCNTEN_BIT             : integer := 4;
constant DMACR_FSYNCSEL_LSB             : integer := 5;
constant DMACR_FSYNCSEL_MSB             : integer := 6;
constant DMACR_GENLOCK_SEL_BIT          : integer := 7;
constant DMACR_PNTR_NUM_LSB             : integer := 8;
constant DMACR_PNTR_NUM_MSB             : integer := 11;
constant DMACR_IOC_IRQEN_BIT            : integer := 12;
constant DMACR_DLY_IRQEN_BIT            : integer := 13;
constant DMACR_ERR_IRQEN_BIT            : integer := 14;
--constant DMACR_RESERVED15_BIT           : integer := 15;
constant DMACR_REPEAT_EN_BIT            : integer := 15;
constant DMACR_IRQTHRESH_LSB_BIT        : integer := 16;
constant DMACR_IRQTHRESH_MSB_BIT        : integer := 23;
constant DMACR_IRQDELAY_LSB_BIT         : integer := 24;
constant DMACR_IRQDELAY_MSB_BIT         : integer := 31;

-- DMASR
constant DMASR_HALTED_BIT               : integer := 0;
constant DMASR_IDLE_BIT                 : integer := 1;
constant DMASR_RESERVED2_BIT            : integer := 2;
constant DMASR_ERR_BIT                : integer := 3;
constant DMASR_DMAINTERR_BIT            : integer := 4;
constant DMASR_DMASLVERR_BIT            : integer := 5;
constant DMASR_DMADECERR_BIT            : integer := 6;
constant DMASR_FSIZEERR_BIT            : integer := 7;
constant DMASR_LSIZEERR_BIT            : integer := 8;
constant DMASR_SGSLVERR_BIT             : integer := 9;
constant DMASR_SGDECERR_BIT             : integer := 10;
--constant DMASR_RESERVED11_BIT           : integer := 11;
constant DMASR_FSIZE_MORE_OR_SOF_LATE_ERR_BIT           : integer := 11;
constant DMASR_IOCIRQ_BIT               : integer := 12;
constant DMASR_DLYIRQ_BIT               : integer := 13;
constant DMASR_ERRIRQ_BIT               : integer := 14;
constant DMASR_LSIZE_MORE_ERR_BIT           : integer := 15;
constant DMASR_IRQTHRESH_LSB_BIT        : integer := 16;
constant DMASR_IRQTHRESH_MSB_BIT        : integer := 23;
constant DMASR_IRQDELAY_LSB_BIT         : integer := 24;
constant DMASR_IRQDELAY_MSB_BIT         : integer := 31;

-- CURDESC
constant CURDESC_LOWER_MSB_BIT          : integer := 31;
constant CURDESC_LOWER_LSB_BIT          : integer := 5;
constant CURDESC_RESERVED_BIT4          : integer := 4;

-- TAILDESC
constant TAILDESC_LOWER_MSB_BIT         : integer := 31;
constant TAILDESC_LOWER_LSB_BIT         : integer := 5;
constant TAILDESC_RESERVED_BIT4         : integer := 4;
constant TAILDESC_RESERVED_BIT3         : integer := 3;
constant TAILDESC_RESERVED_BIT2         : integer := 2;
constant TAILDESC_RESERVED_BIT1         : integer := 1;
constant TAILDESC_RESERVED_BIT0         : integer := 0;


constant PARKPTR_FRMSTR_RSVD_BIT31      : integer := 31;
constant PARKPTR_FRMSTR_S2MM_MSB_BIT    : integer := 28;
constant PARKPTR_FRMSTR_S2MM_LSB_BIT    : integer := 24;
constant PARKPTR_FRMSTR_MM2S_MSB_BIT    : integer := 20;
constant PARKPTR_FRMSTR_MM2S_LSB_BIT    : integer := 16;
constant PARKPTR_FRMSTR_RSVD_BIT15      : integer := 15;
constant PARKPTR_FRMPTR_S2MM_MSB_BIT    : integer := 12;
constant PARKPTR_FRMPTR_S2MM_LSB_BIT    : integer := 8;
constant PARKPTR_FRMPTR_MM2S_MSB_BIT    : integer := 4;
constant PARKPTR_FRMPTR_MM2S_LSB_BIT    : integer := 0;

-- FRAMESTORE
constant FRMSTORE_LSB_BIT               : integer := 0;
constant FRMSTORE_MSB_BIT               : integer := NUM_FRM_STORE_WIDTH-1;

-- LineBuffer Threshold
constant THRESH_LSB_BIT                 : integer := 0;
constant THRESH_MSB_BIT                 : integer := LINEBUFFER_THRESH_WIDTH-1;

-- DataMover Command / Status Constants
constant DATAMOVER_CMDDONE_BIT          : integer := 7;
constant DATAMOVER_SLVERR_BIT           : integer := 6;
constant DATAMOVER_DECERR_BIT           : integer := 5;
constant DATAMOVER_INTERR_BIT           : integer := 4;
constant DATAMOVER_TAGMSB_BIT           : integer := 3;
constant DATAMOVER_TAGLSB_BIT           : integer := 0;


-- Descriptor Word 0 : NXTDESC PTR LS-WORD
-- Descriptor Word 1 : NXTDESC PTR MS-WORD
-- Descriptor Word 2 : STARTADDR PTR LS-WORD
-- Descriptor Word 3 : STARTADDR PTR MS-WORD
-- Descriptor Word 4
constant DESC_WRD4_VSIZE_LSB_BIT  : integer := 0;
constant DESC_WRD4_VSIZE_MSB_BIT  : integer := 12;
-- Descriptor Word 5
constant DESC_WRD5_HSIZE_LSB_BIT  : integer := 0;
constant DESC_WRD5_HSIZE_MSB_BIT  : integer := 15;
-- Descriptor Word 6
constant DESC_WRD6_STRIDE_LSB_BIT : integer := 0;
constant DESC_WRD6_STRIDE_MSB_BIT : integer := 15;
constant DESC_WRD6_FRMDLY_LSB_BIT : integer := 24;
constant DESC_WRD6_FRMDLY_MSB_BIT : integer := 28;




-- DataMover Command / Status Constants
constant DATAMOVER_STS_CMDDONE_BIT  : integer := 7;
constant DATAMOVER_STS_SLVERR_BIT   : integer := 6;
constant DATAMOVER_STS_DECERR_BIT   : integer := 5;
constant DATAMOVER_STS_INTERR_BIT   : integer := 4;
constant DATAMOVER_STS_TAGMSB_BIT   : integer := 3;
constant DATAMOVER_STS_TAGLSB_BIT   : integer := 0;

constant DATAMOVER_STS_TAGEOF_BIT   : integer := 1;
constant DATAMOVER_STS_TLAST_BIT    : integer := 31;

constant DATAMOVER_CMD_BTTLSB_BIT   : integer := 0;
constant DATAMOVER_CMD_BTTMSB_BIT   : integer := 22;
constant DATAMOVER_CMD_TYPE_BIT     : integer := 23;
constant DATAMOVER_CMD_DSALSB_BIT   : integer := 24;
constant DATAMOVER_CMD_DSAMSB_BIT   : integer := 29;
constant DATAMOVER_CMD_EOF_BIT      : integer := 30;
constant DATAMOVER_CMD_DRR_BIT      : integer := 31;
constant DATAMOVER_CMD_ADDRLSB_BIT  : integer := 32;

-- Note: Bit offset require adding ADDR WIDTH to get to actual bit index
constant DATAMOVER_CMD_ADDRMSB_BOFST: integer := 31;
constant DATAMOVER_CMD_TAGLSB_BOFST : integer := 32;
constant DATAMOVER_CMD_TAGMSB_BOFST : integer := 35;
constant DATAMOVER_CMD_RSVLSB_BOFST : integer := 36;
constant DATAMOVER_CMD_RSVMSB_BOFST : integer := 39;


-- Gen-Lock constants
constant MSTR0              : std_logic_vector(3 downto 0) := "0000";
constant MSTR1              : std_logic_vector(3 downto 0) := "0001";
constant MSTR2              : std_logic_vector(3 downto 0) := "0010";
constant MSTR3              : std_logic_vector(3 downto 0) := "0011";
constant MSTR4              : std_logic_vector(3 downto 0) := "0100";
constant MSTR5              : std_logic_vector(3 downto 0) := "0101";
constant MSTR6              : std_logic_vector(3 downto 0) := "0110";
constant MSTR7              : std_logic_vector(3 downto 0) := "0111";
constant MSTR8              : std_logic_vector(3 downto 0) := "1000";
constant MSTR9              : std_logic_vector(3 downto 0) := "1001";
constant MSTR10             : std_logic_vector(3 downto 0) := "1010";
constant MSTR11             : std_logic_vector(3 downto 0) := "1011";
constant MSTR12             : std_logic_vector(3 downto 0) := "1100";
constant MSTR13             : std_logic_vector(3 downto 0) := "1101";
constant MSTR14             : std_logic_vector(3 downto 0) := "1110";
constant MSTR15             : std_logic_vector(3 downto 0) := "1111";

constant MSTR0_LO_INDEX     : integer := 0;
constant MSTR0_HI_INDEX     : integer := 5;

constant MSTR1_LO_INDEX     : integer := 6;
constant MSTR1_HI_INDEX     : integer := 11;

constant MSTR2_LO_INDEX     : integer := 12;
constant MSTR2_HI_INDEX     : integer := 17;

constant MSTR3_LO_INDEX     : integer := 18;
constant MSTR3_HI_INDEX     : integer := 23;

constant MSTR4_LO_INDEX     : integer := 24;
constant MSTR4_HI_INDEX     : integer := 29;

constant MSTR5_LO_INDEX     : integer := 30;
constant MSTR5_HI_INDEX     : integer := 35;

constant MSTR6_LO_INDEX     : integer := 36;
constant MSTR6_HI_INDEX     : integer := 41;

constant MSTR7_LO_INDEX     : integer := 42;
constant MSTR7_HI_INDEX     : integer := 47;

constant MSTR8_LO_INDEX     : integer := 48;
constant MSTR8_HI_INDEX     : integer := 53;

constant MSTR9_LO_INDEX     : integer := 54;
constant MSTR9_HI_INDEX     : integer := 59;

constant MSTR10_LO_INDEX    : integer := 60;
constant MSTR10_HI_INDEX    : integer := 65;

constant MSTR11_LO_INDEX    : integer := 66;
constant MSTR11_HI_INDEX    : integer := 71;

constant MSTR12_LO_INDEX    : integer := 72;
constant MSTR12_HI_INDEX    : integer := 77;

constant MSTR13_LO_INDEX    : integer := 78;
constant MSTR13_HI_INDEX    : integer := 83;

constant MSTR14_LO_INDEX    : integer := 84;
constant MSTR14_HI_INDEX    : integer := 89;

constant MSTR15_LO_INDEX    : integer := 90;
constant MSTR15_HI_INDEX    : integer := 95;



-------------------------------------------------------------------------------
-- Types
-------------------------------------------------------------------------------
constant BITS_PER_REG       : integer := 32;

type STARTADDR_ARRAY_TYPE        is array(natural range <>)
                                 of std_logic_vector(BITS_PER_REG - 1 downto 0);


end axi_vdma_pkg;

-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------
package body axi_vdma_pkg is


    -- coverage off

-------------------------------------------------------------------------------
-- Function to determine minimum bits required for BTT_SIZE field
-------------------------------------------------------------------------------
function required_btt_width (dwidth     : integer;
                             burst_size : integer;
                             btt_width  : integer)
    return integer  is
variable min_width : integer;

begin
    min_width := clog2((dwidth/8)*burst_size)+1;
    if(min_width > btt_width)then
        return min_width;
    else
        return btt_width;
    end if;
end function required_btt_width;

-------------------------------------------------------------------------------
-- String to Integer Function
-------------------------------------------------------------------------------
function string2int(strngbuf: string)
  return integer is
  variable result : integer := 0;
  begin
    for i in 1 to strngbuf'length loop
            case strngbuf(i) is
                    when '0' => result := result*10;
                    when '1' => result := result*10 + 1;
                    when '2' => result := result*10 + 2;
                    when '3' => result := result*10 + 3;
                    when '4' => result := result*10 + 4;
                    when '5' => result := result*10 + 5;
                    when '6' => result := result*10 + 6;
                    when '7' => result := result*10 + 7;
                    when '8' => result := result*10 + 8;
                    when '9' => result := result*10 + 9;
    -- coverage off
                    when others => null;
    -- coverage on
            end case;
    end loop;
    return result;
  end;

--------------------------------------------------------------------------------
--Channel Fsync & Flush decoding
--------------------------------------------------------------------------------

function find_mm2s_fsync      (use_fsync     : integer;
                               mm2s_included : integer;
                               s2mm_included : integer)
            return  integer is
begin
      if   ((mm2s_included = 0 and s2mm_included = 1) or (mm2s_included = 1 and s2mm_included = 0)) then
             if (use_fsync = 0 or  use_fsync = 1)then
             return use_fsync;
             else
             return 0;
             end if;
      elsif(mm2s_included = 1 and s2mm_included = 1) then
             if    (use_fsync = 1 or use_fsync = 2) then
             return 1;
    -- coverage off
             else
             return 0;
    -- coverage on
             end if;
      elsif(mm2s_included = 0 and s2mm_included = 0) then
      return 0;
    -- coverage off
      else
      return 0;
    -- coverage on
      end if;


end function find_mm2s_fsync;

function find_s2mm_fsync_01      (use_s2mm_fsync     : integer)
            return  integer is 
begin
             if (use_s2mm_fsync = 1 or  use_s2mm_fsync = 2)then
             return 1;
             else
             return 0;
             end if;

end function find_s2mm_fsync_01;


function find_s2mm_fsync      (use_fsync     : integer;
                               mm2s_included : integer;
                               s2mm_included : integer)
            return  integer is
begin
      if   ((mm2s_included = 0 and s2mm_included = 1) or (mm2s_included = 1 and s2mm_included = 0)) then
             if (use_fsync = 0 or  use_fsync = 1)then
             return use_fsync;
             else
             return 0;
             end if;
      elsif(mm2s_included = 1 and s2mm_included = 1) then
             if    (use_fsync = 1 or use_fsync = 3) then
             return 1;
    -- coverage off
             else
             return 0;
    -- coverage on
             end if;
      elsif(mm2s_included = 0 and s2mm_included = 0) then
      return 0;
    -- coverage off
      else
      return 0;
    -- coverage on
      end if;


end function find_s2mm_fsync;




function find_mm2s_flush      (use_fsync         : integer;
                               mm2s_included     : integer;
                               s2mm_included     : integer;
                               flush_on_fsync    : integer)
            return  integer is

begin
      if   ((mm2s_included = 0 and s2mm_included = 1) or (mm2s_included = 1 and s2mm_included = 0)) then
             if (use_fsync = 1 and (flush_on_fsync = 0 or flush_on_fsync = 1)) then
             return flush_on_fsync;
             else
             return 0;
             end if;
      elsif(mm2s_included = 1 and s2mm_included = 1) then
             if (use_fsync = 1 and  ( flush_on_fsync = 1 or flush_on_fsync = 2))then
             return 1;
             elsif (use_fsync = 2 and flush_on_fsync = 2)then
             return 1;
             else
             return 0;
             end if;
      elsif(mm2s_included = 0 and s2mm_included = 0) then
      return 0;
    -- coverage off
      else
      return 0;
    -- coverage on
      end if;


end function find_mm2s_flush;



function find_s2mm_flush      (use_fsync         : integer;
                               mm2s_included     : integer;
                               s2mm_included     : integer;
                               flush_on_fsync    : integer)
            return  integer is

begin
      if   ((mm2s_included = 0 and s2mm_included = 1) or (mm2s_included = 1 and s2mm_included = 0)) then
             if (use_fsync = 1 and (flush_on_fsync = 0 or flush_on_fsync = 1)) then
             return flush_on_fsync;
             else
             return 0;
             end if;
      elsif(mm2s_included = 1 and s2mm_included = 1) then
             if (use_fsync = 1 and  ( flush_on_fsync = 1 or flush_on_fsync = 3))then
             return 1;
             elsif (use_fsync = 3 and flush_on_fsync = 3)then
             return 1;
             else
             return 0;
             end if;
      elsif(mm2s_included = 0 and s2mm_included = 0) then
      return 0;
    -- coverage off
      else
      return 0;
    -- coverage on
      end if;


end function find_s2mm_flush;

    -- coverage on

----------------------------------------------------------------------------------------------------------
-- Function to calculate minimum threshold value for MM2S Line buffer based on TDATA, and LineBuffer Depth 
----------------------------------------------------------------------------------------------------------


function calculated_minimum_mm2s_linebuffer_thresh (mm2s_included : integer; mm2s_tdata_dwidth         : integer; mm2s_linebuffer_depth : integer)
            return  integer is



begin
    if(mm2s_included = 0 or mm2s_linebuffer_depth = 0)then
        return 4;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 8) then
        return 1;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 16) then
        return 2;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 32) then
        return 4;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 64) then
        return 8;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 128) then
        return 16;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 256) then
        return 32;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 512) then
        return 64;
    elsif(mm2s_included = 1 and mm2s_linebuffer_depth > 0 and mm2s_tdata_dwidth = 1024) then
        return 128;
        -- coverage off
    else
        return 128 ;
    -- coverage on
    end if;
end function calculated_minimum_mm2s_linebuffer_thresh;


function calculated_minimum_s2mm_linebuffer_thresh (s2mm_included : integer; s2mm_tdata_dwidth         : integer; s2mm_linebuffer_depth : integer)
            return  integer is



begin
    if(s2mm_included = 0 or s2mm_linebuffer_depth = 0)then
        return 4;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 8) then
        return 1;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 16) then
        return 2;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 32) then
        return 4;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 64) then
        return 8;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 128) then
        return 16;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 256) then
        return 32;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 512) then
        return 64;
    elsif(s2mm_included = 1 and s2mm_linebuffer_depth > 0 and s2mm_tdata_dwidth = 1024) then
        return 128;
        -- coverage off
    else
        return 128 ;
    -- coverage on
    end if;
end function calculated_minimum_s2mm_linebuffer_thresh;




-------------------------------------------------------------------------------
-- Function to calculate C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED from C_M_AXIS_MM2S_TDATA_WIDTH 
-------------------------------------------------------------------------------
function calculated_mm2s_tdata_width (mm2s_tdata_dwidth         : integer)
            return  integer is


begin
    if(mm2s_tdata_dwidth <= 16)then
        return mm2s_tdata_dwidth;
    elsif(mm2s_tdata_dwidth > 16 and mm2s_tdata_dwidth <= 32) then
        return 32;
    elsif(mm2s_tdata_dwidth > 32 and mm2s_tdata_dwidth <= 64) then
        return 64;
    elsif(mm2s_tdata_dwidth > 64 and mm2s_tdata_dwidth <= 128) then
        return 128;
    elsif(mm2s_tdata_dwidth > 128 and mm2s_tdata_dwidth <= 256) then
        return 256;
    elsif(mm2s_tdata_dwidth > 256 and mm2s_tdata_dwidth <= 512) then
        return 512;
    elsif(mm2s_tdata_dwidth > 512 and mm2s_tdata_dwidth <= 1024) then
        return 1024;
    -- coverage off
    else
        return 32 ;
    -- coverage on
    end if;
end function calculated_mm2s_tdata_width;


function calculated_s2mm_tdata_width (s2mm_tdata_dwidth         : integer)
            return  integer is


begin
    if(s2mm_tdata_dwidth <= 16)then
        return s2mm_tdata_dwidth;
    elsif(s2mm_tdata_dwidth > 16 and s2mm_tdata_dwidth <= 32) then
        return 32;
    elsif(s2mm_tdata_dwidth > 32 and s2mm_tdata_dwidth <= 64) then
        return 64;
    elsif(s2mm_tdata_dwidth > 64 and s2mm_tdata_dwidth <= 128) then
        return 128;
    elsif(s2mm_tdata_dwidth > 128 and s2mm_tdata_dwidth <= 256) then
        return 256;
    elsif(s2mm_tdata_dwidth > 256 and s2mm_tdata_dwidth <= 512) then
        return 512;
    elsif(s2mm_tdata_dwidth > 512 and s2mm_tdata_dwidth <= 1024) then
        return 1024;
    -- coverage off
    else
        return 32 ;
    -- coverage on
    end if;
end function calculated_s2mm_tdata_width;



function enable_tkeep_connectivity (tdata_dwidth         : integer; tdata_width_calculated : integer; DRE_ON : integer)
            return  integer is

begin

    if(DRE_ON = 1 or ( tdata_width_calculated /=  tdata_dwidth))then
        return 1;

    else
        return 0 ;
    end if;



end function enable_tkeep_connectivity;






-------------------------------------------------------------------------------
-- function to return number of registers depending on mode of operation
-------------------------------------------------------------------------------
function get_num_registers(mode         : integer;
                           sg_num       : integer;
                           regdir_num   : integer)
    return integer is
    begin
        -- 1 = Scatter Gather Mode
        -- 0 = Register Direct Mode
        if(mode = 1)then
            return sg_num;
        else
            return regdir_num;
        end if;
    end;

    -- coverage off
-------------------------------------------------------------------------------
-- function to return Frequency Hertz parameter based on inclusion of sg engine
-------------------------------------------------------------------------------
function hertz_prmtr_select(included        : integer;
                            lite_frequency  : integer;
                            sg_frequency    : integer)
    return integer is
    begin
        -- 1 = Scatter Gather Included
        -- 0 = Scatter Gather Excluded
        if(included = 1)then
            return sg_frequency;
        else
            return lite_frequency;
        end if;
    end;

    -- coverage on
-------------------------------------------------------------------------------
-- function to enable store and forward based on data width mismatch
-- or directly enabled
-------------------------------------------------------------------------------
function enable_snf (sf_enabled         : integer;
                     axi_data_width     : integer;
                     axis_tdata_width   : integer)
    return integer is
    begin
        -- If store and forward enable or data widths do not
        -- match then return 1 to enable snf
        if( (sf_enabled = 1) or (axi_data_width /= axis_tdata_width))then
            return 1;
        else
            return 0;
        end if;
    end;



-------------------------------------------------------------------------------
-- Convert mm2s index to an s2mm index for the base registers
-------------------------------------------------------------------------------
function convert_base_index(channel_is_mm2s : integer;
                            mm2s_index      : integer)
    return integer is
    variable new_index : integer := 0;
    begin
        if(channel_is_mm2s = 1)then
            return mm2s_index;
        else
            new_index := mm2s_index + 12;
            return new_index;
        end if;
    end;

-------------------------------------------------------------------------------
-- Convert mm2s index to an s2mm index for the regdir registers
-------------------------------------------------------------------------------
function convert_regdir_index(channel_is_mm2s : integer;
                              mm2s_index      : integer)
    return integer is
    variable new_index : integer := 0;
    begin
        if(channel_is_mm2s = 1)then
            return mm2s_index;
        else
            --new_index := mm2s_index + 68;
            new_index := mm2s_index + 20;
            return new_index;
        end if;
    end;

-------------------------------------------------------------------------------
-- enable internal genlock bus based on genlock modes and internal genlock
-- parameters.
-------------------------------------------------------------------------------
function enable_internal_genloc(mm2s_enabled    : integer;
				s2mm_enabled    : integer;
				internal_genlock    : integer;
                                mm2s_genlock_mode   : integer;
                                s2mm_genlock_mode   : integer)

    return integer is


    begin
        -- internal genlock turned OFF at parameter or if NOT both channel enabled.
        if(internal_genlock = 0 or mm2s_enabled = 0 or s2mm_enabled = 0)then
            return 0;
        -- at least one channel must be a master and one be a slave
        -- before turning ON the internal genlock bus
        elsif( (mm2s_genlock_mode = 0 and  s2mm_genlock_mode = 1)
             or (mm2s_genlock_mode = 1 and  s2mm_genlock_mode = 0))then
                return 1;
        elsif( (mm2s_genlock_mode = 2 and  s2mm_genlock_mode = 3)
             or (mm2s_genlock_mode = 3 and  s2mm_genlock_mode = 2))then
                return 1;
        -- either both are maters or both are slaves therefore
        -- turn OFF internal genlock bus
        else
            return 0;
        end if;
    end;





end package body axi_vdma_pkg;
