-------------------------------------------------------------------------------
-- axi_sg_ftch_queue
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
-- Filename:          axi_sg_ftch_queue.vhd
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
--  GAB     7/27/10    v1_00_a
-- ^^^^^^
-- CR569609
-- Remove double driven signal for exclude update engine mode
-- ~~~~~~
--  GAB     8/26/10    v2_00_a
-- ^^^^^^
--  Rolled axi_sg library version to version v2_00_a
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
entity  axi_sg_ftch_q_mngr is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64    := 32;
            -- Master AXI Memory Map Address Width

        C_M_AXIS_SG_TDATA_WIDTH     : integer range 32 to 32    := 32;
            -- Master AXI Stream Data width

        C_AXIS_IS_ASYNC             : integer range 0 to 1      := 0;
            -- Channel 1 is async to sg_aclk
            -- 0 = Synchronous to SG ACLK
            -- 1 = Asynchronous to SG ACLK

        C_SG_FTCH_DESC2QUEUE        : integer range 0 to 8         := 0;
            -- Number of descriptors to fetch and queue for each channel.
            -- A value of zero excludes the fetch queues.

        C_SG_CH1_WORDS_TO_FETCH         : integer range 4 to 16     := 8;
            -- Number of words to fetch for channel 1

        C_SG_CH2_WORDS_TO_FETCH         : integer range 4 to 16     := 8;
            -- Number of words to fetch for channel 1

        C_SG_CH1_ENBL_STALE_ERROR   : integer range 0 to 1          := 1;
            -- Enable or disable stale descriptor check
            -- 0 = Disable stale descriptor error check
            -- 1 = Enable stale descriptor error check

        C_SG_CH2_ENBL_STALE_ERROR   : integer range 0 to 1          := 1;
            -- Enable or disable stale descriptor check
            -- 0 = Disable stale descriptor error check
            -- 1 = Enable stale descriptor error check

        C_INCLUDE_CH1               : integer range 0 to 1          := 1;
            -- Include or Exclude channel 1 scatter gather engine
            -- 0 = Exclude Channel 1 SG Engine
            -- 1 = Include Channel 1 SG Engine


        C_INCLUDE_CH2               : integer range 0 to 1          := 1;
            -- Include or Exclude channel 2 scatter gather engine
            -- 0 = Exclude Channel 2 SG Engine
            -- 1 = Include Channel 2 SG Engine

        C_FAMILY                    : string            := "virtex6"
            -- Device family used for proper BRAM selection
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
        -- Channel 1 Control                                                                    --
        ch1_desc_flush              : in  std_logic                         ;                   --
        ch1_ftch_active             : in  std_logic                         ;                   --
        ch1_nxtdesc_wren            : out std_logic                         ;                   --
        ch1_ftch_queue_empty        : out std_logic                         ;                   --
        ch1_ftch_queue_full         : out std_logic                         ;                   --
        ch1_ftch_pause              : out std_logic                         ;                   --
                                                                                                --
        -- Channel 2 Control                                                                    --
        ch2_desc_flush              : in  std_logic                         ;                   --
        ch2_ftch_active             : in  std_logic                         ;                   --
        ch2_nxtdesc_wren            : out std_logic                         ;                   --
        ch2_ftch_queue_empty        : out std_logic                         ;                   --
        ch2_ftch_queue_full         : out std_logic                         ;                   --
        ch2_ftch_pause              : out std_logic                         ;                   --
        nxtdesc                     : out std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        -- DataMover Command                                                                    --
        ftch_cmnd_wr                : in  std_logic                         ;                   --
        ftch_cmnd_data              : in  std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
        ftch_stale_desc             : out std_logic                         ;                   --
                                                                                                --
        -- MM2S Stream In from DataMover                                                        --
        m_axis_mm2s_tdata           : in  std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;                  --
        m_axis_mm2s_tkeep           : in  std_logic_vector                                      --
                                        ((C_M_AXIS_SG_TDATA_WIDTH/8)-1 downto 0);               --
        m_axis_mm2s_tlast           : in  std_logic                         ;                   --
        m_axis_mm2s_tvalid          : in  std_logic                         ;                   --
        m_axis_mm2s_tready          : out std_logic                         ;                   --
                                                                                                --
                                                                                                --
        -- Channel 1 AXI Fetch Stream Out                                                       --
        m_axis_ch1_ftch_aclk        : in  std_logic                         ;
        m_axis_ch1_ftch_tdata       : out std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0);                   --
        m_axis_ch1_ftch_tvalid      : out std_logic                         ;                   --
        m_axis_ch1_ftch_tready      : in  std_logic                         ;                   --
        m_axis_ch1_ftch_tlast       : out std_logic                         ;                   --
                                                                                                --
                                                                                                --
        -- Channel 2 AXI Fetch Stream Out                                                       --
        m_axis_ch2_ftch_aclk        : in  std_logic                         ;                   --
        m_axis_ch2_ftch_tdata       : out std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;                  --
        m_axis_ch2_ftch_tvalid      : out std_logic                         ;                   --
        m_axis_ch2_ftch_tready      : in  std_logic                         ;                   --
        m_axis_ch2_ftch_tlast       : out std_logic                                             --

    );

end axi_sg_ftch_q_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_q_mngr is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-- Determine the maximum word count for use in setting the word counter width
-- Set bit width on max num words to fetch
constant FETCH_COUNT            : integer := max2(C_SG_CH1_WORDS_TO_FETCH
                                                 ,C_SG_CH2_WORDS_TO_FETCH);
-- LOG2 to get width of counter
constant WORDS2FETCH_BITWIDTH   : integer := clog2(FETCH_COUNT);
-- Zero value for counter
constant WORD_ZERO              : std_logic_vector(WORDS2FETCH_BITWIDTH-1 downto 0)
                                    := (others => '0');
-- One value for counter
constant WORD_ONE               : std_logic_vector(WORDS2FETCH_BITWIDTH-1 downto 0)
                                    := std_logic_vector(to_unsigned(1,WORDS2FETCH_BITWIDTH));
-- Seven value for counter
constant WORD_SEVEN             : std_logic_vector(WORDS2FETCH_BITWIDTH-1 downto 0)
                                    := std_logic_vector(to_unsigned(7,WORDS2FETCH_BITWIDTH));

constant USE_LOGIC_FIFOS        : integer   := 0; -- Use Logic FIFOs
constant USE_BRAM_FIFOS         : integer   := 1; -- Use BRAM FIFOs


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal m_axis_mm2s_tready_i     : std_logic := '0';
signal ch1_ftch_tready          : std_logic := '0';
signal ch2_ftch_tready          : std_logic := '0';

-- Misc Signals
signal writing_curdesc          : std_logic := '0';
signal fetch_word_count         : std_logic_vector
                                    (WORDS2FETCH_BITWIDTH-1 downto 0) := (others => '0');
signal msb_curdesc              : std_logic_vector(31 downto 0) := (others => '0');

signal lsbnxtdesc_tready        : std_logic := '0';
signal msbnxtdesc_tready        : std_logic := '0';
signal nxtdesc_tready           : std_logic := '0';

signal ch1_writing_curdesc      : std_logic := '0';
signal ch2_writing_curdesc      : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

---------------------------------------------------------------------------
-- For 32-bit SG addresses then drive zero on msb
---------------------------------------------------------------------------
GEN_CURDESC_32 : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
begin
    msb_curdesc <= (others => '0');
end generate  GEN_CURDESC_32;

---------------------------------------------------------------------------
-- For 64-bit SG addresses then capture upper order adder to msb
---------------------------------------------------------------------------
GEN_CURDESC_64 : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
begin
    CAPTURE_CURADDR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    msb_curdesc <= (others => '0');
                elsif(ftch_cmnd_wr = '1')then
                    msb_curdesc <= ftch_cmnd_data(DATAMOVER_CMD_ADDRMSB_BOFST
                                                    + C_M_AXI_SG_ADDR_WIDTH
                                                    downto DATAMOVER_CMD_ADDRMSB_BOFST
                                                    + DATAMOVER_CMD_ADDRLSB_BIT + 1);
                end if;
            end if;
        end process CAPTURE_CURADDR;
end generate  GEN_CURDESC_64;

-------------------------------------------------------------------------------
-- Fetch Stream Word Counter
-- The process is used to determine when to strip off NextDesc pointer from
-- stream and when to look at control word for complete bit set.
-------------------------------------------------------------------------------
REG_WORD_COUNTER : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            -- Clear on reset and on datamover command write
            if(m_axi_sg_aresetn = '0' or ftch_cmnd_wr = '1'
            or (m_axis_mm2s_tlast = '1' and m_axis_mm2s_tvalid = '1' and m_axis_mm2s_tready_i = '1'))then
                fetch_word_count <= (others => '0');
            -- If both tvalid=1 and tready = 1 then count
            elsif(m_axis_mm2s_tvalid = '1' and m_axis_mm2s_tready_i = '1')then
                fetch_word_count <= std_logic_vector(unsigned(fetch_word_count
                                        (WORDS2FETCH_BITWIDTH-1 downto 0)) + 1);
            end if;
        end if;
    end process REG_WORD_COUNTER;

---------------------------------------------------------------------------
-- Write lower order Next Descriptor Pointer out to pntr_mngr
---------------------------------------------------------------------------
REG_LSB_NXTPNTR : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0' )then
                nxtdesc(31 downto 0)    <= (others => '0');

            -- On valid and word count at 0 and channel active capture LSB next pointer
            elsif(m_axis_mm2s_tvalid = '1' and fetch_word_count = WORD_ZERO)then
                nxtdesc(31 downto 0)    <= m_axis_mm2s_tdata;

            end if;
        end if;
    end process REG_LSB_NXTPNTR;

lsbnxtdesc_tready <= '1' when m_axis_mm2s_tvalid = '1'
                          and fetch_word_count = WORD_ZERO
                    else '0';

---------------------------------------------------------------------------
-- 64 Bit Scatter Gather addresses enabled
---------------------------------------------------------------------------
GEN_UPPER_MSB_NXTDESC : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
begin
    ---------------------------------------------------------------------------
    -- Write upper order Next Descriptor Pointer out to pntr_mngr
    ---------------------------------------------------------------------------
    REG_MSB_NXTPNTR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' )then
                    nxtdesc(63 downto 32)   <= (others => '0');
                    ch1_nxtdesc_wren            <= '0';
                    ch2_nxtdesc_wren            <= '0';
                -- Capture upper pointer, drive ready to progress DataMover
                -- and also write nxtdesc out
                elsif(m_axis_mm2s_tvalid = '1' and fetch_word_count = WORD_ONE)then
                    nxtdesc(63 downto 32)   <= m_axis_mm2s_tdata;
                    ch1_nxtdesc_wren            <= ch1_ftch_active;
                    ch2_nxtdesc_wren            <= ch2_ftch_active;
                -- Assert tready/wren for only 1 clock
                else
                    ch1_nxtdesc_wren            <= '0';
                    ch2_nxtdesc_wren            <= '0';
                end if;
            end if;
        end process REG_MSB_NXTPNTR;

    msbnxtdesc_tready <= '1' when m_axis_mm2s_tvalid = '1'
                              and fetch_word_count = WORD_ONE
                        else '0';


end generate GEN_UPPER_MSB_NXTDESC;

---------------------------------------------------------------------------
-- 32 Bit Scatter Gather addresses enabled
---------------------------------------------------------------------------
GEN_NO_UPR_MSB_NXTDESC : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
begin

    -----------------------------------------------------------------------
    -- No upper order therefore dump fetched word and write pntr lower next
    -- pointer to pntr mngr
    -----------------------------------------------------------------------
    REG_MSB_NXTPNTR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' )then
                    ch1_nxtdesc_wren            <= '0';
                    ch2_nxtdesc_wren            <= '0';
                -- Throw away second word but drive ready to progress DataMover
                -- and also write nxtdesc out
                elsif(m_axis_mm2s_tvalid = '1' and fetch_word_count = WORD_ONE)then
                    ch1_nxtdesc_wren            <= ch1_ftch_active;
                    ch2_nxtdesc_wren            <= ch2_ftch_active;
                -- Assert for only 1 clock
                else
                    ch1_nxtdesc_wren            <= '0';
                    ch2_nxtdesc_wren            <= '0';
                end if;
            end if;
        end process REG_MSB_NXTPNTR;

    msbnxtdesc_tready <= '1' when m_axis_mm2s_tvalid = '1'
                              and fetch_word_count = WORD_ONE
                    else '0';


end generate GEN_NO_UPR_MSB_NXTDESC;

-- Drive ready to DataMover for ether lsb or msb capture
nxtdesc_tready  <= msbnxtdesc_tready or lsbnxtdesc_tready;

-- Generate logic for checking stale descriptor
GEN_STALE_DESC_CHECK : if C_SG_CH1_ENBL_STALE_ERROR = 1 or C_SG_CH2_ENBL_STALE_ERROR = 1 generate
begin

    ---------------------------------------------------------------------------
    -- Examine Completed BIT to determine if stale descriptor fetched
    ---------------------------------------------------------------------------
    CMPLTD_CHECK : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' )then
                    ftch_stale_desc <= '0';
                -- On valid and word count at 0 and channel active capture LSB next pointer
                elsif(m_axis_mm2s_tvalid = '1' and fetch_word_count = WORD_SEVEN
                and m_axis_mm2s_tready_i = '1'
                and m_axis_mm2s_tdata(DESC_STS_CMPLTD_BIT) = '1' )then
                    ftch_stale_desc <= '1';
                else
                    ftch_stale_desc <= '0';
                end if;
            end if;
        end process CMPLTD_CHECK;

end generate GEN_STALE_DESC_CHECK;

-- No needed logic for checking stale descriptor
GEN_NO_STALE_CHECK : if C_SG_CH1_ENBL_STALE_ERROR = 0 and C_SG_CH2_ENBL_STALE_ERROR = 0 generate
begin
    ftch_stale_desc <= '0';
end generate GEN_NO_STALE_CHECK;



-------------------------------------------------------------------------------
-- If channel 1 is included then generate ch1 logic
-------------------------------------------------------------------------------
GEN_CH1_FTCH_Q_IF : if C_INCLUDE_CH1 = 1 generate
begin
    ---------------------------------------------------------------------------
    -- SG Queueing therefore pass stream signals to
    -- FIFO
    ---------------------------------------------------------------------------
    GEN_CH1_QUEUE : if C_SG_FTCH_DESC2QUEUE /= 0 generate
    begin
        -- Instantiate the queue version
        FTCH_QUEUE_I : entity  axi_vdma_v6_2.axi_sg_ftch_queue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH        ,
                C_M_AXIS_SG_TDATA_WIDTH     => C_M_AXIS_SG_TDATA_WIDTH      ,
                C_SG_FTCH_DESC2QUEUE        => C_SG_FTCH_DESC2QUEUE         ,
                C_SG_WORDS_TO_FETCH         => C_SG_CH1_WORDS_TO_FETCH      ,
                C_AXIS_IS_ASYNC             => C_AXIS_IS_ASYNC              ,
                C_FAMILY                    => C_FAMILY
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn             ,

                -- Channel Control
                desc_flush                  => ch1_desc_flush               ,
                ftch_active                 => ch1_ftch_active              ,
                ftch_queue_empty            => ch1_ftch_queue_empty         ,
                ftch_queue_full             => ch1_ftch_queue_full          ,
                ftch_pause                  => ch1_ftch_pause               ,

                writing_nxtdesc_in          => nxtdesc_tready               ,
                writing_curdesc_out         => ch1_writing_curdesc          ,

                -- DataMover Command
                ftch_cmnd_wr                => ftch_cmnd_wr                 ,
                ftch_cmnd_data              => ftch_cmnd_data               ,

                -- MM2S Stream In from DataMover
                m_axis_mm2s_tdata           => m_axis_mm2s_tdata            ,
                m_axis_mm2s_tlast           => m_axis_mm2s_tlast            ,
                m_axis_mm2s_tvalid          => m_axis_mm2s_tvalid           ,
                m_axis_mm2s_tready          => ch1_ftch_tready              ,

                -- Channel 1 AXI Fetch Stream Out
                m_axis_ftch_aclk            => m_axis_ch1_ftch_aclk         ,
                m_axis_ftch_tdata           => m_axis_ch1_ftch_tdata        ,
                m_axis_ftch_tvalid          => m_axis_ch1_ftch_tvalid       ,
                m_axis_ftch_tready          => m_axis_ch1_ftch_tready       ,
                m_axis_ftch_tlast           => m_axis_ch1_ftch_tlast
            );

    end generate GEN_CH1_QUEUE;

    -- No SG Queueing therefore pass stream signals straight
    -- out channel port
    GEN_NO_CH1_QUEUE : if C_SG_FTCH_DESC2QUEUE = 0 generate
    begin
        -- Instantiate the No queue version
        NO_FTCH_QUEUE_I : entity  axi_vdma_v6_2.axi_sg_ftch_noqueue
            generic map (
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH,
                C_M_AXIS_SG_TDATA_WIDTH     => C_M_AXIS_SG_TDATA_WIDTH
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn             ,

                -- Channel Control
                desc_flush                  => ch1_desc_flush               ,
                ftch_active                 => ch1_ftch_active              ,
                ftch_queue_empty            => ch1_ftch_queue_empty         ,
                ftch_queue_full             => ch1_ftch_queue_full          ,

                writing_nxtdesc_in          => nxtdesc_tready               ,
                writing_curdesc_out         => ch1_writing_curdesc          ,

                -- DataMover Command
                ftch_cmnd_wr                => ftch_cmnd_wr                 ,
                ftch_cmnd_data              => ftch_cmnd_data               ,

                -- MM2S Stream In from DataMover
                m_axis_mm2s_tdata           => m_axis_mm2s_tdata            ,
                m_axis_mm2s_tlast           => m_axis_mm2s_tlast            ,
                m_axis_mm2s_tvalid          => m_axis_mm2s_tvalid           ,
                m_axis_mm2s_tready          => ch1_ftch_tready              ,

                -- Channel 1 AXI Fetch Stream Out
                m_axis_ftch_tdata           => m_axis_ch1_ftch_tdata        ,
                m_axis_ftch_tvalid          => m_axis_ch1_ftch_tvalid       ,
                m_axis_ftch_tready          => m_axis_ch1_ftch_tready       ,
                m_axis_ftch_tlast           => m_axis_ch1_ftch_tlast
            );

        ch1_ftch_pause          <= '0';

    end generate GEN_NO_CH1_QUEUE;

end generate GEN_CH1_FTCH_Q_IF;


-------------------------------------------------------------------------------
-- Channel 1 excluded so tie outputs low
-------------------------------------------------------------------------------
GEN_NO_CH1_FTCH_Q_IF : if C_INCLUDE_CH1 = 0 generate
begin
    ch1_ftch_queue_empty    <= '0';
    ch1_ftch_queue_full     <= '0';
    ch1_ftch_pause          <= '0';
    ch1_writing_curdesc     <= '0';
    ch1_ftch_tready         <= '0';

    m_axis_ch1_ftch_tdata   <= (others => '0');
    m_axis_ch1_ftch_tlast   <= '0';
    m_axis_ch1_ftch_tvalid  <= '0';

end generate GEN_NO_CH1_FTCH_Q_IF;



-------------------------------------------------------------------------------
-- If channel 2 is included then generate ch1 logic
-------------------------------------------------------------------------------
GEN_CH2_FTCH_Q_IF : if C_INCLUDE_CH2 = 1 generate
begin
    ---------------------------------------------------------------------------
    -- SG Queueing therefore pass stream signals to
    -- FIFO
    ---------------------------------------------------------------------------
    GEN_CH2_QUEUE : if C_SG_FTCH_DESC2QUEUE /= 0 generate
    begin
        -- Instantiate the queue version
        FTCH_QUEUE_I : entity  axi_vdma_v6_2.axi_sg_ftch_queue
            generic map(
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH        ,
                C_M_AXIS_SG_TDATA_WIDTH     => C_M_AXIS_SG_TDATA_WIDTH      ,
                C_SG_FTCH_DESC2QUEUE        => C_SG_FTCH_DESC2QUEUE         ,
                C_SG_WORDS_TO_FETCH         => C_SG_CH2_WORDS_TO_FETCH      ,
                C_AXIS_IS_ASYNC             => C_AXIS_IS_ASYNC              ,
                C_FAMILY                    => C_FAMILY
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn             ,

                -- Channel Control
                desc_flush                  => ch2_desc_flush               ,
                ftch_active                 => ch2_ftch_active              ,
                ftch_queue_empty            => ch2_ftch_queue_empty         ,
                ftch_queue_full             => ch2_ftch_queue_full          ,
                ftch_pause                  => ch2_ftch_pause               ,

                writing_nxtdesc_in          => nxtdesc_tready               ,
                writing_curdesc_out         => ch2_writing_curdesc          ,

                -- DataMover Command
                ftch_cmnd_wr                => ftch_cmnd_wr                 ,
                ftch_cmnd_data              => ftch_cmnd_data               ,

                -- MM2S Stream In from DataMover
                m_axis_mm2s_tdata           => m_axis_mm2s_tdata            ,
                m_axis_mm2s_tlast           => m_axis_mm2s_tlast            ,
                m_axis_mm2s_tvalid          => m_axis_mm2s_tvalid           ,
                m_axis_mm2s_tready          => ch2_ftch_tready              ,

                -- Channel 1 AXI Fetch Stream Out
                m_axis_ftch_aclk            => m_axis_ch2_ftch_aclk         ,
                m_axis_ftch_tdata           => m_axis_ch2_ftch_tdata        ,
                m_axis_ftch_tvalid          => m_axis_ch2_ftch_tvalid       ,
                m_axis_ftch_tready          => m_axis_ch2_ftch_tready       ,
                m_axis_ftch_tlast           => m_axis_ch2_ftch_tlast
            );

    end generate GEN_CH2_QUEUE;

    -- No SG Queueing therefore pass stream signals straight
    -- out channel port
    GEN_NO_CH2_QUEUE : if C_SG_FTCH_DESC2QUEUE = 0 generate
    begin
        -- Instantiate the No queue version
        NO_FTCH_QUEUE_I : entity  axi_vdma_v6_2.axi_sg_ftch_noqueue
            generic map (
                C_M_AXI_SG_ADDR_WIDTH       => C_M_AXI_SG_ADDR_WIDTH,
                C_M_AXIS_SG_TDATA_WIDTH     => C_M_AXIS_SG_TDATA_WIDTH
            )
            port map(
                -----------------------------------------------------------------------
                -- AXI Scatter Gather Interface
                -----------------------------------------------------------------------
                m_axi_sg_aclk               => m_axi_sg_aclk                ,
                m_axi_sg_aresetn            => m_axi_sg_aresetn             ,

                -- Channel Control
                desc_flush                  => ch2_desc_flush               ,
                ftch_active                 => ch2_ftch_active              ,
                ftch_queue_empty            => ch2_ftch_queue_empty         ,
                ftch_queue_full             => ch2_ftch_queue_full          ,

                writing_nxtdesc_in          => nxtdesc_tready               ,
                writing_curdesc_out         => ch2_writing_curdesc          ,

                -- DataMover Command
                ftch_cmnd_wr                => ftch_cmnd_wr                 ,
                ftch_cmnd_data              => ftch_cmnd_data               ,

                -- MM2S Stream In from DataMover
                m_axis_mm2s_tdata           => m_axis_mm2s_tdata            ,
                m_axis_mm2s_tlast           => m_axis_mm2s_tlast            ,
                m_axis_mm2s_tvalid          => m_axis_mm2s_tvalid           ,
                m_axis_mm2s_tready          => ch2_ftch_tready              ,

                -- Channel 2 AXI Fetch Stream Out
                m_axis_ftch_tdata           => m_axis_ch2_ftch_tdata        ,
                m_axis_ftch_tvalid          => m_axis_ch2_ftch_tvalid       ,
                m_axis_ftch_tready          => m_axis_ch2_ftch_tready       ,
                m_axis_ftch_tlast           => m_axis_ch2_ftch_tlast
            );

            ch2_ftch_pause          <= '0';

    end generate GEN_NO_CH2_QUEUE;

end generate GEN_CH2_FTCH_Q_IF;


-------------------------------------------------------------------------------
-- Channel 2 excluded so tie outputs low
-------------------------------------------------------------------------------
GEN_NO_CH2_FTCH_Q_IF : if C_INCLUDE_CH2 = 0 generate
begin
    ch2_ftch_queue_empty    <= '0';
    ch2_ftch_queue_full     <= '0';
    ch2_ftch_pause          <= '0';
    ch2_writing_curdesc     <= '0';
    ch2_ftch_tready         <= '0';

    m_axis_ch2_ftch_tdata   <= (others => '0');
    m_axis_ch2_ftch_tlast   <= '0';
    m_axis_ch2_ftch_tvalid  <= '0';

end generate GEN_NO_CH2_FTCH_Q_IF;


-------------------------------------------------------------------------------
-- DataMover TREADY MUX
-------------------------------------------------------------------------------
writing_curdesc <= ch1_writing_curdesc or ch2_writing_curdesc or ftch_cmnd_wr;


TREADY_MUX : process(writing_curdesc,
                     fetch_word_count,
                     nxtdesc_tready,

                     -- channel 1 signals
                     ch1_ftch_active,
                     ch1_desc_flush,
                     ch1_ftch_tready,

                     -- channel 2 signals
                     ch2_ftch_active,
                     ch2_desc_flush,
                     ch2_ftch_tready)
    begin
        -- If commmanded to flush descriptor then assert ready
        -- to datamover until active de-asserts.  this allows
        -- any commanded fetches to complete.
        if( (ch1_desc_flush = '1' and ch1_ftch_active = '1')
          or(ch2_desc_flush = '1' and ch2_ftch_active = '1'))then
            m_axis_mm2s_tready_i <= '1';

        -- NOT ready if cmnd being written because
        -- curdesc gets written to queue
        elsif(writing_curdesc = '1')then
            m_axis_mm2s_tready_i <= '0';

        -- First two words drive ready from internal logic
        elsif(fetch_word_count = WORD_ZERO or fetch_word_count = WORD_ONE)then
            m_axis_mm2s_tready_i <= nxtdesc_tready;

        -- Remainder stream words drive ready from channel input
        else
            m_axis_mm2s_tready_i <= (ch1_ftch_active and ch1_ftch_tready)
                                 or (ch2_ftch_active and ch2_ftch_tready);
        end if;
    end process TREADY_MUX;

m_axis_mm2s_tready    <= m_axis_mm2s_tready_i;





end implementation;
