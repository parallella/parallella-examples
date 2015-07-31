-------------------------------------------------------------------------------
-- axi_vdma_genlock_mux
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
-- Filename:        axi_vdma_genlock_mux.vhd
--
-- Description:     This entity encompasses the Gen Lock Mux.  This entity
--                  rips frame_ptr_in bus based on master in control selection.
--                  MUX size based on number of masters parameter.
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
entity  axi_vdma_genlock_mux is
    generic(
        C_GENLOCK_NUM_MASTERS   	: integer range 1 to 16     := 1                    ;
            -- Number of Gen-Lock masters capable of controlling Gen-Lock Slave

        C_INTERNAL_GENLOCK_ENABLE   	: integer range 0 to 1  := 0
            -- Enable internal genlock bus
            -- 0 = disable internal genlock bus
            -- 1 = enable internal genlock bus
    );
    port (

        prmry_aclk              : in std_logic                                      ;   --
        prmry_resetn            : in std_logic                                      ;   --
                                                                                        --
        mstr_in_control         : in std_logic_vector(3 downto 0)                   ;   --
        genlock_select          : in std_logic                                      ;   --
                                                                                        --
        internal_frame_ptr_in   : in  std_logic_vector                                  --
                                    (NUM_FRM_STORE_WIDTH-1 downto 0)                ;   --
        frame_ptr_in            : in std_logic_vector                                   --
                                    ((C_GENLOCK_NUM_MASTERS                             --
                                    *NUM_FRM_STORE_WIDTH)-1 downto 0)               ;   --
                                                                                        --
        frame_ptr_out           : out std_logic_vector                                  --
                                    (NUM_FRM_STORE_WIDTH-1 downto 0)                    --
    );
end axi_vdma_genlock_mux;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_genlock_mux is
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
signal frame_ptr2use        : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)  := (others => '0');
signal mstr_selected        : std_logic_vector(3 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Register frame pointer out
REG_POINTER_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                frame_ptr_out <= (others => '0');

            else
                frame_ptr_out <= frame_ptr2use;
            end if;
        end if;
    end process REG_POINTER_OUT;

-- If internal genlock NOT selected or enabled then set to DMACR pointer ref
-- else if internal genlock is enabled and selected then set to master 0
mstr_selected <= mstr_in_control when genlock_select = '0' or C_INTERNAL_GENLOCK_ENABLE = 0
            else MSTR0;


-- 16 Master Frame Pointer In to Slave Pointer To Use Out
GEN_16_MASTERS : if C_GENLOCK_NUM_MASTERS = 16 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

                when MSTR11 =>
                    frame_ptr2use <= frame_ptr_in(MSTR11_HI_INDEX downto MSTR11_LO_INDEX);

                when MSTR12 =>
                    frame_ptr2use <= frame_ptr_in(MSTR12_HI_INDEX downto MSTR12_LO_INDEX);

                when MSTR13 =>
                    frame_ptr2use <= frame_ptr_in(MSTR13_HI_INDEX downto MSTR13_LO_INDEX);

                when MSTR14 =>
                    frame_ptr2use <= frame_ptr_in(MSTR14_HI_INDEX downto MSTR14_LO_INDEX);

                when MSTR15 =>
                    frame_ptr2use <= frame_ptr_in(MSTR15_HI_INDEX downto MSTR15_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_16_MASTERS;

-- 15 Master Frame Pointer In to Slave Pointer To Use Out
GEN_15_MASTERS : if C_GENLOCK_NUM_MASTERS = 15 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

                when MSTR11 =>
                    frame_ptr2use <= frame_ptr_in(MSTR11_HI_INDEX downto MSTR11_LO_INDEX);

                when MSTR12 =>
                    frame_ptr2use <= frame_ptr_in(MSTR12_HI_INDEX downto MSTR12_LO_INDEX);

                when MSTR13 =>
                    frame_ptr2use <= frame_ptr_in(MSTR13_HI_INDEX downto MSTR13_LO_INDEX);

                when MSTR14 =>
                    frame_ptr2use <= frame_ptr_in(MSTR14_HI_INDEX downto MSTR14_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_15_MASTERS;

-- 14 Master Frame Pointer In to Slave Pointer To Use Out
GEN_14_MASTERS : if C_GENLOCK_NUM_MASTERS = 14 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

                when MSTR11 =>
                    frame_ptr2use <= frame_ptr_in(MSTR11_HI_INDEX downto MSTR11_LO_INDEX);

                when MSTR12 =>
                    frame_ptr2use <= frame_ptr_in(MSTR12_HI_INDEX downto MSTR12_LO_INDEX);

                when MSTR13 =>
                    frame_ptr2use <= frame_ptr_in(MSTR13_HI_INDEX downto MSTR13_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_14_MASTERS;

-- 13 Master Frame Pointer In to Slave Pointer To Use Out
GEN_13_MASTERS : if C_GENLOCK_NUM_MASTERS = 13 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

                when MSTR11 =>
                    frame_ptr2use <= frame_ptr_in(MSTR11_HI_INDEX downto MSTR11_LO_INDEX);

                when MSTR12 =>
                    frame_ptr2use <= frame_ptr_in(MSTR12_HI_INDEX downto MSTR12_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_13_MASTERS;


-- 12 Master Frame Pointer In to Slave Pointer To Use Out
GEN_12_MASTERS : if C_GENLOCK_NUM_MASTERS = 12 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

                when MSTR11 =>
                    frame_ptr2use <= frame_ptr_in(MSTR11_HI_INDEX downto MSTR11_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_12_MASTERS;

-- 11 Master Frame Pointer In to Slave Pointer To Use Out
GEN_11_MASTERS : if C_GENLOCK_NUM_MASTERS = 11 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

                when MSTR10 =>
                    frame_ptr2use <= frame_ptr_in(MSTR10_HI_INDEX downto MSTR10_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_11_MASTERS;

-- 10 Master Frame Pointer In to Slave Pointer To Use Out
GEN_10_MASTERS : if C_GENLOCK_NUM_MASTERS = 10 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

                when MSTR9 =>
                    frame_ptr2use <= frame_ptr_in(MSTR9_HI_INDEX downto MSTR9_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_10_MASTERS;

-- 9 Master Frame Pointer In to Slave Pointer To Use Out
GEN_9_MASTERS : if C_GENLOCK_NUM_MASTERS = 9 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

                when MSTR8 =>
                    frame_ptr2use <= frame_ptr_in(MSTR8_HI_INDEX downto MSTR8_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_9_MASTERS;

-- 8 Master Frame Pointer In to Slave Pointer To Use Out
GEN_8_MASTERS : if C_GENLOCK_NUM_MASTERS = 8 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

                when MSTR7 =>
                    frame_ptr2use <= frame_ptr_in(MSTR7_HI_INDEX downto MSTR7_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_8_MASTERS;

-- 7 Master Frame Pointer In to Slave Pointer To Use Out
GEN_7_MASTERS : if C_GENLOCK_NUM_MASTERS = 7 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

                when MSTR6 =>
                    frame_ptr2use <= frame_ptr_in(MSTR6_HI_INDEX downto MSTR6_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_7_MASTERS;

-- 6 Master Frame Pointer In to Slave Pointer To Use Out
GEN_6_MASTERS : if C_GENLOCK_NUM_MASTERS = 6 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);

                when MSTR5 =>
                    frame_ptr2use <= frame_ptr_in(MSTR5_HI_INDEX downto MSTR5_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on

            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_6_MASTERS;

-- 5 Master Frame Pointer In to Slave Pointer To Use Out
GEN_5_MASTERS : if C_GENLOCK_NUM_MASTERS = 5 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

                when MSTR4 =>
                    frame_ptr2use <= frame_ptr_in(MSTR4_HI_INDEX downto MSTR4_LO_INDEX);


    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on
            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_5_MASTERS;

-- 4 Master Frame Pointer In to Slave Pointer To Use Out
GEN_4_MASTERS : if C_GENLOCK_NUM_MASTERS = 4 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

                when MSTR3 =>
                    frame_ptr2use <= frame_ptr_in(MSTR3_HI_INDEX downto MSTR3_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on
            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_4_MASTERS;

-- 3 Master Frame Pointer In to Slave Pointer To Use Out
GEN_3_MASTERS : if C_GENLOCK_NUM_MASTERS = 3 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

                when MSTR2 =>
                    frame_ptr2use <= frame_ptr_in(MSTR2_HI_INDEX downto MSTR2_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on
            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_3_MASTERS;

-- 2 Master Frame Pointer In to Slave Pointer To Use Out
GEN_2_MASTERS : if C_GENLOCK_NUM_MASTERS = 2 generate
begin
    MASTER_CONTROL_MUX : process(mstr_selected, frame_ptr_in, genlock_select, internal_frame_ptr_in)
        begin
            case mstr_selected is
                when MSTR0 =>
                    -- If internal genlock bus included and dmacr.genlock_select=1
                    -- then route internal genlock bus as frame pointer to use
                    if(C_INTERNAL_GENLOCK_ENABLE = 1 and  genlock_select = '1')then
                        frame_ptr2use <= internal_frame_ptr_in;
                    else
                        frame_ptr2use <= frame_ptr_in(MSTR0_HI_INDEX downto MSTR0_LO_INDEX);
                    end if;

                when MSTR1 =>
                    frame_ptr2use <= frame_ptr_in(MSTR1_HI_INDEX downto MSTR1_LO_INDEX);

    -- coverage off

                when others =>
                    frame_ptr2use <= (others => '0');
    -- coverage on
            end case;
        end process MASTER_CONTROL_MUX;
end generate GEN_2_MASTERS;

-- 1 Master Frame Pointer In to Slave Pointer To Use Out
GEN_1_MASTERS : if C_GENLOCK_NUM_MASTERS = 1 generate
begin


--    GEN_MUX_FOR_INTERNAL : if C_INTERNAL_GENLOCK_ENABLE = 1 generate
--    begin
--    -- If internal genlock bus included and dmacr.genlock_select=1
--    -- then route internal genlock bus as frame pointer to use
--        MASTER_CONTROL_MUX : process(frame_ptr_in,internal_frame_ptr_in,genlock_select)
--            begin
--                if(genlock_select = '0')then
--                    frame_ptr2use <= frame_ptr_in;
--                else
--                    frame_ptr2use <= internal_frame_ptr_in;
--                end if;
--            end process MASTER_CONTROL_MUX;
--
--    end generate GEN_MUX_FOR_INTERNAL;
    GEN_MUX_FOR_INTERNAL : if C_INTERNAL_GENLOCK_ENABLE = 1 generate
    begin
                       frame_ptr2use <= internal_frame_ptr_in;

    end generate GEN_MUX_FOR_INTERNAL;

    GEN_MUX_FOR_NO_INTERNAL : if C_INTERNAL_GENLOCK_ENABLE = 0 generate
    begin
        frame_ptr2use <= frame_ptr_in;
    end generate GEN_MUX_FOR_NO_INTERNAL;

end generate GEN_1_MASTERS;

end implementation;
