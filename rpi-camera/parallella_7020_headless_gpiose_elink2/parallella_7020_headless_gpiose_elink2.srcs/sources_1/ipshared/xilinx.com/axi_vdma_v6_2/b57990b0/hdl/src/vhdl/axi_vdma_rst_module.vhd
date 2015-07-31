-------------------------------------------------------------------------------
-- axi_vdma_rst_module
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
-- Filename:          axi_vdma_rst_module.vhd
-- Description: This entity is the top level reset module entity for the
--              AXI VDMA core.
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

--use proc_common_v4_0.family_support.all;


-------------------------------------------------------------------------------
entity  axi_vdma_rst_module is
    generic(
        C_INCLUDE_MM2S                  : integer range 0 to 1      := 1;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path

        C_INCLUDE_S2MM                  : integer range 0 to 1      := 1;
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

        C_INCLUDE_SG                    : integer range 0 to 1      := 1;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_PRMRY_IS_ACLK_ASYNC       	: integer range 0 to 1          := 0
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - Primary data path channels (MM2S and S2MM)
            --                            run asynchronous to AXI Lite, DMA Control,
            --                            and SG.
    );
    port (
        -----------------------------------------------------------------------
        -- Clock Sources
        -----------------------------------------------------------------------
        s_axi_lite_aclk             : in  std_logic                         ;           --
        m_axi_sg_aclk               : in  std_logic                         ;           --
        m_axi_mm2s_aclk             : in  std_logic                         ;           --
        m_axis_mm2s_aclk            : in  std_logic                         ;           --
        m_axi_s2mm_aclk             : in  std_logic                         ;           --
        s_axis_s2mm_aclk            : in  std_logic                         ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- Hard Reset                                                                   --
        -----------------------------------------------------------------------         --
        axi_resetn                  : in  std_logic                         ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- MM2S Soft Reset Support                                                      --
        -----------------------------------------------------------------------         --
        mm2s_soft_reset             : in  std_logic                         ;           --
        mm2s_soft_reset_clr         : out std_logic := '0'                  ;           --
        mm2s_all_idle               : in  std_logic                         ;           --
        mm2s_fsize_mismatch_err     : in  std_logic                         ;           -- CR591965
        mm2s_stop                   : in  std_logic                         ;           --
        mm2s_halt                   : out std_logic := '0'                  ;           --
        mm2s_halt_cmplt             : in  std_logic                         ;           --
        mm2s_run_stop               : in  std_logic                         ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- S2MM Soft Reset Support                                                      --
        -----------------------------------------------------------------------         --
        s2mm_soft_reset             : in  std_logic                         ;           --
        s2mm_soft_reset_clr         : out std_logic := '0'                  ;           --
        s2mm_all_idle               : in  std_logic                         ;           --
        s2mm_fsize_mismatch_err     : in  std_logic                         ;           -- CR591965
        s2mm_stop                   : in  std_logic                         ;           --
        s2mm_halt                   : out std_logic := '0'                  ;           --
        s2mm_halt_cmplt             : in  std_logic                         ;           --
        s2mm_run_stop               : in  std_logic                         ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- SG Status                                                                    --
        -----------------------------------------------------------------------         --
        ftch_err                    : in  std_logic                         ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- MM2S Distributed Reset Out                                                   --
        -----------------------------------------------------------------------         --
        -- AXI Upsizer and Line Buffer                                                  --
        mm2s_prmry_resetn           : out std_logic := '1'                  ;           --
        -- AXI DataMover Primary Reset (Raw)                                            --
        mm2s_dm_prmry_resetn        : out std_logic := '1'                  ;           --
        -- AXI Stream Logic Reset                                                       --
        mm2s_axis_resetn            : out std_logic := '1'                  ;           --
        -- AXI Stream Reset Outputs                                                     --
        mm2s_axis_reset_out_n       : out std_logic := '1'                  ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- S2MM Distributed Reset Out                                                   --
        -----------------------------------------------------------------------         --
        -- AXI Upsizer and Line Buffer                                                  --
        s2mm_prmry_resetn           : out std_logic := '1'                  ;           --
        -- AXI DataMover Primary Reset (Raw)                                            --
        s2mm_dm_prmry_resetn        : out std_logic := '1'                  ;           --
        -- AXI Stream Logic Reset                                                       --
        s2mm_axis_resetn            : out std_logic := '1'                  ;           --
        -- AXI Stream Reset Outputs                                                     --
        s2mm_axis_reset_out_n       : out std_logic := '1'                  ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- Scatter Gather Distributed Reset Out                                         --
        -----------------------------------------------------------------------         --
        m_axi_sg_resetn             : out std_logic := '1'                  ;           --
        m_axi_dm_sg_resetn          : out std_logic := '1'                  ;           --
                                                                                        --
        -----------------------------------------------------------------------         --
        -- Hard Reset Out                                                               --
        -----------------------------------------------------------------------         --
        s_axi_lite_resetn           : out std_logic := '1'                  ;           --
        mm2s_hrd_resetn             : out std_logic := '1'                  ;           --
        s2mm_hrd_resetn             : out std_logic := '1'                              --
    );

end axi_vdma_rst_module;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_rst_module is
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


signal hrd_resetn_i                     : std_logic := '1';
--signal axi_lite_resetn_d1               : std_logic := '1';
signal mm2s_axi_sg_resetn               : std_logic := '1';
signal mm2s_dm_axi_sg_resetn            : std_logic := '1';
signal s2mm_axi_sg_resetn               : std_logic := '1';
signal s2mm_dm_axi_sg_resetn            : std_logic := '1';



Attribute KEEP : string; -- declaration
Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration




-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin




REG_HRD_RST : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            hrd_resetn_i        <= axi_resetn;
        end if;
    end process REG_HRD_RST;

s_axi_lite_resetn   <= hrd_resetn_i;



-- Generate MM2S reset signals
GEN_RESET_FOR_MM2S : if C_INCLUDE_MM2S = 1 generate
signal sig_mm2s_dm_prmry_resetn              : std_logic := '1';
signal sig_mm2s_axis_resetn                  : std_logic := '1';

signal sig_mm2s_prmry_resetn                     : std_logic := '1';
Attribute KEEP of sig_mm2s_prmry_resetn         : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_mm2s_prmry_resetn        : signal is "no";
Attribute KEEP of sig_mm2s_dm_prmry_resetn      : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_mm2s_dm_prmry_resetn     : signal is "no";
Attribute KEEP of sig_mm2s_axis_resetn          : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_mm2s_axis_resetn         : signal is "no";


begin

mm2s_prmry_resetn <= sig_mm2s_prmry_resetn;
mm2s_dm_prmry_resetn <= sig_mm2s_dm_prmry_resetn;

mm2s_axis_resetn <= sig_mm2s_axis_resetn;

    RESET_I : entity  axi_vdma_v6_2.axi_vdma_reset
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC        ,
            C_INCLUDE_SG                => C_INCLUDE_SG                 -- CR622081
        )
        port map(
            -- Clock Sources
            s_axi_lite_aclk             => s_axi_lite_aclk              ,
            m_axi_sg_aclk               => m_axi_sg_aclk                ,
            prmry_axi_aclk              => m_axi_mm2s_aclk              ,
            prmry_axis_aclk             => m_axis_mm2s_aclk             ,

            -- Hard Reset
            axi_resetn                  => hrd_resetn_i                 ,
            hrd_axi_resetn              => mm2s_hrd_resetn                 ,

            -- Soft Reset
            soft_reset                  => mm2s_soft_reset              ,
            soft_reset_clr              => mm2s_soft_reset_clr          ,

            run_stop                    => mm2s_run_stop                ,
            all_idle                    => mm2s_all_idle                ,
            stop                        => mm2s_stop                    ,
            halt                        => mm2s_halt                    ,
            halt_cmplt                  => mm2s_halt_cmplt              ,
            fsize_mismatch_err          => mm2s_fsize_mismatch_err      ,   -- CR591965


            -- MM2S Main Primary Reset (Hard and Soft)
            prmry_resetn                => sig_mm2s_prmry_resetn            ,
            -- MM2S Main Datamover Primary Reset (RAW) (Hard and Soft)
            dm_prmry_resetn             => sig_mm2s_dm_prmry_resetn         ,
            -- AXI Stream Reset (Hard and Soft)
            axis_resetn                 => sig_mm2s_axis_resetn             ,
            -- AXI Stream Reset Out (Hard and Soft)
            axis_reset_out_n            => mm2s_axis_reset_out_n        ,
            -- AXI Scatter/Gather Reset (Hard and Soft)
            axi_sg_resetn               => mm2s_axi_sg_resetn           ,
            -- AXI Scatter/Gather Reset (RAW) (Hard and Soft)
            axi_dm_sg_resetn            => mm2s_dm_axi_sg_resetn
        );


end generate GEN_RESET_FOR_MM2S;


-- No MM2S therefore tie off mm2s reset signals
GEN_NO_RESET_FOR_MM2S : if C_INCLUDE_MM2S = 0 generate
begin
    mm2s_prmry_resetn       <= '1';
    mm2s_dm_prmry_resetn    <= '1';
    mm2s_axis_resetn        <= '1';
    mm2s_axis_reset_out_n   <= '1';
    mm2s_axi_sg_resetn      <= '1';
    mm2s_dm_axi_sg_resetn   <= '1';
    mm2s_halt               <= '0';
    mm2s_soft_reset_clr     <= '0';
end generate GEN_NO_RESET_FOR_MM2S;


-- Generate S2MM reset signals
GEN_RESET_FOR_S2MM : if C_INCLUDE_S2MM = 1 generate
signal sig_s2mm_dm_prmry_resetn              : std_logic := '1';
signal sig_s2mm_axis_resetn                  : std_logic := '1';

signal sig_s2mm_prmry_resetn                 : std_logic := '1';
Attribute KEEP of sig_s2mm_prmry_resetn         : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s2mm_prmry_resetn        : signal is "no";
Attribute KEEP of sig_s2mm_dm_prmry_resetn      : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s2mm_dm_prmry_resetn     : signal is "no";
Attribute KEEP of sig_s2mm_axis_resetn          : signal is "TRUE";
Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s2mm_axis_resetn         : signal is "no";



begin

s2mm_prmry_resetn <= sig_s2mm_prmry_resetn;
s2mm_dm_prmry_resetn <= sig_s2mm_dm_prmry_resetn;
s2mm_axis_resetn <= sig_s2mm_axis_resetn;

    RESET_I : entity  axi_vdma_v6_2.axi_vdma_reset
        generic map(
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC        ,
            C_INCLUDE_SG                => C_INCLUDE_SG                 -- CR622081
        )
        port map(
            -- Clock Sources
            s_axi_lite_aclk             => s_axi_lite_aclk              ,
            m_axi_sg_aclk               => m_axi_sg_aclk                ,
            prmry_axi_aclk              => m_axi_s2mm_aclk              ,
            prmry_axis_aclk             => s_axis_s2mm_aclk             ,

            -- Hard Reset
            axi_resetn                  => hrd_resetn_i                 ,
            hrd_axi_resetn              => s2mm_hrd_resetn                 ,

            -- Soft Reset
            soft_reset                  => s2mm_soft_reset              ,
            soft_reset_clr              => s2mm_soft_reset_clr          ,

            run_stop                    => s2mm_run_stop                ,
            all_idle                    => s2mm_all_idle                ,
            stop                        => s2mm_stop                    ,
            halt                        => s2mm_halt                    ,
            halt_cmplt                  => s2mm_halt_cmplt              ,
            fsize_mismatch_err          => s2mm_fsize_mismatch_err      ,   -- CR591965

            -- MM2S Main Primary Reset (Hard and Soft)
            prmry_resetn                => sig_s2mm_prmry_resetn            ,
            -- MM2S Main Datamover Primary Reset (RAW) (Hard and Soft)
            dm_prmry_resetn             => sig_s2mm_dm_prmry_resetn         ,
            -- AXI Stream Reset (Hard and Soft)
            axis_resetn                 => sig_s2mm_axis_resetn             ,
            -- AXI Stream Reset Out (Hard and Soft)
            axis_reset_out_n            => s2mm_axis_reset_out_n        ,
            -- AXI Scatter/Gather Reset (Hard and Soft)
            axi_sg_resetn               => s2mm_axi_sg_resetn           ,
            -- AXI Scatter/Gather Reset (RAW) (Hard and Soft)
            axi_dm_sg_resetn            => s2mm_dm_axi_sg_resetn
        );

end generate GEN_RESET_FOR_S2MM;

-- No SsMM therefore tie off mm2s reset signals
GEN_NO_RESET_FOR_S2MM : if C_INCLUDE_S2MM = 0 generate
begin
    s2mm_prmry_resetn       <= '1';
    s2mm_dm_prmry_resetn    <= '1';
    s2mm_axis_resetn        <= '1';
    s2mm_axis_reset_out_n   <= '1';
    s2mm_axi_sg_resetn      <= '1';
    s2mm_dm_axi_sg_resetn   <= '1';
    s2mm_halt               <= '0';
    s2mm_soft_reset_clr     <= '0';
end generate GEN_NO_RESET_FOR_S2MM;

-- Scatter Gather Mode
GEN_FOR_SG : if C_INCLUDE_SG = 1 generate
begin
    REG_SG_RESET_OUT : process(m_axi_sg_aclk)
        begin
            if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then

                -- If there is a scatter gather error, then a reset on either channel
                -- (soft or hard) will reset axi_sg engine
                if(ftch_err = '1')then
                    m_axi_sg_resetn     <= mm2s_axi_sg_resetn and s2mm_axi_sg_resetn;
                    m_axi_dm_sg_resetn  <= mm2s_dm_axi_sg_resetn and s2mm_dm_axi_sg_resetn;
                -- If no scatter gather erros then only a hard reset will reset scatter gather engine
                else
                    m_axi_sg_resetn     <= hrd_resetn_i;
                    m_axi_dm_sg_resetn  <= hrd_resetn_i;
                end if;
            end if;
        end process REG_SG_RESET_OUT;
end generate GEN_FOR_SG;

-- Register Direct Mode
GEN_FOR_NO_SG : if C_INCLUDE_SG = 0 generate
begin
    m_axi_sg_resetn    <= '1';
    m_axi_dm_sg_resetn <= '1';
end generate GEN_FOR_NO_SG;



end implementation;

