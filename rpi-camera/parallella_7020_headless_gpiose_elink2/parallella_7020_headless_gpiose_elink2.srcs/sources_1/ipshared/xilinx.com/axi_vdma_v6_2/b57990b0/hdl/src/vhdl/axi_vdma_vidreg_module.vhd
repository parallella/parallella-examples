-------------------------------------------------------------------------------
-- axi_vdma_vidreg_module
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
-- Filename:        axi_vdma_vidreg_module.vhd
--
-- Description:     This entity is the top level for the dual register blocks,
--                  i.e. video register set and sg register set and provides
--                  indication of valid parameters.
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
entity  axi_vdma_vidreg_module is
    generic(
        C_INCLUDE_SG              : integer range 0 to 1        := 1        ;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_NUM_FSTORES             : integer range 1 to 32       := 1        ;
            -- Number of Frame Stores

        -----------------------------------------------------------------------
        C_DYNAMIC_RESOLUTION      : integer range 0 to 1      	:= 1	    ;
            -- Run time configuration of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 0 = Halt VDMA before writing new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 1 = Run time register configuration for new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE.
        -----------------------------------------------------------------------




        C_ADDR_WIDTH              : integer range 32 to 32      := 32       ;
            -- Start Address Width

        C_FAMILY                  : string            		:= "virtex7"
            -- Target FPGA Device Family


    );
    port (
        prmry_aclk                  : in  std_logic                         ;       --
        prmry_resetn                : in  std_logic                         ;       --
                                                                                    --
                                                                                    --
        -- Register update control                                                  --
        run_stop                    : in  std_logic                         ;       --
        dmasr_halt                  : in  std_logic                         ;       --
        ftch_idle                   : in  std_logic                         ;       --
        tailpntr_updated            : in  std_logic                         ;       --
        frame_number                : in  std_logic_vector                          --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;       --
        num_fstore_minus1           : in  std_logic_vector                          --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;       --
                                                                                    --
        -- Register swap control/status                                             --
        frame_sync                  : in  std_logic                         ;       --
        ftch_complete               : in  std_logic                         ;       --
        ftch_complete_clr           : out std_logic                         ;       --
        parameter_update            : out std_logic                         ;       --
        video_prmtrs_valid          : out std_logic                         ;       --
        prmtr_update_complete       : out std_logic                         ;       -- CR605424
                                                                                    --
        -- Register Direct Mode Video Parameter In                                  --
        reg_module_vsize            : in  std_logic_vector                          --
                                        (VSIZE_DWIDTH-1 downto 0)           ;       --
        reg_module_hsize            : in  std_logic_vector                          --
                                        (HSIZE_DWIDTH-1 downto 0)           ;       --
        reg_module_stride           : in  std_logic_vector                          --
                                        (STRIDE_DWIDTH-1 downto 0)          ;       --
        reg_module_frmdly           : in  std_logic_vector                          --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;       --
        reg_module_strt_addr        : in STARTADDR_ARRAY_TYPE                       --
                                        (0 to C_NUM_FSTORES - 1)            ;       --
                                                                                    --
        -- Descriptor data/control from sg interface                                --
        desc_data_wren              : in  std_logic                         ;       --
                                                                                    --
        desc_strtaddress            : in  std_logic_vector                          --
                                        (C_ADDR_WIDTH-1 downto 0)           ;       --
        desc_vsize                  : in  std_logic_vector                          --
                                        (VSIZE_DWIDTH-1 downto 0)           ;       --
        desc_hsize                  : in  std_logic_vector                          --
                                        (HSIZE_DWIDTH-1 downto 0)           ;       --
        desc_stride                 : in  std_logic_vector                          --
                                        (STRIDE_DWIDTH-1 downto 0)          ;       --
        desc_frmdly                 : in  std_logic_vector                          --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;       --
                                                                                    --
        -- Scatter Gather register Bank                                             --
        crnt_vsize                  : out std_logic_vector                          --
                                        (VSIZE_DWIDTH-1 downto 0)           ;       --
        crnt_hsize                  : out std_logic_vector                          --
                                        (HSIZE_DWIDTH-1 downto 0)           ;       --
        crnt_stride                 : out std_logic_vector                          --
                                        (STRIDE_DWIDTH-1 downto 0)          ;       --
        crnt_frmdly                 : out std_logic_vector                          --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;       --
        crnt_start_address          : out std_logic_vector                          --
                                        (C_ADDR_WIDTH - 1 downto 0)                 --
    );
end axi_vdma_vidreg_module;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_vidreg_module is
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
-- Control
signal video_parameter_updt     : std_logic := '0';
signal video_prmtrs_valid_i     : std_logic := '0';
signal ftch_complete_clr_i      : std_logic := '0';
signal run_stop_re              : std_logic := '0';
signal run_stop_d1              : std_logic := '0';
signal video_reg_updated        : std_logic := '0';
signal video_reg_update         : std_logic := '0';
signal update_complete          : std_logic := '0';

-- Scatter Gather Side Video Register Bank
--signal vsize_sg                 : std_logic_vector(VSIZE_DWIDTH-1 downto 0)    := (others => '0');
--signal hsize_sg                 : std_logic_vector(HSIZE_DWIDTH-1 downto 0)    := (others => '0');
--signal stride_sg                : std_logic_vector(STRIDE_DWIDTH-1 downto 0)   := (others => '0');
--signal frmdly_sg                : std_logic_vector(FRMDLY_DWIDTH-1 downto 0)   := (others => '0');
signal start_address_vid        : STARTADDR_ARRAY_TYPE(0 to C_NUM_FSTORES - 1);
--signal start_address_sg         : STARTADDR_ARRAY_TYPE(0 to C_NUM_FSTORES - 1);


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin



-- If Scatter Gather engine is included then instantiate SG register block
GEN_SG_REGISTER : if C_INCLUDE_SG = 1 generate
begin

    -- Flag for updating video parameters on descriptor fetch
    -- Used to enable vsize, hsize, stride, frmdly update on first desc
    -- fetchted
    REG_UPDATE_VIDEO_PRMTRS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_parameter_updt <= '0';
                -- if new tailpointer and sg fetch engine idle or if new start then
                -- set flag to capture video parameters
                elsif((tailpntr_updated = '1' and ftch_idle = '1') or run_stop_re = '1')then
                    video_parameter_updt <= '1';
                -- clear flag when parameters written to video_register module.
                elsif(desc_data_wren = '1')then
                    video_parameter_updt <= '0';
                end if;
            end if;
        end process REG_UPDATE_VIDEO_PRMTRS;


    -- Register run stop to generate rising edge pulse
    -- Used to force start address counter reset on shutdown
    REG_RUN_STOP : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    run_stop_d1 <= '0';
                else
                    run_stop_d1 <= run_stop;
                end if;
            end if;
        end process REG_RUN_STOP;

        run_stop_re <= run_stop and not run_stop_d1;

    -- Scatter Gather Start Address Register Block (LUTRAM)
    SG_ADDREG_I : entity  axi_vdma_v6_2.axi_vdma_sgregister
        generic map(
            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
            C_ADDR_WIDTH                => C_ADDR_WIDTH                         ,
            C_FAMILY                    => C_FAMILY
        )
        port map (
            prmry_aclk               => prmry_aclk                              ,
            prmry_resetn             => prmry_resetn                            ,

            -- Update Control
            video_reg_update            => video_reg_update                     ,
            video_parameter_updt        => video_parameter_updt                 ,
            video_parameter_valid       => video_prmtrs_valid_i                 ,
            dmasr_halt                  => dmasr_halt                           ,
            strt_addr_clr               => run_stop_re                          ,
            desc_data_wren              => desc_data_wren                       ,
            frame_number                => frame_number                         ,
            ftch_complete               => ftch_complete                        ,
            ftch_complete_clr           => ftch_complete_clr_i                  ,
            update_complete             => update_complete                      ,
            num_fstore_minus1           => num_fstore_minus1                    , -- CR607089

            -- Video Start Address / Parameters In from Scatter Gather Engine
            desc_vsize                  => desc_vsize                           ,
            desc_hsize                  => desc_hsize                           ,
            desc_stride                 => desc_stride                          ,
            desc_frmdly                 => desc_frmdly                          ,
            desc_strtaddress            => desc_strtaddress                     ,

            -- Video Start Address / Parameters Out to DMA Controller
            crnt_vsize                  => crnt_vsize                           ,
            crnt_hsize                  => crnt_hsize                           ,
            crnt_stride                 => crnt_stride                          ,
            crnt_frmdly                 => crnt_frmdly                          ,
            crnt_start_address          => crnt_start_address
        );

    -- Generate logic to transfer sg bank to vid bank of registers
    -- transfer on frame sync if sg engine fetch is complete
    --video_reg_update <= '1' when (frame_sync = '1' and ftch_complete = '1')
    --                          or (video_prmtrs_valid_i = '0' and ftch_complete = '1')
    --               else '0';
    video_reg_update <= '1' when (frame_sync = '1' and update_complete = '1')
                              or (video_prmtrs_valid_i = '0' and update_complete = '1')
                   else '0';

    -- CR605424
    -- Pass up to sts_mngr when update is finally complete
    -- This is used for initial fsync generation for Free Run mode
    prmtr_update_complete   <= update_complete;

    -- Indicate valid parameters on fsync and video registers updated.
    REG_VIDPRMTR_VALID : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- reset or channel halt will clear video parameters
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_prmtrs_valid_i    <= '0';
                    ftch_complete_clr_i     <= '0';
                -- Frame sync and video parameter have been updated,then flag video parameters
                -- valid
                --elsif(frame_sync = '1' and ftch_complete = '1')then
                elsif(frame_sync = '1' and update_complete = '1')then
                    video_prmtrs_valid_i    <= '1';
                    ftch_complete_clr_i     <= '1';
                else
                    video_prmtrs_valid_i    <= video_prmtrs_valid_i;
                    ftch_complete_clr_i     <= '0';
                end if;
            end if;
        end process REG_VIDPRMTR_VALID;

    -- When video register block update drive out parameter update flag
    -- for generation of ****_prmtr_update output
    parameter_update <= ftch_complete_clr_i;

    -- Clear fetch flag in sg interface
    ftch_complete_clr <= ftch_complete_clr_i;

    -- Drive out flag to sm and frame counter that valid video
    -- parameters have been loaded.
    video_prmtrs_valid  <= video_prmtrs_valid_i;

end generate GEN_SG_REGISTER;


-- If Scatter Gather engine is excluded then instantiate register direct block
GEN_REGISTER_DIRECT : if C_INCLUDE_SG = 0 generate
begin

  GEN_REGDIRECT_DRES : if C_DYNAMIC_RESOLUTION = 1 generate

   begin

    ftch_complete_clr <= '0'; -- Not Used in Register Direct Mode

    -- Register Direct Mode - Video Register Block
-------    REGDIR_REGBLOCK_I : entity  axi_vdma_v6_2.axi_vdma_vregister
-------        generic map(
-------            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
-------            C_ADDR_WIDTH                => C_ADDR_WIDTH
-------
-------        )
-------        port map(
-------            prmry_aclk                  => prmry_aclk                           ,
-------            prmry_resetn                => prmry_resetn                         ,
-------
-------            -- Video Register Update control
-------            video_reg_update            => ftch_complete                        ,
-------
-------            dmasr_halt                  => dmasr_halt                           ,
-------
-------            -- Scatter Gather register Bank
-------            vsize_sg                    => reg_module_vsize                     ,
-------            hsize_sg                    => reg_module_hsize                     ,
-------            stride_sg                   => reg_module_stride                    ,
-------            frmdly_sg                   => reg_module_frmdly                    ,
-------            start_address_sg            => reg_module_strt_addr                 ,
-------
-------            -- Video Register Bank
-------            vsize_vid                   => vsize_sg                             ,
-------            hsize_vid                   => hsize_sg                             ,
-------            stride_vid                  => stride_sg                            ,
-------            frmdly_vid                  => frmdly_sg                            ,
-------            start_address_vid           => start_address_sg
-------        );
-------
    -- Flag when video parameters/start address have been updated.
    -- Assert on sg engine fetch or register update is complete
    REG_PRE_VIDREG_UPDT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear flag on reset, or halt
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_reg_updated       <= '0';

                elsif(video_reg_updated = '1' and frame_sync = '1')then
                    video_reg_updated       <= '0';

                -- video parameter from register module updated to
                -- pre-video register block
                elsif(ftch_complete = '1')then			-- in RegDirect mode ftch_complete = writing VSIZE register.
                    video_reg_updated       <= '1';
                end if;
            end if;
        end process REG_PRE_VIDREG_UPDT;

    -- Generate logic to transfer sg bank to vid bank of registers
    -- transfer on frame sync if sg engine fetch is complete
    video_reg_update <= '1' when (frame_sync = '1' and video_reg_updated = '1')
                              or (video_prmtrs_valid_i = '0' and video_reg_updated = '1')
                   else '0';

    -- CR605424
    -- Pass up to sts_mngr when update is finally complete
    -- This is used for initial fsync generation for Free Run mode
    prmtr_update_complete   <= video_reg_updated;

    -- Indicate valid parameters on fsync and video registers updated.
    REG_VIDPRMTR_VALID : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- reset or channel halt will clear video parameters
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_prmtrs_valid_i    <= '0';
                    parameter_update        <= '0';
                -- Frame sync and video parameter have been updated,then flag video parameters
                -- valid
                -- CR583673 - Fixes wrong hsize and frmdly values being registered on first frame
                --elsif(frame_sync = '1' and (ftch_complete = '1' or video_reg_updated = '1'))then
                elsif(frame_sync = '1' and video_reg_updated = '1')then
                    video_prmtrs_valid_i    <= '1';
                    parameter_update        <= '1';
                else
                    video_prmtrs_valid_i    <= video_prmtrs_valid_i;
                    parameter_update        <= '0';
                end if;
            end if;
        end process REG_VIDPRMTR_VALID;

    -- Drive out flag to sm and frame counter that valid video
    -- parameters have been loaded.
    video_prmtrs_valid  <= video_prmtrs_valid_i;


    -- Video Register Block
    VIDREGISTER_I : entity  axi_vdma_v6_2.axi_vdma_vregister
        generic map(
            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
            C_ADDR_WIDTH                => C_ADDR_WIDTH

        )
        port map(
            prmry_aclk                  => prmry_aclk                           ,
            prmry_resetn               => prmry_resetn                        ,

            -- Video Register Update control
            video_reg_update            => video_reg_update                     ,

            dmasr_halt                  => dmasr_halt                           ,

            -- Scatter Gather register Bank
--            vsize_sg                    => vsize_sg                             ,
--            hsize_sg                    => hsize_sg                             ,
--            stride_sg                   => stride_sg                            ,
--            frmdly_sg                   => frmdly_sg                            ,
--            start_address_sg            => start_address_sg                     ,

            vsize_sg                    => reg_module_vsize                     ,
            hsize_sg                    => reg_module_hsize                     ,
            stride_sg                   => reg_module_stride                    ,
            frmdly_sg                   => reg_module_frmdly                    ,
            start_address_sg            => reg_module_strt_addr                 ,




            -- Video Register Bank
            vsize_vid                   => crnt_vsize                           ,
            hsize_vid                   => crnt_hsize                           ,
            stride_vid                  => crnt_stride                          ,
            frmdly_vid                  => crnt_frmdly                          ,
            start_address_vid           => start_address_vid

        );

    -- Video Start Address MUX
    VIDADDR_MUX_I : entity  axi_vdma_v6_2.axi_vdma_vaddrreg_mux
        generic map(
            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
            C_ADDR_WIDTH                => C_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => prmry_aclk                           ,
            prmry_resetn               => prmry_resetn                          ,

            -- Current Frame Number
            frame_number                => frame_number                         ,
            start_address_vid           => start_address_vid                    ,
            crnt_start_address          => crnt_start_address
        );

  end generate GEN_REGDIRECT_DRES;


  GEN_REGDIRECT_NO_DRES : if C_DYNAMIC_RESOLUTION = 0 generate

   begin

    ftch_complete_clr <= '0'; -- Not Used in Register Direct Mode

    -- Flag when video parameters/start address have been updated.
    -- Assert on sg engine fetch or register update is complete
    REG_PRE_VIDREG_UPDT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- Clear flag on reset, or halt
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_reg_updated       <= '0';

                elsif(video_reg_updated = '1' and frame_sync = '1')then
                    video_reg_updated       <= '0';

                -- video parameter from register module updated to
                -- pre-video register block
                elsif(ftch_complete = '1')then			-- in RegDirect mode ftch_complete = writing VSIZE register.
                    video_reg_updated       <= '1';
                end if;
            end if;
        end process REG_PRE_VIDREG_UPDT;

    -- CR605424
    -- Pass up to sts_mngr when update is finally complete
    -- This is used for initial fsync generation for Free Run mode
    prmtr_update_complete   <= video_reg_updated;

    -- Indicate valid parameters on fsync and video registers updated.
    REG_VIDPRMTR_VALID : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- reset or channel halt will clear video parameters
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                    video_prmtrs_valid_i    <= '0';
                    parameter_update        <= '0';
                -- Frame sync and video parameter have been updated,then flag video parameters
                -- valid
                -- CR583673 - Fixes wrong hsize and frmdly values being registered on first frame
                --elsif(frame_sync = '1' and (ftch_complete = '1' or video_reg_updated = '1'))then
                elsif(frame_sync = '1' and video_reg_updated = '1')then
                    video_prmtrs_valid_i    <= '1';
                    parameter_update        <= '1';
                else
                    video_prmtrs_valid_i    <= video_prmtrs_valid_i;
                    parameter_update        <= '0';
                end if;
            end if;
        end process REG_VIDPRMTR_VALID;

    -- Drive out flag to sm and frame counter that valid video
    -- parameters have been loaded.
    video_prmtrs_valid  <= video_prmtrs_valid_i;



crnt_vsize 		<= reg_module_vsize;
crnt_hsize 		<= reg_module_hsize;
crnt_stride 		<= reg_module_stride;
crnt_frmdly 		<= reg_module_frmdly;

-- Generate C_NUM_FSTORE start address registeres
GEN_START_ADDR_REG : for i in 0 to C_NUM_FSTORES-1 generate
begin

start_address_vid(i) 	<= reg_module_strt_addr(i);

end generate GEN_START_ADDR_REG;

    -- Video Start Address MUX
    VIDADDR_MUX_I : entity  axi_vdma_v6_2.axi_vdma_vaddrreg_mux
        generic map(
            C_NUM_FSTORES               => C_NUM_FSTORES                        ,
            C_ADDR_WIDTH                => C_ADDR_WIDTH
        )
        port map(
            prmry_aclk                  => prmry_aclk                           ,
            prmry_resetn               => prmry_resetn                          ,

            -- Current Frame Number
            frame_number                => frame_number                         ,
            start_address_vid           => start_address_vid                    ,
            crnt_start_address          => crnt_start_address
        );

  end generate GEN_REGDIRECT_NO_DRES;



end generate GEN_REGISTER_DIRECT;




end implementation;

