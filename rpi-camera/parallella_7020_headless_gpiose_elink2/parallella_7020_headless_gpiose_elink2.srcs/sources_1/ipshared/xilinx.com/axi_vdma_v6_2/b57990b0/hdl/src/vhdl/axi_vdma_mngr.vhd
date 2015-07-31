-------------------------------------------------------------------------------
-- axi_vdma_mngr
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
-- Filename:          axi_vdma_mngr.vhd
-- Description: This entity is the top level entity for the AXI VDMA Controller
--              manager.
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
entity  axi_vdma_mngr is
    generic(
        C_PRMRY_IS_ACLK_ASYNC           : integer range 0 to 1      	:= 0;
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - Primary data path channels (MM2S and S2MM)
            --                            run asynchronous to AXI Lite, DMA Control,
            --                            and SG.

        C_PRMY_CMDFIFO_DEPTH        	: integer range 1 to 16        	:= 1;
            -- Depth of DataMover command FIFO

        C_INCLUDE_SF                	: integer range 0 to 1 		:= 0;
            -- Include or exclude store and forward module
            -- 0 = excluded
            -- 1 = included

        C_USE_FSYNC                     : integer range 0 to 1      	:= 0;
            -- Specifies DMA oeration synchronized to frame sync input
            -- 0 = Free running
            -- 1 = Fsync synchronous
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

        C_ENABLE_FLUSH_ON_FSYNC     	: integer range 0 to 1          := 0;           -- CR591965
            -- Specifies VDMA Flush on Frame sync enabled
            -- 0 = Disabled
            -- 1 = Enabled

        C_NUM_FSTORES               	: integer range 1 to 32         := 1;
            -- Number of Frame Stores

        C_GENLOCK_MODE              	: integer range 0 to 3          := 0;
            -- Specifies Gen-Lock Mode of operation
            -- 0 = Master - Channel configured to be Gen-Lock Master
            -- 1 = Slave - Channel configured to be Gen-Lock Slave

        C_GENLOCK_NUM_MASTERS       	: integer range 1 to 16         := 1;
            -- Number of Gen-Lock masters capable of controlling Gen-Lock Slave

        --C_GENLOCK_REPEAT_EN        	: integer range 0 to 1      	:= 0;                -- CR591965
            -- In flush on frame sync mode specifies whether frame number
            -- will increment on error'ed frame or repeat error'ed frame
            -- 0 = increment frame
            -- 1 = repeat frame

        -----------------------------------------------------------------------
        C_DYNAMIC_RESOLUTION           : integer range 0 to 1      	:= 1;
            -- Run time configuration of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 0 = Halt VDMA before writing new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 1 = Run time register configuration for new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE.
        -----------------------------------------------------------------------

        C_INTERNAL_GENLOCK_ENABLE   	: integer range 0 to 1          := 0;
            -- Enable internal genlock bus
            -- 0 = disable internal genlock bus
            -- 1 = enable internal genlock bus

        C_EXTEND_DM_COMMAND         	: integer range 0 to 1          := 0;
            -- Extend datamover command by padding BTT with 1's for
            -- indeterminate BTT mode

        -----------------------------------------------------------------------
        -- Scatter Gather Parameters
        -----------------------------------------------------------------------
        C_INCLUDE_SG              : integer range 0 to 1        	:= 1        ;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_M_AXI_SG_ADDR_WIDTH           : integer range 32 to 64    	:= 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_M_AXIS_SG_TDATA_WIDTH         : integer range 32 to 32    	:= 32;
            -- AXI Master Stream in for descriptor fetch

        -----------------------------------------------------------------------
        -- Memory Map Parameters
        -----------------------------------------------------------------------
        C_M_AXI_ADDR_WIDTH              : integer range 32 to 64    	:= 32;
            -- Master AXI Memory Map Address Width for Read Port

        C_DM_STATUS_WIDTH               : integer                   	:= 8 ;
            -- CR608521
            -- DataMover status width - is based on mode of operation

        C_S2MM_SOF_ENABLE                : integer range 0 to 1        	:= 0;
        C_MM2S_SOF_ENABLE                : integer range 0 to 1        	:= 0;

        C_INCLUDE_MM2S                  : integer range 0 to 1      	:= 1;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path

        C_INCLUDE_S2MM                  : integer range 0 to 1      	:= 1;
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

        C_FAMILY                        : string                    	:= "virtex7"
            -- Target FPGA Device Family
    );
    port (

        -- Secondary Clock and Reset
        prmry_aclk                  : in  std_logic                         ;               --
        prmry_resetn                : in  std_logic                         ;               --
        soft_reset                  : in  std_logic                         ;               --
 

        scndry_aclk                 : in  std_logic                             ;       --
        scndry_resetn               : in  std_logic                             ;       --
                                                                                        --
                                                                                           --
        -- Control and Status                                                               --
        run_stop                    : in  std_logic                         ;               --
        dmasr_halt                  : in  std_logic                         ;               --
        dmacr_repeat_en             : in  std_logic                         ;               --
        sync_enable                 : in  std_logic                         ;               --
        regdir_idle                 : in  std_logic                         ;               --
        ftch_idle                   : in  std_logic                         ;               --
        halt                        : in  std_logic                         ;               --
        halt_cmplt                  : in  std_logic                         ;               --
        halted_clr                  : out std_logic                         ;               --
        halted_set                  : out std_logic                         ;               --
        idle_set                    : out std_logic                         ;               --
        idle_clr                    : out std_logic                         ;               --
        chnl_current_frame          : out std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        genlock_pair_frame          : out std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --


        frame_number                : out std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        new_curdesc                 : out std_logic_vector                                  --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0);                 --
        new_curdesc_wren            : out std_logic                         ;               --
        stop                        : out std_logic                         ;               --
        all_idle                    : out std_logic                         ;               --
        cmdsts_idle                 : out std_logic                         ;               --
        ftchcmdsts_idle             : out std_logic                         ;               --
        fsize_mismatch_err_flag     : out std_logic                         ;               -- CR591965
        fsize_mismatch_err          : out std_logic                         ;               -- CR591965
        lsize_mismatch_err          : out std_logic                         ;               -- CR591965
        lsize_more_mismatch_err     : out std_logic                         ;               -- CR591965
        s2mm_fsize_mismatch_err_s   : out std_logic                         ;               -- CR591965

        mm2s_fsize_mismatch_err_s   : in std_logic                         ;               -- CR591965
        mm2s_fsize_mismatch_err_m   : in std_logic                         ;               -- CR591965
                                                                                            --
        -- Register direct support                                                          --
        prmtr_updt_complete         : in  std_logic                         ;               --
        reg_module_vsize            : in  std_logic_vector                                  --
                                        (VSIZE_DWIDTH-1 downto 0)           ;               --
        reg_module_hsize            : in  std_logic_vector                                  --
                                        (HSIZE_DWIDTH-1 downto 0)           ;               --
        reg_module_stride           : in  std_logic_vector                                  --
                                        (STRIDE_DWIDTH-1 downto 0)          ;               --
        reg_module_frmdly           : in  std_logic_vector                                  --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;               --
        reg_module_strt_addr        : in STARTADDR_ARRAY_TYPE                               --
                                        (0 to C_NUM_FSTORES - 1)            ;               --
                                                                                            --
        mstr_pntr_ref               : in  std_logic_vector(3 downto 0)      ;               -- (master in control)
        genlock_select              : in  std_logic                         ;               --
        frame_ptr_ref               : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        frame_ptr_in                : in std_logic_vector                                   --
                                        ((C_GENLOCK_NUM_MASTERS                             --
                                        *NUM_FRM_STORE_WIDTH)-1 downto 0)   ;               --
        frame_ptr_out               : out std_logic_vector                                  --
                                        (NUM_FRM_STORE_WIDTH-1 downto 0)    ;               --
        internal_frame_ptr_in       : in  std_logic_vector                                  --
                                        (NUM_FRM_STORE_WIDTH-1 downto 0)    ;               --
                                                                                            --
        update_frmstore             : out std_logic                         ;               -- CR582182
        frmstr_err_addr             : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               -- CR582182
        valid_frame_sync            : out std_logic                         ;               --
        valid_frame_sync_cmb        : out std_logic                         ;               --
        valid_video_prmtrs          : out std_logic                         ;               --
        parameter_update            : out std_logic                         ;               --
        tailpntr_updated            : in  std_logic                         ;               --
        frame_sync                  : in  std_logic                         ;               --
        circular_prk_mode           : in  std_logic                         ;               --
        line_buffer_empty           : in  std_logic                         ;               --
        dwidth_fifo_pipe_empty           : in  std_logic                         ;               --
        crnt_vsize                  : out std_logic_vector                                  --
                                        (VSIZE_DWIDTH-1 downto 0)           ;               -- CR575884
        num_frame_store             : in  std_logic_vector                                  --
                                        (NUM_FRM_STORE_WIDTH-1 downto 0)    ;               --
        all_lines_xfred             : in  std_logic                         ;               -- CR616211
        all_lasts_rcvd              : in  std_logic                         ;               --
        s2mm_strm_all_lines_rcvd              : in  std_logic                         ;               --
        drop_fsync_d_pulse_gen_fsize_less_err              : in  std_logic                         ;               --
        s2mm_fsize_more_or_sof_late : in  std_logic                         ;       --

        s2mm_dmasr_lsize_less_err   : in  std_logic                         ;       --

        s2mm_fsync_core             : in  std_logic                         ;       
        s2mm_fsync_out_m            : in  std_logic                         ;       
        mm2s_fsync_out_m            : in  std_logic                         ;       
       
	capture_hsize_at_uf_err     :  out std_logic_vector(15 downto 0) ;
  
        -- Test Vector signals                                                              --
        tstvect_err                 : out std_logic                         ;               --
        tstvect_fsync               : out std_logic                         ;               --
        tstvect_frame               : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        tstvect_frm_ptr_out         : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        mstrfrm_tstsync_out         : out std_logic                         ;               --
                                                                                            --
        -- AXI Stream Signals                                                               --
        packet_sof                  : in  std_logic                         ;               --
                                                                                            --
        -- Primary DMA Errors                                                               --
        dma_interr_set_minus_frame_errors              : out std_logic                         ;               --
        dma_interr_set              : out std_logic                         ;               --
        dma_slverr_set              : out std_logic                         ;               --
        dma_decerr_set              : out std_logic                         ;               --
                                                                                            --
        -- SG Descriptor Fetch AXI Stream In                                                --
        m_axis_ftch_tdata           : in  std_logic_vector                                  --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;              --
        m_axis_ftch_tvalid          : in  std_logic                         ;               --
        m_axis_ftch_tready          : out std_logic                         ;               --
        m_axis_ftch_tlast           : in  std_logic                         ;               --
                                                                                            --
        -- User Command Interface Ports (AXI Stream)                                        --
        s_axis_cmd_tvalid           : out std_logic                         ;               --
        s_axis_cmd_tready           : in  std_logic                         ;               --
        s_axis_cmd_tdata            : out std_logic_vector                                  --
                                        ((C_M_AXI_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);   --
                                                                                            --
        -- User Status Interface Ports (AXI Stream)                                         --
        m_axis_sts_tvalid           : in  std_logic                         ;               --
        m_axis_sts_tready           : out std_logic                         ;               --
        m_axis_sts_tdata            : in  std_logic_vector                                  --
                                        (C_DM_STATUS_WIDTH-1 downto 0);                     -- CR608521
        m_axis_sts_tkeep            : in  std_logic_vector                                  --
                                        ((C_DM_STATUS_WIDTH/8)-1  downto 0) ;               -- CR608521
        err                         : in  std_logic                         ;               --
                                                                                            --
        ftch_err                    : in  std_logic                                         --
    );

end axi_vdma_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_mngr is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-- Zero vector for tying off unused inputs
constant ZERO_VALUE         	: std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- Primary DataMover Command signals
signal cmnd_wr                  : std_logic := '0';
signal cmnd_data                : std_logic_vector
                                            ((C_M_AXI_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0) := (others => '0');
signal cmnd_pending             : std_logic := '0';
signal sts_received             : std_logic := '0';

-- Primary DataMover Status signals
signal done                     : std_logic := '0';
signal stop_i                   : std_logic := '0';
signal interr                   : std_logic := '0';
signal interr_minus_frame_errors                   : std_logic := '0';
signal slverr                   : std_logic := '0';
signal decerr                   : std_logic := '0';
signal tag                      : std_logic_vector(3 downto 0) := (others => '0');
signal dma_err                	: std_logic := '0';
--signal error                    : std_logic := '0';
signal zero_size_err            : std_logic := '0';
signal fsize_mismatch_err_i     : std_logic := '0'; -- CR591965
signal lsize_mismatch_err_i     : std_logic := '0'; -- CR591965
signal lsize_more_mismatch_err_i       : std_logic := '0'; -- CR591965
signal cmnd_idle                : std_logic := '0';
signal sts_idle                 : std_logic := '0';
signal ftch_complete            : std_logic := '0';
signal ftch_complete_clr        : std_logic := '0';
signal video_prmtrs_valid       : std_logic := '0';
signal prmtr_update_complete    : std_logic := '0'; -- CR605424

--Descriptor video xfer parameters
signal desc_data_wren           : std_logic := '0';
signal desc_strtaddress         : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0)  	:= (others => '0');
signal desc_vsize               : std_logic_vector(VSIZE_DWIDTH-1 downto 0)   		:= (others => '0');
signal desc_hsize               : std_logic_vector(HSIZE_DWIDTH-1 downto 0)   		:= (others => '0');
signal desc_stride              : std_logic_vector(STRIDE_DWIDTH-1 downto 0)  		:= (others => '0');
signal desc_frmdly              : std_logic_vector(FRMDLY_DWIDTH-1 downto 0)  		:= (others => '0');


-- Scatter Gather register Bank
signal crnt_vsize_i             : std_logic_vector(VSIZE_DWIDTH-1 downto 0)   		:= (others => '0'); -- CR575884
signal crnt_hsize               : std_logic_vector(HSIZE_DWIDTH-1 downto 0)   		:= (others => '0');
signal crnt_stride              : std_logic_vector(STRIDE_DWIDTH-1 downto 0)  		:= (others => '0');
signal crnt_frmdly              : std_logic_vector(FRMDLY_DWIDTH-1 downto 0)  		:= (others => '0');
signal crnt_start_address       : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0)	:= (others => '0');


signal frame_number_i           : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0');
signal mstr_frame_ref_in        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0');
signal slv_frame_ref_out        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0');
signal valid_frame_sync_i       : std_logic := '0';
signal valid_frame_sync_d2      : std_logic := '0';
signal initial_frame            : std_logic := '0';
signal tstvect_fsync_d1         : std_logic := '0';
signal tstvect_fsync_d2         : std_logic := '0';
signal repeat_frame             : std_logic := '0'; -- CR591965
signal repeat_frame_nmbr        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0'); -- CR591965
signal s_h_frame_number         : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0'); -- CR582182
signal dm_prev_frame_number     : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  	:= (others => '0'); -- CR582182
signal all_idle_d1              : std_logic := '0'; -- CR582182
signal all_idle_re              : std_logic := '0'; -- CR582182
signal all_idle_i               : std_logic := '0'; -- CR582182
signal late_idle                : std_logic := '0'; -- CR582182

signal frame_sync_d1            : std_logic := '0';
signal frame_sync_d2            : std_logic := '0';

signal err_d1                 	: std_logic := '0';



-- Dynamic frame store support
signal num_fstore_minus1_cmb    : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) 	:= (others => '0');
signal num_fstore_minus1        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal num_fstore_equal_one     : std_logic 						:= '0';
signal fsize_mismatch_err_flag_i     : std_logic 					:= '0';
signal flag_to_repeat_after_fsize_less_err     : std_logic 				:= '0'; 

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

fsize_mismatch_err_flag      <= fsize_mismatch_err_flag_i ;




-- Number of fstore value set in register is 0x01.
num_fstore_equal_one <= '1' when num_fstore_minus1 = ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)
                   else '0';



-- Pass errors to register module
dma_interr_set      <= interr ;
dma_interr_set_minus_frame_errors      <= interr_minus_frame_errors ;
dma_slverr_set      <= slverr ;
dma_decerr_set      <= decerr ;

-- Route out to map to reset module for halt/recover of datamover
fsize_mismatch_err  <= fsize_mismatch_err_i;    -- CR591965
lsize_mismatch_err  <= lsize_mismatch_err_i;    -- CR591965
lsize_more_mismatch_err  <= lsize_more_mismatch_err_i;    -- CR591965

-- Pass current vertical size out for line tracking in linebuffers
crnt_vsize          <= crnt_vsize_i; -- CR575884

-- Pass out to allow masking of fsync_out when parameters are not valid.
valid_video_prmtrs  <= video_prmtrs_valid;

all_idle            <= all_idle_i;  -- CR582182

--*****************************************************************************
-- Frame sync for incrementing frame_number.  This sync is qualified with
-- video parameter valid to prevent incrementing frame_number on first frame.
-- So valid_frame_sync will assert after first frame and then every frame
-- after that.
--*****************************************************************************
-- Qualify frame sync with valid parameters to allow for
-- clean video startup
valid_frame_sync_i <= frame_sync and video_prmtrs_valid;

--*****************************************************************************
-- Frame Sync For Masking FSync OUT when shutting down channel for
-- FrmCntEn Mode and frame count reached. (cannot move in time)
--*****************************************************************************
-- Pass combinatorial version for frame_count enable masking in axi_vdma_fsync_gen.
valid_frame_sync_cmb    <= valid_frame_sync_i;


--*****************************************************************************
-- INTIAL Frame Flag
-- Used to keep frame_number at Zero for intial frame
--*****************************************************************************

-- Flag used for intializing frame number to 0.  Will
-- hold frame number at 0 until a valid frame sync
-- occurs.
REG_INITIAL_FRAME_FLAG : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                initial_frame  <= '0';
            elsif(frame_sync = '1')then
                initial_frame  <= '1';
            end if;
        end if;
    end process REG_INITIAL_FRAME_FLAG;


--*****************************************************************************
-- Frame Store Error Address (CR582182)
--  Frame number currently being operated on from a memory map perspective.
--  Needed because axi stream can complete significanly prior to memory map
--  completion on S2MM writes allowing for an external fsync to be seen before
--  all status is returned from datamover.  This memory mapped based frame
--  number allows the correct frame store pointer to be updated to the
--  PARK_PTR_REF register during error events.
--*****************************************************************************
GEN_FRMSTORE_EXTFSYNC : if C_USE_FSYNC = 1 generate
begin
    -- Register all idle to generate re pulse for error frame store process
    REG_IDLE_RE : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' )then
                    all_idle_d1 <= '0';
                else
                    all_idle_d1 <= all_idle_i;
                end if;
            end if;
        end process REG_IDLE_RE;

        all_idle_re <= all_idle_i and not all_idle_d1;

    -- Case 2: Fsync asserts before Idle
    -- If this case and not case 3 (below) then do not sample
    -- frame_number but use s_h_frame_number.
    LATE_IDLE_CASE : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or all_idle_re = '1' or video_prmtrs_valid = '0')then
                    late_idle <= '0';
                elsif(frame_sync = '1' and all_idle_i = '0')then
                    late_idle <= '1';
                end if;
            end if;
        end process LATE_IDLE_CASE;

    -- Sample and hold frame number for special "late idle" case
    -- i.e. when memory map write does not complete before external
    -- fsync in asserts
    S_H_FRAME : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    s_h_frame_number <= (others => '0');
                elsif(frame_sync = '1')then
                    s_h_frame_number <= frame_number_i;
                end if;
            end if;
        end process S_H_FRAME;

    -- Sample current frame.  If normal fsync to idle relationship
    -- then pass frame_number.  If idle occurs after fsync then
    -- pass sample-n-held frame number.
----    REG_FRMSTORE_FRAME : process(prmry_aclk)
----        begin
----            if(prmry_aclk'EVENT and prmry_aclk = '1')then
----                -- Reset on reset and also on error delayed 1 to prevent re-assertion on transient
----                -- conditions causing wrong error frame to be logged.
----                --if(prmry_resetn = '0' or zero_size_err_d1 = '1')then
----                if(prmry_resetn = '0')then
----                    frmstr_err_addr <= (others => '0');
----                    update_frmstore   <= '0';
----
----                -- On frame size mismatch, late idle will be asserted and need
----                -- to latch in last frame (i.e. sample and held frame) into
----                -- the frame store register.
----                elsif(late_idle = '1' and fsize_mismatch_err_i = '1')then
----                    frmstr_err_addr <= s_h_frame_number;
----                    update_frmstore   <= '1';
----
----                -- CR591965 capture error frame for zero size and frm mismatch
----                -- needed because these two errors are detected at the completion
----                -- of a frame
----                --elsif(zero_size_err_re = '1')then
----                elsif(zero_size_err = '1' or fsize_mismatch_err_i = '1')then
----                    frmstr_err_addr <= frame_number_i;
----                    update_frmstore   <= '1';
----
----                -- Not in Park mode and Idle occurs after fsync therefore
----                -- pass sample-n-held frm number
----                -- CR583667
----                --elsif(late_idle = '1' and all_idle_re = '1')then
----                elsif(late_idle = '1' and all_idle_re = '1' and circular_prk_mode = '1')then
----                    frmstr_err_addr <= s_h_frame_number;
----                    update_frmstore   <= '1';
----
----                -- On idle assertion latch current frame number
----                -- CR583667
----                --elsif(all_idle_re = '1')then
----                elsif(all_idle_re = '1' or circular_prk_mode = '0')then
----                    frmstr_err_addr <= frame_number_i;
----                    update_frmstore   <= '1';
----                --else
----                --    update_frmstore   <= '0';
----                end if;
----            end if;
----        end process REG_FRMSTORE_FRAME;

    frmstr_err_addr <= frame_number_i;
    update_frmstore   <= '1';
end generate GEN_FRMSTORE_EXTFSYNC;

-- If configured for internal fsync then can simply pass
-- frame number to framestore value.
GEN_FRMSTORE_INTFSYNC : if C_USE_FSYNC = 0 generate
begin
    frmstr_err_addr <= frame_number_i;
    update_frmstore   <= '1';
end generate GEN_FRMSTORE_INTFSYNC;


--*****************************************************************************
-- Dynamic Frame Store Support
--*****************************************************************************
-- One less than setting of number of frame stores.  Use for reverse
-- flag toggle
num_fstore_minus1_cmb <= std_logic_vector(unsigned(num_frame_store) - 1);

REG_NUM_FSTR_MINUS1 : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                num_fstore_minus1 <= (others =>'0');
            else
                num_fstore_minus1 <= num_fstore_minus1_cmb(FRAME_NUMBER_WIDTH-1 downto 0);
            end if;
        end if;
    end process REG_NUM_FSTR_MINUS1;
--*****************************************************************************
-- Dynamic GenLock Slave Mode
--*****************************************************************************


-- Frame counter for Dynamic GenLock Slave Mode


DYNAMIC_SLAVE_MODE_FRAME_CNT : if C_GENLOCK_MODE = 3 generate
signal reg_frame_number_ds    : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)  := (others => '0');
signal rst_to_frame_zero        : std_logic := '0';
signal valid_frame_sync_d1      : std_logic := '0';
--signal valid_frame_sync_d2      : std_logic := '0';
begin

    -- Register qualified frame sync (i.e. valid parameters and frame_sync)
    -- for use in IOC Threshold count wr to hold counter at intial
    -- value until after first frame.  This is done in axi_vdma_reg_module.vhd
    DS_REG_VALID_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    valid_frame_sync    <= '0';
                    valid_frame_sync_d1 <= '0';
                    valid_frame_sync_d2 <= '0';
                else
                    valid_frame_sync_d1 <= valid_frame_sync_i;
                    valid_frame_sync_d2 <= valid_frame_sync_d1;
                    valid_frame_sync    <= valid_frame_sync_d2;
                end if;
            end if;
        end process DS_REG_VALID_FSYNC_OUT;

    -- Frame sync for test vector, delay counter, and threshold counter
    -- Register test vector signals out.  Also used for
    -- delay timer and threshold counter.
    -- Mask with valid video parameters to prevent delay counter
    -- from counting at start up for external fsyncs that can
    -- be coming in long before starting.
    -- Note: tstvect_fsync output needs to be aligned exactly
    -- with valid_frame_sync output for use in register module to
    -- reset threshold counter on first frame but not on subsequent
    -- frames.
    -- coverage off
    DS_PROCESS_TSTVECTOR_REG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    tstvect_fsync_d1    <= '0';
                    tstvect_fsync_d2    <= '0';
                    tstvect_fsync       <= '0';
                else
                    tstvect_fsync_d1    <= frame_sync;
                    tstvect_fsync_d2    <= tstvect_fsync_d1;
                    tstvect_fsync       <= tstvect_fsync_d2
                                            and video_prmtrs_valid;

                end if;
            end if;
        end process DS_PROCESS_TSTVECTOR_REG;
    -- coverage on

    -- Pass frame number out for test vector
    -- used in verification only
    
--tstvect_frame   <= frame_number_i;

    -- coverage off
    DS_TSTVECT_FRM_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frame <= (others => '0');
                    	elsif (dmasr_halt = '0') then
            			tstvect_frame <= frame_number_i;
                    	--else 
            		--	tstvect_frame <= tstvect_frame;
                    	end if;
                    end if;

        end process DS_TSTVECT_FRM_OUT;

    -- coverage on

    -- Calculate frame to work on based on frame delay
    DS_GEN_FSTORE_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin

        -- Register to break long timing paths
        DS_REG_EXT_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_frame_number_ds <= (others => '0');
                    else 
                        reg_frame_number_ds <= slv_frame_ref_out;
                    end if;
                end if;
            end process DS_REG_EXT_FRM_NUMBER;

    end generate DS_GEN_FSTORE_GRTR_ONE;

    DS_GEN_FSTORE_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin
        reg_frame_number_ds <= slv_frame_ref_out;

    end generate DS_GEN_FSTORE_EQL_ONE;

    --*************************************************************************
    --** VERIFICATION ONLY RTL
    --*************************************************************************
    -- coverage off
   -- TSTVECT_FTPTR_OUT : process(reg_frame_number_ds)
    DS_TSTVECT_FTPTR_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frm_ptr_out <= (others => '0');
                    	elsif (dmasr_halt = '0') then
            			tstvect_frm_ptr_out <= reg_frame_number_ds(FRAME_NUMBER_WIDTH-1 downto 0);
			--else 
				--tstvect_frm_ptr_out <= tstvect_frm_ptr_out;
                    	end if;
                    end if;

        end process DS_TSTVECT_FTPTR_OUT;

    -- coverage on
    --*************************************************************************
    --** END VERIFICATION ONLY RTL
    --*************************************************************************

    -------------------------------------------------------------------------------
    -- Include State Machine and support logic
    -------------------------------------------------------------------------------
    rst_to_frame_zero <= '1' when (dmasr_halt = '1')
                               or (initial_frame = '0' and sync_enable = '0' and circular_prk_mode = '1')
                    else '0';

    -- CR582183 incorrect frame delay on first frame
    -- Delay fsync 2 pipeline stages to allow crnt_frmdly to propogate to
    -- the correct value for frame_number_i sampling for genlock slave mode
    DS_REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_sync_d1 <= '0';
                    frame_sync_d2 <= '0';
                else
                    frame_sync_d1 <= frame_sync;
                    frame_sync_d2 <= frame_sync_d1;
                end if;
            end if;
        end process DS_REG_DELAY_FSYNC;

    -- Frame Number generation
    DS_REG_FRAME_COUNT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear at reset or stopped or first valid fsync not occured
                if(prmry_resetn = '0' or rst_to_frame_zero = '1')then
                    frame_number_i <= (others => '0');

                -- GenLock Mode and Not in Park Mode (i.e. in tail ptr mode)
                -- elsif(valid_frame_sync_i = '1' and sync_enable = '1' and circular_prk_mode = '1')then
                -- latch with frame_sync when doing gen lock to proper capture initial frame ptr in.
                -- CR582183 incorrect frame delay on first frame
                --elsif(frame_sync = '1' and sync_enable = '1' and circular_prk_mode = '1')then
 
               --elsif(frame_sync_d2 = '1' and sync_enable = '1' and circular_prk_mode = '1')then



                --elsif(fsize_mismatch_err_flag_i= '1')then
                elsif(flag_to_repeat_after_fsize_less_err= '1')then
                        frame_number_i <= frame_number_i;



                elsif(valid_frame_sync_d2 = '1' and sync_enable = '1' and circular_prk_mode = '1')then
                        frame_number_i <= reg_frame_number_ds(FRAME_NUMBER_WIDTH-1 downto 0);

                -- Otherwise all other changes are on frame sync boudnary.
                elsif(valid_frame_sync_d2 = '1')then
                    -- If Park is enabled
                    if(circular_prk_mode = '0')then
                        frame_number_i  <= frame_ptr_ref;
                    -- Frame count reached terminal count therefore roll count over
                    --elsif(frame_number_i = FRAME_NUMBER_TC)then
                    elsif(frame_number_i = num_fstore_minus1)then
                        frame_number_i <= (others => '0');
                    -- Increment frame count with each sync if valid prmtr values
                    -- stored.
                    else
                        frame_number_i <= std_logic_vector(unsigned(frame_number_i) + 1);
                    end if;

                end if;
            end if;
        end process DS_REG_FRAME_COUNT;

    frame_number <= frame_number_i;


--pass Dynamic Genlock Slave's current working frame number for grey encoding and then output

mstr_frame_ref_in <= frame_number_i;


        REG_CURR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        chnl_current_frame <= (others => '0');
                    else 
                        chnl_current_frame <= frame_number_i;
                    end if;
                end if;
            end process REG_CURR_FRM_NUMBER;

----chnl_current_frame <= frame_number_i;
----genlock_pair_frame <= slv_frame_ref_out;

        REG_PAIR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        genlock_pair_frame <= (others => '0');
                    else 
                        genlock_pair_frame <= slv_frame_ref_out;
                    end if;
                end if;
            end process REG_PAIR_FRM_NUMBER;


end generate DYNAMIC_SLAVE_MODE_FRAME_CNT;





--*****************************************************************************
-- GEN-LOCK Slave Mode
--*****************************************************************************
-- Frame counter for Gen-Lock Slave Mode
SLAVE_MODE_FRAME_CNT : if C_GENLOCK_MODE = 1 generate
constant ONE_FSTORE             : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)
                                    := std_logic_vector(to_unsigned(1,NUM_FRM_STORE_WIDTH));
signal ext_frame_number_grtr    : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal ext_frame_number_lesr    : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal reg_frame_number_grtr    : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal reg_frame_number_lesr    : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal ext_slv_frmref           : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal ext_crnt_frmdly          : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal ext_num_fstore           : std_logic_vector(NUM_FRM_STORE_WIDTH downto 0)  := (others => '0');
signal rst_to_frame_zero        : std_logic := '0';
signal valid_frame_sync_d1      : std_logic := '0';
--signal valid_frame_sync_d2      : std_logic := '0';
begin

    -- Register qualified frame sync (i.e. valid parameters and frame_sync)
    -- for use in IOC Threshold count wr to hold counter at intial
    -- value until after first frame.  This is done in axi_vdma_reg_module.vhd
    S_REG_VALID_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    valid_frame_sync    <= '0';
                    valid_frame_sync_d1 <= '0';
                    valid_frame_sync_d2 <= '0';
                else
                    valid_frame_sync_d1 <= valid_frame_sync_i;
                    valid_frame_sync_d2 <= valid_frame_sync_d1;
                    valid_frame_sync    <= valid_frame_sync_d2;
                end if;
            end if;
        end process S_REG_VALID_FSYNC_OUT;

    -- Frame sync for test vector, delay counter, and threshold counter
    -- Register test vector signals out.  Also used for
    -- delay timer and threshold counter.
    -- Mask with valid video parameters to prevent delay counter
    -- from counting at start up for external fsyncs that can
    -- be coming in long before starting.
    -- Note: tstvect_fsync output needs to be aligned exactly
    -- with valid_frame_sync output for use in register module to
    -- reset threshold counter on first frame but not on subsequent
    -- frames.
    S_PROCESS_TSTVECTOR_REG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    tstvect_fsync_d1    <= '0';
                    tstvect_fsync_d2    <= '0';
                    tstvect_fsync       <= '0';
                else
                    tstvect_fsync_d1    <= frame_sync;
                    tstvect_fsync_d2    <= tstvect_fsync_d1;
                    tstvect_fsync       <= tstvect_fsync_d2
                                            and video_prmtrs_valid;

                end if;
            end if;
        end process S_PROCESS_TSTVECTOR_REG;

    -- Pass frame number out for test vector
    -- used in verification only
    --tstvect_frame   <= frame_number_i;
    -- coverage off
    S_TSTVECT_FRM_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frame <= (others => '0');
                    	elsif (dmasr_halt = '0') then
            			tstvect_frame <= frame_number_i;
                    	--else 
            		--	tstvect_frame <= tstvect_frame;
                    	end if;
                    end if;

        end process S_TSTVECT_FRM_OUT;
    -- coverage on



    -- Calculate frame to work on based on frame delay
    GEN_FSTORE_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin
        -- Extend unsigned vectors by 1 bit to allow for
        -- carry out during addition.
        --ext_slv_frmref  <= '0' & slv_frame_ref_out;
        --ext_crnt_frmdly <= '0' & crnt_frmdly;
        ext_slv_frmref  <= "00" & slv_frame_ref_out;
        ext_crnt_frmdly <= "00" & crnt_frmdly;
        ext_num_fstore  <= '0' & num_frame_store;

        -- Calculate for when frame delay less than or equal to slave frame ref. This is
        -- normal operation where a simple subtraction of frame delay from slave frame ref
        -- will work.
        ext_frame_number_lesr <= std_logic_vector(unsigned(ext_slv_frmref)
                                                    - unsigned(ext_crnt_frmdly));

        -- Calculate for when frame delay greater than slave frame ref.  This is roll-over
        -- point, i.e. if slave frame ref = 0 then you want frame number to be C_NUM_FSTORES-1
        -- This can be calculated with (C_NUM_FSTORES + Slave Frame Ref) - Frame Delay
        --ext_frame_number_grtr  <= std_logic_vector( (C_NUM_FSTORES + unsigned(ext_slv_frmref))
        --                                            - unsigned(ext_crnt_frmdly));
        ext_frame_number_grtr  <= std_logic_vector( (unsigned(ext_num_fstore) + unsigned(ext_slv_frmref))
                                                    - unsigned(ext_crnt_frmdly));


        -- Register to break long timing paths
        REG_EXT_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_frame_number_grtr <= (others => '0');
                        reg_frame_number_lesr <= (others => '0');

                    -- If frame stores set to 1 then simply pass unmodified version
                    -- through
                    elsif(num_frame_store = ONE_FSTORE)then
                        reg_frame_number_grtr <= ext_slv_frmref;
                        reg_frame_number_lesr <= ext_slv_frmref;

                    else
                        reg_frame_number_grtr <= ext_frame_number_grtr;
                        reg_frame_number_lesr <= ext_frame_number_lesr;
                    end if;
                end if;
            end process REG_EXT_FRM_NUMBER;

    end generate GEN_FSTORE_GRTR_ONE;

    -- For frame stores = 1 then frame delay has no meaning.
    GEN_FSTORE_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin
        reg_frame_number_grtr <= ext_slv_frmref;
        reg_frame_number_lesr <= ext_slv_frmref;

    end generate GEN_FSTORE_EQL_ONE;

    --*************************************************************************
    --** VERIFICATION ONLY RTL
    --*************************************************************************
    -- coverage off
----    TSTVECT_FTPTR_OUT : process(crnt_frmdly,
----                                slv_frame_ref_out,
----                                reg_frame_number_lesr,
----                                reg_frame_number_grtr)
----        begin
----            if(crnt_frmdly <= slv_frame_ref_out)then
----                tstvect_frm_ptr_out <= reg_frame_number_lesr(FRAME_NUMBER_WIDTH-1 downto 0);
----            else
----                tstvect_frm_ptr_out <= reg_frame_number_grtr(FRAME_NUMBER_WIDTH-1 downto 0);
----            end if;
----        end process TSTVECT_FTPTR_OUT;


    S_TSTVECT_FTPTR_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frm_ptr_out <= (others => '0');
                    	elsif (dmasr_halt = '0') then
		            if(crnt_frmdly <= slv_frame_ref_out)then
		                tstvect_frm_ptr_out <= reg_frame_number_lesr(FRAME_NUMBER_WIDTH-1 downto 0);
		            else
		                tstvect_frm_ptr_out <= reg_frame_number_grtr(FRAME_NUMBER_WIDTH-1 downto 0);
		            end if;
			--else 
				--tstvect_frm_ptr_out <= tstvect_frm_ptr_out;
                    	end if;
                    end if;

        end process S_TSTVECT_FTPTR_OUT;



    -- coverage on
    --*************************************************************************
    --** END VERIFICATION ONLY RTL
    --*************************************************************************

    -------------------------------------------------------------------------------
    -- Include State Machine and support logic
    -------------------------------------------------------------------------------
    rst_to_frame_zero <= '1' when (dmasr_halt = '1')
                               or (initial_frame = '0' and sync_enable = '0' and circular_prk_mode = '1')
                    else '0';

    -- CR582183 incorrect frame delay on first frame
    -- Delay fsync 2 pipeline stages to allow crnt_frmdly to propogate to
    -- the correct value for frame_number_i sampling for genlock slave mode
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_sync_d1 <= '0';
                    frame_sync_d2 <= '0';
                else
                    frame_sync_d1 <= frame_sync;
                    frame_sync_d2 <= frame_sync_d1;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Frame Number generation
    REG_FRAME_COUNT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear at reset or stopped or first valid fsync not occured
                if(prmry_resetn = '0' or rst_to_frame_zero = '1')then
                    frame_number_i <= (others => '0');

                -- GenLock Mode and Not in Park Mode (i.e. in tail ptr mode)
                -- elsif(valid_frame_sync_i = '1' and sync_enable = '1' and circular_prk_mode = '1')then
                -- latch with frame_sync when doing gen lock to proper capture initial frame ptr in.
                -- CR582183 incorrect frame delay on first frame
                --elsif(frame_sync = '1' and sync_enable = '1' and circular_prk_mode = '1')then


                --elsif(fsize_mismatch_err_flag_i= '1')then
                elsif(flag_to_repeat_after_fsize_less_err= '1')then
                        frame_number_i <= frame_number_i;


                elsif(frame_sync_d2 = '1' and sync_enable = '1' and circular_prk_mode = '1')then
                    -- If frame delay less than or equal slave frame reference
                    -- then simply subtract
                    if(crnt_frmdly <= slv_frame_ref_out)then
                        frame_number_i <= reg_frame_number_lesr(FRAME_NUMBER_WIDTH-1 downto 0);
                    else
                        frame_number_i <= reg_frame_number_grtr(FRAME_NUMBER_WIDTH-1 downto 0);
                    end if;

                -- Otherwise all other changes are on frame sync boudnary.
                elsif(valid_frame_sync_d2 = '1')then
                    -- If Park is enabled
                    if(circular_prk_mode = '0')then
                        frame_number_i  <= frame_ptr_ref;
                    -- Frame count reached terminal count therefore roll count over
                    --elsif(frame_number_i = FRAME_NUMBER_TC)then
                    elsif(frame_number_i = num_fstore_minus1)then
                        frame_number_i <= (others => '0');
                    -- Increment frame count with each sync if valid prmtr values
                    -- stored.
                    else
                        frame_number_i <= std_logic_vector(unsigned(frame_number_i) + 1);
                    end if;

                end if;
            end if;
        end process REG_FRAME_COUNT;

    frame_number <= frame_number_i;

    
--pass Genlock Slave's current working frame number for grey encoding and then output -- CR 703788
--mstr_frame_ref_in <= (others =>  '0'); -- Not Used in Slave Mode

mstr_frame_ref_in <= frame_number_i;   -- CR 703788





        REG_CURR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        chnl_current_frame <= (others => '0');
                    else 
                        chnl_current_frame <= frame_number_i;
                    end if;
                end if;
            end process REG_CURR_FRM_NUMBER;

----chnl_current_frame <= frame_number_i;
----genlock_pair_frame <= slv_frame_ref_out;

        REG_PAIR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        genlock_pair_frame <= (others => '0');
                    else 
                        genlock_pair_frame <= slv_frame_ref_out;
                    end if;
                end if;
            end process REG_PAIR_FRM_NUMBER;



end generate SLAVE_MODE_FRAME_CNT;

--*****************************************************************************
-- Dynamic GenLock Master Mode
--*****************************************************************************
-- Frame counter for Gen-Lock Master Mode
DYNAMIC_MASTER_MODE_FRAME_CNT : if C_GENLOCK_MODE = 2 generate
signal valid_frame_sync_d1      		 : std_logic := '0';
--signal flag_to_repeat_after_fsize_less_err     : std_logic := '0'; 
--signal valid_frame_sync_d2      : std_logic := '0';
begin


    -- Register qualified frame sync (i.e. valid parameters and frame_sync)
    -- for use in IOC Threshold count wr to hold counter at intial
    -- value until after first frame.  This is done in axi_vdma_reg_module.vhd
    DM_REG_VALID_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    valid_frame_sync    <= '0';
                    valid_frame_sync_d1 <= '0';
                    valid_frame_sync_d2 <= '0';
                else
                    valid_frame_sync_d1 <= valid_frame_sync_i;
                    valid_frame_sync_d2 <= valid_frame_sync_d1;
                    valid_frame_sync    <= valid_frame_sync_d2;
                end if;
            end if;
        end process DM_REG_VALID_FSYNC_OUT;

    -- Frame sync for test vector, delay counter, and threshold counter
    -- Register test vector signals out.  Also used for
    -- delay timer and threshold counter.
 ----   DM_PROCESS_TSTVECTOR_REG : process(prmry_aclk)
 ----       begin
 ----           if(prmry_aclk'EVENT and prmry_aclk = '1')then
 ----               if(prmry_resetn = '0')then
 ----                   tstvect_fsync_d1<= '0';
 ----                   tstvect_fsync_d2<= '0';
 ----                   tstvect_frame   <= (others => '0');
 ----               else
 ----                   tstvect_fsync_d1<= frame_sync;
 ----                   tstvect_fsync_d2<= tstvect_fsync_d1;
 ----                   tstvect_frame   <= frame_number_i;
 ----               end if;
 ----           end if;
 ----       end process DM_PROCESS_TSTVECTOR_REG;
    -- coverage off
    DM_PROCESS_TSTVECTOR_REG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    tstvect_fsync_d1    <= '0';
                    tstvect_fsync_d2    <= '0';
                    tstvect_fsync       <= '0';
                else
                    tstvect_fsync_d1    <= frame_sync;
                    tstvect_fsync_d2    <= tstvect_fsync_d1;
                    tstvect_fsync       <= tstvect_fsync_d2
                                            and video_prmtrs_valid;

                end if;
            end if;
        end process DM_PROCESS_TSTVECTOR_REG;
    DM_TSTVECT_FRM_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frame <= (others => '0');
                    	elsif (dmasr_halt = '0') then
            			tstvect_frame <= frame_number_i;
                    	--else 
            		--	tstvect_frame <= tstvect_frame;
                    	end if;
                    end if;

        end process DM_TSTVECT_FRM_OUT;
    -- coverage on


    -- Mask with valid video parameters to prevent delay counter
    -- from counting at start up for external fsyncs that can
    -- be coming in long before starting.
    -- video_prmtrs_valid asserts on clock cycle following assertion
    -- of frame_sync, thus pipeline delay to create tstvect_fsync_d1
    -- is required to assert first fsync for first valid frame
    -- Note: tstvect_fsync output needs to be aligned exactly
    -- with valid_frame_sync output for use in register module to
    -- reset threshold counter on first frame but not on subsequent
    -- frames.
    --tstvect_fsync <= tstvect_fsync_d1 and video_prmtrs_valid;
    --tstvect_fsync <= tstvect_fsync_d2 and video_prmtrs_valid;

    DM_GEN_FSTORE_GRTR_TWO : if C_NUM_FSTORES > 2 generate
    begin
    -------------------------------------------------------------------------------
    -- Include State Machine and support logic
    -------------------------------------------------------------------------------
    -- Frame Number generation
    DM_REG_FRAME_COUNT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear at reset or stopped or first valid fsync not occured
                if(prmry_resetn = '0' or dmasr_halt = '1'
                or (circular_prk_mode = '1' and initial_frame = '0') or num_fstore_equal_one = '1')then

                    frame_number_i <= (others => '0');
                -- If Park is enabled then on frame sync transision to
                -- frame pointer reference.



                --elsif(fsize_mismatch_err_flag_i= '1')then
                elsif(flag_to_repeat_after_fsize_less_err= '1')then
                        frame_number_i <= frame_number_i;




                elsif(valid_frame_sync_d2 = '1' and circular_prk_mode = '0')then
                    frame_number_i <= frame_ptr_ref;
------------------------------------------------------------------------------------------------------------
                -- On Repeat Frame simply hold current frame number (CR591965)
                --elsif(repeat_frame = '1')then
                elsif(repeat_frame = '1' and dmacr_repeat_en = '1')then
                    frame_number_i <= repeat_frame_nmbr;
------------------------------------------------------------------------------------------------------------
                -- Frame count reached terminal count therefore roll count over
                --elsif(valid_frame_sync_i = '1' and frame_number_i = FRAME_NUMBER_TC)then
                elsif(valid_frame_sync_d2 = '1'  and sync_enable = '1' and frame_number_i = num_fstore_minus1 and (slv_frame_ref_out /= "00000"))then
                    frame_number_i <= (others => '0');
  
                elsif(valid_frame_sync_d2 = '1'  and sync_enable = '1' and frame_number_i = num_fstore_minus1 and (slv_frame_ref_out = "00000"))then
                    frame_number_i <= "00001";
                elsif(valid_frame_sync_d2 = '1'  and sync_enable = '1' and slv_frame_ref_out = num_fstore_minus1 and (frame_number_i = std_logic_vector(unsigned(slv_frame_ref_out) - 1)))then
                    frame_number_i <= (others => '0');

                elsif(valid_frame_sync_d2 = '1'  and sync_enable = '1' and (slv_frame_ref_out /= num_fstore_minus1) and (slv_frame_ref_out /= "00000") and (frame_number_i = std_logic_vector(unsigned(slv_frame_ref_out) - 1)))then
                    frame_number_i <= std_logic_vector(unsigned(frame_number_i) + 2);
                -- Increment frame count with each sync if valid prmtr values
                -- stored.


                elsif(valid_frame_sync_d2 = '1' and frame_number_i = num_fstore_minus1)then
                    frame_number_i <= (others => '0');


                elsif(valid_frame_sync_d2 = '1')then
                    frame_number_i <= std_logic_vector(unsigned(frame_number_i) + 1);
                end if;
            end if;
        end process DM_REG_FRAME_COUNT;
    end generate DM_GEN_FSTORE_GRTR_TWO;



   DM_GEN_FSTORES_EQL_TWO : if C_NUM_FSTORES = 2 generate
   begin
    -------------------------------------------------------------------------------
    -- Include State Machine and support logic
    -------------------------------------------------------------------------------
    -- Frame Number generation
    DM_REG_FRAME_COUNT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear at reset or stopped or first valid fsync not occured
                if(prmry_resetn = '0' or dmasr_halt = '1'
                or (circular_prk_mode = '1' and initial_frame = '0') or num_fstore_equal_one = '1')then

                    frame_number_i <= (others => '0');
                -- If Park is enabled then on frame sync transision to
                -- frame pointer reference.



                --elsif(fsize_mismatch_err_flag_i= '1')then
                elsif(flag_to_repeat_after_fsize_less_err= '1')then
                        frame_number_i <= frame_number_i;




                elsif(valid_frame_sync_d2 = '1' and circular_prk_mode = '0')then
                    frame_number_i <= frame_ptr_ref;
------------------------------------------------------------------------------------------------------------
                -- On Repeat Frame simply hold current frame number (CR591965)
                --elsif(repeat_frame = '1')then
                elsif(repeat_frame = '1' and dmacr_repeat_en = '1')then
                    frame_number_i <= repeat_frame_nmbr;
------------------------------------------------------------------------------------------------------------
                -- Frame count reached terminal count therefore roll count over
                --elsif(valid_frame_sync_i = '1' and frame_number_i = FRAME_NUMBER_TC)then
                elsif(valid_frame_sync_d2 = '1' and sync_enable = '1' and (frame_number_i = "00001") and (slv_frame_ref_out = "00001"))then
                    frame_number_i <= (others => '0');
  
                elsif(valid_frame_sync_d2 = '1' and sync_enable = '1' and (frame_number_i = "00001") and (slv_frame_ref_out = "00000"))then
                    frame_number_i <= "00001";
                elsif(valid_frame_sync_d2 = '1' and sync_enable = '1' and (frame_number_i = "00000") and (slv_frame_ref_out = "00001"))then
                    frame_number_i <= (others => '0');

                elsif(valid_frame_sync_d2 = '1' and sync_enable = '1' and (frame_number_i = "00000") and (slv_frame_ref_out = "00000"))then
                    frame_number_i <="00001" ;


                elsif(valid_frame_sync_d2 = '1' and frame_number_i = "00001")then
                    frame_number_i <= (others => '0');


                elsif(valid_frame_sync_d2 = '1' and frame_number_i = "00000")then
                    frame_number_i <="00001" ;
                end if;
            end if;
        end process DM_REG_FRAME_COUNT;



   end generate DM_GEN_FSTORES_EQL_TWO;




   DM_GEN_FSTORES_EQL_ONE : if C_NUM_FSTORES = 1 generate
   begin

                    frame_number_i <= (others => '0');


   end generate DM_GEN_FSTORES_EQL_ONE;

    DM_GEN_REPEAT_FRM_FSIZE_LESS_ERR_SOF : if C_MM2S_SOF_ENABLE = 1 or C_S2MM_SOF_ENABLE = 1 generate
    begin

		DM_REPEAT_EN_FSIZE_LESS_ERR_FLAG : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0' or valid_frame_sync_d2 = '1')then
		                flag_to_repeat_after_fsize_less_err  <= '0';
		            elsif(fsize_mismatch_err_i = '1')then
		                flag_to_repeat_after_fsize_less_err  <= '1';
		            end if;
		        end if;
		    end process DM_REPEAT_EN_FSIZE_LESS_ERR_FLAG;
    end generate DM_GEN_REPEAT_FRM_FSIZE_LESS_ERR_SOF;
		
    DM_GEN_REPEAT_FRM_FSIZE_LESS_ERR_NO_SOF : if C_MM2S_SOF_ENABLE = 0 and C_S2MM_SOF_ENABLE = 0 generate
    begin

			       flag_to_repeat_after_fsize_less_err  <= '0';
		            
    end generate DM_GEN_REPEAT_FRM_FSIZE_LESS_ERR_NO_SOF;
		



    -- If flush on frame sync enabled and genlock repeat frame enabled
    -- then repeat errored frame on next frame sync. (CR591965)
--    DM_GEN_REPEAT_FRM_LOGIC : if C_GENLOCK_REPEAT_EN = 1 and C_ENABLE_FLUSH_ON_FSYNC = 1 generate
--    begin


        DM_REPEAT_FRAME_PROCESS : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    ----if(prmry_resetn = '0' or valid_frame_sync_d2 = '1')then
                    if(prmry_resetn = '0' or (valid_frame_sync_d2 = '1' and flag_to_repeat_after_fsize_less_err = '0'))then
                        repeat_frame_nmbr <= (others => '0');
                        repeat_frame <= '0';

                    -- Frame size mismatch
                    elsif(fsize_mismatch_err_i='1' or flag_to_repeat_after_fsize_less_err = '1')then
                        repeat_frame_nmbr <= s_h_frame_number;
                        repeat_frame      <= '1';

                    -- Line size mismatch
                    elsif(lsize_mismatch_err_i='1' or lsize_more_mismatch_err_i ='1')then
                        repeat_frame_nmbr <= frame_number_i;
                        repeat_frame      <= '1';

                    end if;
                end if;
            end process DM_REPEAT_FRAME_PROCESS;
--    end generate DM_GEN_REPEAT_FRM_LOGIC;





----    -- Not in flush on frame sync mode or repeat frame not enabled (CR591965)
----    DM_GEN_NO_REPEAT_FRM_LOGIC : if C_GENLOCK_REPEAT_EN = 0 or C_ENABLE_FLUSH_ON_FSYNC = 0 generate
----    begin
----        -- never repeat frame
----        repeat_frame        <= '0';
----        repeat_frame_nmbr   <= (others => '0');
----
----    end generate DM_GEN_NO_REPEAT_FRM_LOGIC;

    -- Pass Frame sync to video
    mstr_frame_ref_in <= dm_prev_frame_number;

    -- Pass frame number out to register module
    frame_number <= frame_number_i;

    -- Drive test vector to zero for GenLock master mode
    --tstvect_frm_ptr_out <= (others => '0');
    -- Drive test vector for Dynamic GenLock master mode
    --tstvect_frm_ptr_out <= slv_frame_ref_out;

    -- coverage off
   -- TSTVECT_FTPTR_OUT : process(reg_frame_number_ds)
    DM_TSTVECT_FTPTR_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frm_ptr_out <= (others => '0');
                    	elsif (dmasr_halt = '0') then
    				tstvect_frm_ptr_out <= slv_frame_ref_out;
			--else 
				--tstvect_frm_ptr_out <= tstvect_frm_ptr_out;
                    	end if;
                    end if;

        end process DM_TSTVECT_FTPTR_OUT;

    -- coverage on


    DM_PREV_FRAME : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    dm_prev_frame_number <= (others => '0');
                --elsif(valid_frame_sync_d2 = '1'and repeat_frame = '0' and fsize_mismatch_err_flag_i = '0')then
                ----elsif(valid_frame_sync_d2 = '1'and repeat_frame = '0' and flag_to_repeat_after_fsize_less_err = '0')then
                elsif(valid_frame_sync_d2 = '1'and  (dmacr_repeat_en = '0' or repeat_frame = '0') and flag_to_repeat_after_fsize_less_err = '0')then
                    dm_prev_frame_number <= frame_number_i;
                end if;
            end if;
        end process DM_PREV_FRAME;




        REG_CURR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        chnl_current_frame <= (others => '0');
                    else 
                        chnl_current_frame <= frame_number_i;
                    end if;
                end if;
            end process REG_CURR_FRM_NUMBER;

----chnl_current_frame <= frame_number_i;
----genlock_pair_frame <= slv_frame_ref_out;

        REG_PAIR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        genlock_pair_frame <= (others => '0');
                    else 
                        genlock_pair_frame <= slv_frame_ref_out;
                    end if;
                end if;
            end process REG_PAIR_FRM_NUMBER;



end generate DYNAMIC_MASTER_MODE_FRAME_CNT;

--*****************************************************************************
-- GEN-LOCK MASTER Mode
--*****************************************************************************
-- Frame counter for Gen-Lock Master Mode
MASTER_MODE_FRAME_CNT : if C_GENLOCK_MODE = 0 generate
signal valid_frame_sync_d1      		 : std_logic := '0';
--signal flag_to_repeat_after_fsize_less_err     : std_logic := '0'; 
--signal valid_frame_sync_d2      : std_logic := '0';
begin


    -- Register qualified frame sync (i.e. valid parameters and frame_sync)
    -- for use in IOC Threshold count wr to hold counter at intial
    -- value until after first frame.  This is done in axi_vdma_reg_module.vhd

    M_REG_VALID_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    valid_frame_sync    <= '0';
                    valid_frame_sync_d1 <= '0';
                    valid_frame_sync_d2 <= '0';
                else
                    valid_frame_sync_d1 <= valid_frame_sync_i;
                    valid_frame_sync_d2 <= valid_frame_sync_d1;
                    valid_frame_sync    <= valid_frame_sync_d2;
                end if;
            end if;
        end process M_REG_VALID_FSYNC_OUT;




----    REG_VALID_FSYNC_OUT : process(prmry_aclk)
----        begin
----            if(prmry_aclk'EVENT and prmry_aclk = '1')then
----                if(prmry_resetn = '0')then
----                    valid_frame_sync <= '0';
----                else
----                    valid_frame_sync    <= valid_frame_sync_i;
----                end if;
----            end if;
----        end process REG_VALID_FSYNC_OUT;

    -- Frame sync for test vector, delay counter, and threshold counter
    -- Register test vector signals out.  Also used for
    -- delay timer and threshold counter.
----    PROCESS_TSTVECTOR_REG : process(prmry_aclk)
----        begin
----            if(prmry_aclk'EVENT and prmry_aclk = '1')then
----                if(prmry_resetn = '0')then
----                    tstvect_fsync_d1<= '0';
----                    tstvect_frame   <= (others => '0');
----                else
----                    tstvect_fsync_d1<= frame_sync;
----                    tstvect_frame   <= frame_number_i;
----                end if;
----            end if;
----        end process PROCESS_TSTVECTOR_REG;
    -- coverage off
    M_TSTVECT_FRM_OUT : process(prmry_aclk)
        begin
                    if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    	if(prmry_resetn = '0')then
                        	tstvect_frame <= (others => '0');
                    	elsif (dmasr_halt = '0') then
            			tstvect_frame <= frame_number_i;
                    	--else 
            		--	tstvect_frame <= tstvect_frame;
                    	end if;
                    end if;

        end process M_TSTVECT_FRM_OUT;

    M_PROCESS_TSTVECTOR_REG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    tstvect_fsync_d1    <= '0';
                    tstvect_fsync_d2    <= '0';
                    tstvect_fsync       <= '0';
                else
                    tstvect_fsync_d1    <= frame_sync;
                    tstvect_fsync_d2    <= tstvect_fsync_d1;
                    tstvect_fsync       <= tstvect_fsync_d2
                                            and video_prmtrs_valid;

                end if;
            end if;
        end process M_PROCESS_TSTVECTOR_REG;
    -- coverage on



    -- Mask with valid video parameters to prevent delay counter
    -- from counting at start up for external fsyncs that can
    -- be coming in long before starting.
    -- video_prmtrs_valid asserts on clock cycle following assertion
    -- of frame_sync, thus pipeline delay to create tstvect_fsync_d1
    -- is required to assert first fsync for first valid frame
    -- Note: tstvect_fsync output needs to be aligned exactly
    -- with valid_frame_sync output for use in register module to
    -- reset threshold counter on first frame but not on subsequent
    -- frames.
    --tstvect_fsync <= tstvect_fsync_d1 and video_prmtrs_valid;

    -------------------------------------------------------------------------------
    -- Include State Machine and support logic
    -------------------------------------------------------------------------------
    -- Frame Number generation
    REG_FRAME_COUNT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear at reset or stopped or first valid fsync not occured
                if(prmry_resetn = '0' or dmasr_halt = '1'
                or (circular_prk_mode = '1' and initial_frame = '0'))then

                    frame_number_i <= (others => '0');
                -- If Park is enabled then on frame sync transision to
                -- frame pointer reference.


                --elsif(fsize_mismatch_err_flag_i= '1')then
                elsif(flag_to_repeat_after_fsize_less_err= '1')then
                        frame_number_i <= frame_number_i;



                elsif(valid_frame_sync_d2 = '1' and circular_prk_mode = '0')then
                    frame_number_i <= frame_ptr_ref;

                -- On Repeat Frame simply hold current frame number (CR591965)
                --elsif(repeat_frame = '1')then
                elsif(repeat_frame = '1' and dmacr_repeat_en = '1')then
                    frame_number_i <= repeat_frame_nmbr;

                -- Frame count reached terminal count therefore roll count over
                --elsif(valid_frame_sync_i = '1' and frame_number_i = FRAME_NUMBER_TC)then
                elsif(valid_frame_sync_d2 = '1' and frame_number_i = num_fstore_minus1)then
                    frame_number_i <= (others => '0');

                -- Increment frame count with each sync if valid prmtr values
                -- stored.
                elsif(valid_frame_sync_d2 = '1' and video_prmtrs_valid = '1')then
                    frame_number_i <= std_logic_vector(unsigned(frame_number_i) + 1);
                end if;
            end if;
        end process REG_FRAME_COUNT;




    GEN_REPEAT_FRM_FSIZE_LESS_ERR_SOF : if C_MM2S_SOF_ENABLE = 1 or C_S2MM_SOF_ENABLE = 1 generate
    begin

		REPEAT_EN_FSIZE_LESS_ERR_FLAG : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0' or valid_frame_sync_d2 = '1')then
		                flag_to_repeat_after_fsize_less_err  <= '0';
		            elsif(fsize_mismatch_err_i = '1')then
		                flag_to_repeat_after_fsize_less_err  <= '1';
		            end if;
		        end if;
		    end process REPEAT_EN_FSIZE_LESS_ERR_FLAG;
    end generate GEN_REPEAT_FRM_FSIZE_LESS_ERR_SOF;
		
    GEN_REPEAT_FRM_FSIZE_LESS_ERR_NO_SOF : if C_MM2S_SOF_ENABLE = 0 and C_S2MM_SOF_ENABLE = 0 generate
    begin

			       flag_to_repeat_after_fsize_less_err  <= '0';
		            
    end generate GEN_REPEAT_FRM_FSIZE_LESS_ERR_NO_SOF;
		






    -- If flush on frame sync enabled and genlock repeat frame enabled
    -- then repeat errored frame on next frame sync. (CR591965)
   -- GEN_REPEAT_FRM_LOGIC : if C_GENLOCK_REPEAT_EN = 1 and C_ENABLE_FLUSH_ON_FSYNC = 1 generate
   -- begin


        REPEAT_FRAME_PROCESS : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    ----if(prmry_resetn = '0' or valid_frame_sync_d2 = '1')then
                    if(prmry_resetn = '0' or (valid_frame_sync_d2 = '1' and flag_to_repeat_after_fsize_less_err = '0'))then
                        repeat_frame_nmbr <= (others => '0');
                        repeat_frame <= '0';

                    -- Frame size mismatch
                    --elsif(fsize_mismatch_err_i='1')then
                    elsif(fsize_mismatch_err_i='1' or flag_to_repeat_after_fsize_less_err='1')then
                        repeat_frame_nmbr <= s_h_frame_number;
                        repeat_frame      <= '1';

                    -- Line size mismatch
                    elsif(lsize_mismatch_err_i='1' or lsize_more_mismatch_err_i ='1')then
                        repeat_frame_nmbr <= frame_number_i;
                        repeat_frame      <= '1';

                    end if;
                end if;
            end process REPEAT_FRAME_PROCESS;
    --end generate GEN_REPEAT_FRM_LOGIC;





----    -- Not in flush on frame sync mode or repeat frame not enabled (CR591965)
----    GEN_NO_REPEAT_FRM_LOGIC : if C_GENLOCK_REPEAT_EN = 0 or C_ENABLE_FLUSH_ON_FSYNC = 0 generate
----    begin
----        -- never repeat frame
----        repeat_frame        <= '0';
----        repeat_frame_nmbr   <= (others => '0');
----
----    end generate GEN_NO_REPEAT_FRM_LOGIC;

    -- Pass Frame sync to video
    mstr_frame_ref_in <= frame_number_i;

    -- Pass frame number out to register module
    frame_number <= frame_number_i;

    -- Drive test vector to zero for master mode
    tstvect_frm_ptr_out <= (others => '0');

----chnl_current_frame <= frame_number_i;




        REG_CURR_FRM_NUMBER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        chnl_current_frame <= (others => '0');
                    else 
                        chnl_current_frame <= frame_number_i;
                    end if;
                end if;
            end process REG_CURR_FRM_NUMBER;

----chnl_current_frame <= frame_number_i;

    genlock_pair_frame <= (others => '0');




end generate MASTER_MODE_FRAME_CNT;

--*****************************************************************************
-- Error Handling
-- For graceful shut down logic
--*****************************************************************************
-- Clear run/stop and stop state machines due to errors or soft reset
-- Error based on datamover error report or sg fetch error
-- SG fetch error included because need to shut down because data maybe corrupt
-- therefor do not want to issue the xfer command to primary datamover
-- Added run_stop to assertion for when run_stop is de-asserted in middle of video
-- frame need to halt datamover to clear out potential pending commands.
stop_i    <= dma_err         -- DMAIntErr, DMADecErr, DMASlvErr, ZeroSize, possibly Frame/Line Mismatch
          or ftch_err         -- SGDecErr, SGSlvErr
          or soft_reset;        -- Soft Reset issued

-- Reg stop out
REG_STOP_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                stop       <= '0';
            else
                stop       <= stop_i;
            end if;
        end if;
    end process REG_STOP_OUT;

-- For verification only - drive error detection
-- out to test vector port, will be stripped during build
-- (Broke up in order to capture all errors regardless of
-- flush on frame sync mode)
-- coverage off
REG_DELAY_ERR : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                err_d1        <= '0';
                tstvect_err   <= '0';
            else
                err_d1        <= slverr       -- DMASlvErr
                                or decerr       -- DMADecErr
                                or interr       -- DMAIntErr, ZeroSize, Frame
				or lsize_mismatch_err_i			-- Line Mismatch
				or lsize_more_mismatch_err_i		-- Line Mismatch
                                or ftch_err;  -- SGSlvErr, SGDecErr

                tstvect_err   <= err_d1;
            end if;
        end if;
    end process REG_DELAY_ERR;
-- coverage on


--*****************************************************************************
-- DMA Control
--*****************************************************************************

---------------------------------------------------------------------------
-- Primary DMA Controller State Machine
---------------------------------------------------------------------------
I_SM : entity  axi_vdma_v6_2.axi_vdma_sm
    generic map(
        C_M_AXI_ADDR_WIDTH              => C_M_AXI_ADDR_WIDTH           ,
        C_INCLUDE_SF                    => C_INCLUDE_SF                 ,
        C_USE_FSYNC                     => C_USE_FSYNC                  ,   -- CR591965
        C_ENABLE_FLUSH_ON_FSYNC         => C_ENABLE_FLUSH_ON_FSYNC      ,   -- CR591965
        C_EXTEND_DM_COMMAND             => C_EXTEND_DM_COMMAND          ,
        C_PRMY_CMDFIFO_DEPTH            => C_PRMY_CMDFIFO_DEPTH         ,
        C_MM2S_SOF_ENABLE               => C_MM2S_SOF_ENABLE               ,
        C_S2MM_SOF_ENABLE               => C_S2MM_SOF_ENABLE               ,
        C_PRMRY_IS_ACLK_ASYNC           => C_PRMRY_IS_ACLK_ASYNC               ,
        C_INCLUDE_MM2S                  => C_INCLUDE_MM2S               ,
        C_INCLUDE_S2MM                  => C_INCLUDE_S2MM
    )
    port map(
        prmry_aclk                      => prmry_aclk                   ,
        prmry_resetn                    => prmry_resetn                 ,
  
          scndry_aclk                 => scndry_aclk                 ,
          scndry_resetn               => scndry_resetn                 ,

        -- AXI Stream Qualifiers
        packet_sof                      => packet_sof                   ,

        -- Raw fsync (must use unqualified frame sync for proper sm operation)
        frame_sync                      => frame_sync                   ,

        -- Valid video parameter available
        video_prmtrs_valid              => video_prmtrs_valid           ,

        -- Control and Status
        run_stop                        => run_stop                     ,
        cmnd_idle                       => cmnd_idle                    ,
        sts_idle                        => sts_idle                     ,
        stop                            => stop_i                       ,
        halt                            => halt                         ,
        zero_size_err                   => zero_size_err                ,
        mm2s_fsync_out_m            	=> mm2s_fsync_out_m                  ,
        s2mm_fsync_out_m            	=> s2mm_fsync_out_m                  ,
        mm2s_fsize_mismatch_err_s       => mm2s_fsize_mismatch_err_s         ,   
        mm2s_fsize_mismatch_err_m       => mm2s_fsize_mismatch_err_m         ,   
        s2mm_fsize_mismatch_err_s       => s2mm_fsize_mismatch_err_s         ,   
        fsize_mismatch_err_flag         => fsize_mismatch_err_flag_i         ,   
        fsize_mismatch_err              => fsize_mismatch_err_i         ,   -- CR591965
        all_lines_xfred                 => all_lines_xfred              ,   -- CR616211

        all_lasts_rcvd                  => all_lasts_rcvd             ,   
drop_fsync_d_pulse_gen_fsize_less_err   => drop_fsync_d_pulse_gen_fsize_less_err                      ,
      	s2mm_strm_all_lines_rcvd    	=> s2mm_strm_all_lines_rcvd	,	--      : out std_logic;
      	s2mm_fsync_core    		=> s2mm_fsync_core	,	--      : out std_logic;
 
       -- DataMover Command/Status
        cmnd_wr                         => cmnd_wr                      ,
        cmnd_data                       => cmnd_data                    ,
        cmnd_pending                    => cmnd_pending                 ,
        sts_received                    => sts_received                 ,

        -- Descriptor Fields
        crnt_start_address              => crnt_start_address           ,
        crnt_vsize                      => crnt_vsize_i                 ,   -- CR575884
        crnt_hsize                      => crnt_hsize                   ,
        crnt_stride                     => crnt_stride

    );

-- If Scatter Gather engine is included then instantiate scatter gather
-- interface
GEN_SG_INTERFACE : if C_INCLUDE_SG = 1 generate
begin
    ---------------------------------------------------------------------------
    -- Scatter Gather State Machine
    ---------------------------------------------------------------------------
    I_SG_IF : entity  axi_vdma_v6_2.axi_vdma_sg_if
        generic map(

            -------------------------------------------------------------------
            -- Scatter Gather Parameters
            -------------------------------------------------------------------
            C_M_AXIS_SG_TDATA_WIDTH         => C_M_AXIS_SG_TDATA_WIDTH      ,
            C_M_AXI_SG_ADDR_WIDTH           => C_M_AXI_SG_ADDR_WIDTH        ,
            C_M_AXI_ADDR_WIDTH              => C_M_AXI_ADDR_WIDTH
        )
        port map(

            prmry_aclk                      => prmry_aclk                   ,
            prmry_resetn                    => prmry_resetn                 ,

            dmasr_halt                      => dmasr_halt                   ,
            ftch_idle                       => ftch_idle                    ,
            ftch_complete                   => ftch_complete                ,
            ftch_complete_clr               => ftch_complete_clr            ,

            -- SG Descriptor Fetch AXI Stream In
            m_axis_ftch_tdata               => m_axis_ftch_tdata            ,
            m_axis_ftch_tvalid              => m_axis_ftch_tvalid           ,
            m_axis_ftch_tready              => m_axis_ftch_tready           ,
            m_axis_ftch_tlast               => m_axis_ftch_tlast            ,

            -- Descriptor Field Output
            new_curdesc                     => new_curdesc                  ,
            new_curdesc_wren                => new_curdesc_wren             ,

            desc_data_wren                  => desc_data_wren               ,
            desc_strtaddress                => desc_strtaddress             ,
            desc_vsize                      => desc_vsize                   ,
            desc_hsize                      => desc_hsize                   ,
            desc_stride                     => desc_stride                  ,
            desc_frmdly                     => desc_frmdly

        );
end generate GEN_SG_INTERFACE;

-- If Scatter Gather engine is excluded then tie off unused signals
GEN_NO_SG_INTERFACE : if C_INCLUDE_SG = 0 generate
begin
    -- Map update complete to ftch_complete signal for proper
    -- video paramter transfer from axi_lite registers to video registers
    ftch_complete           <= prmtr_updt_complete;

    -- Signals not need for register direct mode
    m_axis_ftch_tready     <= '0';
    new_curdesc            <= (others => '0');
    new_curdesc_wren       <= '0';
    desc_data_wren         <= '0';
    desc_strtaddress       <= (others => '0');
    desc_vsize             <= (others => '0');
    desc_hsize             <= (others => '0');
    desc_stride            <= (others => '0');
    desc_frmdly            <= (others => '0');

end generate GEN_NO_SG_INTERFACE;

-------------------------------------------------------------------------------
-- Primary DataMover command status interface
-------------------------------------------------------------------------------
I_CMDSTS : entity  axi_vdma_v6_2.axi_vdma_cmdsts_if
    generic map(
        C_M_AXI_ADDR_WIDTH              => C_M_AXI_ADDR_WIDTH           ,
        C_DM_STATUS_WIDTH               => C_DM_STATUS_WIDTH            ,
        C_INCLUDE_MM2S                  => C_INCLUDE_MM2S               ,
        --C_ENABLE_DEBUG_INFO             => C_ENABLE_DEBUG_INFO             ,
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

        C_INCLUDE_S2MM                  => C_INCLUDE_S2MM,
        C_ENABLE_FLUSH_ON_FSYNC         => C_ENABLE_FLUSH_ON_FSYNC
    )
    port map(
        prmry_aclk                      => prmry_aclk                   ,
        prmry_resetn                    => prmry_resetn                 ,

        -- Fetch command write interface from sm
        cmnd_wr                         => cmnd_wr                      ,
        cmnd_data                       => cmnd_data                    ,
        cmnd_pending                    => cmnd_pending                 ,
        sts_received                    => sts_received                 ,
        crnt_hsize                      => crnt_hsize                   ,
        stop                            => stop_i                       ,
        halt                            => halt                         ,   -- CR613214
        dmasr_halt                      => dmasr_halt                   ,

        -- User Command Interface Ports (AXI Stream)
        s_axis_cmd_tvalid               => s_axis_cmd_tvalid            ,
        s_axis_cmd_tready               => s_axis_cmd_tready            ,
        s_axis_cmd_tdata                => s_axis_cmd_tdata             ,

        -- User Status Interface Ports (AXI Stream)
        m_axis_sts_tvalid               => m_axis_sts_tvalid            ,
        m_axis_sts_tready               => m_axis_sts_tready            ,
        m_axis_sts_tdata                => m_axis_sts_tdata             ,
        m_axis_sts_tkeep                => m_axis_sts_tkeep             ,
 
           s2mm_fsize_more_or_sof_late => s2mm_fsize_more_or_sof_late          ,   

        s2mm_dmasr_lsize_less_err                   => s2mm_dmasr_lsize_less_err                ,
        -- Zero Hsize and/or Vsize. mapped here to combine with interr
        zero_size_err                   => zero_size_err                ,
        -- Frame Mismatch. mapped here to combine with interr
        fsize_mismatch_err              => fsize_mismatch_err_i         ,   -- CR591965
        lsize_mismatch_err              => lsize_mismatch_err_i           ,   -- CR591965
        lsize_more_mismatch_err              => lsize_more_mismatch_err_i           ,   -- CR591965

        capture_hsize_at_uf_err              => capture_hsize_at_uf_err           ,   
        -- Primary DataMover Status
        err                             => err                          ,
        done                            => done                         ,
        err_o                           => dma_err                    ,
        interr_minus_frame_errors                          => interr_minus_frame_errors                       ,
        interr                          => interr                       ,
        slverr                          => slverr                       ,
        decerr                          => decerr                       ,
        tag                             => tag                             -- Not used
    );

---------------------------------------------------------------------------
-- Halt / Idle Status Manager
---------------------------------------------------------------------------
I_STS_MNGR : entity  axi_vdma_v6_2.axi_vdma_sts_mngr
    port map(
        prmry_aclk                      => prmry_aclk                   ,
        prmry_resetn                    => prmry_resetn                 ,

        -- dma control and sg engine status signals
        run_stop                        => run_stop                     ,
        regdir_idle                     => regdir_idle                  ,
        ftch_idle                       => ftch_idle                    ,
        cmnd_idle                       => cmnd_idle                    ,
        sts_idle                        => sts_idle                     ,
        line_buffer_empty               => line_buffer_empty            ,
        dwidth_fifo_pipe_empty               => dwidth_fifo_pipe_empty            ,
        video_prmtrs_valid              => video_prmtrs_valid           ,
        prmtr_update_complete           => prmtr_update_complete        , -- CR605424

        -- stop and halt control/status
        stop                            => stop_i                       ,
        halt                            => halt                         , -- CR 625278
        halt_cmplt                      => halt_cmplt                   ,

        -- system state and control
        all_idle                        => all_idle_i                   ,
        ftchcmdsts_idle                 => ftchcmdsts_idle              ,
        cmdsts_idle                     => cmdsts_idle                  ,
        halted_clr                      => halted_clr                   ,
        halted_set                      => halted_set                   ,
        idle_set                        => idle_set                     ,
        idle_clr                        => idle_clr
    );

---------------------------------------------------------------------------
-- Video Register Bank
---------------------------------------------------------------------------
VIDEO_REG_I : entity  axi_vdma_v6_2.axi_vdma_vidreg_module
    generic map(
        C_INCLUDE_SG                    => C_INCLUDE_SG                 ,
        C_NUM_FSTORES                   => C_NUM_FSTORES                ,
        C_DYNAMIC_RESOLUTION            => C_DYNAMIC_RESOLUTION                ,
        C_ADDR_WIDTH                    => C_M_AXI_ADDR_WIDTH           ,
        C_FAMILY                        => C_FAMILY
    )
    port map(
        prmry_aclk                      => prmry_aclk                   ,
        prmry_resetn                    => prmry_resetn                 ,

        -- Register update control
        ftch_complete                   => ftch_complete                ,
        ftch_complete_clr               => ftch_complete_clr            ,
        parameter_update                => parameter_update             ,
        video_prmtrs_valid              => video_prmtrs_valid           ,
        prmtr_update_complete           => prmtr_update_complete        , -- CR605424
        num_fstore_minus1               => num_fstore_minus1            , -- CR607089

        -- Register swap control/status
        frame_sync                      => frame_sync                   ,
        run_stop                        => run_stop                     ,
        dmasr_halt                      => dmasr_halt                   ,
        ftch_idle                       => ftch_idle                    ,
        tailpntr_updated                => tailpntr_updated             ,
        frame_number                    => frame_number_i               ,

        -- Register Direct Mode Video Parameter In
        reg_module_vsize                => reg_module_vsize             ,
        reg_module_hsize                => reg_module_hsize             ,
        reg_module_stride               => reg_module_stride            ,
        reg_module_frmdly               => reg_module_frmdly            ,
        reg_module_strt_addr            => reg_module_strt_addr         ,

        -- Descriptor data/control from sg interface
        desc_data_wren                  => desc_data_wren               ,
        desc_strtaddress                => desc_strtaddress             ,
        desc_vsize                      => desc_vsize                   ,
        desc_hsize                      => desc_hsize                   ,
        desc_stride                     => desc_stride                  ,
        desc_frmdly                     => desc_frmdly                  ,

        -- Scatter Gather register Bank
        --crnt_vsize                      => crnt_vsize                 ,   -- CR575884
        crnt_vsize                      => crnt_vsize_i                 ,   -- CR575884
        crnt_hsize                      => crnt_hsize                   ,
        crnt_stride                     => crnt_stride                  ,
        crnt_frmdly                     => crnt_frmdly                  ,
        crnt_start_address              => crnt_start_address
    );

---------------------------------------------------------------------------
-- Gen Lock
---------------------------------------------------------------------------
VIDEO_GENLOCK_I : entity axi_vdma_v6_2.axi_vdma_genlock_mngr
    generic map(
        C_GENLOCK_MODE                  => C_GENLOCK_MODE               ,
        C_GENLOCK_NUM_MASTERS           => C_GENLOCK_NUM_MASTERS        ,
        C_INTERNAL_GENLOCK_ENABLE       => C_INTERNAL_GENLOCK_ENABLE    ,
        C_NUM_FSTORES                   => C_NUM_FSTORES
    )
    port map(

        -- Secondary Clock Domain
        prmry_aclk                      => prmry_aclk                   ,
        prmry_resetn                    => prmry_resetn                 ,

        -- Dynamic Frame Store Support
        num_frame_store                 => num_frame_store              ,
        num_fstore_minus1               => num_fstore_minus1            ,

        -- Gen-Lock Slave Signals
        mstr_in_control                 => mstr_pntr_ref                ,
        genlock_select                  => genlock_select               ,
        frame_ptr_in                    => frame_ptr_in                 ,
        internal_frame_ptr_in           => internal_frame_ptr_in        ,
        slv_frame_ref_out               => slv_frame_ref_out            ,

        -- Gen-Lock Master Signals
        dmasr_halt                      => dmasr_halt                   ,
        circular_prk_mode               => circular_prk_mode            ,
        fsize_mismatch_err_flag         => fsize_mismatch_err_flag_i         ,   
        mstr_frame_update               => valid_frame_sync_d2           ,
        mstr_frame_ref_in               => mstr_frame_ref_in            ,
        mstrfrm_tstsync_out             => mstrfrm_tstsync_out          ,
        frame_ptr_out                   => frame_ptr_out
    );


end implementation;
