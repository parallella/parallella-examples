-------------------------------------------------------------------------------
-- axi_vdma_sg_cdc
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
-- Filename:    axi_vdma_sg_cdc.vhd
-- Description: This entity encompases the Clock Domain Crossing Pulse
--              Generator for Scatter Gather signals
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

library lib_cdc_v1_0;
-------------------------------------------------------------------------------
entity  axi_vdma_sg_cdc is
    generic (
        C_PRMRY_IS_ACLK_ASYNC       : integer range 0 to 1      := 0            ;
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 32    := 32
    );
    port (
        prmry_aclk                  : in  std_logic                             ;       --
        prmry_resetn                : in  std_logic                             ;       --
                                                                                        --
        scndry_aclk                 : in  std_logic                             ;       --
        scndry_resetn               : in  std_logic                             ;       --
                                                                                        --
        -- From Register Module (Primary Clk Domain)                                    --
        reg2cdc_run_stop            : in  std_logic                             ;       --
        reg2cdc_stop                : in  std_logic                             ;       --
        reg2cdc_taildesc_wren       : in  std_logic                             ;       --
        reg2cdc_taildesc            : in  std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
                                                                                        --
        reg2cdc_curdesc             : in  std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
                                                                                        --
        -- To Scatter Gather Engine (Secondary Clk Domain                               --
        cdc2sg_run_stop             : out std_logic                             ;       --
        cdc2sg_stop                 : out std_logic                             ;       --
        cdc2sg_taildesc_wren        : out std_logic                             ;       --
        cdc2sg_taildesc             : out std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
        cdc2sg_curdesc              : out std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
                                                                                        --
        -- From Scatter Gather Engine (Secondary Clk Domain)                            --
        sg2cdc_ftch_idle            : in  std_logic                             ;       --
        sg2cdc_ftch_interr_set      : in  std_logic                             ;       --
        sg2cdc_ftch_slverr_set      : in  std_logic                             ;       --
        sg2cdc_ftch_decerr_set      : in  std_logic                             ;       --
        sg2cdc_ftch_err_addr        : in  std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
        sg2cdc_ftch_err             : in  std_logic                             ;       --
                                                                                        --
        -- To DMA Controller                                                            --
        cdc2dmac_ftch_idle          : out std_logic                             ;       --
                                                                                        --
        -- To Register Module                                                           --
        cdc2reg_ftch_interr_set     : out std_logic                             ;       --
        cdc2reg_ftch_slverr_set     : out std_logic                             ;       --
        cdc2reg_ftch_decerr_set     : out std_logic                             ;       --
        cdc2reg_ftch_err_addr       : out std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
        cdc2reg_ftch_err            : out std_logic                                     --





    );

end axi_vdma_sg_cdc;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_sg_cdc is
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

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------

signal        reg2cdc_taildesc_i            : std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)   := (others => '0')   ;       --
signal        sg2cdc_ftch_err_addr_i        : std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)   := (others => '0')   ;       --
signal        reg2cdc_curdesc_i             : std_logic_vector                              --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)   := (others => '0')   ;       --
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


-- Aysnchronous mode therefore instantiate clock domain crossing logic
GEN_CDC_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

    -- From register module (primary clock domain) to
    -- scatter gather engine (secondary clock domain)
----    CUR_DESC_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_VECTR_P_S                           ,
----            C_VECTOR_WIDTH          => C_M_AXI_SG_ADDR_WIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT                              -- Not Used
----                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '1'                                      ,
----            prmry_vect_in           => reg2cdc_curdesc                          ,
----            scndry_vect_out         => cdc2sg_curdesc
----        );


-- Register signal in to give clear FF output to CDC
P_IN_CUR_DESC : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk ='1')then
            if(prmry_resetn = '0')then
                reg2cdc_curdesc_i   <= (others => '0');
            else
                reg2cdc_curdesc_i   <= reg2cdc_curdesc;
            end if;
        end if;
    end process P_IN_CUR_DESC;





CUR_DESC_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 0,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 0,
        C_VECTOR_WIDTH             => C_M_AXI_SG_ADDR_WIDTH,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_aclk,
        prmry_resetn               => prmry_resetn, 
        prmry_in                   => '0', 
        prmry_vect_in              => reg2cdc_curdesc_i,
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => open,
        scndry_vect_out            => cdc2sg_curdesc
    );







    -- From register module (primary clock domain) to
    -- scatter gather engine (secondary clock domain)
----    TAIL_DESC_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => C_M_AXI_SG_ADDR_WIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => reg2cdc_taildesc_wren                    ,
----            scndry_out              => cdc2sg_taildesc_wren                     ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT                              -- Not Used
----                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                    ,
----            prmry_vect_in           => ZERO_VALUE_VECT                         
----                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ,   -- Not Used
----            scndry_vect_out         => open
----        );





TAIL_DESC_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_aclk,
        prmry_resetn               => prmry_resetn, 
        prmry_in                   => reg2cdc_taildesc_wren, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2sg_taildesc_wren,
        scndry_vect_out            => open
    );



    -- From register module (primary clock domain) to
    -- scatter gather engine (secondary clock domain)
----    TAIL_DESC_VECT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_VECTR_P_S                           ,
----            C_VECTOR_WIDTH          => C_M_AXI_SG_ADDR_WIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => '0'                    ,
----            scndry_out              => open                     ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT                              -- Not Used
----                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => reg2cdc_taildesc_wren                    ,
----            prmry_vect_in           => reg2cdc_taildesc                         ,
----            scndry_vect_out         => cdc2sg_taildesc
----        );
----


-- Register signal in to give clear FF output to CDC
P_IN_TAIL_DESC : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk ='1')then
            if(prmry_resetn = '0')then
                reg2cdc_taildesc_i   <= (others => '0');
            elsif(reg2cdc_taildesc_wren = '1')then
                reg2cdc_taildesc_i   <= reg2cdc_taildesc;
            end if;
        end if;
    end process P_IN_TAIL_DESC;



TAIL_DESC_VECT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 0,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 0,
        C_VECTOR_WIDTH             => C_M_AXI_SG_ADDR_WIDTH,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_aclk,
        prmry_resetn               => prmry_resetn, 
        prmry_in                   => '0', 
        prmry_vect_in              => reg2cdc_taildesc_i,
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => open,
        scndry_vect_out            => cdc2sg_taildesc
    );




    -- From register module (primary clock domain) to
    -- scatter gather engine (secondary clock domain)
----    RUNSTOP_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => reg2cdc_run_stop                         ,
----            scndry_out              => cdc2sg_run_stop                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );



RUNSTOP_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_aclk,
        prmry_resetn               => prmry_resetn, 
        prmry_in                   => reg2cdc_run_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2sg_run_stop,
        scndry_vect_out            => open
    );







    -- From register module (primary clock domain) to
    -- scatter gather engine (secondary clock domain)
----    STOP_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => reg2cdc_stop                             ,
----            scndry_out              => cdc2sg_stop                              ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


STOP_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => prmry_aclk,
        prmry_resetn               => prmry_resetn, 
        prmry_in                   => reg2cdc_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2sg_stop,
        scndry_vect_out            => open
    );







    -- From SG Engine (secondary clock domain) to
    -- DMA Controller (primary clock domain)
----    FTCH_IDLE_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1                                        ,
----            C_RESET_STATE           => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => sg2cdc_ftch_idle                         ,
----            prmry_out               => cdc2dmac_ftch_idle                       ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



FTCH_IDLE_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => sg2cdc_ftch_idle, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2dmac_ftch_idle,
        scndry_vect_out            => open
    );






    --sg to reg
    -- From SG Engine (secondary clock domain) to
    -- Register Block (primary clock domain)
----    FTCH_INTERR_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => sg2cdc_ftch_interr_set                   ,
----            prmry_out               => cdc2reg_ftch_interr_set                  ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


FTCH_INTERR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => sg2cdc_ftch_interr_set, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2reg_ftch_interr_set,
        scndry_vect_out            => open
    );








----    FTCH_SLVERR_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => sg2cdc_ftch_slverr_set                   ,
----            prmry_out               => cdc2reg_ftch_slverr_set                  ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



FTCH_SLVERR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => sg2cdc_ftch_slverr_set, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2reg_ftch_slverr_set,
        scndry_vect_out            => open
    );







----    FTCH_DECERR_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => sg2cdc_ftch_decerr_set                   ,
----            prmry_out               => cdc2reg_ftch_decerr_set                  ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



FTCH_DECERR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => sg2cdc_ftch_decerr_set, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2reg_ftch_decerr_set,
        scndry_vect_out            => open
    );











----    ERR_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => C_M_AXI_SG_ADDR_WIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => sg2cdc_ftch_err                        ,
----            prmry_out               => cdc2reg_ftch_err                       ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => '0'                        ,
----            scndry_vect_in          =>  ZERO_VALUE_VECT(C_M_AXI_SG_ADDR_WIDTH-1 downto 0)                  ,
----            prmry_vect_out          => open                  ,
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(C_M_AXI_SG_ADDR_WIDTH-1 downto 0),   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



ERR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => sg2cdc_ftch_err, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2reg_ftch_err,
        scndry_vect_out            => open
    );








----    ERR_VECT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_VECTR_S_P                           ,
----            C_VECTOR_WIDTH          => C_M_AXI_SG_ADDR_WIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => '0'                        ,
----            prmry_out               => open                       ,
----            prmry_in                => '0'                                      ,   -- Not Used
----            scndry_out              => open                                     ,   -- Not Used
----            scndry_vect_s_h         => sg2cdc_ftch_err                        ,
----            scndry_vect_in          => sg2cdc_ftch_err_addr                   ,
----            prmry_vect_out          => cdc2reg_ftch_err_addr                  ,
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(C_M_AXI_SG_ADDR_WIDTH-1 downto 0),   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



-- Register signal in to give clear FF output to CDC
P_IN_ERR_VECT : process(scndry_aclk)
    begin
        if(scndry_aclk'EVENT and scndry_aclk ='1')then
            if(scndry_resetn = '0')then
                sg2cdc_ftch_err_addr_i   <= (others => '0');
            elsif(sg2cdc_ftch_err = '1')then
                sg2cdc_ftch_err_addr_i   <= sg2cdc_ftch_err_addr;
            end if;
        end if;
    end process P_IN_ERR_VECT;



ERR_VECT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 0,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 0,
        C_VECTOR_WIDTH             => C_M_AXI_SG_ADDR_WIDTH,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => '0', 
        prmry_vect_in              => sg2cdc_ftch_err_addr_i,
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => open,
        scndry_vect_out            => cdc2reg_ftch_err_addr
    );






end generate GEN_CDC_FOR_ASYNC;


-- Synchronous Mode therefore map inputs to associated
-- outputs directly.
GEN_NO_CDC_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin

    cdc2sg_run_stop         <= reg2cdc_run_stop         ;
    cdc2sg_stop             <= reg2cdc_stop             ;
    cdc2sg_taildesc_wren    <= reg2cdc_taildesc_wren    ;
    cdc2sg_taildesc         <= reg2cdc_taildesc         ;
    cdc2sg_curdesc          <= reg2cdc_curdesc          ;
    cdc2dmac_ftch_idle      <= sg2cdc_ftch_idle         ;
    cdc2reg_ftch_interr_set <= sg2cdc_ftch_interr_set   ;
    cdc2reg_ftch_slverr_set <= sg2cdc_ftch_slverr_set   ;
    cdc2reg_ftch_decerr_set <= sg2cdc_ftch_decerr_set   ;
    cdc2reg_ftch_err        <= sg2cdc_ftch_err          ;
    cdc2reg_ftch_err_addr   <= sg2cdc_ftch_err_addr     ;

end generate GEN_NO_CDC_FOR_SYNC;



end implementation;
