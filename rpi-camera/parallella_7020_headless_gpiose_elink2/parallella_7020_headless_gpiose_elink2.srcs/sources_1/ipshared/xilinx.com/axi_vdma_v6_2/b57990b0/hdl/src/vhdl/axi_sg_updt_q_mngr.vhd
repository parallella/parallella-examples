-------------------------------------------------------------------------------
-- axi_sg_updt_q_mngr
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
-- Filename:          axi_sg_updt_q_mngr.vhd
-- Description: This entity is the descriptor update queue manager
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
--  Created top level for descriptor update queue management
-- ~~~~~~
--  GAB     10/21/10    v4_03
-- ^^^^^^
--  Rolled version to v4_03
-- ~~~~~~
--  GAB     11/15/10    v2_01_a
-- ^^^^^^
--  CR582800
--  Converted all stream paraters ***_DATA_WIDTH to ***_TDATA_WIDTH
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

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_sg_pkg.all;

library lib_pkg_v1_0;
library lib_fifo_v1_0;
use lib_fifo_v1_0.sync_fifo_fg;
use lib_pkg_v1_0.lib_pkg.all;

-------------------------------------------------------------------------------
entity  axi_sg_updt_q_mngr is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64        := 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_M_AXI_SG_DATA_WIDTH       : integer range 32 to 32        := 32;
            -- Master AXI Memory Map Data Width for Scatter Gather R/W Port

        C_S_AXIS_UPDPTR_TDATA_WIDTH : integer range 32 to 32         := 32;
            -- 32 Update Status Bits

        C_S_AXIS_UPDSTS_TDATA_WIDTH : integer range 33 to 33         := 33;
            -- 1 IOC bit + 32 Update Status Bits

        C_SG_UPDT_DESC2QUEUE     : integer range 0 to 8             := 0;
            -- Number of descriptors to fetch and queue for each channel.
            -- A value of zero excludes the fetch queues.

        C_SG_CH1_WORDS_TO_UPDATE : integer range 1 to 16          := 8;
            -- Number of words to update

        C_SG_CH2_WORDS_TO_UPDATE : integer range 1 to 16          := 8;
            -- Number of words to update

        C_INCLUDE_CH1               : integer range 0 to 1          := 1;
            -- Include or Exclude channel 1 scatter gather engine
            -- 0 = Exclude Channel 1 SG Engine
            -- 1 = Include Channel 1 SG Engine

        C_INCLUDE_CH2               : integer range 0 to 1          := 1;
            -- Include or Exclude channel 2 scatter gather engine
            -- 0 = Exclude Channel 2 SG Engine
            -- 1 = Include Channel 2 SG Engine

        C_AXIS_IS_ASYNC             : integer range 0 to 1          := 0;
            -- Channel 1 is async to sg_aclk
            -- 0 = Synchronous to SG ACLK
            -- 1 = Asynchronous to SG ACLK

        C_FAMILY                    : string            := "virtex6"
            -- Device family used for proper BRAM selection
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;           --
        m_axi_sg_aresetn            : in  std_logic                         ;           --
                                                                                        --
        --***********************************--                                         --
        --** Channel 1 Control             **--                                         --
        --***********************************--                                         --
        ch1_updt_curdesc_wren       : out std_logic                         ;           --
        ch1_updt_curdesc            : out std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;           --
        ch1_updt_active             : in  std_logic                         ;           --
        ch1_updt_queue_empty        : out std_logic                         ;           --
        ch1_updt_ioc                : out std_logic                         ;           --
        ch1_updt_ioc_irq_set        : in  std_logic                         ;           --
                                                                                        --
        ch1_dma_interr              : out std_logic                         ;           --
        ch1_dma_slverr              : out std_logic                         ;           --
        ch1_dma_decerr              : out std_logic                         ;           --
        ch1_dma_interr_set          : in  std_logic                         ;           --
        ch1_dma_slverr_set          : in  std_logic                         ;           --
        ch1_dma_decerr_set          : in  std_logic                         ;           --
                                                                                        --
        --***********************************--                                         --
        --** Channel 2 Control             **--                                         --
        --***********************************--                                         --
        ch2_updt_active             : in  std_logic                         ;           --
        ch2_updt_curdesc_wren       : out std_logic                         ;           --
        ch2_updt_curdesc            : out std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;           --
        ch2_updt_queue_empty        : out std_logic                         ;           --
        ch2_updt_ioc                : out std_logic                         ;           --
        ch2_updt_ioc_irq_set        : in  std_logic                         ;           --
                                                                                        --
        ch2_dma_interr              : out std_logic                         ;           --
        ch2_dma_slverr              : out std_logic                         ;           --
        ch2_dma_decerr              : out std_logic                         ;           --
        ch2_dma_interr_set          : in  std_logic                         ;           --
        ch2_dma_slverr_set          : in  std_logic                         ;           --
        ch2_dma_decerr_set          : in  std_logic                         ;           --
                                                                                        --
        --***********************************--                                         --
        --** Channel 1 Update Interface In **--                                         --
        --***********************************--                                         --
        s_axis_ch1_updt_aclk        : in  std_logic                         ;           --
        -- Update Pointer Stream                                                        --
        s_axis_ch1_updtptr_tdata    : in  std_logic_vector                              --
                                        (C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0);       --
        s_axis_ch1_updtptr_tvalid   : in  std_logic                         ;           --
        s_axis_ch1_updtptr_tready   : out std_logic                         ;           --
        s_axis_ch1_updtptr_tlast    : in  std_logic                         ;           --
                                                                                        --
        -- Update Status Stream                                                         --
        s_axis_ch1_updtsts_tdata    : in  std_logic_vector                              --
                                        (C_S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0);       --
        s_axis_ch1_updtsts_tvalid   : in  std_logic                         ;           --
        s_axis_ch1_updtsts_tready   : out std_logic                         ;           --
        s_axis_ch1_updtsts_tlast    : in  std_logic                         ;           --
                                                                                        --
        --***********************************--                                         --
        --** Channel 2 Update Interface In **--                                         --
        --***********************************--                                         --
        s_axis_ch2_updt_aclk        : in  std_logic                         ;           --
        -- Update Pointer Stream                                                        --
        s_axis_ch2_updtptr_tdata    : in  std_logic_vector                              --
                                        (C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0);       --
        s_axis_ch2_updtptr_tvalid   : in  std_logic                         ;           --
        s_axis_ch2_updtptr_tready   : out std_logic                         ;           --
        s_axis_ch2_updtptr_tlast    : in  std_logic                         ;           --
                                                                                        --
        -- Update Status Stream                                                         --
        s_axis_ch2_updtsts_tdata    : in  std_logic_vector                              --
                                        (C_S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0);       --
        s_axis_ch2_updtsts_tvalid   : in  std_logic                         ;           --
        s_axis_ch2_updtsts_tready   : out std_logic                         ;           --
        s_axis_ch2_updtsts_tlast    : in  std_logic                         ;           --
                                                                                        --
        --***************************************--                                     --
        --** Update Interface to AXI DataMover **--                                     --
        --***************************************--                                     --
        -- S2MM Stream Out To DataMover                                                 --
        s_axis_s2mm_tdata           : out std_logic_vector                              --
                                        (C_M_AXI_SG_DATA_WIDTH-1 downto 0)  ;           --
        s_axis_s2mm_tlast           : out std_logic                         ;           --
        s_axis_s2mm_tvalid          : out std_logic                         ;           --
        s_axis_s2mm_tready          : in  std_logic                                     --


    );

end axi_sg_updt_q_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_updt_q_mngr is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal m_axis_ch1_updt_tdata            : std_logic_vector(C_M_AXI_SG_DATA_WIDTH-1 downto 0) := (others => '0');
signal m_axis_ch1_updt_tlast            : std_logic := '0';
signal m_axis_ch1_updt_tvalid           : std_logic := '0';
signal m_axis_ch1_updt_tready           : std_logic := '0';

signal m_axis_ch2_updt_tdata            : std_logic_vector(C_M_AXI_SG_DATA_WIDTH-1 downto 0) := (others => '0');
signal m_axis_ch2_updt_tlast            : std_logic := '0';
signal m_axis_ch2_updt_tvalid           : std_logic := '0';
signal m_axis_ch2_updt_tready           : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

--*****************************************************************************
--**                                CHANNEL 1                                **
--*****************************************************************************
-------------------------------------------------------------------------------
-- If Channel 1 is enabled then instantiate descriptor update logic.
-------------------------------------------------------------------------------
GEN_CH1_UPDATE_Q_IF : if C_INCLUDE_CH1 = 1 generate
begin

--*****************************************************************************
--**                        CHANNEL 1 - DESCRIPTOR QUEUE                     **
--*****************************************************************************
    -- If Descriptor Update queueing enabled then instantiate Queue Logic
    GEN_CH1_QUEUE : if  C_SG_UPDT_DESC2QUEUE  /= 0 generate
    begin
        -------------------------------------------------------------------------------
        I_CH1_UPDT_DESC_QUEUE : entity  axi_vdma_v6_2.axi_sg_updt_queue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                ,
                C_M_AXIS_UPDT_DATA_WIDTH    => C_M_AXI_SG_DATA_WIDTH                ,
                C_S_AXIS_UPDPTR_TDATA_WIDTH => C_S_AXIS_UPDPTR_TDATA_WIDTH          ,
                C_S_AXIS_UPDSTS_TDATA_WIDTH => C_S_AXIS_UPDSTS_TDATA_WIDTH          ,
                C_SG_UPDT_DESC2QUEUE        => C_SG_UPDT_DESC2QUEUE                 ,
                C_SG_WORDS_TO_UPDATE        => C_SG_CH1_WORDS_TO_UPDATE             ,
                C_AXIS_IS_ASYNC             => C_AXIS_IS_ASYNC                      ,
                C_FAMILY                    => C_FAMILY
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                        ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn                     ,
                s_axis_updt_aclk            => s_axis_ch1_updt_aclk                 ,

                --********************************--
                --** Control and Status         **--
                --********************************--
                updt_curdesc_wren           => ch1_updt_curdesc_wren                ,
                updt_curdesc                => ch1_updt_curdesc                     ,
                updt_active                 => ch1_updt_active                      ,
                updt_queue_empty            => ch1_updt_queue_empty                 ,
                updt_ioc                    => ch1_updt_ioc                         ,
                updt_ioc_irq_set            => ch1_updt_ioc_irq_set                 ,

                dma_interr                  => ch1_dma_interr                       ,
                dma_slverr                  => ch1_dma_slverr                       ,
                dma_decerr                  => ch1_dma_decerr                       ,
                dma_interr_set              => ch1_dma_interr_set                   ,
                dma_slverr_set              => ch1_dma_slverr_set                   ,
                dma_decerr_set              => ch1_dma_decerr_set                   ,

                --********************************--
                --** Update Interfaces In       **--
                --********************************--
                -- Update Pointer Stream
                s_axis_updtptr_tdata        => s_axis_ch1_updtptr_tdata             ,
                s_axis_updtptr_tvalid       => s_axis_ch1_updtptr_tvalid            ,
                s_axis_updtptr_tready       => s_axis_ch1_updtptr_tready            ,
                s_axis_updtptr_tlast        => s_axis_ch1_updtptr_tlast             ,

                -- Update Status Stream
                s_axis_updtsts_tdata        => s_axis_ch1_updtsts_tdata             ,
                s_axis_updtsts_tvalid       => s_axis_ch1_updtsts_tvalid            ,
                s_axis_updtsts_tready       => s_axis_ch1_updtsts_tready            ,
                s_axis_updtsts_tlast        => s_axis_ch1_updtsts_tlast             ,

                --********************************--
                --** Update Interfaces Out      **--
                --********************************--
                -- S2MM Stream Out To DataMover
                m_axis_updt_tdata           => m_axis_ch1_updt_tdata                ,
                m_axis_updt_tlast           => m_axis_ch1_updt_tlast                ,
                m_axis_updt_tvalid          => m_axis_ch1_updt_tvalid               ,
                m_axis_updt_tready          => m_axis_ch1_updt_tready
            );
    end generate GEN_CH1_QUEUE;


--*****************************************************************************
--**                        CHANNEL 1 - NO DESCRIPTOR QUEUE                  **
--*****************************************************************************
    -- No update queue enabled, therefore map internal stream logic
    -- directly to channel port.
    GEN_CH1_NO_QUEUE : if C_SG_UPDT_DESC2QUEUE = 0 generate
    begin

        I_NO_CH1_UPDT_DESC_QUEUE : entity  axi_vdma_v6_2.axi_sg_updt_noqueue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH                ,
                C_M_AXIS_UPDT_DATA_WIDTH    => C_M_AXI_SG_DATA_WIDTH                ,
                C_S_AXIS_UPDPTR_TDATA_WIDTH => C_S_AXIS_UPDPTR_TDATA_WIDTH          ,
                C_S_AXIS_UPDSTS_TDATA_WIDTH  => C_S_AXIS_UPDSTS_TDATA_WIDTH
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                        ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn                     ,

                --********************************--
                --** Control and Status         **--
                --********************************--
                updt_curdesc_wren           => ch1_updt_curdesc_wren                ,
                updt_curdesc                => ch1_updt_curdesc                     ,
                updt_active                 => ch1_updt_active                      ,
                updt_queue_empty            => ch1_updt_queue_empty                 ,
                updt_ioc                    => ch1_updt_ioc                         ,
                updt_ioc_irq_set            => ch1_updt_ioc_irq_set                 ,

                dma_interr                  => ch1_dma_interr                       ,
                dma_slverr                  => ch1_dma_slverr                       ,
                dma_decerr                  => ch1_dma_decerr                       ,
                dma_interr_set              => ch1_dma_interr_set                   ,
                dma_slverr_set              => ch1_dma_slverr_set                   ,
                dma_decerr_set              => ch1_dma_decerr_set                   ,

                --********************************--
                --** Update Interfaces In       **--
                --********************************--
                -- Update Pointer Stream
                s_axis_updtptr_tdata        => s_axis_ch1_updtptr_tdata             ,
                s_axis_updtptr_tvalid       => s_axis_ch1_updtptr_tvalid            ,
                s_axis_updtptr_tready       => s_axis_ch1_updtptr_tready            ,
                s_axis_updtptr_tlast        => s_axis_ch1_updtptr_tlast             ,

                -- Update Status Stream
                s_axis_updtsts_tdata        => s_axis_ch1_updtsts_tdata             ,
                s_axis_updtsts_tvalid       => s_axis_ch1_updtsts_tvalid            ,
                s_axis_updtsts_tready       => s_axis_ch1_updtsts_tready            ,
                s_axis_updtsts_tlast        => s_axis_ch1_updtsts_tlast             ,

                --********************************--
                --** Update Interfaces Out      **--
                --********************************--
                -- S2MM Stream Out To DataMover
                m_axis_updt_tdata           => m_axis_ch1_updt_tdata                ,
                m_axis_updt_tlast           => m_axis_ch1_updt_tlast                ,
                m_axis_updt_tvalid          => m_axis_ch1_updt_tvalid               ,
                m_axis_updt_tready          => m_axis_ch1_updt_tready
            );

    end generate GEN_CH1_NO_QUEUE;


end generate GEN_CH1_UPDATE_Q_IF;


-- Channel 1 NOT included therefore tie ch1 outputs off
GEN_NO_CH1_UPDATE_Q_IF : if C_INCLUDE_CH1 = 0 generate
begin
    ch1_updt_curdesc_wren       <= '0';
    ch1_updt_curdesc            <= (others => '0');
    ch1_updt_queue_empty        <= '1';

    ch1_updt_ioc                <= '0';
    ch1_dma_interr              <= '0';
    ch1_dma_slverr              <= '0';
    ch1_dma_decerr              <= '0';

    m_axis_ch1_updt_tdata       <= (others => '0');
    m_axis_ch1_updt_tlast       <= '0';
    m_axis_ch1_updt_tvalid      <= '0';

    s_axis_ch1_updtptr_tready   <= '0';
    s_axis_ch1_updtsts_tready   <= '0';

end generate GEN_NO_CH1_UPDATE_Q_IF;

--*****************************************************************************
--**                                CHANNEL 2                                **
--*****************************************************************************
-------------------------------------------------------------------------------
-- If Channel 2 is enabled then instantiate descriptor update logic.
-------------------------------------------------------------------------------
GEN_CH2_UPDATE_Q_IF : if C_INCLUDE_CH2 = 1 generate

begin

    --*************************************************************************
    --**                        CHANNEL 2 - DESCRIPTOR QUEUE                 **
    --*************************************************************************
    -- If Descriptor Update queueing enabled then instantiate Queue Logic
    GEN_CH2_QUEUE : if  C_SG_UPDT_DESC2QUEUE  /= 0 generate
    begin
    ---------------------------------------------------------------------------
        I_CH2_UPDT_DESC_QUEUE : entity  axi_vdma_v6_2.axi_sg_updt_queue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH        ,
                C_M_AXIS_UPDT_DATA_WIDTH    => C_M_AXI_SG_DATA_WIDTH        ,
                C_S_AXIS_UPDPTR_TDATA_WIDTH => C_S_AXIS_UPDPTR_TDATA_WIDTH  ,
                C_S_AXIS_UPDSTS_TDATA_WIDTH => C_S_AXIS_UPDSTS_TDATA_WIDTH  ,
                C_SG_UPDT_DESC2QUEUE        => C_SG_UPDT_DESC2QUEUE         ,
                C_SG_WORDS_TO_UPDATE        => C_SG_CH2_WORDS_TO_UPDATE     ,
                C_FAMILY                    => C_FAMILY
            )
            port map(
                ---------------------------------------------------------------
                -- AXI Scatter Gather Interface
                ---------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn             ,
                s_axis_updt_aclk            => s_axis_ch2_updt_aclk         ,

                --********************************--
                --** Control and Status         **--
                --********************************--
                updt_curdesc_wren           => ch2_updt_curdesc_wren        ,
                updt_curdesc                => ch2_updt_curdesc             ,
                updt_active                 => ch2_updt_active              ,
                updt_queue_empty            => ch2_updt_queue_empty         ,
                updt_ioc                    => ch2_updt_ioc                 ,
                updt_ioc_irq_set            => ch2_updt_ioc_irq_set         ,

                dma_interr                  => ch2_dma_interr               ,
                dma_slverr                  => ch2_dma_slverr               ,
                dma_decerr                  => ch2_dma_decerr               ,
                dma_interr_set              => ch2_dma_interr_set           ,
                dma_slverr_set              => ch2_dma_slverr_set           ,
                dma_decerr_set              => ch2_dma_decerr_set           ,

                --********************************--
                --** Update Interfaces In       **--
                --********************************--
                -- Update Pointer Stream
                s_axis_updtptr_tdata        => s_axis_ch2_updtptr_tdata     ,
                s_axis_updtptr_tvalid       => s_axis_ch2_updtptr_tvalid    ,
                s_axis_updtptr_tready       => s_axis_ch2_updtptr_tready    ,
                s_axis_updtptr_tlast        => s_axis_ch2_updtptr_tlast     ,

                -- Update Status Stream
                s_axis_updtsts_tdata        => s_axis_ch2_updtsts_tdata     ,
                s_axis_updtsts_tvalid       => s_axis_ch2_updtsts_tvalid    ,
                s_axis_updtsts_tready       => s_axis_ch2_updtsts_tready    ,
                s_axis_updtsts_tlast        => s_axis_ch2_updtsts_tlast     ,

                --********************************--
                --** Update Interfaces Out      **--
                --********************************--
                -- S2MM Stream Out To DataMover
                m_axis_updt_tdata           => m_axis_ch2_updt_tdata        ,
                m_axis_updt_tlast           => m_axis_ch2_updt_tlast        ,
                m_axis_updt_tvalid          => m_axis_ch2_updt_tvalid       ,
                m_axis_updt_tready          => m_axis_ch2_updt_tready
            );

    end generate GEN_CH2_QUEUE;


    --*****************************************************************************
    --**                        CHANNEL 2 - NO DESCRIPTOR QUEUE                  **
    --*****************************************************************************

    -- No update queue enabled, therefore map internal stream logic
    -- directly to channel port.
    GEN_CH2_NO_QUEUE : if C_SG_UPDT_DESC2QUEUE = 0 generate
        I_NO_CH2_UPDT_DESC_QUEUE : entity  axi_vdma_v6_2.axi_sg_updt_noqueue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH        ,
                C_M_AXIS_UPDT_DATA_WIDTH    => C_M_AXI_SG_DATA_WIDTH        ,
                C_S_AXIS_UPDPTR_TDATA_WIDTH => C_S_AXIS_UPDPTR_TDATA_WIDTH  ,
                C_S_AXIS_UPDSTS_TDATA_WIDTH => C_S_AXIS_UPDSTS_TDATA_WIDTH
            )
            port map(
                ---------------------------------------------------------------
                -- AXI Scatter Gather Interface
                ---------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn             => m_axi_sg_aresetn              ,

                --********************************--
                --** Control and Status         **--
                --********************************--
                updt_curdesc_wren           => ch2_updt_curdesc_wren        ,
                updt_curdesc                => ch2_updt_curdesc             ,
                updt_active                 => ch2_updt_active              ,
                updt_queue_empty            => ch2_updt_queue_empty         ,
                updt_ioc                    => ch2_updt_ioc                 ,
                updt_ioc_irq_set            => ch2_updt_ioc_irq_set         ,

                dma_interr                  => ch2_dma_interr               ,
                dma_slverr                  => ch2_dma_slverr               ,
                dma_decerr                  => ch2_dma_decerr               ,
                dma_interr_set              => ch2_dma_interr_set           ,
                dma_slverr_set              => ch2_dma_slverr_set           ,
                dma_decerr_set              => ch2_dma_decerr_set           ,

                --********************************--
                --** Update Interfaces In       **--
                --********************************--
                -- Update Pointer Stream
                s_axis_updtptr_tdata        => s_axis_ch2_updtptr_tdata     ,
                s_axis_updtptr_tvalid       => s_axis_ch2_updtptr_tvalid    ,
                s_axis_updtptr_tready       => s_axis_ch2_updtptr_tready    ,
                s_axis_updtptr_tlast        => s_axis_ch2_updtptr_tlast     ,

                -- Update Status Stream
                s_axis_updtsts_tdata        => s_axis_ch2_updtsts_tdata     ,
                s_axis_updtsts_tvalid       => s_axis_ch2_updtsts_tvalid    ,
                s_axis_updtsts_tready       => s_axis_ch2_updtsts_tready    ,
                s_axis_updtsts_tlast        => s_axis_ch2_updtsts_tlast     ,

                --********************************--
                --** Update Interfaces Out      **--
                --********************************--
                -- S2MM Stream Out To DataMover
                m_axis_updt_tdata           => m_axis_ch2_updt_tdata        ,
                m_axis_updt_tlast           => m_axis_ch2_updt_tlast        ,
                m_axis_updt_tvalid          => m_axis_ch2_updt_tvalid       ,
                m_axis_updt_tready          => m_axis_ch2_updt_tready
            );

    end generate GEN_CH2_NO_QUEUE;

end generate GEN_CH2_UPDATE_Q_IF;

-- Channel 2 NOT included therefore tie ch2 outputs off
GEN_NO_CH2_UPDATE_Q_IF : if C_INCLUDE_CH2 = 0 generate
begin
    ch2_updt_curdesc_wren       <= '0';
    ch2_updt_curdesc            <= (others => '0');
    ch2_updt_queue_empty        <= '1';

    ch2_updt_ioc                <= '0';
    ch2_dma_interr              <= '0';
    ch2_dma_slverr              <= '0';
    ch2_dma_decerr              <= '0';

    m_axis_ch2_updt_tdata       <= (others => '0');
    m_axis_ch2_updt_tlast       <= '0';
    m_axis_ch2_updt_tvalid      <= '0';

    s_axis_ch2_updtptr_tready   <= '0';
    s_axis_ch2_updtsts_tready   <= '0';

end generate GEN_NO_CH2_UPDATE_Q_IF;

-------------------------------------------------------------------------------
-- MUX For DataMover
-------------------------------------------------------------------------------
TO_DATAMVR_MUX : process(ch1_updt_active,
                         ch2_updt_active,
                         m_axis_ch1_updt_tdata,
                         m_axis_ch1_updt_tlast,
                         m_axis_ch1_updt_tvalid,
                         m_axis_ch2_updt_tdata,
                         m_axis_ch2_updt_tlast,
                         m_axis_ch2_updt_tvalid)
    begin
        if(ch1_updt_active = '1')then
            s_axis_s2mm_tdata   <= m_axis_ch1_updt_tdata;
            s_axis_s2mm_tlast   <= m_axis_ch1_updt_tlast;
            s_axis_s2mm_tvalid  <= m_axis_ch1_updt_tvalid;
        elsif(ch2_updt_active = '1')then
            s_axis_s2mm_tdata   <= m_axis_ch2_updt_tdata;
            s_axis_s2mm_tlast   <= m_axis_ch2_updt_tlast;
            s_axis_s2mm_tvalid  <= m_axis_ch2_updt_tvalid;
        else
            s_axis_s2mm_tdata   <= (others => '0');
            s_axis_s2mm_tlast   <= '0';
            s_axis_s2mm_tvalid  <= '0';
        end if;
    end process TO_DATAMVR_MUX;

m_axis_ch1_updt_tready <= s_axis_s2mm_tready;
m_axis_ch2_updt_tready <= s_axis_s2mm_tready;


end implementation;
