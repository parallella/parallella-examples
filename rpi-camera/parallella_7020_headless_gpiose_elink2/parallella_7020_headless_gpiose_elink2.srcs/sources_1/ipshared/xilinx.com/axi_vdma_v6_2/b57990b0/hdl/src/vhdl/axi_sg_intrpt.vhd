-------------------------------------------------------------------------------
-- axi_sg_intrpt
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
-- Filename:          axi_sg_intrpt.vhd
-- Description: This entity handles interrupt coalescing
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
--  GAB     6/14/10    v1_00_a
-- ^^^^^^
-- CR565366
--  Fixed issue where simultaneous sof and eof caused delay timer to not enable
-- thus missing a delay interrupt.  This issue occurs with small packets(i.e.
-- 2 data beats)
-- ~~~~~~
--  GAB     7/1/10    v1_00_a
-- ^^^^^^
-- CR567661
-- Remapped interrupt threshold control to be driven based on whether update
-- engine is included or not. Renamed interrupt threshold decrement control here
-- to match change in upper level.
-- ~~~~~~
--  GAB     8/3/10    v1_00_a
-- ^^^^^^
-- CR570398
-- Routed dlyirq_wren to reset delay timer logic on assertion
-- ~~~~~~
--  GAB     8/12/10    v1_00_a
-- ^^^^^^
-- CR572013
-- Added ability to disable threshold count reset on delay timer timeout in
-- order to match legacy SDMA operation.
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

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;

-------------------------------------------------------------------------------
entity  axi_sg_intrpt is
    generic(

        C_INCLUDE_CH1                  : integer range 0 to 1       := 1    ;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path

        C_INCLUDE_CH2                  : integer range 0 to 1       := 1    ;
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

        C_INCLUDE_DLYTMR            : integer range 0 to 1          := 1    ;
            -- Include/Exclude interrupt delay timer
            -- 0 = Exclude Delay timer
            -- 1 = Include Delay timer

        C_DLYTMR_RESOLUTION         : integer range 1 to 100000      := 125
            -- Interrupt Delay Timer resolution in usec

    );
    port (

        -- Secondary Clock and Reset
        m_axi_sg_aclk               : in  std_logic                         ;              --
        m_axi_sg_aresetn            : in  std_logic                         ;              --
                                                                                           --
        ch1_irqthresh_decr          : in  std_logic                         ;-- CR567661   --
        ch1_irqthresh_rstdsbl       : in  std_logic                         ;-- CR572013   --
        ch1_dlyirq_dsble            : in  std_logic                         ;              --
        ch1_irqdelay_wren           : in  std_logic                         ;              --
        ch1_irqdelay                : in  std_logic_vector(7 downto 0)      ;              --
        ch1_irqthresh_wren          : in  std_logic                         ;              --
        ch1_irqthresh               : in  std_logic_vector(7 downto 0)      ;              --
        ch1_packet_sof              : in  std_logic                         ;              --
        ch1_packet_eof              : in  std_logic                         ;              --
        ch1_ioc_irq_set             : out std_logic                         ;              --
        ch1_dly_irq_set             : out std_logic                         ;              --
        ch1_irqdelay_status         : out std_logic_vector(7 downto 0)      ;              --
        ch1_irqthresh_status        : out std_logic_vector(7 downto 0)      ;              --
                                                                                           --
        ch2_irqthresh_decr          : in  std_logic                         ;-- CR567661   --
        ch2_irqthresh_rstdsbl       : in  std_logic                         ;-- CR572013   --
        ch2_dlyirq_dsble            : in  std_logic                         ;              --
        ch2_irqdelay_wren           : in  std_logic                         ;              --
        ch2_irqdelay                : in  std_logic_vector(7 downto 0)      ;              --
        ch2_irqthresh_wren          : in  std_logic                         ;              --
        ch2_irqthresh               : in  std_logic_vector(7 downto 0)      ;              --
        ch2_packet_sof              : in  std_logic                         ;              --
        ch2_packet_eof              : in  std_logic                         ;              --
        ch2_ioc_irq_set             : out std_logic                         ;              --
        ch2_dly_irq_set             : out std_logic                         ;              --
        ch2_irqdelay_status         : out std_logic_vector(7 downto 0)      ;              --
        ch2_irqthresh_status        : out std_logic_vector(7 downto 0)                     --

    );

end axi_sg_intrpt;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_intrpt is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Delay interrupt fast counter width
constant FAST_COUNT_WIDTH   : integer := clog2(C_DLYTMR_RESOLUTION+1);
-- Delay interrupt fast counter terminal count
constant FAST_COUNT_TC      : std_logic_vector(FAST_COUNT_WIDTH-1 downto 0)
                                := std_logic_vector(to_unsigned(
                                (C_DLYTMR_RESOLUTION-1),FAST_COUNT_WIDTH));




-- Delay interrupt fast counter zero value
constant ZERO_FAST_COUNT    : std_logic_vector(FAST_COUNT_WIDTH-1 downto 0)
                                := (others => '0');

constant ZERO_VALUE         : std_logic_vector(7 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal ch1_thresh_count    : std_logic_vector(7 downto 0) := ONE_THRESHOLD;
signal ch1_dly_irq_set_i   : std_logic := '0';
signal ch1_ioc_irq_set_i   : std_logic := '0';

signal ch1_delay_count     : std_logic_vector(7 downto 0) := (others => '0');
signal ch1_delay_cnt_en    : std_logic := '0';
signal ch1_dly_fast_cnt    : std_logic_vector(FAST_COUNT_WIDTH-1 downto 0) := (others => '0');
signal ch1_dly_fast_incr   : std_logic := '0';
signal ch1_delay_zero      : std_logic := '0';
signal ch1_delay_tc        : std_logic := '0';
signal ch1_disable_delay   : std_logic := '0';

signal ch2_thresh_count    : std_logic_vector(7 downto 0) := ONE_THRESHOLD;
signal ch2_dly_irq_set_i   : std_logic := '0';
signal ch2_ioc_irq_set_i   : std_logic := '0';

signal ch2_delay_count     : std_logic_vector(7 downto 0) := (others => '0');
signal ch2_delay_cnt_en    : std_logic := '0';
signal ch2_dly_fast_cnt    : std_logic_vector(FAST_COUNT_WIDTH-1 downto 0) := (others => '0');
signal ch2_dly_fast_incr   : std_logic := '0';
signal ch2_delay_zero      : std_logic := '0';
signal ch2_delay_tc        : std_logic := '0';
signal ch2_disable_delay   : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Transmit channel included therefore generate transmit interrupt logic
GEN_INCLUDE_MM2S : if C_INCLUDE_CH1 = 1 generate
begin
    REG_THRESH_COUNT : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_thresh_count   <= ONE_THRESHOLD;
                    ch1_ioc_irq_set_i  <= '0';

                -- New Threshold set by CPU OR delay interrupt event occured.
-- CR572013 - added ability to disable threshold count reset on delay timeout
--                elsif(ch1_irqthresh_wren = '1' or ch1_dly_irq_set_i = '1') then
                elsif( (ch1_irqthresh_wren = '1')
                    or (ch1_dly_irq_set_i = '1' and ch1_irqthresh_rstdsbl = '0')) then
                    ch1_thresh_count   <= ch1_irqthresh;
                    ch1_ioc_irq_set_i  <= '0';

                -- IOC event then...
                elsif(ch1_irqthresh_decr = '1')then --CR567661
                    -- Threshold at zero, reload threshold and drive ioc
                    -- interrupt.
                    if(ch1_thresh_count = ONE_THRESHOLD)then
                        ch1_thresh_count    <= ch1_irqthresh;
                        ch1_ioc_irq_set_i  <= '1';
                    else
                        ch1_thresh_count   <= std_logic_vector(unsigned(ch1_thresh_count(7 downto 0)) - 1);
                        ch1_ioc_irq_set_i  <= '0';
                    end if;
                else
                    ch1_thresh_count   <= ch1_thresh_count;
                    ch1_ioc_irq_set_i  <= '0';
                end if;
            end if;
        end process REG_THRESH_COUNT;

    -- Pass current threshold count out to DMASR
    ch1_irqthresh_status <= ch1_thresh_count;
    ch1_ioc_irq_set      <= ch1_ioc_irq_set_i;

    ---------------------------------------------------------------------------
    -- Generate Delay Interrupt Timers
    ---------------------------------------------------------------------------
    GEN_CH1_DELAY_INTERRUPT : if C_INCLUDE_DLYTMR = 1 generate
    begin
        GEN_CH1_FAST_COUNTER : if C_DLYTMR_RESOLUTION /= 1 generate
        begin
            ---------------------------------------------------------------------------
            -- Delay interrupt high resolution timer
            ---------------------------------------------------------------------------
            REG_DLY_FAST_CNT : process(m_axi_sg_aclk)
                begin
                    if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 - need to reset on sof due to chanes for CR
--                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1' or ch1_packet_sof = '1')then
                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
                        or ch1_packet_sof = '1' or ch1_irqdelay_wren = '1')then
                            ch1_dly_fast_cnt   <= FAST_COUNT_TC;
                            ch1_dly_fast_incr  <= '0';
                        elsif(ch1_dly_fast_cnt = ZERO_FAST_COUNT)then
                            ch1_dly_fast_cnt   <= FAST_COUNT_TC;
                            ch1_dly_fast_incr  <= '1';
                        else
                            ch1_dly_fast_cnt   <= std_logic_vector(unsigned(ch1_dly_fast_cnt(FAST_COUNT_WIDTH-1 downto 0)) - 1);
                            ch1_dly_fast_incr  <= '0';
                        end if;
                    end if;
                end process REG_DLY_FAST_CNT;
        end generate GEN_CH1_FAST_COUNTER;

        GEN_CH1_NO_FAST_COUNTER :  if C_DLYTMR_RESOLUTION = 1 generate
            REG_DLY_FAST_CNT : process(m_axi_sg_aclk)
                begin
                    if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 - need to reset on sof due to chanes for CR
--                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1' or ch1_packet_sof = '1')then
                        if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
                        or ch1_packet_sof = '1' or ch1_irqdelay_wren = '1')then
                            ch1_dly_fast_incr <= '0';
                        else
                            ch1_dly_fast_incr <= '1';
                        end if;
                    end if;
                end process REG_DLY_FAST_CNT;
        end generate GEN_CH1_NO_FAST_COUNTER;

        -- DMACR Delay value set to zero - disable delay interrupt
        ch1_delay_zero <= '1' when ch1_irqdelay = ZERO_DELAY
                      else '0';

        -- Delay Terminal Count reached (i.e. Delay count = DMACR delay value)
        ch1_delay_tc <= '1' when ch1_delay_count = ch1_irqdelay
                             and ch1_delay_zero = '0'
                             and ch1_packet_sof = '0'
                    else '0';

        -- 1 clock earlier delay counter disable to prevent count
        -- increment on TC hit.
        ch1_disable_delay <= '1' when ch1_delay_zero = '1'
                                   or ch1_dlyirq_dsble = '1'
                                   or ch1_dly_irq_set_i = '1'
                        else '0';

        ---------------------------------------------------------------------------
        -- Delay interrupt low resolution timer
        ---------------------------------------------------------------------------
        REG_DELAY_COUNT : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 need to reset on SOF now due to CR change
--                    if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                    if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1' or ch1_packet_sof = '1')then
                    if(m_axi_sg_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
                    or ch1_packet_sof = '1' or ch1_irqdelay_wren = '1')then
                        ch1_delay_count    <= (others => '0');
                        ch1_dly_irq_set_i  <= '0';
                    elsif(ch1_dly_fast_incr = '1' and ch1_delay_tc = '1')then
                        ch1_delay_count    <= (others => '0');
                        ch1_dly_irq_set_i  <= '1';
                    elsif(ch1_dly_fast_incr = '1')then
                        ch1_delay_count    <= std_logic_vector(unsigned(ch1_delay_count(7 downto 0)) + 1);
                        ch1_dly_irq_set_i  <= '0';
                    else
                        ch1_delay_count    <= ch1_delay_count;
                        ch1_dly_irq_set_i  <= '0';
                    end if;
                end if;
            end process REG_DELAY_COUNT;

        -- Pass current delay count to DMASR
        ch1_irqdelay_status    <= ch1_delay_count;
        ch1_dly_irq_set        <= ch1_dly_irq_set_i;

        -- Enable control for delay counter
        REG_DELAY_CNT_ENABLE : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    if(m_axi_sg_aresetn = '0' or ch1_disable_delay = '1')then
                        ch1_delay_cnt_en   <= '0';

-- CR565366 simulatenous sof/eof which occurs for small packets causes delay timer
-- to not enable
--                    elsif(ch1_packet_sof = '1')then
                    -- stop counting if already counting and receive an sof and
                    -- not end of another packet
                    elsif(ch1_delay_cnt_en = '1' and ch1_packet_sof = '1'
                    and ch1_packet_eof = '0')then
                        ch1_delay_cnt_en   <= '0';
                    elsif(ch1_packet_eof = '1')then
                        ch1_delay_cnt_en   <= '1';
                    end if;
                end if;
            end process REG_DELAY_CNT_ENABLE;
    end generate GEN_CH1_DELAY_INTERRUPT;

    ---------------------------------------------------------------------------
    -- Delay interrupt NOT included
    ---------------------------------------------------------------------------
    GEN_NO_CH1_DELAY_INTR : if C_INCLUDE_DLYTMR = 0  generate
    begin
        ch1_dly_irq_set     <= '0';
        ch1_dly_irq_set_i   <= '0';
        ch1_irqdelay_status <= (others => '0');
    end generate GEN_NO_CH1_DELAY_INTR;

end generate GEN_INCLUDE_MM2S;

-- Receive channel included therefore generate receive interrupt logic
GEN_INCLUDE_S2MM : if C_INCLUDE_CH2 = 1 generate
begin
    REG_THRESH_COUNT : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_thresh_count   <= ONE_THRESHOLD;
                    ch2_ioc_irq_set_i  <= '0';

                -- New Threshold set by CPU OR delay interrupt event occured.
-- CR572013 - added ability to disable threshold count reset on delay timeout
--                elsif(ch2_irqthresh_wren = '1' or ch2_dly_irq_set_i = '1') then
                elsif( (ch2_irqthresh_wren = '1')
                    or (ch2_dly_irq_set_i = '1' and ch2_irqthresh_rstdsbl = '0')) then
                    ch2_thresh_count   <= ch2_irqthresh;
                    ch2_ioc_irq_set_i  <= '0';

                -- IOC event then...
                elsif(ch2_irqthresh_decr = '1')then --CR567661
                    -- Threshold at zero, reload threshold and drive ioc
                    -- interrupt.
                    if(ch2_thresh_count = ONE_THRESHOLD)then
                        ch2_thresh_count   <= ch2_irqthresh;
                        ch2_ioc_irq_set_i  <= '1';
                    else
                        ch2_thresh_count   <= std_logic_vector(unsigned(ch2_thresh_count(7 downto 0)) - 1);
                        ch2_ioc_irq_set_i  <= '0';
                    end if;
                else
                    ch2_thresh_count   <= ch2_thresh_count;
                    ch2_ioc_irq_set_i  <= '0';
                end if;
            end if;
        end process REG_THRESH_COUNT;

    -- Pass current threshold count out to DMASR
    ch2_irqthresh_status   <= ch2_thresh_count;
    ch2_ioc_irq_set        <= ch2_ioc_irq_set_i;

    ---------------------------------------------------------------------------
    -- Generate Delay Interrupt Timers
    ---------------------------------------------------------------------------
    GEN_CH2_DELAY_INTERRUPT : if C_INCLUDE_DLYTMR = 1 generate
    begin
        ---------------------------------------------------------------------------
        -- Delay interrupt high resolution timer
        ---------------------------------------------------------------------------
        GEN_CH2_FAST_COUNTER : if C_DLYTMR_RESOLUTION /= 1 generate
        begin
            REG_DLY_FAST_CNT : process(m_axi_sg_aclk)
                begin
                    if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 - need to reset on sof due to chanes for CR
--                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1' or ch2_packet_sof = '1')then
                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
                        or ch2_packet_sof = '1' or ch2_irqdelay_wren = '1')then
                            ch2_dly_fast_cnt   <= FAST_COUNT_TC;
                            ch2_dly_fast_incr  <= '0';
                        elsif(ch2_dly_fast_cnt = ZERO_FAST_COUNT)then
                            ch2_dly_fast_cnt   <= FAST_COUNT_TC;
                            ch2_dly_fast_incr  <= '1';
                        else
                            ch2_dly_fast_cnt   <= std_logic_vector(unsigned(ch2_dly_fast_cnt(FAST_COUNT_WIDTH-1 downto 0)) - 1);
                            ch2_dly_fast_incr  <= '0';
                        end if;
                    end if;
                end process REG_DLY_FAST_CNT;
        end generate GEN_CH2_FAST_COUNTER;

        GEN_CH2_NO_FAST_COUNTER :  if C_DLYTMR_RESOLUTION = 1 generate
            REG_DLY_FAST_CNT : process(m_axi_sg_aclk)
                begin
                    if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 - need to reset on sof due to chanes for CR
--                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1' or ch2_packet_sof = '1')then
                        if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
                        or ch2_packet_sof = '1' or ch2_irqdelay_wren = '1')then
                            ch2_dly_fast_incr <= '0';
                        else
                            ch2_dly_fast_incr <= '1';
                        end if;
                    end if;
                end process REG_DLY_FAST_CNT;
        end generate GEN_CH2_NO_FAST_COUNTER;

        -- DMACR Delay value set to zero - disable delay interrupt
        ch2_delay_zero <= '1' when ch2_irqdelay = ZERO_DELAY
                      else '0';

        -- Delay Terminal Count reached (i.e. Delay count = DMACR delay value)
        ch2_delay_tc <= '1' when ch2_delay_count = ch2_irqdelay
                             and ch2_delay_zero = '0'
                             and ch2_packet_sof = '0'
                      else '0';

        -- 1 clock earlier delay counter disable to prevent count
        -- increment on TC hit.
        ch2_disable_delay <= '1' when ch2_delay_zero = '1'
                                   or ch2_dlyirq_dsble = '1'
                                   or ch2_dly_irq_set_i = '1'
                        else '0';

        ---------------------------------------------------------------------------
        -- Delay interrupt low resolution timer
        ---------------------------------------------------------------------------
        REG_DELAY_COUNT : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
-- CR565366 need to reset on SOF now due to CR change
--                    if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1')then
-- CR570398 - need to reset delay timer each time a new delay value is written.
--                    if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1' or ch2_packet_sof = '1')then
                    if(m_axi_sg_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
                    or ch2_packet_sof = '1' or ch2_irqdelay_wren = '1')then
                        ch2_delay_count    <= (others => '0');
                        ch2_dly_irq_set_i  <= '0';
                    elsif(ch2_dly_fast_incr = '1' and ch2_delay_tc = '1')then
                        ch2_delay_count    <= (others => '0');
                        ch2_dly_irq_set_i  <= '1';
                    elsif(ch2_dly_fast_incr = '1')then
                        ch2_delay_count    <= std_logic_vector(unsigned(ch2_delay_count(7 downto 0)) + 1);
                        ch2_dly_irq_set_i  <= '0';
                    else
                        ch2_delay_count    <= ch2_delay_count;
                        ch2_dly_irq_set_i  <= '0';
                    end if;
                end if;
            end process REG_DELAY_COUNT;

        -- Pass current delay count to DMASR
        ch2_irqdelay_status <= ch2_delay_count;
        ch2_dly_irq_set     <= ch2_dly_irq_set_i;

        -- Enable control for delay counter
        REG_DELAY_CNT_ENABLE : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    if(m_axi_sg_aresetn = '0' or ch2_disable_delay = '1')then
                        ch2_delay_cnt_en   <= '0';
-- CR565366 simulatenous sof/eof which occurs for small packets causes delay timer
-- to not enable
--                    elsif(ch2_packet_sof = '1')then
                    -- stop counting if already counting and receive an sof and
                    -- not end of another packet
                    elsif(ch2_delay_cnt_en = '1' and ch2_packet_sof = '1'
                    and ch2_packet_eof = '0')then
                        ch2_delay_cnt_en   <= '0';
                    elsif(ch2_packet_eof = '1')then
                        ch2_delay_cnt_en   <= '1';
                    end if;
                end if;
            end process REG_DELAY_CNT_ENABLE;
    end generate GEN_CH2_DELAY_INTERRUPT;

    ---------------------------------------------------------------------------
    -- Delay interrupt NOT included
    ---------------------------------------------------------------------------
    GEN_NO_CH2_DELAY_INTR : if C_INCLUDE_DLYTMR = 0  generate
    begin
        ch2_dly_irq_set     <= '0';
        ch2_dly_irq_set_i   <= '0';
        ch2_irqdelay_status <= (others => '0');
    end generate GEN_NO_CH2_DELAY_INTR;

end generate GEN_INCLUDE_S2MM;




-- Transmit channel not included therefore associated outputs to zero
GEN_EXCLUDE_MM2S : if C_INCLUDE_CH1 = 0 generate
begin
    ch1_ioc_irq_set        <= '0';
    ch1_dly_irq_set        <= '0';
    ch1_irqdelay_status    <= (others => '0');
    ch1_irqthresh_status   <= (others => '0');
end generate GEN_EXCLUDE_MM2S;

-- Receive channel not included therefore associated outputs to zero
GEN_EXCLUDE_S2MM : if C_INCLUDE_CH2 = 0 generate
begin
    ch2_ioc_irq_set        <= '0';
    ch2_dly_irq_set        <= '0';
    ch2_irqdelay_status    <= (others => '0');
    ch2_irqthresh_status   <= (others => '0');
end generate GEN_EXCLUDE_S2MM;



end implementation;
