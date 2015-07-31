-------------------------------------------------------------------------------
-- axi_sg_updt_sm
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
-- Filename:          axi_sg_updt_sm.vhd
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
entity  axi_sg_updt_sm is
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

        C_SG_CH1_WORDS_TO_UPDATE    : integer range 1 to 16     := 8;
            -- Number of words to fetch

        C_SG_CH1_FIRST_UPDATE_WORD  : integer range 0 to 15     := 0;
            -- Starting update word offset

        C_SG_CH2_WORDS_TO_UPDATE    : integer range 1 to 16     := 8;
            -- Number of words to fetch

        C_SG_CH2_FIRST_UPDATE_WORD  : integer range 0 to 15     := 0
            -- Starting update word offset

    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                  --
        m_axi_sg_aresetn            : in  std_logic                         ;                  --
                                                                                               --
        ftch_error                  : in  std_logic                         ;                  --
                                                                                               --
        -- Channel 1 Control and Status                                                        --
        ch1_updt_queue_empty        : in  std_logic                         ;                  --
        ch1_updt_curdesc_wren       : in  std_logic                         ;                  --
        ch1_updt_curdesc            : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
        ch1_updt_ioc                : in  std_logic                         ;                  --
        ch1_dma_interr              : in  std_logic                         ;                  --
        ch1_dma_slverr              : in  std_logic                         ;                  --
        ch1_dma_decerr              : in  std_logic                         ;                  --
        ch1_updt_active             : out std_logic                         ;                  --
        ch1_updt_idle               : out std_logic                         ;                  --
        ch1_updt_interr_set         : out std_logic                         ;                  --
        ch1_updt_slverr_set         : out std_logic                         ;                  --
        ch1_updt_decerr_set         : out std_logic                         ;                  --
        ch1_dma_interr_set          : out std_logic                         ;                  --
        ch1_dma_slverr_set          : out std_logic                         ;                  --
        ch1_dma_decerr_set          : out std_logic                         ;                  --
        ch1_updt_ioc_irq_set        : out std_logic                         ;                  --
        ch1_updt_done               : out std_logic                         ;                  --
                                                                                               --
        -- Channel 2 Control and Status                                                        --
        ch2_updt_queue_empty        : in  std_logic                         ;                  --
        ch2_updt_curdesc_wren       : in  std_logic                         ;                  --
        ch2_updt_curdesc            : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
        ch2_updt_ioc                : in  std_logic                         ;                  --
        ch2_dma_interr              : in  std_logic                         ;                  --
        ch2_dma_slverr              : in  std_logic                         ;                  --
        ch2_dma_decerr              : in  std_logic                         ;                  --
        ch2_updt_active             : out std_logic                         ;                  --
        ch2_updt_idle               : out std_logic                         ;                  --
        ch2_updt_interr_set         : out std_logic                         ;                  --
        ch2_updt_slverr_set         : out std_logic                         ;                  --
        ch2_updt_decerr_set         : out std_logic                         ;                  --
        ch2_dma_interr_set          : out std_logic                         ;                  --
        ch2_dma_slverr_set          : out std_logic                         ;                  --
        ch2_dma_decerr_set          : out std_logic                         ;                  --
        ch2_updt_ioc_irq_set        : out std_logic                         ;                  --
        ch2_updt_done               : out std_logic                         ;                  --
                                                                                               --
        -- DataMover Command                                                                   --
        updt_cmnd_wr                : out std_logic                         ;                  --
        updt_cmnd_data              : out std_logic_vector                                     --
                                        ((C_M_AXI_SG_ADDR_WIDTH                                --
                                        +CMD_BASE_WIDTH)-1 downto 0)        ;                  --
        -- DataMover Status                                                                    --
        updt_done                   : in  std_logic                         ;                  --
        updt_error                  : in  std_logic                         ;                  --
        updt_interr                 : in  std_logic                         ;                  --
        updt_slverr                 : in  std_logic                         ;                  --
        updt_decerr                 : in  std_logic                         ;                  --
        updt_error_addr             : out std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)                     --
    );

end axi_sg_updt_sm;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_updt_sm is
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
constant UPDATE_CMD_TAG      : std_logic_vector(3 downto 0)  := (others => '0');
-- DataMover Command Type
constant UPDATE_CMD_TYPE     : std_logic := '0';
-- DataMover Cmnd Reserved Bits
constant UPDATE_MSB_IGNORED  : std_logic_vector(7 downto 0)  := (others => '0');
-- DataMover Cmnd Reserved Bits
constant UPDATE_LSB_IGNORED  : std_logic_vector(15 downto 0) := (others => '0');
-- DataMover Cmnd Bytes to Xfer for Channel 1
constant UPDATE_CH1_CMD_BTT  : std_logic_vector(SG_BTT_WIDTH-1 downto 0)
                                := std_logic_vector(to_unsigned(
                                (C_SG_CH1_WORDS_TO_UPDATE*4),SG_BTT_WIDTH));
-- DataMover Cmnd Bytes to Xfer for Channel 2
constant UPDATE_CH2_CMD_BTT  : std_logic_vector(SG_BTT_WIDTH-1 downto 0)
                                := std_logic_vector(to_unsigned(
                                (C_SG_CH2_WORDS_TO_UPDATE*4),SG_BTT_WIDTH));
-- DataMover Cmnd Reserved Bits
constant UPDATE_CMD_RSVD     : std_logic_vector(
                                DATAMOVER_CMD_RSVMSB_BOFST + C_M_AXI_SG_ADDR_WIDTH downto
                                DATAMOVER_CMD_RSVLSB_BOFST + C_M_AXI_SG_ADDR_WIDTH)
                                := (others => '0');
-- DataMover Cmnd Address Offset for channel 1
constant UPDATE_CH1_ADDR_OFFSET  : integer := C_SG_CH1_FIRST_UPDATE_WORD*4;
-- DataMover Cmnd Address Offset for channel 2
constant UPDATE_CH2_ADDR_OFFSET  : integer := C_SG_CH2_FIRST_UPDATE_WORD*4;


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
type SG_UPDATE_STATE_TYPE      is (
                                IDLE,
                                GET_UPDATE_PNTR,
                                UPDATE_DESCRIPTOR,
                                UPDATE_STATUS,
                                UPDATE_ERROR
                                );

signal updt_cs                  : SG_UPDATE_STATE_TYPE;
signal updt_ns                  : SG_UPDATE_STATE_TYPE;


-- State Machine Signals
signal ch1_active_set           : std_logic := '0';
signal ch2_active_set           : std_logic := '0';
signal write_cmnd_cmb           : std_logic := '0';
signal ch1_updt_sm_idle         : std_logic := '0';
signal ch2_updt_sm_idle         : std_logic := '0';

-- Misc Signals
signal ch1_active_i             : std_logic := '0';
signal service_ch1              : std_logic := '0';

signal ch2_active_i             : std_logic := '0';
signal service_ch2              : std_logic := '0';

signal update_address           : std_logic_vector
                                    (C_M_AXI_SG_ADDR_WIDTH-1 downto 0) := (others => '0');
signal update_cmd_btt           : std_logic_vector
                                    (SG_BTT_WIDTH-1 downto 0) := (others => '0');


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
ch1_updt_active  <= ch1_active_i;
ch2_updt_active  <= ch2_active_i;

-------------------------------------------------------------------------------
-- Scatter Gather Fetch State Machine
-------------------------------------------------------------------------------
SG_UPDT_MACHINE : process(updt_cs,
                            ch1_active_i,
                            ch2_active_i,
                            service_ch1,
                            service_ch2,
                            ch1_updt_curdesc_wren,
                            ch2_updt_curdesc_wren,
                            updt_error,
                            updt_done)

    begin
        -- Default signal assignment
        ch1_active_set          <= '0';
        ch2_active_set          <= '0';
        write_cmnd_cmb          <= '0';
        ch1_updt_sm_idle        <= '0';
        ch2_updt_sm_idle        <= '0';
        updt_ns                 <= updt_cs;

        case updt_cs is

            -------------------------------------------------------------------
            when IDLE =>
                ch1_updt_sm_idle       <= not service_ch1;
                ch2_updt_sm_idle       <= not service_ch2;
                -- error during update - therefore shut down
                if(updt_error = '1')then
                    updt_ns     <= UPDATE_ERROR;
                -- If channel 1 is running and not idle and queue is not full
                -- then fetch descriptor for channel 1
                elsif(service_ch1 = '1')then
                    ch1_active_set  <= '1';
                    updt_ns <= GET_UPDATE_PNTR;
                -- If channel 2 is running and not idle and queue is not full
                -- then fetch descriptor for channel 2
                elsif(service_ch2 = '1')then
                    ch2_active_set  <= '1';
                    updt_ns <= GET_UPDATE_PNTR;
                else
                    updt_ns <= IDLE;
                end if;

            when GET_UPDATE_PNTR =>
                if(ch1_updt_curdesc_wren = '1' or ch2_updt_curdesc_wren = '1')then
                    updt_ns <= UPDATE_DESCRIPTOR;
                else
                    updt_ns <= GET_UPDATE_PNTR;
                end if;

            -------------------------------------------------------------------
            when UPDATE_DESCRIPTOR =>
                -- error during update - therefore shut down
                if(updt_error = '1')then
                    updt_ns     <= UPDATE_ERROR;
                -- write command
                else
                    ch1_updt_sm_idle        <= not ch1_active_i and not service_ch1;
                    ch2_updt_sm_idle        <= not ch2_active_i and not service_ch2;
                    write_cmnd_cmb          <= '1';
                    updt_ns                 <= UPDATE_STATUS;
                end if;

            -------------------------------------------------------------------
            when UPDATE_STATUS =>
                ch1_updt_sm_idle        <= not ch1_active_i and not service_ch1;
                ch2_updt_sm_idle        <= not ch2_active_i and not service_ch2;
                -- error during update - therefore shut down
                if(updt_error = '1')then
                    updt_ns     <= UPDATE_ERROR;
                -- wait until done with update
                elsif(updt_done = '1')then

                    -- If just finished fethcing for channel 2 then...
                    if(ch2_active_i = '1')then
                        -- If ready, update descriptor for channel 1
                        if(service_ch1 = '1')then
                            ch1_active_set <= '1';
                            updt_ns <= GET_UPDATE_PNTR;
                        -- Otherwise return to IDLE
                        else
                            updt_ns <= IDLE;
                        end if;

                    -- If just finished fethcing for channel 1 then...
                    elsif(ch1_active_i = '1')then
                        -- If ready, update descriptor for channel 2
                        if(service_ch2 = '1')then
                            ch2_active_set <= '1';
                            updt_ns <= GET_UPDATE_PNTR;
                        -- Otherwise return to IDLE
                        else
                            updt_ns <= IDLE;
                        end if;
                    else
                        updt_ns <= IDLE;
                    end if;
                else
                    updt_ns <= UPDATE_STATUS;
                end if;

            -------------------------------------------------------------------
            when UPDATE_ERROR =>
                ch1_updt_sm_idle       <= '1';
                ch2_updt_sm_idle       <= '1';
                updt_ns <= UPDATE_ERROR;

            -------------------------------------------------------------------
            when others =>
                updt_ns <= IDLE;

        end case;
    end process SG_UPDT_MACHINE;

-------------------------------------------------------------------------------
-- Register states of state machine
-------------------------------------------------------------------------------
REGISTER_STATE : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                updt_cs     <= IDLE;
            else
                updt_cs     <= updt_ns;
            end if;
        end if;
    end process REGISTER_STATE;


-------------------------------------------------------------------------------
-- Channel included therefore generate fetch logic
-------------------------------------------------------------------------------
GEN_CH1_UPDATE : if C_INCLUDE_CH1 = 1 generate
begin
    -------------------------------------------------------------------------------
    -- Active channel flag.  Indicates which channel is active.
    -- 0 = channel active
    -- 1 = channel active
    -------------------------------------------------------------------------------
    CH1_ACTIVE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_active_i <= '0';

                elsif(ch1_active_i = '1' and updt_done = '1')then
                    ch1_active_i <= '0';

                elsif(ch1_active_set = '1')then
                    ch1_active_i <= '1';
                end if;
            end if;
        end process CH1_ACTIVE_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 ready to be serviced?
    -------------------------------------------------------------------------------
    service_ch1 <= '1' when ch1_updt_queue_empty = '0'  -- Queue not empty
                        and ftch_error = '0'            -- No SG Fetch Error
              else '0';


    -------------------------------------------------------------------------------
    -- Channel 1 Interrupt On Complete
    -------------------------------------------------------------------------------
    CH1_INTR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_updt_ioc_irq_set <= '0';
                -- Set interrupt on Done and Descriptor IOC set
                elsif(updt_done = '1' and ch1_updt_ioc = '1')then
                    ch1_updt_ioc_irq_set <= '1';
                else
                    ch1_updt_ioc_irq_set <= '0';
                end if;
            end if;
        end process CH1_INTR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Internal Error
    -------------------------------------------------------------------------------
    CH1_INTERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_dma_interr_set <= '0';
                -- Set internal error on desc updt Done and Internal Error
                elsif(updt_done = '1' and ch1_dma_interr = '1')then
                    ch1_dma_interr_set <= '1';
                end if;
            end if;
        end process CH1_INTERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Slave Error
    -------------------------------------------------------------------------------
    CH1_SLVERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_dma_slverr_set <= '0';
                -- Set slave error on desc updt Done and Slave Error
                elsif(updt_done = '1' and ch1_dma_slverr = '1')then
                    ch1_dma_slverr_set <= '1';
                end if;
            end if;
        end process CH1_SLVERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Decode Error
    -------------------------------------------------------------------------------
    CH1_DECERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_dma_decerr_set <= '0';
                -- Set decode error on desc updt Done and Decode Error
                elsif(updt_done = '1' and ch1_dma_decerr = '1')then
                    ch1_dma_decerr_set <= '1';
                end if;
            end if;
        end process CH1_DECERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Log Fetch Errors
    -------------------------------------------------------------------------------
    -- Log Slave Errors reported during descriptor update
    SLV_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_updt_slverr_set  <= '0';
                elsif(ch1_active_i = '1' and updt_slverr = '1')then
                    ch1_updt_slverr_set  <= '1';
                end if;
            end if;
        end process SLV_SET_PROCESS;

    -- Log Internal Errors reported during descriptor update
    INT_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_updt_interr_set  <= '0';
                elsif(ch1_active_i = '1' and updt_interr = '1')then
                    ch1_updt_interr_set  <= '1';
                end if;
            end if;
        end process INT_SET_PROCESS;

    -- Log Decode Errors reported during descriptor update
    DEC_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_updt_decerr_set  <= '0';
                elsif(ch1_active_i = '1' and updt_decerr = '1')then
                    ch1_updt_decerr_set  <= '1';
                end if;
            end if;
        end process DEC_SET_PROCESS;


    -- Indicate update is idle if state machine is idle and update queue is empty
    IDLE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or updt_error = '1' or ftch_error = '1')then
                    ch1_updt_idle <= '1';


                elsif(service_ch1 = '1')then
                    ch1_updt_idle <= '0';

                elsif(service_ch1 = '0' and ch1_updt_sm_idle = '1')then

                    ch1_updt_idle <= '1';
                end if;
            end if;
        end process IDLE_PROCESS;

    ---------------------------------------------------------------------------
    -- Indicate update is done to allow fetch of next descriptor
    -- This is needed to prevent a partial descriptor being fetched
    -- and then axi read is throttled for extended periods until the
    -- remainder of the descriptor is fetched.
    --
    -- Note: Only used when fetch queue not inluded otherwise
    -- tools optimize out this process
    ---------------------------------------------------------------------------
    REG_CH1_DONE : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_updt_done <= '0';
                elsif(updt_done = '1' and ch1_active_i = '1')then
                    ch1_updt_done <= '1';
                else
                    ch1_updt_done <= '0';
                end if;
            end if;
        end process REG_CH1_DONE;

end generate GEN_CH1_UPDATE;

-------------------------------------------------------------------------------
-- Channel excluded therefore do not generate fetch logic
-------------------------------------------------------------------------------
GEN_NO_CH1_UPDATE : if C_INCLUDE_CH1 = 0 generate
begin
    service_ch1             <= '0';
    ch1_active_i            <= '0';
    ch1_updt_idle           <= '0';
    ch1_updt_interr_set     <= '0';
    ch1_updt_slverr_set     <= '0';
    ch1_updt_decerr_set     <= '0';
    ch1_dma_interr_set      <= '0';
    ch1_dma_slverr_set      <= '0';
    ch1_dma_decerr_set      <= '0';
    ch1_updt_ioc_irq_set    <= '0';
    ch1_updt_done           <= '0';
end generate GEN_NO_CH1_UPDATE;


-------------------------------------------------------------------------------
-- Channel included therefore generate fetch logic
-------------------------------------------------------------------------------
GEN_CH2_UPDATE : if C_INCLUDE_CH2 = 1 generate
begin

    -------------------------------------------------------------------------------
    -- Active channel flag.  Indicates which channel is active.
    -- 0 = channel active
    -- 1 = channel active
    -------------------------------------------------------------------------------
    CH2_ACTIVE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_active_i <= '0';
                elsif(ch2_active_i = '1' and updt_done = '1')then
                    ch2_active_i <= '0';
                elsif(ch2_active_set = '1')then
                    ch2_active_i <= '1';
                end if;
            end if;
        end process CH2_ACTIVE_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 2 ready to be serviced?
    -------------------------------------------------------------------------------
    service_ch2 <= '1' when ch2_updt_queue_empty = '0'  -- Queue not empty
                        and ftch_error = '0'            -- No SG Fetch Error
              else '0';


    -------------------------------------------------------------------------------
    -- Channel 2 Interrupt On Complete
    -------------------------------------------------------------------------------
    CH2_INTR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_updt_ioc_irq_set <= '0';
                -- Set interrupt on Done and Descriptor IOC set
                elsif(updt_done = '1' and ch2_updt_ioc = '1')then
                    ch2_updt_ioc_irq_set <= '1';
                else
                    ch2_updt_ioc_irq_set <= '0';
                end if;
            end if;
        end process CH2_INTR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Internal Error
    -------------------------------------------------------------------------------
    CH2_INTERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_dma_interr_set <= '0';
                -- Set internal error on desc updt Done and Internal Error
                elsif(updt_done = '1' and ch2_dma_interr = '1')then
                    ch2_dma_interr_set <= '1';
                end if;
            end if;
        end process CH2_INTERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Slave Error
    -------------------------------------------------------------------------------
    CH2_SLVERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_dma_slverr_set <= '0';
                -- Set slave error on desc updt Done and Slave Error
                elsif(updt_done = '1' and ch2_dma_slverr = '1')then
                    ch2_dma_slverr_set <= '1';
                end if;
            end if;
        end process CH2_SLVERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Channel 1 DMA Decode Error
    -------------------------------------------------------------------------------
    CH2_DECERR_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_dma_decerr_set <= '0';
                -- Set decode error on desc updt Done and Decode Error
                elsif(updt_done = '1' and ch2_dma_decerr = '1')then
                    ch2_dma_decerr_set <= '1';
                end if;
            end if;
        end process CH2_DECERR_PROCESS;

    -------------------------------------------------------------------------------
    -- Log Fetch Errors
    -------------------------------------------------------------------------------
    -- Log Slave Errors reported during descriptor update
    SLV_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_updt_slverr_set  <= '0';
                elsif(ch2_active_i = '1' and updt_slverr = '1')then
                    ch2_updt_slverr_set  <= '1';
                end if;
            end if;
        end process SLV_SET_PROCESS;

    -- Log Internal Errors reported during descriptor update
    INT_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_updt_interr_set  <= '0';
                elsif(ch2_active_i = '1' and updt_interr = '1')then
                    ch2_updt_interr_set  <= '1';
                end if;
            end if;
        end process INT_SET_PROCESS;

    -- Log Decode Errors reported during descriptor update
    DEC_SET_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_updt_decerr_set  <= '0';
                elsif(ch2_active_i = '1' and updt_decerr = '1')then
                    ch2_updt_decerr_set  <= '1';
                end if;
            end if;
        end process DEC_SET_PROCESS;

    -- Indicate update is idle if state machine is idle and update queue is empty
    IDLE_PROCESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or updt_error = '1' or ftch_error = '1')then
                    ch2_updt_idle <= '1';

                elsif(service_ch2 = '1')then
                    ch2_updt_idle <= '0';

                elsif(service_ch2 = '0' and ch2_updt_sm_idle = '1')then

                    ch2_updt_idle <= '1';
                end if;
            end if;
        end process IDLE_PROCESS;

    ---------------------------------------------------------------------------
    -- Indicate update is done to allow fetch of next descriptor
    -- This is needed to prevent a partial descriptor being fetched
    -- and then axi read is throttled for extended periods until the
    -- remainder of the descriptor is fetched.
    --
    -- Note: Only used when fetch queue not inluded otherwise
    -- tools optimize out this process
    ---------------------------------------------------------------------------
    REG_CH2_DONE : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_updt_done <= '0';
                elsif(updt_done = '1' and ch2_active_i = '1')then
                    ch2_updt_done <= '1';
                else
                    ch2_updt_done <= '0';
                end if;
            end if;
        end process REG_CH2_DONE;


end generate GEN_CH2_UPDATE;

-------------------------------------------------------------------------------
-- Channel excluded therefore do not generate fetch logic
-------------------------------------------------------------------------------
GEN_NO_CH2_UPDATE : if C_INCLUDE_CH2 = 0 generate
begin
    service_ch2             <= '0';
    ch2_active_i            <= '0';
    ch2_updt_idle           <= '0';
    ch2_updt_interr_set     <= '0';
    ch2_updt_slverr_set     <= '0';
    ch2_updt_decerr_set     <= '0';
    ch2_dma_interr_set      <= '0';
    ch2_dma_slverr_set      <= '0';
    ch2_dma_decerr_set      <= '0';
    ch2_updt_ioc_irq_set    <= '0';
    ch2_updt_done           <= '0';
end generate GEN_NO_CH2_UPDATE;


---------------------------------------------------------------------------
-- Register Current Update Address.  Address captured from channel port
-- or queue by axi_sg_updt_queue
---------------------------------------------------------------------------
REG_UPDATE_ADDRESS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                update_address   <= (others => '0');
            -- Channel 1 descriptor update pointer
            elsif(ch1_updt_curdesc_wren = '1')then
                update_address   <= std_logic_vector(unsigned(ch1_updt_curdesc)
                                        + UPDATE_CH1_ADDR_OFFSET);
            -- Channel 2 descriptor update pointer
            elsif(ch2_updt_curdesc_wren = '1')then
                update_address   <= std_logic_vector(unsigned(ch2_updt_curdesc)
                                        + UPDATE_CH2_ADDR_OFFSET);
            end if;
        end if;
    end process REG_UPDATE_ADDRESS;


-- Assigne Bytes to Transfer (BTT)
update_cmd_btt <= UPDATE_CH1_CMD_BTT when ch1_active_i = '1'
             else UPDATE_CH2_CMD_BTT;

-------------------------------------------------------------------------------
-- Build DataMover command
-------------------------------------------------------------------------------
-- When command by sm, drive command to updt_cmdsts_if
GEN_DATAMOVER_CMND : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                updt_cmnd_wr    <= '0';
                updt_cmnd_data  <= (others => '0');

            -- Fetch SM issued a command write
            elsif(write_cmnd_cmb = '1')then
                updt_cmnd_wr    <= '1';
                updt_cmnd_data  <=  UPDATE_CMD_RSVD
                                    & UPDATE_CMD_TAG
                                    & update_address
                                    & UPDATE_MSB_IGNORED
                                    & UPDATE_CMD_TYPE
                                    & UPDATE_LSB_IGNORED
                                    & update_cmd_btt;
            else
                updt_cmnd_wr    <= '0';

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
               updt_error_addr    <= (others => '0');
            elsif(write_cmnd_cmb = '1')then
                updt_error_addr    <= update_address(C_M_AXI_SG_ADDR_WIDTH-1 downto SG_ADDR_LSB) & "000000";
            end if;
        end if;
    end process LOG_ERROR_ADDR;



end implementation;
