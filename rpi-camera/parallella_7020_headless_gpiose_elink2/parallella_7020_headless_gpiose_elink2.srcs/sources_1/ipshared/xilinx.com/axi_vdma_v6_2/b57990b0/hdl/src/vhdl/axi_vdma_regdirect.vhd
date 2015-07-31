-------------------------------------------------------------------------------
-- axi_vdma_regdirect
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
-- Filename:        axi_vdma_regdirect.vhd
--
-- Description:     This entity encompasses the channel register set.
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
entity  axi_vdma_regdirect is
    generic(
        C_NUM_REGISTERS             : integer                   := 6        ;
        C_NUM_FSTORES               : integer range 1 to 32     := 1        ;
        C_GENLOCK_MODE              : integer range 0 to 3      := 0        ;

        -----------------------------------------------------------------------
        C_DYNAMIC_RESOLUTION        : integer range 0 to 1      := 1	    ;
            -- Run time configuration of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 0 = Halt VDMA before writing new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE
            -- 1 = Run time register configuration for new set of HSIZE, STRIDE, FRM_DLY, StartAddress & VSIZE.
        -----------------------------------------------------------------------


        C_S_AXI_LITE_DATA_WIDTH     : integer range 32 to 32    := 32       ;
        C_M_AXI_ADDR_WIDTH          : integer range 32 to 32    := 32
    );
    port (
        prmry_aclk                  : in  std_logic                         ;           --
        prmry_resetn                : in  std_logic                         ;           --
                                                                                        --
        -- AXI Interface Control                                                        --
        axi2ip_wrce                 : in  std_logic_vector                              --
                                        (C_NUM_REGISTERS-1 downto 0)        ;           --
        axi2ip_wrdata               : in  std_logic_vector                              --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);           --
                                                                                        --
        run_stop                    : in  std_logic                         ;           --
        dmasr_halt                  : in  std_logic                         ;           --
        stop                        : in  std_logic                         ;           --
                                                                                        --

        reg_index                       : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --

        -- Register Direct Support                                                      --
        prmtr_updt_complete         : out std_logic                         ;           --
        regdir_idle                 : out std_logic                         ;           --
                                                                                        --
        -- Register Direct Mode Video Parameter In                                      --
        reg_module_vsize            : out std_logic_vector                              --
                                        (VSIZE_DWIDTH-1 downto 0)           ;           --
        reg_module_hsize            : out std_logic_vector                              --
                                        (HSIZE_DWIDTH-1 downto 0)           ;           --
        reg_module_strid            : out std_logic_vector                              --
                                        (STRIDE_DWIDTH-1 downto 0)          ;           --
        reg_module_frmdly           : out std_logic_vector                              --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;           --
        reg_module_strt_addr        : out STARTADDR_ARRAY_TYPE                          --
                                        (0 to C_NUM_FSTORES - 1)            ;           --
        reg_module_start_address1   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address2   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address3   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address4   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address5   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address6   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address7   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address8   : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address9   : out std_logic_vector                              --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address10  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address11  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address12  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address13  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address14  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address15  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address16  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address17  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address18  : out std_logic_vector                              --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address19  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address20  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address21  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address22  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address23  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address24  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address25  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address26  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address27  : out std_logic_vector                              --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address28  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address29  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address30  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address31  : out std_logic_vector                              --
                                         (C_M_AXI_ADDR_WIDTH - 1 downto 0);           --
        reg_module_start_address32  : out std_logic_vector                              --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)            --

    );
end axi_vdma_regdirect;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_regdirect is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
constant VSYNC_INDEX          : integer := 0;           -- VSYNC Register index
constant HSYNC_INDEX          : integer := 1;           -- HSYNC Register index
constant DLY_STRIDE_INDEX     : integer := 2;           -- STRIDE/DLY Reg index
--constant RESERVED_INDEX3      : integer := 3;           -- Reserved
constant STARTADDR1_INDEX       : integer := 3;           -- Start Address 1 Reg index
constant STARTADDR2_INDEX       : integer := 4;           -- Start Address 2 Reg index
constant STARTADDR3_INDEX       : integer := 5;           -- Start Address 3 Reg index
constant STARTADDR4_INDEX       : integer := 6;           -- Start Address 3 Reg index
constant STARTADDR5_INDEX       : integer := 7;           -- Start Address 3 Reg index
constant STARTADDR6_INDEX       : integer := 8;           -- Start Address 3 Reg index
constant STARTADDR7_INDEX       : integer := 9;           -- Start Address 3 Reg index
constant STARTADDR8_INDEX       : integer := 10;          -- Start Address 3 Reg index
constant STARTADDR9_INDEX       : integer := 11;          -- Start Address 3 Reg index
constant STARTADDR10_INDEX      : integer := 12;          -- Start Address 3 Reg index
constant STARTADDR11_INDEX      : integer := 13;          -- Start Address 3 Reg index
constant STARTADDR12_INDEX      : integer := 14;          -- Start Address 3 Reg index
constant STARTADDR13_INDEX      : integer := 15;          -- Start Address 3 Reg index
constant STARTADDR14_INDEX      : integer := 16;          -- Start Address 3 Reg index
constant STARTADDR15_INDEX      : integer := 17;          -- Start Address 3 Reg index
constant STARTADDR16_INDEX      : integer := 18;          -- Start Address 3 Reg index


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal prmtr_updt_complete_i    : std_logic := '0';
signal reg_config_locked_i      : std_logic := '0';
signal regdir_idle_i            : std_logic := '0';
signal run_stop_d1              : std_logic := '0';
signal run_stop_re              : std_logic := '0';

--signal reg_module_strt_addr_i   : STARTADDR_ARRAY_TYPE(0 to MAX_FSTORES-1);
signal reg_module_start_address1_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address2_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address3_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address4_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address5_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address6_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address7_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address8_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address9_i  : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address10_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address11_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address12_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address13_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address14_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address15_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address16_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address17_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address18_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address19_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address20_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address21_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address22_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address23_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address24_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address25_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address26_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address27_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address28_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address29_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address30_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address31_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal reg_module_start_address32_i : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


-- Register DMACR RunStop bit to create a RE pulse
REG_RUN_RE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                run_stop_d1 <= '0';
            else
                run_stop_d1 <= run_stop;
            end if;
        end if;
    end process REG_RUN_RE;

run_stop_re    <= run_stop and not run_stop_d1;

-- Gen register direct idle flag to indicate when not idle.
-- Flag is asserted to NOT idle at start of run and to Idle
-- on reset, halt, or stop (i.e. error)
-- This is used to generate first fsync in free run mode.
REG_IDLE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or stop = '1')then
                regdir_idle_i <= '1';

            elsif(run_stop_re = '1')then
                regdir_idle_i <= '0';

            elsif(prmtr_updt_complete_i = '1')then
                regdir_idle_i <= '1';
            end if;
        end if;
    end process REG_IDLE;

regdir_idle <= regdir_idle_i;

-- Vertical Size Register
VSIZE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                reg_module_vsize   <= (others => '0');
            elsif(axi2ip_wrce(VSYNC_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_vsize   <= axi2ip_wrdata(VSIZE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process VSIZE_REGISTER;

VIDEO_PRMTR_UPDATE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or run_stop = '0')then
                prmtr_updt_complete_i    <= '0';
            elsif(axi2ip_wrce(VSYNC_INDEX) = '1' and reg_config_locked_i = '0')then
                prmtr_updt_complete_i    <= '1';
            else
                prmtr_updt_complete_i    <= '0';
            end if;
        end if;
    end process VIDEO_PRMTR_UPDATE;

prmtr_updt_complete <= prmtr_updt_complete_i;

-- Horizontal Size Register
HSIZE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                reg_module_hsize   <= (others => '0');
            elsif(axi2ip_wrce(HSYNC_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_hsize   <= axi2ip_wrdata(HSIZE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process HSIZE_REGISTER;

-- Delay/Stride Register
--Genlock Slave mode 
S_GEN_DLYSTRIDE_REGISTER : if C_GENLOCK_MODE = 1 generate
begin
S_DLYSTRIDE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                --reg_module_frmdly   <= (others => '0');
                reg_module_frmdly   <= "00001";		--CR 709007
                reg_module_strid    <= (others => '0');
            elsif(axi2ip_wrce(DLY_STRIDE_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_frmdly   <= axi2ip_wrdata(FRMDLY_MSB downto FRMDLY_LSB);
                reg_module_strid    <= axi2ip_wrdata(STRIDE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process S_DLYSTRIDE_REGISTER;
end generate S_GEN_DLYSTRIDE_REGISTER;

--Genlock Master mode 
M_GEN_DLYSTRIDE_REGISTER : if C_GENLOCK_MODE = 0 generate
begin
                reg_module_frmdly   <= (others => '0');
M_DLYSTRIDE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                reg_module_strid    <= (others => '0');
            elsif(axi2ip_wrce(DLY_STRIDE_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_strid    <= axi2ip_wrdata(STRIDE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process M_DLYSTRIDE_REGISTER;
end generate M_GEN_DLYSTRIDE_REGISTER;


--Dynamic Genlock Master mode 
DM_GEN_DLYSTRIDE_REGISTER : if C_GENLOCK_MODE = 2 generate
begin
                reg_module_frmdly   <= (others => '0');
DM_DLYSTRIDE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                reg_module_strid    <= (others => '0');
            elsif(axi2ip_wrce(DLY_STRIDE_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_strid    <= axi2ip_wrdata(STRIDE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process DM_DLYSTRIDE_REGISTER;
end generate DM_GEN_DLYSTRIDE_REGISTER;


--Dynamic Genlock Slave mode 
DS_GEN_DLYSTRIDE_REGISTER : if C_GENLOCK_MODE = 3 generate
begin
                reg_module_frmdly   <= (others => '0');
DS_DLYSTRIDE_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                reg_module_strid    <= (others => '0');
            elsif(axi2ip_wrce(DLY_STRIDE_INDEX) = '1' and reg_config_locked_i = '0')then
                reg_module_strid    <= axi2ip_wrdata(STRIDE_DWIDTH-1 downto 0);
            end if;
        end if;
    end process DS_DLYSTRIDE_REGISTER;
end generate DS_GEN_DLYSTRIDE_REGISTER;


--No Dynamic resolution 
GEN_REG_CONFIG_LOCK_BIT : if C_DYNAMIC_RESOLUTION = 0 generate
begin

REG_CONFIG_LOCKED : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                reg_config_locked_i    <= '0';
            elsif(axi2ip_wrce(VSYNC_INDEX) = '1')then
                reg_config_locked_i    <= '1';
            end if;
        end if;
    end process REG_CONFIG_LOCKED;



end generate GEN_REG_CONFIG_LOCK_BIT;

--Dynamic resolution 
GEN_NO_REG_CONFIG_LOCK_BIT : if C_DYNAMIC_RESOLUTION = 1 generate
begin

                reg_config_locked_i    <= '0';

end generate GEN_NO_REG_CONFIG_LOCK_BIT;





--*****************************************************************************
--** START ADDRESS REGISTERS
--*****************************************************************************

-- Generate C_NUM_FSTORE start address registeres
--GEN_START_ADDR_REG : for i in 1 to MAX_FSTORES generate
----signal j              		: integer := 1;
--
--begin
----j<= i;
--
--        -- Start Address Registers
--        START_ADDR : process(prmry_aclk)
--            begin
--                if(prmry_aclk'EVENT and prmry_aclk = '1')then
--                    if(prmry_resetn = '0')then
--                        reg_module_strt_addr_i(i-1)   <= (others => '0');
--                    -- Write to appropriate Start Address
--
--		    elsif(i>= C_NUM_FSTORES)then
--                        reg_module_strt_addr_i(i-1) <= (others => '0');
--
--
--                    elsif(i<C_NUM_FSTORES and axi2ip_wrce(i+2) = '1'and C_NUM_FSTORES <17)then
--			reg_module_strt_addr_i(i-1)   <= axi2ip_wrdata;
--		    elsif(i<C_NUM_FSTORES and C_NUM_FSTORES >=17 and j<17 and axi2ip_wrce(i+2) = '1' and reg_index(0) = '0')then	
--			--if(i<17 and axi2ip_wrce(i+2) = '1')then
--				--if(reg_index(0) = '0')then
--					reg_module_strt_addr_i(i-1)   <= axi2ip_wrdata;
--				--elsif(reg_index(0) = '1')then
--		    elsif(i<C_NUM_FSTORES and C_NUM_FSTORES >=17 and j<17 and axi2ip_wrce(i+2) = '1' and reg_index(0) = '1')then	
--					reg_module_strt_addr_i(i+15)   <= axi2ip_wrdata;
--				--end if;
--			--elsif(i>=17 and axi2ip_wrce(i-14) = '1')then
--		    elsif(i<C_NUM_FSTORES and C_NUM_FSTORES >=17 and j>=17 and axi2ip_wrce(i-14) = '1' and reg_index(0) = '0')then	
--				--if(reg_index(0) = '0')then
--					reg_module_strt_addr_i(i-17)   <= axi2ip_wrdata;
--				--elsif(reg_index(0) = '1')then
--		    elsif(i<C_NUM_FSTORES and C_NUM_FSTORES >=17 and j>=17 and axi2ip_wrce(i-14) = '1' and reg_index(0) = '1')then	
--					reg_module_strt_addr_i(i-1)   <= axi2ip_wrdata;
--				--end if;
--			--end if;
--	            -- For frames greater than fstores the vectors are reserved
--                    -- and set to zero
--                     end if;
--                end if;
--            end process START_ADDR;
--end generate GEN_START_ADDR_REG;

-- Map only C_NUM_FSTORE vectors to output port


-- Number of Fstores Generate
GEN_NUM_FSTORES_1   : if C_NUM_FSTORES = 1 generate

    -- Start Address Register
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    reg_module_start_address2_i   <= (others => '0');
    reg_module_start_address3_i   <= (others => '0');
    reg_module_start_address4_i   <= (others => '0');
    reg_module_start_address5_i   <= (others => '0');
    reg_module_start_address6_i   <= (others => '0');
    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_1;

-- Number of Fstores Generate
GEN_NUM_FSTORES_2   : if C_NUM_FSTORES = 2 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    reg_module_start_address3_i   <= (others => '0');
    reg_module_start_address4_i   <= (others => '0');
    reg_module_start_address5_i   <= (others => '0');
    reg_module_start_address6_i   <= (others => '0');
    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_2;


-- Number of Fstores Generate
GEN_NUM_FSTORES_3   : if C_NUM_FSTORES = 3 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;


    reg_module_start_address4_i   <= (others => '0');
    reg_module_start_address5_i   <= (others => '0');
    reg_module_start_address6_i   <= (others => '0');
    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_3;


-- Number of Fstores Generate
GEN_NUM_FSTORES_4   : if C_NUM_FSTORES = 4 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    reg_module_start_address5_i   <= (others => '0');
    reg_module_start_address6_i   <= (others => '0');
    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_4;


-- Number of Fstores Generate
GEN_NUM_FSTORES_5   : if C_NUM_FSTORES = 5 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    reg_module_start_address6_i   <= (others => '0');
    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_5;

-- Number of Fstores Generate
GEN_NUM_FSTORES_6   : if C_NUM_FSTORES = 6 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    reg_module_start_address7_i   <= (others => '0');
    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_6;

-- Number of Fstores Generate
GEN_NUM_FSTORES_7   : if C_NUM_FSTORES = 7 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    reg_module_start_address8_i   <= (others => '0');
    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_7;

-- Number of Fstores Generate
GEN_NUM_FSTORES_8   : if C_NUM_FSTORES = 8 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    reg_module_start_address9_i   <= (others => '0');
    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_8;



-- Number of Fstores Generate
GEN_NUM_FSTORES_9   : if C_NUM_FSTORES = 9 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    reg_module_start_address10_i  <= (others => '0');
    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_9;

-- Number of Fstores Generate
GEN_NUM_FSTORES_10   : if C_NUM_FSTORES = 10 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    reg_module_start_address11_i  <= (others => '0');
    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_10;

-- Number of Fstores Generate
GEN_NUM_FSTORES_11   : if C_NUM_FSTORES = 11 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    reg_module_start_address12_i  <= (others => '0');
    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_11;

-- Number of Fstores Generate
GEN_NUM_FSTORES_12   : if C_NUM_FSTORES = 12 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    reg_module_start_address13_i  <= (others => '0');
    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_12;

-- Number of Fstores Generate
GEN_NUM_FSTORES_13   : if C_NUM_FSTORES = 13 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    reg_module_start_address14_i  <= (others => '0');
    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_13;

-- Number of Fstores Generate
GEN_NUM_FSTORES_14   : if C_NUM_FSTORES = 14 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    reg_module_start_address15_i  <= (others => '0');
    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_14;

-- Number of Fstores Generate
GEN_NUM_FSTORES_15   : if C_NUM_FSTORES = 15 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    reg_module_start_address16_i  <= (others => '0');
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_15;


-- Number of Fstores Generate
GEN_NUM_FSTORES_16   : if C_NUM_FSTORES = 16 generate

    -- Start Address Register 1
    START_ADDR1 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0')then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;
    reg_module_start_address17_i  <= (others => '0');
    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_16;

-- Number of Fstores Generate
GEN_NUM_FSTORES_17   : if C_NUM_FSTORES = 17 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    START_ADDR2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;

    reg_module_start_address18_i  <= (others => '0');
    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_17;




-- Number of Fstores Generate
GEN_NUM_FSTORES_18   : if C_NUM_FSTORES = 18 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    START_ADDR3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;


    reg_module_start_address19_i  <= (others => '0');
    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_18;





-- Number of Fstores Generate
GEN_NUM_FSTORES_19   : if C_NUM_FSTORES = 19 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    START_ADDR4 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    reg_module_start_address20_i  <= (others => '0');
    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_19;





-- Number of Fstores Generate
GEN_NUM_FSTORES_20   : if C_NUM_FSTORES = 20 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    START_ADDR5 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    reg_module_start_address21_i  <= (others => '0');
    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_20;




-- Number of Fstores Generate
GEN_NUM_FSTORES_21   : if C_NUM_FSTORES = 21 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    START_ADDR6 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    reg_module_start_address22_i  <= (others => '0');
    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_21;




-- Number of Fstores Generate
GEN_NUM_FSTORES_22   : if C_NUM_FSTORES = 22 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    START_ADDR7 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;


    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;



    reg_module_start_address23_i  <= (others => '0');
    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_22;




-- Number of Fstores Generate
GEN_NUM_FSTORES_23   : if C_NUM_FSTORES = 23 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
    START_ADDR8 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;


    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;



    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;



    reg_module_start_address24_i  <= (others => '0');
    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_23;




-- Number of Fstores Generate
GEN_NUM_FSTORES_24   : if C_NUM_FSTORES = 24 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    START_ADDR9 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;


    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;

    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;





    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    reg_module_start_address25_i  <= (others => '0');
    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_24;



-- Number of Fstores Generate
GEN_NUM_FSTORES_25   : if C_NUM_FSTORES = 25 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    START_ADDR10 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;


    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;


    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;

    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;





    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;



    reg_module_start_address26_i  <= (others => '0');
    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_25;




-- Number of Fstores Generate
GEN_NUM_FSTORES_26   : if C_NUM_FSTORES = 26 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    START_ADDR11 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;



    reg_module_start_address27_i  <= (others => '0');
    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_26;






-- Number of Fstores Generate
GEN_NUM_FSTORES_27   : if C_NUM_FSTORES = 27 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    START_ADDR12 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;



    reg_module_start_address28_i  <= (others => '0');
    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_27;




-- Number of Fstores Generate
GEN_NUM_FSTORES_28   : if C_NUM_FSTORES = 28 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    --START_ADDR12 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address12_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address12_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR12;

    -- Start Address Register 13
    START_ADDR13 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;


    START_ADDR28 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                    reg_module_start_address28_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address28_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR28;



    reg_module_start_address29_i  <= (others => '0');
    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_28;




-- Number of Fstores Generate
GEN_NUM_FSTORES_29   : if C_NUM_FSTORES = 29 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    --START_ADDR12 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address12_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address12_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR12;

    -- Start Address Register 13
    --START_ADDR13 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address13_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address13_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR13;

    -- Start Address Register 14
    START_ADDR14 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;


    START_ADDR28 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                    reg_module_start_address28_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address28_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR28;


    START_ADDR29 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                    reg_module_start_address29_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address29_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR29;



    reg_module_start_address30_i  <= (others => '0');
    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_29;



-- Number of Fstores Generate
GEN_NUM_FSTORES_30   : if C_NUM_FSTORES = 30 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    --START_ADDR12 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address12_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address12_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR12;

    -- Start Address Register 13
    --START_ADDR13 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address13_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address13_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR13;

    -- Start Address Register 14
    --START_ADDR14 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address14_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address14_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR14;

    -- Start Address Register 15
    START_ADDR15 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;


    START_ADDR28 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                    reg_module_start_address28_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address28_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR28;


    START_ADDR29 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                    reg_module_start_address29_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address29_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR29;


    START_ADDR30 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                    reg_module_start_address30_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address30_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR30;




    reg_module_start_address31_i  <= (others => '0');
    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_30;




-- Number of Fstores Generate
GEN_NUM_FSTORES_31   : if C_NUM_FSTORES = 31 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    --START_ADDR12 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address12_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address12_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR12;

    -- Start Address Register 13
    --START_ADDR13 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address13_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address13_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR13;

    -- Start Address Register 14
    --START_ADDR14 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address14_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address14_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR14;

    -- Start Address Register 15
    --START_ADDR15 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address15_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address15_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR15;

    -- Start Address Register 16
    START_ADDR16 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;


    START_ADDR28 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                    reg_module_start_address28_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address28_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR28;


    START_ADDR29 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                    reg_module_start_address29_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address29_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR29;


    START_ADDR30 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                    reg_module_start_address30_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address30_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR30;


    START_ADDR31 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                    reg_module_start_address31_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address31_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR31;





    reg_module_start_address32_i  <= (others => '0');

end generate GEN_NUM_FSTORES_31;




-- Number of Fstores Generate
GEN_NUM_FSTORES_32   : if C_NUM_FSTORES = 32 generate

    -- Start Address Register 1
    --START_ADDR1 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address1_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address1_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR1;

    -- Start Address Register 2
    --START_ADDR2 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address2_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address2_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR2;

    -- Start Address Register 3
    --START_ADDR3 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address3_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address3_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR3;

    -- Start Address Register 4
    --START_ADDR4 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address4_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address4_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR4;

    -- Start Address Register 5
    --START_ADDR5 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address5_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address5_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR5;

    -- Start Address Register 6
    --START_ADDR6 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address6_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address6_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR6;

    -- Start Address Register 7
    --START_ADDR7 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address7_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address7_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR7;

    -- Start Address Register 8
   -- START_ADDR8 : process(prmry_aclk)
   --     begin
   --         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   --             if(prmry_resetn = '0')then
   --                 reg_module_start_address8_i   <= (others => '0');
   --             elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
   --                 reg_module_start_address8_i   <= axi2ip_wrdata;
   --             end if;
   --         end if;
   --     end process START_ADDR8;

    -- Start Address Register 9
    --START_ADDR9 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address9_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address9_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR9;

    -- Start Address Register 10
    --START_ADDR10 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address10_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address10_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR10;

    -- Start Address Register 11
    --START_ADDR11 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address11_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address11_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR11;

    -- Start Address Register 12
    --START_ADDR12 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address12_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address12_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR12;

    -- Start Address Register 13
    --START_ADDR13 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address13_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address13_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR13;

    -- Start Address Register 14
    --START_ADDR14 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address14_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address14_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR14;

    -- Start Address Register 15
    --START_ADDR15 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address15_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address15_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR15;

    -- Start Address Register 16
    --START_ADDR16 : process(prmry_aclk)
    --    begin
    --        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    --            if(prmry_resetn = '0')then
    --                reg_module_start_address16_i   <= (others => '0');
    --            elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0' and reg_index(0) = '0'  )then
    --                reg_module_start_address16_i   <= axi2ip_wrdata;
    --            end if;
    --        end if;
    --    end process START_ADDR16;

    -- Start Address Register 17
    START_ADDR17 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address1_i   <= (others => '0');
                    reg_module_start_address17_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address1_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR1_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address17_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR17;
    -- Start Address Register 17
    START_ADDR18 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address2_i   <= (others => '0');
                    reg_module_start_address18_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address2_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR2_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address18_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR18;

    START_ADDR19 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address3_i   <= (others => '0');
                    reg_module_start_address19_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address3_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR3_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address19_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR19;


    START_ADDR20 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address4_i   <= (others => '0');
                    reg_module_start_address20_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address4_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR4_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address20_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR20;

    START_ADDR21 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address5_i   <= (others => '0');
                    reg_module_start_address21_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address5_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR5_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address21_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR21;



    START_ADDR22 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address6_i   <= (others => '0');
                    reg_module_start_address22_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address6_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR6_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address22_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR22;


    START_ADDR23 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address7_i   <= (others => '0');
                    reg_module_start_address23_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address7_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR7_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address23_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR23;




    START_ADDR24 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address8_i   <= (others => '0');
                    reg_module_start_address24_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address8_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR8_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address24_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR24;



    START_ADDR25 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address9_i   <= (others => '0');
                    reg_module_start_address25_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address9_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR9_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address25_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR25;


    START_ADDR26 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address10_i   <= (others => '0');
                    reg_module_start_address26_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address10_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR10_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address26_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR26;


    START_ADDR27 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address11_i   <= (others => '0');
                    reg_module_start_address27_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address11_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR11_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address27_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR27;


    START_ADDR28 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address12_i   <= (others => '0');
                    reg_module_start_address28_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address12_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR12_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address28_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR28;


    START_ADDR29 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address13_i   <= (others => '0');
                    reg_module_start_address29_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address13_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR13_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address29_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR29;


    START_ADDR30 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address14_i   <= (others => '0');
                    reg_module_start_address30_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address14_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR14_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address30_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR30;


    START_ADDR31 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address15_i   <= (others => '0');
                    reg_module_start_address31_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address15_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR15_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address31_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR31;



    START_ADDR32 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    reg_module_start_address16_i   <= (others => '0');
                    reg_module_start_address32_i   <= (others => '0');
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '0')then
                    reg_module_start_address16_i   <= axi2ip_wrdata;
                elsif(  axi2ip_wrce(STARTADDR16_INDEX) = '1' and  reg_config_locked_i = '0'  and reg_index(0) = '1')then
                    reg_module_start_address32_i   <= axi2ip_wrdata;
                end if;
            end if;
        end process START_ADDR32;






end generate GEN_NUM_FSTORES_32;




-- Number of Fstores Generate
GEN_1   : if C_NUM_FSTORES = 1 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 

end generate GEN_1;


-- Number of Fstores Generate
GEN_2   : if C_NUM_FSTORES = 2 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 

end generate GEN_2;


-- Number of Fstores Generate
GEN_3   : if C_NUM_FSTORES = 3 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 

end generate GEN_3;


-- Number of Fstores Generate
GEN_4   : if C_NUM_FSTORES = 4 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 

end generate GEN_4;

-- Number of Fstores Generate
GEN_5   : if C_NUM_FSTORES = 5 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 

end generate GEN_5;

-- Number of Fstores Generate
GEN_6   : if C_NUM_FSTORES = 6 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 

end generate GEN_6;


-- Number of Fstores Generate
GEN_7   : if C_NUM_FSTORES = 7 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 

end generate GEN_7;


-- Number of Fstores Generate
GEN_8   : if C_NUM_FSTORES = 8 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 

end generate GEN_8;



-- Number of Fstores Generate
GEN_9   : if C_NUM_FSTORES = 9 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 

end generate GEN_9;



-- Number of Fstores Generate
GEN_10   : if C_NUM_FSTORES = 10 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 

end generate GEN_10;

-- Number of Fstores Generate
GEN_11   : if C_NUM_FSTORES = 11 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 

end generate GEN_11;


-- Number of Fstores Generate
GEN_12   : if C_NUM_FSTORES = 12 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 

end generate GEN_12;


-- Number of Fstores Generate
GEN_13   : if C_NUM_FSTORES = 13 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 

end generate GEN_13;


-- Number of Fstores Generate
GEN_14   : if C_NUM_FSTORES = 14 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 

end generate GEN_14;

-- Number of Fstores Generate
GEN_15   : if C_NUM_FSTORES = 15 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 

end generate GEN_15;

-- Number of Fstores Generate
GEN_16   : if C_NUM_FSTORES = 16 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 


end generate GEN_16;


-- Number of Fstores Generate
GEN_17   : if C_NUM_FSTORES = 17 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 

end generate GEN_17;


-- Number of Fstores Generate
GEN_18   : if C_NUM_FSTORES = 18 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 

end generate GEN_18;



-- Number of Fstores Generate
GEN_19   : if C_NUM_FSTORES = 19 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 

end generate GEN_19;

-- Number of Fstores Generate
GEN_20   : if C_NUM_FSTORES = 20 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 

end generate GEN_20;


-- Number of Fstores Generate
GEN_21   : if C_NUM_FSTORES = 21 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 

end generate GEN_21;


-- Number of Fstores Generate
GEN_22   : if C_NUM_FSTORES = 22 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 


end generate GEN_22;


-- Number of Fstores Generate
GEN_23   : if C_NUM_FSTORES = 23 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 

end generate GEN_23;


-- Number of Fstores Generate
GEN_24   : if C_NUM_FSTORES = 24 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 

end generate GEN_24;

-- Number of Fstores Generate
GEN_25   : if C_NUM_FSTORES = 25 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 

end generate GEN_25;

-- Number of Fstores Generate
GEN_26   : if C_NUM_FSTORES = 26 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 

end generate GEN_26;


-- Number of Fstores Generate
GEN_27   : if C_NUM_FSTORES = 27 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 

end generate GEN_27;


-- Number of Fstores Generate
GEN_28   : if C_NUM_FSTORES = 28 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 

end generate GEN_28;



-- Number of Fstores Generate
GEN_29   : if C_NUM_FSTORES = 29 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 
 reg_module_strt_addr(28) 	<=   reg_module_start_address29_i ; 

end generate GEN_29;



-- Number of Fstores Generate
GEN_30   : if C_NUM_FSTORES = 30 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 
 reg_module_strt_addr(28) 	<=   reg_module_start_address29_i ; 
 reg_module_strt_addr(29) 	<=   reg_module_start_address30_i ; 

end generate GEN_30;


-- Number of Fstores Generate
GEN_31   : if C_NUM_FSTORES = 31 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 
 reg_module_strt_addr(28) 	<=   reg_module_start_address29_i ; 
 reg_module_strt_addr(29) 	<=   reg_module_start_address30_i ; 
 reg_module_strt_addr(30) 	<=   reg_module_start_address31_i ; 

end generate GEN_31;


-- Number of Fstores Generate
GEN_32   : if C_NUM_FSTORES = 32 generate

 reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
 reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 
 reg_module_strt_addr(28) 	<=   reg_module_start_address29_i ; 
 reg_module_strt_addr(29) 	<=   reg_module_start_address30_i ; 
 reg_module_strt_addr(30) 	<=   reg_module_start_address31_i ; 
 reg_module_strt_addr(31) 	<=   reg_module_start_address32_i ; 

end generate GEN_32;








--GEN_START_ADDR_MAP : for i in 0 to C_NUM_FSTORES-1 generate
--begin
--
--    reg_module_strt_addr(i) <= reg_module_strt_addr_i(i);
--
--end generate GEN_START_ADDR_MAP;




 --reg_module_strt_addr(0) 	<=   reg_module_start_address1_i  ; 
 --reg_module_strt_addr(1) 	<=   reg_module_start_address2_i  ; 
 --reg_module_strt_addr(2) 	<=   reg_module_start_address3_i  ; 
 --reg_module_strt_addr(3) 	<=   reg_module_start_address4_i  ; 
 --reg_module_strt_addr(4) 	<=   reg_module_start_address5_i  ; 
 --reg_module_strt_addr(5) 	<=   reg_module_start_address6_i  ; 
 --reg_module_strt_addr(6) 	<=   reg_module_start_address7_i  ; 
 --reg_module_strt_addr(7) 	<=   reg_module_start_address8_i  ; 
 --reg_module_strt_addr(8) 	<=   reg_module_start_address9_i  ; 
 --reg_module_strt_addr(9) 	<=   reg_module_start_address10_i ; 
 --reg_module_strt_addr(10) 	<=   reg_module_start_address11_i ; 
 --reg_module_strt_addr(11) 	<=   reg_module_start_address12_i ; 
 --reg_module_strt_addr(12) 	<=   reg_module_start_address13_i ; 
 --reg_module_strt_addr(13) 	<=   reg_module_start_address14_i ; 
 --reg_module_strt_addr(14) 	<=   reg_module_start_address15_i ; 
 --reg_module_strt_addr(15) 	<=   reg_module_start_address16_i ; 
 --reg_module_strt_addr(16) 	<=   reg_module_start_address17_i ; 
 --reg_module_strt_addr(17) 	<=   reg_module_start_address18_i ; 
 --reg_module_strt_addr(18) 	<=   reg_module_start_address19_i ; 
 --reg_module_strt_addr(19) 	<=   reg_module_start_address20_i ; 
 --reg_module_strt_addr(20) 	<=   reg_module_start_address21_i ; 
 --reg_module_strt_addr(21) 	<=   reg_module_start_address22_i ; 
 --reg_module_strt_addr(22) 	<=   reg_module_start_address23_i ; 
 --reg_module_strt_addr(23) 	<=   reg_module_start_address24_i ; 
 --reg_module_strt_addr(24) 	<=   reg_module_start_address25_i ; 
 --reg_module_strt_addr(25) 	<=   reg_module_start_address26_i ; 
 --reg_module_strt_addr(26) 	<=   reg_module_start_address27_i ; 
 --reg_module_strt_addr(27) 	<=   reg_module_start_address28_i ; 
 --reg_module_strt_addr(28) 	<=   reg_module_start_address29_i ; 
 --reg_module_strt_addr(29) 	<=   reg_module_start_address30_i ; 
 --reg_module_strt_addr(30) 	<=   reg_module_start_address31_i ; 
 --reg_module_strt_addr(31) 	<=   reg_module_start_address32_i ; 























---- Map for use in read mux.
reg_module_start_address1  <=    reg_module_start_address1_i  ;
reg_module_start_address2  <=    reg_module_start_address2_i  ;
reg_module_start_address3  <=    reg_module_start_address3_i  ;
reg_module_start_address4  <=    reg_module_start_address4_i  ;
reg_module_start_address5  <=    reg_module_start_address5_i  ;
reg_module_start_address6  <=    reg_module_start_address6_i  ;
reg_module_start_address7  <=    reg_module_start_address7_i  ;
reg_module_start_address8  <=    reg_module_start_address8_i  ;
reg_module_start_address9  <=    reg_module_start_address9_i  ;
reg_module_start_address10 <=    reg_module_start_address10_i ;
reg_module_start_address11 <=    reg_module_start_address11_i ;
reg_module_start_address12 <=    reg_module_start_address12_i ;
reg_module_start_address13 <=    reg_module_start_address13_i ;
reg_module_start_address14 <=    reg_module_start_address14_i ;
reg_module_start_address15 <=    reg_module_start_address15_i ;
reg_module_start_address16 <=    reg_module_start_address16_i ;
reg_module_start_address17 <=    reg_module_start_address17_i ;
reg_module_start_address18 <=    reg_module_start_address18_i ;
reg_module_start_address19 <=    reg_module_start_address19_i ;
reg_module_start_address20 <=    reg_module_start_address20_i ;
reg_module_start_address21 <=    reg_module_start_address21_i ;
reg_module_start_address22 <=    reg_module_start_address22_i ;
reg_module_start_address23 <=    reg_module_start_address23_i ;
reg_module_start_address24 <=    reg_module_start_address24_i ;
reg_module_start_address25 <=    reg_module_start_address25_i ;
reg_module_start_address26 <=    reg_module_start_address26_i ;
reg_module_start_address27 <=    reg_module_start_address27_i ;
reg_module_start_address28 <=    reg_module_start_address28_i ;
reg_module_start_address29 <=    reg_module_start_address29_i ;
reg_module_start_address30 <=    reg_module_start_address30_i ;
reg_module_start_address31 <=    reg_module_start_address31_i ;
reg_module_start_address32 <=    reg_module_start_address32_i ;


--------*****************************************************************************
--------** START ADDRESS REGISTERS
--------*****************************************************************************
------
-------- Generate C_NUM_FSTORE start address registeres
------GEN_START_ADDR_REG : for i in 0 to MAX_FSTORES-1 generate
------begin
------
------        -- Start Address Registers
------        START_ADDR : process(prmry_aclk)
------            begin
------                if(prmry_aclk'EVENT and prmry_aclk = '1')then
------                    if(prmry_resetn = '0')then
------                        reg_module_strt_addr_i(i)   <= (others => '0');
------                    -- Write to appropriate Start Address
------                    -- Index based on [(i+1)*2]+2.  This gives an index increment
------                    -- starting at 4 then going 6,8,10,12, etc. skipping each
------                    -- reserved space between 32-bit start addresses.  For
------                    -- 64bit addressing this index calculation will need to be
------                    -- modified.
------                    elsif(i<C_NUM_FSTORES and axi2ip_wrce(((i+1)*2)+2) = '1')then
------                        reg_module_strt_addr_i(i)   <= axi2ip_wrdata;
------
------                    -- For frames greater than fstores the vectors are reserved
------                    -- and set to zero
------                    elsif(i>= C_NUM_FSTORES)then
------                        reg_module_strt_addr_i(i) <= (others => '0');
------
------                    end if;
------                end if;
------            end process START_ADDR;
------end generate GEN_START_ADDR_REG;
------
-------- Map only C_NUM_FSTORE vectors to output port
------GEN_START_ADDR_MAP : for i in 0 to C_NUM_FSTORES-1 generate
------begin
------
------    reg_module_strt_addr(i) <= reg_module_strt_addr_i(i);
------
------end generate GEN_START_ADDR_MAP;
------
------
-------- Map for use in read mux.
------reg_module_start_address1_i  <= reg_module_strt_addr_i(0);
------reg_module_start_address2_i  <= reg_module_strt_addr_i(1);
------reg_module_start_address3_i  <= reg_module_strt_addr_i(2);
------reg_module_start_address4_i  <= reg_module_strt_addr_i(3);
------reg_module_start_address5_i  <= reg_module_strt_addr_i(4);
------reg_module_start_address6_i  <= reg_module_strt_addr_i(5);
------reg_module_start_address7_i  <= reg_module_strt_addr_i(6);
------reg_module_start_address8_i  <= reg_module_strt_addr_i(7);
------reg_module_start_address9_i  <= reg_module_strt_addr_i(8);
------reg_module_start_address10_i <= reg_module_strt_addr_i(9);
------reg_module_start_address11_i <= reg_module_strt_addr_i(10);
------reg_module_start_address12_i <= reg_module_strt_addr_i(11);
------reg_module_start_address13_i <= reg_module_strt_addr_i(12);
------reg_module_start_address14_i <= reg_module_strt_addr_i(13);
------reg_module_start_address15_i <= reg_module_strt_addr_i(14);
------reg_module_start_address16_i <= reg_module_strt_addr_i(15);
------reg_module_start_address17_i <= reg_module_strt_addr_i(16);
------reg_module_start_address18_i <= reg_module_strt_addr_i(17);
------reg_module_start_address19_i <= reg_module_strt_addr_i(18);
------reg_module_start_address20_i <= reg_module_strt_addr_i(19);
------reg_module_start_address21_i <= reg_module_strt_addr_i(20);
------reg_module_start_address22_i <= reg_module_strt_addr_i(21);
------reg_module_start_address23_i <= reg_module_strt_addr_i(22);
------reg_module_start_address24_i <= reg_module_strt_addr_i(23);
------reg_module_start_address25_i <= reg_module_strt_addr_i(24);
------reg_module_start_address26_i <= reg_module_strt_addr_i(25);
------reg_module_start_address27_i <= reg_module_strt_addr_i(26);
------reg_module_start_address28_i <= reg_module_strt_addr_i(27);
------reg_module_start_address29_i <= reg_module_strt_addr_i(28);
------reg_module_start_address30_i <= reg_module_strt_addr_i(29);
------reg_module_start_address31_i <= reg_module_strt_addr_i(30);
------reg_module_start_address32_i <= reg_module_strt_addr_i(31);




end implementation;


