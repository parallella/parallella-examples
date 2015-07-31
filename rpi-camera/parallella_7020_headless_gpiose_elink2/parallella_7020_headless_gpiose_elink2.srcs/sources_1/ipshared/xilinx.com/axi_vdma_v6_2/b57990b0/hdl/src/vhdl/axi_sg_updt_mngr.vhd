-------------------------------------------------------------------------------
-- axi_sg_updt_mngr
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
-- Filename:          axi_sg_updt_mngr.vhd
-- Description: This entity manages updating of descriptors.
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
entity  axi_sg_updt_mngr is
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

        C_SG_CH1_WORDS_TO_UPDATE    : integer range 1 to 16     := 8;
            -- Number of words to fetch for channel 1

        C_SG_CH1_FIRST_UPDATE_WORD     : integer range 0 to 15  := 0;
            -- Starting update word offset

        C_SG_CH2_WORDS_TO_UPDATE    : integer range 1 to 16     := 8;
            -- Number of words to fetch for channel 1

        C_SG_CH2_FIRST_UPDATE_WORD     : integer range 0 to 15  := 0
            -- Starting update word offset


    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
                                                                                                --
        -- Channel 1 Control and Status                                                         --
        ch1_updt_queue_empty        : in  std_logic                         ;                   --
        ch1_updt_curdesc_wren       : in  std_logic                         ;                   --
        ch1_updt_curdesc            : in  std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        ch1_updt_ioc                : in  std_logic                         ;                   --
        ch1_updt_idle               : out std_logic                         ;                   --
        ch1_updt_active             : out std_logic                         ;                   --
        ch1_updt_ioc_irq_set        : out std_logic                         ;                   --
        ch1_updt_interr_set         : out std_logic                         ;                   --
        ch1_updt_slverr_set         : out std_logic                         ;                   --
        ch1_updt_decerr_set         : out std_logic                         ;                   --
        ch1_dma_interr              : in  std_logic                         ;                   --
        ch1_dma_slverr              : in  std_logic                         ;                   --
        ch1_dma_decerr              : in  std_logic                         ;                   --
        ch1_dma_interr_set          : out std_logic                         ;                   --
        ch1_dma_slverr_set          : out std_logic                         ;                   --
        ch1_dma_decerr_set          : out std_logic                         ;                   --
        ch1_updt_done               : out std_logic                         ;                   --
                                                                                                --
        -- Channel 2 Control and Status                                                         --
        ch2_updt_queue_empty        : in  std_logic                         ;                   --
        ch2_updt_curdesc_wren       : in  std_logic                         ;                   --
        ch2_updt_curdesc            : in  std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        ch2_updt_ioc                : in  std_logic                         ;                   --
        ch2_updt_idle               : out std_logic                         ;                   --
        ch2_updt_active             : out std_logic                         ;                   --
        ch2_updt_ioc_irq_set        : out std_logic                         ;                   --
        ch2_updt_interr_set         : out std_logic                         ;                   --
        ch2_updt_slverr_set         : out std_logic                         ;                   --
        ch2_updt_decerr_set         : out std_logic                         ;                   --
        ch2_dma_interr              : in  std_logic                         ;                   --
        ch2_dma_slverr              : in  std_logic                         ;                   --
        ch2_dma_decerr              : in  std_logic                         ;                   --
        ch2_dma_interr_set          : out std_logic                         ;                   --
        ch2_dma_slverr_set          : out std_logic                         ;                   --
        ch2_dma_decerr_set          : out std_logic                         ;                   --
        ch2_updt_done               : out std_logic                         ;                   --
                                                                                                --
        -- User Command Interface Ports (AXI Stream)                                            --
        s_axis_updt_cmd_tvalid      : out std_logic                         ;                   --
        s_axis_updt_cmd_tready      : in  std_logic                         ;                   --
        s_axis_updt_cmd_tdata       : out std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
                                                                                                --
        -- User Status Interface Ports (AXI Stream)                                             --
        m_axis_updt_sts_tvalid      : in  std_logic                         ;                   --
        m_axis_updt_sts_tready      : out std_logic                         ;                   --
        m_axis_updt_sts_tdata       : in  std_logic_vector(7 downto 0)      ;                   --
        m_axis_updt_sts_tkeep       : in  std_logic_vector(0 downto 0)      ;                   --
        s2mm_err                    : in  std_logic                         ;                   --
                                                                                                --
        ftch_error                  : in  std_logic                         ;                   --
        updt_error                  : out std_logic                         ;                   --
        updt_error_addr             : out std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)                      --

    );

end axi_sg_updt_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_updt_mngr is
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
signal updt_cmnd_wr                 : std_logic := '0';
signal updt_cmnd_data               : std_logic_vector
                                        ((C_M_AXI_SG_ADDR_WIDTH
                                         +CMD_BASE_WIDTH)-1 downto 0)
                                        := (others => '0');

signal updt_done                    : std_logic := '0';
signal updt_error_i                 : std_logic := '0';
signal updt_interr                  : std_logic := '0';
signal updt_slverr                  : std_logic := '0';
signal updt_decerr                  : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
updt_error      <= updt_error_i;


-------------------------------------------------------------------------------
--  Scatter Gather Fetch State Machine
-------------------------------------------------------------------------------
I_UPDT_SG : entity  axi_vdma_v6_2.axi_sg_updt_sm
    generic map(
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                ,
        C_INCLUDE_CH1               => C_INCLUDE_CH1                        ,
        C_INCLUDE_CH2               => C_INCLUDE_CH2                        ,
        C_SG_CH1_WORDS_TO_UPDATE    => C_SG_CH1_WORDS_TO_UPDATE             ,
        C_SG_CH2_WORDS_TO_UPDATE    => C_SG_CH2_WORDS_TO_UPDATE             ,
        C_SG_CH1_FIRST_UPDATE_WORD  => C_SG_CH1_FIRST_UPDATE_WORD           ,
        C_SG_CH2_FIRST_UPDATE_WORD  => C_SG_CH2_FIRST_UPDATE_WORD
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_sg_aresetn             => m_axi_sg_aresetn                      ,

        ftch_error                  => ftch_error                           ,

        -- Channel 1 Control and Status
        ch1_updt_queue_empty        => ch1_updt_queue_empty                 ,
        ch1_updt_active             => ch1_updt_active                      ,
        ch1_updt_idle               => ch1_updt_idle                        ,
        ch1_updt_ioc                => ch1_updt_ioc                         ,
        ch1_updt_ioc_irq_set        => ch1_updt_ioc_irq_set                 ,
        ch1_dma_interr              => ch1_dma_interr                       ,
        ch1_dma_slverr              => ch1_dma_slverr                       ,
        ch1_dma_decerr              => ch1_dma_decerr                       ,
        ch1_dma_interr_set          => ch1_dma_interr_set                   ,
        ch1_dma_slverr_set          => ch1_dma_slverr_set                   ,
        ch1_dma_decerr_set          => ch1_dma_decerr_set                   ,
        ch1_updt_interr_set         => ch1_updt_interr_set                  ,
        ch1_updt_slverr_set         => ch1_updt_slverr_set                  ,
        ch1_updt_decerr_set         => ch1_updt_decerr_set                  ,
        ch1_updt_curdesc_wren       => ch1_updt_curdesc_wren                ,
        ch1_updt_curdesc            => ch1_updt_curdesc                     ,
        ch1_updt_done               => ch1_updt_done                        ,

        -- Channel 2 Control and Status
        ch2_updt_queue_empty        => ch2_updt_queue_empty                 ,
        ch2_updt_active             => ch2_updt_active                      ,
        ch2_updt_idle               => ch2_updt_idle                        ,
        ch2_updt_ioc                => ch2_updt_ioc                         ,
        ch2_updt_ioc_irq_set        => ch2_updt_ioc_irq_set                 ,
        ch2_dma_interr              => ch2_dma_interr                       ,
        ch2_dma_slverr              => ch2_dma_slverr                       ,
        ch2_dma_decerr              => ch2_dma_decerr                       ,
        ch2_dma_interr_set          => ch2_dma_interr_set                   ,
        ch2_dma_slverr_set          => ch2_dma_slverr_set                   ,
        ch2_dma_decerr_set          => ch2_dma_decerr_set                   ,
        ch2_updt_interr_set         => ch2_updt_interr_set                  ,
        ch2_updt_slverr_set         => ch2_updt_slverr_set                  ,
        ch2_updt_decerr_set         => ch2_updt_decerr_set                  ,
        ch2_updt_curdesc_wren       => ch2_updt_curdesc_wren                ,
        ch2_updt_curdesc            => ch2_updt_curdesc                     ,
        ch2_updt_done               => ch2_updt_done                        ,

        -- DataMover Command
        updt_cmnd_wr                => updt_cmnd_wr                         ,
        updt_cmnd_data              => updt_cmnd_data                       ,

        -- DataMover Status
        updt_done                   => updt_done                            ,
        updt_error                  => updt_error_i                         ,
        updt_interr                 => updt_interr                          ,
        updt_slverr                 => updt_slverr                          ,
        updt_decerr                 => updt_decerr                          ,
        updt_error_addr             => updt_error_addr

    );


-------------------------------------------------------------------------------
--  Scatter Gather Fetch Command / Status Interface
-------------------------------------------------------------------------------
I_UPDT_CMDSTS_IF : entity  axi_vdma_v6_2.axi_sg_updt_cmdsts_if
    generic map(
        C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH
    )
    port map(
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               => m_axi_sg_aclk                        ,
        m_axi_sg_aresetn             => m_axi_sg_aresetn                      ,

        -- Fetch command write interface from fetch sm
        updt_cmnd_wr                => updt_cmnd_wr                         ,
        updt_cmnd_data              => updt_cmnd_data                       ,

        -- User Command Interface Ports (AXI Stream)
        s_axis_updt_cmd_tvalid      => s_axis_updt_cmd_tvalid               ,
        s_axis_updt_cmd_tready      => s_axis_updt_cmd_tready               ,
        s_axis_updt_cmd_tdata       => s_axis_updt_cmd_tdata                ,

        -- User Status Interface Ports (AXI Stream)
        m_axis_updt_sts_tvalid      => m_axis_updt_sts_tvalid               ,
        m_axis_updt_sts_tready      => m_axis_updt_sts_tready               ,
        m_axis_updt_sts_tdata       => m_axis_updt_sts_tdata                ,
        m_axis_updt_sts_tkeep       => m_axis_updt_sts_tkeep                ,

        -- Scatter Gather Fetch Status
        s2mm_err                    => s2mm_err                             ,

        updt_done                   => updt_done                            ,
        updt_error                  => updt_error_i                         ,
        updt_interr                 => updt_interr                          ,
        updt_slverr                 => updt_slverr                          ,
        updt_decerr                 => updt_decerr
    );




end implementation;
