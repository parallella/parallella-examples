-------------------------------------------------------------------------------
-- axi_vdma_fsync_gen
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
-- Filename:    axi_vdma_fsync_gen.vhd
-- Description: This entity generates the frame sync for vdma operations.
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

-------------------------------------------------------------------------------
entity  axi_vdma_fsync_gen is
    generic (
        C_USE_FSYNC                 	: integer range 0 to 1        := 0;
            -- Specifies DMA oeration synchronized to frame sync input
            -- 0 = Free running
            -- 1 = Fsync synchronous

        ENABLE_FLUSH_ON_MM2S_FSYNC      : integer range 0 to 1        := 0      ;
        ENABLE_FLUSH_ON_S2MM_FSYNC      : integer range 0 to 1        := 0      ;
        C_INCLUDE_S2MM                  : integer range 0 to 1        := 0      ;
        C_INCLUDE_MM2S                  : integer range 0 to 1        := 0      ;
        
        C_SOF_ENABLE                	: integer range 0 to 1        := 0
            -- Enable/Disable start of frame generation on tuser(0). This
            -- is only valid for external frame sync (C_USE_FSYNC = 1)
            -- 0 = disable SOF
            -- 1 = enable SOF
    );
    port (
        prmry_aclk                  : in  std_logic                         ;           --
        prmry_resetn                : in  std_logic                         ;           --
                                                                                        --
        -- Frame Count Enable Support                                                   --
        valid_video_prmtrs          : in  std_logic                         ;           --
        valid_frame_sync_cmb        : in  std_logic                         ;           --
        frmcnt_ioc                  : in  std_logic                         ;           --
        dmacr_frmcnt_enbl           : in  std_logic                         ;           --
        dmasr_frmcnt_status         : in  std_logic_vector(7 downto 0)      ;           --
        mask_fsync_out              : out std_logic                         ;           --
                                                                                        --
        -- VDMA status for free run (C_USE_FSYNC = 0)                                   --
        run_stop                    : in  std_logic                         ;           --
        all_idle                    : in  std_logic                         ;           --
        parameter_update            : in  std_logic                         ;           --
                                                                                        --
        -- Frame Sync Sources (C_USE_FSYNC = 1)                                         --
        fsync                       : in  std_logic                         ;           --
        tuser_fsync                 : in  std_logic                         ;           --
        othrchnl_fsync              : in  std_logic                         ;           --
        fsync_src_select            : in  std_logic_vector(1 downto 0)      ;           --
                                                                                        --
        -- Sync out for VDMA logic                                                      --
        frame_sync                  : out std_logic                         ;           --
                                                                                        --
        -- Sync / Update out top level for Video IP                                     --
        frame_sync_out              : out std_logic                         ;           --
        prmtr_update                : out std_logic                                     --


    );

end axi_vdma_fsync_gen;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_fsync_gen is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

constant FRAME_COUNT_ONE : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(1,8));

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------

-- No Signals Declared

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- Generate Free Run Mode (Internal Frame Sync)
-------------------------------------------------------------------------------
GEN_FREE_RUN_MODE : if C_USE_FSYNC = 0 generate
-- For internal fsync generation
signal all_idle_d1          : std_logic := '0';
signal all_idle_d2          : std_logic := '0';
signal all_idle_re          : std_logic := '0';

-- For internal fsync and fsync out
signal frame_sync_aligned   : std_logic := '0';
signal frame_sync_i         : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';
begin

    -- Register all idle for use in creating rising edge pulse
    REG_IDLE : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                -- On reset clear flag
                if(prmry_resetn = '0')then
                    all_idle_d1  <= '0';
                    all_idle_d2  <= '0';
                -- Otherwise pass idle state through to gen re pulse
                else
                    all_idle_d1  <= all_idle;
                    all_idle_d2  <= all_idle_d1;
                end if;
            end if;
        end process REG_IDLE;

    all_idle_re <= all_idle_d1 and not all_idle_d2;

    -- Register frame sync source to shift all processes started
    -- by fsync 1 clock later in time.  This allows initial FrameDelay
    -- and resulting calculation to be registered before
    -- being latched by frame_sync.
    REG_FSYNC_PROCESS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_i <= '0';
                else
                    frame_sync_i <= all_idle_re and run_stop;
                end if;
            end if;
        end process REG_FSYNC_PROCESS;

    -- Pass out for internal use (secondary clock domain)
    frame_sync  <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;


end generate GEN_FREE_RUN_MODE;


-------------------------------------------------------------------------------
-- Generate Frame Sync Mode (External frame sync)
-------------------------------------------------------------------------------
-- Note: Treated async and sync clock modes as async so fsync out behavior is
-- identical regardless of mode.
GEN_FSYNC_MODE_MM2S_NO_SOF : if (C_USE_FSYNC = 1 and C_INCLUDE_MM2S = 1 and (ENABLE_FLUSH_ON_MM2S_FSYNC = 0 or C_SOF_ENABLE = 0)) generate
-- Frame sync for VDMA and for core output
signal frame_sync_i         : std_logic := '0';
signal frame_sync_aligned   : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';


begin
        -- Frame sync cross bar
        FSYNC_CROSSBAR : process(fsync_src_select,
                                 run_stop,
                                 fsync,
                                 othrchnl_fsync)
            begin
                case fsync_src_select is

                    when "00" =>   -- primary fsync (default)
                        frame_sync_i <= fsync and run_stop;
                    when "01" =>   -- other channel fsync
                        frame_sync_i <= othrchnl_fsync and run_stop;
                    when others =>
                        frame_sync_i <= '0';
                end case;
            end process FSYNC_CROSSBAR;

----    end generate GEN_FSYNC_NO_SOF;


    -- Pass out for VDMA use
    frame_sync <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;

end generate GEN_FSYNC_MODE_MM2S_NO_SOF;

GEN_FSYNC_MODE_MM2S_SOF : if (C_USE_FSYNC = 1 and C_INCLUDE_MM2S = 1 and ENABLE_FLUSH_ON_MM2S_FSYNC = 1 and C_SOF_ENABLE = 1) generate
-- Frame sync for VDMA and for core output
signal frame_sync_i         : std_logic := '0';
signal frame_sync_aligned   : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';


begin

    frame_sync_i <= fsync;
    -- Pass out for VDMA use
    frame_sync <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;

end generate GEN_FSYNC_MODE_MM2S_SOF;




-------------------------------------------------------------------------------
-- Generate Frame Sync Mode (External frame sync)
-------------------------------------------------------------------------------
-- Note: Treated async and sync clock modes as async so fsync out behavior is
-- identical regardless of mode.
GEN_FSYNC_MODE_S2MM_NON_FLUSH : if (C_USE_FSYNC = 1 and C_INCLUDE_S2MM = 1 and ENABLE_FLUSH_ON_S2MM_FSYNC = 0) generate
-- Frame sync for VDMA and for core output
signal frame_sync_i         : std_logic := '0';
signal frame_sync_aligned   : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';


begin
    -- generate fsync from tuser
    GEN_FSYNC_FOR_SOF : if C_SOF_ENABLE = 1 generate
    begin

        -- frame_sync_i <= tuser_fsync and run_stop;

        -- Frame sync cross bar
        FSYNC_CROSSBAR : process(fsync_src_select,
                                 run_stop,
                                 fsync,
                                 othrchnl_fsync,
                                 tuser_fsync)
            begin
                case fsync_src_select is

                    when "00" =>   -- primary fsync (default)
                        frame_sync_i <= fsync and run_stop;
                    when "01" =>   -- other channel fsync
                        frame_sync_i <= othrchnl_fsync and run_stop;
                    when "10" =>   -- tuser fsync  (used only by s2mm)
                        frame_sync_i <= tuser_fsync and run_stop;
                    when others =>
                        frame_sync_i <= '0';
                end case;
            end process FSYNC_CROSSBAR;

    end generate GEN_FSYNC_FOR_SOF;

    -- generate fsync from fsync
    GEN_FSYNC_NO_SOF  : if C_SOF_ENABLE = 0 generate
    begin
        -- Internal fsync on fe for vdma if running
        --frame_sync_i <= fsync and run_stop;


        -- Frame sync cross bar
        FSYNC_CROSSBAR : process(fsync_src_select,
                                 run_stop,
                                 fsync,
                                 othrchnl_fsync)
            begin
                case fsync_src_select is

                    when "00" =>   -- primary fsync (default)
                        frame_sync_i <= fsync and run_stop;
                    when "01" =>   -- other channel fsync
                        frame_sync_i <= othrchnl_fsync and run_stop;
                    when others =>
                        frame_sync_i <= '0';
                end case;
            end process FSYNC_CROSSBAR;

    end generate GEN_FSYNC_NO_SOF;


    -- Pass out for VDMA use
    frame_sync <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;

end generate GEN_FSYNC_MODE_S2MM_NON_FLUSH;


-------------------------------------------------------------------------------
-- Generate Frame Sync Mode (External frame sync)
-------------------------------------------------------------------------------
-- Note: Treated async and sync clock modes as async so fsync out behavior is
-- identical regardless of mode.
GEN_FSYNC_MODE_S2MM_FLUSH_NON_SOF : if (C_USE_FSYNC = 1 and C_INCLUDE_S2MM = 1 and ENABLE_FLUSH_ON_S2MM_FSYNC = 1 and C_SOF_ENABLE = 0) generate
-- Frame sync for VDMA and for core output
signal frame_sync_i         : std_logic := '0';
signal frame_sync_aligned   : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';


begin

        -- Frame sync cross bar
        FSYNC_CROSSBAR : process(fsync_src_select,
                                 run_stop,
                                 fsync,
                                 othrchnl_fsync)
            begin
                case fsync_src_select is

                    when "00" =>   -- primary fsync (default)
                        frame_sync_i <= fsync and run_stop;
                    when "01" =>   -- other channel fsync
                        frame_sync_i <= othrchnl_fsync and run_stop;
                    when others =>
                        frame_sync_i <= '0';
                end case;
            end process FSYNC_CROSSBAR;



    -- Pass out for VDMA use
    frame_sync <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;

end generate GEN_FSYNC_MODE_S2MM_FLUSH_NON_SOF;


-------------------------------------------------------------------------------
-- Generate Frame Sync Mode (External frame sync)
-------------------------------------------------------------------------------
-- Note: Treated async and sync clock modes as async so fsync out behavior is
-- identical regardless of mode.
GEN_FSYNC_MODE_S2MM_FLUSH_SOF : if (C_USE_FSYNC = 1 and C_INCLUDE_S2MM = 1 and ENABLE_FLUSH_ON_S2MM_FSYNC = 1 and C_SOF_ENABLE = 1) generate
-- Frame sync for VDMA and for core output
signal frame_sync_i         : std_logic := '0';
signal frame_sync_aligned   : std_logic := '0';
signal mask_fsync_out_i     : std_logic := '0';


begin


    frame_sync_i <= fsync;
    -- Pass out for VDMA use
    frame_sync <= frame_sync_i;

    -- For frame count enable, mask fsync out at end of frame.
    FRAME_SYNC_MASK : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then

                    mask_fsync_out_i <= '0';

                -- If masked and ioc occurs then clear mask
                elsif(mask_fsync_out_i = '1' and frmcnt_ioc = '1')then
                    mask_fsync_out_i <= '0';

                -- On frame count enable at end of last frame mask off last fsync out
                elsif(dmacr_frmcnt_enbl = '1' and dmasr_frmcnt_status = FRAME_COUNT_ONE and valid_frame_sync_cmb = '1')then
                    mask_fsync_out_i <= '1';

                end if;
            end if;
        end process FRAME_SYNC_MASK;

    mask_fsync_out  <= mask_fsync_out_i or not valid_video_prmtrs;

    -------------------------------------------------------------------
    -- GENERATE FSYNC OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Align internal fsync with parameter update.  Parameter update
    -- asserts on next clock after frame_sync therefor by adding 1
    -- pipe of delay we align parameter_update input with frame_sync
    REG_DELAY_FSYNC : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk ='1')then
                -- clear on reset or s_h clear
                if(prmry_resetn = '0')then
                    frame_sync_aligned <= '0';
                else
                    frame_sync_aligned <= frame_sync_i;
                end if;
            end if;
        end process REG_DELAY_FSYNC;

    -- Provide output of frame sync to target Video IP.
    REG_FSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    frame_sync_out <= '0';
                else
                    frame_sync_out  <= frame_sync_aligned and not mask_fsync_out_i and valid_video_prmtrs;
                end if;
            end if;
        end process REG_FSYNC_OUT;

    -------------------------------------------------------------------
    -- GENERATE PARAMETER UPDATE OUT FOR VIDEO IP
    -------------------------------------------------------------------
    -- Provide output of video parameter update to target Video IP.
    REG_PRMTRUPDT_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    prmtr_update   <= '0';
                else
                    prmtr_update   <= parameter_update and not mask_fsync_out_i;
                end if;
            end if;
        end process REG_PRMTRUPDT_OUT;

end generate GEN_FSYNC_MODE_S2MM_FLUSH_SOF;






end implementation;
