-------------------------------------------------------------------------------
-- axi_sg_ftchq_if
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
-- Filename:          axi_sg_updt_queue.vhd
-- Description: This entity is the descriptor fetch queue interface
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
--  Seperated update queues into two seperate files, no queue and queue to
--  simplify maintainance.
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
entity  axi_sg_updt_queue is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64        := 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_M_AXIS_UPDT_DATA_WIDTH    : integer range 32 to 32        := 32;
            -- Master AXI Memory Map Data Width for Scatter Gather R/W Port

        C_S_AXIS_UPDPTR_TDATA_WIDTH  : integer range 32 to 32        := 32;
            -- 32 Update Status Bits

        C_S_AXIS_UPDSTS_TDATA_WIDTH  : integer range 33 to 33        := 33;
            -- 1 IOC bit + 32 Update Status Bits

        C_SG_UPDT_DESC2QUEUE        : integer range 0 to 8          := 0;
            -- Number of descriptors to fetch and queue for each channel.
            -- A value of zero excludes the fetch queues.

        C_SG_WORDS_TO_UPDATE        : integer range 1 to 16         := 8;
            -- Number of words to update

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
        m_axi_sg_aclk               : in  std_logic                         ;              --
        m_axi_sg_aresetn            : in  std_logic                         ;              --
        s_axis_updt_aclk            : in  std_logic                         ;              --
                                                                                           --
        --********************************--                                               --
        --** Control and Status         **--                                               --
        --********************************--                                               --
        updt_curdesc_wren           : out std_logic                         ;              --
        updt_curdesc                : out std_logic_vector                                 --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;              --
        updt_active                 : in  std_logic                         ;              --
        updt_queue_empty            : out std_logic                         ;              --
        updt_ioc                    : out std_logic                         ;              --
        updt_ioc_irq_set            : in  std_logic                         ;              --
                                                                                           --
        dma_interr                  : out std_logic                         ;              --
        dma_slverr                  : out std_logic                         ;              --
        dma_decerr                  : out std_logic                         ;              --
        dma_interr_set              : in  std_logic                         ;              --
        dma_slverr_set              : in  std_logic                         ;              --
        dma_decerr_set              : in  std_logic                         ;              --
                                                                                           --
        --********************************--                                               --
        --** Update Interfaces In       **--                                               --
        --********************************--                                               --
        -- Update Pointer Stream                                                           --
        s_axis_updtptr_tdata        : in  std_logic_vector                                 --
                                        (C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0);          --
        s_axis_updtptr_tvalid       : in  std_logic                         ;              --
        s_axis_updtptr_tready       : out std_logic                         ;              --
        s_axis_updtptr_tlast        : in  std_logic                         ;              --
                                                                                           --
        -- Update Status Stream                                                            --
        s_axis_updtsts_tdata        : in  std_logic_vector                                 --
                                        (C_S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0);           --
        s_axis_updtsts_tvalid       : in  std_logic                         ;              --
        s_axis_updtsts_tready       : out std_logic                         ;              --
        s_axis_updtsts_tlast        : in  std_logic                         ;              --
                                                                                           --
        --********************************--                                               --
        --** Update Interfaces Out      **--                                               --
        --********************************--                                               --
        -- S2MM Stream Out To DataMover                                                    --
        m_axis_updt_tdata           : out std_logic_vector                                 --
                                        (C_M_AXIS_UPDT_DATA_WIDTH-1 downto 0);             --
        m_axis_updt_tlast           : out std_logic                         ;              --
        m_axis_updt_tvalid          : out std_logic                         ;              --
        m_axis_updt_tready          : in  std_logic                                        --
    );

end axi_sg_updt_queue;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_updt_queue is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
constant USE_LOGIC_FIFOS            : integer   := 0; -- Use Logic FIFOs
constant USE_BRAM_FIFOS             : integer   := 1; -- Use BRAM FIFOs

-- Number of words deep fifo needs to be. Depth required to store 2 word
-- porters for each descriptor is C_SG_UPDT_DESC2QUEUE x 2
--constant UPDATE_QUEUE_DEPTH         : integer := max2(16,C_SG_UPDT_DESC2QUEUE * 2);
constant UPDATE_QUEUE_DEPTH         : integer := max2(16,pad_power2(C_SG_UPDT_DESC2QUEUE * 2));



-- Width of fifo rd and wr counts - only used for proper fifo operation
constant UPDATE_QUEUE_CNT_WIDTH     : integer   := clog2(UPDATE_QUEUE_DEPTH+1);

-- Select between BRAM or LOGIC memory type
constant UPD_Q_MEMORY_TYPE          : integer := bo2int(UPDATE_QUEUE_DEPTH > 16);

-- Number of words deep fifo needs to be. Depth required to store all update
-- words is C_SG_UPDT_DESC2QUEUE x C_SG_WORDS_TO_UPDATE
constant UPDATE_STS_QUEUE_DEPTH     : integer := max2(16,pad_power2(C_SG_UPDT_DESC2QUEUE
                                                    * C_SG_WORDS_TO_UPDATE));
-- Select between BRAM or LOGIC memory type
constant STS_Q_MEMORY_TYPE          : integer := bo2int(UPDATE_STS_QUEUE_DEPTH > 16);

-- Width of fifo rd and wr counts - only used for proper fifo operation
constant UPDATE_STS_QUEUE_CNT_WIDTH : integer := clog2(C_SG_UPDT_DESC2QUEUE+1);

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- Channel signals
signal write_curdesc_lsb    : std_logic := '0';
signal write_curdesc_msb    : std_logic := '0';
signal updt_active_d1       : std_logic := '0';
signal updt_active_re       : std_logic := '0';


type PNTR_STATE_TYPE      is (IDLE,
                              READ_CURDESC_LSB,
                              READ_CURDESC_MSB,
                              WRITE_STATUS
                              );

signal pntr_cs              : PNTR_STATE_TYPE;
signal pntr_ns              : PNTR_STATE_TYPE;

-- State Machine Signal
signal writing_status       : std_logic := '0';
signal dataq_rden           : std_logic := '0';
signal stsq_rden            : std_logic := '0';

-- Pointer Queue FIFO Signals
signal ptr_queue_rden       : std_logic := '0';
signal ptr_queue_wren       : std_logic := '0';
signal ptr_queue_empty      : std_logic := '0';
signal ptr_queue_full       : std_logic := '0';
signal ptr_queue_din        : std_logic_vector
                                (C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0) := (others => '0');
signal ptr_queue_dout       : std_logic_vector
                                (C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0) := (others => '0');

-- Status Queue FIFO Signals
signal sts_queue_wren       : std_logic := '0';
signal sts_queue_rden       : std_logic := '0';
signal sts_queue_din        : std_logic_vector
                                (C_S_AXIS_UPDSTS_TDATA_WIDTH downto 0) := (others => '0');
signal sts_queue_dout       : std_logic_vector
                                (C_S_AXIS_UPDSTS_TDATA_WIDTH downto 0) := (others => '0');
signal sts_queue_full       : std_logic := '0';
signal sts_queue_empty      : std_logic := '0';

-- Misc Support Signals
signal writing_status_d1    : std_logic := '0';
signal writing_status_re    : std_logic := '0';
signal sinit                : std_logic := '0';
signal updt_tvalid          : std_logic := '0';
signal updt_tlast           : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
    -- Asset active strobe on rising edge of update active
    -- asertion.  This kicks off the update process for
    -- channel 1
    REG_ACTIVE : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' )then
                    updt_active_d1 <= '0';
                else
                    updt_active_d1 <= updt_active;
                end if;
            end if;
        end process REG_ACTIVE;

    updt_active_re  <= updt_active and not updt_active_d1;

    -- Current Descriptor Pointer Fetch.  This state machine controls
    -- reading out the current pointer from the Queue or channel port
    -- and writing it to the update manager for use in command
    -- generation to the DataMover for Descriptor update.
    CURDESC_PNTR_STATE : process(pntr_cs,
                                 updt_active_re,
                                 ptr_queue_empty,
                                 m_axis_updt_tready,
                                 updt_tvalid,
                                 updt_tlast)
        begin

            write_curdesc_lsb   <= '0';
            write_curdesc_msb   <= '0';
            writing_status      <= '0';
            dataq_rden          <= '0';
            stsq_rden           <= '0';
            pntr_ns             <= pntr_cs;

            case pntr_cs is

                when IDLE =>
                    if(updt_active_re = '1')then
                        pntr_ns <= READ_CURDESC_LSB;
                    else
                        pntr_ns <= IDLE;
                    end if;

                ---------------------------------------------------------------
                -- Get lower current descriptor pointer
                -- Reads one word from data queue fifo
                ---------------------------------------------------------------
                when READ_CURDESC_LSB =>
                    -- on tvalid from Queue or channel port then register
                    -- lsb curdesc and setup to register msb curdesc
                    if(ptr_queue_empty = '0')then
                        write_curdesc_lsb   <= '1';
                        dataq_rden          <= '1';
                        pntr_ns             <= READ_CURDESC_MSB;
                    else
                        pntr_ns <= READ_CURDESC_LSB;
                    end if;

                ---------------------------------------------------------------
                -- Get upper current descriptor
                -- Reads one word from data queue fifo
                ---------------------------------------------------------------
                when READ_CURDESC_MSB =>
                    -- On tvalid from Queue or channel port then register
                    -- msb.  This will also write curdesc out to update
                    -- manager.
                    if(ptr_queue_empty = '0')then
                        dataq_rden      <= '1';
                        write_curdesc_msb   <= '1';
                        pntr_ns         <= WRITE_STATUS;
                    else
                        pntr_ns         <= READ_CURDESC_MSB;
                    end if;

                ---------------------------------------------------------------
                -- Hold in this state until remainder of descriptor is
                -- written out.
                when WRITE_STATUS =>
                    -- De-MUX appropriage tvalid/tlast signals
                    writing_status <= '1';

                    -- Enable reading of Status Queue if datamover can
                    -- accept data
                    stsq_rden      <= m_axis_updt_tready;

                    -- Hold in the status state until tlast is pulled
                    -- from status fifo
                    if(updt_tvalid = '1' and m_axis_updt_tready = '1'
                    and updt_tlast = '1')then
                        pntr_ns     <= IDLE;
                    else
                        pntr_ns     <= WRITE_STATUS;
                    end if;

                when others =>
                    pntr_ns             <= IDLE;

            end case;
        end process CURDESC_PNTR_STATE;

    ---------------------------------------------------------------------------
    -- Register for CURDESC Pointer state machine
    ---------------------------------------------------------------------------
    REG_PNTR_STATES : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    pntr_cs <= IDLE;
                else
                    pntr_cs <= pntr_ns;
                end if;
            end if;
        end process REG_PNTR_STATES;

GEN_Q_FOR_SYNC : if C_AXIS_IS_ASYNC = 0 generate
begin
    -- Channel Pointer Queue (Generate Synchronous FIFO)
    I_UPDT_DATA_FIFO : entity lib_fifo_v1_0.sync_fifo_fg
    generic map (
        C_FAMILY                =>  C_FAMILY                    ,
        C_MEMORY_TYPE           =>  UPD_Q_MEMORY_TYPE           ,
        C_WRITE_DATA_WIDTH      =>  C_S_AXIS_UPDPTR_TDATA_WIDTH ,
        C_WRITE_DEPTH           =>  UPDATE_QUEUE_DEPTH          ,
        C_READ_DATA_WIDTH       =>  C_S_AXIS_UPDPTR_TDATA_WIDTH ,
        C_READ_DEPTH            =>  UPDATE_QUEUE_DEPTH          ,
        C_PORTS_DIFFER          =>  0,
        C_HAS_DCOUNT            =>  1, --req for proper fifo operation
        C_DCOUNT_WIDTH          =>  UPDATE_QUEUE_CNT_WIDTH,
        C_HAS_ALMOST_FULL       =>  0,
        C_HAS_RD_ACK            =>  0,
        C_HAS_RD_ERR            =>  0,
        C_HAS_WR_ACK            =>  0,
        C_HAS_WR_ERR            =>  0,
        C_RD_ACK_LOW            =>  0,
        C_RD_ERR_LOW            =>  0,
        C_WR_ACK_LOW            =>  0,
        C_WR_ERR_LOW            =>  0,
        C_PRELOAD_REGS          =>  1,-- 1 = first word fall through
        C_PRELOAD_LATENCY       =>  0 -- 0 = first word fall through
    )
    port map (

        Clk             =>  m_axi_sg_aclk           ,
        Sinit           =>  sinit                   ,
        Din             =>  ptr_queue_din           ,
        Wr_en           =>  ptr_queue_wren          ,
        Rd_en           =>  ptr_queue_rden          ,
        Dout            =>  ptr_queue_dout          ,
        Full            =>  ptr_queue_full          ,
        Empty           =>  ptr_queue_empty         ,
        Almost_full     =>  open                    ,
        Data_count      =>  open                    ,
        Rd_ack          =>  open                    ,
        Rd_err          =>  open                    ,
        Wr_ack          =>  open                    ,
        Wr_err          =>  open

    );

    -- Channel Status Queue (Generate Synchronous FIFO)
    I_UPDT_STS_FIFO : entity lib_fifo_v1_0.sync_fifo_fg
    generic map (
        C_FAMILY                =>  C_FAMILY                        ,
        C_MEMORY_TYPE           =>  STS_Q_MEMORY_TYPE               ,
        C_WRITE_DATA_WIDTH      =>  C_S_AXIS_UPDSTS_TDATA_WIDTH + 1 , --add 1 for tlast storage
        C_WRITE_DEPTH           =>  UPDATE_STS_QUEUE_DEPTH          ,
        C_READ_DATA_WIDTH       =>  C_S_AXIS_UPDSTS_TDATA_WIDTH + 1 , --add 1 for tlast storage
        C_READ_DEPTH            =>  UPDATE_STS_QUEUE_DEPTH          ,
        C_PORTS_DIFFER          =>  0                               ,
        C_HAS_DCOUNT            =>  1                               , --req for proper fifo operation
        C_DCOUNT_WIDTH          =>  UPDATE_STS_QUEUE_CNT_WIDTH      ,
        C_HAS_ALMOST_FULL       =>  0                               ,
        C_HAS_RD_ACK            =>  0                               ,
        C_HAS_RD_ERR            =>  0                               ,
        C_HAS_WR_ACK            =>  0                               ,
        C_HAS_WR_ERR            =>  0                               ,
        C_RD_ACK_LOW            =>  0                               ,
        C_RD_ERR_LOW            =>  0                               ,
        C_WR_ACK_LOW            =>  0                               ,
        C_WR_ERR_LOW            =>  0                               ,
        C_PRELOAD_REGS          =>  1                               ,-- 1 = first word fall through
        C_PRELOAD_LATENCY       =>  0                                -- 0 = first word fall through

    )
    port map (

        Clk             =>  m_axi_sg_aclk       ,
        Sinit           =>  sinit               ,
        Din             =>  sts_queue_din       ,
        Wr_en           =>  sts_queue_wren      ,
        Rd_en           =>  sts_queue_rden      ,
        Dout            =>  sts_queue_dout      ,
        Full            =>  sts_queue_full      ,
        Empty           =>  sts_queue_empty     ,
        Almost_full     =>  open                ,
        Data_count      =>  open                ,
        Rd_ack          =>  open                ,
        Rd_err          =>  open                ,
        Wr_ack          =>  open                ,
        Wr_err          =>  open

    );

end generate GEN_Q_FOR_SYNC;

GEN_Q_FOR_ASYNC : if C_AXIS_IS_ASYNC = 1 generate
begin


    -- Generate Asynchronous FIFO
    I_UPDT_DATA_FIFO : entity axi_vdma_v6_2.axi_sg_afifo_autord
      generic map(
         C_DWIDTH        => C_S_AXIS_UPDPTR_TDATA_WIDTH         ,
         C_DEPTH         => UPDATE_QUEUE_DEPTH                  ,
         C_CNT_WIDTH     => UPDATE_QUEUE_CNT_WIDTH              ,
         C_USE_BLKMEM    => UPD_Q_MEMORY_TYPE                   ,
         C_FAMILY        => C_FAMILY
        )
      port map(
        -- Inputs
         AFIFO_Ainit                => sinit                    ,
         AFIFO_Wr_clk               => m_axi_sg_aclk            ,
         AFIFO_Wr_en                => ptr_queue_wren           ,
         AFIFO_Din                  => ptr_queue_din            ,
         AFIFO_Rd_clk               => s_axis_updt_aclk         ,
         AFIFO_Rd_en                => ptr_queue_rden           ,
         AFIFO_Clr_Rd_Data_Valid    => '0'                      ,

        -- Outputs
         AFIFO_DValid               => open                     ,
         AFIFO_Dout                 => ptr_queue_dout           ,
         AFIFO_Full                 => ptr_queue_full           ,
         AFIFO_Empty                => ptr_queue_empty          ,
         AFIFO_Almost_full          => open                     ,
         AFIFO_Almost_empty         => open                     ,
         AFIFO_Wr_count             => open                     ,
         AFIFO_Rd_count             => open                     ,
         AFIFO_Corr_Rd_count        => open                     ,
         AFIFO_Corr_Rd_count_minus1 => open                     ,
         AFIFO_Rd_ack               => open
        );


    -- Generate Asynchronous FIFO
    I_UPDT_STS_FIFO : entity axi_vdma_v6_2.axi_sg_afifo_autord
      generic map(
         C_DWIDTH        => C_S_AXIS_UPDSTS_TDATA_WIDTH + 1     ,
         C_DEPTH         => UPDATE_STS_QUEUE_DEPTH              ,
         C_CNT_WIDTH     => UPDATE_STS_QUEUE_CNT_WIDTH          ,
         C_USE_BLKMEM    => STS_Q_MEMORY_TYPE                   ,
         C_FAMILY        => C_FAMILY
        )
      port map(
        -- Inputs
         AFIFO_Ainit                => sinit                    ,
         AFIFO_Wr_clk               => s_axis_updt_aclk         ,
         AFIFO_Wr_en                => sts_queue_wren           ,
         AFIFO_Din                  => sts_queue_din            ,
         AFIFO_Rd_clk               => m_axi_sg_aclk            ,
         AFIFO_Rd_en                => sts_queue_rden           ,
         AFIFO_Clr_Rd_Data_Valid    => '0'                      ,

        -- Outputs
         AFIFO_DValid               => open                     ,
         AFIFO_Dout                 => sts_queue_dout           ,
         AFIFO_Full                 => sts_queue_full           ,
         AFIFO_Empty                => sts_queue_empty          ,
         AFIFO_Almost_full          => open                     ,
         AFIFO_Almost_empty         => open                     ,
         AFIFO_Wr_count             => open                     ,
         AFIFO_Rd_count             => open                     ,
         AFIFO_Corr_Rd_count        => open                     ,
         AFIFO_Corr_Rd_count_minus1 => open                     ,
         AFIFO_Rd_ack               => open
        );


end generate GEN_Q_FOR_ASYNC;


    -- FIFO Reset is active high
    sinit   <= not m_axi_sg_aresetn;


    --*****************************************
    --** Channel Data Port Side of Queues
    --*****************************************

    -- Pointer Queue Update -  Descriptor Pointer (32bits)
    -- i.e. 2 current descriptor pointers and any app fields
    ptr_queue_din(C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0)   <= s_axis_updtptr_tdata(        -- DESC DATA
                                                                C_S_AXIS_UPDPTR_TDATA_WIDTH-1
                                                                downto 0);

    -- Data Queue Write Enable - based on tvalid and queue not full
    ptr_queue_wren    <=  s_axis_updtptr_tvalid    -- TValid
                          and not ptr_queue_full;      -- Data Queue NOT Full


    -- Drive channel port with ready if room in data queue
    s_axis_updtptr_tready <= not ptr_queue_full;


    --*****************************************
    --** Channel Status Port Side of Queues
    --*****************************************

    -- Status Queue Update - TLAST(1bit) & Includes IOC(1bit) & Descriptor Status(32bits)
    -- Note: Type field is stripped off
    sts_queue_din(C_S_AXIS_UPDSTS_TDATA_WIDTH)              <= s_axis_updtsts_tlast;        -- Store with tlast
    sts_queue_din(C_S_AXIS_UPDSTS_TDATA_WIDTH-1 downto 0)   <= s_axis_updtsts_tdata(        -- IOC & DESC STS
                                                                C_S_AXIS_UPDSTS_TDATA_WIDTH-1
                                                                downto 0);

    -- Status Queue Write Enable - based on tvalid and queue not full
    sts_queue_wren  <= s_axis_updtsts_tvalid
                          and not sts_queue_full;

    -- Drive channel port with ready if room in status queue
    s_axis_updtsts_tready <= not sts_queue_full;


    --*************************************
    --** SG Engine Side of Queues
    --*************************************
    -- Indicate NOT empty if both status queue and data queue are not empty
    updt_queue_empty    <= ptr_queue_empty
                            or sts_queue_empty;


    -- Data queue read enable
    ptr_queue_rden <= '1' when dataq_rden = '1'             -- Cur desc read enable
                               and ptr_queue_empty = '0'        -- Data Queue NOT empty
                 else '0';

    -- Status queue read enable
    sts_queue_rden <= '1' when stsq_rden = '1'          -- Writing desc status
                               and sts_queue_empty = '0'    -- Status fifo NOT empty
                     else '0';



    -----------------------------------------------------------------------
    -- TVALID - status queue not empty and writing status
    -----------------------------------------------------------------------
    updt_tvalid <= not sts_queue_empty
                       and writing_status;

    -----------------------------------------------------------------------
    -- TLAST - status queue not empty, writing status, and last asserted
    -----------------------------------------------------------------------
    -- Drive last as long as tvalid is asserted and last from fifo
    -- is asserted
    updt_tlast  <= not sts_queue_empty
                       and writing_status
                       and sts_queue_dout(C_S_AXIS_UPDSTS_TDATA_WIDTH);

    -----------------------------------------------------------------------
    -- TDATA - drive data to datamover from status queue
    -----------------------------------------------------------------------
    m_axis_updt_tdata  <= sts_queue_dout(C_S_AXIS_UPDSTS_TDATA_WIDTH-2 downto 0);
    m_axis_updt_tvalid <= updt_tvalid;
    m_axis_updt_tlast  <= updt_tlast;




--*********************************************************************
--** POINTER CAPTURE LOGIC
--*********************************************************************

    ---------------------------------------------------------------------------
    -- Write lower order Next Descriptor Pointer out to pntr_mngr
    ---------------------------------------------------------------------------
    REG_LSB_CURPNTR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' )then
                    updt_curdesc(31 downto 0)    <= (others => '0');

                -- Capture lower pointer from FIFO or channel port
                elsif(write_curdesc_lsb = '1')then
                    updt_curdesc(31 downto 0)    <= ptr_queue_dout(C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0);

                end if;
            end if;
        end process REG_LSB_CURPNTR;

    ---------------------------------------------------------------------------
    -- 64 Bit Scatter Gather addresses enabled
    ---------------------------------------------------------------------------
    GEN_UPPER_MSB_CURDESC : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
    begin
        ---------------------------------------------------------------------------
        -- Write upper order Next Descriptor Pointer out to pntr_mngr
        ---------------------------------------------------------------------------
        REG_MSB_CURPNTR : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    if(m_axi_sg_aresetn = '0' )then
                        updt_curdesc(63 downto 32)   <= (others => '0');
                        updt_curdesc_wren            <= '0';
                    -- Capture upper pointer from FIFO or channel port
                    -- and also write curdesc out
                    elsif(write_curdesc_msb = '1')then
                        updt_curdesc(63 downto 32)   <= ptr_queue_dout(C_S_AXIS_UPDPTR_TDATA_WIDTH-1 downto 0);
                        updt_curdesc_wren            <= '1';
                    -- Assert tready/wren for only 1 clock
                    else
                        updt_curdesc_wren            <= '0';
                    end if;
                end if;
            end process REG_MSB_CURPNTR;

    end generate GEN_UPPER_MSB_CURDESC;

    ---------------------------------------------------------------------------
    -- 32 Bit Scatter Gather addresses enabled
    ---------------------------------------------------------------------------
    GEN_NO_UPR_MSB_CURDESC : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
    begin

        -----------------------------------------------------------------------
        -- No upper order therefore dump fetched word and write pntr lower next
        -- pointer to pntr mngr
        -----------------------------------------------------------------------
        REG_MSB_CURPNTR : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    if(m_axi_sg_aresetn = '0' )then
                        updt_curdesc_wren            <= '0';
                    -- Throw away second word, only write curdesc out with msb
                    -- set to zero
                    elsif(write_curdesc_msb = '1')then
                        updt_curdesc_wren            <= '1';
                    -- Assert for only 1 clock
                    else
                        updt_curdesc_wren            <= '0';
                    end if;
                end if;
            end process REG_MSB_CURPNTR;

    end generate GEN_NO_UPR_MSB_CURDESC;




--*********************************************************************
--** ERROR CAPTURE LOGIC
--*********************************************************************

    -----------------------------------------------------------------------
    -- Generate rising edge pulse on writing status signal.  This will
    -- assert at the beginning of the status write.  Coupled with status
    -- fifo set to first word fall through status will be on dout
    -- regardless of target ready.
    -----------------------------------------------------------------------
    REG_WRITE_STATUS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    writing_status_d1 <= '0';
                else
                    writing_status_d1 <= writing_status;
                end if;
            end if;
        end process REG_WRITE_STATUS;

    writing_status_re <= writing_status and not writing_status_d1;

    -----------------------------------------------------------------------
    -- Caputure IOC begin set
    -----------------------------------------------------------------------
    REG_IOC_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or updt_ioc_irq_set = '1')then
                    updt_ioc <= '0';
                elsif(writing_status_re = '1')then
                    updt_ioc <= sts_queue_dout(DESC_IOC_TAG_BIT);
                end if;
            end if;
        end process REG_IOC_PROCESS;

    -----------------------------------------------------------------------
    -- Capture DMA Internal Errors
    -----------------------------------------------------------------------
    CAPTURE_DMAINT_ERROR: process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or dma_interr_set = '1')then
                    dma_interr  <= '0';
                elsif(writing_status_re = '1')then
                    dma_interr <=  sts_queue_dout(DESC_STS_INTERR_BIT);
                end if;
            end if;
        end process CAPTURE_DMAINT_ERROR;

    -----------------------------------------------------------------------
    -- Capture DMA Slave Errors
    -----------------------------------------------------------------------
    CAPTURE_DMASLV_ERROR: process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or dma_slverr_set = '1')then
                    dma_slverr  <= '0';
                elsif(writing_status_re = '1')then
                    dma_slverr <=  sts_queue_dout(DESC_STS_SLVERR_BIT);
                end if;
            end if;
        end process CAPTURE_DMASLV_ERROR;

    -----------------------------------------------------------------------
    -- Capture DMA Decode Errors
    -----------------------------------------------------------------------
    CAPTURE_DMADEC_ERROR: process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or dma_decerr_set = '1')then
                    dma_decerr  <= '0';
                elsif(writing_status_re = '1')then
                    dma_decerr <=  sts_queue_dout(DESC_STS_DECERR_BIT);
                end if;
            end if;
        end process CAPTURE_DMADEC_ERROR;

end implementation;
