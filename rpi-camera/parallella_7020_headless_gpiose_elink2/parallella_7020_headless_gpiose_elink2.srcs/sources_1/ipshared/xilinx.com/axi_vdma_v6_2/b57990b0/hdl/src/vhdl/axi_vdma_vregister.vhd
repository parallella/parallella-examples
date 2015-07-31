-------------------------------------------------------------------------------
-- axi_vdma_vregister
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
-- Filename:        axi_vdma_vregister.vhd
--
-- Description: Top level for video register block.  These registers provide
--              the video parameters to the DMA controllers.
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

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

-------------------------------------------------------------------------------
entity  axi_vdma_vregister is
    generic(
        C_NUM_FSTORES             : integer range 1 to 32       := 1        ;
            -- Number of Frame Stores

        C_ADDR_WIDTH              : integer range 32 to 32      := 32
            -- Start Address Width
    );
    port (
        prmry_aclk                  : in  std_logic                         ;           --
        prmry_resetn                : in  std_logic                         ;           --
                                                                                        --
        -- Video Register Update control                                                --
        video_reg_update            : in  std_logic                         ;           --
                                                                                        --
        dmasr_halt                  : in  std_logic                         ;           --
        -- Scatter Gather register Bank                                                 --
        vsize_sg                    : in  std_logic_vector                              --
                                        (VSIZE_DWIDTH-1 downto 0)           ;           --
        hsize_sg                    : in  std_logic_vector                              --
                                        (HSIZE_DWIDTH-1 downto 0)           ;           --
        stride_sg                   : in  std_logic_vector                              --
                                        (STRIDE_DWIDTH-1 downto 0)          ;           --
        frmdly_sg                   : in  std_logic_vector                              --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;           --
        start_address_sg            : in STARTADDR_ARRAY_TYPE                              --
                                        (0 to C_NUM_FSTORES - 1)            ;           --
        -- Video Register Bank                                                          --
        vsize_vid                   : out std_logic_vector                              --
                                        (VSIZE_DWIDTH-1 downto 0)           ;           --
        hsize_vid                   : out std_logic_vector                              --
                                        (HSIZE_DWIDTH-1 downto 0)           ;           --
        stride_vid                  : out std_logic_vector                              --
                                        (STRIDE_DWIDTH-1 downto 0)          ;           --
        frmdly_vid                  : out std_logic_vector                              --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;           --
        start_address_vid           : out STARTADDR_ARRAY_TYPE
                                        (0 to C_NUM_FSTORES - 1)                        --

    );
end axi_vdma_vregister;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_vregister is
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

-- No Signals Declared

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


-- Vertical Size - Video Side
REG_VSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                vsize_vid <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                vsize_vid <= vsize_sg;
            end if;
        end if;
    end process REG_VSIZE;

-- Horizontal Size - Video Side
REG_HSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                hsize_vid <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                hsize_vid <= hsize_sg;
            end if;
        end if;
    end process REG_HSIZE;

-- Stride - Video Side
REG_STRIDE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                stride_vid <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                stride_vid <= stride_sg;
            end if;
        end if;
    end process REG_STRIDE;

-- Frame Delay - Video Side
REG_FRMDLY : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                frmdly_vid <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                frmdly_vid <= frmdly_sg;
            end if;
        end if;
    end process REG_FRMDLY;


-- Generate C_NUM_FSTORE start address registeres
GEN_START_ADDR_REG : for i in 0 to C_NUM_FSTORES-1 generate
begin
        -- Start Address Registers
        REG_START_ADDR : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_vid(i)   <= (others => '0');
                    elsif(video_reg_update = '1')then
                        start_address_vid(i)   <= start_address_sg(i);

                    end if;
                end if;
            end process REG_START_ADDR;

end generate GEN_START_ADDR_REG;

end implementation;
