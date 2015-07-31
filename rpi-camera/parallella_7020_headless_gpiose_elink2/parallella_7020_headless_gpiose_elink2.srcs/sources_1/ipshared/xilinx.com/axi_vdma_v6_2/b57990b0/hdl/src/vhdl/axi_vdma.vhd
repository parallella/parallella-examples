-------------------------------------------------------------------------------
-- axi_vdma
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
-- Filename:          axi_vdma.vhd
-- Description: This entity is the top level entity for the AXI VDMA core.
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
--                   |- axi_datamover_v5_1.axi_datamover.vhd (FULL)
--                   |- axi_vdma_v6_2.axi_sg_v4_03.axi_sg.vhd
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

--library axi_sg_v4_03;
--use axi_sg_v4_03.all;

library axi_datamover_v5_1;
use axi_datamover_v5_1.all;

library lib_cdc_v1_0;
library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.max2;

--use proc_common_v4_0.family_support.all;

-------------------------------------------------------------------------------
entity  axi_vdma is
    generic(
        C_S_AXI_LITE_ADDR_WIDTH         : integer range 9 to 9    	:= 9;
            -- Address width of the AXI Lite Interface

        C_S_AXI_LITE_DATA_WIDTH         : integer range 32 to 32    	:= 32;
            -- Data width of the AXI Lite Interface

        C_DLYTMR_RESOLUTION             : integer range 1 to 100000 	:= 125;
            -- Interrupt Delay Timer resolution in usec

        C_PRMRY_IS_ACLK_ASYNC           : integer range 0 to 1      	:= 1;
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - all clocks may be asynchronous.
        -----------------------------------------------------------------------
        -- Video Specific Parameters
        -----------------------------------------------------------------------
        C_ENABLE_VIDPRMTR_READS         : integer range 0 to 1      	:= 1;
            -- Specifies whether video parameters are readable by axi_lite interface
            -- when configure for Register Direct Mode
            -- 0 = Disable Video Parameter Reads (Saves FPGA Resources)
            -- 1 = Enable Video Parameter Reads

        -----------------------------------------------------------------------
        C_DYNAMIC_RESOLUTION           : integer range 0 to 1      	:= 1;
            -- Run time configuration of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 0 = Halt VDMA before writing new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 1 = Run time register configuration for new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE.
        -----------------------------------------------------------------------

        C_NUM_FSTORES                   : integer range 1 to 32     	:= 3;
            -- Number of Frame Stores

        C_USE_FSYNC                     : integer range 0 to 3      	:= 1; 
        -- 2013.1 : Spilt into C_USE_MM2S_FSYNC & C_USE_S2MM_FSYNC. C_USE_FSYNC is no longer used.

        C_USE_MM2S_FSYNC                     : integer range 0 to 1      	:= 0; --2013.1
            -- Specifies MM2S channel operation synchronized to frame sync input
            -- 0 = channel is Free running
            -- 1 = channel uses mm2s_fsync as a frame_sync

        C_USE_S2MM_FSYNC                     : integer range 0 to 2      	:= 2; --2013.1
            -- Specifies MM2S channel operation synchronized to frame sync input
            -- 0 = channel is Free running
            -- 1 = channel uses s2mm_fsync as a frame_sync
            -- 2 = channel uses s2mm_tuser(0) as a frame_sync



        C_FLUSH_ON_FSYNC                : integer range 0 to 3      	:= 1;	--Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Specifies VDMA will flush on frame sync
            -- 0 = Disabled -  both channel halts on error detection
            -- 1 = Enabled - both channel does not halt and will flush on next fsync
            -- 2 = Enabled - ONLY MM2S channel does not halt and will flush on next fsync
            -- 3 = Enabled - ONLY S2MM channel does not halt and will flush on next fsync

        C_INCLUDE_INTERNAL_GENLOCK      : integer range 0 to 1      	:= 1; --Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Include or exclude the use of internal genlock bus.
            -- 0 = Exclude internal genlock bus
            -- 1 = Include internal genlock bus

        -----------------------------------------------------------------------
        -- Scatter Gather Parameters
        -----------------------------------------------------------------------
        C_INCLUDE_SG                    : integer range 0 to 1      	:= 0;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_M_AXI_SG_ADDR_WIDTH           : integer range 32 to 32    	:= 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_M_AXI_SG_DATA_WIDTH           : integer range 32 to 32    	:= 32;
            -- Master AXI Memory Map Data Width for Scatter Gather R/W Port

        -----------------------------------------------------------------------
        -- Memory Map to Stream (MM2S) Parameters
        -----------------------------------------------------------------------
        C_INCLUDE_MM2S                  : integer range 0 to 1      	:= 1;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path

        C_MM2S_GENLOCK_MODE             : integer range 0 to 3      	:= 3;
            -- Specifies the Gen-Lock mode for the MM2S Channel
            -- 0 = Master Mode
            -- 1 = Slave Mode

        C_MM2S_GENLOCK_NUM_MASTERS      : integer range 1 to 16     	:= 1;
            -- Specifies the number of Gen-Lock masters a Gen-Lock slave
            -- can be synchronized with

        C_MM2S_GENLOCK_REPEAT_EN        : integer range 0 to 1      	:= 0;
            -- In flush on frame sync mode specifies whether frame number
            -- will increment on error'ed frame or repeat error'ed frame
            -- 0 = increment frame
            -- 1 = repeat frame

        C_MM2S_SOF_ENABLE               : integer range 0 to 1      	:= 1;	--Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Enable/Disable start of frame generation on tuser(0).
            -- 0 = disable SOF
            -- 1 = enable SOF

        C_INCLUDE_MM2S_DRE              : integer range 0 to 1      	:= 0;
            -- Include or exclude MM2S data realignment engine (DRE)
            -- 0 = Exclude MM2S DRE
            -- 1 = Include MM2S DRE

        C_INCLUDE_MM2S_SF               : integer range 0 to 1      	:= 0;
            -- Include or exclude MM2S Store And Forward Functionality
            -- 0 = Exclude MM2S Store and Forward
            -- 1 = Include MM2S Store and Forward

        C_MM2S_LINEBUFFER_DEPTH         : integer range 0 to 65536  	:= 512;
            -- Depth of line buffer. Width of the line buffer is derived from Streaming width.  

        C_MM2S_LINEBUFFER_THRESH        : integer range 1 to 65536  	:= 4; --Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Almost Empty Threshold. Threshold point at which MM2S line buffer
            -- almost empty flag asserts high.  Must be a resolution of
            -- C_M_AXIS_MM2S_TDATA_WIDTH/8
            -- Minimum valid value is C_M_AXIS_MM2S_TDATA_WIDTH/8
            -- Maximum valid value is C_MM2S_LINEBUFFER_DEPTH

        C_MM2S_MAX_BURST_LENGTH         : integer range 2 to 256   	:= 8;
            -- Maximum burst size in databeats per burst request on MM2S Read Port

        C_M_AXI_MM2S_ADDR_WIDTH         : integer range 32 to 32    	:= 32;
            -- Master AXI Memory Map Address Width for MM2S Read Port

        C_M_AXI_MM2S_DATA_WIDTH         : integer range 32 to 1024  	:= 64;
            -- Master AXI Memory Map Data Width for MM2S Read Port

        C_M_AXIS_MM2S_TDATA_WIDTH       : integer range 8 to 1024   	:= 32;
            -- Master AXI Stream Data Width for MM2S Channel

        C_M_AXIS_MM2S_TUSER_BITS        : integer range 1 to 1      	:= 1;
            -- Master AXI Stream User Width for MM2S Channel

        -----------------------------------------------------------------------
        -- Stream to Memory Map (S2MM) Parameters
        -----------------------------------------------------------------------
        C_INCLUDE_S2MM                  : integer range 0 to 1      	:= 1;
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

        C_S2MM_GENLOCK_MODE             : integer range 0 to 3      	:= 2;
            -- Specifies the Gen-Lock mode for the S2MM Channel
            -- 0 = Master Mode
            -- 1 = Slave Mode

        C_S2MM_GENLOCK_NUM_MASTERS      : integer range 1 to 16     	:= 1;
            -- Specifies the number of Gen-Lock masters a Gen-Lock slave
            -- can be synchronized with

        C_S2MM_GENLOCK_REPEAT_EN        : integer range 0 to 1      	:= 1;
            -- In flush on frame sync mode specifies whether frame number
            -- will increment on error'ed frame or repeat error'ed frame
            -- 0 = increment frame
            -- 1 = repeat frame

        C_S2MM_SOF_ENABLE               : integer range 0 to 1      	:= 1; --Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Enable/Disable start of frame generation on tuser(0). 
            -- 0 = disable SOF
            -- 1 = enable SOF

        C_INCLUDE_S2MM_DRE              : integer range 0 to 1      	:= 0;
            -- Include or exclude S2MM data realignment engine (DRE)
            -- 0 = Exclude S2MM DRE
            -- 1 = Include S2MM DRE

        C_INCLUDE_S2MM_SF               : integer range 0 to 1      	:= 1;
            -- Include or exclude MM2S Store And Forward Functionality
            -- 0 = Exclude S2MM Store and Forward
            -- 1 = Include S2MM Store and Forward

        C_S2MM_LINEBUFFER_DEPTH         : integer range 0 to 65536  	:= 512;
            -- Depth of line buffer. Width of the line buffer is derived from Streaming width.  

        C_S2MM_LINEBUFFER_THRESH        : integer range 1 to 65536  	:= 4; --Interally enabled i.e. user values are not passed to the core  and this parameter is redundant (2013.1/14.5)
            -- Almost Full Threshold. Threshold point at which S2MM line buffer
            -- almost full flag asserts high.  Must be a resolution of
            -- C_M_AXIS_MM2S_TDATA_WIDTH/8
            -- Minimum valid value is C_S_AXIS_S2MM_TDATA_WIDTH/8
            -- Maximum valid value is C_S2MM_LINEBUFFER_DEPTH

        C_S2MM_MAX_BURST_LENGTH         : integer range 2 to 256   	:= 8;
            -- Maximum burst size in data beats per burst request on S2MM Write Port

        C_M_AXI_S2MM_ADDR_WIDTH         : integer range 32 to 32    	:= 32;
            -- Master AXI Memory Map Address Width for S2MM Write Port

        C_M_AXI_S2MM_DATA_WIDTH         : integer range 32 to 1024  	:= 64;
            -- Master AXI Memory Map Data Width for MM2SS2MMWrite Port

        C_S_AXIS_S2MM_TDATA_WIDTH       : integer range 8 to 1024   	:= 32;
            -- Slave AXI Stream Data Width for S2MM Channel

        C_S_AXIS_S2MM_TUSER_BITS        : integer range 1 to 1      	:= 1;
            -- Slave AXI Stream User Width for S2MM Channel



        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '0');		 
            -- Enable debug information

        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 0;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers

        C_ENABLE_DEBUG_INFO_0       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 0
        C_ENABLE_DEBUG_INFO_1       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 1
        C_ENABLE_DEBUG_INFO_2       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 2
        C_ENABLE_DEBUG_INFO_3       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 3
        C_ENABLE_DEBUG_INFO_4       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 4
        C_ENABLE_DEBUG_INFO_5       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 5
        C_ENABLE_DEBUG_INFO_6       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 6
        C_ENABLE_DEBUG_INFO_7       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 7
        C_ENABLE_DEBUG_INFO_8       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 8
        C_ENABLE_DEBUG_INFO_9       : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 9
        C_ENABLE_DEBUG_INFO_10      : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 10
        C_ENABLE_DEBUG_INFO_11      : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 11
        C_ENABLE_DEBUG_INFO_12      : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 12
        C_ENABLE_DEBUG_INFO_13      : integer range 0 to 1      	:= 0;
            -- Enable debug information bit 13
        C_ENABLE_DEBUG_INFO_14      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 14
        C_ENABLE_DEBUG_INFO_15      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 15

        C_INSTANCE                      : string   			:= "axi_vdma";

        C_FAMILY                        : string                    	:= "virtex7"
            -- Target FPGA Device Family
    );
    port (
        -- Control Clocks
        s_axi_lite_aclk             : in  std_logic           		:= '0' ;        --
        m_axi_sg_aclk               : in  std_logic           		:= '0' ;        --

        -- MM2S Clocks
        m_axi_mm2s_aclk             : in  std_logic           		:= '0' ;        --
        m_axis_mm2s_aclk            : in  std_logic           		:= '0' ;        --

        -- S2MM Clocks
        m_axi_s2mm_aclk             : in  std_logic          		:= '0' ;        --
        s_axis_s2mm_aclk            : in  std_logic          		:= '0' ;        --

        axi_resetn                  : in  std_logic          		:= '0' ;        --
                                                                                                --
        -----------------------------------------------------------------------                 --
        -- AXI Lite Control Interface                                                           --
        -----------------------------------------------------------------------                 --
        -- AXI Lite Write Address Channel                                                       --
        s_axi_lite_awvalid          : in  std_logic                    	:= '0' ;        --
        s_axi_lite_awready          : out std_logic                    	       ;        --
        s_axi_lite_awaddr           : in  std_logic_vector                              --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');                   --
                                                                                        --
        -- AXI Lite Write Data Channel                                                  --
        s_axi_lite_wvalid           : in  std_logic                    	:= '0' ;        --
        s_axi_lite_wready           : out std_logic                   	       ;        --
        s_axi_lite_wdata            : in  std_logic_vector                                      --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');                   --
                                                                                                --
        -- AXI Lite Write Response Channel                                                      --
        s_axi_lite_bresp            : out std_logic_vector(1 downto 0)      ;                   --
        s_axi_lite_bvalid           : out std_logic                         ;                   --
        s_axi_lite_bready           : in  std_logic                       := '0'  ;                   --
                                                                                                --
        -- AXI Lite Read Address Channel                                                        --
        s_axi_lite_arvalid          : in  std_logic                       := '0'  ;                   --
        s_axi_lite_arready          : out std_logic                         ;                   --
        s_axi_lite_araddr           : in  std_logic_vector                                      --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');                   --
        s_axi_lite_rvalid           : out std_logic                         ;                   --
        s_axi_lite_rready           : in  std_logic                       := '0'  ;                   --
        s_axi_lite_rdata            : out std_logic_vector                                      --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);                   --
        s_axi_lite_rresp            : out std_logic_vector(1 downto 0)      ;                   --
                                                                                                --
        -----------------------------------------------------------------------                 --
        -- AXI Video Interface                                                                  --
        -----------------------------------------------------------------------                 --
        mm2s_fsync                  : in  std_logic                        := '0' ;                   --
        mm2s_frame_ptr_in           : in  std_logic_vector                                      --
                                        ((C_MM2S_GENLOCK_NUM_MASTERS*6)-1 downto 0) := (others => '0');            --
        mm2s_frame_ptr_out          : out std_logic_vector(5 downto 0);                         --
        s2mm_fsync                  : in  std_logic                         := '0';                   --
        s2mm_frame_ptr_in           : in  std_logic_vector                                      --
                                        ((C_S2MM_GENLOCK_NUM_MASTERS*6)-1 downto 0) := (others => '0');            --
        s2mm_frame_ptr_out          : out std_logic_vector(5 downto 0);                         --
        mm2s_buffer_empty           : out std_logic                         ;                   --
        mm2s_buffer_almost_empty    : out std_logic                         ;                   --
        s2mm_buffer_full            : out std_logic                         ;                   --
        s2mm_buffer_almost_full     : out std_logic                         ;                   --
                                                                                                --
        mm2s_fsync_out              : out std_logic                         ;                   --
        s2mm_fsync_out              : out std_logic                         ;                   --
        mm2s_prmtr_update           : out std_logic                         ;                   --
        s2mm_prmtr_update           : out std_logic                         ;                   --
                                                                                                --
        -----------------------------------------------------------------------                 --
        -- AXI Scatter Gather Interface                                                         --
        -----------------------------------------------------------------------                 --
        -- Scatter Gather Read Address Channel                                                  --
        m_axi_sg_araddr             : out std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        m_axi_sg_arlen              : out std_logic_vector(7 downto 0)      ;                   --
        m_axi_sg_arsize             : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_sg_arburst            : out std_logic_vector(1 downto 0)      ;                   --
        m_axi_sg_arprot             : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_sg_arcache            : out std_logic_vector(3 downto 0)      ;                   --
        m_axi_sg_arvalid            : out std_logic                         ;                   --
        m_axi_sg_arready            : in  std_logic                         := '0';                   --
                                                                                                --
        -- Memory Map to Stream Scatter Gather Read Data Channel                                --
        m_axi_sg_rdata              : in  std_logic_vector                                      --
                                        (C_M_AXI_SG_DATA_WIDTH-1 downto 0)   := (others => '0');                   --
        m_axi_sg_rresp              : in  std_logic_vector(1 downto 0)       := (others => '0')  ;                   --
        m_axi_sg_rlast              : in  std_logic                          := '0';                   --
        m_axi_sg_rvalid             : in  std_logic                          := '0';                   --
        m_axi_sg_rready             : out std_logic                         ;                   --
                                                                                                --
        -----------------------------------------------------------------------                 --
        -- AXI MM2S Channel                                                                     --
        -----------------------------------------------------------------------                 --
        -- Memory Map To Stream Read Address Channel                                            --
        m_axi_mm2s_araddr           : out std_logic_vector                                      --
                                        (C_M_AXI_MM2S_ADDR_WIDTH-1 downto 0);                   --
        m_axi_mm2s_arlen            : out std_logic_vector(7 downto 0)      ;                   --
        m_axi_mm2s_arsize           : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_mm2s_arburst          : out std_logic_vector(1 downto 0)      ;                   --
        m_axi_mm2s_arprot           : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_mm2s_arcache          : out std_logic_vector(3 downto 0)      ;                   --
        m_axi_mm2s_arvalid          : out std_logic                         ;                   --
        m_axi_mm2s_arready          : in  std_logic                          := '0';                   --
                                                                                                --
        -- Memory Map  to Stream Read Data Channel                                              --
        m_axi_mm2s_rdata            : in  std_logic_vector                                      --
                                        (C_M_AXI_MM2S_DATA_WIDTH-1 downto 0) := (others => '0');                   --
        m_axi_mm2s_rresp            : in  std_logic_vector(1 downto 0)       := (others => '0');                   --
        m_axi_mm2s_rlast            : in  std_logic                          := '0';                   --
        m_axi_mm2s_rvalid           : in  std_logic                          := '0';                   --
        m_axi_mm2s_rready           : out std_logic                         ;                   --
                                                                                                --
        -- Memory Map to Stream Stream Interface                                                --
        mm2s_prmry_reset_out_n      : out std_logic                         ;                   --
        m_axis_mm2s_tdata           : out std_logic_vector                                      --
                                        (C_M_AXIS_MM2S_TDATA_WIDTH-1 downto 0);                 --
        m_axis_mm2s_tkeep           : out std_logic_vector                                      --
                                        ((C_M_AXIS_MM2S_TDATA_WIDTH/8)-1 downto 0);             --
        m_axis_mm2s_tuser           : out std_logic_vector                                      --
                                        (C_M_AXIS_MM2S_TUSER_BITS-1 downto 0);                  --
        m_axis_mm2s_tvalid          : out std_logic                         ;                   --
        m_axis_mm2s_tready          : in  std_logic                          := '0';                   --
        m_axis_mm2s_tlast           : out std_logic                         ;                   --
                                                                                                --
        -----------------------------------------------------------------------                 --
        -- AXI S2MM Channel                                                                     --
        -----------------------------------------------------------------------                 --
        -- Stream to Memory Map Write Address Channel                                           --
        m_axi_s2mm_awaddr           : out std_logic_vector                                      --
                                        (C_M_AXI_S2MM_ADDR_WIDTH-1 downto 0);                   --
        m_axi_s2mm_awlen            : out std_logic_vector(7 downto 0)      ;                   --
        m_axi_s2mm_awsize           : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_s2mm_awburst          : out std_logic_vector(1 downto 0)      ;                   --
        m_axi_s2mm_awprot           : out std_logic_vector(2 downto 0)      ;                   --
        m_axi_s2mm_awcache          : out std_logic_vector(3 downto 0)      ;                   --
        m_axi_s2mm_awvalid          : out std_logic                         ;                   --
        m_axi_s2mm_awready          : in  std_logic                         := '0';                   --
                                                                                                --
        -- Stream to Memory Map Write Data Channel                                              --
        m_axi_s2mm_wdata            : out std_logic_vector                                      --
                                        (C_M_AXI_S2MM_DATA_WIDTH-1 downto 0);                   --
        m_axi_s2mm_wstrb            : out std_logic_vector                                      --
                                        ((C_M_AXI_S2MM_DATA_WIDTH/8)-1 downto 0);               --
        m_axi_s2mm_wlast            : out std_logic                         ;                   --
        m_axi_s2mm_wvalid           : out std_logic                         ;                   --
        m_axi_s2mm_wready           : in  std_logic                         := '0';                   --
                                                                                                --
        -- Stream to Memory Map Write Response Channel                                          --
        m_axi_s2mm_bresp            : in  std_logic_vector(1 downto 0)       := (others => '0');                   --
        m_axi_s2mm_bvalid           : in  std_logic                         := '0';                   --
        m_axi_s2mm_bready           : out std_logic                         ;                   --
                                                                                                --
        -- Stream to Memory Map Steam Interface                                                 --
        s2mm_prmry_reset_out_n      : out std_logic                         ;                   --
        s_axis_s2mm_tdata           : in  std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TDATA_WIDTH-1 downto 0) := (others => '0');                 --
        s_axis_s2mm_tkeep           : in  std_logic_vector                                      --
                                        ((C_S_AXIS_S2MM_TDATA_WIDTH/8)-1 downto 0) := (others => '0');             --
        s_axis_s2mm_tuser           : in  std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TUSER_BITS-1 downto 0) := (others => '0');                  --
        s_axis_s2mm_tvalid          : in  std_logic                         := '0';                   --
        s_axis_s2mm_tready          : out std_logic                         ;                   --
        s_axis_s2mm_tlast           : in  std_logic                         := '0';                   --
                                                                                                --
                                                                                                --
        -- MM2S and S2MM Channel Interrupts                                                     --
        mm2s_introut                : out std_logic                         ;                   --
        s2mm_introut                : out std_logic                         ;                   --
        axi_vdma_tstvec             : out std_logic_vector(63 downto 0)                         --
    );

-----------------------------------------------------------------
-- Start of PSFUtil MPD attributes
-----------------------------------------------------------------
attribute IP_GROUP                  : string;
attribute IP_GROUP     of axi_vdma   : entity   is "LOGICORE";

attribute IPTYPE                    : string;
attribute IPTYPE       of axi_vdma   : entity   is "PERIPHERAL";

attribute RUN_NGCBUILD              : string;
attribute RUN_NGCBUILD of axi_vdma   : entity   is "TRUE";

-----------------------------------------------------------------
-- End of PSFUtil MPD attributes
-----------------------------------------------------------------
end axi_vdma;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

--constant C_CORE_GENERATION_INFO : string := C_INSTANCE &  ",axi_vdma,{"
--& "C_FAMILY= "    & C_FAMILY
--& ",C_INSTANCE = " & C_INSTANCE   
--& ",C_DLYTMR_RESOLUTION= "    & integer'image(C_DLYTMR_RESOLUTION)
--& ",C_PRMRY_IS_ACLK_ASYNC= "    & integer'image(C_PRMRY_IS_ACLK_ASYNC)
--& ",C_ENABLE_VIDPRMTR_READS= "    & integer'image(C_ENABLE_VIDPRMTR_READS)
--& ",C_DYNAMIC_RESOLUTION= "    & integer'image(C_DYNAMIC_RESOLUTION)
--& ",C_NUM_FSTORES= "    & integer'image(C_NUM_FSTORES)
--& ",C_USE_MM2S_FSYNC= "    & integer'image(C_USE_MM2S_FSYNC)
--& ",C_USE_S2MM_FSYNC= "    & integer'image(C_USE_S2MM_FSYNC)
--& ",C_INCLUDE_SG= "    & integer'image(C_INCLUDE_SG)
--& ",C_INCLUDE_MM2S= "      & integer'image(C_INCLUDE_MM2S)
--& ",C_MM2S_GENLOCK_MODE= "      & integer'image(C_MM2S_GENLOCK_MODE)
--& ",C_MM2S_GENLOCK_NUM_MASTERS= "      & integer'image(C_MM2S_GENLOCK_NUM_MASTERS)
--& ",C_INCLUDE_MM2S_DRE= "      & integer'image(C_INCLUDE_MM2S_DRE)
--& ",C_MM2S_LINEBUFFER_DEPTH= "      & integer'image(C_MM2S_LINEBUFFER_DEPTH)
--& ",C_MM2S_MAX_BURST_LENGTH= "      & integer'image(C_MM2S_MAX_BURST_LENGTH)
--& ",C_M_AXI_MM2S_DATA_WIDTH = "  & integer'image(C_M_AXI_MM2S_DATA_WIDTH)
--& ",C_M_AXIS_MM2S_TDATA_WIDTH = "  & integer'image(C_M_AXIS_MM2S_TDATA_WIDTH)
--& ",C_INCLUDE_S2MM= "      & integer'image(C_INCLUDE_S2MM)
--& ",C_S2MM_GENLOCK_MODE= "      & integer'image(C_S2MM_GENLOCK_MODE)
--& ",C_S2MM_GENLOCK_NUM_MASTERS= "      & integer'image(C_S2MM_GENLOCK_NUM_MASTERS)
--& ",C_INCLUDE_S2MM_DRE= "      & integer'image(C_INCLUDE_S2MM_DRE)
--& ",C_S2MM_LINEBUFFER_DEPTH= "      & integer'image(C_S2MM_LINEBUFFER_DEPTH)
--& ",C_S2MM_MAX_BURST_LENGTH= "      & integer'image(C_S2MM_MAX_BURST_LENGTH)
--& ",C_M_AXI_S2MM_DATA_WIDTH= "      & integer'image(C_M_AXI_S2MM_DATA_WIDTH)
--& ",C_S_AXIS_S2MM_TDATA_WIDTH= "      & integer'image(C_S_AXIS_S2MM_TDATA_WIDTH)
--& "}";
--attribute CORE_GENERATION_INFO : string;
--attribute CORE_GENERATION_INFO of implementation : architecture is C_CORE_GENERATION_INFO;
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Major Version number 0, 1, 2, 3 etc.
constant VERSION_MAJOR                  : std_logic_vector (3 downto 0) := X"6" ;
-- Minor Version Number 00, 01, 02, etc.
constant VERSION_MINOR                  : std_logic_vector (7 downto 0) := X"20";
-- Version Revision character (EDK) a,b,c,etc
constant VERSION_REVISION               : std_logic_vector (3 downto 0) := X"0" ;
-- Internal build number
constant REVISION_NUMBER                : string := "Build Number: P80";

--*****************************************************************************
--** Scatter Gather Engine Configuration
--*****************************************************************************
constant SG_INCLUDE_DESC_QUEUE          : integer range 0 to 1          := 0;
            -- Include or Exclude Scatter Gather Descriptor Queuing
            -- 0 = Exclude SG Descriptor Queuing
            -- 1 = Include SG Descriptor Queuing
-- Number of Fetch Descriptors to Queue
constant SG_FTCH_DESC2QUEUE             : integer := SG_INCLUDE_DESC_QUEUE * 4;
-- Number of Update Descriptors to Queue
constant SG_UPDT_DESC2QUEUE             : integer := SG_INCLUDE_DESC_QUEUE * 4;
-- Number of fetch words per descriptor for channel 1 (MM2S)
constant SG_CH1_WORDS_TO_FETCH          : integer := 7;
-- Number of fetch words per descriptor for channel 2 (S2MM)
constant SG_CH2_WORDS_TO_FETCH          : integer := 7;
-- Number of update words per descriptor for channel 1 (MM2S)
constant SG_CH1_WORDS_TO_UPDATE         : integer := 1; -- No Descriptor update for video
-- Number of update words per descriptor for channel 2 (S2MM)
constant SG_CH2_WORDS_TO_UPDATE         : integer := 1; -- No Descriptor update for video
-- First word offset (referenced to descriptor beginning) to update for channel 1 (MM2S)
constant SG_CH1_FIRST_UPDATE_WORD       : integer := 0; -- No Descriptor update for video
-- First word offset (referenced to descriptor beginning) to update for channel 2 (MM2S)
constant SG_CH2_FIRST_UPDATE_WORD       : integer := 0; -- No Descriptor update for video
-- Enable stale descriptor check for channel 1
constant SG_CH1_ENBL_STALE_ERR        : integer := 0;
-- Enable stale descriptor check for channel 2
constant SG_CH2_ENBL_STALE_ERR        : integer := 0;
-- Width of descriptor fetch bus
constant M_AXIS_SG_TDATA_WIDTH          : integer := 32;
-- Width of descriptor pointer update bus
constant S_AXIS_UPDPTR_TDATA_WIDTH      : integer := 32;
-- Width of descriptor status update bus
constant S_AXIS_UPDSTS_TDATA_WIDTH      : integer := 33;
-- Include SG Descriptor Updates
constant EXCLUDE_DESC_UPDATE            : integer := 0;  -- No Descriptor update for video
-- Include SG Interrupt Logic
constant EXCLUDE_INTRPT                 : integer := 0; -- Interrupt logic external to sg engine
-- Include SG Delay Interrupt
constant INCLUDE_DLYTMR                 : integer := 1;
constant EXCLUDE_DLYTMR                 : integer := 0;

--*****************************************************************************
--** General/Misc Constants
--*****************************************************************************

--constant C_USE_MM2S_FSYNC     : integer :=find_mm2s_fsync(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM);


--constant C_USE_S2MM_FSYNC     : integer :=find_s2mm_fsync(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM);
constant C_USE_S2MM_FSYNC_01     : integer :=find_s2mm_fsync_01(C_USE_S2MM_FSYNC);

--constant ENABLE_FLUSH_ON_MM2S_FSYNC          : integer :=find_mm2s_flush(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM,C_FLUSH_ON_FSYNC);
--constant ENABLE_FLUSH_ON_S2MM_FSYNC          : integer :=find_s2mm_flush(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM,C_FLUSH_ON_FSYNC);




 
--constant ENABLE_FLUSH_ON_MM2S_FSYNC          : integer :=find_mm2s_flush(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM,C_USE_FSYNC);
--constant ENABLE_FLUSH_ON_S2MM_FSYNC          : integer :=find_s2mm_flush(C_USE_FSYNC,C_INCLUDE_MM2S,C_INCLUDE_S2MM,C_USE_FSYNC);

 
constant ENABLE_FLUSH_ON_MM2S_FSYNC          : integer := C_USE_MM2S_FSYNC;
constant ENABLE_FLUSH_ON_S2MM_FSYNC          : integer := C_USE_S2MM_FSYNC_01;



--*****************************************************************************
--** AXI LITE Interface Constants
--*****************************************************************************
--constant TOTAL_NUM_REGISTER     : integer := NUM_REG_TOTAL_REGDIR;
constant TOTAL_NUM_REGISTER     : integer := get_num_registers(C_INCLUDE_SG,NUM_REG_TOTAL_SG,NUM_REG_TOTAL_REGDIR);








constant C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED     : integer := calculated_mm2s_tdata_width(C_M_AXIS_MM2S_TDATA_WIDTH);
constant C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED     : integer := calculated_s2mm_tdata_width(C_S_AXIS_S2MM_TDATA_WIDTH);



constant C_MM2S_ENABLE_TKEEP     : integer := enable_tkeep_connectivity(C_M_AXIS_MM2S_TDATA_WIDTH,C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED,C_INCLUDE_MM2S_DRE);
constant C_S2MM_ENABLE_TKEEP     : integer := enable_tkeep_connectivity(C_S_AXIS_S2MM_TDATA_WIDTH,C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED,C_INCLUDE_S2MM_DRE);

-- Specifies to register module which channel is which
constant CHANNEL_IS_MM2S        : integer := 1;
constant CHANNEL_IS_S2MM        : integer := 0;

--*****************************************************************************
--** DataMover General Constants
--*****************************************************************************
-- Primary DataMover Configuration
-- DataMover Command / Status FIFO Depth
-- Note :Set maximum to the number of update descriptors to queue, to prevent lock up do to
-- update data fifo full before
constant DM_CMDSTS_FIFO_DEPTH           : integer := 4;

-- DataMover Include Status FIFO
constant DM_INCLUDE_STS_FIFO            : integer := 1;

-- DataMover outstanding address request fifo depth
constant DM_ADDR_PIPE_DEPTH             : integer := 4;

-- Base status vector width
constant BASE_STATUS_WIDTH              : integer := 8;

-- AXI DataMover Full mode value
constant AXI_FULL_MODE                  : integer := 1;

-- Datamover clock always synchronous
constant DM_CLOCK_SYNC                  : integer := 0;

-- Always allow datamover address requests
constant ALWAYS_ALLOW                   : std_logic := '1';

constant ZERO_VALUE                     : std_logic_vector(1023 downto 0) := (others => '0');

--*****************************************************************************
--** S2MM DataMover Specific Constants
--*****************************************************************************
-- AXI DataMover mode for S2MM Channel (0 if channel not included)
constant S2MM_AXI_FULL_MODE             : integer := C_INCLUDE_S2MM * AXI_FULL_MODE;

-- CR591965 - Modified for flush on frame sync
-- Enable indeterminate BTT on datamover when S2MM Store And Forward Present
-- In this mode, the DataMovers S2MM store and forward buffer will be used
-- and underflow and overflow will be detected via receive byte compare
-- Enable indeterminate BTT on datamover when S2MM flush on frame sync is
-- enabled allowing S2MM AXIS stream absorption and prevent datamover
-- halt.  Overflow and Underfow error detected external to datamover
-- in axi_vdma_cmdsts.vhd
constant DM_SUPPORT_INDET_BTT           : integer := 1;


-- Indterminate BTT Mode additional status vector width
constant INDETBTT_ADDED_STS_WIDTH       : integer := 24;

-- DataMover status width is based on mode of operation
constant S2MM_DM_STATUS_WIDTH           : integer := BASE_STATUS_WIDTH
                                                  + (DM_SUPPORT_INDET_BTT * INDETBTT_ADDED_STS_WIDTH);
-- Never extend on S2MM
constant S2MM_DM_CMD_EXTENDED           : integer := 0;

-- Minimum value required for length width based on burst size and stream dwidth
-- If hsize is too small based on setting of burst size and
-- dwidth then this will reset the width to a larger mimimum requirement.
constant S2MM_DM_BTT_LENGTH_WIDTH       : integer := required_btt_width(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED,
                                                                   C_S2MM_MAX_BURST_LENGTH,
                                                                   HSIZE_DWIDTH);
constant C_INCLUDE_S2MM_SF_INT           : integer := 1;

-- Enable store and forward on datamover if data widths are mismatched (allows upsizers
-- to be instantiated) or when enabled by user.
constant DM_S2MM_INCLUDE_SF             : integer := enable_snf(C_INCLUDE_S2MM_SF_INT,
                                                                C_M_AXI_S2MM_DATA_WIDTH,
                                                                C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED);

--*****************************************************************************
--** MM2S DataMover Specific Constants
--*****************************************************************************
-- AXI DataMover mode for MM2S Channel (0 if channel not included)
constant MM2S_AXI_FULL_MODE             : integer := C_INCLUDE_MM2S * AXI_FULL_MODE;

-- Never extend on MM2S
constant MM2S_DM_CMD_NOT_EXTENDED       : integer := 0;

-- DataMover status width - fixed to 8 for MM2S
constant MM2S_DM_STATUS_WIDTH           : integer := BASE_STATUS_WIDTH;

-- Minimum value required for length width based on burst size and stream dwidth
-- If hsize is too small based on setting of burst size and
-- dwidth then this will reset the width to a larger mimimum requirement.
constant MM2S_DM_BTT_LENGTH_WIDTH       : integer := required_btt_width(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED,
                                                                  C_MM2S_MAX_BURST_LENGTH,
                                                                  HSIZE_DWIDTH);

-- Enable store and forward on datamover if data widths are mismatched (allows upsizers
-- to be instantiated) or when enabled by user.


----constant DM_MM2S_INCLUDE_SF             : integer := enable_snf(C_INCLUDE_MM2S_SF,
----                                                                C_M_AXI_MM2S_DATA_WIDTH,
----                                                                C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED);
----

constant DM_MM2S_INCLUDE_SF             : integer := enable_snf(0,
                                                                C_M_AXI_MM2S_DATA_WIDTH,
                                                                C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED);





--constant DM_MM2S_INCLUDE_SF             : integer := 0; 


--*****************************************************************************
--** Line Buffer Constants
--*****************************************************************************
-- For LineBuffer, track vertical lines to allow de-assertion of tready
-- when s2mm finished with frame. MM2S does not need to track lines
constant TRACK_NO_LINES                 : integer := 0;
constant TRACK_LINES                    : integer := 1;
-- zero vector of vsize width used to tie off mm2s line tracking ports
constant VSIZE_ZERO                     : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := (others => '0');

-- Linebuffer default Almost Empty Threshold and Almost Full threshold
constant LINEBUFFER_AE_THRESH           : integer := 1;
constant LINEBUFFER_AF_THRESH           : integer := max2(1,C_MM2S_LINEBUFFER_DEPTH/2);

-- Include and Exclude settings for linebuffer skid buffers
constant INCLUDE_MSTR_SKID_BUFFER       : integer := 1;
constant EXCLUDE_MSTR_SKID_BUFFER       : integer := 0;
constant INCLUDE_SLV_SKID_BUFFER        : integer := 1;
constant EXCLUDE_SLV_SKID_BUFFER        : integer := 0;



-------- Force a depth of 512 minimum if asynchronous clocks enabled and a 128 minimum for synchronous mode
-------- Also converts depth in bytes to depth in data beats
------constant MM2S_LINEBUFFER_DEPTH          : integer := max2(128,(max2((C_MM2S_LINEBUFFER_DEPTH/(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8)),
------                                                          (C_PRMRY_IS_ACLK_ASYNC*512))));
------
-------- Force a depth of 512 minimum if asynchronous clocks enabled and a 128 minimum for synchronous mode
-------- Also converts depth in bytes to depth in data beats
------constant S2MM_LINEBUFFER_DEPTH          : integer := max2(128,(max2((C_S2MM_LINEBUFFER_DEPTH/(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED/8)),
------                                                          (C_PRMRY_IS_ACLK_ASYNC*512))));
------


--2013.1

--constant MM2S_LINEBUFFER_DEPTH          : integer :=  C_MM2S_LINEBUFFER_DEPTH;
--constant S2MM_LINEBUFFER_DEPTH          : integer :=  C_S2MM_LINEBUFFER_DEPTH; 
-- Force a depth of 512 minimum if asynchronous clocks enabled and a 128 minimum for synchronous mode
constant MM2S_LINEBUFFER_DEPTH          : integer := max2(128,(max2(C_MM2S_LINEBUFFER_DEPTH,(C_PRMRY_IS_ACLK_ASYNC*512))));

-- Force a depth of 512 minimum if asynchronous clocks enabled and a 128 minimum for synchronous mode
constant S2MM_LINEBUFFER_DEPTH          : integer := max2(128,(max2(C_S2MM_LINEBUFFER_DEPTH,(C_PRMRY_IS_ACLK_ASYNC*512))));


-- Enable SOF only for external frame sync and when SOF Enable parameter set
----constant MM2S_SOF_ENABLE                : integer := C_USE_MM2S_FSYNC * C_MM2S_SOF_ENABLE;
--constant MM2S_SOF_ENABLE                : integer := C_MM2S_SOF_ENABLE;
constant MM2S_SOF_ENABLE                : integer := 1;
--constant S2MM_SOF_ENABLE                : integer := C_USE_S2MM_FSYNC * C_S2MM_SOF_ENABLE;
--constant S2MM_SOF_ENABLE                : integer := C_USE_S2MM_FSYNC ;
constant S2MM_SOF_ENABLE                : integer := C_USE_S2MM_FSYNC_01 ;


--*****************************************************************************
--** GenLock Constants
--*****************************************************************************
-- GenLock Data Widths for Clock Domain Crossing Module
constant MM2S_GENLOCK_SLVE_PTR_DWIDTH   : integer := (C_MM2S_GENLOCK_NUM_MASTERS*NUM_FRM_STORE_WIDTH);
constant S2MM_GENLOCK_SLVE_PTR_DWIDTH   : integer := (C_S2MM_GENLOCK_NUM_MASTERS*NUM_FRM_STORE_WIDTH);

--constant INTERNAL_GENLOCK_ENABLE        : integer := enable_internal_genloc(C_INCLUDE_MM2S, C_INCLUDE_S2MM, C_INCLUDE_INTERNAL_GENLOCK,
--                                                                            C_MM2S_GENLOCK_MODE,
--                                                                            C_S2MM_GENLOCK_MODE);
--

constant INTERNAL_GENLOCK_ENABLE        : integer := enable_internal_genloc(C_INCLUDE_MM2S, C_INCLUDE_S2MM, 1,
                                                                            C_MM2S_GENLOCK_MODE,
                                                                            C_S2MM_GENLOCK_MODE);


constant C_MM2S_LINEBUFFER_THRESH_INT : integer := calculated_minimum_mm2s_linebuffer_thresh(C_INCLUDE_MM2S, C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED, C_MM2S_LINEBUFFER_DEPTH);
constant C_S2MM_LINEBUFFER_THRESH_INT : integer := calculated_minimum_s2mm_linebuffer_thresh(C_INCLUDE_S2MM, C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED, C_S2MM_LINEBUFFER_DEPTH);

Constant C_ROOT_FAMILY        : string  := C_FAMILY;  -- function from family_support.vhd



-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal mm2s_prmry_resetn                : std_logic := '1';     -- AXI  MM2S Primary Reset
signal mm2s_dm_prmry_resetn             : std_logic := '1';     -- AXI  MM2S DataMover Primary Reset (Raw)
signal mm2s_axis_resetn                 : std_logic := '1';     -- AXIS MM2S Primary Reset
signal mm2s_axis_linebuf_reset_out                 : std_logic := '1';     -- AXIS MM2S Primary Reset
signal s2mm_axis_linebuf_reset_out                 : std_logic := '1';     -- AXIS MM2S Primary Reset
signal s2mm_axis_linebuf_reset_out_inv                 : std_logic := '1';     -- AXIS MM2S Primary Reset
signal s2mm_prmry_resetn                : std_logic := '1';     -- AXI  S2MM Primary Reset
signal s2mm_dm_prmry_resetn             : std_logic := '1';     -- AXI  S2MM DataMover Primary Reset (Raw)
signal s2mm_axis_resetn                 : std_logic := '1';     -- AXIS S2MM Primary Reset
signal s_axi_lite_resetn                : std_logic := '1';     -- AXI  Lite Interface Reset (Hard Only)
signal m_axi_sg_resetn                  : std_logic := '1';     -- AXI  Scatter Gather Interface Reset
signal m_axi_dm_sg_resetn               : std_logic := '1';     -- AXI  Scatter Gather Interface Reset (Raw)
signal mm2s_hrd_resetn                  : std_logic := '1';     -- AXI Hard Reset Only for MM2S
signal s2mm_hrd_resetn                  : std_logic := '1';     -- AXI Hard Reset Only for S2MM


-- MM2S Register Module Signals
signal mm2s_stop                        : std_logic := '0';
signal mm2s_stop_reg                        : std_logic := '0';
signal mm2s_halted_clr                  : std_logic := '0';
signal mm2s_halted_set                  : std_logic := '0';
signal mm2s_idle_set                    : std_logic := '0';
signal mm2s_idle_clr                    : std_logic := '0';
signal mm2s_dma_interr_set              : std_logic := '0';
signal mm2s_dma_interr_set_minus_frame_errors              : std_logic := '0';
signal mm2s_dma_slverr_set              : std_logic := '0';
signal mm2s_dma_decerr_set              : std_logic := '0';
signal mm2s_ioc_irq_set                 : std_logic := '0';
signal mm2s_dly_irq_set                 : std_logic := '0';
signal mm2s_irqdelay_status             : std_logic_vector(7 downto 0) := (others => '0');
signal mm2s_irqthresh_status            : std_logic_vector(7 downto 0) := (others => '0');
signal mm2s_new_curdesc_wren            : std_logic := '0';
signal mm2s_new_curdesc                 : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal mm2s_tailpntr_updated            : std_logic := '0';
signal mm2s_dmacr                       : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal mm2s_dmasr                       : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal mm2s_curdesc                     : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal mm2s_taildesc                    : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal mm2s_num_frame_store             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)      := (others => '0');
signal mm2s_linebuf_threshold           : std_logic_vector(THRESH_MSB_BIT downto 0)           := (others => '0');
signal mm2s_packet_sof                  : std_logic := '0';
signal mm2s_all_idle                    : std_logic := '0';
signal mm2s_cmdsts_idle                 : std_logic := '0';
signal mm2s_frame_number                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_chnl_current_frame                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_genlock_pair_frame                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_crnt_vsize                  : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal mm2s_crnt_vsize_d2                  : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal mm2s_dlyirq_dsble                : std_logic := '0';
signal mm2s_irqthresh_rstdsbl           : std_logic := '0';
signal mm2s_valid_video_prmtrs          : std_logic := '0';
signal mm2s_all_lines_xfred             : std_logic := '0';
signal mm2s_all_lines_xfred_s           : std_logic := '0';
signal mm2s_all_lines_xfred_s_dwidth    : std_logic := '0';
signal mm2s_fsize_mismatch_err          : std_logic := '0'; -- CR591965
signal mm2s_lsize_mismatch_err          : std_logic := '0'; -- CR591965
signal mm2s_lsize_more_mismatch_err          : std_logic := '0'; -- CR591965
signal mm2s_frame_ptr_out_i             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
signal mm2s_to_s2mm_fsync               : std_logic := '0';

-- MM2S Register Direct Support
signal mm2s_regdir_idle                 : std_logic := '0';
signal mm2s_prmtr_updt_complete         : std_logic := '0';
signal mm2s_reg_module_vsize            : std_logic_vector(VSIZE_DWIDTH-1 downto 0);
signal mm2s_reg_module_hsize            : std_logic_vector(HSIZE_DWIDTH-1 downto 0);
signal mm2s_reg_module_stride           : std_logic_vector(STRIDE_DWIDTH-1 downto 0);
signal mm2s_reg_module_frmdly           : std_logic_vector(FRMDLY_DWIDTH-1 downto 0);
signal mm2s_reg_module_strt_addr        : STARTADDR_ARRAY_TYPE(0 to C_NUM_FSTORES - 1);

-- MM2S Register Interface Signals
signal mm2s_axi2ip_wrce                 : std_logic_vector(TOTAL_NUM_REGISTER-1 downto 0)       := (others => '0');
signal mm2s_axi2ip_wrdata               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0')      ;
signal mm2s_axi2ip_rdaddr               : std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0')      ;
--signal mm2s_axi2ip_rden                 : std_logic := '0';
signal mm2s_ip2axi_rddata               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0')      ;
--signal mm2s_ip2axi_rddata_valid         : std_logic := '0';
signal mm2s_ip2axi_frame_ptr_ref        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_ip2axi_frame_store          : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_ip2axi_introut              : std_logic := '0';

-- MM2S Scatter Gather clock domain crossing signals
signal mm2s_cdc2sg_run_stop             : std_logic := '0';
signal mm2s_cdc2sg_stop                 : std_logic := '0';
signal mm2s_cdc2sg_taildesc_wren        : std_logic := '0';
signal mm2s_cdc2sg_taildesc             : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal mm2s_cdc2sg_curdesc              : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal mm2s_sg2cdc_ftch_idle            : std_logic := '0';
signal mm2s_sg2cdc_ftch_interr_set      : std_logic := '0';
signal mm2s_sg2cdc_ftch_slverr_set      : std_logic := '0';
signal mm2s_sg2cdc_ftch_decerr_set      : std_logic := '0';

-- MM2S DMA Controller Signals
signal mm2s_ftch_idle                   : std_logic := '0';
signal mm2s_updt_ioc_irq_set            : std_logic := '0';
signal mm2s_irqthresh_wren              : std_logic := '0';
signal mm2s_irqdelay_wren               : std_logic := '0';
signal mm2s_ftchcmdsts_idle             : std_logic := '0';

-- SG MM2S Descriptor Fetch AXI Stream IN
signal m_axis_mm2s_ftch_tdata           : std_logic_vector(M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal m_axis_mm2s_ftch_tvalid          : std_logic := '0';
signal m_axis_mm2s_ftch_tready          : std_logic := '0';
signal m_axis_mm2s_ftch_tlast           : std_logic := '0';

-- DataMover MM2S Command Stream Signals
signal s_axis_mm2s_cmd_tvalid           : std_logic := '0';
signal s_axis_mm2s_cmd_tready           : std_logic := '0';
signal s_axis_mm2s_cmd_tdata            : std_logic_vector
                                            ((C_M_AXI_MM2S_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0) := (others => '0');
-- DataMover MM2S Status Stream Signals
signal m_axis_mm2s_sts_tvalid           : std_logic := '0';
signal m_axis_mm2s_sts_tready           : std_logic := '0';
signal m_axis_mm2s_sts_tdata            : std_logic_vector(MM2S_DM_STATUS_WIDTH - 1 downto 0) := (others => '0');   -- CR608521
signal m_axis_mm2s_sts_tkeep            : std_logic_vector((MM2S_DM_STATUS_WIDTH/8)-1 downto 0) := (others => '0'); -- CR608521
signal mm2s_err                         : std_logic := '0';
signal mm2s_halt                        : std_logic := '0';
signal mm2s_halt_reg                        : std_logic := '0';
signal mm2s_halt_cmplt                  : std_logic := '0';

-- DataMover To Line Buffer AXI Stream Signals
signal dm2linebuf_mm2s_tdata            : std_logic_vector(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED-1 downto 0);
signal dm2linebuf_mm2s_tkeep            : std_logic_vector((C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8)-1 downto 0);
signal dm2linebuf_mm2s_tlast            : std_logic := '0';
signal dm2linebuf_mm2s_tvalid           : std_logic := '0';
signal linebuf2dm_mm2s_tready           : std_logic := '0';

-- MM2S Error Status Control
signal mm2s_ftch_interr_set             : std_logic := '0';
signal mm2s_ftch_slverr_set             : std_logic := '0';
signal mm2s_ftch_decerr_set             : std_logic := '0';

-- MM2S Soft Reset support
signal mm2s_soft_reset                  : std_logic := '0';
signal mm2s_soft_reset_clr              : std_logic := '0';

-- MM2S SOF generation support
signal m_axis_mm2s_tvalid_i             : std_logic := '0';
signal m_axis_mm2s_tvalid_i_axis_dw_conv             : std_logic := '0';
signal m_axis_mm2s_tlast_i              : std_logic := '0';
signal m_axis_mm2s_tlast_i_axis_dw_conv              : std_logic := '0';

signal              s_axis_s2mm_tdata_i           :   std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED-1 downto 0) := (others => '0');                 --
signal              s_axis_s2mm_tkeep_i           :   std_logic_vector                                      --
                                        ((C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED/8)-1 downto 0) := (others => '0');             --
signal              s_axis_s2mm_tuser_i           :   std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TUSER_BITS-1 downto 0) := (others => '0');                  --
signal              s_axis_s2mm_tvalid_i          :   std_logic                         ;                   --
signal              s_axis_s2mm_tvalid_int          :   std_logic                         ;                   --
signal              s_axis_s2mm_tlast_i           :   std_logic ;            


signal         m_axis_mm2s_tdata_i           : std_logic_vector                                      --
                                        (C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED-1 downto 0) := (others => '0');                 --
signal         m_axis_mm2s_tkeep_i           : std_logic_vector                                      --
                                        ((C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8)-1 downto 0) := (others => '0');             --
signal         m_axis_mm2s_tuser_i           : std_logic_vector                                      --
                                        (C_M_AXIS_MM2S_TUSER_BITS-1 downto 0) := (others => '0');                  --
signal         m_axis_mm2s_tready_i          : std_logic                         ;                   --
-- S2MM Register Module Signals
signal s2mm_stop                        : std_logic := '0';
signal s2mm_halted_clr                  : std_logic := '0';
signal s2mm_halted_set                  : std_logic := '0';
signal s2mm_idle_set                    : std_logic := '0';
signal s2mm_idle_clr                    : std_logic := '0';
signal s2mm_dma_interr_set              : std_logic := '0';
signal s2mm_dma_interr_set_minus_frame_errors              : std_logic := '0';
signal s2mm_dma_slverr_set              : std_logic := '0';
signal s2mm_dma_decerr_set              : std_logic := '0';
signal s2mm_ioc_irq_set                 : std_logic := '0';
signal s2mm_dly_irq_set                 : std_logic := '0';
signal s2mm_irqdelay_status             : std_logic_vector(7 downto 0) := (others => '0');
signal s2mm_irqthresh_status            : std_logic_vector(7 downto 0) := (others => '0');
signal s2mm_new_curdesc_wren            : std_logic := '0';
signal s2mm_new_curdesc                 : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal s2mm_tailpntr_updated            : std_logic := '0';
signal s2mm_dmacr                       : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal s2mm_dmasr                       : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal s2mm_curdesc                     : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal s2mm_taildesc                    : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)    := (others => '0');
signal s2mm_num_frame_store             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)      := (others => '0');
signal s2mm_linebuf_threshold           : std_logic_vector(THRESH_MSB_BIT downto 0)           := (others => '0');
signal s2mm_packet_sof                  : std_logic := '0';
signal s2mm_all_idle                    : std_logic := '0';
signal s2mm_cmdsts_idle                 : std_logic := '0';
signal s2mm_frame_number                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_chnl_current_frame                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_genlock_pair_frame                : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_dlyirq_dsble                : std_logic := '0';
signal s2mm_irqthresh_rstdsbl           : std_logic := '0';
signal s2mm_valid_video_prmtrs          : std_logic := '0';
signal s2mm_crnt_vsize                  : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');-- CR575884
signal s2mm_update_frmstore             : std_logic := '0'; --CR582182
signal s2mm_frmstr_err_addr           : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0'); --CR582182
signal s2mm_all_lines_xfred             : std_logic := '0'; -- CR591965
signal all_lasts_rcvd                   : std_logic := '0';
signal s2mm_capture_hsize_at_uf_err_sig : std_logic_vector(15 downto 0) ;
signal s2mm_capture_dm_done_vsize_counter_sig : std_logic_vector(12 downto 0) ;


signal s2mm_fsize_mismatch_err_flag          : std_logic := '0'; -- CR591965
signal s2mm_fsize_mismatch_err          : std_logic := '0'; -- CR591965
signal s2mm_lsize_mismatch_err          : std_logic := '0'; -- CR591965
signal s2mm_lsize_more_mismatch_err          : std_logic := '0'; -- CR591965
signal s2mm_tuser_fsync                 : std_logic := '0';
signal s2mm_frame_ptr_out_i             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
signal s2mm_to_mm2s_fsync               : std_logic := '0';

-- S2MM Register Direct Support
signal s2mm_regdir_idle                 : std_logic := '0';
signal s2mm_prmtr_updt_complete         : std_logic := '0';
signal s2mm_reg_module_vsize            : std_logic_vector(VSIZE_DWIDTH-1 downto 0);
signal s2mm_reg_module_hsize            : std_logic_vector(HSIZE_DWIDTH-1 downto 0);
signal s2mm_reg_module_stride           : std_logic_vector(STRIDE_DWIDTH-1 downto 0);
signal s2mm_reg_module_frmdly           : std_logic_vector(FRMDLY_DWIDTH-1 downto 0);
signal s2mm_reg_module_strt_addr        : STARTADDR_ARRAY_TYPE(0 to C_NUM_FSTORES - 1);

-- S2MM Register Interface Signals
signal s2mm_axi2ip_wrce                 : std_logic_vector(TOTAL_NUM_REGISTER-1 downto 0)       := (others => '0');
signal s2mm_axi2ip_wrdata               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal s2mm_axi2ip_rdaddr               : std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0');
--signal s2mm_axi2ip_rden                 : std_logic := '0';
signal s2mm_ip2axi_rddata               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
--signal s2mm_ip2axi_rddata_valid         : std_logic := '0';
signal s2mm_ip2axi_frame_ptr_ref        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_ip2axi_frame_store          : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_ip2axi_introut              : std_logic := '0';

-- S2MM Scatter Gather clock domain crossing signals
signal s2mm_cdc2sg_run_stop             : std_logic := '0';
signal s2mm_cdc2sg_stop                 : std_logic := '0';
signal s2mm_cdc2sg_taildesc_wren        : std_logic := '0';
signal s2mm_cdc2sg_taildesc             : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal s2mm_cdc2sg_curdesc              : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal s2mm_sg2cdc_ftch_idle            : std_logic := '0';
signal s2mm_sg2cdc_ftch_interr_set      : std_logic := '0';
signal s2mm_sg2cdc_ftch_slverr_set      : std_logic := '0';
signal s2mm_sg2cdc_ftch_decerr_set      : std_logic := '0';

-- S2MM DMA Controller Signals
signal s2mm_desc_flush                  : std_logic := '0';
signal s2mm_ftch_idle                   : std_logic := '0';
signal s2mm_irqthresh_wren              : std_logic := '0';
signal s2mm_irqdelay_wren               : std_logic := '0';
signal s2mm_ftchcmdsts_idle             : std_logic := '0';

-- SG S2MM Descriptor Fetch AXI Stream IN
signal m_axis_s2mm_ftch_tdata           : std_logic_vector(M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal m_axis_s2mm_ftch_tvalid          : std_logic := '0';
signal m_axis_s2mm_ftch_tready          : std_logic := '0';
signal m_axis_s2mm_ftch_tlast           : std_logic := '0';

-- DataMover S2MM Command Stream Signals
signal s_axis_s2mm_cmd_tvalid           : std_logic := '0';
signal s_axis_s2mm_cmd_tready           : std_logic := '0';
signal s_axis_s2mm_cmd_tdata            : std_logic_vector
                                        ((C_M_AXI_S2MM_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0) := (others => '0');
-- DataMover S2MM Status Stream Signals
signal m_axis_s2mm_sts_tvalid           : std_logic := '0';
signal m_axis_s2mm_sts_tready           : std_logic := '0';
signal m_axis_s2mm_sts_tdata            : std_logic_vector(S2MM_DM_STATUS_WIDTH - 1 downto 0) := (others => '0');   -- CR608521
signal m_axis_s2mm_sts_tkeep            : std_logic_vector((S2MM_DM_STATUS_WIDTH/8)-1 downto 0) := (others => '0'); -- CR608521
signal s2mm_err                         : std_logic := '0';
signal s2mm_halt                        : std_logic := '0';
signal s2mm_halt_cmplt                  : std_logic := '0';

-- Line Buffer To DataMover AXI Stream Signals
signal linebuf2dm_s2mm_tdata            : std_logic_vector(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED-1 downto 0);
signal linebuf2dm_s2mm_tkeep            : std_logic_vector((C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED/8)-1 downto 0);
signal linebuf2dm_s2mm_tlast            : std_logic := '0';
signal linebuf2dm_s2mm_tvalid           : std_logic := '0';
signal dm2linebuf_s2mm_tready           : std_logic := '0';

-- S2MM Error Status Control
signal s2mm_ftch_interr_set             : std_logic := '0';
signal s2mm_ftch_slverr_set             : std_logic := '0';
signal s2mm_ftch_decerr_set             : std_logic := '0';

-- S2MM Soft Reset support
signal s2mm_soft_reset                  : std_logic := '0';
signal s2mm_soft_reset_clr              : std_logic := '0';

-- S2MM SOF generation support
signal s_axis_s2mm_tready_i             : std_logic := '0';
signal s_axis_s2mm_tready_i_axis_dw_conv             : std_logic := '0';




-- Video specific
signal s2mm_frame_sync                  : std_logic := '0';
signal mm2s_frame_sync                  : std_logic := '0';
signal mm2s_parameter_update            : std_logic := '0';
signal s2mm_parameter_update            : std_logic := '0';

-- Line Buffer Support
signal mm2s_allbuffer_empty             : std_logic := '0';
signal mm2s_dwidth_fifo_pipe_empty             : std_logic := '0';
signal mm2s_dwidth_fifo_pipe_empty_m             : std_logic := '0';

-- Video CDC support
signal mm2s_cdc2dmac_fsync              : std_logic := '0';
signal mm2s_dmac2cdc_fsync_out          : std_logic := '0';
signal mm2s_dmac2cdc_prmtr_update       : std_logic := '0';
signal mm2s_vid2cdc_packet_sof          : std_logic := '0';

signal s2mm_cdc2dmac_fsync              : std_logic := '0';
signal s2mm_dmac2cdc_fsync_out          : std_logic := '0';
signal s2mm_dmac2cdc_prmtr_update       : std_logic := '0';
signal s2mm_vid2cdc_packet_sof          : std_logic := '0';

-- fsync qualified by valid parameters for frame count
-- decrement
signal mm2s_valid_frame_sync            : std_logic := '0';
signal s2mm_valid_frame_sync            : std_logic := '0';
signal mm2s_valid_frame_sync_cmb        : std_logic := '0';
signal s2mm_valid_frame_sync_cmb        : std_logic := '0';

--signal for test bench and for output
signal s2mm_tstvect_err               : std_logic := '0';
signal mm2s_tstvect_err               : std_logic := '0';
signal s2mm_tstvect_fsync               : std_logic := '0';
signal mm2s_tstvect_fsync               : std_logic := '0';
signal s2mm_tstvect_frame               : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal mm2s_tstvect_frame               : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_fsync_out_i                 : std_logic := '0';
signal s2mm_fsync_out_m_i                 : std_logic := '0';
signal mm2s_fsync_out_i                 : std_logic := '0';
signal mm2s_mask_fsync_out              : std_logic := '0';
signal s2mm_mask_fsync_out              : std_logic := '0';

signal mm2s_mstrfrm_tstsync_out         : std_logic := '0';
signal s2mm_mstrfrm_tstsync_out         : std_logic := '0';

-- Genlock pointer signals
signal mm2s_mstrfrm_tstsync             : std_logic := '0';
signal mm2s_s_frame_ptr_in              : std_logic_vector(MM2S_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0) := (others => '0');
signal mm2s_m_frame_ptr_out             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');

signal s2mm_mstrfrm_tstsync             : std_logic := '0';
signal s2mm_s_frame_ptr_in              : std_logic_vector(S2MM_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0) := (others => '0');
signal s2mm_m_frame_ptr_out             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
signal mm2s_tstvect_frm_ptr_out         : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal s2mm_tstvect_frm_ptr_out         : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) := (others => '0');
signal  sg2cdc_ftch_err_addr          : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal  sg2cdc_ftch_err               : std_logic := '0';
signal  mm2s_ftch_err_addr            : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal  mm2s_ftch_err                 : std_logic := '0';
signal  s2mm_ftch_err_addr            : std_logic_vector(C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal  s2mm_ftch_err                 : std_logic := '0';
-- Internal GenLock bus support
signal s2mm_to_mm2s_frame_ptr_in        : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
signal mm2s_to_s2mm_frame_ptr_in        : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');
signal mm2s_reg_index                   : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal s2mm_reg_index                   : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal s2mm_crnt_vsize_d2               : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal s2mm_fsync_src_select_s          : std_logic_vector(1 downto 0) := (others => '0');
signal hold_dummy_tready_low	        : std_logic := '0';
signal hold_dummy_tready_low2	        : std_logic := '0';
signal drop_fsync_d_pulse_gen_fsize_less_err	                : std_logic := '0';
signal s2mm_tuser_fsync_top	        : std_logic := '0';
signal s2mm_fsync_core	                : std_logic := '0';
signal s2mm_chnl_ready	                : std_logic := '0';
signal s2mm_strm_not_finished           : std_logic := '0';
signal s2mm_strm_all_lines_rcvd         : std_logic := '0';
signal s2mm_all_vount_rcvd              : std_logic := '0';
signal s2mm_fsize_mismatch_err_s        : std_logic := '0'; 
signal s2mm_fsize_less_err_internal_tvalid_gating          	: std_logic := '0'; 
signal s2mm_dummy_tready		: std_logic := '0';
signal s2mm_fsize_more_or_sof_late_s		: std_logic := '0';
signal s2mm_fsize_more_or_sof_late		: std_logic := '0';
signal        s_axis_s2mm_tdata_signal           :   std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TDATA_WIDTH-1 downto 0) := (others => '0');                 --
signal        s_axis_s2mm_tkeep_signal           :   std_logic_vector                                      --
                                        ((C_S_AXIS_S2MM_TDATA_WIDTH/8)-1 downto 0) := (others => '0');             --
signal        s_axis_s2mm_tuser_signal           :   std_logic_vector                                      --
                                        (C_S_AXIS_S2MM_TUSER_BITS-1 downto 0) := (others => '0');                  --
signal        s_axis_s2mm_tvalid_signal          :   std_logic                         := '0';                   --
signal        s_axis_s2mm_tready_signal          :   std_logic                         := '0';                   --
signal        s_axis_s2mm_tlast_signal           :   std_logic                         := '0';                   --


signal mm2s_fsync_core	                : std_logic := '0';
signal mm2s_fsize_mismatch_err_s        : std_logic := '0';
signal mm2s_fsize_mismatch_err_m        : std_logic := '0';
signal MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S        : std_logic := '0';
signal m_axis_mm2s_tready_i2          	: std_logic                         ;                   --
signal m_axis_mm2s_tvalid_i2          	: std_logic                         ;                   --
signal mm2s_fsync_out_m                 : std_logic := '0';
signal mm2s_fsize_mismatch_err_flag          : std_logic := '0'; -- CR591965
signal mm2s_vsize_cntr_clr_flag          : std_logic := '0'; -- CR591965
signal mm2s_fsync_d1               : std_logic := '0';
signal mm2s_fsync_d2               : std_logic := '0';
signal mm2s_fsync_fe               : std_logic := '0';
signal s2mm_fsync_d1               : std_logic := '0';
signal s2mm_fsync_d2               : std_logic := '0';
signal s2mm_fsync_fe               : std_logic := '0';
signal mm2s_buffer_empty_i         : std_logic := '0';
signal s2mm_buffer_full_i          : std_logic := '0';
signal mm2s_buffer_almost_empty_i  : std_logic := '0';
signal s2mm_buffer_almost_full_i   : std_logic := '0';
signal mm2s_prmtr_update_i         : std_logic := '0';
signal s2mm_prmtr_update_i         : std_logic := '0';
signal mm2s_fsync_out_sig          : std_logic := '0';
signal s2mm_fsync_out_sig          : std_logic := '0';
signal axi_vdma_tstvec_i           : std_logic_vector(63 downto 0) := (others => '0');
signal mm2s_prmry_reset_out_n_i   : std_logic := '1';
signal s2mm_prmry_reset_out_n_i   : std_logic := '1';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


ENABLE_MM2S_PRMRY_RESET_OUT_N : if (C_INCLUDE_MM2S = 1 and (C_ENABLE_DEBUG_INFO_0 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	mm2s_prmry_reset_out_n <= mm2s_prmry_reset_out_n_i;

end generate ENABLE_MM2S_PRMRY_RESET_OUT_N;
  

DISABLE_MM2S_PRMRY_RESET_OUT_N : if (C_INCLUDE_MM2S = 0 or (C_ENABLE_DEBUG_INFO_0 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	mm2s_prmry_reset_out_n <= '1';

end generate DISABLE_MM2S_PRMRY_RESET_OUT_N;



ENABLE_MM2S_BUFFER_EMPTY : if (C_INCLUDE_MM2S = 1 and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	mm2s_buffer_empty <= mm2s_buffer_empty_i;
	mm2s_buffer_almost_empty <= mm2s_buffer_almost_empty_i;

end generate ENABLE_MM2S_BUFFER_EMPTY;
  

DISABLE_MM2S_BUFFER_EMPTY : if (C_INCLUDE_MM2S = 0 or (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	mm2s_buffer_empty <= '0';
	mm2s_buffer_almost_empty <= '0';

end generate DISABLE_MM2S_BUFFER_EMPTY;



ENABLE_MM2S_PRMTR_UPDATE : if (C_INCLUDE_MM2S = 1 and (C_ENABLE_DEBUG_INFO_2 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	mm2s_prmtr_update <= mm2s_prmtr_update_i;

end generate ENABLE_MM2S_PRMTR_UPDATE;
  

DISABLE_MM2S_PRMTR_UPDATE : if (C_INCLUDE_MM2S = 0 or (C_ENABLE_DEBUG_INFO_2 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	mm2s_prmtr_update <= '0';

end generate DISABLE_MM2S_PRMTR_UPDATE;


ENABLE_MM2S_FSYNC_OUT : if (C_INCLUDE_MM2S = 1 and (C_ENABLE_DEBUG_INFO_3 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	mm2s_fsync_out <= mm2s_fsync_out_sig;

end generate ENABLE_MM2S_FSYNC_OUT;
  

DISABLE_MM2S_FSYNC_OUT : if (C_INCLUDE_MM2S = 0 or (C_ENABLE_DEBUG_INFO_3 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	mm2s_fsync_out <= '0';

end generate DISABLE_MM2S_FSYNC_OUT;


ENABLE_AXI_VDMA_TSTVEC : if (C_ENABLE_DEBUG_INFO_4 = 1 or C_ENABLE_DEBUG_ALL = 1) generate
begin 
	axi_vdma_tstvec <= axi_vdma_tstvec_i;

end generate ENABLE_AXI_VDMA_TSTVEC;
  

DISABLE_AXI_VDMA_TSTVEC : if (C_ENABLE_DEBUG_INFO_4 = 0 and C_ENABLE_DEBUG_ALL = 0) generate
begin 
	axi_vdma_tstvec <= (others => '0');

end generate DISABLE_AXI_VDMA_TSTVEC;



ENABLE_S2MM_PRMRY_RESET_OUT_N : if (C_INCLUDE_S2MM = 1 and (C_ENABLE_DEBUG_INFO_8 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	s2mm_prmry_reset_out_n <= s2mm_prmry_reset_out_n_i;

end generate ENABLE_S2MM_PRMRY_RESET_OUT_N;
  

DISABLE_S2MM_PRMRY_RESET_OUT_N : if (C_INCLUDE_S2MM = 0 or (C_ENABLE_DEBUG_INFO_8 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	s2mm_prmry_reset_out_n <= '1';

end generate DISABLE_S2MM_PRMRY_RESET_OUT_N;



ENABLE_S2MM_BUFFER_FULL : if (C_INCLUDE_S2MM = 1 and (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	s2mm_buffer_full <= s2mm_buffer_full_i;
	s2mm_buffer_almost_full <= s2mm_buffer_almost_full_i;

end generate ENABLE_S2MM_BUFFER_FULL;
  

DISABLE_S2MM_BUFFER_FULL : if (C_INCLUDE_S2MM = 0 or (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	s2mm_buffer_full <= '0';
	s2mm_buffer_almost_full <= '0';

end generate DISABLE_S2MM_BUFFER_FULL;



ENABLE_S2MM_PRMTR_UPDATE : if (C_INCLUDE_S2MM = 1 and (C_ENABLE_DEBUG_INFO_10 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	s2mm_prmtr_update <= s2mm_prmtr_update_i;

end generate ENABLE_S2MM_PRMTR_UPDATE;
  

DISABLE_S2MM_PRMTR_UPDATE : if (C_INCLUDE_S2MM = 0 or (C_ENABLE_DEBUG_INFO_10 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	s2mm_prmtr_update <= '0';

end generate DISABLE_S2MM_PRMTR_UPDATE;



ENABLE_S2MM_FSYNC_OUT : if (C_INCLUDE_S2MM = 1 and (C_ENABLE_DEBUG_INFO_11 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin 
	s2mm_fsync_out <= s2mm_fsync_out_sig;

end generate ENABLE_S2MM_FSYNC_OUT;
  

DISABLE_S2MM_FSYNC_OUT : if (C_INCLUDE_S2MM = 0 or (C_ENABLE_DEBUG_INFO_11 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin 
	s2mm_fsync_out <= '0';

end generate DISABLE_S2MM_FSYNC_OUT;








-- AXI DMA Test Vector (For Xilinx Internal Use Only)
axi_vdma_tstvec_i(63 downto 59)   		<= s2mm_tstvect_frm_ptr_out;		---
axi_vdma_tstvec_i(58 downto 54)   		<= mm2s_tstvect_frm_ptr_out;		---
axi_vdma_tstvec_i(53 downto 49)   		<= s2mm_tstvect_frame;		---
axi_vdma_tstvec_i(48 downto 44)   		<= mm2s_tstvect_frame;		---
axi_vdma_tstvec_i(43 downto 33) 		<= (others => '0');
axi_vdma_tstvec_i(32) 				<= s2mm_strm_all_lines_rcvd;		-- 
axi_vdma_tstvec_i(31) 				<= s2mm_halt;		-- DataMover halt tracking
axi_vdma_tstvec_i(30) 				<= mm2s_halt;		-- DataMover halt tracking
axi_vdma_tstvec_i(29)             		<= s2mm_tstvect_err;
axi_vdma_tstvec_i(28)             		<= mm2s_tstvect_err;
axi_vdma_tstvec_i(27 downto 24)   		<= s2mm_tstvect_frm_ptr_out(3 downto 0);		--
axi_vdma_tstvec_i(23 downto 20)   		<= mm2s_tstvect_frm_ptr_out(3 downto 0);		--
axi_vdma_tstvec_i(19)             		<= s2mm_mstrfrm_tstsync_out;
axi_vdma_tstvec_i(18)             		<= mm2s_mstrfrm_tstsync_out;
axi_vdma_tstvec_i(17)             		<= s2mm_dmasr(DMASR_HALTED_BIT);
axi_vdma_tstvec_i(16)             		<= mm2s_dmasr(DMASR_HALTED_BIT);
axi_vdma_tstvec_i(15 downto 12)   		<= s2mm_tstvect_frame(3 downto 0);			--
axi_vdma_tstvec_i(11 downto 8)    		<= mm2s_tstvect_frame(3 downto 0);			--
axi_vdma_tstvec_i(7)              		<= s2mm_tstvect_fsync
                                    			and not s2mm_mask_fsync_out;
axi_vdma_tstvec_i(6)              		<= mm2s_tstvect_fsync
                                    			and not mm2s_mask_fsync_out;
axi_vdma_tstvec_i(5)              		<= s2mm_tstvect_fsync;
axi_vdma_tstvec_i(4)              		<= mm2s_tstvect_fsync;
axi_vdma_tstvec_i(3)              		<= s2mm_dummy_tready and s_axis_s2mm_tvalid_signal;
axi_vdma_tstvec_i(2)              		<= s2mm_packet_sof;
axi_vdma_tstvec_i(1)              		<= mm2s_all_lines_xfred;
axi_vdma_tstvec_i(0)              		<= mm2s_packet_sof;



GEN_MM2S_D1_REG : process(m_axis_mm2s_aclk)
    begin
        if(m_axis_mm2s_aclk'EVENT and m_axis_mm2s_aclk = '1')then

	  mm2s_fsync_d1      <= mm2s_fsync;
	  mm2s_fsync_d2      <= mm2s_fsync_d1;

        end if;
    end process GEN_MM2S_D1_REG;




mm2s_fsync_fe <= mm2s_fsync_d2 and not mm2s_fsync_d1;

GEN_S2MM_D1_REG : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then

	  s2mm_fsync_d1      <= s2mm_fsync;
	  s2mm_fsync_d2      <= s2mm_fsync_d1;

        end if;
    end process GEN_S2MM_D1_REG;

s2mm_fsync_fe <= s2mm_fsync_d2 and not s2mm_fsync_d1;




s2mm_fsize_more_or_sof_late_s 		<= s2mm_dummy_tready and s_axis_s2mm_tvalid_signal and not s2mm_fsize_less_err_internal_tvalid_gating;




--s_axis_s2mm_tready              <= s_axis_s2mm_tready_i_axis_dw_conv;
--m_axis_mm2s_tvalid              <= m_axis_mm2s_tvalid_i_axis_dw_conv;


m_axis_mm2s_tvalid              <= m_axis_mm2s_tvalid_i2;
m_axis_mm2s_tlast               <= m_axis_mm2s_tlast_i_axis_dw_conv;


mm2s_frame_ptr_out  <= mm2s_frame_ptr_out_i ;
s2mm_frame_ptr_out  <= s2mm_frame_ptr_out_i ;


--*****************************************************************************
--**                             RESET MODULE                                **
--*****************************************************************************
I_RST_MODULE : entity  axi_vdma_v6_2.axi_vdma_rst_module
    generic map(
        C_INCLUDE_MM2S              => C_INCLUDE_MM2S                       ,
        C_INCLUDE_S2MM              => C_INCLUDE_S2MM                       ,
        C_INCLUDE_SG                => C_INCLUDE_SG                         ,
        C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC
    )
    port map(
        -----------------------------------------------------------------------
        -- Clock Sources
        -----------------------------------------------------------------------
        s_axi_lite_aclk             => s_axi_lite_aclk                      ,
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_mm2s_aclk             => m_axi_mm2s_aclk                      ,
        m_axis_mm2s_aclk            => m_axis_mm2s_aclk                     ,
        m_axi_s2mm_aclk             => m_axi_s2mm_aclk                      ,
        s_axis_s2mm_aclk            => s_axis_s2mm_aclk                     ,

        -----------------------------------------------------------------------
        -- Hard Reset
        -----------------------------------------------------------------------
        axi_resetn                  => axi_resetn                           ,

        -----------------------------------------------------------------------
        -- MM2S Soft Reset Support
        -----------------------------------------------------------------------
        mm2s_soft_reset             => mm2s_soft_reset                      ,
        mm2s_soft_reset_clr         => mm2s_soft_reset_clr                  ,
        mm2s_stop                   => mm2s_stop                            ,
        mm2s_all_idle               => mm2s_ftchcmdsts_idle                 ,
        mm2s_fsize_mismatch_err     => mm2s_fsize_mismatch_err              , -- CR591965
        mm2s_halt                   => mm2s_halt                            ,
        mm2s_halt_cmplt             => mm2s_halt_cmplt                      ,
        mm2s_run_stop               => mm2s_dmacr(DMACR_RS_BIT)             ,

        -----------------------------------------------------------------------
        -- MM2S Soft Reset Support
        -----------------------------------------------------------------------
        s2mm_soft_reset             => s2mm_soft_reset                      ,
        s2mm_soft_reset_clr         => s2mm_soft_reset_clr                  ,
        s2mm_stop                   => s2mm_stop                            ,
        s2mm_all_idle               => s2mm_ftchcmdsts_idle                 ,
        s2mm_fsize_mismatch_err     => s2mm_fsize_mismatch_err              , -- CR591965
        s2mm_halt                   => s2mm_halt                            ,
        s2mm_halt_cmplt             => s2mm_halt_cmplt                      ,
        s2mm_run_stop               => s2mm_dmacr(DMACR_RS_BIT)             ,

        -----------------------------------------------------------------------
        -- SG Status
        -----------------------------------------------------------------------
        ftch_err                  => sg2cdc_ftch_err                    ,

        -----------------------------------------------------------------------
        -- MM2S Distributed Reset Out
        -----------------------------------------------------------------------
        -- AXI Upsizer and Line Buffer
        mm2s_prmry_resetn           => mm2s_prmry_resetn                    ,
        -- AXI DataMover Primary Reset (Raw)
        mm2s_dm_prmry_resetn        => mm2s_dm_prmry_resetn                 ,
        -- AXI Stream Logic Reset
        mm2s_axis_resetn            => mm2s_axis_resetn                     ,
        -- AXI Stream Reset Outputs
        mm2s_axis_reset_out_n       => mm2s_prmry_reset_out_n_i               ,

        -----------------------------------------------------------------------
        -- S2MM Distributed Reset Out
        -----------------------------------------------------------------------
        s2mm_prmry_resetn           => s2mm_prmry_resetn                    ,
        -- AXI DataMover Primary Reset (Raw)
        s2mm_dm_prmry_resetn        => s2mm_dm_prmry_resetn                 ,
        -- AXI Stream Logic Reset
        s2mm_axis_resetn            => s2mm_axis_resetn                     ,
        -- AXI Stream Reset Outputs
        s2mm_axis_reset_out_n       => s2mm_prmry_reset_out_n_i               ,

        -----------------------------------------------------------------------
        -- Scatter Gather Distributed Reset Out
        -----------------------------------------------------------------------
        m_axi_sg_resetn             => m_axi_sg_resetn                      ,
        m_axi_dm_sg_resetn          => m_axi_dm_sg_resetn                   ,

        -----------------------------------------------------------------------
        -- AXI Lite Interface Reset Out (Hard Only)
        -----------------------------------------------------------------------
        s_axi_lite_resetn           => s_axi_lite_resetn                    ,
        mm2s_hrd_resetn             => mm2s_hrd_resetn                      ,
        s2mm_hrd_resetn             => s2mm_hrd_resetn
    );


--*****************************************************************************
--**                      AXI LITE REGISTER INTERFACE                        **
--*****************************************************************************
-------------------------------------------------------------------------------
-- Provides the s_axi_lite inteface and clock domain crossing between
-- axi lite and mm2s/s2mm register modules
-------------------------------------------------------------------------------
AXI_LITE_REG_INTERFACE_I :  entity axi_vdma_v6_2.axi_vdma_reg_if
    generic map(
        C_INCLUDE_MM2S              => C_INCLUDE_MM2S                       ,
        C_INCLUDE_S2MM              => C_INCLUDE_S2MM                       ,
        C_INCLUDE_SG                => C_INCLUDE_SG                         ,
        C_ENABLE_VIDPRMTR_READS     => C_ENABLE_VIDPRMTR_READS              ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
        C_ENABLE_DEBUG_INFO_0      => C_ENABLE_DEBUG_INFO_0             ,
        C_ENABLE_DEBUG_INFO_1      => C_ENABLE_DEBUG_INFO_1             ,
        C_ENABLE_DEBUG_INFO_2      => C_ENABLE_DEBUG_INFO_2             ,
        C_ENABLE_DEBUG_INFO_3      => C_ENABLE_DEBUG_INFO_3             ,
        C_ENABLE_DEBUG_INFO_4      => C_ENABLE_DEBUG_INFO_4             ,
        C_ENABLE_DEBUG_INFO_5      => C_ENABLE_DEBUG_INFO_5             ,
        C_ENABLE_DEBUG_INFO_6      => C_ENABLE_DEBUG_INFO_6             ,
        C_ENABLE_DEBUG_INFO_7      => C_ENABLE_DEBUG_INFO_7             ,
        C_ENABLE_DEBUG_INFO_8      => C_ENABLE_DEBUG_INFO_8             ,
        C_ENABLE_DEBUG_INFO_9      => C_ENABLE_DEBUG_INFO_9             ,
        C_ENABLE_DEBUG_INFO_10     => C_ENABLE_DEBUG_INFO_10             ,
        C_ENABLE_DEBUG_INFO_11     => C_ENABLE_DEBUG_INFO_11             ,
        C_ENABLE_DEBUG_INFO_12     => C_ENABLE_DEBUG_INFO_12             ,
        C_ENABLE_DEBUG_INFO_13     => C_ENABLE_DEBUG_INFO_13             ,
        C_ENABLE_DEBUG_INFO_14     => C_ENABLE_DEBUG_INFO_14             ,
        C_ENABLE_DEBUG_INFO_15     => C_ENABLE_DEBUG_INFO_15             ,
        C_TOTAL_NUM_REGISTER        => TOTAL_NUM_REGISTER                   ,
        C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC                ,
        C_S_AXI_LITE_ADDR_WIDTH     => C_S_AXI_LITE_ADDR_WIDTH              ,
        C_S_AXI_LITE_DATA_WIDTH     => C_S_AXI_LITE_DATA_WIDTH              ,
        C_VERSION_MAJOR             => VERSION_MAJOR                        ,
        C_VERSION_MINOR             => VERSION_MINOR                        ,
        C_VERSION_REVISION          => VERSION_REVISION                     ,
        C_REVISION_NUMBER           => REVISION_NUMBER
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        s_axi_lite_aclk             => s_axi_lite_aclk                      ,
        s_axi_lite_reset_n          => s_axi_lite_resetn                    ,
        s_axi_lite_awvalid          => s_axi_lite_awvalid                   ,
        s_axi_lite_awready          => s_axi_lite_awready                   ,
        s_axi_lite_awaddr           => s_axi_lite_awaddr                    ,
        s_axi_lite_wvalid           => s_axi_lite_wvalid                    ,
        s_axi_lite_wready           => s_axi_lite_wready                    ,
        s_axi_lite_wdata            => s_axi_lite_wdata                     ,
        s_axi_lite_bresp            => s_axi_lite_bresp                     ,
        s_axi_lite_bvalid           => s_axi_lite_bvalid                    ,
        s_axi_lite_bready           => s_axi_lite_bready                    ,
        s_axi_lite_arvalid          => s_axi_lite_arvalid                   ,
        s_axi_lite_arready          => s_axi_lite_arready                   ,
        s_axi_lite_araddr           => s_axi_lite_araddr                    ,
        s_axi_lite_rvalid           => s_axi_lite_rvalid                    ,
        s_axi_lite_rready           => s_axi_lite_rready                    ,
        s_axi_lite_rdata            => s_axi_lite_rdata                     ,
        s_axi_lite_rresp            => s_axi_lite_rresp                     ,

        -- MM2S Register Interface
        m_axi_mm2s_aclk             => m_axi_mm2s_aclk                      ,
        mm2s_hrd_resetn             => mm2s_hrd_resetn                      ,
        mm2s_axi2ip_wrce            => mm2s_axi2ip_wrce                     ,
        mm2s_axi2ip_wrdata          => mm2s_axi2ip_wrdata                   ,
        mm2s_axi2ip_rdaddr          => mm2s_axi2ip_rdaddr                   ,
        --mm2s_axi2ip_rden            => mm2s_axi2ip_rden                     ,
        mm2s_ip2axi_rddata          => mm2s_ip2axi_rddata                   ,
        --mm2s_ip2axi_rddata_valid    => mm2s_ip2axi_rddata_valid             ,
        mm2s_ip2axi_frame_ptr_ref   => mm2s_ip2axi_frame_ptr_ref            ,
        mm2s_ip2axi_frame_store     => mm2s_ip2axi_frame_store              ,
        mm2s_chnl_current_frame     => mm2s_chnl_current_frame                ,
        mm2s_genlock_pair_frame     => mm2s_genlock_pair_frame                ,
        mm2s_ip2axi_introut         => mm2s_ip2axi_introut                  ,
        mm2s_introut                => mm2s_introut                         ,

        -- S2MM Register Interface
        m_axi_s2mm_aclk             => m_axi_s2mm_aclk                      ,
        s2mm_hrd_resetn             => s2mm_hrd_resetn                      ,
        s2mm_axi2ip_wrce            => s2mm_axi2ip_wrce                     ,
        s2mm_axi2ip_wrdata          => s2mm_axi2ip_wrdata                   ,
        --s2mm_axi2ip_rden            => s2mm_axi2ip_rden                     ,
        s2mm_axi2ip_rdaddr          => s2mm_axi2ip_rdaddr                   ,
        s2mm_ip2axi_rddata          => s2mm_ip2axi_rddata                   ,
        --s2mm_ip2axi_rddata_valid    => s2mm_ip2axi_rddata_valid             ,
        s2mm_ip2axi_frame_ptr_ref   => s2mm_ip2axi_frame_ptr_ref            ,
        s2mm_ip2axi_frame_store     => s2mm_ip2axi_frame_store              ,
        s2mm_capture_dm_done_vsize_counter     => s2mm_capture_dm_done_vsize_counter_sig                ,
        s2mm_capture_hsize_at_uf_err     => s2mm_capture_hsize_at_uf_err_sig                ,
        s2mm_chnl_current_frame     => s2mm_chnl_current_frame                ,
        s2mm_genlock_pair_frame     => s2mm_genlock_pair_frame                ,
        s2mm_ip2axi_introut         => s2mm_ip2axi_introut                  ,
        s2mm_introut                => s2mm_introut
    );

--*****************************************************************************
--**                       INTERRUPT CONTROLLER                              **
--*****************************************************************************
I_AXI_DMA_INTRPT : entity  axi_vdma_v6_2.axi_vdma_intrpt
    generic map(

        C_INCLUDE_CH1              => C_INCLUDE_MM2S                            ,
        C_INCLUDE_CH2              => C_INCLUDE_S2MM                            ,
        --C_ENABLE_DEBUG_INFO        => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
        C_ENABLE_DEBUG_INFO_0      => C_ENABLE_DEBUG_INFO_0             ,
        C_ENABLE_DEBUG_INFO_1      => C_ENABLE_DEBUG_INFO_1             ,
        C_ENABLE_DEBUG_INFO_2      => C_ENABLE_DEBUG_INFO_2             ,
        C_ENABLE_DEBUG_INFO_3      => C_ENABLE_DEBUG_INFO_3             ,
        C_ENABLE_DEBUG_INFO_4      => C_ENABLE_DEBUG_INFO_4             ,
        C_ENABLE_DEBUG_INFO_5      => C_ENABLE_DEBUG_INFO_5             ,
        C_ENABLE_DEBUG_INFO_6      => C_ENABLE_DEBUG_INFO_6             ,
        C_ENABLE_DEBUG_INFO_7      => C_ENABLE_DEBUG_INFO_7             ,
        C_ENABLE_DEBUG_INFO_8      => C_ENABLE_DEBUG_INFO_8             ,
        C_ENABLE_DEBUG_INFO_9      => C_ENABLE_DEBUG_INFO_9             ,
        C_ENABLE_DEBUG_INFO_10     => C_ENABLE_DEBUG_INFO_10             ,
        C_ENABLE_DEBUG_INFO_11     => C_ENABLE_DEBUG_INFO_11             ,
        C_ENABLE_DEBUG_INFO_12     => C_ENABLE_DEBUG_INFO_12             ,
        C_ENABLE_DEBUG_INFO_13     => C_ENABLE_DEBUG_INFO_13             ,
        C_ENABLE_DEBUG_INFO_14     => C_ENABLE_DEBUG_INFO_14             ,
        C_ENABLE_DEBUG_INFO_15     => C_ENABLE_DEBUG_INFO_15             ,
        C_INCLUDE_DLYTMR           => INCLUDE_DLYTMR                            ,
        C_DLYTMR_RESOLUTION        => C_DLYTMR_RESOLUTION
    )
    port map(
        m_axi_ch1_aclk              => m_axi_mm2s_aclk                          ,
        m_axi_ch1_aresetn           => mm2s_prmry_resetn                        ,
        m_axi_ch2_aclk              => m_axi_s2mm_aclk                          ,
        m_axi_ch2_aresetn           => s2mm_prmry_resetn                        ,

        ch1_irqthresh_decr          => mm2s_tstvect_fsync                       ,
        ch1_irqthresh_decr_mask     => mm2s_fsize_mismatch_err_flag                       ,
        ch1_irqthresh_rstdsbl       => mm2s_irqthresh_rstdsbl                   ,
        ch1_dlyirq_dsble            => mm2s_dlyirq_dsble                        ,
        ch1_irqdelay_wren           => mm2s_irqdelay_wren                       ,
        ch1_irqdelay                => mm2s_dmacr(DMACR_IRQDELAY_MSB_BIT
                                           downto DMACR_IRQDELAY_LSB_BIT)       ,
        ch1_irqthresh_wren          => mm2s_irqthresh_wren                      ,
        ch1_irqthresh               => mm2s_dmacr(DMACR_IRQTHRESH_MSB_BIT
                                           downto DMACR_IRQTHRESH_LSB_BIT)      ,
        ch1_packet_sof              => mm2s_packet_sof                          ,
        ch1_packet_eof              => mm2s_tstvect_fsync                       ,
        ch1_packet_eof_mask         => mm2s_fsize_mismatch_err_flag                       ,
        ch1_ioc_irq_set             => mm2s_ioc_irq_set                         ,
        ch1_dly_irq_set             => mm2s_dly_irq_set                         ,
        ch1_irqdelay_status         => mm2s_irqdelay_status                     ,
        ch1_irqthresh_status        => mm2s_irqthresh_status                    ,

        ch2_irqthresh_decr          => s2mm_tstvect_fsync                       ,
        ch2_irqthresh_decr_mask     => s2mm_fsize_mismatch_err_flag                       ,
        ch2_irqthresh_rstdsbl       => s2mm_irqthresh_rstdsbl                   ,
        ch2_dlyirq_dsble            => s2mm_dlyirq_dsble                        ,
        ch2_irqdelay_wren           => s2mm_irqdelay_wren                       ,
        ch2_irqdelay                => s2mm_dmacr(DMACR_IRQDELAY_MSB_BIT
                                           downto DMACR_IRQDELAY_LSB_BIT)       ,
        ch2_irqthresh_wren          => s2mm_irqthresh_wren                      ,
        ch2_irqthresh               => s2mm_dmacr(DMACR_IRQTHRESH_MSB_BIT
                                           downto DMACR_IRQTHRESH_LSB_BIT)      ,
        ch2_packet_sof              => s2mm_packet_sof                          ,
        ch2_packet_eof              => s2mm_tstvect_fsync                       ,
        ch2_packet_eof_mask         => s2mm_fsize_mismatch_err_flag                       ,
        ch2_ioc_irq_set             => s2mm_ioc_irq_set                         ,
        ch2_dly_irq_set             => s2mm_dly_irq_set                         ,
        ch2_irqdelay_status         => s2mm_irqdelay_status                     ,
        ch2_irqthresh_status        => s2mm_irqthresh_status
    );


--*****************************************************************************
--**                       SCATTER GATHER ENGINE                             **
--*****************************************************************************

-- If Scatter Gather Engine is included the instantiate axi_sg
GEN_SG_ENGINE : if C_INCLUDE_SG = 1 generate
    -------------------------------------------------------------------------------
    -- Scatter Gather Engine
    -------------------------------------------------------------------------------
    I_SG_ENGINE : entity  axi_vdma_v6_2.axi_sg
        generic map(
            C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH            ,
            C_M_AXI_SG_DATA_WIDTH       => C_M_AXI_SG_DATA_WIDTH            ,
            C_M_AXIS_SG_TDATA_WIDTH     => M_AXIS_SG_TDATA_WIDTH            ,
            C_S_AXIS_UPDPTR_TDATA_WIDTH => S_AXIS_UPDPTR_TDATA_WIDTH        ,
            C_S_AXIS_UPDSTS_TDATA_WIDTH => S_AXIS_UPDSTS_TDATA_WIDTH        ,
            C_SG_FTCH_DESC2QUEUE        => SG_FTCH_DESC2QUEUE               ,
            C_SG_UPDT_DESC2QUEUE        => SG_UPDT_DESC2QUEUE               ,
            C_SG_CH1_WORDS_TO_FETCH     => SG_CH1_WORDS_TO_FETCH            ,
            C_SG_CH1_WORDS_TO_UPDATE    => SG_CH1_WORDS_TO_UPDATE           ,
            C_SG_CH1_FIRST_UPDATE_WORD  => SG_CH1_FIRST_UPDATE_WORD         ,
            C_SG_CH1_ENBL_STALE_ERROR   => SG_CH1_ENBL_STALE_ERR          ,
            C_SG_CH2_WORDS_TO_FETCH     => SG_CH2_WORDS_TO_FETCH            ,
            C_SG_CH2_WORDS_TO_UPDATE    => SG_CH2_WORDS_TO_UPDATE           ,
            C_SG_CH2_FIRST_UPDATE_WORD  => SG_CH2_FIRST_UPDATE_WORD         ,
            C_SG_CH2_ENBL_STALE_ERROR   => SG_CH2_ENBL_STALE_ERR          ,
            C_INCLUDE_CH1               => C_INCLUDE_MM2S                   ,
            C_INCLUDE_CH2               => C_INCLUDE_S2MM                   ,
            C_INCLUDE_DESC_UPDATE       => EXCLUDE_DESC_UPDATE              ,
            C_INCLUDE_INTRPT            => EXCLUDE_INTRPT                   ,
            C_INCLUDE_DLYTMR            => EXCLUDE_DLYTMR                   ,
            C_DLYTMR_RESOLUTION         => C_DLYTMR_RESOLUTION              ,
            C_AXIS_IS_ASYNC             => C_PRMRY_IS_ACLK_ASYNC            ,
            C_FAMILY                    => C_ROOT_FAMILY
        )
        port map(
            -----------------------------------------------------------------------
            -- AXI Scatter Gather Interface
            -----------------------------------------------------------------------
            m_axi_sg_aclk               => m_axi_sg_aclk                    ,
            m_axi_sg_aresetn            => m_axi_sg_resetn                  ,
            dm_resetn                   => m_axi_dm_sg_resetn               ,

            -- Scatter Gather Write Address Channel
            m_axi_sg_awaddr             => open                             ,
            m_axi_sg_awlen              => open                             ,
            m_axi_sg_awsize             => open                             ,
            m_axi_sg_awburst            => open                             ,
            m_axi_sg_awprot             => open                             ,
            m_axi_sg_awcache            => open                             ,
            m_axi_sg_awvalid            => open                             ,
            m_axi_sg_awready            => '0'                              ,

            -- Scatter Gather Write Data Channel
            m_axi_sg_wdata              => open                             ,
            m_axi_sg_wstrb              => open                             ,
            m_axi_sg_wlast              => open                             ,
            m_axi_sg_wvalid             => open                             ,
            m_axi_sg_wready             => '0'                              ,

            -- Scatter Gather Write Response Channel
            m_axi_sg_bresp              => "00"                             ,
            m_axi_sg_bvalid             => '0'                              ,
            m_axi_sg_bready             => open                             ,

            -- Scatter Gather Read Address Channel
            m_axi_sg_araddr             => m_axi_sg_araddr                  ,
            m_axi_sg_arlen              => m_axi_sg_arlen                   ,
            m_axi_sg_arsize             => m_axi_sg_arsize                  ,
            m_axi_sg_arburst            => m_axi_sg_arburst                 ,
            m_axi_sg_arprot             => m_axi_sg_arprot                  ,
            m_axi_sg_arcache            => m_axi_sg_arcache                 ,
            m_axi_sg_arvalid            => m_axi_sg_arvalid                 ,
            m_axi_sg_arready            => m_axi_sg_arready                 ,

            -- Memory Map to Stream Scatter Gather Read Data Channel
            m_axi_sg_rdata              => m_axi_sg_rdata                   ,
            m_axi_sg_rresp              => m_axi_sg_rresp                   ,
            m_axi_sg_rlast              => m_axi_sg_rlast                   ,
            m_axi_sg_rvalid             => m_axi_sg_rvalid                  ,
            m_axi_sg_rready             => m_axi_sg_rready                  ,

            -- Channel 1 Control and Status
            ch1_run_stop                => mm2s_cdc2sg_run_stop             ,
            ch1_desc_flush              => mm2s_cdc2sg_stop                 ,
            ch1_ftch_idle               => mm2s_sg2cdc_ftch_idle            ,
            ch1_ftch_interr_set         => mm2s_sg2cdc_ftch_interr_set      ,
            ch1_ftch_slverr_set         => mm2s_sg2cdc_ftch_slverr_set      ,
            ch1_ftch_decerr_set         => mm2s_sg2cdc_ftch_decerr_set      ,
            ch1_ftch_err_early          => open                             ,
            ch1_ftch_stale_desc         => open                             ,
            ch1_updt_idle               => open                             ,
            ch1_updt_ioc_irq_set        => open                             ,
            ch1_updt_interr_set         => open                             ,
            ch1_updt_slverr_set         => open                             ,
            ch1_updt_decerr_set         => open                             ,
            ch1_dma_interr_set          => open                             ,
            ch1_dma_slverr_set          => open                             ,
            ch1_dma_decerr_set          => open                             ,
            ch1_tailpntr_enabled        => '1'                              ,
            ch1_taildesc_wren           => mm2s_cdc2sg_taildesc_wren        ,
            ch1_taildesc                => mm2s_cdc2sg_taildesc             ,
            ch1_curdesc                 => mm2s_cdc2sg_curdesc              ,

            -- Channel 1 Interrupt Coalescing Signals
            ch1_dlyirq_dsble            => '0'                              ,
            ch1_irqthresh_rstdsbl       => '0'                              ,
            ch1_irqdelay_wren           => '0'                              ,
            ch1_irqdelay                => ZERO_VALUE(7 downto 0)           ,
            ch1_irqthresh_wren          => '0'                              ,
            ch1_irqthresh               => ZERO_VALUE(7 downto 0)           ,
            ch1_packet_sof              => '0'                              ,
            ch1_packet_eof              => '0'                              ,
            ch1_ioc_irq_set             => open                             ,
            ch1_dly_irq_set             => open                             ,
            ch1_irqdelay_status         => open                             ,
            ch1_irqthresh_status        => open                             ,

            -- Channel 1 AXI Fetch Stream Out
            m_axis_ch1_ftch_aclk        => m_axi_mm2s_aclk                  ,
            m_axis_ch1_ftch_tdata       => m_axis_mm2s_ftch_tdata           ,
            m_axis_ch1_ftch_tvalid      => m_axis_mm2s_ftch_tvalid          ,
            m_axis_ch1_ftch_tready      => m_axis_mm2s_ftch_tready          ,
            m_axis_ch1_ftch_tlast       => m_axis_mm2s_ftch_tlast           ,

            -- Channel 1 AXI Update Stream In
            s_axis_ch1_updt_aclk        => '0'                              ,
            s_axis_ch1_updtptr_tdata    => ZERO_VALUE(S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0),
            s_axis_ch1_updtptr_tvalid   => '0'                              ,
            s_axis_ch1_updtptr_tready   => open                             ,
            s_axis_ch1_updtptr_tlast    => '0'                              ,

            s_axis_ch1_updtsts_tdata    => ZERO_VALUE(S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0),
            s_axis_ch1_updtsts_tvalid   => '0'                              ,
            s_axis_ch1_updtsts_tready   => open                             ,
            s_axis_ch1_updtsts_tlast    => '0'                              ,

            -- Channel 2 Control and Status
            ch2_run_stop                => s2mm_cdc2sg_run_stop             ,
            ch2_desc_flush              => s2mm_cdc2sg_stop                 ,
            ch2_ftch_idle               => s2mm_sg2cdc_ftch_idle            ,
            ch2_ftch_interr_set         => s2mm_sg2cdc_ftch_interr_set      ,
            ch2_ftch_slverr_set         => s2mm_sg2cdc_ftch_slverr_set      ,
            ch2_ftch_decerr_set         => s2mm_sg2cdc_ftch_decerr_set      ,
            ch2_ftch_err_early          => open                             ,
            ch2_ftch_stale_desc         => open                             ,
            ch2_updt_idle               => open                             ,
            ch2_updt_ioc_irq_set        => open                             ,
            ch2_updt_interr_set         => open                             ,
            ch2_updt_slverr_set         => open                             ,
            ch2_updt_decerr_set         => open                             ,
            ch2_dma_interr_set          => open                             ,
            ch2_dma_slverr_set          => open                             ,
            ch2_dma_decerr_set          => open                             ,
            ch2_tailpntr_enabled        => '1'                              ,
            ch2_taildesc_wren           => s2mm_cdc2sg_taildesc_wren        ,
            ch2_taildesc                => s2mm_cdc2sg_taildesc             ,
            ch2_curdesc                 => s2mm_cdc2sg_curdesc              ,

            -- Channel 2 Interrupt Coalescing Signals
            ch2_dlyirq_dsble            => '0'                              ,
            ch2_irqthresh_rstdsbl       => '0'                              ,
            ch2_irqdelay_wren           => '0'                              ,
            ch2_irqdelay                => ZERO_VALUE(7 downto 0)           ,
            ch2_irqthresh_wren          => '0'                              ,
            ch2_irqthresh               => ZERO_VALUE(7 downto 0)           ,
            ch2_packet_sof              => '0'                              ,
            ch2_packet_eof              => '0'                              ,
            ch2_ioc_irq_set             => open                             ,
            ch2_dly_irq_set             => open                             ,
            ch2_irqdelay_status         => open                             ,
            ch2_irqthresh_status        => open                             ,

            -- Channel 2 AXI Fetch Stream Out
            m_axis_ch2_ftch_aclk        => m_axi_s2mm_aclk                  ,
            m_axis_ch2_ftch_tdata       => m_axis_s2mm_ftch_tdata           ,
            m_axis_ch2_ftch_tvalid      => m_axis_s2mm_ftch_tvalid          ,
            m_axis_ch2_ftch_tready      => m_axis_s2mm_ftch_tready          ,
            m_axis_ch2_ftch_tlast       => m_axis_s2mm_ftch_tlast           ,

            -- Channel 2 AXI Update Stream In
            s_axis_ch2_updt_aclk        => '0'                  ,
            s_axis_ch2_updtptr_tdata    => ZERO_VALUE(S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0),
            s_axis_ch2_updtptr_tvalid   => '0'                              ,
            s_axis_ch2_updtptr_tready   => open                             ,
            s_axis_ch2_updtptr_tlast    => '0'                              ,

            s_axis_ch2_updtsts_tdata    => ZERO_VALUE(S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0),
            s_axis_ch2_updtsts_tvalid   => '0'                              ,
            s_axis_ch2_updtsts_tready   => open                             ,
            s_axis_ch2_updtsts_tlast    => '0'                              ,

            -- Error addresses
            ftch_error_addr             => sg2cdc_ftch_err_addr           ,
            ftch_error                  => sg2cdc_ftch_err                ,
            updt_error                  => open                             ,
            updt_error_addr             => open
        );

    --*********************************************************************
    --** MM2S Clock Domain To/From Scatter Gather Clock Domain           **
    --*********************************************************************
    MM2S_SG_CDC_I : entity  axi_vdma_v6_2.axi_vdma_sg_cdc
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => m_axi_mm2s_aclk                  ,
            prmry_resetn                => mm2s_prmry_resetn                ,

            scndry_aclk                 => m_axi_sg_aclk                    ,
            scndry_resetn               => m_axi_sg_resetn                  ,

            -- From Register Module (Primary Clk Domain)
            reg2cdc_run_stop            => mm2s_dmacr(DMACR_RS_BIT)         ,
            reg2cdc_stop                => mm2s_stop                        ,
            reg2cdc_taildesc_wren       => mm2s_tailpntr_updated            ,
            reg2cdc_taildesc            => mm2s_taildesc                    ,
            reg2cdc_curdesc             => mm2s_curdesc                     ,

            -- To Scatter Gather Engine (Secondary Clk Domain)
            cdc2sg_run_stop             => mm2s_cdc2sg_run_stop             ,
            cdc2sg_stop                 => mm2s_cdc2sg_stop                 ,
            cdc2sg_taildesc_wren        => mm2s_cdc2sg_taildesc_wren        ,
            cdc2sg_taildesc             => mm2s_cdc2sg_taildesc             ,
            cdc2sg_curdesc              => mm2s_cdc2sg_curdesc              ,

            -- From Scatter Gather Engine (Secondary Clk Domain)
            sg2cdc_ftch_idle            => mm2s_sg2cdc_ftch_idle            ,
            sg2cdc_ftch_interr_set      => mm2s_sg2cdc_ftch_interr_set      ,
            sg2cdc_ftch_slverr_set      => mm2s_sg2cdc_ftch_slverr_set      ,
            sg2cdc_ftch_decerr_set      => mm2s_sg2cdc_ftch_decerr_set      ,
            sg2cdc_ftch_err_addr      => sg2cdc_ftch_err_addr           ,
            sg2cdc_ftch_err           => sg2cdc_ftch_err                ,

            -- To DMA Controller
            cdc2dmac_ftch_idle          => mm2s_ftch_idle                   ,

            -- To Register Module
            cdc2reg_ftch_interr_set     => mm2s_ftch_interr_set             ,
            cdc2reg_ftch_slverr_set     => mm2s_ftch_slverr_set             ,
            cdc2reg_ftch_decerr_set     => mm2s_ftch_decerr_set             ,
            cdc2reg_ftch_err_addr     => mm2s_ftch_err_addr             ,
            cdc2reg_ftch_err          => mm2s_ftch_err
        );

    --*********************************************************************
    --** S2MM Clock Domain To/From Scatter Gather Clock Domain           **
    --*********************************************************************
    S2MM_SG_CDC_I : entity  axi_vdma_v6_2.axi_vdma_sg_cdc
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => m_axi_s2mm_aclk                  ,
            prmry_resetn                => s2mm_prmry_resetn                ,

            scndry_aclk                 => m_axi_sg_aclk                    ,
            scndry_resetn               => m_axi_sg_resetn                  ,

            -- From Register Module (Primary Clk Domain)
            reg2cdc_run_stop            => s2mm_dmacr(DMACR_RS_BIT)         ,
            reg2cdc_stop                => s2mm_stop                        ,
            reg2cdc_taildesc_wren       => s2mm_tailpntr_updated            ,
            reg2cdc_taildesc            => s2mm_taildesc                    ,
            reg2cdc_curdesc             => s2mm_curdesc                     ,

            -- To Scatter Gather Engine (Secondary Clk Domain)
            cdc2sg_run_stop             => s2mm_cdc2sg_run_stop             ,
            cdc2sg_stop                 => s2mm_cdc2sg_stop                 ,
            cdc2sg_taildesc_wren        => s2mm_cdc2sg_taildesc_wren        ,
            cdc2sg_taildesc             => s2mm_cdc2sg_taildesc             ,
            cdc2sg_curdesc              => s2mm_cdc2sg_curdesc              ,

            -- From Scatter Gather Engine (Secondary Clk Domain)
            sg2cdc_ftch_idle            => s2mm_sg2cdc_ftch_idle            ,
            sg2cdc_ftch_interr_set      => s2mm_sg2cdc_ftch_interr_set      ,
            sg2cdc_ftch_slverr_set      => s2mm_sg2cdc_ftch_slverr_set      ,
            sg2cdc_ftch_decerr_set      => s2mm_sg2cdc_ftch_decerr_set      ,
            sg2cdc_ftch_err_addr      => sg2cdc_ftch_err_addr           ,
            sg2cdc_ftch_err           => sg2cdc_ftch_err                ,

            -- To DMA Controller
            cdc2dmac_ftch_idle          => s2mm_ftch_idle                   ,

            -- To Register Module
            cdc2reg_ftch_interr_set     => s2mm_ftch_interr_set             ,
            cdc2reg_ftch_slverr_set     => s2mm_ftch_slverr_set             ,
            cdc2reg_ftch_decerr_set     => s2mm_ftch_decerr_set             ,
            cdc2reg_ftch_err_addr     => s2mm_ftch_err_addr             ,
            cdc2reg_ftch_err          => s2mm_ftch_err
        );

end generate GEN_SG_ENGINE;

-- No scatter gather engine therefore tie off unused signals
GEN_NO_SG_ENGINE : if C_INCLUDE_SG = 0 generate
begin
    m_axi_sg_araddr             <= (others => '0');
    m_axi_sg_arlen              <= (others => '0');
    m_axi_sg_arsize             <= (others => '0');
    m_axi_sg_arburst            <= (others => '0');
    m_axi_sg_arcache            <= (others => '0');
    m_axi_sg_arprot             <= (others => '0');
    m_axi_sg_arvalid            <= '0';
    m_axi_sg_rready             <= '0';
    mm2s_ftch_idle              <= '1';
    mm2s_ftch_interr_set        <= '0';
    mm2s_ftch_slverr_set        <= '0';
    mm2s_ftch_decerr_set        <= '0';
    m_axis_mm2s_ftch_tdata      <= (others => '0');
    m_axis_mm2s_ftch_tvalid     <= '0';
    m_axis_mm2s_ftch_tlast      <= '0';
    s2mm_ftch_idle              <= '1';
    s2mm_ftch_interr_set        <= '0';
    s2mm_ftch_slverr_set        <= '0';
    s2mm_ftch_decerr_set        <= '0';
    m_axis_s2mm_ftch_tdata      <= (others => '0');
    m_axis_s2mm_ftch_tvalid     <= '0';
    m_axis_s2mm_ftch_tlast      <= '0';
    mm2s_ftch_err_addr        <= (others => '0');
    mm2s_ftch_err             <= '0';
    s2mm_ftch_err_addr        <= (others => '0');
    s2mm_ftch_err             <= '0';

    sg2cdc_ftch_err             <= '0';
end generate GEN_NO_SG_ENGINE;


--*****************************************************************************
--**                            MM2S CHANNEL                                 **
--*****************************************************************************

-- Generate support logic for MM2S
GEN_SPRT_FOR_MM2S : if C_INCLUDE_MM2S = 1 generate
begin



GEN_FLUSH_SOF_MM2S : if (ENABLE_FLUSH_ON_MM2S_FSYNC = 1  and MM2S_SOF_ENABLE = 1) generate

begin




--m_axis_mm2s_tvalid_i2 <= m_axis_mm2s_tvalid_i_axis_dw_conv when  MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S = '0'
--            else '0';

m_axis_mm2s_tvalid_i2 <= '0' when  MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S = '1' or mm2s_fsync_core = '1'
            else m_axis_mm2s_tvalid_i_axis_dw_conv;
m_axis_mm2s_tready_i2 <= m_axis_mm2s_tready when  MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S = '0'
            else '1';

end generate GEN_FLUSH_SOF_MM2S;


GEN_NO_FLUSH_SOF_MM2S : if (ENABLE_FLUSH_ON_MM2S_FSYNC = 0  or MM2S_SOF_ENABLE = 0) generate

begin


m_axis_mm2s_tvalid_i2 <= m_axis_mm2s_tvalid_i_axis_dw_conv;
m_axis_mm2s_tready_i2 <= m_axis_mm2s_tready;

end generate GEN_NO_FLUSH_SOF_MM2S;







  GEN_AXIS_MM2S_DWIDTH_CONV : if (C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED /=  C_M_AXIS_MM2S_TDATA_WIDTH) generate



		constant C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8     	: integer := C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8;
		constant C_M_AXIS_MM2S_TDATA_WIDTH_div_by_8     		: integer := C_M_AXIS_MM2S_TDATA_WIDTH/8;
		
		signal         m_axis_mm2s_dwidth_tuser_i           : std_logic_vector                                      --
		                                        (C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8-1 downto 0) := (others => '0');                  --
		
		signal         m_axis_mm2s_dwidth_tuser           : std_logic_vector                                      --
		                                        (C_M_AXIS_MM2S_TDATA_WIDTH_div_by_8-1 downto 0) := (others => '0');                  --
		
		




  begin

			                        m_axis_mm2s_dwidth_tuser_i(0)   <= m_axis_mm2s_tuser_i(0);

			MM2S_TUSER_CNCT : for i in 1 to C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8-1 generate
			begin

			                        m_axis_mm2s_dwidth_tuser_i(i)   <= '0';
			
			end generate MM2S_TUSER_CNCT;


		
		m_axis_mm2s_tuser(C_M_AXIS_MM2S_TUSER_BITS-1 downto 0)				 	<= m_axis_mm2s_dwidth_tuser(C_M_AXIS_MM2S_TUSER_BITS-1 downto 0);
		


    AXIS_MM2S_DWIDTH_CONVERTER_I: entity  axi_vdma_v6_2.axi_vdma_mm2s_axis_dwidth_converter
        generic map(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED 		=>	C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED		, 
 		C_M_AXIS_MM2S_TDATA_WIDTH         	 		=>	C_M_AXIS_MM2S_TDATA_WIDTH		, 
 		--C_AXIS_SIGNAL_SET            		 		=>	255		, 
 		C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8         	=>	C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8		, 
 		C_M_AXIS_MM2S_TDATA_WIDTH_div_by_8         		=>	C_M_AXIS_MM2S_TDATA_WIDTH_div_by_8		, 
            	C_MM2S_SOF_ENABLE           				=> 	MM2S_SOF_ENABLE                  ,
            	ENABLE_FLUSH_ON_FSYNC      				=> 	ENABLE_FLUSH_ON_MM2S_FSYNC,
 		C_AXIS_TID_WIDTH             		 		=>	1		, 
 		C_AXIS_TDEST_WIDTH           		 		=>	1		, 
        	C_FAMILY                     		 		=>	C_ROOT_FAMILY		   ) 
        port map( 
      		ACLK                         =>	m_axis_mm2s_aclk                 			, 
      		ARESETN                      =>	mm2s_axis_linebuf_reset_out              			, 
      		ACLKEN                       =>	'1'               			, 

            	dm_halt_reg                  => mm2s_halt_reg                        ,
            	stop_reg                     => mm2s_stop_reg                        ,   

             	crnt_vsize_d2                => mm2s_crnt_vsize_d2                  ,   
            	fsync_out                    => mm2s_fsync_out_i    ,
            	mm2s_vsize_cntr_clr_flag     => mm2s_vsize_cntr_clr_flag    ,

		dwidth_fifo_pipe_empty       => mm2s_dwidth_fifo_pipe_empty    ,
                all_lines_xfred_s_dwidth     => mm2s_all_lines_xfred_s_dwidth         ,


      		S_AXIS_TVALID                =>	m_axis_mm2s_tvalid_i        			, 
      		S_AXIS_TREADY                =>	m_axis_mm2s_tready_i        			, 
      		S_AXIS_TDATA                 =>	m_axis_mm2s_tdata_i(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED-1 downto 0)         			, 
      		--S_AXIS_TSTRB                 =>	ZERO_VALUE(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8-1 downto 0)         			, 
      		S_AXIS_TSTRB                 =>	m_axis_mm2s_tkeep_i(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8-1 downto 0)         			, 
      		S_AXIS_TKEEP                 =>	m_axis_mm2s_tkeep_i(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED/8-1 downto 0)         			, 
      		S_AXIS_TLAST                 =>	m_axis_mm2s_tlast_i         			, 
      		S_AXIS_TID                   =>	ZERO_VALUE(0 downto 0)           			, 
      		S_AXIS_TDEST                 =>	ZERO_VALUE(0 downto 0)         			, 
      		S_AXIS_TUSER                 =>	m_axis_mm2s_dwidth_tuser_i(C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED_div_by_8-1 downto 0)         			, 
      		M_AXIS_TVALID                =>	m_axis_mm2s_tvalid_i_axis_dw_conv        			, 
      		M_AXIS_TREADY                =>	m_axis_mm2s_tready_i2        			, 
      		M_AXIS_TDATA                 =>	m_axis_mm2s_tdata(C_M_AXIS_MM2S_TDATA_WIDTH-1 downto 0)         			, 
      		M_AXIS_TSTRB                 =>	open         			, 
      		M_AXIS_TKEEP                 =>	m_axis_mm2s_tkeep(C_M_AXIS_MM2S_TDATA_WIDTH/8-1 downto 0)         			, 
      		M_AXIS_TLAST                 =>	m_axis_mm2s_tlast_i_axis_dw_conv         			, 
      		M_AXIS_TID                   =>	open           			, 
      		M_AXIS_TDEST                 =>	open         			, 
      		M_AXIS_TUSER                 =>	m_axis_mm2s_dwidth_tuser(C_M_AXIS_MM2S_TDATA_WIDTH_div_by_8-1 downto 0)         			
  ) ;


  end generate GEN_AXIS_MM2S_DWIDTH_CONV;


  GEN_NO_AXIS_MM2S_DWIDTH_CONV : if (C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED =  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin


		m_axis_mm2s_tvalid_i_axis_dw_conv		<= m_axis_mm2s_tvalid_i;
		m_axis_mm2s_tdata				<= m_axis_mm2s_tdata_i;
		m_axis_mm2s_tkeep				<= m_axis_mm2s_tkeep_i;
		m_axis_mm2s_tlast_i_axis_dw_conv		<= m_axis_mm2s_tlast_i;
		m_axis_mm2s_tuser				<= m_axis_mm2s_tuser_i;
		m_axis_mm2s_tready_i				<= m_axis_mm2s_tready_i2;
		mm2s_dwidth_fifo_pipe_empty				<= '1';
		mm2s_all_lines_xfred_s_dwidth				<= '0';



  end generate GEN_NO_AXIS_MM2S_DWIDTH_CONV;





    --*************************************************************************
    --** MM2S AXI4 Clock Domain - (m_axi_mm2s_aclk)
    --*************************************************************************
    ---------------------------------------------------------------------------
    -- MM2S Register Module
    ---------------------------------------------------------------------------
    MM2S_REGISTER_MODULE_I : entity  axi_vdma_v6_2.axi_vdma_reg_module
        generic map(
            C_TOTAL_NUM_REGISTER    => TOTAL_NUM_REGISTER                   ,
            C_INCLUDE_SG            => C_INCLUDE_SG                         ,
            C_CHANNEL_IS_MM2S       => CHANNEL_IS_MM2S                      ,
            C_ENABLE_FLUSH_ON_FSYNC => ENABLE_FLUSH_ON_MM2S_FSYNC                , -- CR591965
            C_ENABLE_VIDPRMTR_READS => C_ENABLE_VIDPRMTR_READS              ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE          ,
            C_DYNAMIC_RESOLUTION    => C_DYNAMIC_RESOLUTION                ,
            --C_ENABLE_DEBUG_INFO     => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0   => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1   => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2   => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3   => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4   => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5   => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6   => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7   => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8   => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9   => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10  => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11  => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12  => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13  => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14  => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15  => C_ENABLE_DEBUG_INFO_15             ,
            C_LINEBUFFER_THRESH     => C_MM2S_LINEBUFFER_THRESH_INT             ,
            C_NUM_FSTORES           => C_NUM_FSTORES                        ,
            C_GENLOCK_MODE          => C_MM2S_GENLOCK_MODE                  ,
            C_S_AXI_LITE_ADDR_WIDTH => C_S_AXI_LITE_ADDR_WIDTH              ,
            C_S_AXI_LITE_DATA_WIDTH => C_S_AXI_LITE_DATA_WIDTH              ,
            C_M_AXI_SG_ADDR_WIDTH   => C_M_AXI_SG_ADDR_WIDTH                ,
            C_M_AXI_ADDR_WIDTH      => C_M_AXI_MM2S_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => m_axi_mm2s_aclk                  ,
            prmry_resetn                => mm2s_prmry_resetn                ,

            -- Register to AXI Lite Interface
            axi2ip_wrce                 => mm2s_axi2ip_wrce                 ,
            axi2ip_wrdata               => mm2s_axi2ip_wrdata               ,
            axi2ip_rdaddr               => mm2s_axi2ip_rdaddr               ,
            --axi2ip_rden                 => mm2s_axi2ip_rden                 ,
            axi2ip_rden                 => '0'                 ,
            ip2axi_rddata               => mm2s_ip2axi_rddata               ,
            --ip2axi_rddata_valid         => mm2s_ip2axi_rddata_valid         ,
            ip2axi_rddata_valid         => open         ,
            ip2axi_frame_ptr_ref        => mm2s_ip2axi_frame_ptr_ref        ,
            ip2axi_frame_store          => mm2s_ip2axi_frame_store          ,
            ip2axi_introut              => mm2s_ip2axi_introut              ,

            -- Soft Reset
            soft_reset                  => mm2s_soft_reset                  ,
            soft_reset_clr              => mm2s_soft_reset_clr              ,

            -- DMA Control / Status Register Signals
            halted_clr                  => mm2s_halted_clr                  ,
            halted_set                  => mm2s_halted_set                  ,
            idle_set                    => mm2s_idle_set                    ,
            idle_clr                    => mm2s_idle_clr                    ,
            ioc_irq_set                 => mm2s_ioc_irq_set                 ,
            dly_irq_set                 => mm2s_dly_irq_set                 ,
            irqdelay_status             => mm2s_irqdelay_status             ,
            irqthresh_status            => mm2s_irqthresh_status            ,
            frame_sync                  => mm2s_frame_sync                  ,
            fsync_mask                  => mm2s_mask_fsync_out              ,
            new_curdesc_wren            => mm2s_new_curdesc_wren            ,
            new_curdesc                 => mm2s_new_curdesc                 ,
            update_frmstore             => '1'                              , -- Always Update
            new_frmstr                  => mm2s_frame_number                ,
            tstvect_fsync               => mm2s_tstvect_fsync               ,
            valid_frame_sync            => mm2s_valid_frame_sync            ,
            irqthresh_rstdsbl           => mm2s_irqthresh_rstdsbl           ,
            dlyirq_dsble                => mm2s_dlyirq_dsble                ,
            irqthresh_wren              => mm2s_irqthresh_wren              ,
            irqdelay_wren               => mm2s_irqdelay_wren               ,
            tailpntr_updated            => mm2s_tailpntr_updated            ,

            -- Error Detection Control
            stop                        => mm2s_stop                        ,
            dma_interr_set              => mm2s_dma_interr_set              ,
            dma_interr_set_minus_frame_errors              => mm2s_dma_interr_set_minus_frame_errors              ,
            dma_slverr_set              => mm2s_dma_slverr_set              ,
            dma_decerr_set              => mm2s_dma_decerr_set              ,
            ftch_slverr_set             => mm2s_ftch_slverr_set             ,
            ftch_decerr_set             => mm2s_ftch_decerr_set             ,

            fsize_mismatch_err          => mm2s_fsize_mismatch_err          ,   
            lsize_mismatch_err          => mm2s_lsize_mismatch_err          ,   
            lsize_more_mismatch_err          => mm2s_lsize_more_mismatch_err          ,   
            s2mm_fsize_more_or_sof_late => '0'          ,   

            -- VDMA Base Registers
    	reg_index                	=> mm2s_reg_index           ,

            dmacr                       => mm2s_dmacr                       ,
            dmasr                       => mm2s_dmasr                       ,
            curdesc                     => mm2s_curdesc                     ,
            taildesc                    => mm2s_taildesc                    ,
            num_frame_store             => mm2s_num_frame_store             ,
            linebuf_threshold           => mm2s_linebuf_threshold           ,

            -- Register Direct Support
            regdir_idle                 => mm2s_regdir_idle                 ,
            prmtr_updt_complete         => mm2s_prmtr_updt_complete         ,
            reg_module_vsize            => mm2s_reg_module_vsize            ,
            reg_module_hsize            => mm2s_reg_module_hsize            ,
            reg_module_stride           => mm2s_reg_module_stride           ,
            reg_module_frmdly           => mm2s_reg_module_frmdly           ,
            reg_module_strt_addr        => mm2s_reg_module_strt_addr        ,

            -- Fetch/Update error addresses
            frmstr_err_addr           => mm2s_frame_number                ,
            ftch_err_addr             => mm2s_ftch_err_addr
        );

    ---------------------------------------------------------------------------
    -- MM2S DMA Controller
    ---------------------------------------------------------------------------
    I_MM2S_DMA_MNGR : entity  axi_vdma_v6_2.axi_vdma_mngr
        generic map(
            C_PRMY_CMDFIFO_DEPTH        => DM_CMDSTS_FIFO_DEPTH             ,
            C_INCLUDE_SF                => DM_MM2S_INCLUDE_SF               ,
            C_USE_FSYNC                 => C_USE_MM2S_FSYNC                      , -- CR582182
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_ENABLE_FLUSH_ON_FSYNC     => ENABLE_FLUSH_ON_MM2S_FSYNC            , -- CR591965
            C_NUM_FSTORES               => C_NUM_FSTORES                    ,
            C_GENLOCK_MODE              => C_MM2S_GENLOCK_MODE              ,
            C_DYNAMIC_RESOLUTION        => C_DYNAMIC_RESOLUTION                ,
            C_GENLOCK_NUM_MASTERS       => C_MM2S_GENLOCK_NUM_MASTERS       ,
            --C_GENLOCK_REPEAT_EN         => C_MM2S_GENLOCK_REPEAT_EN         , -- CR591965
            --C_ENABLE_DEBUG_INFO         => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0       => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1       => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2       => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3       => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4       => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5       => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6       => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7       => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8       => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9       => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10      => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11      => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12      => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13      => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14      => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15      => C_ENABLE_DEBUG_INFO_15             ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE          ,
            C_INCLUDE_SG                => C_INCLUDE_SG                     , -- CR581800
            C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH            ,
            C_M_AXIS_SG_TDATA_WIDTH     => M_AXIS_SG_TDATA_WIDTH            ,
            C_M_AXI_ADDR_WIDTH          => C_M_AXI_MM2S_ADDR_WIDTH          ,
            C_DM_STATUS_WIDTH           => MM2S_DM_STATUS_WIDTH             , -- CR608521
            C_EXTEND_DM_COMMAND         => MM2S_DM_CMD_NOT_EXTENDED         ,
            C_MM2S_SOF_ENABLE           => MM2S_SOF_ENABLE ,
            C_S2MM_SOF_ENABLE           => 0 ,
            C_INCLUDE_MM2S              => C_INCLUDE_MM2S                   ,
            C_INCLUDE_S2MM              => 0                  ,
            C_FAMILY                    => C_ROOT_FAMILY
        )
        port map(

            -- Secondary Clock and Reset
            prmry_aclk                  => m_axi_mm2s_aclk                  ,
            prmry_resetn                => mm2s_prmry_resetn                ,
            soft_reset                  => mm2s_soft_reset                  ,

            scndry_aclk                 => '0'                 ,
            scndry_resetn               => '1'                 ,


            -- MM2S Control and Status
            run_stop                    => mm2s_dmacr(DMACR_RS_BIT)         ,
            dmacr_repeat_en             => mm2s_dmacr(DMACR_REPEAT_EN_BIT)     ,
            dmasr_halt                  => mm2s_dmasr(DMASR_HALTED_BIT)     ,
            sync_enable                 => mm2s_dmacr(DMACR_SYNCEN_BIT)     ,
            regdir_idle                 => mm2s_regdir_idle                 ,
            ftch_idle                   => mm2s_ftch_idle                   ,
            halt                        => mm2s_halt                        ,
            halt_cmplt                  => mm2s_halt_cmplt                  ,
            halted_clr                  => mm2s_halted_clr                  ,
            halted_set                  => mm2s_halted_set                  ,
            idle_set                    => mm2s_idle_set                    ,
            idle_clr                    => mm2s_idle_clr                    ,
            stop                        => mm2s_stop                        ,
            s2mm_dmasr_lsize_less_err   => '0'     ,
            s2mm_fsize_more_or_sof_late => '0'          ,   
            capture_hsize_at_uf_err     => open          ,   
            all_idle                    => mm2s_all_idle                    ,
            cmdsts_idle                 => mm2s_cmdsts_idle                 ,
            ftchcmdsts_idle             => mm2s_ftchcmdsts_idle             ,
            s2mm_fsync_out_m            => '0'                  ,
            frame_sync                  => mm2s_frame_sync                  ,
            mm2s_fsync_out_m            => mm2s_fsync_out_m                 ,   -- CR616211
            update_frmstore             => open                             ,   -- Not Needed for MM2S channel
            frmstr_err_addr           => open                             ,   -- Not Needed for MM2S channel
            frame_ptr_ref               => mm2s_ip2axi_frame_ptr_ref        ,
            frame_ptr_in                => mm2s_s_frame_ptr_in              ,
            frame_ptr_out               => mm2s_m_frame_ptr_out             ,
            internal_frame_ptr_in       => s2mm_to_mm2s_frame_ptr_in        ,
            valid_frame_sync            => mm2s_valid_frame_sync            ,
            valid_frame_sync_cmb        => mm2s_valid_frame_sync_cmb        ,
            valid_video_prmtrs          => mm2s_valid_video_prmtrs          ,
            parameter_update            => mm2s_parameter_update            ,
            circular_prk_mode           => mm2s_dmacr(DMACR_CRCLPRK_BIT)    ,
            mstr_pntr_ref               => mm2s_dmacr(DMACR_PNTR_NUM_MSB
                                               downto DMACR_PNTR_NUM_LSB)   ,
            genlock_select              => mm2s_dmacr(DMACR_GENLOCK_SEL_BIT),
            line_buffer_empty           => mm2s_allbuffer_empty             ,
            dwidth_fifo_pipe_empty           => mm2s_dwidth_fifo_pipe_empty_m             ,
            crnt_vsize                  => mm2s_crnt_vsize                  ,   -- CR616211
            num_frame_store             => mm2s_num_frame_store             ,
            all_lines_xfred             => mm2s_all_lines_xfred             ,   -- CR616211
            all_lasts_rcvd              => all_lasts_rcvd             ,   -- 
            fsize_mismatch_err_flag     => mm2s_fsize_mismatch_err_flag          ,   -- CR591965
            s2mm_fsize_mismatch_err_s   => open                             ,   -- Not Needed for MM2S channel
drop_fsync_d_pulse_gen_fsize_less_err   => '0'                      ,
      	    s2mm_strm_all_lines_rcvd    => '0'	,	--      : out std_logic;
            s2mm_fsync_core             => '0'                      ,
            mm2s_fsize_mismatch_err_s   => mm2s_fsize_mismatch_err_s          ,   -- CR591965
            mm2s_fsize_mismatch_err_m   => mm2s_fsize_mismatch_err_m          ,   -- CR591965
            fsize_mismatch_err          => mm2s_fsize_mismatch_err          ,   -- CR591965
            lsize_mismatch_err          => mm2s_lsize_mismatch_err          ,   -- CR591965
            lsize_more_mismatch_err          => mm2s_lsize_more_mismatch_err          ,   -- CR591965


            -- Register Direct Support
            prmtr_updt_complete         => mm2s_prmtr_updt_complete         ,
            reg_module_vsize            => mm2s_reg_module_vsize            ,
            reg_module_hsize            => mm2s_reg_module_hsize            ,
            reg_module_stride           => mm2s_reg_module_stride           ,
            reg_module_frmdly           => mm2s_reg_module_frmdly           ,
            reg_module_strt_addr        => mm2s_reg_module_strt_addr        ,

            -- Fsync signals and Genlock for test vector
            tstvect_err               => mm2s_tstvect_err               ,
            tstvect_fsync               => mm2s_tstvect_fsync               ,
            tstvect_frame               => mm2s_tstvect_frame               ,
            tstvect_frm_ptr_out         => mm2s_tstvect_frm_ptr_out         ,
            mstrfrm_tstsync_out         => mm2s_mstrfrm_tstsync             ,

            -- AXI Stream Timing
            packet_sof                  => '1'                              ,  -- NOT Used for MM2S

            -- Primary DMA Errors
            dma_interr_set              => mm2s_dma_interr_set              ,
            dma_interr_set_minus_frame_errors              => mm2s_dma_interr_set_minus_frame_errors              ,
            dma_slverr_set              => mm2s_dma_slverr_set              ,
            dma_decerr_set              => mm2s_dma_decerr_set              ,


            -- SG MM2S Descriptor Fetch AXI Stream In
            m_axis_ftch_tdata           => m_axis_mm2s_ftch_tdata           ,
            m_axis_ftch_tvalid          => m_axis_mm2s_ftch_tvalid          ,
            m_axis_ftch_tready          => m_axis_mm2s_ftch_tready          ,
            m_axis_ftch_tlast           => m_axis_mm2s_ftch_tlast           ,

            -- Currently Being Processed Descriptor/Frame
            frame_number                => mm2s_frame_number                ,
            chnl_current_frame          => mm2s_chnl_current_frame                ,
            genlock_pair_frame          => mm2s_genlock_pair_frame                ,
            new_curdesc                 => mm2s_new_curdesc                 ,
            new_curdesc_wren            => mm2s_new_curdesc_wren            ,
            tailpntr_updated            => mm2s_tailpntr_updated            ,

            -- User Command Interface Ports (AXI Stream)
            s_axis_cmd_tvalid           => s_axis_mm2s_cmd_tvalid           ,
            s_axis_cmd_tready           => s_axis_mm2s_cmd_tready           ,
            s_axis_cmd_tdata            => s_axis_mm2s_cmd_tdata            ,

            -- User Status Interface Ports (AXI Stream)
            m_axis_sts_tvalid           => m_axis_mm2s_sts_tvalid           ,
            m_axis_sts_tready           => m_axis_mm2s_sts_tready           ,
            m_axis_sts_tdata            => m_axis_mm2s_sts_tdata            ,
            m_axis_sts_tkeep            => m_axis_mm2s_sts_tkeep            ,
            err                         => mm2s_err                         ,
            ftch_err                  => mm2s_ftch_err
        );

    ---------------------------------------------------------------------------
    -- MM2S Frame sync generator
    ---------------------------------------------------------------------------
    MM2S_FSYNC_I : entity  axi_vdma_v6_2.axi_vdma_fsync_gen
        generic map(
            C_USE_FSYNC                 => C_USE_MM2S_FSYNC                      ,
            ENABLE_FLUSH_ON_S2MM_FSYNC  => 0                      ,
            ENABLE_FLUSH_ON_MM2S_FSYNC  => ENABLE_FLUSH_ON_MM2S_FSYNC                      ,
            C_INCLUDE_S2MM              => 0                   ,
            C_INCLUDE_MM2S              => 1                       ,
            C_SOF_ENABLE                => MM2S_SOF_ENABLE                                    -- Always disabled
        )
        port map(
            prmry_aclk                  => m_axi_mm2s_aclk                  ,
            prmry_resetn                => mm2s_prmry_resetn                ,

            -- Frame Count Enable Support
            valid_frame_sync_cmb        => mm2s_valid_frame_sync_cmb        ,
            valid_video_prmtrs          => mm2s_valid_video_prmtrs          ,
            frmcnt_ioc                  => mm2s_ioc_irq_set                 ,
            dmacr_frmcnt_enbl           => mm2s_dmacr(DMACR_FRMCNTEN_BIT)   ,
            dmasr_frmcnt_status         => mm2s_irqthresh_status            ,
            mask_fsync_out              => mm2s_mask_fsync_out              ,

            -- VDMA process status
            run_stop                    => mm2s_dmacr(DMACR_RS_BIT)         ,
            all_idle                    => mm2s_all_idle                    ,
            parameter_update            => mm2s_parameter_update            ,

            -- VDMA Frame Sync Sources
            fsync                       => mm2s_cdc2dmac_fsync              ,
            tuser_fsync                 => '0'                              ,   -- Not used by MM2S
            othrchnl_fsync              => s2mm_to_mm2s_fsync               ,

            fsync_src_select            => mm2s_dmacr(DMACR_FSYNCSEL_MSB
                                            downto DMACR_FSYNCSEL_LSB)      ,

            -- VDMA frame sync output to core
            frame_sync                  => mm2s_frame_sync                  ,

            -- VDMA frame sync output to ports
            frame_sync_out              => mm2s_dmac2cdc_fsync_out          ,
            prmtr_update                => mm2s_dmac2cdc_prmtr_update
        );

    -- Clock Domain Crossing between m_axi_mm2s_aclk and m_axis_mm2s_aclk
    MM2S_VID_CDC_I : entity axi_vdma_v6_2.axi_vdma_vid_cdc
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_GENLOCK_MSTR_PTR_DWIDTH   => NUM_FRM_STORE_WIDTH          ,
            C_GENLOCK_SLVE_PTR_DWIDTH   => MM2S_GENLOCK_SLVE_PTR_DWIDTH     ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE
        )
        port map(
            prmry_aclk                  => m_axi_mm2s_aclk                  ,
            prmry_resetn                => mm2s_prmry_resetn                ,

            scndry_aclk                 => m_axis_mm2s_aclk                 ,
            scndry_resetn               => mm2s_axis_resetn                 ,

            -- Genlock internal bus cdc
            othrchnl_aclk               => m_axi_s2mm_aclk                  ,
            othrchnl_resetn             => s2mm_prmry_resetn                ,
            othrchnl2cdc_frame_ptr_out  => s2mm_frame_ptr_out_i             ,
            cdc2othrchnl_frame_ptr_in   => s2mm_to_mm2s_frame_ptr_in        ,

            cdc2othrchnl_fsync          => mm2s_to_s2mm_fsync               ,

            -- GenLock Clock Domain Crossing
            dmac2cdc_frame_ptr_out      => mm2s_m_frame_ptr_out             ,
            cdc2top_frame_ptr_out       => mm2s_frame_ptr_out_i             ,
            top2cdc_frame_ptr_in        => mm2s_frame_ptr_in                ,
            cdc2dmac_frame_ptr_in       => mm2s_s_frame_ptr_in              ,
            dmac2cdc_mstrfrm_tstsync    => mm2s_mstrfrm_tstsync             ,
            cdc2dmac_mstrfrm_tstsync    => mm2s_mstrfrm_tstsync_out         ,

            -- SOF Detection Domain Crossing
            vid2cdc_packet_sof          => mm2s_vid2cdc_packet_sof          ,
            cdc2dmac_packet_sof         => mm2s_packet_sof                  ,

            -- Frame Sync Generation Domain Crossing
            vid2cdc_fsync               => mm2s_fsync_core                       ,
            cdc2dmac_fsync              => mm2s_cdc2dmac_fsync              ,

            dmac2cdc_fsync_out          => mm2s_dmac2cdc_fsync_out          ,
            dmac2cdc_prmtr_update       => mm2s_dmac2cdc_prmtr_update       ,

            cdc2vid_fsync_out           => mm2s_fsync_out_i                 ,
            cdc2vid_prmtr_update        => mm2s_prmtr_update_i
        );

    mm2s_fsync_out_sig  <= mm2s_fsync_out_i;

    -- Start of Frame Detection - used for interrupt coalescing
    MM2S_SOF_I : entity  axi_vdma_v6_2.axi_vdma_sof_gen
        port map(
            scndry_aclk                 => m_axis_mm2s_aclk                 ,
            scndry_resetn               => mm2s_axis_resetn                 ,

            axis_tready                 => m_axis_mm2s_tready_i2               ,
            ---axis_tvalid                 => m_axis_mm2s_tvalid_i             ,
            axis_tvalid                 => m_axis_mm2s_tvalid_i2             ,

            fsync                       => mm2s_fsync_out_i                 , -- CR622884

            packet_sof                  => mm2s_vid2cdc_packet_sof
        );

    ---------------------------------------------------------------------------
    -- Primary MM2S Line Buffer
    ---------------------------------------------------------------------------
    MM2S_LINEBUFFER_I : entity  axi_vdma_v6_2.axi_vdma_mm2s_linebuf
        generic map(
            C_DATA_WIDTH                => C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED        ,
            C_M_AXIS_MM2S_TDATA_WIDTH   => C_M_AXIS_MM2S_TDATA_WIDTH        ,
            --C_INCLUDE_MM2S_SF           => C_INCLUDE_MM2S_SF                ,
            C_INCLUDE_MM2S_SF           => 0                ,
            C_INCLUDE_MM2S_DRE          => C_MM2S_ENABLE_TKEEP                   ,
            C_MM2S_SOF_ENABLE           => MM2S_SOF_ENABLE                  ,
            C_M_AXIS_MM2S_TUSER_BITS    => C_M_AXIS_MM2S_TUSER_BITS         ,
            C_TOPLVL_LINEBUFFER_DEPTH   => C_MM2S_LINEBUFFER_DEPTH          , -- CR625142
            ENABLE_FLUSH_ON_FSYNC       => ENABLE_FLUSH_ON_MM2S_FSYNC,
            --C_ENABLE_DEBUG_INFO         => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0       => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1       => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2       => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3       => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4       => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5       => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6       => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7       => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8       => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9       => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10      => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11      => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12      => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13      => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14      => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15      => C_ENABLE_DEBUG_INFO_15             ,
            C_LINEBUFFER_DEPTH          => MM2S_LINEBUFFER_DEPTH            ,
            C_LINEBUFFER_AE_THRESH      => C_MM2S_LINEBUFFER_THRESH_INT         ,
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_FAMILY                    => C_ROOT_FAMILY
        )
        port map(
            -------------------------------------------------------------------
            -- AXI Scatter Gather Interface
            -------------------------------------------------------------------
            -- MM2S AXIS Datamover side
            s_axis_aclk                 => m_axi_mm2s_aclk                  ,
            s_axis_resetn               => mm2s_prmry_resetn                ,

            -- MM2S AXIS Out side
            m_axis_aclk                 => m_axis_mm2s_aclk                 ,
            m_axis_resetn               => mm2s_axis_resetn                 ,
            mm2s_axis_linebuf_reset_out => mm2s_axis_linebuf_reset_out                 ,
            run_stop                    => mm2s_dmacr(DMACR_RS_BIT)         ,


            s2mm_axis_resetn            => s2mm_axis_resetn                     ,
            s_axis_s2mm_aclk            => s_axis_s2mm_aclk                     ,
            mm2s_fsync                  => mm2s_fsync_fe                      ,
            s2mm_fsync                  => s2mm_fsync_fe                      ,
            mm2s_fsync_core             => mm2s_fsync_core                      ,
            mm2s_vsize_cntr_clr_flag    => mm2s_vsize_cntr_clr_flag                            , 
            mm2s_fsize_mismatch_err_flag => mm2s_fsize_mismatch_err_flag                            , 
            MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S   => MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S                      ,
            mm2s_fsize_mismatch_err_m   => mm2s_fsize_mismatch_err_m                      ,
            mm2s_fsize_mismatch_err_s   => mm2s_fsize_mismatch_err_s                      ,
            fsync_src_select            => mm2s_dmacr(DMACR_FSYNCSEL_MSB
                                            downto DMACR_FSYNCSEL_LSB)      ,

            -- Graceful shut down control
            cmdsts_idle                 => mm2s_cmdsts_idle                 ,
            dm_halt                     => mm2s_halt                        ,
            dm_halt_reg_out             => mm2s_halt_reg                        ,
            stop                        => mm2s_stop                        ,   -- CR623291
            stop_reg_out                => mm2s_stop_reg                        ,   -- CR623291

            -- Vertical Line Count control
            crnt_vsize                  => mm2s_crnt_vsize                  ,   -- CR616211
            crnt_vsize_d2_out           => mm2s_crnt_vsize_d2                  ,   -- CR616211
            fsync_out                   => mm2s_fsync_out_i                 ,   -- CR616211
            fsync_out_m                 => mm2s_fsync_out_m                 ,   -- CR616211
            frame_sync                  => mm2s_frame_sync                  ,   -- CR616211

            -- Threshold
            linebuf_threshold           => mm2s_linebuf_threshold           ,


            -- Stream In (Datamover to Linebuffer)
            s_axis_tdata                => dm2linebuf_mm2s_tdata            ,
            s_axis_tkeep                => dm2linebuf_mm2s_tkeep            ,
            s_axis_tlast                => dm2linebuf_mm2s_tlast            ,
            s_axis_tvalid               => dm2linebuf_mm2s_tvalid           ,
            s_axis_tready               => linebuf2dm_mm2s_tready           ,

            -- Stream Out (Linebuffer to AXIS Out)
            m_axis_tdata                => m_axis_mm2s_tdata_i                ,
            m_axis_tkeep                => m_axis_mm2s_tkeep_i                ,
            m_axis_tlast                => m_axis_mm2s_tlast_i              ,
            m_axis_tvalid               => m_axis_mm2s_tvalid_i             ,
            m_axis_tready               => m_axis_mm2s_tready_i               ,
            m_axis_tuser                => m_axis_mm2s_tuser_i                ,

            -- Fifo Status Flags
            dwidth_fifo_pipe_empty      => mm2s_dwidth_fifo_pipe_empty             ,
            dwidth_fifo_pipe_empty_m      => mm2s_dwidth_fifo_pipe_empty_m             ,
            mm2s_fifo_pipe_empty        => mm2s_allbuffer_empty             ,
            mm2s_fifo_empty             => mm2s_buffer_empty_i                ,
            mm2s_fifo_almost_empty      => mm2s_buffer_almost_empty_i         ,
            mm2s_all_lines_xfred_s_dwidth => mm2s_all_lines_xfred_s_dwidth         ,
            mm2s_all_lines_xfred_s      => mm2s_all_lines_xfred_s         ,
            mm2s_all_lines_xfred        => mm2s_all_lines_xfred                 -- CR616211
        );


end generate GEN_SPRT_FOR_MM2S;


-- Do not generate support logic for MM2S
GEN_NO_SPRT_FOR_MM2S : if C_INCLUDE_MM2S = 0 generate
begin
    -- Register Module Tie-Offs
    mm2s_ip2axi_rddata              <= (others => '0');
    --mm2s_ip2axi_rddata_valid        <= '0';
    mm2s_ip2axi_frame_ptr_ref       <= (others => '0');
    mm2s_ip2axi_frame_store         <= (others => '0');
    mm2s_ip2axi_introut             <= '0';
    mm2s_soft_reset                 <= '0';
    mm2s_irqthresh_rstdsbl          <= '0';
    mm2s_dlyirq_dsble               <= '0';
    mm2s_irqthresh_wren             <= '0';
    mm2s_irqdelay_wren              <= '0';
    mm2s_tailpntr_updated           <= '0';
    mm2s_dmacr                      <= (others => '0');
    mm2s_dmasr                      <= (others => '0');
    mm2s_curdesc                    <= (others => '0');
    mm2s_taildesc                   <= (others => '0');

    --internal to mm2s generate (dont really need to tie off)
    mm2s_num_frame_store            <= (others => '0');
    mm2s_linebuf_threshold          <= (others => '0');
    mm2s_regdir_idle                <= '0';
    mm2s_prmtr_updt_complete        <= '0';
    mm2s_reg_module_vsize           <= (others => '0');
    mm2s_reg_module_hsize           <= (others => '0');
    mm2s_reg_module_stride          <= (others => '0');
    mm2s_reg_module_frmdly          <= (others => '0');

    -- Must zero each element of an array of vectors to zero
    -- all vectors.
    GEN_MM2S_ZERO_STRT : for i in 0 to C_NUM_FSTORES-1 generate
        begin
            mm2s_reg_module_strt_addr(i)   <= (others => '0');
    end generate GEN_MM2S_ZERO_STRT;

    -- Line Buffer Tie-Offs
    linebuf2dm_mm2s_tready          <= '0';
    m_axis_mm2s_tdata               <= (others => '0');
    m_axis_mm2s_tdata_i               <= (others => '0');
    m_axis_mm2s_tkeep               <= (others => '0');
    m_axis_mm2s_tkeep_i               <= (others => '0');
    m_axis_mm2s_tlast_i             <= '0';
    m_axis_mm2s_tlast_i_axis_dw_conv             <= '0';
    m_axis_mm2s_tuser               <= (others => '0');
    m_axis_mm2s_tuser_i               <= (others => '0');
    m_axis_mm2s_tvalid_i            <= '0';
    m_axis_mm2s_tvalid_i2            <= '0';
    m_axis_mm2s_tvalid_i_axis_dw_conv            <= '0';
    mm2s_allbuffer_empty            <= '0';
    mm2s_dwidth_fifo_pipe_empty            <= '0';
    mm2s_buffer_empty_i               <= '0';
    mm2s_buffer_almost_empty_i        <= '0';
    mm2s_all_lines_xfred            <= '0';

    -- SOF generator
    mm2s_packet_sof                 <= '0';

    -- DMA Controller
    mm2s_halted_clr                 <= '0';
    mm2s_halted_set                 <= '0';
    mm2s_idle_set                   <= '0';
    mm2s_idle_clr                   <= '0';
    mm2s_frame_number               <= (others => '0');
    mm2s_chnl_current_frame               <= (others => '0');
    mm2s_genlock_pair_frame               <= (others => '0');
    mm2s_new_curdesc                <= (others => '0');
    mm2s_new_curdesc_wren           <= '0';
    mm2s_stop                       <= '0';
    mm2s_stop_reg                       <= '0';
    mm2s_all_idle                   <= '1';
    mm2s_cmdsts_idle                <= '1';
    mm2s_ftchcmdsts_idle            <= '1';
    m_axis_mm2s_ftch_tready         <= '0';
    s_axis_mm2s_cmd_tvalid          <= '0';
    s_axis_mm2s_cmd_tdata           <= (others => '0');
    m_axis_mm2s_sts_tready          <= '0';
    mm2s_m_frame_ptr_out            <= (others => '0');
    mm2s_frame_ptr_out_i            <= (others => '0');
    s2mm_to_mm2s_frame_ptr_in       <= (others => '0');
    mm2s_valid_frame_sync           <= '0';
    mm2s_valid_frame_sync_cmb       <= '0';
    mm2s_valid_video_prmtrs         <= '0';
    mm2s_parameter_update           <= '0';
    mm2s_tstvect_err              <= '0';
    mm2s_tstvect_fsync              <= '0';
    mm2s_tstvect_frame              <= (others => '0');
    mm2s_dma_interr_set             <= '0';
    mm2s_dma_interr_set_minus_frame_errors             <= '0';
    mm2s_dma_slverr_set             <= '0';
    mm2s_dma_decerr_set             <= '0';
    mm2s_crnt_vsize                 <= (others => '0');
    mm2s_crnt_vsize_d2                 <= (others => '0');
    mm2s_fsize_mismatch_err         <= '0';
    mm2s_lsize_mismatch_err         <= '0';
    mm2s_lsize_more_mismatch_err         <= '0';

    -- Frame Sync generator
    mm2s_frame_sync                 <= '0';
    mm2s_fsync_out_sig                  <= '0';
    mm2s_prmtr_update_i               <= '0';
    mm2s_mask_fsync_out             <= '0';
    mm2s_mstrfrm_tstsync            <= '0';
    mm2s_mstrfrm_tstsync_out        <= '0';
    mm2s_tstvect_frm_ptr_out        <= (others => '0');
    mm2s_to_s2mm_fsync              <= '0';


end generate GEN_NO_SPRT_FOR_MM2S;

--*****************************************************************************
--**                            S2MM CHANNEL                                 **
--*****************************************************************************

-- Generate support logic for S2MM
GEN_SPRT_FOR_S2MM : if C_INCLUDE_S2MM = 1 generate

		signal no_fsync_before_vsize_sel_00_01             	: std_logic := '0';
begin
------------------------------------------------------------------------------------------------------------------------------------------------------


s2mm_axis_linebuf_reset_out_inv <= not s2mm_axis_linebuf_reset_out;

GEN_S2MM_DRE_ON_SKID : if C_S2MM_ENABLE_TKEEP = 1 generate
begin


    --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
    I_S2MM_SKID_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_skid_buf
        generic map(
            C_WDATA_WIDTH           => C_S_AXIS_S2MM_TDATA_WIDTH             ,
            C_TUSER_WIDTH           => C_S_AXIS_S2MM_TUSER_BITS
        )
        port map(
            -- System Ports
            ACLK                   => s_axis_s2mm_aclk              ,
            ARST                   => s2mm_axis_linebuf_reset_out_inv          ,

            -- Shutdown control (assert for 1 clk pulse)
            skid_stop              => '0'                      ,

            -- Slave Side (Stream Data Input)
            S_VALID                => s_axis_s2mm_tvalid   ,
            S_READY                => s_axis_s2mm_tready        ,
            S_Data                 => s_axis_s2mm_tdata             ,
            S_STRB                 => s_axis_s2mm_tkeep             ,
            S_Last                 => s_axis_s2mm_tlast             ,
            S_User                 => s_axis_s2mm_tuser             ,

            -- Master Side (Stream Data Output)
            M_VALID                => s_axis_s2mm_tvalid_signal            ,
            M_READY                => s_axis_s2mm_tready_signal            ,
            M_Data                 => s_axis_s2mm_tdata_signal             ,
            M_STRB                 => s_axis_s2mm_tkeep_signal             ,
            M_Last                 => s_axis_s2mm_tlast_signal            ,
            M_User                 => s_axis_s2mm_tuser_signal 
        );

end generate GEN_S2MM_DRE_ON_SKID;


GEN_S2MM_DRE_OFF_SKID : if C_S2MM_ENABLE_TKEEP = 0 generate
begin



    --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
    I_S2MM_SKID_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_skid_buf
        generic map(
            C_WDATA_WIDTH           => C_S_AXIS_S2MM_TDATA_WIDTH             ,
            C_TUSER_WIDTH           => C_S_AXIS_S2MM_TUSER_BITS
        )
        port map(
            -- System Ports
            ACLK                   => s_axis_s2mm_aclk              ,
            ARST                   => s2mm_axis_linebuf_reset_out_inv          ,

            -- Shutdown control (assert for 1 clk pulse)
            skid_stop              => '0'                      ,

            -- Slave Side (Stream Data Input)
            S_VALID                => s_axis_s2mm_tvalid   ,
            S_READY                => s_axis_s2mm_tready        ,
            S_Data                 => s_axis_s2mm_tdata             ,
            --S_STRB                 => s_axis_s2mm_tkeep             ,
            S_STRB                 => (others => '1')             ,
            S_Last                 => s_axis_s2mm_tlast             ,
            S_User                 => s_axis_s2mm_tuser             ,

            -- Master Side (Stream Data Output)
            M_VALID                => s_axis_s2mm_tvalid_signal            ,
            M_READY                => s_axis_s2mm_tready_signal            ,
            M_Data                 => s_axis_s2mm_tdata_signal             ,
            M_STRB                 => s_axis_s2mm_tkeep_signal             ,
            M_Last                 => s_axis_s2mm_tlast_signal            ,
            M_User                 => s_axis_s2mm_tuser_signal 
        );


end generate GEN_S2MM_DRE_OFF_SKID;







	GEN_FLUSH_SOF_TREADY : if ENABLE_FLUSH_ON_S2MM_FSYNC = 1 and  S2MM_SOF_ENABLE = 1 generate


		signal s2mm_fsize_less_err_flag_10          			: std_logic := '0'; 
		signal s2mm_fsize_less_err_flag_00_01          			: std_logic := '0'; 
		signal s_axis_s2mm_tuser_d1                 			: std_logic := '0';
		signal s2mm_tuser_to_fsync_out                 			: std_logic := '0';
		signal d_tready_sof_late                 			: std_logic := '0';
		signal d_tready_sof_late_cmb                 			: std_logic := '0';
		signal s2mm_sof_late_err                 			: std_logic := '0';

		signal s2mm_prmtr_or_tail_ptr_updt_complete             	: std_logic := '0';
		signal s2mm_prmtr_updt_complete_s             			: std_logic := '0';
		signal s2mm_dmasr_halted_s             				: std_logic := '0';
		signal d_tready_before_fsync_clr_flag1             		: std_logic := '0';
		signal d_tready_before_fsync             			: std_logic := '0';
		signal d_tready_before_fsync_cmb             			: std_logic := '0';

		signal d_tready_after_prmtr_updt             			: std_logic := '0';
		signal d_tready_after_prmtr_updt_clrd_till_reset           	: std_logic := '0';
		signal d_tready_after_prmtr_updt_clrd             		: std_logic := '0';
		signal d_tready_sof_late_prmtr_updt             		: std_logic := '0';
		signal d_tready_after_prmtr_updt_clrd_cmb             		: std_logic := '0';
		signal s2mm_sof_late_err_prmtr_updt             		: std_logic := '0';

		signal s2mm_fsync_src_select_s_d1                  		: std_logic_vector(1 downto 0) := (others => '0');


		signal s2mm_dummy_tready_fsync_src_sel_00_or_01       		: std_logic := '0';
		signal s2mm_dummy_tready_fsync_src_sel_10       		: std_logic := '0';


		signal d_tready_before_fsync_clr_flag1_sel_00_01             	: std_logic := '0';
		signal d_tready_before_fsync_clrd_sel_00_01            	 	: std_logic := '0';
		signal d_tready_before_fsync_clr_sel_00_01            	 	: std_logic := '0';
		signal d_tready_before_fsync_sel_00_01             		: std_logic := '0';
		signal d_tready_before_fsync_cmb_sel_00_01           		: std_logic := '0';
		signal d_tready_after_vcount_sel_00_01           		: std_logic := '0';
		signal after_vcount_flag_sel_00_01	           		: std_logic := '0';
		signal d_tready_after_fsize_less_err_flag_00_01       		: std_logic := '0';
		signal d_tready_after_fsize_less_err_00_01       		: std_logic := '0';
		signal s2mm_fsize_less_err_internal_tvalid_gating_10       	: std_logic := '0';
		signal s2mm_fsize_less_err_internal_tvalid_gating_00_01       	: std_logic := '0';

        	    begin


no_fsync_before_vsize_sel_00_01 <= d_tready_before_fsync_clr_flag1_sel_00_01;










	
 		s_axis_s2mm_tvalid_int			<= 	s_axis_s2mm_tvalid_signal and s2mm_chnl_ready ;
		s_axis_s2mm_tready_signal		<= 	(s_axis_s2mm_tready_i_axis_dw_conv  and s2mm_chnl_ready) or s2mm_dummy_tready;




GEN_C_USE_S2MM_FSYNC_1 : if C_USE_S2MM_FSYNC = 1 generate
begin
                        s2mm_dummy_tready <= s2mm_dummy_tready_fsync_src_sel_00_or_01;
                        s2mm_fsize_less_err_internal_tvalid_gating <= s2mm_fsize_less_err_internal_tvalid_gating_00_01;

end generate GEN_C_USE_S2MM_FSYNC_1;


GEN_C_USE_S2MM_FSYNC_2 : if C_USE_S2MM_FSYNC = 2 generate
begin
                        s2mm_dummy_tready <= s2mm_dummy_tready_fsync_src_sel_10;
                        s2mm_fsize_less_err_internal_tvalid_gating <= s2mm_fsize_less_err_internal_tvalid_gating_10;

end generate GEN_C_USE_S2MM_FSYNC_2;






----        FSYNC_SEL_TREADY_S2MM_S : process(s2mm_fsync_src_select_s_d1,
----                                 s2mm_dummy_tready,
----                                 s2mm_dummy_tready_fsync_src_sel_00_or_01,
----                                 s2mm_fsize_less_err_internal_tvalid_gating_10,
----                                 s2mm_fsize_less_err_internal_tvalid_gating_00_01,
----                                 s2mm_fsize_less_err_internal_tvalid_gating,
----                                 s2mm_dummy_tready_fsync_src_sel_10)
----            begin
----                case s2mm_fsync_src_select_s_d1 is
----
----                    when "00" =>   -- primary fsync (default)
----                        s2mm_dummy_tready <= s2mm_dummy_tready_fsync_src_sel_00_or_01;
----                        s2mm_fsize_less_err_internal_tvalid_gating <= s2mm_fsize_less_err_internal_tvalid_gating_00_01;
----                    when "01" =>   -- other channel fsync
----                        s2mm_dummy_tready <= s2mm_dummy_tready_fsync_src_sel_00_or_01;
----                        s2mm_fsize_less_err_internal_tvalid_gating <= s2mm_fsize_less_err_internal_tvalid_gating_00_01;
----                    when "10" =>   -- s2mm_tuser_fsync_top_d1 fsync  
----                        s2mm_dummy_tready <= s2mm_dummy_tready_fsync_src_sel_10;
----                        s2mm_fsize_less_err_internal_tvalid_gating <= s2mm_fsize_less_err_internal_tvalid_gating_10;
----                    when others =>
----                        s2mm_dummy_tready <= '0';
----                        s2mm_fsize_less_err_internal_tvalid_gating <= '0';
----                end case;
----            end process FSYNC_SEL_TREADY_S2MM_S;
----
----
----
----				D1_S2MM_FSYNC_SRC_SEL_STRM : process(s_axis_s2mm_aclk)
----				    begin
----				        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
----				            if(s2mm_axis_resetn = '0')then
----				                s2mm_fsync_src_select_s_d1  <= (others => '0');
----				            else
----				                s2mm_fsync_src_select_s_d1  <= s2mm_fsync_src_select_s;
----				            end if;
----				        end if;
----				    end process D1_S2MM_FSYNC_SRC_SEL_STRM;
----


--------------------------------------------------TUSER Start-------------------------------------------------------------------------------------------------------------------------

		s2mm_dummy_tready_fsync_src_sel_10	<= 	d_tready_sof_late_cmb  or d_tready_before_fsync_cmb ;


		d_tready_sof_late_cmb 			<= 	d_tready_sof_late  when  s2mm_tuser_fsync_top = '0' and s2mm_tuser_to_fsync_out = '0' and s2mm_chnl_ready = '0'             											    else '0';

        	TUSER_TO_FSYNC_OUT_FLAG : process(s_axis_s2mm_aclk)
        	    begin
        	        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
        	            if(s2mm_axis_resetn = '0' or s2mm_fsync_out_i = '1'  )then
        	                s2mm_tuser_to_fsync_out <= '0';
        	            elsif(s2mm_tuser_fsync_top = '1' and d_tready_before_fsync_clr_flag1 = '0')then
        	                s2mm_tuser_to_fsync_out <= '1';
        	            end if;
        	        end if;
        	    end process TUSER_TO_FSYNC_OUT_FLAG;

		s2mm_fsize_less_err_internal_tvalid_gating_10 <= '1'  when  s2mm_fsize_less_err_flag_10 = '1' and  s2mm_tuser_fsync_top = '0'
		            else '0';
		
		
		FSIZE_LESS_ERR_FLAG_10 : process(s_axis_s2mm_aclk)
		    begin
		        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
		            if(s2mm_axis_resetn = '0' or s2mm_tuser_fsync_top = '1')then
		                s2mm_fsize_less_err_flag_10  <= '0';
		            elsif(s2mm_fsize_mismatch_err_s = '1')then
		                s2mm_fsize_less_err_flag_10  <= '1';
		            end if;
		        end if;
		    end process FSIZE_LESS_ERR_FLAG_10;
		

    		    TOP_TUSER_RE_PROCESS : process(s_axis_s2mm_aclk)
    		        begin
    		            if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
    		                if(s2mm_axis_resetn = '0')then
    		                    s_axis_s2mm_tuser_d1 <= '0';
    		                else
    		                    s_axis_s2mm_tuser_d1 <= s_axis_s2mm_tuser_signal(0) and s_axis_s2mm_tvalid_signal;
    		                end if;
    		            end if;
    		        end process TOP_TUSER_RE_PROCESS;

    		    s2mm_tuser_fsync_top <= s_axis_s2mm_tuser_signal(0) and s_axis_s2mm_tvalid_signal and (not s_axis_s2mm_tuser_d1);


        	SOF_LATE_ERR_PULSE_PROCESS : process(s_axis_s2mm_aclk)
        	    begin
        	        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
        	            if(s2mm_axis_resetn = '0' or s2mm_sof_late_err = '1' or s2mm_chnl_ready = '1' or d_tready_before_fsync_clr_flag1 = '1')then
        	                s2mm_sof_late_err <= '0';
        	                d_tready_sof_late <= '0';
        	            elsif((s2mm_chnl_ready = '0' or s2mm_fsize_less_err_internal_tvalid_gating_10 = '1') and s_axis_s2mm_tvalid_signal = '1' and s_axis_s2mm_tuser_signal(0) = '0' ) then
        	                s2mm_sof_late_err <= '1';
        	                d_tready_sof_late <= '1';
        	            end if;
        	        end if;
        	    end process SOF_LATE_ERR_PULSE_PROCESS;




--------------------------------------------------------------------------------------------------------



d_tready_before_fsync_cmb <= d_tready_before_fsync and d_tready_before_fsync_clr_flag1;





GEN_D_TREADY_BEFORE_FSYNC : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(d_tready_before_fsync_clr_flag1 = '0')then
                d_tready_before_fsync  <= '0';
            elsif(s2mm_axis_resetn = '1' or s2mm_dmasr_halted_s = '1')then
                d_tready_before_fsync  <= '1';
            end if;
        end if;
    end process GEN_D_TREADY_BEFORE_FSYNC;






VALID_PRM_UPDT_FLAG_10 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_axis_resetn = '0' or s2mm_dmasr_halted_s = '1')then
                d_tready_before_fsync_clr_flag1  <= '1';
            elsif(s2mm_prmtr_updt_complete_s = '1')then
                d_tready_before_fsync_clr_flag1  <= '0';
            end if;
        end if;
    end process VALID_PRM_UPDT_FLAG_10;



--------------------------------------------------TUSER End-------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------External Fsync Start-----------------------------------------------------------------------------------------------------------------------


s2mm_dummy_tready_fsync_src_sel_00_or_01	<= 	d_tready_after_fsize_less_err_00_01 or d_tready_after_vcount_sel_00_01 or d_tready_before_fsync_cmb_sel_00_01;


--------------------------------------------------------------------------------------------------------------

d_tready_after_fsize_less_err_00_01 <= '1'  when  d_tready_after_fsize_less_err_flag_00_01 = '1' and  s2mm_fsync_core = '0' and hold_dummy_tready_low2 = '0'
            else '0';



TREADY_AFTER_FSIZE_LESS_ERR_FLAG_00_01 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_axis_resetn = '0' or s2mm_fsync_core = '1'  or hold_dummy_tready_low2 = '1')then
                d_tready_after_fsize_less_err_flag_00_01  <= '0';
            elsif(s2mm_fsize_mismatch_err_s = '1')then
                d_tready_after_fsize_less_err_flag_00_01  <= '1';
            end if;
        end if;
    end process TREADY_AFTER_FSIZE_LESS_ERR_FLAG_00_01;


--------------------------------------------------------------------------------------------------------------


d_tready_after_vcount_sel_00_01 <= '1'  when  s2mm_fsync_core = '0' and after_vcount_flag_sel_00_01 = '1' and hold_dummy_tready_low = '0'
            else '0';

REG_S2MM_FSYNC_TO_FSYNC_OUT_FLAG_00_01 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_axis_resetn = '0' or s2mm_fsync_core = '1' or hold_dummy_tready_low = '1')then
                after_vcount_flag_sel_00_01  <= '0';
            elsif(s2mm_all_vount_rcvd = '1')then
                after_vcount_flag_sel_00_01  <= '1';
            end if;
        end if;
    end process REG_S2MM_FSYNC_TO_FSYNC_OUT_FLAG_00_01;



--------------------------------------------------------------------------------------------------------------


d_tready_before_fsync_cmb_sel_00_01 <= d_tready_before_fsync_sel_00_01 and d_tready_before_fsync_clr_sel_00_01;





GEN_D_TREADY_BEFORE_FSYNC_00_01 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_fsync_core = '1'and d_tready_before_fsync_clr_flag1_sel_00_01 = '1')then
                d_tready_before_fsync_sel_00_01  <= '0';
            elsif(s2mm_axis_resetn = '1')then
                d_tready_before_fsync_sel_00_01  <= '1';
            end if;
        end if;
    end process GEN_D_TREADY_BEFORE_FSYNC_00_01;




d_tready_before_fsync_clr_sel_00_01 <= '0'  when  d_tready_before_fsync_clr_flag1_sel_00_01 = '1' and  s2mm_fsync_core = '1'
            else d_tready_before_fsync_clrd_sel_00_01;



REG_INITIAL_FRM_FLAG_00_01 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_axis_resetn = '0' or s2mm_dmasr_halted_s = '1')then
                d_tready_before_fsync_clrd_sel_00_01  <= '1';
            elsif(s2mm_fsync_core = '1'and d_tready_before_fsync_clr_flag1_sel_00_01 = '1')then
                d_tready_before_fsync_clrd_sel_00_01  <= '0';
            end if;
        end if;
    end process REG_INITIAL_FRM_FLAG_00_01;


VALID_PRM_UPDT_FLAG_00_01 : process(s_axis_s2mm_aclk)
    begin
        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            if(s2mm_axis_resetn = '0' or s2mm_dmasr_halted_s = '1')then
                d_tready_before_fsync_clr_flag1_sel_00_01  <= '0';
            elsif(s2mm_prmtr_updt_complete_s = '1')then
                d_tready_before_fsync_clr_flag1_sel_00_01  <= '1';
            end if;
        end if;
    end process VALID_PRM_UPDT_FLAG_00_01;


-----------------------------------------------------------------------------------

		s2mm_fsize_less_err_internal_tvalid_gating_00_01 <= '1'  when  s2mm_fsize_less_err_flag_00_01 = '1' and  s2mm_fsync_core = '0'
		            else '0';
			
		FSIZE_LESS_ERR_FLAG_00_01 : process(s_axis_s2mm_aclk)
		    begin
		        if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
		            if(s2mm_axis_resetn = '0' or s2mm_fsync_core = '1')then
		                s2mm_fsize_less_err_flag_00_01  <= '0';
		            elsif(s2mm_fsize_mismatch_err_s = '1')then
		                s2mm_fsize_less_err_flag_00_01  <= '1';
		            end if;
		        end if;
		    end process FSIZE_LESS_ERR_FLAG_00_01;
		


--------------------------------------------------External Fsync End-------------------------------------------------------------------------------------------------------------------------
SG_INCLUDED : if C_INCLUDE_SG = 1 generate

s2mm_prmtr_or_tail_ptr_updt_complete <= s2mm_tailpntr_updated;

end generate SG_INCLUDED;

SG_NOT_INCLUDED : if C_INCLUDE_SG = 0 generate

s2mm_prmtr_or_tail_ptr_updt_complete <= s2mm_prmtr_updt_complete;

end generate SG_NOT_INCLUDED;



GEN_FOR_ASYNC_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin


----    S2MM_PRM_UPDT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axi_s2mm_aclk                               ,
----            prmry_resetn            => s2mm_prmry_resetn                             ,
----            scndry_aclk             => s_axis_s2mm_aclk                              ,
----            scndry_resetn           => s2mm_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => s2mm_prmtr_or_tail_ptr_updt_complete                         ,
----            scndry_out              => s2mm_prmtr_updt_complete_s                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


S2MM_PRM_UPDT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axi_s2mm_aclk,
        prmry_resetn               => s2mm_prmry_resetn, 
        prmry_in                   => s2mm_prmtr_or_tail_ptr_updt_complete, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_s2mm_aclk, 
        scndry_resetn              => s2mm_axis_resetn,
        scndry_out                 => s2mm_prmtr_updt_complete_s,
        scndry_vect_out            => open
    );







----    S2MM_HALTED_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axi_s2mm_aclk                               ,
----            prmry_resetn            => s2mm_prmry_resetn                             ,
----            scndry_aclk             => s_axis_s2mm_aclk                              ,
----            scndry_resetn           => s2mm_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => s2mm_dmasr(DMASR_HALTED_BIT)                         ,
----            scndry_out              => s2mm_dmasr_halted_s                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



S2MM_HALTED_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axi_s2mm_aclk,
        prmry_resetn               => s2mm_prmry_resetn, 
        prmry_in                   => s2mm_dmasr(DMASR_HALTED_BIT), 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_s2mm_aclk, 
        scndry_resetn              => s2mm_axis_resetn,
        scndry_out                 => s2mm_dmasr_halted_s,
        scndry_vect_out            => open
    );








----    SOF_LATE_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axi_s2mm_aclk                               ,
----            prmry_resetn            => s2mm_prmry_resetn                             ,
----            scndry_aclk             => s_axis_s2mm_aclk                              ,
----            scndry_resetn           => s2mm_axis_resetn                            ,
----            scndry_in               => s2mm_fsize_more_or_sof_late_s                                      ,   -- Not Used
----            prmry_out               => s2mm_fsize_more_or_sof_late                                     ,   -- Not Used
----            prmry_in                => '0'                         ,
----            scndry_out              => open                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


SOF_LATE_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_s2mm_aclk,
        prmry_resetn               => s2mm_axis_resetn, 
        prmry_in                   => s2mm_fsize_more_or_sof_late_s, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_s2mm_aclk, 
        scndry_resetn              => s2mm_prmry_resetn,
        scndry_out                 => s2mm_fsize_more_or_sof_late,
        scndry_vect_out            => open
    );



end generate GEN_FOR_ASYNC_FLUSH_SOF;



GEN_FOR_SYNC_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    s2mm_dmasr_halted_s           <= s2mm_dmasr(DMASR_HALTED_BIT);
    s2mm_prmtr_updt_complete_s    <= s2mm_prmtr_or_tail_ptr_updt_complete;
    s2mm_fsize_more_or_sof_late    <= s2mm_fsize_more_or_sof_late_s;

end generate GEN_FOR_SYNC_FLUSH_SOF;













---------------------------------------------------------------------------	
	
	end generate GEN_FLUSH_SOF_TREADY;
----------------------------------------------------------------------------------------------------------------------------------------------------------	
	
	GEN_FLUSH_NO_SOF_TREADY : if ENABLE_FLUSH_ON_S2MM_FSYNC = 1 and  S2MM_SOF_ENABLE = 0 generate
        	    begin
	
						--s_axis_s2mm_tdata_signal  <= s_axis_s2mm_tdata;
				                --s_axis_s2mm_tkeep_signal  <= s_axis_s2mm_tkeep;
				                --s_axis_s2mm_tuser_signal  <= s_axis_s2mm_tuser;
				                --s_axis_s2mm_tlast_signal  <= s_axis_s2mm_tlast;
				                --s_axis_s2mm_tvalid_signal <= s_axis_s2mm_tvalid;
				                --s_axis_s2mm_tready 	  <= s_axis_s2mm_tready_signal;



	 		s_axis_s2mm_tvalid_int			<= 	s_axis_s2mm_tvalid_signal;
			s_axis_s2mm_tready_signal              	<= 	s_axis_s2mm_tready_i_axis_dw_conv;
			s2mm_dummy_tready			<=	'0';
	end generate GEN_FLUSH_NO_SOF_TREADY;
	
	
	GEN_NO_FLUSH_TREADY : if ENABLE_FLUSH_ON_S2MM_FSYNC = 0 generate
        	    begin
	

						--s_axis_s2mm_tdata_signal  <= s_axis_s2mm_tdata;
				                --s_axis_s2mm_tkeep_signal  <= s_axis_s2mm_tkeep;
				                --s_axis_s2mm_tuser_signal  <= s_axis_s2mm_tuser;
				                --s_axis_s2mm_tlast_signal  <= s_axis_s2mm_tlast;
				                --s_axis_s2mm_tvalid_signal <= s_axis_s2mm_tvalid;
				                --s_axis_s2mm_tready 	  <= s_axis_s2mm_tready_signal;


	 		s_axis_s2mm_tvalid_int			<= 	s_axis_s2mm_tvalid_signal;
			s_axis_s2mm_tready_signal              	<= 	s_axis_s2mm_tready_i_axis_dw_conv;
			s2mm_dummy_tready			<=	'0';
	
	
	end generate GEN_NO_FLUSH_TREADY;
	





  GEN_AXIS_S2MM_DWIDTH_CONV : if C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED /=  C_S_AXIS_S2MM_TDATA_WIDTH generate
 
		constant C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED_div_by_8     	: integer := C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED/8;
		constant C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8     		: integer := C_S_AXIS_S2MM_TDATA_WIDTH/8;
		
		signal   s_axis_s2mm_dwidth_tuser_i           			:   std_logic_vector                                      --
		                                        				(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED_div_by_8-1 downto 0) := (others => '0');                  --
		
		signal   s_axis_s2mm_dwidth_tuser           			:   std_logic_vector                                      --
		                                        				(C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8-1 downto 0) := (others => '0');                  --


  begin


			S2MM_TUSER_CNCT : for i in 0 to C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8-1 generate
			begin

			                        s_axis_s2mm_dwidth_tuser(i)   <= s_axis_s2mm_tuser_signal(0);
			
			end generate S2MM_TUSER_CNCT;




		
		s_axis_s2mm_tuser_i(C_S_AXIS_S2MM_TUSER_BITS-1 downto 0)		<= s_axis_s2mm_dwidth_tuser_i(C_S_AXIS_S2MM_TUSER_BITS-1 downto 0);

    AXIS_S2MM_DWIDTH_CONVERTER_I: entity  axi_vdma_v6_2.axi_vdma_s2mm_axis_dwidth_converter
        generic map(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED 	=>	C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED		, 
 		C_S_AXIS_S2MM_TDATA_WIDTH         	 	=>	C_S_AXIS_S2MM_TDATA_WIDTH		, 
 		--C_AXIS_SIGNAL_SET            		 	=>	255		, 
 		C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8         	=>	C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8		, 
 		C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED_div_by_8   =>	C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED_div_by_8		, 
            	C_S2MM_SOF_ENABLE           			=> 	S2MM_SOF_ENABLE                  ,
            	ENABLE_FLUSH_ON_FSYNC      			=> 	ENABLE_FLUSH_ON_S2MM_FSYNC,
 		C_AXIS_TID_WIDTH             		 	=>	1		, 
 		C_AXIS_TDEST_WIDTH           		 	=>	1		, 
        	C_FAMILY                     		 	=>	C_ROOT_FAMILY		   ) 
        port map( 
      		ACLK                         =>	s_axis_s2mm_aclk                 			, 
      		ARESETN                      =>	s2mm_axis_linebuf_reset_out              			, 
      		--ARESETN                      =>	s2mm_axis_resetn              			, 
      		ACLKEN                       =>	'1'               			, 


        	s2mm_fsize_less_err_internal_tvalid_gating                   =>	s2mm_fsize_less_err_internal_tvalid_gating		,	--	: in  std_logic                         ;   
        	fsync_out                   =>	s2mm_fsync_out_i		,	--	: in  std_logic                         ;   
        	crnt_vsize_d2               =>	s2mm_crnt_vsize_d2		,	--	: in  std_logic_vector(VSIZE_DWIDTH-1 downto 0)                         ;   
      		chnl_ready_dwidth           =>	s2mm_chnl_ready			,	--	: out std_logic;
      		strm_not_finished_dwidth    =>	s2mm_strm_not_finished		,	--      : out std_logic;
      		strm_all_lines_rcvd_dwidth  =>	s2mm_strm_all_lines_rcvd	,	--      : out std_logic;
      		all_vount_rcvd_dwidth	    =>	s2mm_all_vount_rcvd	,	--      : out std_logic;



      		S_AXIS_TVALID                =>	s_axis_s2mm_tvalid_int        			, 
      		S_AXIS_TREADY                =>	s_axis_s2mm_tready_i_axis_dw_conv        			, 
      		S_AXIS_TDATA                 =>	s_axis_s2mm_tdata_signal(C_S_AXIS_S2MM_TDATA_WIDTH-1 downto 0)         			, 
      		--S_AXIS_TSTRB                 =>	ZERO_VALUE(C_S_AXIS_S2MM_TDATA_WIDTH/8-1 downto 0)         			, 
      		S_AXIS_TSTRB                 =>	s_axis_s2mm_tkeep_signal(C_S_AXIS_S2MM_TDATA_WIDTH/8-1 downto 0)         			, 
      		S_AXIS_TKEEP                 =>	s_axis_s2mm_tkeep_signal(C_S_AXIS_S2MM_TDATA_WIDTH/8-1 downto 0)         			, 
      		S_AXIS_TLAST                 =>	s_axis_s2mm_tlast_signal         			, 
      		S_AXIS_TID                   =>	ZERO_VALUE(0 downto 0)           			, 
      		S_AXIS_TDEST                 =>	ZERO_VALUE(0 downto 0)         			, 
      		S_AXIS_TUSER                 =>	s_axis_s2mm_dwidth_tuser(C_S_AXIS_S2MM_TDATA_WIDTH_div_by_8-1 downto 0)         			, 



      		M_AXIS_TVALID                =>	s_axis_s2mm_tvalid_i        			, 
      		M_AXIS_TREADY                =>	s_axis_s2mm_tready_i        			, 
      		M_AXIS_TDATA                 =>	s_axis_s2mm_tdata_i(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED-1 downto 0)         			, 
      		M_AXIS_TSTRB                 =>	open         			, 
      		M_AXIS_TKEEP                 =>	s_axis_s2mm_tkeep_i(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED/8-1 downto 0)         			, 
      		M_AXIS_TLAST                 =>	s_axis_s2mm_tlast_i         			, 
      		M_AXIS_TID                   =>	open           			, 
      		M_AXIS_TDEST                 =>	open         			, 
      		M_AXIS_TUSER                 =>	s_axis_s2mm_dwidth_tuser_i(C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED_div_by_8-1 downto 0)         			
  ) ;


  end generate GEN_AXIS_S2MM_DWIDTH_CONV;


  GEN_NO_AXIS_S2MM_DWIDTH_CONV_NO_FLUSH_SOF : if ((C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED =  C_S_AXIS_S2MM_TDATA_WIDTH) and  (ENABLE_FLUSH_ON_S2MM_FSYNC = 0 or  S2MM_SOF_ENABLE = 0) )generate
  begin


 		s_axis_s2mm_tvalid_i			<= 	s_axis_s2mm_tvalid_int;
 		s_axis_s2mm_tdata_i			<= 	s_axis_s2mm_tdata_signal;
 		s_axis_s2mm_tkeep_i			<= 	s_axis_s2mm_tkeep_signal;
 		s_axis_s2mm_tlast_i			<= 	s_axis_s2mm_tlast_signal;
 		s_axis_s2mm_tuser_i			<= 	s_axis_s2mm_tuser_signal;
 		s_axis_s2mm_tready_i_axis_dw_conv	<= 	s_axis_s2mm_tready_i;


s2mm_chnl_ready			<= '0' ;
s2mm_strm_not_finished		<= '0' ;	
s2mm_strm_all_lines_rcvd	<= '0' ;
s2mm_all_vount_rcvd		<= '0' ;



  end generate GEN_NO_AXIS_S2MM_DWIDTH_CONV_NO_FLUSH_SOF;





  GEN_NO_AXIS_S2MM_DWIDTH_CONV : if ((C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED =  C_S_AXIS_S2MM_TDATA_WIDTH) and  (ENABLE_FLUSH_ON_S2MM_FSYNC = 1 and  S2MM_SOF_ENABLE = 1) ) generate

	constant ZERO_VALUE                 		: std_logic_vector(255 downto 0)
	                                        						:= (others => '0');

	constant VSIZE_ONE_VALUE            		: std_logic_vector(VSIZE_DWIDTH-1 downto 0)
	                                        						:= std_logic_vector(to_unsigned(1,VSIZE_DWIDTH));

	constant VSIZE_ZERO_VALUE           		: std_logic_vector(VSIZE_DWIDTH-1 downto 0)
	                                        						:= (others => '0');
	
	
	signal chnl_ready_no_dwidth                  : std_logic := '0';
	signal strm_not_finished_no_dwidth           : std_logic := '0';
	signal strm_all_lines_rcvd_no_dwidth         : std_logic := '0';
	signal decr_vcount_no_dwidth                 : std_logic := '0';
	signal vsize_counter_no_dwidth               : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0'); 

 	signal all_vount_rcvd_no_dwidth              : std_logic := '0';



  begin


 		s_axis_s2mm_tvalid_i			<= 	s_axis_s2mm_tvalid_int;
 		s_axis_s2mm_tdata_i			<= 	s_axis_s2mm_tdata_signal;
 		s_axis_s2mm_tkeep_i			<= 	s_axis_s2mm_tkeep_signal;
 		s_axis_s2mm_tlast_i			<= 	s_axis_s2mm_tlast_signal;
 		s_axis_s2mm_tuser_i			<= 	s_axis_s2mm_tuser_signal;
 		s_axis_s2mm_tready_i_axis_dw_conv	<= 	s_axis_s2mm_tready_i;


    -- Decrement vertical count with each accept tlast
    decr_vcount_no_dwidth <= '1' when s_axis_s2mm_tlast_signal = '1'
                        and s_axis_s2mm_tvalid_int = '1'
                        and s_axis_s2mm_tready_i_axis_dw_conv = '1'
              else '0';

    -- Drive ready at fsync out then de-assert once all lines have
    -- been accepted.
    NO_DWIDTH_VERT_COUNTER : process(s_axis_s2mm_aclk)
        begin
            if(s_axis_s2mm_aclk'EVENT and s_axis_s2mm_aclk = '1')then
            --if(s2mm_axis_linebuf_reset_out = '0' and s2mm_fsync_out_i = '0')then
            --if((s2mm_axis_linebuf_reset_out = '0' and s2mm_fsync_out_i = '0') or s2mm_fsize_less_err_flag = '1')then
            if((s2mm_axis_linebuf_reset_out = '0' and s2mm_fsync_out_i = '0') or s2mm_fsize_less_err_internal_tvalid_gating = '1')then
                    vsize_counter_no_dwidth          	<= (others => '0');
                    chnl_ready_no_dwidth      		<= '0';
                    strm_not_finished_no_dwidth      	<= '0';
                    strm_all_lines_rcvd_no_dwidth    	<= '1';
                    all_vount_rcvd_no_dwidth    	<= '0';

                elsif(s2mm_fsync_out_i = '1')then
                    vsize_counter_no_dwidth          	<= s2mm_crnt_vsize_d2;
                    chnl_ready_no_dwidth     		<= '1';
                    strm_not_finished_no_dwidth     	<= '1';
                    strm_all_lines_rcvd_no_dwidth    	<= '0';
                    all_vount_rcvd_no_dwidth    	<= '0';

                elsif(decr_vcount_no_dwidth = '1' and vsize_counter_no_dwidth = VSIZE_ONE_VALUE)then
                    vsize_counter_no_dwidth          	<= (others => '0');
                    chnl_ready_no_dwidth      		<= '0';
                    strm_not_finished_no_dwidth      	<= '0';
                    strm_all_lines_rcvd_no_dwidth    	<= '1';
                    all_vount_rcvd_no_dwidth    	<= '1';

                elsif(decr_vcount_no_dwidth = '1' and vsize_counter_no_dwidth /= VSIZE_ZERO_VALUE)then
                    vsize_counter_no_dwidth          	<= std_logic_vector(unsigned(vsize_counter_no_dwidth) - 1);
                    chnl_ready_no_dwidth      		<= '1';
                    strm_not_finished_no_dwidth      	<= '1';
                    strm_all_lines_rcvd_no_dwidth    	<= '0';
                    all_vount_rcvd_no_dwidth    	<= '0';

            	else
                    all_vount_rcvd_no_dwidth    	<= '0';


                end if;
            end if;
        end process NO_DWIDTH_VERT_COUNTER;



s2mm_chnl_ready			<= chnl_ready_no_dwidth;
s2mm_strm_not_finished		<= strm_not_finished_no_dwidth;	
s2mm_strm_all_lines_rcvd	<= strm_all_lines_rcvd_no_dwidth;

s2mm_all_vount_rcvd		<= all_vount_rcvd_no_dwidth;


  end generate GEN_NO_AXIS_S2MM_DWIDTH_CONV;





    ---------------------------------------------------------------------------
    -- S2MM Register Module
    ---------------------------------------------------------------------------
    S2MM_REGISTER_MODULE_I : entity  axi_vdma_v6_2.axi_vdma_reg_module
        generic map(
            C_TOTAL_NUM_REGISTER    => TOTAL_NUM_REGISTER                   ,
            C_INCLUDE_SG            => C_INCLUDE_SG                         ,
            C_CHANNEL_IS_MM2S       => CHANNEL_IS_S2MM                      ,
            C_ENABLE_FLUSH_ON_FSYNC => ENABLE_FLUSH_ON_S2MM_FSYNC                , -- CR591965
            C_ENABLE_VIDPRMTR_READS => C_ENABLE_VIDPRMTR_READS              ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE          ,
            C_DYNAMIC_RESOLUTION    => C_DYNAMIC_RESOLUTION                ,
            C_NUM_FSTORES           => C_NUM_FSTORES                        ,
            --C_ENABLE_DEBUG_INFO     => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0   => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1   => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2   => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3   => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4   => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5   => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6   => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7   => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8   => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9   => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10  => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11  => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12  => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13  => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14  => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15  => C_ENABLE_DEBUG_INFO_15             ,
            C_LINEBUFFER_THRESH     => C_S2MM_LINEBUFFER_THRESH_INT             ,
            C_GENLOCK_MODE          => C_S2MM_GENLOCK_MODE                  ,
            C_S_AXI_LITE_ADDR_WIDTH => C_S_AXI_LITE_ADDR_WIDTH              ,
            C_S_AXI_LITE_DATA_WIDTH => C_S_AXI_LITE_DATA_WIDTH              ,
            C_M_AXI_SG_ADDR_WIDTH   => C_M_AXI_SG_ADDR_WIDTH                ,
            C_M_AXI_ADDR_WIDTH      => C_M_AXI_S2MM_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => m_axi_s2mm_aclk                  ,
            prmry_resetn                => s2mm_prmry_resetn                ,

            -- Register to AXI Lite Interface
            axi2ip_wrce                 => s2mm_axi2ip_wrce                 ,
            axi2ip_wrdata               => s2mm_axi2ip_wrdata               ,
            axi2ip_rdaddr               => s2mm_axi2ip_rdaddr               ,
            --axi2ip_rden                 => s2mm_axi2ip_rden                 ,
            axi2ip_rden                 => '0'                 ,
            ip2axi_rddata               => s2mm_ip2axi_rddata               ,
            --ip2axi_rddata_valid         => s2mm_ip2axi_rddata_valid         ,
            ip2axi_rddata_valid         => open         ,
            ip2axi_frame_ptr_ref        => s2mm_ip2axi_frame_ptr_ref        ,
            ip2axi_frame_store          => s2mm_ip2axi_frame_store          ,
            ip2axi_introut              => s2mm_ip2axi_introut              ,

            -- Soft Reset
            soft_reset                  => s2mm_soft_reset                  ,
            soft_reset_clr              => s2mm_soft_reset_clr              ,

            -- DMA Control / Status Register Signals
            halted_clr                  => s2mm_halted_clr                  ,
            halted_set                  => s2mm_halted_set                  ,
            idle_set                    => s2mm_idle_set                    ,
            idle_clr                    => s2mm_idle_clr                    ,
            ioc_irq_set                 => s2mm_ioc_irq_set                 ,
            dly_irq_set                 => s2mm_dly_irq_set                 ,
            irqdelay_status             => s2mm_irqdelay_status             ,
            irqthresh_status            => s2mm_irqthresh_status            ,
            frame_sync                  => s2mm_frame_sync                  ,
            fsync_mask                  => s2mm_mask_fsync_out              ,
            new_curdesc_wren            => s2mm_new_curdesc_wren            ,
            new_curdesc                 => s2mm_new_curdesc                 ,
            update_frmstore             => s2mm_update_frmstore             ,
            new_frmstr                  => s2mm_frame_number                ,
            tstvect_fsync               => s2mm_tstvect_fsync               ,
            valid_frame_sync            => s2mm_valid_frame_sync            ,
            irqthresh_rstdsbl           => s2mm_irqthresh_rstdsbl           ,
            dlyirq_dsble                => s2mm_dlyirq_dsble                ,
            irqthresh_wren              => s2mm_irqthresh_wren              ,
            irqdelay_wren               => s2mm_irqdelay_wren               ,
            tailpntr_updated            => s2mm_tailpntr_updated            ,

            -- Error Detection Control
            stop                        => s2mm_stop                        ,
            dma_interr_set              => s2mm_dma_interr_set              ,
            dma_interr_set_minus_frame_errors              => s2mm_dma_interr_set_minus_frame_errors              ,
            dma_slverr_set              => s2mm_dma_slverr_set              ,
            dma_decerr_set              => s2mm_dma_decerr_set              ,
            ftch_slverr_set             => s2mm_ftch_slverr_set             ,
            ftch_decerr_set             => s2mm_ftch_decerr_set             ,

            fsize_mismatch_err          => s2mm_fsize_mismatch_err          ,   
            lsize_mismatch_err          => s2mm_lsize_mismatch_err          ,   
            lsize_more_mismatch_err          => s2mm_lsize_more_mismatch_err          ,   
            s2mm_fsize_more_or_sof_late => s2mm_fsize_more_or_sof_late          ,   

            -- VDMA Base Registers
    	reg_index                	=> s2mm_reg_index           ,
            dmacr                       => s2mm_dmacr                       ,
            dmasr                       => s2mm_dmasr                       ,
            curdesc                     => s2mm_curdesc                     ,
            taildesc                    => s2mm_taildesc                    ,
            num_frame_store             => s2mm_num_frame_store             ,
            linebuf_threshold           => s2mm_linebuf_threshold           ,

            -- Register Direct Support
            regdir_idle                 => s2mm_regdir_idle                 ,
            prmtr_updt_complete         => s2mm_prmtr_updt_complete         ,
            reg_module_vsize            => s2mm_reg_module_vsize            ,
            reg_module_hsize            => s2mm_reg_module_hsize            ,
            reg_module_stride           => s2mm_reg_module_stride           ,
            reg_module_frmdly           => s2mm_reg_module_frmdly           ,
            reg_module_strt_addr        => s2mm_reg_module_strt_addr        ,

            -- Fetch/Update error addresses
            frmstr_err_addr           => s2mm_frmstr_err_addr           ,
            ftch_err_addr             => s2mm_ftch_err_addr
        );

    ---------------------------------------------------------------------------
    -- S2MM DMA Controller
    ---------------------------------------------------------------------------
    I_S2MM_DMA_MNGR : entity  axi_vdma_v6_2.axi_vdma_mngr
        generic map(
            C_PRMY_CMDFIFO_DEPTH        => DM_CMDSTS_FIFO_DEPTH             ,
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_INCLUDE_SF                => DM_S2MM_INCLUDE_SF               ,
            C_USE_FSYNC                 => C_USE_S2MM_FSYNC_01                      ,   -- CR582182
            C_ENABLE_FLUSH_ON_FSYNC     => ENABLE_FLUSH_ON_S2MM_FSYNC            ,   -- CR591965
            C_NUM_FSTORES               => C_NUM_FSTORES                    ,
            C_GENLOCK_MODE              => C_S2MM_GENLOCK_MODE              ,
            C_GENLOCK_NUM_MASTERS       => C_S2MM_GENLOCK_NUM_MASTERS       ,
            C_DYNAMIC_RESOLUTION        => C_DYNAMIC_RESOLUTION                ,
            --C_GENLOCK_REPEAT_EN         => C_S2MM_GENLOCK_REPEAT_EN         ,   -- CR591965
            --C_ENABLE_DEBUG_INFO         => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0       => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1       => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2       => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3       => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4       => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5       => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6       => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7       => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8       => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9       => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10      => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11      => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12      => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13      => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14      => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15      => C_ENABLE_DEBUG_INFO_15             ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE          ,
            C_INCLUDE_SG                => C_INCLUDE_SG                     ,   -- CR581800
            C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH            ,
            C_M_AXIS_SG_TDATA_WIDTH     => M_AXIS_SG_TDATA_WIDTH            ,
            C_M_AXI_ADDR_WIDTH          => C_M_AXI_S2MM_ADDR_WIDTH          ,
            C_DM_STATUS_WIDTH           => S2MM_DM_STATUS_WIDTH             ,   -- CR608521
            C_EXTEND_DM_COMMAND         => S2MM_DM_CMD_EXTENDED             ,
            C_S2MM_SOF_ENABLE           => S2MM_SOF_ENABLE,
            C_MM2S_SOF_ENABLE           => 0                   ,
            C_INCLUDE_MM2S              => 0                   ,
            C_INCLUDE_S2MM              => C_INCLUDE_S2MM                   ,
            C_FAMILY                    => C_ROOT_FAMILY
        )
        port map(
            -- Secondary Clock and Reset
            prmry_aclk                  => m_axi_s2mm_aclk                  ,
            prmry_resetn                => s2mm_prmry_resetn                ,
            soft_reset                  => s2mm_soft_reset                  ,

            scndry_aclk                 => s_axis_s2mm_aclk                 ,
            scndry_resetn               => s2mm_axis_resetn                 ,

            -- MM2S Control and Status
            run_stop                    => s2mm_dmacr(DMACR_RS_BIT)         ,
            dmacr_repeat_en             => s2mm_dmacr(DMACR_REPEAT_EN_BIT)     ,
            dmasr_halt                  => s2mm_dmasr(DMASR_HALTED_BIT)     ,
            sync_enable                 => s2mm_dmacr(DMACR_SYNCEN_BIT)     ,
            regdir_idle                 => s2mm_regdir_idle                 ,
            ftch_idle                   => s2mm_ftch_idle                   ,
            halt                        => s2mm_halt                        ,
            halt_cmplt                  => s2mm_halt_cmplt                  ,
            halted_clr                  => s2mm_halted_clr                  ,
            halted_set                  => s2mm_halted_set                  ,
            idle_set                    => s2mm_idle_set                    ,
            idle_clr                    => s2mm_idle_clr                    ,
            stop                        => s2mm_stop                        ,
            s2mm_fsize_more_or_sof_late => s2mm_fsize_more_or_sof_late          ,   
            s2mm_dmasr_lsize_less_err   => s2mm_dmasr(DMASR_LSIZEERR_BIT)     ,
            all_idle                    => s2mm_all_idle                    ,
            cmdsts_idle                 => s2mm_cmdsts_idle                 ,
            ftchcmdsts_idle             => s2mm_ftchcmdsts_idle             ,
            s2mm_fsync_out_m            => s2mm_fsync_out_m_i                  ,
            mm2s_fsync_out_m            => '0'                 ,   -- CR616211
            frame_sync                  => s2mm_frame_sync                  ,
            update_frmstore             => s2mm_update_frmstore             ,   -- CR582182
            frmstr_err_addr           => s2mm_frmstr_err_addr           ,   -- CR582182
            frame_ptr_ref               => s2mm_ip2axi_frame_ptr_ref        ,
            frame_ptr_in                => s2mm_s_frame_ptr_in              ,
            frame_ptr_out               => s2mm_m_frame_ptr_out             ,
            internal_frame_ptr_in       => mm2s_to_s2mm_frame_ptr_in        ,
            valid_frame_sync            => s2mm_valid_frame_sync            ,
            valid_frame_sync_cmb        => s2mm_valid_frame_sync_cmb        ,
            valid_video_prmtrs          => s2mm_valid_video_prmtrs          ,
            parameter_update            => s2mm_parameter_update            ,
            circular_prk_mode           => s2mm_dmacr(DMACR_CRCLPRK_BIT)    ,
            mstr_pntr_ref               => s2mm_dmacr(DMACR_PNTR_NUM_MSB
                                               downto DMACR_PNTR_NUM_LSB)   ,
            genlock_select              => s2mm_dmacr(DMACR_GENLOCK_SEL_BIT),
            line_buffer_empty           => '1'                              ,   -- NOT Used by S2MM therefore tie off
            dwidth_fifo_pipe_empty           => '1'                              ,   -- NOT Used by S2MM therefore tie off
            crnt_vsize                  => s2mm_crnt_vsize                  ,   -- CR575884
            num_frame_store             => s2mm_num_frame_store             ,
            all_lines_xfred             => s2mm_all_lines_xfred             ,   -- CR591965
            all_lasts_rcvd              => all_lasts_rcvd             ,   
            mm2s_fsize_mismatch_err_m   => '0'                             ,   -- Not Needed for MM2S channel
            mm2s_fsize_mismatch_err_s   => '0'                             ,   -- Not Needed for MM2S channel
            s2mm_fsize_mismatch_err_s   => s2mm_fsize_mismatch_err_s                             ,   -- Not Needed for MM2S channel
drop_fsync_d_pulse_gen_fsize_less_err   => drop_fsync_d_pulse_gen_fsize_less_err                      ,
      	    s2mm_strm_all_lines_rcvd    => s2mm_strm_all_lines_rcvd	,	--      : out std_logic;
            s2mm_fsync_core             => s2mm_fsync_core                      ,
            fsize_mismatch_err_flag          => s2mm_fsize_mismatch_err_flag          ,   -- CR591965
            fsize_mismatch_err          => s2mm_fsize_mismatch_err          ,   -- CR591965
            lsize_mismatch_err          => s2mm_lsize_mismatch_err          ,   -- CR591965
            lsize_more_mismatch_err     => s2mm_lsize_more_mismatch_err          ,   -- CR591965
            capture_hsize_at_uf_err     => s2mm_capture_hsize_at_uf_err_sig          ,   

            -- Register Direct Support
            prmtr_updt_complete         => s2mm_prmtr_updt_complete         ,
            reg_module_vsize            => s2mm_reg_module_vsize            ,
            reg_module_hsize            => s2mm_reg_module_hsize            ,
            reg_module_stride           => s2mm_reg_module_stride           ,
            reg_module_frmdly           => s2mm_reg_module_frmdly           ,
            reg_module_strt_addr        => s2mm_reg_module_strt_addr        ,

            -- Test vector signals
            tstvect_err               => s2mm_tstvect_err               ,
            tstvect_fsync               => s2mm_tstvect_fsync               ,
            tstvect_frame               => s2mm_tstvect_frame               ,
            tstvect_frm_ptr_out         => s2mm_tstvect_frm_ptr_out         ,
            mstrfrm_tstsync_out         => s2mm_mstrfrm_tstsync             ,

            -- AXI Stream Timing
            packet_sof                  => s2mm_packet_sof                  ,


            -- Primary DMA Errors
            dma_interr_set              => s2mm_dma_interr_set              ,
            dma_interr_set_minus_frame_errors              => s2mm_dma_interr_set_minus_frame_errors              ,
            dma_slverr_set              => s2mm_dma_slverr_set              ,
            dma_decerr_set              => s2mm_dma_decerr_set              ,

            -- SG MM2S Descriptor Fetch AXI Stream In
            m_axis_ftch_tdata           => m_axis_s2mm_ftch_tdata           ,
            m_axis_ftch_tvalid          => m_axis_s2mm_ftch_tvalid          ,
            m_axis_ftch_tready          => m_axis_s2mm_ftch_tready          ,
            m_axis_ftch_tlast           => m_axis_s2mm_ftch_tlast           ,

            -- Currently Being Processed Descriptor/Frame
            frame_number                => s2mm_frame_number                ,
            chnl_current_frame          => s2mm_chnl_current_frame                ,
            genlock_pair_frame          => s2mm_genlock_pair_frame                ,
            new_curdesc                 => s2mm_new_curdesc                 ,
            new_curdesc_wren            => s2mm_new_curdesc_wren            ,
            tailpntr_updated            => s2mm_tailpntr_updated            ,

            -- User Command Interface Ports (AXI Stream)
            s_axis_cmd_tvalid           => s_axis_s2mm_cmd_tvalid           ,
            s_axis_cmd_tready           => s_axis_s2mm_cmd_tready           ,
            s_axis_cmd_tdata            => s_axis_s2mm_cmd_tdata            ,

            -- User Status Interface Ports (AXI Stream)
            m_axis_sts_tvalid           => m_axis_s2mm_sts_tvalid           ,
            m_axis_sts_tready           => m_axis_s2mm_sts_tready           ,
            m_axis_sts_tdata            => m_axis_s2mm_sts_tdata            ,
            m_axis_sts_tkeep            => m_axis_s2mm_sts_tkeep       ,
            err                         => s2mm_err                         ,
            ftch_err                  => s2mm_ftch_err
        );



    ---------------------------------------------------------------------------
    -- MM2S Frame sync generator
    ---------------------------------------------------------------------------
    S2MM_FSYNC_I : entity  axi_vdma_v6_2.axi_vdma_fsync_gen
        generic map(
            C_USE_FSYNC                 => C_USE_S2MM_FSYNC_01                      ,
            ENABLE_FLUSH_ON_S2MM_FSYNC  => ENABLE_FLUSH_ON_S2MM_FSYNC                      ,
            ENABLE_FLUSH_ON_MM2S_FSYNC  => 0                      ,
            C_INCLUDE_S2MM              => 1                   ,
            C_INCLUDE_MM2S              => 0                       ,
            C_SOF_ENABLE                => S2MM_SOF_ENABLE
        )
        port map(
            prmry_aclk                  => m_axi_s2mm_aclk                  ,
            prmry_resetn                => s2mm_prmry_resetn                ,

            -- Frame Count Enable Support
            valid_frame_sync_cmb        => s2mm_valid_frame_sync_cmb        ,
            valid_video_prmtrs          => s2mm_valid_video_prmtrs          ,
            frmcnt_ioc                  => s2mm_ioc_irq_set                 ,
            dmacr_frmcnt_enbl           => s2mm_dmacr(DMACR_FRMCNTEN_BIT)   ,
            dmasr_frmcnt_status         => s2mm_irqthresh_status            ,
            mask_fsync_out              => s2mm_mask_fsync_out              ,

            -- VDMA process status
            run_stop                    => s2mm_dmacr(DMACR_RS_BIT)         ,
            all_idle                    => s2mm_all_idle                    ,
            parameter_update            => s2mm_parameter_update            ,

            -- VDMA Frame Sync sources
            fsync                       => s2mm_cdc2dmac_fsync              ,
            tuser_fsync                 => s2mm_tuser_fsync                 ,
            othrchnl_fsync              => mm2s_to_s2mm_fsync               ,

            fsync_src_select            => s2mm_dmacr(DMACR_FSYNCSEL_MSB
                                            downto DMACR_FSYNCSEL_LSB)      ,

            -- VDMA frame sync output to core
            frame_sync                  => s2mm_frame_sync                  ,

            -- VDMA Frame Sync Output to ports
            frame_sync_out              => s2mm_dmac2cdc_fsync_out          ,
            prmtr_update                => s2mm_dmac2cdc_prmtr_update
        );

    -- Clock Domain Crossing between m_axi_s2mm_aclk and s_axis_s2mm_aclk
    S2MM_VID_CDC_I : entity axi_vdma_v6_2.axi_vdma_vid_cdc
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC            ,
            C_GENLOCK_MSTR_PTR_DWIDTH   => NUM_FRM_STORE_WIDTH          ,
            C_GENLOCK_SLVE_PTR_DWIDTH   => S2MM_GENLOCK_SLVE_PTR_DWIDTH     ,
            C_INTERNAL_GENLOCK_ENABLE   => INTERNAL_GENLOCK_ENABLE
        )
        port map(
            prmry_aclk                  => m_axi_s2mm_aclk                  ,
            prmry_resetn                => s2mm_prmry_resetn                ,

            scndry_aclk                 => s_axis_s2mm_aclk                 ,
            scndry_resetn               => s2mm_axis_resetn                 ,

            -- Genlock internal bus cdc
            othrchnl_aclk               => m_axi_mm2s_aclk                  ,
            othrchnl_resetn             => mm2s_prmry_resetn                ,
            othrchnl2cdc_frame_ptr_out  => mm2s_frame_ptr_out_i             ,
            cdc2othrchnl_frame_ptr_in   => mm2s_to_s2mm_frame_ptr_in        ,
            cdc2othrchnl_fsync          => s2mm_to_mm2s_fsync               ,

            -- GenLock Clock Domain Crossing
            dmac2cdc_frame_ptr_out      => s2mm_m_frame_ptr_out             ,
            cdc2top_frame_ptr_out       => s2mm_frame_ptr_out_i             ,
            top2cdc_frame_ptr_in        => s2mm_frame_ptr_in                ,
            cdc2dmac_frame_ptr_in       => s2mm_s_frame_ptr_in              ,
            dmac2cdc_mstrfrm_tstsync    => s2mm_mstrfrm_tstsync             ,
            cdc2dmac_mstrfrm_tstsync    => s2mm_mstrfrm_tstsync_out         ,

            -- SOF Detection Domain Crossing
            vid2cdc_packet_sof          => s2mm_vid2cdc_packet_sof          ,
            cdc2dmac_packet_sof         => s2mm_packet_sof                  ,

            -- Frame Sync Generation Domain Crossing
            vid2cdc_fsync               => s2mm_fsync_core                       ,
            cdc2dmac_fsync              => s2mm_cdc2dmac_fsync              ,

            dmac2cdc_fsync_out          => s2mm_dmac2cdc_fsync_out          ,
            dmac2cdc_prmtr_update       => s2mm_dmac2cdc_prmtr_update       ,

            cdc2vid_fsync_out           => s2mm_fsync_out_i                 ,
            cdc2vid_prmtr_update        => s2mm_prmtr_update_i
        );

    s2mm_fsync_out_sig  <= s2mm_fsync_out_i;

    -- Start of Frame Detection - used for interrupt coalescing
    S2MM_SOF_I : entity  axi_vdma_v6_2.axi_vdma_sof_gen
        port map(
            scndry_aclk                 => s_axis_s2mm_aclk                 ,
            scndry_resetn               => s2mm_axis_resetn                 ,

            axis_tready                 => s_axis_s2mm_tready_i             ,
            axis_tvalid                 => s_axis_s2mm_tvalid_i               ,

            fsync                       => s2mm_fsync_out_i                 , -- CR622884

            packet_sof                  => s2mm_vid2cdc_packet_sof
        );

    -------------------------------------------------------------------------------
    -- Primary S2MM Line Buffer
    -------------------------------------------------------------------------------
    S2MM_LINEBUFFER_I : entity  axi_vdma_v6_2.axi_vdma_s2mm_linebuf
        generic map(
            C_DATA_WIDTH                => C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED            ,
            C_S2MM_SOF_ENABLE           => S2MM_SOF_ENABLE                      ,
            C_USE_FSYNC                 => C_USE_S2MM_FSYNC_01                      ,   
            C_USE_S2MM_FSYNC            => C_USE_S2MM_FSYNC                      ,   
            C_S_AXIS_S2MM_TUSER_BITS    => C_S_AXIS_S2MM_TUSER_BITS             ,
            C_INCLUDE_S2MM_DRE          => C_S2MM_ENABLE_TKEEP                   ,
            C_TOPLVL_LINEBUFFER_DEPTH   => C_S2MM_LINEBUFFER_DEPTH              , -- CR625142
            --C_ENABLE_DEBUG_INFO         => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
            C_ENABLE_DEBUG_INFO_0       => C_ENABLE_DEBUG_INFO_0             ,
            C_ENABLE_DEBUG_INFO_1       => C_ENABLE_DEBUG_INFO_1             ,
            C_ENABLE_DEBUG_INFO_2       => C_ENABLE_DEBUG_INFO_2             ,
            C_ENABLE_DEBUG_INFO_3       => C_ENABLE_DEBUG_INFO_3             ,
            C_ENABLE_DEBUG_INFO_4       => C_ENABLE_DEBUG_INFO_4             ,
            C_ENABLE_DEBUG_INFO_5       => C_ENABLE_DEBUG_INFO_5             ,
            C_ENABLE_DEBUG_INFO_6       => C_ENABLE_DEBUG_INFO_6             ,
            C_ENABLE_DEBUG_INFO_7       => C_ENABLE_DEBUG_INFO_7             ,
            C_ENABLE_DEBUG_INFO_8       => C_ENABLE_DEBUG_INFO_8             ,
            C_ENABLE_DEBUG_INFO_9       => C_ENABLE_DEBUG_INFO_9             ,
            C_ENABLE_DEBUG_INFO_10      => C_ENABLE_DEBUG_INFO_10             ,
            C_ENABLE_DEBUG_INFO_11      => C_ENABLE_DEBUG_INFO_11             ,
            C_ENABLE_DEBUG_INFO_12      => C_ENABLE_DEBUG_INFO_12             ,
            C_ENABLE_DEBUG_INFO_13      => C_ENABLE_DEBUG_INFO_13             ,
            C_ENABLE_DEBUG_INFO_14      => C_ENABLE_DEBUG_INFO_14             ,
            C_ENABLE_DEBUG_INFO_15      => C_ENABLE_DEBUG_INFO_15             ,
            C_LINEBUFFER_DEPTH          => S2MM_LINEBUFFER_DEPTH                ,
            C_LINEBUFFER_AF_THRESH      => C_S2MM_LINEBUFFER_THRESH_INT             ,
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC                ,
            ENABLE_FLUSH_ON_FSYNC       => ENABLE_FLUSH_ON_S2MM_FSYNC,
            C_INCLUDE_MM2S              => C_INCLUDE_MM2S                       ,
            C_FAMILY                    => C_ROOT_FAMILY
        )
        port map(
            -----------------------------------------------------------------------
            -- AXI Scatter Gather Interface
            -----------------------------------------------------------------------
            s_axis_aclk                 => s_axis_s2mm_aclk                     ,
            s_axis_resetn               => s2mm_axis_resetn                     ,
            m_axis_aclk                 => m_axi_s2mm_aclk                      ,
            m_axis_resetn               => s2mm_prmry_resetn                    ,
            s2mm_axis_linebuf_reset_out               => s2mm_axis_linebuf_reset_out                    ,

            -- Graceful shut down control
            run_stop                    => s2mm_dmacr(DMACR_RS_BIT)             ,
            dm_halt                     => s2mm_halt                            , -- CR591965
            dm_halt_cmplt               => s2mm_halt_cmplt                            , -- CR591965

            capture_dm_done_vsize_counter => s2mm_capture_dm_done_vsize_counter_sig                            , 
            s2mm_fsize_mismatch_err_flag => s2mm_fsize_mismatch_err_flag                            , 
            s2mm_fsize_mismatch_err_s   => s2mm_fsize_mismatch_err_s                            , 
            s2mm_fsize_mismatch_err   => s2mm_fsize_mismatch_err                            , 

drop_fsync_d_pulse_gen_fsize_less_err   => drop_fsync_d_pulse_gen_fsize_less_err                      ,
no_fsync_before_vsize_sel_00_01         => no_fsync_before_vsize_sel_00_01                      ,

            hold_dummy_tready_low       => hold_dummy_tready_low                      ,
            hold_dummy_tready_low2      => hold_dummy_tready_low2                      ,
            mm2s_fsync                  => mm2s_fsync_fe                      ,
            m_axis_mm2s_aclk            => m_axis_mm2s_aclk                      ,
            mm2s_axis_resetn            => mm2s_axis_resetn                      ,

            s2mm_fsync_core             => s2mm_fsync_core                      ,
            s2mm_fsync                  => s2mm_fsync_fe                      ,
            s2mm_tuser_fsync_top        => s2mm_tuser_fsync_top                      ,
            s2mm_dmasr_fsize_less_err   => s2mm_dmasr(DMASR_FSIZEERR_BIT)     ,

            fsync_src_select            => s2mm_dmacr(DMACR_FSYNCSEL_MSB
                                            downto DMACR_FSYNCSEL_LSB)      ,
            fsync_src_select_s          => s2mm_fsync_src_select_s                      ,

            chnl_ready_external         => s2mm_chnl_ready                      ,
            strm_not_finished           => s2mm_strm_not_finished                      ,
            crnt_vsize_d2_s               => s2mm_crnt_vsize_d2                      ,

            -- Line Tracking Control
            crnt_vsize                  => s2mm_crnt_vsize                      ,
            fsync_out_m                   => s2mm_fsync_out_m_i                     ,
            fsync_out                   => s2mm_fsync_out_i                     ,
            frame_sync                  => s2mm_frame_sync                      ,

            -- Threshold
            linebuf_threshold           => s2mm_linebuf_threshold               ,

            -- Stream In
            s_axis_tdata                => s_axis_s2mm_tdata_i                    ,
            s_axis_tkeep                => s_axis_s2mm_tkeep_i                    ,
            s_axis_tlast                => s_axis_s2mm_tlast_i                    ,
            s_axis_tvalid               => s_axis_s2mm_tvalid_i                   ,
            s_axis_tready               => s_axis_s2mm_tready_i                 ,
            s_axis_tuser                => s_axis_s2mm_tuser_i                    ,

            -- Stream Out
            m_axis_tdata                => linebuf2dm_s2mm_tdata                ,
            m_axis_tkeep                => linebuf2dm_s2mm_tkeep                ,
            m_axis_tlast                => linebuf2dm_s2mm_tlast                ,
            m_axis_tvalid               => linebuf2dm_s2mm_tvalid               ,
            m_axis_tready               => dm2linebuf_s2mm_tready               ,

            -- Fifo Status Flags
            s2mm_fifo_full              => s2mm_buffer_full_i                     ,
            s2mm_fifo_almost_full       => s2mm_buffer_almost_full_i              ,
            s2mm_all_lines_xfred        => s2mm_all_lines_xfred                 ,   -- CR591965
            all_lasts_rcvd              => all_lasts_rcvd                       ,
            s2mm_tuser_fsync            => s2mm_tuser_fsync
        );

end generate GEN_SPRT_FOR_S2MM;

-- Do not generate support logic for S2MM
GEN_NO_SPRT_FOR_S2MM : if C_INCLUDE_S2MM = 0 generate
begin

    -- Register Module Tie-Offs
    s2mm_ip2axi_rddata               <= (others => '0');
    --s2mm_ip2axi_rddata_valid         <= '0';
    s2mm_ip2axi_frame_ptr_ref        <= (others => '0');
    s2mm_ip2axi_frame_store          <= (others => '0');
    s2mm_ip2axi_introut              <= '0';
    s2mm_soft_reset                  <= '0';
    s2mm_irqthresh_rstdsbl           <= '0';
    s2mm_dlyirq_dsble                <= '0';
    s2mm_irqthresh_wren              <= '0';
    s2mm_irqdelay_wren               <= '0';
    s2mm_tailpntr_updated            <= '0';
    s2mm_dmacr                       <= (others => '0');
    s2mm_dmasr                       <= (others => '0');
    s2mm_curdesc                     <= (others => '0');
    s2mm_taildesc                    <= (others => '0');
    s2mm_num_frame_store             <= (others => '0');
    s2mm_linebuf_threshold           <= (others => '0');
    s2mm_regdir_idle                 <= '0';
    s2mm_prmtr_updt_complete         <= '0';
    s2mm_reg_module_vsize            <= (others => '0');
    s2mm_reg_module_hsize            <= (others => '0');
    s2mm_reg_module_stride           <= (others => '0');
    s2mm_reg_module_frmdly           <= (others => '0');

    s2mm_dummy_tready		     <=	'0';

    -- Must zero each element of an array of vectors to zero
    -- all vectors.
    GEN_S2MM_ZERO_STRT : for i in 0 to C_NUM_FSTORES-1 generate
        begin
            s2mm_reg_module_strt_addr(i)   <= (others => '0');
    end generate GEN_S2MM_ZERO_STRT;

    -- Line buffer Tie-Offs
    s_axis_s2mm_tready_i_axis_dw_conv            <= '0';
    s_axis_s2mm_tready_i            <= '0';
    s_axis_s2mm_tready            <= '0';
    s2mm_capture_dm_done_vsize_counter_sig           <= (others => '0');
    s2mm_capture_hsize_at_uf_err_sig           <= (others => '0');
    linebuf2dm_s2mm_tdata           <= (others => '0');
    linebuf2dm_s2mm_tkeep           <= (others => '0');
    linebuf2dm_s2mm_tlast           <= '0';
    linebuf2dm_s2mm_tvalid          <= '0';
    s2mm_buffer_full_i              <= '0';
    s2mm_buffer_almost_full_i       <= '0';
    s2mm_all_lines_xfred            <= '0'; -- CR591965
    s2mm_tuser_fsync                <= '0';

    -- Frame sync generator
    s2mm_frame_sync                 <= '0';
    -- SOF/EOF generator
    s2mm_packet_sof                 <= '0';
    -- DMA Controller
    s2mm_halted_clr                 <= '0';
    s2mm_halted_set                 <= '1';
    s2mm_idle_set                   <= '0';
    s2mm_idle_clr                   <= '0';
    s2mm_frame_number               <= (others => '0');
    s2mm_chnl_current_frame         <= (others => '0');
    s2mm_genlock_pair_frame         <= (others => '0');
    s2mm_new_curdesc_wren           <= '0';
    s2mm_new_curdesc                <= (others => '0');
    s2mm_stop                       <= '0';
    s2mm_all_idle                   <= '1';
    s2mm_cmdsts_idle                <= '1';
    s2mm_ftchcmdsts_idle            <= '1';
    m_axis_s2mm_ftch_tready         <= '0';
    s_axis_s2mm_cmd_tvalid          <= '0';
    s_axis_s2mm_cmd_tdata           <= (others => '0');
    m_axis_s2mm_sts_tready          <= '0';
    s2mm_frame_ptr_out_i            <= (others => '0');
    s2mm_m_frame_ptr_out            <= (others => '0');
    mm2s_to_s2mm_frame_ptr_in       <= (others => '0');
    s2mm_valid_frame_sync           <= '0';
    s2mm_valid_frame_sync_cmb       <= '0';
    s2mm_valid_video_prmtrs         <= '0';
    s2mm_parameter_update           <= '0';
    s2mm_tstvect_err              <= '0';
    s2mm_tstvect_fsync              <= '0';
    s2mm_tstvect_frame              <= (others => '0');
    s2mm_dma_interr_set             <= '0';
    s2mm_dma_interr_set_minus_frame_errors             <= '0';
    s2mm_dma_slverr_set             <= '0';
    s2mm_dma_decerr_set             <= '0';
    s2mm_fsize_mismatch_err         <= '0';
    s2mm_lsize_mismatch_err         <= '0';
    s2mm_lsize_more_mismatch_err         <= '0';

    -- Frame Sync generator
    s2mm_fsync_out_sig                  <= '0';
    s2mm_prmtr_update_i               <= '0';
    s2mm_crnt_vsize                 <= (others => '0'); -- CR575884
    s2mm_mask_fsync_out             <= '0';
    s2mm_mstrfrm_tstsync            <= '0';
    s2mm_mstrfrm_tstsync_out        <= '0';
    s2mm_tstvect_frm_ptr_out        <= (others => '0');
    s2mm_frmstr_err_addr          <= (others => '0');
    s2mm_to_mm2s_fsync              <= '0';

end generate GEN_NO_SPRT_FOR_S2MM;


-------------------------------------------------------------------------------
-- Primary MM2S and S2MM DataMover
-------------------------------------------------------------------------------
I_PRMRY_DATAMOVER : entity axi_datamover_v5_1.axi_datamover
    generic map(
        C_INCLUDE_MM2S              => MM2S_AXI_FULL_MODE                   ,
        C_M_AXI_MM2S_ADDR_WIDTH     => C_M_AXI_MM2S_ADDR_WIDTH              ,
        C_M_AXI_MM2S_DATA_WIDTH     => C_M_AXI_MM2S_DATA_WIDTH              ,
        C_M_AXIS_MM2S_TDATA_WIDTH   => C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED            ,
        C_INCLUDE_MM2S_STSFIFO      => DM_INCLUDE_STS_FIFO                  ,
        C_MM2S_STSCMD_FIFO_DEPTH    => DM_CMDSTS_FIFO_DEPTH                 ,
        C_MM2S_STSCMD_IS_ASYNC      => DM_CLOCK_SYNC                        ,
        C_INCLUDE_MM2S_DRE          => C_INCLUDE_MM2S_DRE                   ,
        C_ENABLE_MM2S_TKEEP         => C_MM2S_ENABLE_TKEEP                   ,
        C_MM2S_BURST_SIZE           => C_MM2S_MAX_BURST_LENGTH              ,
        C_MM2S_BTT_USED             => MM2S_DM_BTT_LENGTH_WIDTH             ,
        C_MM2S_ADDR_PIPE_DEPTH      => DM_ADDR_PIPE_DEPTH                   ,
        C_MM2S_INCLUDE_SF           => DM_MM2S_INCLUDE_SF                   ,

	C_ENABLE_SKID_BUF	    => "11100"				    ,		

        C_INCLUDE_S2MM              => S2MM_AXI_FULL_MODE                   ,
        C_M_AXI_S2MM_ADDR_WIDTH     => C_M_AXI_S2MM_ADDR_WIDTH              ,
        C_M_AXI_S2MM_DATA_WIDTH     => C_M_AXI_S2MM_DATA_WIDTH              ,
        C_S_AXIS_S2MM_TDATA_WIDTH   => C_S_AXIS_S2MM_TDATA_WIDTH_CALCULATED            ,
        C_INCLUDE_S2MM_STSFIFO      => DM_INCLUDE_STS_FIFO                  ,
        C_S2MM_STSCMD_FIFO_DEPTH    => DM_CMDSTS_FIFO_DEPTH                 ,
        C_S2MM_STSCMD_IS_ASYNC      => DM_CLOCK_SYNC                        ,
        C_INCLUDE_S2MM_DRE          => C_INCLUDE_S2MM_DRE                   ,
        C_ENABLE_S2MM_TKEEP         => C_S2MM_ENABLE_TKEEP                   ,
        C_S2MM_BURST_SIZE           => C_S2MM_MAX_BURST_LENGTH              ,
        C_S2MM_BTT_USED             => S2MM_DM_BTT_LENGTH_WIDTH             ,
        C_S2MM_SUPPORT_INDET_BTT    => DM_SUPPORT_INDET_BTT                 ,
        C_S2MM_ADDR_PIPE_DEPTH      => DM_ADDR_PIPE_DEPTH                   ,
        C_S2MM_INCLUDE_SF           => DM_S2MM_INCLUDE_SF                   ,
        C_FAMILY                    => C_ROOT_FAMILY
    )
    port map(
        -- MM2S Primary Clock / Reset input
        m_axi_mm2s_aclk             => m_axi_mm2s_aclk                      ,
        m_axi_mm2s_aresetn          => mm2s_dm_prmry_resetn                 ,
        mm2s_halt                   => mm2s_halt                            ,
        mm2s_halt_cmplt             => mm2s_halt_cmplt                      ,
        mm2s_err                    => mm2s_err                             ,
        mm2s_allow_addr_req         => ALWAYS_ALLOW                         ,
        mm2s_addr_req_posted        => open                                 ,
        mm2s_rd_xfer_cmplt          => open                                 ,

        -- Memory Map to Stream Command FIFO and Status FIFO I/O --------------
        m_axis_mm2s_cmdsts_aclk     => m_axi_mm2s_aclk                      ,
        m_axis_mm2s_cmdsts_aresetn  => mm2s_dm_prmry_resetn                 ,

        -- User Command Interface Ports (AXI Stream)
        s_axis_mm2s_cmd_tvalid      => s_axis_mm2s_cmd_tvalid               ,
        s_axis_mm2s_cmd_tready      => s_axis_mm2s_cmd_tready               ,
        s_axis_mm2s_cmd_tdata       => s_axis_mm2s_cmd_tdata                ,

        -- User Status Interface Ports (AXI Stream)
        m_axis_mm2s_sts_tvalid      => m_axis_mm2s_sts_tvalid               ,
        m_axis_mm2s_sts_tready      => m_axis_mm2s_sts_tready               ,
        m_axis_mm2s_sts_tdata       => m_axis_mm2s_sts_tdata                ,
        m_axis_mm2s_sts_tkeep       => m_axis_mm2s_sts_tkeep                ,
        m_axis_mm2s_sts_tlast       => open                                 ,

        -- MM2S AXI Address Channel I/O  --------------------------------------
        m_axi_mm2s_arid             => open                                 ,
        m_axi_mm2s_araddr           => m_axi_mm2s_araddr                    ,
        m_axi_mm2s_arlen            => m_axi_mm2s_arlen                     ,
        m_axi_mm2s_arsize           => m_axi_mm2s_arsize                    ,
        m_axi_mm2s_arburst          => m_axi_mm2s_arburst                   ,
        m_axi_mm2s_arprot           => m_axi_mm2s_arprot                    ,
        m_axi_mm2s_arcache          => m_axi_mm2s_arcache                   ,
        m_axi_mm2s_arvalid          => m_axi_mm2s_arvalid                   ,
        m_axi_mm2s_arready          => m_axi_mm2s_arready                   ,

        -- MM2S AXI MMap Read Data Channel I/O  -------------------------------
        m_axi_mm2s_rdata            => m_axi_mm2s_rdata                     ,
        m_axi_mm2s_rresp            => m_axi_mm2s_rresp                     ,
        m_axi_mm2s_rlast            => m_axi_mm2s_rlast                     ,
        m_axi_mm2s_rvalid           => m_axi_mm2s_rvalid                    ,
        m_axi_mm2s_rready           => m_axi_mm2s_rready                    ,

        -- MM2S AXI Master Stream Channel I/O  --------------------------------
        m_axis_mm2s_tdata           => dm2linebuf_mm2s_tdata                ,
        m_axis_mm2s_tkeep           => dm2linebuf_mm2s_tkeep                ,
        m_axis_mm2s_tlast           => dm2linebuf_mm2s_tlast                ,
        m_axis_mm2s_tvalid          => dm2linebuf_mm2s_tvalid               ,
        m_axis_mm2s_tready          => linebuf2dm_mm2s_tready               ,

        -- Testing Support I/O
        mm2s_dbg_sel                => (others => '0')                      ,
        mm2s_dbg_data               => open                                 ,
        -- Datamover v4_02_a addional signals not needed for VDMA 
        --sg_ctl                      => (others => '0')                      ,
        m_axi_mm2s_aruser           => open                                 ,
        m_axi_s2mm_awuser           => open                                 ,

        -- S2MM Primary Clock/Reset input
        m_axi_s2mm_aclk             => m_axi_s2mm_aclk                      ,
        m_axi_s2mm_aresetn          => s2mm_dm_prmry_resetn                 ,
        s2mm_halt                   => s2mm_halt                            ,
        s2mm_halt_cmplt             => s2mm_halt_cmplt                      ,
        s2mm_err                    => s2mm_err                             ,
        s2mm_allow_addr_req         => ALWAYS_ALLOW                         ,
        s2mm_addr_req_posted        => open                                 ,
        s2mm_wr_xfer_cmplt          => open                                 ,
        s2mm_ld_nxt_len             => open                                 ,
        s2mm_wr_len                 => open                                 ,

        -- Stream to Memory Map Command FIFO and Status FIFO I/O --------------
        m_axis_s2mm_cmdsts_awclk    => m_axi_s2mm_aclk                      ,
        m_axis_s2mm_cmdsts_aresetn  => s2mm_dm_prmry_resetn                 ,

        -- User Command Interface Ports (AXI Stream)
        s_axis_s2mm_cmd_tvalid      => s_axis_s2mm_cmd_tvalid               ,
        s_axis_s2mm_cmd_tready      => s_axis_s2mm_cmd_tready               ,
        s_axis_s2mm_cmd_tdata       => s_axis_s2mm_cmd_tdata                ,

        -- User Status Interface Ports (AXI Stream)
        m_axis_s2mm_sts_tvalid      => m_axis_s2mm_sts_tvalid               ,
        m_axis_s2mm_sts_tready      => m_axis_s2mm_sts_tready               ,
        m_axis_s2mm_sts_tdata       => m_axis_s2mm_sts_tdata                ,
        m_axis_s2mm_sts_tkeep       => m_axis_s2mm_sts_tkeep                ,
        m_axis_s2mm_sts_tlast       => open                                 ,


        -- S2MM AXI Address Channel I/O  --------------------------------------
        m_axi_s2mm_awid             => open                                 ,
        m_axi_s2mm_awaddr           => m_axi_s2mm_awaddr                    ,
        m_axi_s2mm_awlen            => m_axi_s2mm_awlen                     ,
        m_axi_s2mm_awsize           => m_axi_s2mm_awsize                    ,
        m_axi_s2mm_awburst          => m_axi_s2mm_awburst                   ,
        m_axi_s2mm_awprot           => m_axi_s2mm_awprot                    ,
        m_axi_s2mm_awcache          => m_axi_s2mm_awcache                   ,
        m_axi_s2mm_awvalid          => m_axi_s2mm_awvalid                   ,
        m_axi_s2mm_awready          => m_axi_s2mm_awready                   ,

        -- S2MM AXI MMap Write Data Channel I/O  ------------------------------
        m_axi_s2mm_wdata            => m_axi_s2mm_wdata                     ,
        m_axi_s2mm_wstrb            => m_axi_s2mm_wstrb                     ,
        m_axi_s2mm_wlast            => m_axi_s2mm_wlast                     ,
        m_axi_s2mm_wvalid           => m_axi_s2mm_wvalid                    ,
        m_axi_s2mm_wready           => m_axi_s2mm_wready                    ,

        -- S2MM AXI MMap Write response Channel I/O  --------------------------
        m_axi_s2mm_bresp            => m_axi_s2mm_bresp                     ,
        m_axi_s2mm_bvalid           => m_axi_s2mm_bvalid                    ,
        m_axi_s2mm_bready           => m_axi_s2mm_bready                    ,


        -- S2MM AXI Slave Stream Channel I/O  ---------------------------------
        s_axis_s2mm_tdata           => linebuf2dm_s2mm_tdata                ,
        s_axis_s2mm_tkeep           => linebuf2dm_s2mm_tkeep                ,
        s_axis_s2mm_tlast           => linebuf2dm_s2mm_tlast                ,
        s_axis_s2mm_tvalid          => linebuf2dm_s2mm_tvalid               ,
        s_axis_s2mm_tready          => dm2linebuf_s2mm_tready               ,

        -- Testing Support I/O
        s2mm_dbg_sel                => (others => '0')                      ,
        s2mm_dbg_data               => open
    );

end implementation;
