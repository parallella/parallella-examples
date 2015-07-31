-------------------------------------------------------------------------------
-- axi_vdma_intrpt
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
--  (c) Copyright 2010-2011, 2013 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:          axi_vdma_intrpt.vhd
-- Description: This entity handles interrupt coalescing
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_vdma.vhd
--                   |- axi_vdma_pkg.vhd
--                   |- axi_vdma_intrpt.vhd
--                   |- axi_vdma_rst_module.vhd
--                   |   |- axi_vdma_reset.vhd (mm2s)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |   |- axi_vdma_reset.vhd (s2mm)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |
--                   |- axi_vdma_reg_if.vhd
--                   |   |- axi_vdma_lite_if.vhd
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (mm2s)
--                   |- axi_vdma_vid_cdc.vhd (mm2s)
--                   |- axi_vdma_fsync_gen.vhd (mm2s)
--                   |- axi_vdma_sof_gen.vhd (mm2s)
--                   |- axi_vdma_reg_module.vhd (mm2s)
--                   |   |- axi_vdma_register.vhd (mm2s)
--                   |   |- axi_vdma_regdirect.vhd (mm2s)
--                   |- axi_vdma_mngr.vhd (mm2s)
--                   |   |- axi_vdma_sg_if.vhd (mm2s)
--                   |   |- axi_vdma_sm.vhd (mm2s)
--                   |   |- axi_vdma_cmdsts_if.vhd (mm2s)
--                   |   |- axi_vdma_vidreg_module.vhd (mm2s)
--                   |   |   |- axi_vdma_sgregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (mm2s)
--                   |   |   |- axi_vdma_blkmem.vhd (mm2s)
--                   |   |- axi_vdma_genlock_mngr.vhd (mm2s)
--                   |       |- axi_vdma_genlock_mux.vhd (mm2s)
--                   |       |- axi_vdma_greycoder.vhd (mm2s)
--                   |- axi_vdma_mm2s_linebuf.vhd (mm2s)
--                   |   |- axi_vdma_sfifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_afifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_skid_buf.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (s2mm)
--                   |- axi_vdma_vid_cdc.vhd (s2mm)
--                   |- axi_vdma_fsync_gen.vhd (s2mm)
--                   |- axi_vdma_sof_gen.vhd (s2mm)
--                   |- axi_vdma_reg_module.vhd (s2mm)
--                   |   |- axi_vdma_register.vhd (s2mm)
--                   |   |- axi_vdma_regdirect.vhd (s2mm)
--                   |- axi_vdma_mngr.vhd (s2mm)
--                   |   |- axi_vdma_sg_if.vhd (s2mm)
--                   |   |- axi_vdma_sm.vhd (s2mm)
--                   |   |- axi_vdma_cmdsts_if.vhd (s2mm)
--                   |   |- axi_vdma_vidreg_module.vhd (s2mm)
--                   |   |   |- axi_vdma_sgregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (s2mm)
--                   |   |   |- axi_vdma_blkmem.vhd (s2mm)
--                   |   |- axi_vdma_genlock_mngr.vhd (s2mm)
--                   |       |- axi_vdma_genlock_mux.vhd (s2mm)
--                   |       |- axi_vdma_greycoder.vhd (s2mm)
--                   |- axi_vdma_s2mm_linebuf.vhd (s2mm)
--                   |   |- axi_vdma_sfifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_afifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_skid_buf.vhd (s2mm)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_datamover_v3_00_a.axi_datamover.vhd (FULL)
--                   |- axi_sg_v3_00_a.axi_sg.vhd
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;

-------------------------------------------------------------------------------
entity  axi_vdma_intrpt is
    generic(

        C_INCLUDE_CH1                  	: integer range 0 to 1       := 1    ;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path
        --C_ENABLE_DEBUG_INFO             : string := "1111111111111111";		-- 1 to 16 -- 
        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '1');		--15 downto 0  -- 
        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 1;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers
        C_ENABLE_DEBUG_INFO_0       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 0
        C_ENABLE_DEBUG_INFO_1       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 1
        C_ENABLE_DEBUG_INFO_2       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 2
        C_ENABLE_DEBUG_INFO_3       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 3
        C_ENABLE_DEBUG_INFO_4       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 4
        C_ENABLE_DEBUG_INFO_5       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 5
        C_ENABLE_DEBUG_INFO_6       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 6
        C_ENABLE_DEBUG_INFO_7       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 7
        C_ENABLE_DEBUG_INFO_8       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 8
        C_ENABLE_DEBUG_INFO_9       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 9
        C_ENABLE_DEBUG_INFO_10      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 10
        C_ENABLE_DEBUG_INFO_11      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 11
        C_ENABLE_DEBUG_INFO_12      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 12
        C_ENABLE_DEBUG_INFO_13      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 13
        C_ENABLE_DEBUG_INFO_14      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 14
        C_ENABLE_DEBUG_INFO_15      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 15





        C_INCLUDE_CH2                  	: integer range 0 to 1       := 1    ;
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

        C_INCLUDE_DLYTMR            	: integer range 0 to 1       := 1    ;
            -- Include/Exclude interrupt delay timer
            -- 0 = Exclude Delay timer
            -- 1 = Include Delay timer

        C_DLYTMR_RESOLUTION         	: integer range 1 to 100000  := 125
            -- Interrupt Delay Timer resolution in usec

    );
    port (

        -- Secondary Clock and Reset
        m_axi_ch1_aclk              : in  std_logic                         ;              --
        m_axi_ch1_aresetn           : in  std_logic                         ;              --
                                                                                           --
        m_axi_ch2_aclk              : in  std_logic                         ;              --
        m_axi_ch2_aresetn           : in  std_logic                         ;              --
                                                                                           --
        ch1_irqthresh_decr          : in  std_logic                         ;-- CR567661   --
        ch1_irqthresh_decr_mask     : in  std_logic                         ;-- CR567661   --
        ch1_irqthresh_rstdsbl       : in  std_logic                         ;-- CR572013   --
        ch1_dlyirq_dsble            : in  std_logic                         ;              --
        ch1_irqdelay_wren           : in  std_logic                         ;              --
        ch1_irqdelay                : in  std_logic_vector(7 downto 0)      ;              --
        ch1_irqthresh_wren          : in  std_logic                         ;              --
        ch1_irqthresh               : in  std_logic_vector(7 downto 0)      ;              --
        ch1_packet_sof              : in  std_logic                         ;              --
        ch1_packet_eof              : in  std_logic                         ;              --
        ch1_packet_eof_mask         : in  std_logic                         ;              --
        ch1_ioc_irq_set             : out std_logic                         ;              --
        ch1_dly_irq_set             : out std_logic                         ;              --
        ch1_irqdelay_status         : out std_logic_vector(7 downto 0)      ;              --
        ch1_irqthresh_status        : out std_logic_vector(7 downto 0)      ;              --
                                                                                           --
        ch2_irqthresh_decr          : in  std_logic                         ;-- CR567661   --
        ch2_irqthresh_decr_mask     : in  std_logic                         ;-- CR567661   --
        ch2_irqthresh_rstdsbl       : in  std_logic                         ;-- CR572013   --
        ch2_dlyirq_dsble            : in  std_logic                         ;              --
        ch2_irqdelay_wren           : in  std_logic                         ;              --
        ch2_irqdelay                : in  std_logic_vector(7 downto 0)      ;              --
        ch2_irqthresh_wren          : in  std_logic                         ;              --
        ch2_irqthresh               : in  std_logic_vector(7 downto 0)      ;              --
        ch2_packet_sof              : in  std_logic                         ;              --
        ch2_packet_eof              : in  std_logic                         ;              --
        ch2_packet_eof_mask         : in  std_logic                         ;              --
        ch2_ioc_irq_set             : out std_logic                         ;              --
        ch2_dly_irq_set             : out std_logic                         ;              --
        ch2_irqdelay_status         : out std_logic_vector(7 downto 0)      ;              --
        ch2_irqthresh_status        : out std_logic_vector(7 downto 0)                     --

    );

end axi_vdma_intrpt;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_intrpt is
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
signal ch1_irqthresh_decr_mask_sig   : std_logic := '0';
signal ch2_irqthresh_decr_mask_sig   : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Transmit channel included therefore generate transmit interrupt logic
GEN_INCLUDE_MM2S : if C_INCLUDE_CH1 = 1 generate
begin


GEN_CH1_FRM_CNTR : if (C_ENABLE_DEBUG_INFO_7 = 1 or C_ENABLE_DEBUG_ALL = 1) generate
begin
    REG_THRESH_COUNT : process(m_axi_ch1_aclk)
        begin
            if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                if(m_axi_ch1_aresetn = '0')then
                    ch1_thresh_count   <= ONE_THRESHOLD;
                    ch1_ioc_irq_set_i  <= '0';

                -- New Threshold set by CPU OR delay interrupt event occured.
                elsif( (ch1_irqthresh_wren = '1')
                    or (ch1_dly_irq_set_i = '1' and ch1_irqthresh_rstdsbl = '0')) then
                    ch1_thresh_count   <= ch1_irqthresh;
                    ch1_ioc_irq_set_i  <= '0';

                -- IOC event then...
                elsif(ch1_irqthresh_decr = '1' and ch1_irqthresh_decr_mask_sig = '0')then --CR567661
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


    CH1_FRMCNT_MASK : process(m_axi_ch1_aclk)
        begin
            if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                if(m_axi_ch1_aresetn = '0')then
                    ch1_irqthresh_decr_mask_sig  <= '0';
                elsif (ch1_irqthresh_decr_mask = '1' and ch1_irqthresh_decr = '1') then
                    ch1_irqthresh_decr_mask_sig  <= '1';
                elsif (ch1_irqthresh_decr = '1') then
                    ch1_irqthresh_decr_mask_sig  <= '0';
                end if;
            end if;
        end process CH1_FRMCNT_MASK;




    -- Pass current threshold count out to DMASR
    ch1_irqthresh_status <= ch1_thresh_count;
    ch1_ioc_irq_set      <= ch1_ioc_irq_set_i;

end generate GEN_CH1_FRM_CNTR;
    ---------------------------------------------------------------------------
    -- Generate Delay Interrupt Timers
    ---------------------------------------------------------------------------
    GEN_CH1_DELAY_INTERRUPT : if (C_ENABLE_DEBUG_INFO_6 = 1 or C_ENABLE_DEBUG_ALL = 1) generate
    begin
        GEN_CH1_FAST_COUNTER : if C_DLYTMR_RESOLUTION /= 1 generate
        begin
            ---------------------------------------------------------------------------
            -- Delay interrupt high resolution timer
            ---------------------------------------------------------------------------
            REG_DLY_FAST_CNT : process(m_axi_ch1_aclk)
                begin
                    if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                        if(m_axi_ch1_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
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
            REG_DLY_FAST_CNT : process(m_axi_ch1_aclk)
                begin
                    if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                        if(m_axi_ch1_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
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
        REG_DELAY_COUNT : process(m_axi_ch1_aclk)
            begin
                if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                    if(m_axi_ch1_aresetn = '0' or ch1_delay_cnt_en = '0' or ch1_disable_delay = '1'
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
        REG_DELAY_CNT_ENABLE : process(m_axi_ch1_aclk)
            begin
                if(m_axi_ch1_aclk'EVENT and m_axi_ch1_aclk = '1')then
                    if(m_axi_ch1_aresetn = '0' or ch1_disable_delay = '1')then
                        ch1_delay_cnt_en   <= '0';

                    -- stop counting if already counting and receive an sof and
                    -- not end of another packet
                    elsif(ch1_delay_cnt_en = '1' and ch1_packet_sof = '1'
                    and ch1_packet_eof = '0')then
                        ch1_delay_cnt_en   <= '0';
                    elsif(ch1_packet_eof = '1' and ch1_packet_eof_mask = '0')then
                        ch1_delay_cnt_en   <= '1';
                    end if;
                end if;
            end process REG_DELAY_CNT_ENABLE;
    end generate GEN_CH1_DELAY_INTERRUPT;

end generate GEN_INCLUDE_MM2S;

-- Receive channel included therefore generate receive interrupt logic
GEN_INCLUDE_S2MM : if C_INCLUDE_CH2 = 1 generate
begin

GEN_CH2_FRM_CNTR : if (C_ENABLE_DEBUG_INFO_15 = 1 or C_ENABLE_DEBUG_ALL = 1) generate
begin


    REG_THRESH_COUNT : process(m_axi_ch2_aclk)
        begin
            if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                if(m_axi_ch2_aresetn = '0')then
                    ch2_thresh_count   <= ONE_THRESHOLD;
                    ch2_ioc_irq_set_i  <= '0';

                -- New Threshold set by CPU OR delay interrupt event occured.
                elsif( (ch2_irqthresh_wren = '1')
                    or (ch2_dly_irq_set_i = '1' and ch2_irqthresh_rstdsbl = '0')) then
                    ch2_thresh_count   <= ch2_irqthresh;
                    ch2_ioc_irq_set_i  <= '0';

                -- IOC event then...
                elsif(ch2_irqthresh_decr = '1' and ch2_irqthresh_decr_mask_sig = '0')then --CR567661
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


    CH2_FRMCNT_MASK : process(m_axi_ch2_aclk)
        begin
            if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                if(m_axi_ch2_aresetn = '0')then
                    ch2_irqthresh_decr_mask_sig  <= '0';
                elsif (ch2_irqthresh_decr_mask = '1' and ch2_irqthresh_decr = '1') then
                    ch2_irqthresh_decr_mask_sig  <= '1';
                elsif (ch2_irqthresh_decr = '1') then
                    ch2_irqthresh_decr_mask_sig  <= '0';
                end if;
            end if;
        end process CH2_FRMCNT_MASK;







    -- Pass current threshold count out to DMASR
    ch2_irqthresh_status   <= ch2_thresh_count;
    ch2_ioc_irq_set        <= ch2_ioc_irq_set_i;

end generate GEN_CH2_FRM_CNTR;
    ---------------------------------------------------------------------------
    -- Generate Delay Interrupt Timers
    ---------------------------------------------------------------------------
    GEN_CH2_DELAY_INTERRUPT : if (C_ENABLE_DEBUG_INFO_14 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin
        ---------------------------------------------------------------------------
        -- Delay interrupt high resolution timer
        ---------------------------------------------------------------------------
        GEN_CH2_FAST_COUNTER : if C_DLYTMR_RESOLUTION /= 1 generate
        begin
            REG_DLY_FAST_CNT : process(m_axi_ch2_aclk)
                begin
                    if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                        if(m_axi_ch2_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
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
            REG_DLY_FAST_CNT : process(m_axi_ch2_aclk)
                begin
                    if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                        if(m_axi_ch2_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
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
        REG_DELAY_COUNT : process(m_axi_ch2_aclk)
            begin
                if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                    if(m_axi_ch2_aresetn = '0' or ch2_delay_cnt_en = '0' or ch2_disable_delay = '1'
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
        REG_DELAY_CNT_ENABLE : process(m_axi_ch2_aclk)
            begin
                if(m_axi_ch2_aclk'EVENT and m_axi_ch2_aclk = '1')then
                    if(m_axi_ch2_aresetn = '0' or ch2_disable_delay = '1')then
                        ch2_delay_cnt_en   <= '0';
                    -- stop counting if already counting and receive an sof and
                    -- not end of another packet
                    elsif(ch2_delay_cnt_en = '1' and ch2_packet_sof = '1'
                    and ch2_packet_eof = '0')then
                        ch2_delay_cnt_en   <= '0';
                    elsif(ch2_packet_eof = '1' and ch2_packet_eof_mask = '0')then
                        ch2_delay_cnt_en   <= '1';
                    end if;
                end if;
            end process REG_DELAY_CNT_ENABLE;
    end generate GEN_CH2_DELAY_INTERRUPT;


end generate GEN_INCLUDE_S2MM;




-- Transmit channel not included therefore associated outputs to zero
GEN_NO_CH1_FRM_CNTR : if C_INCLUDE_CH1 = 0 or (C_ENABLE_DEBUG_INFO_7 = 0 and C_ENABLE_DEBUG_ALL = 0) generate
begin
    ch1_ioc_irq_set        <= '0';
    ch1_irqthresh_status   <= (others => '0');
end generate GEN_NO_CH1_FRM_CNTR;


    ---------------------------------------------------------------------------
    -- MM2S Delay interrupt NOT included
    ---------------------------------------------------------------------------
    GEN_NO_CH1_DELAY_INTR : if C_INCLUDE_CH1 = 0 or (C_ENABLE_DEBUG_INFO_6 = 0 and C_ENABLE_DEBUG_ALL = 0) generate
    begin
        ch1_dly_irq_set     <= '0';
        ch1_dly_irq_set_i   <= '0';
        ch1_irqdelay_status <= (others => '0');
    end generate GEN_NO_CH1_DELAY_INTR;







-- Receive channel not included therefore associated outputs to zero
GEN_NO_CH2_FRM_CNTR : if C_INCLUDE_CH2 = 0 or (C_ENABLE_DEBUG_INFO_15 = 0 and C_ENABLE_DEBUG_ALL = 0) generate
begin
    ch2_ioc_irq_set        <= '0';
    ch2_irqthresh_status   <= (others => '0');
end generate GEN_NO_CH2_FRM_CNTR;


    ---------------------------------------------------------------------------
    -- S2MM Delay interrupt NOT included
    ---------------------------------------------------------------------------
    GEN_NO_CH2_DELAY_INTR : if C_INCLUDE_CH2 = 0 or (C_ENABLE_DEBUG_INFO_14 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        ch2_dly_irq_set     <= '0';
        ch2_dly_irq_set_i   <= '0';
        ch2_irqdelay_status <= (others => '0');
    end generate GEN_NO_CH2_DELAY_INTR;



end implementation;
