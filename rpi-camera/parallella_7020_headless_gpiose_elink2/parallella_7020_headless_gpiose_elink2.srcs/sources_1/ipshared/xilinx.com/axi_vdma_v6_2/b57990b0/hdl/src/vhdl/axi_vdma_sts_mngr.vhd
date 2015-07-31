-------------------------------------------------------------------------------
-- axi_vdma_sts_mngr
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
-- Filename:    axi_vdma_sts_mngr.vhd
-- Description: This entity mangages 'halt' and 'idle' status
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
entity  axi_vdma_sts_mngr is
    port (
        -- system signals
        prmry_aclk                  : in  std_logic                         ;   --
        prmry_resetn                : in  std_logic                         ;   --
                                                                                --
        -- dma control and sg engine status signals                             --
        run_stop                    : in  std_logic                         ;   --
        regdir_idle                 : in  std_logic                         ;   --
        ftch_idle                   : in  std_logic                         ;   --
        cmnd_idle                   : in  std_logic                         ;   --
        sts_idle                    : in  std_logic                         ;   --
        line_buffer_empty           : in  std_logic                         ;   --
        dwidth_fifo_pipe_empty      : in  std_logic                         ;   --
        video_prmtrs_valid          : in  std_logic                         ;   --
        prmtr_update_complete       : in  std_logic                         ;   --CR605424
                                                                                --
        -- stop and halt control/status                                         --
        stop                        : in  std_logic                         ;   --
        halt                        : in  std_logic                         ;   -- CR 625278
        halt_cmplt                  : in  std_logic                         ;   --
                                                                                --
        -- system state and control                                             --
        all_idle                    : out std_logic                         ;   --
        ftchcmdsts_idle             : out std_logic                         ;   --
        cmdsts_idle                 : out std_logic                         ;   --
        halted_clr                  : out std_logic                         ;   --
        halted_set                  : out std_logic                         ;   --
        idle_set                    : out std_logic                         ;   --
        idle_clr                    : out std_logic                             --

    );

end axi_vdma_sts_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_sts_mngr is
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
signal all_is_idle          : std_logic := '0';
signal ftch_idle_d1         : std_logic := '0';
signal ftch_idle_re         : std_logic := '0';
signal ftch_idle_fe         : std_logic := '0';
signal datamover_idle       : std_logic := '0';
--signal cmdstsfifo_idle      : std_logic := '0';
signal halted_set_i         : std_logic := '0';
--signal datamover_idle_i     : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- CR573389 - modified all_idle output to look at sg engine ftch idle only
-- if video parameters are NOT valid, else ignore ftchidle.  this fixes
-- issue of xfer pausing while descriptors are being fetched.
-- all_idle only used for frame sync determination
ALL_IDLE_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                all_idle <= '1';

            -- Qualify all idle with sg engine fetch idle when
            -- no video parameters are valid
            elsif(video_prmtrs_valid = '0')then
                all_idle <= ftch_idle
                                and cmnd_idle
                                and sts_idle
                                and line_buffer_empty
				and dwidth_fifo_pipe_empty
                                and regdir_idle                             -- Reg Direct idle (for fsync only)
                                and prmtr_update_complete;                  -- CR605424 idle needs to account for lutram copy

            -- Otherwise if we have valid video parameters then do
            -- not stall transfers in free-run mode due to sg engine fetches
            else
                all_idle <= cmnd_idle
                                and sts_idle
				and dwidth_fifo_pipe_empty
                                and line_buffer_empty;
            end if;
        end if;
    end process ALL_IDLE_PROCESS;


-- Idle for soft_reset determination
-- Note Line buffer is not looked at because do not want to stall soft reset if external
-- stream target does not accept data from line buffer.
ftchcmdsts_idle <= ftch_idle
                  and cmnd_idle
                  and sts_idle;

-- Command/Status Idle (Used for s2mm linebuffer reset qualification on shut down)
cmdsts_idle <= cmnd_idle
            and sts_idle;


-------------------------------------------------------------------------------
-- For data mover halting look at halt complete to determine when halt
-- is done and datamover has completly halted.  If datamover not being
-- halted then can ignore flag thus simply flag as idle.
-------------------------------------------------------------------------------
-- CR 625278
--datamover_idle  <= '1' when (stop = '1' and halt_cmplt = '1')
--                         or (stop = '0')
--                   else '0';
--
-- Need to sample and hold for cases when user clears run/stop starting
-- a shutdown phase, then an error occurs (stop=1) causing a second
-- shutdown phase to start.  previous the halt complete was missed by datamove_idle
-- because stop asserted after the halt complete asserted due to the first
-- shutdown phase.
DATAMOVER_IDLE_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                datamover_idle <= '0';
            -- if dm being halted and halt is completed then
            -- set and hold datamover idle.
            elsif(halt = '1' and halt_cmplt = '1')then
                datamover_idle <= '1';

            -- clear datamove_idle if running and dm not
            -- being halted.
            elsif(halt = '0' and run_stop = '1')then
                datamover_idle <= '0';

            end if;
        end if;
    end process DATAMOVER_IDLE_PROCESS;


-------------------------------------------------------------------------------
-- Set halt bit if run/stop cleared and all processes are idle
-------------------------------------------------------------------------------
-- Everything is idle when everything is idle used for setting halt flag.
all_is_idle <=  ftch_idle
            and cmnd_idle
            and sts_idle
   	    and dwidth_fifo_pipe_empty
            and line_buffer_empty;

HALT_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                halted_set_i <= '0';

            -- DMACR.Run/Stop is cleared, all processes are idle, datamover halt cmplted
            elsif(run_stop = '0' and all_is_idle = '1' and datamover_idle = '1')then
                halted_set_i <= '1';
            else
                halted_set_i <= '0';
            end if;
        end if;
    end process HALT_PROCESS;

halted_set  <= halted_set_i;

-------------------------------------------------------------------------------
-- Clear halt bit if run/stop is set and SG engine begins to fetch descriptors
-------------------------------------------------------------------------------
NOT_HALTED_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                halted_clr <= '0';
            elsif(run_stop = '1')then
                halted_clr <= '1';
            else
                halted_clr <= '0';
            end if;
        end if;
    end process NOT_HALTED_PROCESS;

-------------------------------------------------------------------------------
-- Register ALL is Idle to create rising and falling edges on idle flag
-------------------------------------------------------------------------------
IDLE_REG_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                ftch_idle_d1 <= '0';
            else
                ftch_idle_d1 <= ftch_idle;
            end if;
        end if;
    end process IDLE_REG_PROCESS;

ftch_idle_re  <= ftch_idle and not ftch_idle_d1;
ftch_idle_fe  <= not ftch_idle and ftch_idle_d1;

-- Set or Clear IDLE bit in DMASR
idle_set <= ftch_idle_re and run_stop;
idle_clr <= ftch_idle_fe;


end implementation;
