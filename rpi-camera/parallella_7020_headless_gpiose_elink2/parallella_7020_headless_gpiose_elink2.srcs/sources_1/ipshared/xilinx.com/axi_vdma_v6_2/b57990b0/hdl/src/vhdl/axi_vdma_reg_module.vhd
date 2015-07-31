-------------------------------------------------------------------------------
-- axi_vdma_reg_module
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
-- Filename:          axi_vdma_reg_module.vhd
-- Description: This entity is AXI VDMA Register Module Top Level
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
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

-------------------------------------------------------------------------------
entity  axi_vdma_reg_module is
    generic (
        C_TOTAL_NUM_REGISTER            : integer                := 8       ;
            -- Total number of defined registers for AXI VDMA.  Used
            -- to determine wrce and rdce vector widths.

        C_INCLUDE_SG                    : integer range 0 to 1   := 1       ;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_CHANNEL_IS_MM2S               : integer range 0 to 1   := 1       ;
            -- Channel type for Read Mux
            -- 0 = Channel is S2MM
            -- 1 = Channel is MM2S

        C_ENABLE_FLUSH_ON_FSYNC     	: integer range 0 to 1       := 0       ;  -- CR591965
            -- Specifies VDMA Flush on Frame sync enabled
            -- 0 = Disabled
            -- 1 = Enabled

        C_ENABLE_VIDPRMTR_READS     	: integer range 0 to 1       := 1       ;
            -- Specifies whether video parameters are readable by axi_lite interface
            -- when configure for Register Direct Mode
            -- 0 = Disable Video Parameter Reads
            -- 1 = Enable Video Parameter Reads

        C_INTERNAL_GENLOCK_ENABLE   	: integer range 0 to 1          := 0;

        -----------------------------------------------------------------------
        C_DYNAMIC_RESOLUTION           : integer range 0 to 1        := 1	;
            -- Run time configuration of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 0 = Halt VDMA before writing new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 1 = Run time register configuration for new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE.
        -----------------------------------------------------------------------

        --C_ENABLE_DEBUG_INFO             : string := "1111111111111111";		-- 1 to 16 -- 
        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '1');		--15 downto 0  -- 

        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 1;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers
        C_ENABLE_DEBUG_INFO_0       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 0
        C_ENABLE_DEBUG_INFO_1       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 1
        C_ENABLE_DEBUG_INFO_2       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 2
        C_ENABLE_DEBUG_INFO_3       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 3
        C_ENABLE_DEBUG_INFO_4       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 4
        C_ENABLE_DEBUG_INFO_5       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 5
        C_ENABLE_DEBUG_INFO_6       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 6
        C_ENABLE_DEBUG_INFO_7       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 7
        C_ENABLE_DEBUG_INFO_8       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 8
        C_ENABLE_DEBUG_INFO_9       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 9
        C_ENABLE_DEBUG_INFO_10      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 10
        C_ENABLE_DEBUG_INFO_11      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 11
        C_ENABLE_DEBUG_INFO_12      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 12
        C_ENABLE_DEBUG_INFO_13      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 13
        C_ENABLE_DEBUG_INFO_14      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 14
        C_ENABLE_DEBUG_INFO_15      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 15


        C_NUM_FSTORES                   : integer range 1 to 32 := 3        ;
            -- Number of Frame Stores

        C_LINEBUFFER_THRESH         	: integer range 1 to 65536  := 1        ;
            -- Linebuffer Threshold Default setting

        C_GENLOCK_MODE                  : integer range 0 to 3  := 0        ;
            -- Specifies the Gen-Lock mode for the MM2S Channel
            -- 0 = Master Mode
            -- 1 = Slave Mode

        C_S_AXI_LITE_ADDR_WIDTH     	: integer range 9 to 9    := 9       ;
            -- AXI Lite interface address width

        C_S_AXI_LITE_DATA_WIDTH     	: integer range 32 to 32    := 32       ;
            -- AXI Lite interface data width

        C_M_AXI_SG_ADDR_WIDTH       	: integer range 32 to 64    := 32       ;
            -- Scatter Gather engine Address Width

        C_M_AXI_ADDR_WIDTH          	: integer range 32 to 32    := 32
            -- Master AXI Memory Map Address Width for MM2S Write Port
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        prmry_aclk                  : in  std_logic                                 ;       --
        prmry_resetn                : in  std_logic                                 ;       --
                                                                                            --
        -- Register to AXI Lite Interface                                                   --
        axi2ip_wrce                 : in  std_logic_vector                                  --
                                           (C_TOTAL_NUM_REGISTER-1 downto 0)        ;       --
        axi2ip_wrdata               : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        axi2ip_rdaddr               : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)     ;       --
        axi2ip_rden                 : in  std_logic                                 ;       --
        ip2axi_rddata               : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        ip2axi_rddata_valid         : out std_logic                                 ;       --
        ip2axi_frame_ptr_ref        : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        ip2axi_frame_store          : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        ip2axi_introut              : out std_logic                                 ;       --
                                                                                            --
        -- Soft Reset                                                                       --
        soft_reset                  : out std_logic                                 ;       --
        soft_reset_clr              : in  std_logic                                 ;       --
                                                                                            --
        -- DMA Control / Status Register Signals                                            --
        stop                        : in  std_logic                                 ;       --
        halted_clr                  : in  std_logic                                 ;       --
        halted_set                  : in  std_logic                                 ;       --
        idle_set                    : in  std_logic                                 ;       --
        idle_clr                    : in  std_logic                                 ;       --
        dma_interr_set              : in  std_logic                                 ;       --
        dma_interr_set_minus_frame_errors              : in  std_logic                                 ;       --
        dma_slverr_set              : in  std_logic                                 ;       --
        dma_decerr_set              : in  std_logic                                 ;       --

        fsize_mismatch_err          : in  std_logic                                 ;       --
        lsize_mismatch_err          : in  std_logic                                 ;       --
        lsize_more_mismatch_err     : in  std_logic                                 ;       --
        s2mm_fsize_more_or_sof_late : in  std_logic                                 ;       --

        ioc_irq_set                 : in  std_logic                                 ;       --
        dly_irq_set                 : in  std_logic                                 ;       --
        irqdelay_status             : in  std_logic_vector(7 downto 0)              ;       --
        irqthresh_status            : in  std_logic_vector(7 downto 0)              ;       --
        frame_sync                  : in  std_logic                                 ;       --
        fsync_mask                  : in  std_logic                                 ;       --
                                                                                            --
        ftch_slverr_set             : in  std_logic                                 ;       --
        ftch_decerr_set             : in  std_logic                                 ;       --
        new_curdesc_wren            : in  std_logic                                 ;       --
        new_curdesc                 : in  std_logic_vector                                  --
                                           (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)       ;       --
        update_frmstore             : in  std_logic                                 ;       --
        new_frmstr                  : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        tstvect_fsync               : in  std_logic                                 ;       --
        valid_frame_sync            : in  std_logic                                 ;       --
        irqthresh_rstdsbl           : out std_logic                                 ;       --
        dlyirq_dsble                : out std_logic                                 ;       --
        irqthresh_wren              : out std_logic                                 ;       --
        irqdelay_wren               : out std_logic                                 ;       --
        tailpntr_updated            : out std_logic                                 ;       --

        reg_index                   : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --


        dmacr                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        dmasr                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        curdesc                     : out std_logic_vector                                  --
                                           (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)       ;       --
        taildesc                    : out std_logic_vector                                  --
                                           (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)       ;       --
        num_frame_store             : out std_logic_vector                                  --
                                        (NUM_FRM_STORE_WIDTH-1 downto 0)            ;       --
        linebuf_threshold           : out std_logic_vector                                  --
                                        (THRESH_MSB_BIT downto 0)                   ;       --
        -- Register Direct Support                                                          --
        regdir_idle                 : out std_logic                                 ;       --
        prmtr_updt_complete         : out std_logic                                 ;       --
        reg_module_vsize            : out std_logic_vector                                  --
                                           (VSIZE_DWIDTH-1 downto 0)                ;       --
        reg_module_hsize            : out std_logic_vector                                  --
                                           (HSIZE_DWIDTH-1 downto 0)                ;       --
        reg_module_stride           : out std_logic_vector                                  --
                                           (STRIDE_DWIDTH-1 downto 0)               ;       --
        reg_module_frmdly           : out std_logic_vector                                  --
                                           (FRMDLY_DWIDTH-1 downto 0)               ;       --
        reg_module_strt_addr        : out STARTADDR_ARRAY_TYPE                              --
                                           (0 to C_NUM_FSTORES - 1)                 ;       --
                                                                                            --
        -- Fetch/Update error addresses                                                     --
        frmstr_err_addr             : in std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)               ;     --
        ftch_err_addr               : in  std_logic_vector                                  --
                                           (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)               --


    );
end axi_vdma_reg_module;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_reg_module is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

constant VSIZE_PAD_WIDTH    : integer := C_S_AXI_LITE_DATA_WIDTH-VSIZE_DWIDTH;
constant VSIZE_PAD          : std_logic_vector(VSIZE_PAD_WIDTH-1 downto 0) 	:= (others => '0');
constant HSIZE_PAD_WIDTH    : integer := C_S_AXI_LITE_DATA_WIDTH-HSIZE_DWIDTH;
constant HSIZE_PAD          : std_logic_vector(HSIZE_PAD_WIDTH-1 downto 0) 	:= (others => '0');

constant FRMSTORE_ZERO_PAD  : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH - 1
                                downto FRMSTORE_MSB_BIT+1) 			:= (others => '0');
constant THRESH_ZERO_PAD    : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH - 1
                                downto THRESH_MSB_BIT+1) 			:= (others => '0');

-- Convert registeSTARTADDRr ce index depending on channel
constant DMACR_INDEX            : integer := convert_base_index(C_CHANNEL_IS_MM2S,MM2S_DMACR_INDEX);
constant THRESHOLD_INDEX      	: integer := convert_base_index(C_CHANNEL_IS_MM2S,MM2S_THRESHOLD_INDEX);
constant STARTADDR16_INDEX      : integer := convert_regdir_index(C_CHANNEL_IS_MM2S,MM2S_STARTADDR16_INDEX);
--constant STARTADDR32_INDEX    : integer := convert_regdir_index(C_CHANNEL_IS_MM2S,MM2S_STARTADDR32_INDEX);
constant VSIZE_INDEX            : integer := convert_regdir_index(C_CHANNEL_IS_MM2S,MM2S_VSIZE_INDEX);

-- Convert msb/lsb bit index depending on channel
constant PARKPTR_FRMPTR_MSB_BIT : integer := PARKPTR_FRMPTR_S2MM_MSB_BIT - (C_CHANNEL_IS_MM2S*8);
constant PARKPTR_FRMPTR_LSB_BIT : integer := PARKPTR_FRMPTR_S2MM_LSB_BIT - (C_CHANNEL_IS_MM2S*8);




-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal dmacr_i                      : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal dmasr_i                      : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal dma_irq_mask_i                      : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal curdesc_lsb_i                : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal curdesc_msb_i                : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal taildesc_lsb_i               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal reg_index_i                  : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal taildesc_msb_i               : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');
signal num_frame_store_i            : std_logic_vector(FRMSTORE_MSB_BIT downto 0)           := (others => '0');
signal num_frame_store_regmux_i     : std_logic_vector(FRMSTORE_MSB_BIT downto 0)           := (others => '0');
signal linebuf_threshold_i          : std_logic_vector(THRESH_MSB_BIT downto 0)             := (others => '0');
signal irqthresh_wren_i             : std_logic 					    := '0';
signal frm_store                    : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)       := (others => '0');
signal ptr_ref_i                    : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)       := (others => '0');

signal regdir_wrack                 : std_logic := '0'; -- CR620124



-- Register Direct signals
signal reg_module_vsize_i           : std_logic_vector(VSIZE_DWIDTH-1 downto 0)         := (others => '0');
signal reg_module_hsize_i           : std_logic_vector(HSIZE_DWIDTH-1 downto 0)         := (others => '0');
signal reg_module_stride_i          : std_logic_vector(STRIDE_DWIDTH-1 downto 0)        := (others => '0');
signal reg_module_frmdly_i          : std_logic_vector(FRMDLY_DWIDTH-1 downto 0)        := (others => '0');
signal reg_module_start_address1_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address2_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address3_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address4_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address5_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address6_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address7_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address8_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address9_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address10_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address11_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address12_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address13_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address14_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address15_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address16_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address17_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address18_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address19_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address20_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address21_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address22_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address23_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address24_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address25_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address26_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address27_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address28_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address29_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address30_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address31_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address32_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');

signal reg_module_strt_addr_i       : STARTADDR_ARRAY_TYPE(0 to C_NUM_FSTORES - 1);




-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


-- Pass register data out to top level for other module use
reg_index               <= reg_index_i;             -- REG INDEX 
dmacr                   <= dmacr_i;             -- DMA Control Register
dmasr                   <= dmasr_i;             -- DMA Status Register
num_frame_store         <= num_frame_store_i;   -- Number of Frame Stores
linebuf_threshold       <= linebuf_threshold_i; -- Line Buffer Threshold
ip2axi_frame_ptr_ref    <= ptr_ref_i;           -- Park Pointer Reference
ip2axi_frame_store      <= frm_store;           -- Current Frame Store


-- For 32 bit address map only lsb registers out
GEN_DESC_ADDR_EQL32 : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
begin
    curdesc    <= curdesc_lsb_i;
    taildesc   <= taildesc_lsb_i;
end generate GEN_DESC_ADDR_EQL32;

-- For 64 bit address map lsb and msb registers out
GEN_DESC_ADDR_EQL64 : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
begin
    curdesc    <= curdesc_msb_i & curdesc_lsb_i;
    taildesc   <= taildesc_msb_i & taildesc_lsb_i;
end generate GEN_DESC_ADDR_EQL64;

-- Pass MM2S register direct signals out
reg_module_vsize               <= reg_module_vsize_i             ;
reg_module_hsize               <= reg_module_hsize_i             ;
reg_module_stride              <= reg_module_stride_i            ;
reg_module_frmdly              <= reg_module_frmdly_i            ;
reg_module_strt_addr           <= reg_module_strt_addr_i         ;


I_DMA_REGISTER : entity axi_vdma_v6_2.axi_vdma_register
generic map (
    C_NUM_REGISTERS             => NUM_REG_PER_CHANNEL      ,
    C_NUM_FSTORES               => C_NUM_FSTORES            ,
    C_ENABLE_FLUSH_ON_FSYNC     => C_ENABLE_FLUSH_ON_FSYNC  , -- CR591965
    --C_ENABLE_DEBUG_INFO         => C_ENABLE_DEBUG_INFO             ,
        C_ENABLE_DEBUG_ALL      => C_ENABLE_DEBUG_ALL             ,
        C_ENABLE_DEBUG_INFO_0        => C_ENABLE_DEBUG_INFO_0             ,
        C_ENABLE_DEBUG_INFO_1        => C_ENABLE_DEBUG_INFO_1             ,
        C_ENABLE_DEBUG_INFO_2        => C_ENABLE_DEBUG_INFO_2             ,
        C_ENABLE_DEBUG_INFO_3        => C_ENABLE_DEBUG_INFO_3             ,
        C_ENABLE_DEBUG_INFO_4        => C_ENABLE_DEBUG_INFO_4             ,
        C_ENABLE_DEBUG_INFO_5        => C_ENABLE_DEBUG_INFO_5             ,
        C_ENABLE_DEBUG_INFO_6        => C_ENABLE_DEBUG_INFO_6             ,
        C_ENABLE_DEBUG_INFO_7        => C_ENABLE_DEBUG_INFO_7             ,
        C_ENABLE_DEBUG_INFO_8        => C_ENABLE_DEBUG_INFO_8             ,
        C_ENABLE_DEBUG_INFO_9        => C_ENABLE_DEBUG_INFO_9             ,
        C_ENABLE_DEBUG_INFO_10       => C_ENABLE_DEBUG_INFO_10             ,
        C_ENABLE_DEBUG_INFO_11       => C_ENABLE_DEBUG_INFO_11             ,
        C_ENABLE_DEBUG_INFO_12       => C_ENABLE_DEBUG_INFO_12             ,
        C_ENABLE_DEBUG_INFO_13       => C_ENABLE_DEBUG_INFO_13             ,
        C_ENABLE_DEBUG_INFO_14       => C_ENABLE_DEBUG_INFO_14             ,
        C_ENABLE_DEBUG_INFO_15       => C_ENABLE_DEBUG_INFO_15             ,


    C_CHANNEL_IS_MM2S           => C_CHANNEL_IS_MM2S                      ,
    C_INTERNAL_GENLOCK_ENABLE   => C_INTERNAL_GENLOCK_ENABLE          ,

    C_LINEBUFFER_THRESH         => C_LINEBUFFER_THRESH      ,
    C_INCLUDE_SG                => C_INCLUDE_SG             ,
    C_GENLOCK_MODE              => C_GENLOCK_MODE           ,
    C_S_AXI_LITE_DATA_WIDTH     => C_S_AXI_LITE_DATA_WIDTH  ,
    C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH
)
port map(
    -- Secondary Clock / Reset
    prmry_aclk                  => prmry_aclk               ,
    prmry_resetn                => prmry_resetn             ,

    -- CPU Write Control (via AXI Lite)
    axi2ip_wrdata               => axi2ip_wrdata            ,
    axi2ip_wrce                 => axi2ip_wrce
                                    (THRESHOLD_INDEX
                                    downto DMACR_INDEX)     ,
    -- DMASR Register bit control/status
    stop_dma                    => stop                     ,
    halted_clr                  => halted_clr               ,
    halted_set                  => halted_set               ,
    idle_set                    => idle_set                 ,
    idle_clr                    => idle_clr                 ,
    ioc_irq_set                 => ioc_irq_set              ,
    dly_irq_set                 => dly_irq_set              ,
    irqdelay_status             => irqdelay_status          ,
    irqthresh_status            => irqthresh_status         ,
    dlyirq_dsble                => dlyirq_dsble             ,
    frame_sync                  => frame_sync               ,
    fsync_mask                  => fsync_mask               ,

    -- SG Error Control
    ftch_slverr_set             => ftch_slverr_set          ,
    ftch_decerr_set             => ftch_decerr_set          ,
    ftch_err_addr               => ftch_err_addr          ,
    frmstr_err_addr             => frmstr_err_addr        ,

    fsize_mismatch_err          => fsize_mismatch_err         ,   -- CR591965
    lsize_mismatch_err          => lsize_mismatch_err           ,   -- CR591965
    lsize_more_mismatch_err     => lsize_more_mismatch_err           ,   -- CR591965
    s2mm_fsize_more_or_sof_late => s2mm_fsize_more_or_sof_late           ,   -- CR591965

    dma_interr_set_minus_frame_errors              => dma_interr_set_minus_frame_errors           ,
    dma_interr_set              => dma_interr_set           ,
    dma_slverr_set              => dma_slverr_set           ,
    dma_decerr_set              => dma_decerr_set           ,
    irqthresh_wren              => irqthresh_wren_i         ,
    irqdelay_wren               => irqdelay_wren            ,
    introut                     => ip2axi_introut           ,
    soft_reset_clr              => soft_reset_clr           ,

    -- CURDESC Update
    update_curdesc              => new_curdesc_wren         ,
    new_curdesc                 => new_curdesc              ,
    update_frmstore             => update_frmstore          ,
    new_frmstr                  => new_frmstr               ,
    frm_store                   => frm_store                ,

    -- TAILDESC Update
    tailpntr_updated            => tailpntr_updated         ,

    -- Channel Registers
    dmacr                       => dmacr_i                  ,
    dmasr                       => dmasr_i                  ,
    dma_irq_mask                       => dma_irq_mask_i                  ,
    curdesc_lsb                 => curdesc_lsb_i            ,
    curdesc_msb                 => curdesc_msb_i            ,
    taildesc_lsb                => taildesc_lsb_i           ,
    reg_index                	=> reg_index_i           ,
    taildesc_msb                => taildesc_msb_i           ,
    num_frame_store_regmux      => num_frame_store_regmux_i        ,
    num_frame_store             => num_frame_store_i        ,
    linebuf_threshold           => linebuf_threshold_i
);


-- Mask off first fsync by asserting irqthresh wren.  This is to prevent decrementing
-- frame count before first frame transfers. Note: implemented this way to prevent
-- having to modify axi_sg helper core
irqthresh_wren <= irqthresh_wren_i or (tstvect_fsync and not valid_frame_sync);

-- If delay interrupt disabled then do not reset irq threshold on delay timeout
irqthresh_rstdsbl  <= not dmacr_i(DMACR_DLY_IRQEN_BIT);

-- Soft reset set in mm2s DMACR or s2MM DMACR
soft_reset <= dmacr_i(DMACR_RESET_BIT);


-- Park Pointer Reference Register Field
PARK_REF_REG : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                ptr_ref_i   <= (others => '0');

            -- CPU Write
            elsif(axi2ip_wrce(VDMA_PARKPTR_INDEX) = '1')then
                ptr_ref_i  <= axi2ip_wrdata(PARKPTR_FRMPTR_MSB_BIT
                                     downto PARKPTR_FRMPTR_LSB_BIT);

            else
                ptr_ref_i   <= ptr_ref_i;

            end if;
        end if;
    end process PARK_REF_REG;


-- In scatter gather mode, tie off register direct signals
GEN_SG_MODE : if C_INCLUDE_SG = 1 generate
begin
    reg_module_vsize_i             <= (others => '0');
    reg_module_hsize_i             <= (others => '0');
    reg_module_stride_i            <= (others => '0');
    reg_module_frmdly_i            <= (others => '0');

    -- Must zero each element of an array of vectors to zero
    -- all vectors.
    GEN_ZERO_STRT : for i in 0 to C_NUM_FSTORES-1 generate
        begin
            reg_module_strt_addr_i(i)   <= (others => '0');
    end generate GEN_ZERO_STRT;


    reg_module_start_address1_i    <= (others => '0');
    reg_module_start_address2_i    <= (others => '0');
    reg_module_start_address3_i    <= (others => '0');
    reg_module_start_address4_i    <= (others => '0');
    reg_module_start_address5_i    <= (others => '0');
    reg_module_start_address6_i    <= (others => '0');
    reg_module_start_address7_i    <= (others => '0');
    reg_module_start_address8_i    <= (others => '0');
    reg_module_start_address9_i    <= (others => '0');
    reg_module_start_address10_i   <= (others => '0');
    reg_module_start_address11_i   <= (others => '0');
    reg_module_start_address12_i   <= (others => '0');
    reg_module_start_address13_i   <= (others => '0');
    reg_module_start_address14_i   <= (others => '0');
    reg_module_start_address15_i   <= (others => '0');
    reg_module_start_address16_i   <= (others => '0');
    reg_module_start_address17_i   <= (others => '0');
    reg_module_start_address18_i   <= (others => '0');
    reg_module_start_address19_i   <= (others => '0');
    reg_module_start_address20_i   <= (others => '0');
    reg_module_start_address21_i   <= (others => '0');
    reg_module_start_address22_i   <= (others => '0');
    reg_module_start_address23_i   <= (others => '0');
    reg_module_start_address24_i   <= (others => '0');
    reg_module_start_address25_i   <= (others => '0');
    reg_module_start_address26_i   <= (others => '0');
    reg_module_start_address27_i   <= (others => '0');
    reg_module_start_address28_i   <= (others => '0');
    reg_module_start_address29_i   <= (others => '0');
    reg_module_start_address30_i   <= (others => '0');
    reg_module_start_address31_i   <= (others => '0');
    reg_module_start_address32_i   <= (others => '0');
    regdir_idle                    <= '1';
    regdir_wrack                   <= '0';   -- CR620124
    prmtr_updt_complete            <= '0';
end generate GEN_SG_MODE;


-- In register direct mode instantiate register direct register block
GEN_REG_DIRECT_MODE : if C_INCLUDE_SG = 0 generate
begin
    REGDIRECT_I : entity  axi_vdma_v6_2.axi_vdma_regdirect
        generic map(
            C_NUM_REGISTERS             => NUM_DIRECT_REG_PER_CHANNEL           ,
            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
    	    C_GENLOCK_MODE              => C_GENLOCK_MODE           ,
    	    C_DYNAMIC_RESOLUTION        => C_DYNAMIC_RESOLUTION           ,
            C_S_AXI_LITE_DATA_WIDTH     => C_S_AXI_LITE_DATA_WIDTH              ,
            C_M_AXI_ADDR_WIDTH          => C_M_AXI_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => prmry_aclk                           ,
            prmry_resetn                => prmry_resetn                         ,

            -- AXI Interface Control
            axi2ip_wrce                 => axi2ip_wrce(STARTADDR16_INDEX
                                            downto VSIZE_INDEX)                 ,
            --axi2ip_wrce                 => axi2ip_wrce(STARTADDR32_INDEX
            --                                downto VSIZE_INDEX)                 ,
            axi2ip_wrdata               => axi2ip_wrdata                        ,

            run_stop                    => dmacr_i(DMACR_RS_BIT)                ,
            dmasr_halt                  => dmasr_i(DMASR_HALTED_BIT)            ,
            stop                        => stop                                 ,
            regdir_idle                 => regdir_idle                          ,

            -- Register Direct Support
        reg_index                   => reg_index_i                           ,
            prmtr_updt_complete         => prmtr_updt_complete                  ,
            reg_module_vsize            => reg_module_vsize_i                   ,
            reg_module_hsize            => reg_module_hsize_i                   ,
            reg_module_strid            => reg_module_stride_i                  ,
            reg_module_frmdly           => reg_module_frmdly_i                  ,
            reg_module_strt_addr        => reg_module_strt_addr_i               ,

            -- Start address mapped for ReadMux
            reg_module_start_address1   => reg_module_start_address1_i          ,
            reg_module_start_address2   => reg_module_start_address2_i          ,
            reg_module_start_address3   => reg_module_start_address3_i          ,
            reg_module_start_address4   => reg_module_start_address4_i          ,
            reg_module_start_address5   => reg_module_start_address5_i          ,
            reg_module_start_address6   => reg_module_start_address6_i          ,
            reg_module_start_address7   => reg_module_start_address7_i          ,
            reg_module_start_address8   => reg_module_start_address8_i          ,
            reg_module_start_address9   => reg_module_start_address9_i          ,
            reg_module_start_address10  => reg_module_start_address10_i         ,
            reg_module_start_address11  => reg_module_start_address11_i         ,
            reg_module_start_address12  => reg_module_start_address12_i         ,
            reg_module_start_address13  => reg_module_start_address13_i         ,
            reg_module_start_address14  => reg_module_start_address14_i         ,
            reg_module_start_address15  => reg_module_start_address15_i         ,
            reg_module_start_address16  => reg_module_start_address16_i         ,
            reg_module_start_address17  => reg_module_start_address17_i         ,
            reg_module_start_address18  => reg_module_start_address18_i         ,
            reg_module_start_address19  => reg_module_start_address19_i         ,
            reg_module_start_address20  => reg_module_start_address20_i         ,
            reg_module_start_address21  => reg_module_start_address21_i         ,
            reg_module_start_address22  => reg_module_start_address22_i         ,
            reg_module_start_address23  => reg_module_start_address23_i         ,
            reg_module_start_address24  => reg_module_start_address24_i         ,
            reg_module_start_address25  => reg_module_start_address25_i         ,
            reg_module_start_address26  => reg_module_start_address26_i         ,
            reg_module_start_address27  => reg_module_start_address27_i         ,
            reg_module_start_address28  => reg_module_start_address28_i         ,
            reg_module_start_address29  => reg_module_start_address29_i         ,
            reg_module_start_address30  => reg_module_start_address30_i         ,
            reg_module_start_address31  => reg_module_start_address31_i         ,
            reg_module_start_address32  => reg_module_start_address32_i
        );
end generate GEN_REG_DIRECT_MODE;



--*****************************************************************************
-- AXI LITE READ MUX
--*****************************************************************************
LITE_READ_MUX_I : entity  axi_vdma_v6_2.axi_vdma_reg_mux
    generic map(
        C_TOTAL_NUM_REGISTER        => C_TOTAL_NUM_REGISTER                     ,
        C_INCLUDE_SG                => C_INCLUDE_SG                             ,
        C_CHANNEL_IS_MM2S           => C_CHANNEL_IS_MM2S                        ,
        C_NUM_FSTORES               => C_NUM_FSTORES                            ,
        C_ENABLE_VIDPRMTR_READS     => C_ENABLE_VIDPRMTR_READS                  ,
        C_S_AXI_LITE_ADDR_WIDTH     => C_S_AXI_LITE_ADDR_WIDTH                  ,
        C_S_AXI_LITE_DATA_WIDTH     => C_S_AXI_LITE_DATA_WIDTH                  ,
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                    ,
        C_M_AXI_ADDR_WIDTH          => C_M_AXI_ADDR_WIDTH
    )
    port map (
        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        axi2ip_rdaddr               => axi2ip_rdaddr                            ,
        axi2ip_rden                 => axi2ip_rden                              ,
        ip2axi_rddata               => ip2axi_rddata                            ,
        ip2axi_rddata_valid         => ip2axi_rddata_valid                      ,

        dmacr                       => dmacr_i                                  ,
        dmasr                       => dmasr_i                                  ,
        dma_irq_mask                       => dma_irq_mask_i                                  ,
        curdesc_lsb                 => curdesc_lsb_i                            ,
        curdesc_msb                 => curdesc_msb_i                            ,
        taildesc_lsb                => taildesc_lsb_i                           ,
        reg_index                   => reg_index_i                           ,
        taildesc_msb                => taildesc_msb_i                           ,
        num_frame_store             => num_frame_store_regmux_i                        ,
        linebuf_threshold           => linebuf_threshold_i                      ,

        -- Register Direct Support
        reg_module_vsize            => reg_module_vsize_i                       ,
        reg_module_hsize            => reg_module_hsize_i                       ,
        reg_module_stride           => reg_module_stride_i                      ,
        reg_module_frmdly           => reg_module_frmdly_i                      ,
        reg_module_start_address1   => reg_module_start_address1_i              ,
        reg_module_start_address2   => reg_module_start_address2_i              ,
        reg_module_start_address3   => reg_module_start_address3_i              ,
        reg_module_start_address4   => reg_module_start_address4_i              ,
        reg_module_start_address5   => reg_module_start_address5_i              ,
        reg_module_start_address6   => reg_module_start_address6_i              ,
        reg_module_start_address7   => reg_module_start_address7_i              ,
        reg_module_start_address8   => reg_module_start_address8_i              ,
        reg_module_start_address9   => reg_module_start_address9_i              ,
        reg_module_start_address10  => reg_module_start_address10_i             ,
        reg_module_start_address11  => reg_module_start_address11_i             ,
        reg_module_start_address12  => reg_module_start_address12_i             ,
        reg_module_start_address13  => reg_module_start_address13_i             ,
        reg_module_start_address14  => reg_module_start_address14_i             ,
        reg_module_start_address15  => reg_module_start_address15_i             ,
        reg_module_start_address16  => reg_module_start_address16_i             ,
        reg_module_start_address17  => reg_module_start_address17_i             ,
        reg_module_start_address18  => reg_module_start_address18_i             ,
        reg_module_start_address19  => reg_module_start_address19_i             ,
        reg_module_start_address20  => reg_module_start_address20_i             ,
        reg_module_start_address21  => reg_module_start_address21_i             ,
        reg_module_start_address22  => reg_module_start_address22_i             ,
        reg_module_start_address23  => reg_module_start_address23_i             ,
        reg_module_start_address24  => reg_module_start_address24_i             ,
        reg_module_start_address25  => reg_module_start_address25_i             ,
        reg_module_start_address26  => reg_module_start_address26_i             ,
        reg_module_start_address27  => reg_module_start_address27_i             ,
        reg_module_start_address28  => reg_module_start_address28_i             ,
        reg_module_start_address29  => reg_module_start_address29_i             ,
        reg_module_start_address30  => reg_module_start_address30_i             ,
        reg_module_start_address31  => reg_module_start_address31_i             ,
        reg_module_start_address32  => reg_module_start_address32_i
    );

end implementation;
