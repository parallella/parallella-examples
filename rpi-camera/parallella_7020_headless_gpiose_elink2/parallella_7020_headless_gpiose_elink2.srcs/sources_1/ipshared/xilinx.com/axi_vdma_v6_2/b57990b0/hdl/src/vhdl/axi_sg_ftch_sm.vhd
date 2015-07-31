-------------------------------------------------------------------------------
-- axi_sg_ftch_sm
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
-- Filename:          axi_sg_ftch_sm.vhd
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
--  GAB     6/10/10    v1_00_a
-- ^^^^^^
-- Fixed issue with fetch idle asserting too soon when simultaneous update
-- decode error and stale descriptor error detected. This fixes CR564855.
-- ~~~~~~
--  GAB     8/26/10    v2_00_a
-- ^^^^^^
--  Rolled axi_sg library version to version v2_00_a
-- ~~~~~~
--  GAB     10/21/10    v4_03
-- ^^^^^^
--  Rolled version to v4_03
-- ~~~~~~
--  GAB     12/07/10    v4_03
-- ^^^^^^
-- CR585958 Constant declaration in axi_sg_ftch_sm needs to move under
--          associated generate
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

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;

-------------------------------------------------------------------------------
entity  axi_sg_ftch_sm is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64    := 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_INCLUDE_CH1               : integer range 0 to 1      := 1;
            -- Include or Exclude channel 1 scatter gather engine
            -- 0 = Exclude Channel 1 SG Engine
            -- 1 = Include Channel 1 SG Engine

        C_INCLUDE_CH2               : integer range 0 to 1       := 1;
            -- Include or Exclude channel 2 scatter gather engine
            -- 0 = Exclude Channel 2 SG Engine
            -- 1 = Include Channel 2 SG Engine

        C_SG_CH1_WORDS_TO_FETCH     : integer range 4 to 16      := 8;
            -- Number of words to fetch

        C_SG_CH2_WORDS_TO_FETCH     : integer range 4 to 16      := 8;
            -- Number of words to fetch

        C_SG_FTCH_DESC2QUEUE     : integer range 0 to 8          := 0;
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
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
        updt_error                  : in  std_logic                         ;                   --
                                                                                                --
        -- Channel 1 Control and Status                                                         --
        ch1_run_stop                : in  std_logic                         ;                   --
        ch1_desc_flush              : in  std_logic                         ;                   --
        ch1_updt_done               : in  std_logic                         ;                   --
        ch1_sg_idle                 : in  std_logic                         ;                   --
        ch1_tailpntr_enabled        : in  std_logic                         ;                   --
        ch1_ftch_queue_full         : in  std_logic                         ;                   --
        ch1_ftch_queue_empty        : in  std_logic                         ;                   --
        ch1_ftch_pause              : in  std_logic                         ;                   --
        ch1_fetch_address           : in std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        ch1_ftch_active             : out std_logic                         ;                   --
        ch1_ftch_idle               : out std_logic                         ;                   --
        ch1_ftch_interr_set         : out std_logic                         ;                   --
        ch1_ftch_slverr_set         : out std_logic                         ;                   --
        ch1_ftch_decerr_set         : out std_logic                         ;                   --
        ch1_ftch_err_early          : out std_logic                         ;                   --
        ch1_ftch_stale_desc         : out std_logic                         ;                   --
                                                                                                --
        -- Channel 2 Control and Status                                                         --
        ch2_run_stop                : in  std_logic                         ;                   --
        ch2_desc_flush              : in  std_logic                         ;                   --
        ch2_updt_done               : in  std_logic                         ;                   --
        ch2_sg_idle                 : in  std_logic                         ;                   --
        ch2_tailpntr_enabled        : in  std_logic                         ;                   --
        ch2_ftch_queue_full         : in  std_logic                         ;                   --
        ch2_ftch_queue_empty        : in  std_logic                         ;                   --
        ch2_ftch_pause              : in  std_logic                         ;                   --
        ch2_fetch_address           : in std_logic_vector                                       --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                   --
        ch2_ftch_active             : out std_logic                         ;                   --
        ch2_ftch_idle               : out std_logic                         ;                   --
        ch2_ftch_interr_set         : out std_logic                         ;                   --
        ch2_ftch_slverr_set         : out std_logic                         ;                   --
        ch2_ftch_decerr_set         : out std_logic                         ;                   --
        ch2_ftch_err_early          : out std_logic                         ;                   --
        ch2_ftch_stale_desc         : out std_logic                         ;                   --
                                                                                                --
        -- DataMover Command                                                                    --
        ftch_cmnd_wr                : out std_logic                         ;                   --
        ftch_cmnd_data              : out std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
        -- DataMover Status                                                                     --
        ftch_done                   : in  std_logic                         ;                   --
        ftch_error                  : in  std_logic                         ;                   --
        ftch_interr                 : in  std_logic                         ;                   --
        ftch_slverr                 : in  std_logic                         ;                   --
        ftch_decerr                 : in  std_logic                         ;                   --
        ftch_stale_desc             : in  std_logic                         ;                   --
        ftch_error_early            : in  std_logic                         ;                   --
        ftch_error_addr             : out std_logic_vector                                      --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)                      --


    );

end axi_sg_ftch_sm;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_sm is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- DataMover Commmand TAG
constant FETCH_CMD_TAG      : std_logic_vector(3 downto 0)  := (others => '0');
-- DataMover Command Type
constant FETCH_CMD_TYPE     : std_logic := '1';
-- DataMover Cmnd Reserved Bits
constant FETCH_MSB_IGNORED  : std_logic_vector(7 downto 0)  := (others => '0');
-- DataMover Cmnd Reserved Bits
constant FETCH_LSB_IGNORED  : std_logic_vector(15 downto 0) := (others => '0');
-- DataMover Cmnd Bytes to Xfer for Channel 1
constant FETCH_CH1_CMD_BTT  : std_logic_vector(SG_BTT_WIDTH-1 downto 0)
                                := std_logic_vector(to_unsigned(
                                (C_SG_CH1_WORDS_TO_FETCH*4),SG_BTT_WIDTH));
-- DataMover Cmnd Bytes to Xfer for Channel 2
constant FETCH_CH2_CMD_BTT  : std_logic_vector(SG_BTT_WIDTH-1 downto 0)
                                := std_logic_vector(to_unsigned(
                                (C_SG_CH2_WORDS_TO_FETCH*4),SG_BTT_WIDTH));
-- DataMover Cmnd Reserved Bits
constant FETCH_CMD_RSVD     : std_logic_vector(
                                DATAMOVER_CMD_RSVMSB_BOFST + C_M_AXI_SG_ADDR_WIDTH downto
                                DATAMOVER_CMD_RSVLSB_BOFST + C_M_AXI_SG_ADDR_WIDTH)
                                := (others => '0');

-- CR585958 Constant declaration in axi_sg_ftch_sm needs to move under associated generate
-- Required width in bits for C_SG_FTCH_DESC2QUEUE
--constant SG_FTCH_DESC2QUEUE_WIDTH : integer := clog2(C_SG_FTCH_DESC2QUEUE+1);
--
---- Vector version of C_SG_FTCH_DESC2QUEUE
--constant SG_FTCH_DESC2QUEUE_VEC   : std_logic_vector(SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0)
--                                    := std_logic_vector(to_unsigned
--                                    (C_SG_FTCH_DESC2QUEUE,SG_FTCH_DESC2QUEUE_WIDTH));


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
type SG_FTCH_STATE_TYPE      is (
                                IDLE,
                                FETCH_DESCRIPTOR,
                                FETCH_STATUS,
                                FETCH_ERROR
                                );

signal ftch_cs                  : SG_FTCH_STATE_TYPE;
signal ftch_ns                  : SG_FTCH_STATE_TYPE;


-- State Machine Signals
signal ch1_active_set           : std_logic := '0';
signal ch2_active_set           : std_logic := '0';
signal write_cmnd_cmb           : std_logic := '0';
signal ch1_ftch_sm_idle         : std_logic := '0';
signal ch2_ftch_sm_idle         : std_logic := '0';
signal ch1_pause_fetch          : std_logic := '0';
signal ch2_pause_fetch          : std_logic := '0';


-- Misc Signals
signal fetch_cmd_addr           : std_logic_vector
                                    (C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal ch1_active_i             : std_logic := '0';
signal service_ch1              : std_logic := '0';

signal ch2_active_i             : std_logic := '0';
signal service_ch2              : std_logic := '0';

signal fetch_cmd_btt            : std_logic_vector
                                    (SG_BTT_WIDTH-1 downto 0) := (others => '0');
signal ch1_stale_descriptor     : std_logic := '0';
signal ch2_stale_descriptor     : std_logic := '0';

signal ch1_ftch_interr_set_i    : std_logic := '0';
signal ch2_ftch_interr_set_i    : std_logic := '0';

-- CR585958 Constant declaration in axi_sg_ftch_sm needs to move under associated generate
-- counts for keeping track of queue descriptors to prevent
-- fifo fill
--signal ch1_desc_ftched_count    : std_logic_vector
--                                    (SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0) := (others => '0');
--signal ch2_desc_ftched_count    : std_logic_vector
--                                    (SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
ch1_ftch_active  <= ch1_active_i;
ch2_ftch_active  <= ch2_active_i;


-------------------------------------------------------------------------------
-- Scatter Gather Fetch State Machine
-------------------------------------------------------------------------------
SG_FTCH_MACHINE : process(ftch_cs,
                            ch1_active_i,
                            ch2_active_i,
                            service_ch1,
                            service_ch2,
                            ftch_error,
                            ftch_done)

    begin
        -- Default signal assignment
        ch1_active_set          <= '0';
        ch2_active_set          <= '0';
        write_cmnd_cmb          <= '0';
        ch1_ftch_sm_idle        <= '0';
        ch2_ftch_sm_idle        <= '0';
        ftch_ns                 <= ftch_cs;

        case ftch_cs is

            -------------------------------------------------------------------
            when IDLE =>
                ch1_ftch_sm_idle       <=  not service_ch1;
                ch2_ftch_sm_idle       <=  not service_ch2;
                -- sg error during fetch - shut down
                if(ftch_error = '1')then
                    ftch_ns     <= FETCH_ERROR;
                -- If channel 1 is running and not idle and queue is not full
                -- then fetch descriptor for channel 1
                elsif(service_ch1 = '1')then
                    ch1_active_set  <= '1';
                    ftch_ns <= FETCH_DESCRIPTOR;
                -- If channel 2 is running and not idle and queue is not full
                -- then fetch descriptor for channel 2
                elsif(service_ch2 = '1')then
                    ch2_active_set  <= '1';
                    ftch_ns <= FETCH_DESCRIPTOR;

                else
                    ftch_ns                <= IDLE;
                end if;

            -------------------------------------------------------------------
            when FETCH_DESCRIPTOR =>
                -- sg error during fetch - shut down
                if(ftch_error = '1')then
                    ftch_ns     <= FETCH_ERROR;
                else
                    ch1_ftch_sm_idle    <= not ch1_active_i and not service_ch1;
                    ch2_ftch_sm_idle    <= not ch2_active_i and not service_ch2;
                    write_cmnd_cmb      <= '1';
                    ftch_ns             <= FETCH_STATUS;
                end if;

            -------------------------------------------------------------------
            when FETCH_STATUS =>

                ch1_ftch_sm_idle    <= not ch1_active_i and not service_ch1;
                ch2_ftch_sm_idle    <= not ch2_active_i and not service_ch2;

                -- sg error during fetch - shut down
                if(ftch_error = '1')then
                    ftch_ns     <= FETCH_ERROR;

                elsif(ftch_done = '1')then
                    -- If just finished fethcing for channel 2 then...
                    if(ch2_active_i = '1')then
                        -- If ready, fetch descriptor for channel 1
                        if(service_ch1 = '1')then
                            ch1_active_set <= '1';
                            ftch_ns <= FETCH_DESCRIPTOR;
                        -- Else if channel 2 still ready then fetch
                        -- another descriptor for channel 2
                        elsif(service_ch2 = '1')then
                            ch1_ftch_sm_idle    <= '1';
                            ftch_ns             <= FETCH_DESCRIPTOR;
                        -- Otherwise return to IDLE
                        else
                            ftch_ns <= IDLE;
                        end if;

                    -- If just finished fethcing for channel 1 then...
                    elsif(ch1_active_i = '1')then
                        -- If ready, fetch descriptor for channel 2
                        if(service_ch2 = '1')then
                            ch2_active_set <= '1';
                            ftch_ns <= FETCH_DESCRIPTOR;
                        -- Else if channel 1 still ready then fetch
                        -- another descriptor for channel 1
                        elsif(service_ch1 = '1')then
                            ch2_ftch_sm_idle    <= '1';
                            ftch_ns             <= FETCH_DESCRIPTOR;
                        -- Otherwise return to IDLE
                        else
                            ftch_ns <= IDLE;
                        end if;
                    else
                        ftch_ns <= IDLE;
                    end if;
                else
                    ftch_ns <= FETCH_STATUS;

                end if;

            -------------------------------------------------------------------
            when FETCH_ERROR =>
                ch1_ftch_sm_idle    <= '1';
                ch2_ftch_sm_idle    <= '1';
                ftch_ns             <= FETCH_ERROR;

            -------------------------------------------------------------------
            when others =>
                ftch_ns <= IDLE;

        end case;
    end process SG_FTCH_MACHINE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
REGISTER_STATE : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                ftch_cs     <= IDLE;
            else
                ftch_cs     <= ftch_ns;
            end if;
        end if;
    end process REGISTER_STATE;


-------------------------------------------------------------------------------
-- Channel included therefore generate fetch logic
-------------------------------------------------------------------------------
GEN_CH1_FETCH : if C_INCLUDE_CH1 = 1 generate
begin

    -------------------------------------------------------------------------------
    -- Active channel flag.  Indicates which channel is active.
    -- 0 = channel active
    -- 1 = channel active
    -------------------------------------------------------------------------------
    CH1_ACTIVE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or ch2_active_set = '1')then
                    ch1_active_i <= '0';
                elsif(ch1_active_set = '1')then
                    ch1_active_i <= '1';
                end if;
            end if;
        end process CH1_ACTIVE_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 IDLE process. Indicates channel 1 fetch process is IDLE
    -- This is 1 part of determining IDLE for a channel
    -------------------------------------------------------------------------------
    CH1_IDLE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch1_ftch_idle   <= '1';

                -- SG Error therefore force IDLE
                -- CR564855 - fetch idle asserted too soon when update error occured.
                -- fetch idle does not need to be concerned with updt_error.  This is
                -- because on going fetch is guarentteed to complete regardless of dma
                -- controller or sg update engine.
                --elsif(updt_error = '1' or ftch_error = '1'
                elsif(ftch_error = '1'
                or ch1_ftch_interr_set_i = '1')then
                    ch1_ftch_idle   <= '1';

                -- When SG Fetch no longer idle then clear fetch idle
                elsif(ch1_sg_idle = '0')then
                    ch1_ftch_idle   <= '0';

                -- If tail = cur and fetch queue is empty then
                elsif(ch1_sg_idle = '1' and ch1_ftch_queue_empty = '1' and ch1_ftch_sm_idle = '1')then
                    ch1_ftch_idle   <= '1';

                end if;
            end if;
        end process CH1_IDLE_PROCESS;

    -------------------------------------------------------------------------------
    -- For No Fetch Queue, generate pause logic to prevent partial descriptor from
    -- being fetched and then endless throttle on AXI read bus
    -------------------------------------------------------------------------------
    GEN_CH1_FETCH_PAUSE : if C_SG_FTCH_DESC2QUEUE = 0 generate
    begin
        REG_PAUSE_FETCH : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    -- On descriptor update done clear pause
                    if(m_axi_sg_aresetn = '0' or ch1_updt_done = '1')then
                        ch1_pause_fetch <= '0';
                    -- If channel active and command written then pause
                    elsif(ch1_active_i='1' and write_cmnd_cmb = '1')then
                        ch1_pause_fetch <= '1';
                    end if;
                 end if;
             end process REG_PAUSE_FETCH;
    end generate GEN_CH1_FETCH_PAUSE;

    -- Fetch queues so do not need to pause
    GEN_CH1_NO_FETCH_PAUSE : if C_SG_FTCH_DESC2QUEUE /= 0 generate
--    -- CR585958
--    -- Required width in bits for C_SG_FTCH_DESC2QUEUE
--    constant SG_FTCH_DESC2QUEUE_WIDTH : integer := clog2(C_SG_FTCH_DESC2QUEUE+1);
--    -- Vector version of C_SG_FTCH_DESC2QUEUE
--    constant SG_FTCH_DESC2QUEUE_VEC   : std_logic_vector(SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0)
--                                        := std_logic_vector(to_unsigned
--                                        (C_SG_FTCH_DESC2QUEUE,SG_FTCH_DESC2QUEUE_WIDTH));
--    signal desc_queued_incr     : std_logic := '0';
--    signal desc_queued_decr     : std_logic := '0';
--
--    -- CR585958
--    signal ch1_desc_ftched_count: std_logic_vector
--                                    (SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0) := (others => '0');
--    begin
--
--        desc_queued_incr <= '1' when ch1_active_i = '1'
--                                 and write_cmnd_cmb = '1'
--                                 and ch1_ftch_descpulled = '0'
--                       else '0';
--
--        desc_queued_decr <= '1' when ch1_ftch_descpulled = '1'
--                                and not (ch1_active_i = '1' and write_cmnd_cmb = '1')
--                       else '0';
--
--        -- Keep track of descriptors queued version descriptors updated
--        DESC_FETCHED_CNTR : process(m_axi_sg_aclk)
--            begin
--                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
--                    if(m_axi_sg_aresetn = '0')then
--                        ch1_desc_ftched_count <= (others => '0');
--                    elsif(desc_queued_incr = '1')then
--                        ch1_desc_ftched_count <= std_logic_vector(unsigned(ch1_desc_ftched_count) + 1);
--                    elsif(desc_queued_decr = '1')then
--                        ch1_desc_ftched_count <= std_logic_vector(unsigned(ch1_desc_ftched_count) - 1);
--                    end if;
--                end if;
--            end process DESC_FETCHED_CNTR;
--
--        REG_PAUSE_FETCH : process(m_axi_sg_aclk)
--            begin
--                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
--                    if(m_axi_sg_aresetn = '0')then
--                        ch1_pause_fetch <= '0';
--                    elsif(ch1_desc_ftched_count >= SG_FTCH_DESC2QUEUE_VEC)then
--                        ch1_pause_fetch <= '1';
--                    else
--                        ch1_pause_fetch <= '0';
--                    end if;
--                end if;
--            end process REG_PAUSE_FETCH;
--
--
--
            ch1_pause_fetch <= ch1_ftch_pause;

    end generate GEN_CH1_NO_FETCH_PAUSE;


    -------------------------------------------------------------------------------
    -- Channel 1 ready to be serviced?
    -------------------------------------------------------------------------------
    service_ch1 <= '1' when ch1_run_stop = '1'          -- Channel running
                        and ch1_sg_idle = '0'           -- SG Engine running
                        and ch1_ftch_queue_full = '0'   -- Queue not full
                        and updt_error = '0'            -- No SG Update error
                        and ch1_stale_descriptor = '0'  -- No Stale Descriptors
                        and ch1_desc_flush = '0'        -- Not flushing desc
                        and ch1_pause_fetch = '0'       -- Not pausing


              else '0';

    -------------------------------------------------------------------------------
    -- Log Fetch Errors
    -------------------------------------------------------------------------------
    INT_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch1_ftch_interr_set_i  <= '0';
                -- Channel active and datamover int error or fetch done and descriptor stale
                elsif((ch1_active_i = '1' and ftch_interr = '1')
                   or ((ftch_done = '1' or ftch_error = '1') and ch1_stale_descriptor = '1'))then
                    ch1_ftch_interr_set_i  <= '1';
                end if;
            end if;
        end process INT_ERROR_PROCESS;

    ch1_ftch_interr_set <= ch1_ftch_interr_set_i;


    SLV_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch1_ftch_slverr_set  <= '0';
                elsif(ch1_active_i = '1' and ftch_slverr = '1')then
                    ch1_ftch_slverr_set  <= '1';
                end if;
            end if;
        end process SLV_ERROR_PROCESS;

    DEC_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch1_ftch_decerr_set  <= '0';
                elsif(ch1_active_i = '1' and ftch_decerr = '1')then
                    ch1_ftch_decerr_set  <= '1';
                end if;
            end if;
        end process DEC_ERROR_PROCESS;


    -- Early detection of SlvErr or DecErr, used to prevent error'ed descriptor
    -- from being used by dma controller
    ch1_ftch_err_early  <= '1' when ftch_error_early = '1' and ch1_active_i = '1'
                      else '0';

    -- Enable stale descriptor check
    GEN_CH1_STALE_CHECK : if C_SG_CH1_ENBL_STALE_ERROR = 1 generate
    begin
        -----------------------------------------------------------------------
        -- Stale Descriptor Error
        -----------------------------------------------------------------------
        CH1_STALE_DESC : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    -- If reset then clear flag
                    if(m_axi_sg_aresetn = '0')then
                        ch1_stale_descriptor <= '0';
                    elsif(ftch_stale_desc = '1' and ch1_active_i = '1' )then
                        ch1_stale_descriptor <= '1';
                    end if;
                end if;
            end process CH1_STALE_DESC;

    end generate GEN_CH1_STALE_CHECK;

    -- Disable stale descriptor check
    GEN_CH1_NO_STALE_CHECK : if C_SG_CH1_ENBL_STALE_ERROR = 0 generate
    begin
        ch1_stale_descriptor <= '0';
    end generate GEN_CH1_NO_STALE_CHECK;


    -- Early detection of Stale Descriptor (valid only in tailpntr mode) used
    -- to prevent error'ed descriptor from being used.
    ch1_ftch_stale_desc <= ch1_stale_descriptor;

end generate GEN_CH1_FETCH;

-------------------------------------------------------------------------------
-- Channel excluded therefore do not generate fetch logic
-------------------------------------------------------------------------------
GEN_NO_CH1_FETCH : if C_INCLUDE_CH1 = 0 generate
begin
    service_ch1         <= '0';
    ch1_active_i        <= '0';
    ch1_ftch_idle       <= '0';
    ch1_ftch_interr_set <= '0';
    ch1_ftch_slverr_set <= '0';
    ch1_ftch_decerr_set <= '0';
    ch1_ftch_err_early  <= '0';
    ch1_ftch_stale_desc <= '0';
end generate GEN_NO_CH1_FETCH;


-------------------------------------------------------------------------------
-- Channel included therefore generate fetch logic
-------------------------------------------------------------------------------
GEN_CH2_FETCH : if C_INCLUDE_CH2 = 1 generate
begin
    -------------------------------------------------------------------------------
    -- Active channel flag.  Indicates which channel is active.
    -- 0 = channel active
    -- 1 = channel active
    -------------------------------------------------------------------------------
    CH2_ACTIVE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or ch1_active_set = '1')then
                    ch2_active_i <= '0';
                elsif(ch2_active_set = '1')then
                    ch2_active_i <= '1';
                end if;
            end if;
        end process CH2_ACTIVE_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 2 IDLE process. Indicates channel 2 fetch process is IDLE
    -- This is 1 part of determining IDLE for a channel
    -------------------------------------------------------------------------------
    CH2_IDLE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch2_ftch_idle   <= '1';

                -- SG Error therefore force IDLE
                -- CR564855 - fetch idle asserted too soon when update error occured.
                -- fetch idle does not need to be concerned with updt_error.  This is
                -- because on going fetch is guarentteed to complete regardless of dma
                -- controller or sg update engine.
--                elsif(updt_error = '1' or ftch_error = '1'
                elsif(ftch_error = '1'
                or ch2_ftch_interr_set_i = '1')then

                    ch2_ftch_idle   <= '1';

                -- When SG Fetch no longer idle then clear fetch idle
                elsif(ch2_sg_idle = '0')then
                    ch2_ftch_idle   <= '0';

                -- If tail = cur and fetch queue is empty then
                elsif(ch2_sg_idle = '1' and ch2_ftch_queue_empty = '1' and ch2_ftch_sm_idle = '1')then
                    ch2_ftch_idle   <= '1';
                end if;
            end if;
        end process CH2_IDLE_PROCESS;

    -------------------------------------------------------------------------------
    -- For No Fetch Queue, generate pause logic to prevent partial descriptor from
    -- being fetched and then endless throttle on AXI read bus
    -------------------------------------------------------------------------------
    GEN_CH2_FETCH_PAUSE : if C_SG_FTCH_DESC2QUEUE = 0 generate
    begin
        REG_PAUSE_FETCH : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    -- On descriptor update done clear pause
                    if(m_axi_sg_aresetn = '0' or ch2_updt_done = '1')then
                        ch2_pause_fetch <= '0';
                    -- If channel active and command written then pause
                    elsif(ch2_active_i='1' and write_cmnd_cmb = '1')then
                        ch2_pause_fetch <= '1';
                    end if;
                 end if;
             end process REG_PAUSE_FETCH;
    end generate GEN_CH2_FETCH_PAUSE;

    -- Fetch queues so do not need to pause
    GEN_CH2_NO_FETCH_PAUSE : if C_SG_FTCH_DESC2QUEUE /= 0 generate
--    -- CR585958
--    -- Required width in bits for C_SG_FTCH_DESC2QUEUE
--    constant SG_FTCH_DESC2QUEUE_WIDTH : integer := clog2(C_SG_FTCH_DESC2QUEUE+1);
--    -- Vector version of C_SG_FTCH_DESC2QUEUE
--    constant SG_FTCH_DESC2QUEUE_VEC   : std_logic_vector(SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0)
--                                        := std_logic_vector(to_unsigned
--                                        (C_SG_FTCH_DESC2QUEUE,SG_FTCH_DESC2QUEUE_WIDTH));
--    signal desc_queued_incr     : std_logic := '0';
--    signal desc_queued_decr     : std_logic := '0';
--
--    -- CR585958
--    signal ch2_desc_ftched_count: std_logic_vector
--                                    (SG_FTCH_DESC2QUEUE_WIDTH-1 downto 0) := (others => '0');
--
--    begin
--
--        desc_queued_incr <= '1' when ch2_active_i = '1'
--                                 and write_cmnd_cmb = '1'
--                                 and ch2_ftch_descpulled = '0'
--                       else '0';
--
--        desc_queued_decr <= '1' when ch2_ftch_descpulled = '1'
--                                and not (ch2_active_i = '1' and write_cmnd_cmb = '1')
--                       else '0';
--
--        -- Keep track of descriptors queued version descriptors updated
--        DESC_FETCHED_CNTR : process(m_axi_sg_aclk)
--            begin
--                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
--                    if(m_axi_sg_aresetn = '0')then
--                        ch2_desc_ftched_count <= (others => '0');
--                    elsif(desc_queued_incr = '1')then
--                        ch2_desc_ftched_count <= std_logic_vector(unsigned(ch2_desc_ftched_count) + 1);
--                    elsif(desc_queued_decr = '1')then
--                        ch2_desc_ftched_count <= std_logic_vector(unsigned(ch2_desc_ftched_count) - 1);
--                    end if;
--                end if;
--            end process DESC_FETCHED_CNTR;
--
--        REG_PAUSE_FETCH : process(m_axi_sg_aclk)
--            begin
--                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
--                    if(m_axi_sg_aresetn = '0')then
--                        ch2_pause_fetch <= '0';
--                    elsif(ch2_desc_ftched_count >= SG_FTCH_DESC2QUEUE_VEC)then
--                        ch2_pause_fetch <= '1';
--                    else
--                        ch2_pause_fetch <= '0';
--                    end if;
--                end if;
--            end process REG_PAUSE_FETCH;
--
            ch2_pause_fetch <= ch2_ftch_pause;
    end generate GEN_CH2_NO_FETCH_PAUSE;

    -------------------------------------------------------------------------------
    -- Channel 2 ready to be serviced?
    -------------------------------------------------------------------------------
    service_ch2 <= '1' when ch2_run_stop = '1'          -- Channel running
                        and ch2_sg_idle = '0'           -- SG Engine running
                        and ch2_ftch_queue_full = '0'   -- Queue not full
                        and updt_error = '0'            -- No SG Update error
                        and ch2_stale_descriptor = '0'  -- No Stale Descriptors
                        and ch2_desc_flush = '0'        -- Not flushing desc
                        and ch2_pause_fetch = '0'       -- No fetch pause
              else '0';

    -------------------------------------------------------------------------------
    -- Log Fetch Errors
    -------------------------------------------------------------------------------
    INT_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch2_ftch_interr_set_i  <= '0';
                -- Channel active and datamover int error or fetch done and descriptor stale
                elsif((ch2_active_i = '1' and ftch_interr = '1')
                   or ((ftch_done = '1' or ftch_error = '1') and ch2_stale_descriptor = '1'))then
                    ch2_ftch_interr_set_i  <= '1';
                end if;
            end if;
        end process INT_ERROR_PROCESS;

    ch2_ftch_interr_set <= ch2_ftch_interr_set_i;

    SLV_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch2_ftch_slverr_set  <= '0';
                elsif(ch2_active_i = '1' and ftch_slverr = '1')then
                    ch2_ftch_slverr_set  <= '1';
                end if;
            end if;
        end process SLV_ERROR_PROCESS;

    DEC_ERROR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- If reset or stopped then clear idle bit
                if(m_axi_sg_aresetn = '0')then
                    ch2_ftch_decerr_set  <= '0';
                elsif(ch2_active_i = '1' and ftch_decerr = '1')then
                    ch2_ftch_decerr_set  <= '1';
                end if;
            end if;
        end process DEC_ERROR_PROCESS;

    -- Early detection of SlvErr or DecErr, used to prevent error'ed descriptor
    -- from being used by dma controller
    ch2_ftch_err_early  <= '1' when ftch_error_early = '1' and ch2_active_i = '1'
                      else '0';


    -- Enable stale descriptor check
    GEN_CH2_STALE_CHECK : if C_SG_CH2_ENBL_STALE_ERROR = 1 generate
    begin
        -----------------------------------------------------------------------
        -- Stale Descriptor Error
        -----------------------------------------------------------------------
        CH2_STALE_DESC : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    -- If reset then clear flag
                    if(m_axi_sg_aresetn = '0')then
                        ch2_stale_descriptor <= '0';
                    elsif(ftch_stale_desc = '1' and ch2_active_i = '1' )then
                        ch2_stale_descriptor <= '1';
                    end if;
                end if;
            end process CH2_STALE_DESC;

    end generate GEN_CH2_STALE_CHECK;

    -- Disable stale descriptor check
    GEN_CH2_NO_STALE_CHECK : if C_SG_CH2_ENBL_STALE_ERROR = 0 generate
    begin
        ch2_stale_descriptor <= '0';
    end generate GEN_CH2_NO_STALE_CHECK;

    -- Early detection of Stale Descriptor (valid only in tailpntr mode) used
    -- to prevent error'ed descriptor from being used.
    ch2_ftch_stale_desc <= ch2_stale_descriptor;

end generate GEN_CH2_FETCH;

-------------------------------------------------------------------------------
-- Channel excluded therefore do not generate fetch logic
-------------------------------------------------------------------------------
GEN_NO_CH2_FETCH : if C_INCLUDE_CH2 = 0 generate
begin
    service_ch2         <= '0';
    ch2_active_i        <= '0';
    ch2_ftch_idle       <= '0';
    ch2_ftch_interr_set <= '0';
    ch2_ftch_slverr_set <= '0';
    ch2_ftch_decerr_set <= '0';
    ch2_ftch_err_early  <= '0';
    ch2_ftch_stale_desc <= '0';
end generate GEN_NO_CH2_FETCH;

-------------------------------------------------------------------------------
-- Build DataMover command
-------------------------------------------------------------------------------
-- Assign fetch address
fetch_cmd_addr  <= ch1_fetch_address when ch1_active_i = '1'
             else  ch2_fetch_address;

-- Assign bytes to transfer (BTT)
fetch_cmd_btt   <= FETCH_CH1_CMD_BTT when ch1_active_i = '1'
             else  FETCH_CH2_CMD_BTT;


-- When command by sm, drive command to ftch_cmdsts_if
GEN_DATAMOVER_CMND : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                ftch_cmnd_wr    <= '0';
                ftch_cmnd_data  <= (others => '0');

            -- Fetch SM issued a command write
            elsif(write_cmnd_cmb = '1')then
                ftch_cmnd_wr    <= '1';
                ftch_cmnd_data  <=  FETCH_CMD_RSVD
                                    & FETCH_CMD_TAG
                                    & fetch_cmd_addr
                                    & FETCH_MSB_IGNORED
                                    & FETCH_CMD_TYPE
                                    & FETCH_LSB_IGNORED
                                    & fetch_cmd_btt;
            else
                ftch_cmnd_wr    <= '0';

            end if;
        end if;
    end process GEN_DATAMOVER_CMND;

-------------------------------------------------------------------------------
-- Capture and hold fetch address in case an error occurs
-------------------------------------------------------------------------------
LOG_ERROR_ADDR : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                ftch_error_addr    <= (others => '0');
            elsif(write_cmnd_cmb = '1')then
                ftch_error_addr    <= fetch_cmd_addr;
            end if;
        end if;
    end process LOG_ERROR_ADDR;



end implementation;
