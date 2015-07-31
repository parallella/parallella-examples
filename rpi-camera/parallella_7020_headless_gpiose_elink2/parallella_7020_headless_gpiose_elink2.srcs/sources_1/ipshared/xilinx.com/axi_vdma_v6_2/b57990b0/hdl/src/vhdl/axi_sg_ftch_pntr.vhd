-------------------------------------------------------------------------------
-- axi_sg_ftch_pntr
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
-- Filename:    axi_sg_ftch_pntr.vhd
-- Description: This entity manages descriptor pointers and determine scatter
--              gather idle mode.
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
entity  axi_sg_ftch_pntr is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64        := 32   ;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_INCLUDE_CH1               : integer range 0 to 1          := 1    ;
            -- Include or Exclude channel 1 scatter gather engine
            -- 0 = Exclude Channel 1 SG Engine
            -- 1 = Include Channel 1 SG Engine

        C_INCLUDE_CH2               : integer range 0 to 1          := 1
            -- Include or Exclude channel 2 scatter gather engine
            -- 0 = Exclude Channel 2 SG Engine
            -- 1 = Include Channel 2 SG Engine
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                  --
        m_axi_sg_aresetn            : in  std_logic                         ;                  --
                                                                                               --
        nxtdesc                     : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
                                                                                               --
        -------------------------------                                                        --
        -- CHANNEL 1                                                                           --
        -------------------------------                                                        --
        ch1_run_stop                : in  std_logic                         ;                  --
        ch1_desc_flush              : in  std_logic                         ; --CR568950       --
                                                                                               --
        -- CURDESC update to fetch pointer on run/stop assertion                               --
        ch1_curdesc                 : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
                                                                                               --
        -- TAILDESC update on CPU write (from axi_dma_reg_module)                              --
        ch1_tailpntr_enabled        : in  std_logic                         ;                  --
        ch1_taildesc_wren           : in  std_logic                         ;                  --
        ch1_taildesc                : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
                                                                                               --
        -- NXTDESC update on descriptor fetch (from axi_sg_ftchq_if)                           --
        ch1_nxtdesc_wren            : in  std_logic                         ;                  --
                                                                                               --
        -- Current address of descriptor to fetch                                              --
        ch1_fetch_address           : out std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
        ch1_sg_idle                 : out std_logic                         ;                  --
                                                                                               --
        -------------------------------                                                        --
        -- CHANNEL 2                                                                           --
        -------------------------------                                                        --
        ch2_run_stop                : in  std_logic                         ;                  --
        ch2_desc_flush              : in  std_logic                         ;--CR568950        --
                                                                                               --
        -- CURDESC update to fetch pointer on run/stop assertion                               --
        ch2_curdesc                 : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
                                                                                               --
        -- TAILDESC update on CPU write (from axi_dma_reg_module)                              --
        ch2_tailpntr_enabled        : in  std_logic                         ;                  --
        ch2_taildesc_wren           : in  std_logic                         ;                  --
        ch2_taildesc                : in  std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
                                                                                               --
        -- NXTDESC update on descriptor fetch (from axi_sg_ftchq_if)                           --
        ch2_nxtdesc_wren            : in  std_logic                         ;                  --
                                                                                               --
        -- Current address of descriptor to fetch                                              --
        ch2_fetch_address           : out std_logic_vector                                     --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;                  --
        ch2_sg_idle                 : out std_logic                                            --
    );

end axi_sg_ftch_pntr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_pntr is
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
signal ch1_run_stop_d1              : std_logic := '0';
signal ch1_run_stop_re              : std_logic := '0';
signal ch1_use_crntdesc             : std_logic := '0';
signal ch1_fetch_address_i          : std_logic_vector
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)
                                        := (others => '0');

signal ch2_run_stop_d1              : std_logic := '0';
signal ch2_run_stop_re              : std_logic := '0';
signal ch2_use_crntdesc             : std_logic := '0';
signal ch2_fetch_address_i          : std_logic_vector
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)
                                        := (others => '0');

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Channel 1 is included therefore generate pointer logic
GEN_PNTR_FOR_CH1 : if C_INCLUDE_CH1 = 1 generate
begin


    GEN_RUNSTOP_RE : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_run_stop_d1 <= '0';
                else
                    ch1_run_stop_d1 <= ch1_run_stop;
                end if;
            end if;
        end process GEN_RUNSTOP_RE;

    ch1_run_stop_re <= ch1_run_stop and not ch1_run_stop_d1;


    ---------------------------------------------------------------------------
    -- At setting of run/stop need to use current descriptor pointer therefor
    -- flag for use
    ---------------------------------------------------------------------------
    GEN_INIT_PNTR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or ch1_nxtdesc_wren = '1')then
                    ch1_use_crntdesc <= '0';
                elsif(ch1_run_stop_re = '1')then
                    ch1_use_crntdesc <= '1';
                end if;
            end if;
        end process GEN_INIT_PNTR;

    ---------------------------------------------------------------------------
    -- Register Current Fetch Address.  During start (run/stop asserts) reg
    -- curdesc pointer from register module.  Once running use nxtdesc pointer.
    ---------------------------------------------------------------------------
    REG_FETCH_ADDRESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch1_fetch_address_i <= (others => '0');
                -- On initial tail pointer write use current desc pointer
                elsif(ch1_use_crntdesc = '1' and ch1_nxtdesc_wren = '0')then
                    ch1_fetch_address_i <= ch1_curdesc;
                -- On desriptor fetch capture next pointer
                elsif(ch1_nxtdesc_wren = '1')then
                    ch1_fetch_address_i <= nxtdesc;
                end if;
            end if;
        end process REG_FETCH_ADDRESS;

    -- Pass address out of module
    ch1_fetch_address <= ch1_fetch_address_i;

    ---------------------------------------------------------------------------
    -- Compair tail descriptor pointer to scatter gather engine current
    -- descriptor pointer.  Set idle if matched.  Only check if DMA engine
    -- is running and current descriptor is in process of being fetched.  This
    -- forces at least 1 descriptor fetch before checking for IDLE condition.
    ---------------------------------------------------------------------------
    COMPARE_ADDRESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- SG is IDLE on reset and on stop.
                --CR568950 - reset idlag on descriptor flush
                --if(m_axi_sg_aresetn = '0' or ch1_run_stop = '0')then
                if(m_axi_sg_aresetn = '0' or ch1_run_stop = '0' or ch1_desc_flush = '1')then
                    ch1_sg_idle <= '1';

                -- taildesc_wren must be in this 'if' to force a minimum
                -- of 1 clock of sg_idle = '0'.
                elsif(ch1_taildesc_wren = '1' or ch1_tailpntr_enabled = '0')then
                    ch1_sg_idle <= '0';

                -- Descriptor at fetch_address is being fetched (wren=1)
                -- therefore safe to check if tail matches the fetch address
                elsif(ch1_nxtdesc_wren = '1'
                and ch1_taildesc = ch1_fetch_address_i)then
                    ch1_sg_idle <= '1';
                end if;
            end if;
        end process COMPARE_ADDRESS;

end generate GEN_PNTR_FOR_CH1;


-- Channel 1 is NOT included therefore tie off pointer logic
GEN_NO_PNTR_FOR_CH1 : if C_INCLUDE_CH1 = 0 generate
begin
    ch1_fetch_address   <= (others =>'0');
    ch1_sg_idle         <= '0';
end generate GEN_NO_PNTR_FOR_CH1;

-- Channel 2 is included therefore generate pointer logic
GEN_PNTR_FOR_CH2 : if C_INCLUDE_CH2 = 1 generate
begin

    ---------------------------------------------------------------------------
    -- Create clock delay of run_stop in order to generate a rising edge pulse
    ---------------------------------------------------------------------------
    GEN_RUNSTOP_RE : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_run_stop_d1 <= '0';
                else
                    ch2_run_stop_d1 <= ch2_run_stop;
                end if;
            end if;
        end process GEN_RUNSTOP_RE;

    ch2_run_stop_re <= ch2_run_stop and not ch2_run_stop_d1;

    ---------------------------------------------------------------------------
    -- At setting of run/stop need to use current descriptor pointer therefor
    -- flag for use
    ---------------------------------------------------------------------------
    GEN_INIT_PNTR : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0' or ch2_nxtdesc_wren = '1')then
                    ch2_use_crntdesc <= '0';
                elsif(ch2_run_stop_re = '1')then
                    ch2_use_crntdesc <= '1';
                end if;
            end if;
        end process GEN_INIT_PNTR;

    ---------------------------------------------------------------------------
    -- Register Current Fetch Address.  During start (run/stop asserts) reg
    -- curdesc pointer from register module.  Once running use nxtdesc pointer.
    ---------------------------------------------------------------------------
    REG_FETCH_ADDRESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                if(m_axi_sg_aresetn = '0')then
                    ch2_fetch_address_i <= (others => '0');
                -- On initial tail pointer write use current desc pointer
                elsif(ch2_use_crntdesc = '1' and ch2_nxtdesc_wren = '0')then
                    ch2_fetch_address_i <= ch2_curdesc;
                -- On descirptor fetch capture next pointer
                elsif(ch2_nxtdesc_wren = '1')then
                    ch2_fetch_address_i <= nxtdesc;
                end if;
            end if;
        end process REG_FETCH_ADDRESS;

    -- Pass address out of module
    ch2_fetch_address <= ch2_fetch_address_i;

    ---------------------------------------------------------------------------
    -- Compair tail descriptor pointer to scatter gather engine current
    -- descriptor pointer.  Set idle if matched.  Only check if DMA engine
    -- is running and current descriptor is in process of being fetched.  This
    -- forces at least 1 descriptor fetch before checking for IDLE condition.
    ---------------------------------------------------------------------------
    COMPARE_ADDRESS : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                -- SG is IDLE on reset and on stop.
                --CR568950 - reset idlag on descriptor flush
                --if(m_axi_sg_aresetn = '0' or ch2_run_stop = '0')then
                if(m_axi_sg_aresetn = '0' or ch2_run_stop = '0' or ch2_desc_flush = '1')then
                    ch2_sg_idle <= '1';

                -- taildesc_wren must be in this 'if' to force a minimum
                -- of 1 clock of sg_idle = '0'.
                elsif(ch2_taildesc_wren = '1' or ch2_tailpntr_enabled = '0')then
                    ch2_sg_idle <= '0';

                -- Descriptor at fetch_address is being fetched (wren=1)
                -- therefore safe to check if tail matches the fetch address
                elsif(ch2_nxtdesc_wren = '1'
                and ch2_taildesc = ch2_fetch_address_i)then
                    ch2_sg_idle <= '1';
                end if;
            end if;
        end process COMPARE_ADDRESS;

end generate GEN_PNTR_FOR_CH2;


-- Channel 2 is NOT included therefore tie off pointer logic
GEN_NO_PNTR_FOR_CH2 : if C_INCLUDE_CH2 = 0 generate
begin
    ch2_fetch_address   <= (others =>'0');
    ch2_sg_idle         <= '0';
end generate GEN_NO_PNTR_FOR_CH2;

end implementation;
