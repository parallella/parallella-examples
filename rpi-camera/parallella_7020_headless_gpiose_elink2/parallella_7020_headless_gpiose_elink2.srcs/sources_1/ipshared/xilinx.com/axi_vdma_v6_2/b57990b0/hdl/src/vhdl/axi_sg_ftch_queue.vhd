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
--  GAB     7/8/11    v4_03
-- ^^^^^^
-- CR616461 - fixed mismatched vector size for async mode
-- ~~~~~~
--  GAB     8/16/11    v4_03
-- ^^^^^^
-- CR621600 - queue empty based on wrclk is needed for fetch idle determination
--            utilized wrcount from queue to create empty flag for fetch sm.
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
entity  axi_sg_ftch_queue is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64    := 32;
            -- Master AXI Memory Map Address Width

        C_M_AXIS_SG_TDATA_WIDTH     : integer range 32 to 32    := 32;
            -- Master AXI Stream Data width

        C_SG_FTCH_DESC2QUEUE        : integer range 0 to 8      := 0;
            -- Number of descriptors to fetch and queue for each channel.
            -- A value of zero excludes the fetch queues.

        C_SG_WORDS_TO_FETCH         : integer range 4 to 16     := 8;
            -- Number of words to fetch for channel 1

        C_AXIS_IS_ASYNC             : integer range 0 to 1      := 0;
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
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
        -- Channel Control                                                                    --
        desc_flush                  : in  std_logic                         ;                   --
        ftch_active                 : in  std_logic                         ;                   --
        ftch_queue_empty            : out std_logic                         ;                   --
        ftch_queue_full             : out std_logic                         ;                   --
        ftch_pause                  : out std_logic                         ;                   --
                                                                                                --
        writing_nxtdesc_in          : in  std_logic                         ;                   --
        writing_curdesc_out         : out std_logic                         ;                   --
                                                                                                --
        -- DataMover Command                                                                    --
        ftch_cmnd_wr                : in  std_logic                         ;                   --
        ftch_cmnd_data              : in  std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
                                                                                                --
        -- MM2S Stream In from DataMover                                                        --
        m_axis_mm2s_tdata           : in  std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;                  --
        m_axis_mm2s_tlast           : in  std_logic                         ;                   --
        m_axis_mm2s_tvalid          : in  std_logic                         ;                   --
        m_axis_mm2s_tready          : out std_logic                         ;                   --
                                                                                                --
                                                                                                --
        -- Channel 1 AXI Fetch Stream Out                                                       --
        m_axis_ftch_aclk            : in  std_logic                         ;                   --
        m_axis_ftch_tdata           : out std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0);                   --
        m_axis_ftch_tvalid          : out std_logic                         ;                   --
        m_axis_ftch_tready          : in  std_logic                         ;                   --
        m_axis_ftch_tlast           : out std_logic                                             --
    );

end axi_sg_ftch_queue;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_queue is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Not currently used
--constant USE_LOGIC_FIFOS        : integer   := 0; -- Use Logic FIFOs
--constant USE_BRAM_FIFOS         : integer   := 1; -- Use BRAM FIFOs

-- Number of words deep fifo needs to be
constant    FETCH_QUEUE_DEPTH       : integer := max2(16,pad_power2(C_SG_FTCH_DESC2QUEUE
                                                                  * C_SG_WORDS_TO_FETCH));

-- Width of fifo rd and wr counts - only used for proper fifo operation
constant    FETCH_QUEUE_CNT_WIDTH   : integer   := clog2(FETCH_QUEUE_DEPTH+1);

-- Select between BRAM or Logic Memory Type
constant    MEMORY_TYPE : integer := bo2int(C_SG_FTCH_DESC2QUEUE
                                    * C_SG_WORDS_TO_FETCH > 16);


constant DESC2QUEUE_VECT_WIDTH      : integer := 4;
--constant SG_FTCH_DESC2QUEUE_VECT    : std_logic_vector(DESC2QUEUE_VECT_WIDTH-1 downto 0)
--                                        := std_logic_vector(to_unsigned(C_SG_FTCH_DESC2QUEUE,DESC2QUEUE_VECT_WIDTH)); --  CR616461
constant SG_FTCH_DESC2QUEUE_VECT    : std_logic_vector(DESC2QUEUE_VECT_WIDTH-1 downto 0)
                                        := std_logic_vector(to_unsigned(C_SG_FTCH_DESC2QUEUE,DESC2QUEUE_VECT_WIDTH));   --  CR616461

constant DCNT_LO_INDEX              : integer :=  max2(1,clog2(C_SG_WORDS_TO_FETCH)) - 1;
--constant DCNT_HI_INDEX              : integer :=  (DCNT_LO_INDEX + DESC2QUEUE_VECT_WIDTH) - 1;    --  CR616461
constant DCNT_HI_INDEX              : integer :=  FETCH_QUEUE_CNT_WIDTH-1;                          --  CR616461


constant ZERO_COUNT                 : std_logic_vector(FETCH_QUEUE_CNT_WIDTH-1 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- Internal signals
signal curdesc_tdata            : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal curdesc_tvalid           : std_logic := '0';
signal ftch_tvalid              : std_logic := '0';
signal ftch_tdata               : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal ftch_tlast               : std_logic := '0';
signal ftch_tready              : std_logic := '0';

-- Misc Signals
signal writing_curdesc          : std_logic := '0';
signal writing_nxtdesc          : std_logic := '0';

signal msb_curdesc              : std_logic_vector(31 downto 0) := (others => '0');
signal writing_lsb              : std_logic := '0';
signal writing_msb              : std_logic := '0';

-- FIFO signals
signal queue_rden               : std_logic := '0';
signal queue_wren               : std_logic := '0';
signal queue_empty              : std_logic := '0';
signal queue_full               : std_logic := '0';
signal queue_din                : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH downto 0) := (others => '0');
signal queue_dout               : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH downto 0) := (others => '0');
signal queue_sinit              : std_logic := '0';
signal q_vacancy                : std_logic_vector(FETCH_QUEUE_CNT_WIDTH-1 downto 0) := (others => '0');
signal queue_dcount             : std_logic_vector(FETCH_QUEUE_CNT_WIDTH-1 downto 0) := (others => '0');
signal ftch_no_room             : std_logic;

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


---------------------------------------------------------------------------
-- Write current descriptor to FIFO or out channel port
---------------------------------------------------------------------------
WRITE_CURDESC_PROCESS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0' )then
                curdesc_tdata       <= (others => '0');
                curdesc_tvalid      <= '0';
                writing_lsb         <= '0';
                writing_msb         <= '0';

            -- Write LSB Address on command write
            elsif(ftch_cmnd_wr = '1' and ftch_active = '1')then
                curdesc_tdata       <= ftch_cmnd_data(DATAMOVER_CMD_ADDRMSB_BOFST
                                                        + DATAMOVER_CMD_ADDRLSB_BIT
                                                        downto DATAMOVER_CMD_ADDRLSB_BIT);
                curdesc_tvalid      <= '1';
                writing_lsb         <= '1';
                writing_msb         <= '0';

            -- On ready write MSB address
            elsif(writing_lsb = '1' and ftch_tready = '1')then
                curdesc_tdata       <= msb_curdesc;
                curdesc_tvalid      <= '1';
                writing_lsb         <= '0';
                writing_msb         <= '1';

            -- On MSB write and ready then clear all
            elsif(writing_msb = '1' and ftch_tready = '1')then
                curdesc_tdata       <= (others => '0');
                curdesc_tvalid      <= '0';
                writing_lsb         <= '0';
                writing_msb         <= '0';

            end if;
        end if;
    end process WRITE_CURDESC_PROCESS;

---------------------------------------------------------------------------
-- TVALID MUX
-- MUX tvalid out channel port
---------------------------------------------------------------------------
TVALID_TDATA_MUX : process(writing_curdesc,
                                writing_nxtdesc,
                                ftch_active,
                                curdesc_tvalid,
                                curdesc_tdata,
                                m_axis_mm2s_tvalid,
                                m_axis_mm2s_tdata,
                                m_axis_mm2s_tlast)
    begin
        -- Select current descriptor to drive out (Queue or Channel Port)
        if(writing_curdesc = '1')then
            ftch_tvalid  <= curdesc_tvalid;
            ftch_tdata   <= curdesc_tdata;
            ftch_tlast   <= '0';
        -- Deassert tvalid when capturing next descriptor pointer
        elsif(writing_nxtdesc = '1')then
            ftch_tvalid  <= '0';
            ftch_tdata   <= (others => '0');
            ftch_tlast   <= '0';
        -- Otherwise drive data from Datamover out (Queue or Channel Port)
        elsif(ftch_active = '1')then
            ftch_tvalid  <= m_axis_mm2s_tvalid;
            ftch_tdata   <= m_axis_mm2s_tdata;
            ftch_tlast   <= m_axis_mm2s_tlast;
        else
            ftch_tvalid  <= '0';
            ftch_tdata   <= (others => '0');
            ftch_tlast   <= '0';
        end if;
    end process TVALID_TDATA_MUX;



GEN_FIFO_FOR_SYNC : if C_AXIS_IS_ASYNC = 0 generate
begin
    -- Generate Synchronous FIFO
    I_CH1_FTCH_FIFO : entity lib_fifo_v1_0.sync_fifo_fg
    generic map (
        C_FAMILY                =>  C_FAMILY                ,
        C_MEMORY_TYPE           =>  MEMORY_TYPE             ,
        C_WRITE_DATA_WIDTH      =>  C_M_AXIS_SG_TDATA_WIDTH + 1,
        C_WRITE_DEPTH           =>  FETCH_QUEUE_DEPTH       ,
        C_READ_DATA_WIDTH       =>  C_M_AXIS_SG_TDATA_WIDTH + 1,
        C_READ_DEPTH            =>  FETCH_QUEUE_DEPTH       ,
        C_PORTS_DIFFER          =>  0,
        C_HAS_DCOUNT            =>  1,
        C_DCOUNT_WIDTH          =>  FETCH_QUEUE_CNT_WIDTH,
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

        Clk             =>  m_axi_sg_aclk       ,
        Sinit           =>  queue_sinit         ,
        Din             =>  queue_din           ,
        Wr_en           =>  queue_wren          ,
        Rd_en           =>  queue_rden          ,
        Dout            =>  queue_dout          ,
        Full            =>  queue_full          ,
        Empty           =>  queue_empty         ,
        Almost_full     =>  open                ,
        Data_count      =>  queue_dcount        ,
        Rd_ack          =>  open                ,
        Rd_err          =>  open                ,
        Wr_ack          =>  open                ,
        Wr_err          =>  open

    );

--    REG_DESC_PULLED : process(m_axi_sg_aclk)
--        begin
--            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk='1')then
--                if(m_axi_sg_aresetn = '0')then
--                    ftch_descpulled <= '0';
--                -- tlast read from fifo then complete descriptor read out
--                elsif(queue_rden = '1' and queue_dout(C_M_AXIS_SG_TDATA_WIDTH) = '1')then
--                    ftch_descpulled <= '1';
--                else
--                    ftch_descpulled <= '0';
--                end if;
--            end if;
--        end process REG_DESC_PULLED;


end generate GEN_FIFO_FOR_SYNC;

GEN_FIFO_FOR_ASYNC : if C_AXIS_IS_ASYNC = 1 generate
begin
    -- Generate Asynchronous FIFO
    I_CH1_FTCH_FIFO : entity axi_vdma_v6_2.axi_sg_afifo_autord
      generic map(
         C_DWIDTH        => C_M_AXIS_SG_TDATA_WIDTH + 1         ,
         C_DEPTH         => FETCH_QUEUE_DEPTH                   ,
         C_CNT_WIDTH     => FETCH_QUEUE_CNT_WIDTH               ,
         C_USE_BLKMEM    => MEMORY_TYPE                         ,
         C_FAMILY        => C_FAMILY
        )
      port map(
        -- Inputs
         AFIFO_Ainit                => queue_sinit              ,
         AFIFO_Wr_clk               => m_axi_sg_aclk            ,
         AFIFO_Wr_en                => queue_wren               ,
         AFIFO_Din                  => queue_din                ,
         AFIFO_Rd_clk               => m_axis_ftch_aclk         ,
         AFIFO_Rd_en                => queue_rden               ,
         AFIFO_Clr_Rd_Data_Valid    => '0'                      ,

        -- Outputs
         AFIFO_DValid               => open                     ,
         AFIFO_Dout                 => queue_dout               ,
         AFIFO_Full                 => queue_full               ,
         AFIFO_Empty                => queue_empty              ,
         AFIFO_Almost_full          => open                     ,
         AFIFO_Almost_empty         => open                     ,
         AFIFO_Wr_count             => queue_dcount             ,
         AFIFO_Rd_count             => open                     ,
         AFIFO_Corr_Rd_count        => open                     ,
         AFIFO_Corr_Rd_count_minus1 => open                     ,
         AFIFO_Rd_ack               => open
        );


end generate GEN_FIFO_FOR_ASYNC;





-----------------------------------------------------------------------
-- Internal Side
-----------------------------------------------------------------------
queue_sinit <= desc_flush or not m_axi_sg_aresetn;

-- Drive tready with fifo not full
ftch_tready <= not queue_full;

-- Drive out to datamover
m_axis_mm2s_tready <= ftch_tready;

-- Build FIFO data in, appending tlast bit
queue_din(C_M_AXIS_SG_TDATA_WIDTH)               <= ftch_tlast;
queue_din(C_M_AXIS_SG_TDATA_WIDTH-1 downto 0)    <= ftch_tdata;

-- Write to fifo if it is not full and data is valid
queue_wren  <= not queue_full
               and ftch_tvalid;

-- Pass fifo status back to fetch sm for channel IDLE determination
--ftch_queue_empty    <= queue_empty; CR 621600
ftch_queue_empty <= '1' when queue_dcount = ZERO_COUNT and queue_wren = '0'
               else '0';


ftch_queue_full     <= queue_full;

ftch_pause <= '1' when queue_dcount(DCNT_HI_INDEX
                             downto DCNT_LO_INDEX) >= SG_FTCH_DESC2QUEUE_VECT
         else '0';

-----------------------------------------------------------------------
-- Channel Port Side
-----------------------------------------------------------------------
-- Read if fifo is not empty and target is ready
queue_rden  <= not queue_empty
               and m_axis_ftch_tready;

-- drive valid if fifo is not empty
m_axis_ftch_tvalid  <= not queue_empty;

-- Pass data out to port channel with MSB driving tlast
m_axis_ftch_tlast   <= not queue_empty and queue_dout(C_M_AXIS_SG_TDATA_WIDTH);
m_axis_ftch_tdata   <= queue_dout(C_M_AXIS_SG_TDATA_WIDTH-1 downto 0);


-- If writing curdesc out then flag for proper mux selection
writing_curdesc     <= curdesc_tvalid;
-- Map intnal signal to port
writing_curdesc_out <= writing_curdesc;
-- Map port to internal signal
writing_nxtdesc     <= writing_nxtdesc_in;


end implementation;
