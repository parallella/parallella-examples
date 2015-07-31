-------------------------------------------------------------------------------
-- axi_vdma_vid_cdc
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
-- Filename:    axi_vdma_vid_cdc.vhd
-- Description: This entity encompases the Clock Domain Crossing Pulse
--              Generator
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
entity  axi_vdma_vid_cdc is
    generic (
        C_PRMRY_IS_ACLK_ASYNC       : integer range 0 to 1      := 0            ;
        C_GENLOCK_MSTR_PTR_DWIDTH   : integer                   := 32           ;
        C_GENLOCK_SLVE_PTR_DWIDTH   : integer                   := 32           ;
        C_INTERNAL_GENLOCK_ENABLE   : integer range 0 to 1      := 0
    );
    port (
        prmry_aclk                  : in  std_logic                             ;       --
        prmry_resetn                : in  std_logic                             ;       --
                                                                                        --
        scndry_aclk                 : in  std_logic                             ;       --
        scndry_resetn               : in  std_logic                             ;       --
                                                                                        --
        -- Cross pntr/fsync to opposing channel                                         --
        othrchnl_aclk               : in  std_logic                             ;       --
        othrchnl_resetn             : in  std_logic                             ;       --
        othrchnl2cdc_frame_ptr_out  : in  std_logic_vector                              --
                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ;       --
        cdc2othrchnl_frame_ptr_in   : out std_logic_vector                              --
                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ;       --

        cdc2othrchnl_fsync          : out std_logic                             ;       --
                                                                                        --
                                                                                        --
        -- GEN-LOCK Clock Domain Crossing                                               --
        dmac2cdc_frame_ptr_out      : in  std_logic_vector                              --
                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ;       --
        cdc2top_frame_ptr_out       : out std_logic_vector                              --
                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ;       --
                                                                                        --
        top2cdc_frame_ptr_in        : in  std_logic_vector                              --
                                        (C_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0)  ;       --
        cdc2dmac_frame_ptr_in       : out std_logic_vector                              --
                                        (C_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0)  ;       --
                                                                                        --
        dmac2cdc_mstrfrm_tstsync    : in  std_logic                             ;       --
        cdc2dmac_mstrfrm_tstsync    : out std_logic                             ;       --
                                                                                        --
        -- SOF Detection Domain Crossing (secondary to primary)                         --
        vid2cdc_packet_sof          : in  std_logic                             ;       --
        cdc2dmac_packet_sof         : out std_logic                             ;       --
                                                                                        --
        -- Frame Sync Generation Domain Crossing                                        --
        vid2cdc_fsync               : in  std_logic                             ;       --
        cdc2dmac_fsync              : out std_logic                             ;       --
                                                                                        --
        dmac2cdc_fsync_out          : in  std_logic                             ;       --
        cdc2vid_fsync_out           : out std_logic                             ;       --
                                                                                        --
        dmac2cdc_prmtr_update       : in  std_logic                             ;       --
        cdc2vid_prmtr_update        : out std_logic                                     --

    );

end axi_vdma_vid_cdc;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_vid_cdc is
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
-- Cross sample and held fsync to secondary
signal s_fsync_d1               : std_logic := '0';
signal s_fsync_d2               : std_logic := '0';
signal s_fsync_fe               : std_logic := '0';

signal frame_ptr_in_d1_cdc_tig          : std_logic_vector(C_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0) := (others => '0');
signal frame_ptr_in_d2		        : std_logic_vector(C_GENLOCK_SLVE_PTR_DWIDTH-1 downto 0) := (others => '0');
signal frame_ptr_out_d1_cdc_tig         : std_logic_vector(C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0) := (others => '0');
signal frame_ptr_out_d2		        : std_logic_vector(C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0) := (others => '0');

signal othrchnl_frame_ptr_in_d1_cdc_tig : std_logic_vector(C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0) := (others => '0');
signal othrchnl_frame_ptr_in_d2	        : std_logic_vector(C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0) := (others => '0');
signal cdc2dmac_fsync_i         	: std_logic := '0';


  ATTRIBUTE async_reg                      : STRING;
  ATTRIBUTE async_reg OF frame_ptr_in_d1_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF frame_ptr_in_d2          : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF frame_ptr_out_d1_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF frame_ptr_out_d2          : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF othrchnl_frame_ptr_in_d1_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF othrchnl_frame_ptr_in_d2	   : SIGNAL IS "true"; 

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

cdc2dmac_fsync  <= cdc2dmac_fsync_i;


-- register fsync in and set up for creating fall edge
REG_FSYNC_IN : process(scndry_aclk)
    begin
        if(scndry_aclk'EVENT and scndry_aclk ='1')then
            if(scndry_resetn = '0')then
                s_fsync_d1  <= '0';
                s_fsync_d2  <= '0';
            else
                s_fsync_d1  <= vid2cdc_fsync;
                s_fsync_d2  <= s_fsync_d1;
            end if;
        end if;
    end process REG_FSYNC_IN;

 -- Pass scndry fe out for frame sync if running
s_fsync_fe <= not s_fsync_d1 and s_fsync_d2;


-- Aysnchronous mode therefore instantiate clock domain crossing logic
GEN_CDC_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

--*****************************************************************************
--** GenLock CDC
--*****************************************************************************

    -- From GenLock manager to AXIS clock domain
----    M_PTR_OUT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => C_GENLOCK_MSTR_PTR_DWIDTH
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                            ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                           ,
----            scndry_in               => '0'                                      ,
----            prmry_out               => open                                     ,
----            prmry_in                => dmac2cdc_mstrfrm_tstsync                 ,
----            scndry_out              => cdc2dmac_mstrfrm_tstsync                 ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT
----                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT
----                                        (C_GENLOCK_MSTR_PTR_DWIDTH-1 downto 0)  ,
----            scndry_vect_out         => open
----        );
----


M_PTR_OUT_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dmac2cdc_mstrfrm_tstsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2dmac_mstrfrm_tstsync,
        scndry_vect_out            => open
    );





    -- frame_ptr is grey coded and thus double register is all that is needed
    CROSS_FRMPTR_IN_1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    frame_ptr_in_d1_cdc_tig         <= top2cdc_frame_ptr_in;
                    frame_ptr_in_d2         	    <= frame_ptr_in_d1_cdc_tig;
            end if;
        end process CROSS_FRMPTR_IN_1;

    CROSS_FRMPTR_IN_2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    cdc2dmac_frame_ptr_in   <= (others => '0');
                else
                    cdc2dmac_frame_ptr_in   <= frame_ptr_in_d2;
                end if;
            end if;
        end process CROSS_FRMPTR_IN_2;


    -- frame_ptr is grey coded and thus double register is all that is needed
    CROSS_FRMPTR_OUT_1 : process(scndry_aclk)
        begin
            if(scndry_aclk'EVENT and scndry_aclk = '1')then
                    frame_ptr_out_d1_cdc_tig        <= dmac2cdc_frame_ptr_out;
                    frame_ptr_out_d2        	    <= frame_ptr_out_d1_cdc_tig;
            end if;
        end process CROSS_FRMPTR_OUT_1;

    CROSS_FRMPTR_OUT_2 : process(scndry_aclk)
        begin
            if(scndry_aclk'EVENT and scndry_aclk = '1')then
                if(scndry_resetn = '0')then
                    cdc2top_frame_ptr_out   <= (others => '0');
                else
                    cdc2top_frame_ptr_out   <= frame_ptr_out_d2;
                end if;
            end if;
        end process CROSS_FRMPTR_OUT_2;




    GEN_FOR_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 1 generate
    begin
        -- Cross from primary channel to other channel
        -- (or opposing channel, i.e. mm2s to s2mm or s2mm to mm2s)
        -- Used for internal genlock option
        CROSS_TO_OTHR_CHANNEL_1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                        othrchnl_frame_ptr_in_d1_cdc_tig    <= othrchnl2cdc_frame_ptr_out;
                        othrchnl_frame_ptr_in_d2    	    <= othrchnl_frame_ptr_in_d1_cdc_tig;
                end if;
            end process CROSS_TO_OTHR_CHANNEL_1;

        CROSS_TO_OTHR_CHANNEL_2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        cdc2othrchnl_frame_ptr_in   <= (others => '0');
                    else
                        cdc2othrchnl_frame_ptr_in   <= othrchnl_frame_ptr_in_d2;
                    end if;
                end if;
            end process CROSS_TO_OTHR_CHANNEL_2;




    end generate GEN_FOR_INTERNAL_GENLOCK;

    GEN_FOR_NO_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 0 generate
    begin
        cdc2othrchnl_frame_ptr_in   <= (others => '0');
    end generate GEN_FOR_NO_INTERNAL_GENLOCK;


    -- Cross other fsync into primary clock domain
----    OTHR_FSYNC_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => othrchnl_aclk                            ,
----            prmry_resetn            => othrchnl_resetn                          ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => s_fsync_fe                               ,
----            prmry_out               => cdc2othrchnl_fsync                       ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );

OTHR_FSYNC_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => s_fsync_fe, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => othrchnl_aclk, 
        scndry_resetn              => othrchnl_resetn,
        scndry_out                 => cdc2othrchnl_fsync,
        scndry_vect_out            => open
    );





--*****************************************************************************
--** SOF CDC
--*****************************************************************************
----    SOF_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                            ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                           ,
----            scndry_in               => vid2cdc_packet_sof                       ,
----            prmry_out               => cdc2dmac_packet_sof                      ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----



SOF_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => vid2cdc_packet_sof, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2dmac_packet_sof,
        scndry_vect_out            => open
    );




--*****************************************************************************
--** Frame Sync CDC
--*****************************************************************************
    -- From axi vdma top out (scndry_aclk) to frame sync gen (prmry_aclk)
----    FSYNC_IN_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----
----            scndry_in               => s_fsync_fe                               ,
----            prmry_out               => cdc2dmac_fsync_i                         ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----



FSYNC_IN_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => s_fsync_fe, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => cdc2dmac_fsync_i,
        scndry_vect_out            => open
    );





    -- From frame sync gen (prmry_aclk) to axi vdma top out (scndry_aclk)
----    FSYNC_OUT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                            ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                           ,
----            scndry_in               => '0'                                      ,
----            prmry_out               => open                                     ,
----            prmry_in                => dmac2cdc_fsync_out                       ,
----            scndry_out              => cdc2vid_fsync_out                        ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----





FSYNC_OUT_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dmac2cdc_fsync_out, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2vid_fsync_out,
        scndry_vect_out            => open
    );







    -- From frame sync gen (prmry_aclk) to axi vdma top out (scndry_aclk)
----    PRMTR_UPDT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                            ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                           ,
----            scndry_in               => '0'                                      ,
----            prmry_out               => open                                     ,
----            prmry_in                => dmac2cdc_prmtr_update                    ,
----            scndry_out              => cdc2vid_prmtr_update                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );



PRMTR_UPDT_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dmac2cdc_prmtr_update, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => scndry_aclk, 
        scndry_resetn              => scndry_resetn,
        scndry_out                 => cdc2vid_prmtr_update,
        scndry_vect_out            => open
    );





end generate GEN_CDC_FOR_ASYNC;


-- Synchronous Mode therefore map inputs to associated
-- outputs directly.
GEN_NO_CDC_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin

    cdc2top_frame_ptr_out       <= dmac2cdc_frame_ptr_out   ;
    cdc2dmac_frame_ptr_in       <= top2cdc_frame_ptr_in     ;
    cdc2dmac_mstrfrm_tstsync    <= dmac2cdc_mstrfrm_tstsync ;
    cdc2dmac_packet_sof         <= vid2cdc_packet_sof;
    cdc2dmac_fsync_i            <= s_fsync_fe               ;
    cdc2vid_fsync_out           <= dmac2cdc_fsync_out       ;
    cdc2vid_prmtr_update        <= dmac2cdc_prmtr_update    ;
    cdc2othrchnl_fsync          <= s_fsync_fe               ;

    GEN_FOR_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 1 generate
    begin

        cdc2othrchnl_frame_ptr_in <= othrchnl2cdc_frame_ptr_out;

    end generate GEN_FOR_INTERNAL_GENLOCK;

    GEN_FOR_NO_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 0 generate
    begin
        cdc2othrchnl_frame_ptr_in   <= (others => '0');
    end generate GEN_FOR_NO_INTERNAL_GENLOCK;


end generate GEN_NO_CDC_FOR_SYNC;



end implementation;
