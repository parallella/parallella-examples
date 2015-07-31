-------------------------------------------------------------------------------
-- axi_vdma_reset
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
-- Filename:          axi_vdma_reset.vhd
-- Description: This entity encompasses the reset logic (soft and hard) for
--              distribution to the axi_vdma core.
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

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

library lib_cdc_v1_0;


-------------------------------------------------------------------------------
entity  axi_vdma_reset is
    generic(
        C_PRMRY_IS_ACLK_ASYNC           : integer range 0 to 1 := 0;
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - Primary data path channels (MM2S and S2MM)
            --                            run asynchronous to AXI Lite, DMA Control,
            --                            and SG.
        C_INCLUDE_SG                    : integer range 0 to 1 := 0
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine
    );
    port (
        -- Clock Sources
        s_axi_lite_aclk             : in  std_logic                         ;               --
        m_axi_sg_aclk               : in  std_logic                         ;               --
        prmry_axi_aclk              : in  std_logic                         ;               --
        prmry_axis_aclk             : in  std_logic                         ;               --
                                                                                            --
        -- Hard Reset                                                                       --
        axi_resetn                  : in  std_logic                         ;               --
                                                                                            --
        -- Soft Reset                                                                       --
        soft_reset                  : in  std_logic                         ;               --
        soft_reset_clr              : out std_logic  := '0'                 ;               --
                                                                                            --
                                                                                            --
        run_stop                    : in  std_logic                         ;               --
        all_idle                    : in  std_logic                         ;               --
        stop                        : in  std_logic                         ;               --
        halt                        : out std_logic := '0'                  ;               --
        halt_cmplt                  : in  std_logic                         ;               --
        fsize_mismatch_err          : in  std_logic                         ;               -- CR591965
        hrd_axi_resetn              : out std_logic                         ;               --
                                                                                            --
        -- MM2S or S2MM Main Primary Reset (Hard and Soft)                                  --
        prmry_resetn                : out std_logic := '0'                  ;               --
        -- MM2S or S2MM Main Datamover Primary Reset (RAW) (Hard and Soft)                  --
        dm_prmry_resetn             : out std_logic := '1'                  ;               --
        -- AXI Stream Reset (Hard and Soft)                                                 --
        axis_resetn                 : out std_logic := '1'                  ;               --
        -- AXI Stream Reset Out (Hard and Soft)                                             --
        axis_reset_out_n            : out std_logic                         ;               --
        -- AXI Scatter/Gather Reset (Hard and Soft)                                         --
        axi_sg_resetn               : out std_logic                         ;               --
        -- AXI Scatter/Gather Reset (RAW) (Hard and Soft)                                   --
        axi_dm_sg_resetn            : out std_logic                                         --
    );

end axi_vdma_reset;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_reset is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

constant ZERO_VALUE_VECT    : std_logic_vector(128 downto 0) := (others => '0');
constant SEVEN_COUNT        : std_logic_vector(2 downto 0)   := (others => '1');
constant FIFTEEN_COUNT        : std_logic_vector(3 downto 0)   := (others => '1');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- Soft Reset Support
signal s_soft_reset_i               : std_logic := '0';
signal s_soft_reset_i_d1            : std_logic := '0';
signal s_soft_reset_i_re            : std_logic := '0';
signal assert_sftrst_d1             : std_logic := '0';
signal min_assert_sftrst            : std_logic := '0';
--signal min_assert_sftrst_d1         : std_logic := '0';
signal sft_rst_dly1                 : std_logic := '0';
signal sft_rst_dly2                 : std_logic := '0';
signal sft_rst_dly3                 : std_logic := '0';
signal sft_rst_dly4                 : std_logic := '0';
signal sft_rst_dly5                 : std_logic := '0';
signal sft_rst_dly6                 : std_logic := '0';
signal sft_rst_dly7                 : std_logic := '0';
signal sft_rst_dly8                 : std_logic := '0';
signal sft_rst_dly9                 : std_logic := '0';
signal sft_rst_dly10                : std_logic := '0';
signal sft_rst_dly11                : std_logic := '0';
signal sft_rst_dly12                : std_logic := '0';
signal sft_rst_dly13                : std_logic := '0';
signal sft_rst_dly14                : std_logic := '0';
signal sft_rst_dly15                : std_logic := '0';
signal soft_reset_d1                : std_logic := '0';
signal soft_reset_re                : std_logic := '0';

-- Composite reset (hard and soft)
signal resetn_i                     : std_logic := '1';

-- Data Mover Halt
signal halt_i                       : std_logic := '0';
signal halt_reset                   : std_logic := '0';

signal run_stop_d1                  : std_logic := '0'; -- CR581004
signal run_stop_fe                  : std_logic := '0'; -- CR581004

-- Reset outputs
signal axis_resetn_i                : std_logic := '1';
signal prmry_resetn_i               : std_logic := '1';
signal axi_sg_resetn_i              : std_logic := '1';

signal hrd_axi_resetn_i               : std_logic := '1';
signal sg_min_assert_sftrst         : std_logic := '0';
signal sg_soft_reset_re             : std_logic := '0';
signal sg_all_idle                  : std_logic := '0';
signal lite_min_assert_sftrst       : std_logic := '0';
signal lite_soft_reset_re           : std_logic := '0';
signal lite_all_idle                : std_logic := '0';
signal axis_min_assert_sftrst       : std_logic := '0';
signal axis_soft_reset_re           : std_logic := '0';
signal axis_all_idle                : std_logic := '0';
-- Soft reset support
signal prmry_min_assert_sftrst      : std_logic := '0';
signal p_sg_min_assert_sftrst       : std_logic := '0';
signal p_lite_min_assert_sftrst     : std_logic := '0';
signal p_axis_min_assert_sftrst     : std_logic := '0';
signal clear_sft_rst_hold           : std_logic := '0';
signal sg_clear_sft_rst_hold        : std_logic := '0';
signal lite_clear_sft_rst_hold      : std_logic := '0';
signal axis_clear_sft_rst_hold      : std_logic := '0';
signal prmry_min_count              : std_logic_vector(3 downto 0)  := (others => '0');
signal sg_min_count                 : std_logic_vector(3 downto 0)  := (others => '0');
signal lite_min_count               : std_logic_vector(3 downto 0)  := (others => '0');
signal axis_min_count               : std_logic_vector(3 downto 0)  := (others => '0');

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

hrd_axi_resetn <= hrd_axi_resetn_i;
-------------------------------------------------------------------------------
-- Internal Hard Reset
-- Generate reset on hardware reset or soft reset
-------------------------------------------------------------------------------
resetn_i    <= '0' when s_soft_reset_i = '1'
                     or min_assert_sftrst = '1'
                     or hrd_axi_resetn_i = '0'
          else '1';

-------------------------------------------------------------------------------
-- Minimum Reset Logic for Soft Reset
-------------------------------------------------------------------------------
-- Register to generate rising edge on soft reset and falling edge
-- on reset assertion.
REG_SFTRST_FOR_RE : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            s_soft_reset_i_d1 <= s_soft_reset_i;
            assert_sftrst_d1  <= min_assert_sftrst;

            -- Register soft reset from DMACR to create
            -- rising edge pulse
            soft_reset_d1     <= soft_reset;

        end if;
    end process REG_SFTRST_FOR_RE;

-- rising edge pulse on internal soft reset
s_soft_reset_i_re <=  s_soft_reset_i and not s_soft_reset_i_d1;

-- rising edge pulse on DMACR soft reset
soft_reset_re   <= soft_reset and not soft_reset_d1;

-- falling edge detection on min soft rst to clear soft reset
-- bit in register module
soft_reset_clr <= (not min_assert_sftrst and assert_sftrst_d1)
                    or (not hrd_axi_resetn_i);

-------------------------------------------------------------------------------
-- Run Stop turned off by user (i.e. not an error and not a soft reset)
-------------------------------------------------------------------------------
-- CR581004 - When AXI VDMA in asynchronous mode does not come out of intial soft reset
-- Generate falling edge pulse for run_stop de-assertion
-- indicating run_stop turned off.
-- Only assert if not soft_reset and not stop (i.e. error)
REG_RUN_STOP_FE : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            if(resetn_i = '0' or soft_reset = '1' or stop = '1')then
                run_stop_d1 <= '0';
            else
                run_stop_d1 <= run_stop;
            end if;
        end if;
     end process REG_RUN_STOP_FE;

run_stop_fe <=   not run_stop and run_stop_d1;


---------------------------------------------------------------------------
-- Minimum soft reset in primary domain
---------------------------------------------------------------------------





GEN_MIN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

    PRMRY_MIN_RESET_ASSERTION : process(prmry_axi_aclk)
        begin
            if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
                if(clear_sft_rst_hold = '1')then
                    prmry_min_count <= (others => '0');
                    prmry_min_assert_sftrst <= '0';
                elsif(s_soft_reset_i_re = '1')then
                    prmry_min_count <= (others => '0');
                    prmry_min_assert_sftrst <= '1';
                elsif(prmry_min_assert_sftrst='1' and prmry_min_count = FIFTEEN_COUNT)then
                    prmry_min_count <= FIFTEEN_COUNT;
                    prmry_min_assert_sftrst <= '1';
                elsif(prmry_min_assert_sftrst='1' and all_idle = '1')then
                    prmry_min_count <= std_logic_vector(unsigned(prmry_min_count) + 1);
                    prmry_min_assert_sftrst <= '1';
                end if;
            end if;
        end process PRMRY_MIN_RESET_ASSERTION;


    ---------------------------------------------------------------------------
    -- Minimum soft reset in lite domain
    ---------------------------------------------------------------------------
----    LITE_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => s_axi_lite_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => s_soft_reset_i_re        ,
----            scndry_out                  => lite_soft_reset_re       ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );



LITE_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => s_soft_reset_i_re, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axi_lite_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => lite_soft_reset_re,
        scndry_vect_out            => open
    );







----    LITE_IDLE_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => s_axi_lite_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => all_idle                 ,
----            scndry_out                  => lite_all_idle            ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );


LITE_IDLE_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => all_idle, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axi_lite_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => lite_all_idle,
        scndry_vect_out            => open
    );










    LITE_MIN_RESET_ASSERTION : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(lite_clear_sft_rst_hold = '1')then
                    lite_min_count          <= (others => '0');
                    lite_min_assert_sftrst  <= '0';
                elsif(lite_soft_reset_re = '1')then
                    lite_min_count <= (others => '0');
                    lite_min_assert_sftrst <= '1';
                elsif(lite_min_assert_sftrst='1' and lite_min_count = FIFTEEN_COUNT)then
                    lite_min_count <= FIFTEEN_COUNT;
                    lite_min_assert_sftrst <= '1';
                elsif(lite_min_assert_sftrst ='1' and lite_all_idle = '1')then
                    lite_min_count <= std_logic_vector(unsigned(lite_min_count) + 1);
                    lite_min_assert_sftrst <= '1';
                end if;
            end if;
        end process LITE_MIN_RESET_ASSERTION;

    -- Cross back to primary
----    LITE_MIN_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_S_P_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => s_axi_lite_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => lite_min_assert_sftrst   ,
----            prmry_out                   => p_lite_min_assert_sftrst ,
----            prmry_in                    => '0'                      ,
----            scndry_out                  => open                     ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );
----


LITE_MIN_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => lite_min_assert_sftrst, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axi_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => p_lite_min_assert_sftrst,
        scndry_vect_out            => open
    );





----    LITE_CLR_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => s_axi_lite_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => clear_sft_rst_hold       ,
----            scndry_out                  => lite_clear_sft_rst_hold  ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );
----


LITE_CLR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => clear_sft_rst_hold, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axi_lite_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => lite_clear_sft_rst_hold,
        scndry_vect_out            => open
    );








    ---------------------------------------------------------------------------
    -- Minimum soft reset in axis domain
    ---------------------------------------------------------------------------
----    AXIS_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => prmry_axis_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => s_soft_reset_i_re        ,
----            scndry_out                  => axis_soft_reset_re       ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );


AXIS_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => s_soft_reset_i_re, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axis_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => axis_soft_reset_re,
        scndry_vect_out            => open
    );








----    AXIS_IDLE_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => prmry_axis_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => all_idle                 ,
----            scndry_out                  => axis_all_idle            ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );
----

AXIS_IDLE_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => all_idle, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axis_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => axis_all_idle,
        scndry_vect_out            => open
    );





    AXIS_MIN_RESET_ASSERTION : process(prmry_axis_aclk)
        begin
            if(prmry_axis_aclk'EVENT and prmry_axis_aclk = '1')then
                if(axis_clear_sft_rst_hold = '1')then
                    axis_min_count          <= (others => '0');
                    axis_min_assert_sftrst  <= '0';
                elsif(axis_soft_reset_re = '1')then
                    axis_min_count <= (others => '0');
                    axis_min_assert_sftrst <= '1';
                elsif(axis_min_assert_sftrst='1' and axis_min_count = FIFTEEN_COUNT)then
                    axis_min_count <= FIFTEEN_COUNT;
                    axis_min_assert_sftrst <= '1';
                elsif(axis_min_assert_sftrst ='1' and axis_all_idle = '1')then
                    axis_min_count <= std_logic_vector(unsigned(axis_min_count) + 1);
                    axis_min_assert_sftrst <= '1';
                end if;
            end if;
        end process AXIS_MIN_RESET_ASSERTION;

    -- Cross back to primary
----    AXIS_MIN_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_S_P_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => prmry_axis_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => axis_min_assert_sftrst   ,
----            prmry_out                   => p_axis_min_assert_sftrst ,
----            prmry_in                    => '0'                      ,
----            scndry_out                  => open                     ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );



AXIS_MIN_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axis_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => axis_min_assert_sftrst, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axi_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => p_axis_min_assert_sftrst,
        scndry_vect_out            => open
    );





----    AXIS_CLR_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----            scndry_aclk                 => prmry_axis_aclk          ,
----            scndry_resetn               => '1'                      ,
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----            prmry_in                    => clear_sft_rst_hold       ,
----            scndry_out                  => axis_clear_sft_rst_hold  ,
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----        );




AXIS_CLR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => clear_sft_rst_hold, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axis_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => axis_clear_sft_rst_hold,
        scndry_vect_out            => open
    );





    ---------------------------------------------------------------------------
    -- Minimum soft reset in sg domain
    ---------------------------------------------------------------------------
    GEN_FOR_SG : if C_INCLUDE_SG = 1 generate
    begin

----        SG_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----                C_VECTOR_WIDTH      => 1
----            )
----            port map(
----                prmry_aclk                  => prmry_axi_aclk           ,
----                prmry_resetn                => '1'                      ,
----                scndry_aclk                 => m_axi_sg_aclk            ,
----                scndry_resetn               => '1'                      ,
----                scndry_in                   => '0'                      ,
----                prmry_out                   => open                     ,
----                prmry_in                    => s_soft_reset_i_re        ,
----                scndry_out                  => sg_soft_reset_re         ,
----                scndry_vect_s_h             => '0'                      ,
----                scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out              => open                     ,
----                prmry_vect_s_h              => '0'                      ,
----                prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----                scndry_vect_out             => open
----            );
----


SG_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => s_soft_reset_i_re, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_sg_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => sg_soft_reset_re,
        scndry_vect_out            => open
    );






----        SG_IDLE_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----                C_VECTOR_WIDTH      => 1
----            )
----            port map(
----                prmry_aclk                  => prmry_axi_aclk           ,
----                prmry_resetn                => '1'                      ,
----                scndry_aclk                 => m_axi_sg_aclk            ,
----                scndry_resetn               => '1'                      ,
----                scndry_in                   => '0'                      ,
----                prmry_out                   => open                     ,
----                prmry_in                    => all_idle                 ,
----                scndry_out                  => sg_all_idle              ,
----                scndry_vect_s_h             => '0'                      ,
----                scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out              => open                     ,
----                prmry_vect_s_h              => '0'                      ,
----                prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----                scndry_vect_out             => open
----            );
----

SG_IDLE_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => all_idle, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_sg_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => sg_all_idle,
        scndry_vect_out            => open
    );








        SG_MIN_RESET_ASSERTION : process(m_axi_sg_aclk)
            begin
                if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
                    if(sg_clear_sft_rst_hold = '1')then
                        sg_min_count <= (others => '0');
                        sg_min_assert_sftrst <= '0';
                    elsif(sg_soft_reset_re = '1')then
                        sg_min_count <= (others => '0');
                        sg_min_assert_sftrst <= '1';
                    elsif(sg_min_assert_sftrst='1' and sg_min_count = FIFTEEN_COUNT)then
                        sg_min_count <= FIFTEEN_COUNT;
                        sg_min_assert_sftrst <= '1';
                    elsif(sg_min_assert_sftrst ='1' and sg_all_idle = '1')then
                        sg_min_count <= std_logic_vector(unsigned(sg_min_count) + 1);
                        sg_min_assert_sftrst <= '1';
                    end if;
                end if;
            end process SG_MIN_RESET_ASSERTION;

        -- Cross back to primary
----        SG_MIN_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE          => CDC_TYPE_LEVEL_S_P_NO_RST                   ,
----                C_VECTOR_WIDTH      => 1
----            )
----            port map(
----                prmry_aclk                  => prmry_axi_aclk           ,
----                prmry_resetn                => '1'                      ,
----                scndry_aclk                 => m_axi_sg_aclk            ,
----                scndry_resetn               => '1'                      ,
----                scndry_in                   => sg_min_assert_sftrst     ,
----                prmry_out                   => p_sg_min_assert_sftrst   ,
----                prmry_in                    => '0'                      ,
----                scndry_out                  => open                     ,
----                scndry_vect_s_h             => '0'                      ,
----                scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out              => open                     ,
----                prmry_vect_s_h              => '0'                      ,
----                prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----                scndry_vect_out             => open
----            );
----


SG_MIN_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axi_sg_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => sg_min_assert_sftrst, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axi_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => p_sg_min_assert_sftrst,
        scndry_vect_out            => open
    );






----        SG_CLR_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE          => CDC_TYPE_PULSE_P_S_OPEN_ENDED_NO_RST                   ,
----                C_VECTOR_WIDTH      => 1
----            )
----            port map(
----                prmry_aclk                  => prmry_axi_aclk           ,
----                prmry_resetn                => '1'                      ,
----                scndry_aclk                 => m_axi_sg_aclk            ,
----                scndry_resetn               => '1'                      ,
----                scndry_in                   => '0'                      ,
----                prmry_out                   => open                     ,
----                prmry_in                    => clear_sft_rst_hold       ,
----                scndry_out                  => sg_clear_sft_rst_hold    ,
----                scndry_vect_s_h             => '0'                      ,
----                scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out              => open                     ,
----                prmry_vect_s_h              => '0'                      ,
----                prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----                scndry_vect_out             => open
----            );
----


SG_CLR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => clear_sft_rst_hold, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_sg_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => sg_clear_sft_rst_hold,
        scndry_vect_out            => open
    );





        clear_sft_rst_hold <=  prmry_min_assert_sftrst
                              and p_sg_min_assert_sftrst
                              and p_lite_min_assert_sftrst
                              and p_axis_min_assert_sftrst;

        -- Assert minimum soft reset.
        REG_MIN_SFTRST : process(prmry_axi_aclk)
            begin
                if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
                    if(s_soft_reset_i_re='1')then
                        min_assert_sftrst <= '1';
                    elsif(min_assert_sftrst = '1'
                    and prmry_min_assert_sftrst = '0'
                    and p_sg_min_assert_sftrst = '0'
                    and p_lite_min_assert_sftrst = '0'
                    and p_axis_min_assert_sftrst = '0')then
                        min_assert_sftrst <= '0';
                    end if;
                end if;
            end process REG_MIN_SFTRST;


    end generate GEN_FOR_SG;

    -- No SG so do not look at sg_min_assert signal
    GEN_FOR_NO_SG : if C_INCLUDE_SG = 0 generate
    begin
        clear_sft_rst_hold <=  prmry_min_assert_sftrst
                              and p_lite_min_assert_sftrst
                              and p_axis_min_assert_sftrst;

        -- Assert minimum soft reset.
        REG_MIN_SFTRST : process(prmry_axi_aclk)
            begin
                if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
                    if(s_soft_reset_i_re='1')then
                        min_assert_sftrst <= '1';
                    elsif(min_assert_sftrst = '1'
                    and prmry_min_assert_sftrst = '0'
                    and p_lite_min_assert_sftrst = '0'
                    and p_axis_min_assert_sftrst = '0')then
                        min_assert_sftrst <= '0';
                    end if;
                end if;
            end process REG_MIN_SFTRST;

    end generate GEN_FOR_NO_SG;



end generate GEN_MIN_FOR_ASYNC;


GEN_MIN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    -- On start of soft reset shift pulse through to assert
    -- 15 clock later.  Used to set minimum 16clk assertion of
    -- reset.  Shift starts when all is idle and internal reset
    -- is asserted.
    MIN_PULSE_GEN : process(prmry_axi_aclk)
        begin
            if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
                if(s_soft_reset_i_re = '1')then
                    sft_rst_dly1    <= '1';
                    sft_rst_dly2    <= '0';
                    sft_rst_dly3    <= '0';
                    sft_rst_dly4    <= '0';
                    sft_rst_dly5    <= '0';
                    sft_rst_dly6    <= '0';
                    sft_rst_dly7    <= '0';
                    sft_rst_dly8    <= '0';
                    sft_rst_dly9    <= '0';
                    sft_rst_dly10   <= '0';
                    sft_rst_dly11   <= '0';
                    sft_rst_dly12   <= '0';
                    sft_rst_dly13   <= '0';
                    sft_rst_dly14   <= '0';
                    sft_rst_dly15   <= '0';
                elsif(all_idle = '1')then
                    sft_rst_dly1    <= '0';
                    sft_rst_dly2    <= sft_rst_dly1;
                    sft_rst_dly3    <= sft_rst_dly2;
                    sft_rst_dly4    <= sft_rst_dly3;
                    sft_rst_dly5    <= sft_rst_dly4;
                    sft_rst_dly6    <= sft_rst_dly5;
                    sft_rst_dly7    <= sft_rst_dly6;
                    sft_rst_dly8    <= sft_rst_dly7;
                    sft_rst_dly9    <= sft_rst_dly8;
                    sft_rst_dly10    <= sft_rst_dly9;
                    sft_rst_dly11    <= sft_rst_dly10;
                    sft_rst_dly12    <= sft_rst_dly11;
                    sft_rst_dly13    <= sft_rst_dly12;
                    sft_rst_dly14    <= sft_rst_dly13;
                    sft_rst_dly15    <= sft_rst_dly14;
                end if;
            end if;
        end process MIN_PULSE_GEN;

    -- Drive minimum reset assertion for 16 clocks.
    PRMRY_MIN_RESET_ASSERTION : process(prmry_axi_aclk)
        begin
            if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then

                if(s_soft_reset_i_re = '1')then
                    min_assert_sftrst <= '1';
                elsif(sft_rst_dly15 = '1')then
                    min_assert_sftrst <= '0';
                end if;
            end if;
        end process PRMRY_MIN_RESET_ASSERTION;

end generate GEN_MIN_FOR_SYNC;

-------------------------------------------------------------------------------
-- Soft Reset Support
-------------------------------------------------------------------------------
-- Generate reset on hardware reset or soft reset if system is idle
-- On soft reset or error
-- mm2s dma controller will idle immediatly
-- sg fetch engine will complete current task and idle (desc's will flush)
-- sg update engine will update all completed descriptors then idle
REG_SOFT_RESET : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            if(soft_reset = '1'
            and all_idle = '1' and (halt_cmplt = '1' or halt_reset = '1'))then
                s_soft_reset_i <= '1';
            else
                s_soft_reset_i <= '0';
            end if;
        end if;
    end process REG_SOFT_RESET;

-- Halt datamover on soft_reset or on error.  Halt will stay
-- asserted until s_soft_reset_i assertion which occurs when
-- halt is complete or hard reset
REG_DM_HALT : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            if(resetn_i = '0')then
                halt_i <= '0';

            -- CR581004 - When AXI VDMA in asynchronous mode does not come out of intial soft reset
            -- Soft reset or error or turned off therefore issue halt to datamover
            --elsif(soft_reset_re = '1' or stop = '1' or run_stop = '0')then
            --elsif(soft_reset_re = '1' or stop = '1' or run_stop_fe = '1')then
            --
            -- CR591965 need to halt and reset data mover on frame size mismatch inorder to correctly
            -- flush out datamover and prep for starting up again on next frame sync.  This is really
            -- only needed for flush on frame sync mode.  Signal is redundant in non-flush on frame sync mode
            elsif(soft_reset_re = '1' or stop = '1' or run_stop_fe = '1' or fsize_mismatch_err = '1')then
                halt_i <= '1';
            -- If halt due to turn off then clear on halt reset else will
            -- clear once resetn_i asserts for soft reset
            --elsif(halt_reset = '1' and stop = '0' and run_stop = '1')then
            elsif(halt_reset = '1' and stop = '0' and run_stop = '1')then
                halt_i <= '0';
            end if;
        end if;
    end process REG_DM_HALT;

-- Halt To DataMover
halt <= halt_i;

-- AXI Stream reset output
--REG_AXIS_RESET_OUT : process(prmry_axi_aclk)
--    begin
--        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
--            axis_resetn_i   <= resetn_i and not s_soft_reset_i;
--        end if;
--    end process REG_AXIS_RESET_OUT;

-- Registered primary and secondary resets out
REG_RESET_OUT : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            prmry_resetn_i <= resetn_i;
        end if;
    end process REG_RESET_OUT;


-- Issue hard reset to DM on halt completed
-- specifically for when run_stop is cleared in DMACR
-- Note: If soft_reset then do not issue halt_reset because this will
-- terminate the halt_cmplt too soon and it will not get captured
-- by soft_reset process above. Reset to dm will occur
-- based on resetn_i for the soft_reset case.
HRDRST_DM : process(prmry_axi_aclk)
    begin
        if(prmry_axi_aclk'EVENT and prmry_axi_aclk = '1')then
            --CR574564 - on hard reset p_halt de-asserted before halt_cmplt thus
            -- halt_reset never asserted causing a system hang
            --if(halt_cmplt = '1' and run_stop = '0' and soft_reset = '0')then
            -- CR581004 - When AXI VDMA in asynchronous mode does not come out of intial soft reset
            --if(halt_cmplt = '1' and halt_i = '1' and soft_reset = '0')then
            if(halt_cmplt = '1' and halt_i = '1' and soft_reset = '0' and stop = '0')then
                halt_reset <= '1';
            elsif(halt_reset = '1' and run_stop = '1')then
                halt_reset <= '0';
            end if;
        end if;
    end process HRDRST_DM;



-- System is asynchronous therefore use CDC module to cross
-- resets to appropriate clock domain
GEN_RESET_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

    -- Cross top level hard reset in from axi_lite to primary (mm2s or s2mm)
----    HARD_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => s_axi_lite_aclk          ,
----            prmry_resetn                => '1'                      ,
----
----            scndry_aclk                 => prmry_axi_aclk           ,
----            scndry_resetn               => '1'                      ,
----
----            -- Secondary to Primary Clock Crossing
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----
----            -- Primary to Secondary Clock Crossing
----            prmry_in                    => axi_resetn               ,
----            scndry_out                  => hrd_axi_resetn_i           ,
----
----            -- Secondary Vector to Primary Vector Clock Crossing
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----
----            -- Primary Vector to Secondary Vector Clock Crossing
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----
----        );
----


HARD_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => axi_resetn, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axi_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => hrd_axi_resetn_i,
        scndry_vect_out            => open
    );













    -- AXI DataMover Primary Reset (Raw) and primary logic reset
    dm_prmry_resetn         <= resetn_i and not halt_reset;
    prmry_resetn            <= prmry_resetn_i;

    -- Scatter Gather Mode
    GEN_FOR_SG : if C_INCLUDE_SG = 1 generate
    begin
--        AXI_SG_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
--            generic map(
--                C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
--                C_VECTOR_WIDTH      => 1
--            )
--            port map(
--                prmry_aclk                  => prmry_axi_aclk           ,
--                prmry_resetn                => '1'                      ,
--
--                scndry_aclk                 => m_axi_sg_aclk            ,
--                scndry_resetn               => '1'                      ,
--
--                -- Secondary to Primary Clock Crossing
--                scndry_in                   => '0'                      ,
--                prmry_out                   => open                     ,
--
--                -- Primary to Secondary Clock Crossing
--                prmry_in                    => resetn_i                 ,
--                scndry_out                  => axi_sg_resetn_i          ,
--
--                -- Secondary Vector to Primary Vector Clock Crossing
--                scndry_vect_s_h             => '0'                      ,
--                scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
--                prmry_vect_out              => open                     ,
--
--                -- Primary Vector to Secondary Vector Clock Crossing
--                prmry_vect_s_h              => '0'                      ,
--                prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
--                scndry_vect_out             => open
--
--            );
--

AXI_SG_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => resetn_i, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_sg_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => axi_sg_resetn_i,
        scndry_vect_out            => open
    );










        -- Scatter Gather Datamover and Logic Reset
        axi_dm_sg_resetn    <= axi_sg_resetn_i;
        axi_sg_resetn       <= axi_sg_resetn_i;
    end generate GEN_FOR_SG;
    -- Register Direct Mode
    GEN_FOR_NO_SG : if C_INCLUDE_SG = 0 generate
        axi_dm_sg_resetn <= '1';
        axi_sg_resetn    <= '1';
    end generate GEN_FOR_NO_SG;

----    AXIS_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => prmry_axi_aclk           ,
----            prmry_resetn                => '1'                      ,
----
----            scndry_aclk                 => prmry_axis_aclk          ,
----            scndry_resetn               => '1'                      ,
----
----            -- Secondary to Primary Clock Crossing
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----
----            -- Primary to Secondary Clock Crossing
----            prmry_in                    => resetn_i                 ,
----            scndry_out                  => axis_resetn_i            ,
----
----            -- Secondary Vector to Primary Vector Clock Crossing
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----
----            -- Primary Vector to Secondary Vector Clock Crossing
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----
----        );


AXIS_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_axi_aclk,
        prmry_resetn               => '1', 
        prmry_in                   => resetn_i, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_axis_aclk, 
        scndry_resetn              => '1',
        scndry_out                 => axis_resetn_i,
        scndry_vect_out            => open
    );








    -- AXIS (MM2S or S2MM) logic reset and reset out
    axis_resetn       <= axis_resetn_i;
    axis_reset_out_n  <= axis_resetn_i;

end generate GEN_RESET_FOR_ASYNC;


-- System is synchronous therefore map internal resets to all
-- reset outputs
GEN_RESET_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin

    -- Hard reset in
    hrd_axi_resetn_i          <= axi_resetn;

    -- AXI DataMover Primary Reset (Raw) and primary logic reset
    prmry_resetn            <= prmry_resetn_i;
    dm_prmry_resetn         <= resetn_i and not halt_reset;

    -- Scatter Gather Mode
    GEN_FOR_SG : if C_INCLUDE_SG = 1 generate
    begin
        -- Scatter Gather Engine Reset
        axi_sg_resetn           <= prmry_resetn_i;
        axi_dm_sg_resetn        <= resetn_i;
    end generate GEN_FOR_SG;
    -- Register Direct Mode
    GEN_FOR_NO_SG : if C_INCLUDE_SG = 0 generate
    begin
        -- Scatter Gather Engine Reset
        axi_sg_resetn           <= '1';
        axi_dm_sg_resetn        <= '1';
    end generate GEN_FOR_NO_SG;


    -- AXIS (MM2S or S2MM) logic reset and reset out
    axis_resetn       <= prmry_resetn_i;
    axis_reset_out_n  <= prmry_resetn_i;

end  generate GEN_RESET_FOR_SYNC;




end implementation;

