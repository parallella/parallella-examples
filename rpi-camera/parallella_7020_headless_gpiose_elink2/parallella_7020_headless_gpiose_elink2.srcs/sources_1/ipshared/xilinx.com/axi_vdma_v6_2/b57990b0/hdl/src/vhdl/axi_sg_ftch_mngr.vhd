-------------------------------------------------------------------------------
-- axi_sg_ftch_mngr
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2010, 2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:          axi_sg_ftch_mngr.vhd
-- Description: This entity manages fetching of descriptors.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_sg.vhd
--                  axi_sg_pkg.vhd
--                   |- axi_sg_ftch_mngr.vhd
--                   |   |- axi_sg_ftch_sm.vhd
--                   |   |- axi_sg_ftch_pntr.vhd
--                   |   |- axi_sg_ftch_cmdsts_if.vhd
--                   |- axi_sg_updt_mngr.vhd
--                   |   |- axi_sg_updt_sm.vhd
--                   |   |- axi_sg_updt_cmdsts_if.vhd
--                   |- axi_sg_ftch_q_mngr.vhd
--                   |   |- axi_sg_ftch_queue.vhd
--                   |   |   |- proc_common_v4_0.sync_fifo_fg.vhd
--                   |   |   |- proc_common_v4_0.axi_sg_afifo_autord.vhd
--                   |   |- axi_sg_ftch_noqueue.vhd
--                   |- axi_sg_updt_q_mngr.vhd
--                   |   |- axi_sg_updt_queue.vhd
--                   |   |   |- proc_common_v4_0.sync_fifo_fg.vhd
--                   |   |- proc_common_v4_0.axi_sg_afifo_autord.vhd
--                   |   |- axi_sg_updt_noqueue.vhd
--                   |- axi_sg_intrpt.vhd
--                   |- axi_datamover_v5_0.axi_datamover.vhd
--
-------------------------------------------------------------------------------
-- Author:      Gary Burch
-- History:
--  GAB     3/19/10    v1_00_a
-- ^^^^^^
--  - Initial Release
-- ~~~~~~
--  GAB     7/20/10    v1_00_a
-- ^^^^^^
-- CR568950
-- Qualified reseting of sg_idle from axi_sg_ftch_pntr with associated channel's
-- flush control.
-- ~~~~~~
--  GAB     8/26/10    v2_00_a
-- ^^^^^^
--  Rolled axi_sg library version to version v2_00_a
-- ~~~~~~
--  GAB     10/21/10    v4_03
-- ^^^^^^
--  Rolled version to v4_03
-- ~~~~~~
--  GAB     6/13/11    v4_03
-- ^^^^^^
-- Update to AXI Datamover v4_03
-- Added aynchronous operation
-- ~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_sg_pkg.all;


-------------------------------------------------------------------------------
entity  axi_sg_ftch_mngr is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64    := 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_INCLUDE_CH1           : integer range 0 to 1          := 1;
            -- Include or Exclude channel 1 scatter gather engine
            -- 0 = Exclude Channel 1 SG Engine
            -- 1 = Include Channel 1 SG Engine

        C_INCLUDE_CH2           : integer range 0 to 1          := 1;
            -- Include or Exclude channel 2 scatter gather engine
            -- 0 = Exclude Channel 2 SG Engine
            -- 1 = Include Channel 2 SG Engine

        C_SG_CH1_WORDS_TO_FETCH : integer range 4 to 16         := 8;
            -- Number of words to fetch for channel 1

        C_SG_CH2_WORDS_TO_FETCH : integer range 4 to 16         := 8;
            -- Number of words to fetch for channel 1

        C_SG_FTCH_DESC2QUEUE     : integer range 0 to 8         := 0;
            -- Number of descriptors to fetch and queue for each channel.
            -- A value of zero excludes the fetch queues.

        C_SG_CH1_ENBL_STALE_ERROR   : integer range 0 to 1      := 1;
            -- Enable or disable stale descriptor check
            -- 0 = Disable stale descriptor error check
            -- 1 = Enable stale descriptor error check

        C_SG_CH2_ENBL_STALE_ERROR   : integer range 0 to 1      := 1
            -- Enable or disable stale descriptor check
            -- 0 = Disable stale descriptor error check
            -- 1 = Enable stale descriptor error check



    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                    --
        m_axi_sg_aresetn            : in  std_logic                         ;                    --
                                                                                                 --
        -- Channel 1 Control and Status                                                          --
        ch1_run_stop                : in  std_logic                         ;                    --
        ch1_desc_flush              : in  std_logic                         ;                    --
        ch1_updt_done               : in  std_logic                         ;                    --
        ch1_ftch_idle               : out std_logic                         ;                    --
        ch1_ftch_active             : out std_logic                         ;                    --
        ch1_ftch_interr_set         : out std_logic                         ;                    --
        ch1_ftch_slverr_set         : out std_logic                         ;                    --
        ch1_ftch_decerr_set         : out std_logic                         ;                    --
        ch1_ftch_err_early          : out std_logic                         ;                    --
        ch1_ftch_stale_desc         : out std_logic                         ;                    --
        ch1_tailpntr_enabled        : in  std_logic                         ;                    --
        ch1_taildesc_wren           : in  std_logic                         ;                    --
        ch1_taildesc                : in  std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                    --
        ch1_nxtdesc_wren            : in  std_logic                         ;                    --
        ch1_curdesc                 : in  std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                    --
        ch1_ftch_queue_empty        : in  std_logic                         ;                    --
        ch1_ftch_queue_full         : in  std_logic                         ;                    --
        ch1_ftch_pause              : in  std_logic                         ;                    --
                                                                                                 --
        -- Channel 2 Control and Status                                                          --
        ch2_run_stop                : in  std_logic                         ;                    --
        ch2_updt_done               : in  std_logic                         ;                    --
        ch2_desc_flush              : in  std_logic                         ;                    --
        ch2_ftch_idle               : out std_logic                         ;                    --
        ch2_ftch_active             : out std_logic                         ;                    --
        ch2_ftch_interr_set         : out std_logic                         ;                    --
        ch2_ftch_slverr_set         : out std_logic                         ;                    --
        ch2_ftch_decerr_set         : out std_logic                         ;                    --
        ch2_ftch_err_early          : out std_logic                         ;                    --
        ch2_ftch_stale_desc         : out std_logic                         ;                    --
        ch2_tailpntr_enabled        : in  std_logic                         ;                    --
        ch2_taildesc_wren           : in  std_logic                         ;                    --
        ch2_taildesc                : in  std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                    --
        ch2_nxtdesc_wren            : in  std_logic                         ;                    --
        ch2_curdesc                 : in  std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                    --
        ch2_ftch_queue_empty        : in  std_logic                         ;                    --
        ch2_ftch_queue_full         : in  std_logic                         ;                    --
        ch2_ftch_pause              : in  std_logic                         ;                    --
                                                                                                 --
        nxtdesc                     : in  std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                    --
                                                                                                 --
        -- Read response for detecting slverr, decerr early                                      --
        m_axi_sg_rresp              : in  std_logic_vector(1 downto 0)      ;                    --
        m_axi_sg_rvalid             : in  std_logic                         ;                    --
                                                                                                 --
        -- User Command Interface Ports (AXI Stream)                                             --
        s_axis_ftch_cmd_tvalid      : out std_logic                         ;                    --
        s_axis_ftch_cmd_tready      : in  std_logic                         ;                    --
        s_axis_ftch_cmd_tdata       : out std_logic_vector                                       --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);     --
                                                                                                 --
        -- User Status Interface Ports (AXI Stream)                                              --
        m_axis_ftch_sts_tvalid      : in  std_logic                         ;                    --
        m_axis_ftch_sts_tready      : out std_logic                         ;                    --
        m_axis_ftch_sts_tdata       : in  std_logic_vector(7 downto 0)      ;                    --
        m_axis_ftch_sts_tkeep       : in  std_logic_vector(0 downto 0)      ;                    --
        mm2s_err                    : in  std_logic                         ;                    --
                                                                                                 --
                                                                                                 --
        ftch_cmnd_wr                : out std_logic                         ;                    --
        ftch_cmnd_data              : out std_logic_vector                                       --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);     --
        ftch_stale_desc             : in  std_logic                         ;                    --
        updt_error                  : in  std_logic                         ;                    --
        ftch_error                  : out std_logic                         ;                    --
        ftch_error_addr             : out std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)                       --

    );

end axi_sg_ftch_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_mngr is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-- No Constants Declared

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal ftch_cmnd_wr_i               : std_logic := '0';
signal ftch_cmnd_data_i             : std_logic_vector
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0)
                                        := (others => '0');

signal ch1_sg_idle                  : std_logic := '0';
signal ch1_fetch_address            : std_logic_vector
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)
                                        := (others => '0');

signal ch2_sg_idle                  : std_logic := '0';
signal ch2_fetch_address            : std_logic_vector
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)
                                        := (others => '0');

signal ftch_done                    : std_logic := '0';
signal ftch_error_i                 : std_logic := '0';
signal ftch_interr                  : std_logic := '0';
signal ftch_slverr                  : std_logic := '0';
signal ftch_decerr                  : std_logic := '0';
signal ftch_error_early             : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
ftch_cmnd_wr        <= ftch_cmnd_wr_i;
ftch_cmnd_data      <= ftch_cmnd_data_i;
ftch_error          <= ftch_error_i;

-------------------------------------------------------------------------------
--  Scatter Gather Fetch State Machine
-------------------------------------------------------------------------------
I_FTCH_SG : entity  axi_vdma_v6_2.axi_sg_ftch_sm
    generic map(
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                ,
        C_INCLUDE_CH1               => C_INCLUDE_CH1                        ,
        C_INCLUDE_CH2               => C_INCLUDE_CH2                        ,
        C_SG_CH1_WORDS_TO_FETCH     => C_SG_CH1_WORDS_TO_FETCH              ,
        C_SG_CH2_WORDS_TO_FETCH     => C_SG_CH2_WORDS_TO_FETCH              ,
        C_SG_FTCH_DESC2QUEUE        => C_SG_FTCH_DESC2QUEUE                 ,
        C_SG_CH1_ENBL_STALE_ERROR   => C_SG_CH1_ENBL_STALE_ERROR            ,
        C_SG_CH2_ENBL_STALE_ERROR   => C_SG_CH2_ENBL_STALE_ERROR
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_sg_aresetn            => m_axi_sg_aresetn                     ,
        updt_error                  => updt_error                           ,

        -- Channel 1 Control and Status
        ch1_run_stop                => ch1_run_stop                         ,
        ch1_updt_done               => ch1_updt_done                        ,
        ch1_desc_flush              => ch1_desc_flush                       ,
        ch1_sg_idle                 => ch1_sg_idle                          ,
        ch1_tailpntr_enabled        => ch1_tailpntr_enabled                 ,
        ch1_ftch_queue_empty        => ch1_ftch_queue_empty                 ,
        ch1_ftch_queue_full         => ch1_ftch_queue_full                  ,
        ch1_fetch_address           => ch1_fetch_address                    ,
        ch1_ftch_active             => ch1_ftch_active                      ,
        ch1_ftch_idle               => ch1_ftch_idle                        ,
        ch1_ftch_interr_set         => ch1_ftch_interr_set                  ,
        ch1_ftch_slverr_set         => ch1_ftch_slverr_set                  ,
        ch1_ftch_decerr_set         => ch1_ftch_decerr_set                  ,
        ch1_ftch_err_early          => ch1_ftch_err_early                   ,
        ch1_ftch_stale_desc         => ch1_ftch_stale_desc                  ,
        ch1_ftch_pause              => ch1_ftch_pause                       ,

        -- Channel 2 Control and Status
        ch2_run_stop                => ch2_run_stop                         ,
        ch2_updt_done               => ch2_updt_done                        ,
        ch2_desc_flush              => ch2_desc_flush                       ,
        ch2_sg_idle                 => ch2_sg_idle                          ,
        ch2_tailpntr_enabled        => ch2_tailpntr_enabled                 ,
        ch2_ftch_queue_empty        => ch2_ftch_queue_empty                 ,
        ch2_ftch_queue_full         => ch2_ftch_queue_full                  ,
        ch2_fetch_address           => ch2_fetch_address                    ,
        ch2_ftch_active             => ch2_ftch_active                      ,
        ch2_ftch_idle               => ch2_ftch_idle                        ,
        ch2_ftch_interr_set         => ch2_ftch_interr_set                  ,
        ch2_ftch_slverr_set         => ch2_ftch_slverr_set                  ,
        ch2_ftch_decerr_set         => ch2_ftch_decerr_set                  ,
        ch2_ftch_err_early          => ch2_ftch_err_early                   ,
        ch2_ftch_stale_desc         => ch2_ftch_stale_desc                  ,
        ch2_ftch_pause              => ch2_ftch_pause                       ,

        -- Transfer Request
        ftch_cmnd_wr                => ftch_cmnd_wr_i                       ,
        ftch_cmnd_data              => ftch_cmnd_data_i                     ,

        -- Transfer Status
        ftch_done                   => ftch_done                            ,
        ftch_error                  => ftch_error_i                         ,
        ftch_interr                 => ftch_interr                          ,
        ftch_slverr                 => ftch_slverr                          ,
        ftch_decerr                 => ftch_decerr                          ,
        ftch_stale_desc             => ftch_stale_desc                      ,
        ftch_error_addr             => ftch_error_addr                      ,
        ftch_error_early            => ftch_error_early
    );

-------------------------------------------------------------------------------
--  Scatter Gather Fetch Pointer Manager
-------------------------------------------------------------------------------
I_FTCH_PNTR_MNGR : entity  axi_vdma_v6_2.axi_sg_ftch_pntr
    generic map(
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                ,
        C_INCLUDE_CH1               => C_INCLUDE_CH1                        ,
        C_INCLUDE_CH2               => C_INCLUDE_CH2
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_sg_aresetn            => m_axi_sg_aresetn                     ,


        nxtdesc                     => nxtdesc                              ,

        -------------------------------
        -- CHANNEL 1
        -------------------------------
        ch1_run_stop                => ch1_run_stop                         ,
        ch1_desc_flush              => ch1_desc_flush                       ,--CR568950

        -- CURDESC update on run/stop assertion (from ftch_sm)
        ch1_curdesc                 => ch1_curdesc                          ,

        -- TAILDESC update on CPU write (from axi_dma_reg_module)
        ch1_tailpntr_enabled        => ch1_tailpntr_enabled                 ,
        ch1_taildesc_wren           => ch1_taildesc_wren                    ,
        ch1_taildesc                => ch1_taildesc                         ,

        -- NXTDESC update on descriptor fetch (from axi_sg_ftchq_if)
        ch1_nxtdesc_wren            => ch1_nxtdesc_wren                     ,

        -- Current address of descriptor to fetch
        ch1_fetch_address           => ch1_fetch_address                    ,
        ch1_sg_idle                 => ch1_sg_idle                          ,

        -------------------------------
        -- CHANNEL 2
        -------------------------------
        ch2_run_stop                => ch2_run_stop                         ,
        ch2_desc_flush              => ch2_desc_flush                       ,--CR568950

        -- CURDESC update on run/stop assertion (from ftch_sm)
        ch2_curdesc                 => ch2_curdesc                          ,

        -- TAILDESC update on CPU write (from axi_dma_reg_module)
        ch2_tailpntr_enabled        => ch2_tailpntr_enabled                 ,
        ch2_taildesc_wren           => ch2_taildesc_wren                    ,
        ch2_taildesc                => ch2_taildesc                         ,

        -- NXTDESC update on descriptor fetch (from axi_sg_ftchq_if)
        ch2_nxtdesc_wren            => ch2_nxtdesc_wren                     ,

        -- Current address of descriptor to fetch
        ch2_fetch_address           => ch2_fetch_address                    ,
        ch2_sg_idle                 => ch2_sg_idle
    );

-------------------------------------------------------------------------------
--  Scatter Gather Fetch Command / Status Interface
-------------------------------------------------------------------------------
I_FTCH_CMDSTS_IF : entity  axi_vdma_v6_2.axi_sg_ftch_cmdsts_if
    generic map(
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_sg_aresetn            => m_axi_sg_aresetn                     ,

        -- Fetch command write interface from fetch sm
        ftch_cmnd_wr                => ftch_cmnd_wr_i                       ,
        ftch_cmnd_data              => ftch_cmnd_data_i                     ,


        -- Read response for detecting slverr, decerr early
        m_axi_sg_rresp              => m_axi_sg_rresp                       ,
        m_axi_sg_rvalid             => m_axi_sg_rvalid                      ,

        -- User Command Interface Ports (AXI Stream)
        s_axis_ftch_cmd_tvalid      => s_axis_ftch_cmd_tvalid               ,
        s_axis_ftch_cmd_tready      => s_axis_ftch_cmd_tready               ,
        s_axis_ftch_cmd_tdata       => s_axis_ftch_cmd_tdata                ,

        -- User Status Interface Ports (AXI Stream)
        m_axis_ftch_sts_tvalid      => m_axis_ftch_sts_tvalid               ,
        m_axis_ftch_sts_tready      => m_axis_ftch_sts_tready               ,
        m_axis_ftch_sts_tdata       => m_axis_ftch_sts_tdata                ,
        m_axis_ftch_sts_tkeep       => m_axis_ftch_sts_tkeep                ,

        -- Scatter Gather Fetch Status
        mm2s_err                    => mm2s_err                             ,

        ftch_done                   => ftch_done                            ,
        ftch_error                  => ftch_error_i                         ,
        ftch_interr                 => ftch_interr                          ,
        ftch_slverr                 => ftch_slverr                          ,
        ftch_decerr                 => ftch_decerr                          ,
        ftch_error_early            => ftch_error_early
    );




end implementation;
