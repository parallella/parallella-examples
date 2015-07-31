-------------------------------------------------------------------------------
-- axi_vdma_sgregister.vhd
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
-- Filename:        axi_vdma_sgregister.vhd
--
-- Description:     This entity encompasses the sg video register block and is
--                  were video parameters are intiallly written on descriptor
--                  fetch.
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
--use proc_common_v4_0.family_support.all;
library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

-------------------------------------------------------------------------------
entity  axi_vdma_sgregister is
    generic(
        C_NUM_FSTORES             : integer range 1 to 32       := 1        ;
            -- Number of Frame Stores

        C_ADDR_WIDTH              : integer range 32 to 32      := 32       ;
            -- Start Address Width
        C_FAMILY                  : string := "virtex7"
    );
    port (
        prmry_aclk                  : in  std_logic                         ;           --
        prmry_resetn                : in  std_logic                         ;           --
                                                                                        --
        -- Update Control                                                               --
        video_parameter_updt        : in  std_logic                         ;           --
        video_parameter_valid       : in  std_logic                         ;           --
        video_reg_update            : in  std_logic                         ;           --
        dmasr_halt                  : in  std_logic                         ;           --
        strt_addr_clr               : in  std_logic                         ;           --
        desc_data_wren              : in  std_logic                         ;           --
        frame_number                : in  std_logic_vector                              --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;           --
        ftch_complete               : in  std_logic                         ;           --
        ftch_complete_clr           : in  std_logic                         ;           --
        update_complete             : out std_logic                         ;           --
        num_fstore_minus1           : in  std_logic_vector                              --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;           --
                                                                                        --
        -- Video Start Address / Parameters In from Scatter Gather Engine               --
        desc_vsize                  : in  std_logic_vector                              --
                                        (VSIZE_DWIDTH-1 downto 0)           ;           --
        desc_hsize                  : in  std_logic_vector                              --
                                        (HSIZE_DWIDTH-1 downto 0)           ;           --
        desc_stride                 : in  std_logic_vector                              --
                                        (STRIDE_DWIDTH-1 downto 0)          ;           --
        desc_frmdly                 : in  std_logic_vector                              --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;           --
        desc_strtaddress            : in  std_logic_vector                              --
                                        (C_ADDR_WIDTH-1 downto 0)           ;           --
                                                                                        --
        -- Video Start Address / Parameters Out to DMA Controller                       --
        crnt_vsize                  : out std_logic_vector                              --
                                        (VSIZE_DWIDTH-1 downto 0)           ;           --
        crnt_hsize                  : out std_logic_vector                              --
                                        (HSIZE_DWIDTH-1 downto 0)           ;           --
        crnt_stride                 : out std_logic_vector                              --
                                        (STRIDE_DWIDTH-1 downto 0)          ;           --
        crnt_frmdly                 : out std_logic_vector                              --
                                        (FRMDLY_DWIDTH-1 downto 0)          ;           --
        crnt_start_address          : out std_logic_vector                              --
                                        (C_ADDR_WIDTH - 1 downto 0)                     --
    );
end axi_vdma_sgregister;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_sgregister is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
constant STRT_ADDR_CNT_WIDTH    : integer := max2(1,clog2(C_NUM_FSTORES));
-- CR607089
--constant STRT_ADDR_TC           : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0)
--                                    := std_logic_vector(to_unsigned(C_NUM_FSTORES-1,STRT_ADDR_CNT_WIDTH));

--constant USE_LUTRAM             : boolean := supported(C_FAMILY,u_RAM16X1S);
constant USE_LUTRAM             : boolean := FALSE;
constant USE_BRAM               : boolean := USE_LUTRAM=FALSE;

constant ADDRESS_1              : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0)
                                    := (others => '0');
constant ADDRESS_2              : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0)
                                    := std_logic_vector(to_unsigned(1,STRT_ADDR_CNT_WIDTH));
constant ADDRESS_3              : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0)
                                    := std_logic_vector(to_unsigned(2,STRT_ADDR_CNT_WIDTH));


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal strt_addr_count      : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');
--signal s_h_wren             : std_logic := '0';
--signal ram_address_incr     : std_logic := '0';


signal vsize_sg             : std_logic_vector(VSIZE_DWIDTH-1 downto 0)  := (others => '0');
signal hsize_sg             : std_logic_vector(HSIZE_DWIDTH-1 downto 0)  := (others => '0');
signal stride_sg            : std_logic_vector(STRIDE_DWIDTH-1 downto 0) := (others => '0');
signal frmdly_sg            : std_logic_vector(FRMDLY_DWIDTH-1 downto 0) := (others => '0');
signal start_address_sg     : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address_out    : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');

signal start_address1_sg    : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address2_sg    : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address3_sg    : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');

signal start_address_addr1  : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address_addr2  : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address_addr3  : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');


signal update_complete_i    : std_logic := '0';
signal ping_pong            : std_logic := '0';
signal start_address_pong   : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
signal start_address_ping   : std_logic_vector(C_ADDR_WIDTH - 1 downto 0):= (others => '0');
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin



-------------------------------------------------------------------------------
-- VIDEO TRANSFER PARAMETERS - FROM SG ENGINE
-------------------------------------------------------------------------------
-- Vertical Size - Video Side
REG_VSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                vsize_sg <= (others => '0');
            -- update video register
            elsif(desc_data_wren='1' and video_parameter_updt = '1') then
                vsize_sg <= desc_vsize;
            end if;
        end if;
    end process REG_VSIZE;

-- Horizontal Size - Video Side
REG_HSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                hsize_sg <= (others => '0');
            -- update video register
            elsif(desc_data_wren='1' and video_parameter_updt = '1') then
                hsize_sg <= desc_hsize;
            end if;
        end if;
    end process REG_HSIZE;

-- Stride - Video Side
REG_STRIDE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                stride_sg <= (others => '0');
            -- update video register
            elsif(desc_data_wren='1' and video_parameter_updt = '1') then
                stride_sg <= desc_stride;
            end if;
        end if;
    end process REG_STRIDE;

-- Frame Delay - Video Side
REG_FRMDLY : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                frmdly_sg <= (others => '0');
            -- update video register
            elsif(desc_data_wren='1' and video_parameter_updt = '1') then
                frmdly_sg <= desc_frmdly;
            end if;
        end if;
    end process REG_FRMDLY;



-------------------------------------------------------------------------------
-- VIDEO START ADDRESSES - FROM SG ENGINE
-------------------------------------------------------------------------------
-- If more than one FSTORE then need counter to address
-- start_address_registers
GEN_STRTADDR_CNTR : if C_NUM_FSTORES /= 1 generate
begin
    REG_DESC_CNTR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                -- on reset or clear then reset start address count
                if(prmry_resetn = '0' or strt_addr_clr = '1')then
                    strt_addr_count <= (others => '0');
                -- on desc write and address count reached terminal count then reset
                -- CR607089 - need to account for frame store setting
                --elsif(desc_data_wren = '1' and strt_addr_count = STRT_ADDR_TC)then
                --elsif(desc_data_wren = '1' and strt_addr_count = num_fstore_minus1)then
                -- CR607433 - need to do comparison on only STRT_ADDR_CNT_WIDTH.
                elsif(desc_data_wren = '1' and strt_addr_count = num_fstore_minus1(STRT_ADDR_CNT_WIDTH-1 downto 0))then
                    strt_addr_count <= (others => '0');
                -- otherwise on each desc write increment the count
                elsif(desc_data_wren = '1')then
                    strt_addr_count <= std_logic_vector(unsigned(strt_addr_count) + 1);
                end if;
            end if;
        end process REG_DESC_CNTR;

end generate GEN_STRTADDR_CNTR;


-- No counter need for FSTORE = 1
GEN_NO_STRTADDR_CNTR : if C_NUM_FSTORES = 1 generate
begin
    strt_addr_count <= (others => '0');

end generate GEN_NO_STRTADDR_CNTR;


-------------------------------------------------------------------------------
-- N0 LUT RAM
-- Do not use a LUT RAM is less than 4 frame stores are required.
-------------------------------------------------------------------------------
GEN_NO_RAM : if C_NUM_FSTORES < 4 generate

    -- For 1 Frame Store
    GEN_FSTORE1 : if C_NUM_FSTORES = 1 generate
    begin
        -----------------------------------------------------------------------
        --  Holding registers for start address fetched via Scatter/Gather
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address1_sg <= (others => '0');
                    elsif(desc_data_wren='1') then
                        start_address1_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR1_SG;

        -----------------------------------------------------------------------
        --  Sample and Hold for DMA Controller
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_sg <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_sg <= start_address1_sg;
                    end if;
                end if;
            end process REG_START_ADDR1;

    end generate GEN_FSTORE1;

    -- For 2 Frame Stores
    GEN_FSTORE2 : if C_NUM_FSTORES = 2 generate
    begin
        -----------------------------------------------------------------------
        --  Holding registers for start address fetched via Scatter/Gather
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address1_sg <= (others => '0');
                    elsif(desc_data_wren='1' and strt_addr_count = ADDRESS_1) then
                        start_address1_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR1_SG;

        -- Start Address Register 2 on SG Side
        REG_START_ADDR2_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address2_sg <= (others => '0');
                    elsif(desc_data_wren='1' and strt_addr_count = ADDRESS_2) then
                        start_address2_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR2_SG;

        -----------------------------------------------------------------------
        --  Sample and Hold for DMA Controller
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_addr1 <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_addr1 <= start_address1_sg;
                    end if;
                end if;
            end process REG_START_ADDR1;

        -- Start Address Register 2 on SG Side
        REG_START_ADDR2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_addr2 <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_addr2 <= start_address2_sg;
                    end if;
                end if;
            end process REG_START_ADDR2;

        START_ADDRESS_MUX : process(frame_number,
                                    start_address_addr1,
                                    start_address_addr2)
            begin
                case frame_number is
                    when "00000" =>
                        start_address_sg <= start_address_addr1;
                    when others =>
                        start_address_sg <= start_address_addr2;
                end case;
            end process START_ADDRESS_MUX;

    end generate GEN_FSTORE2;

    -- For 3 Frame Stores
    GEN_FSTORE3 : if C_NUM_FSTORES = 3 generate
    begin
        -----------------------------------------------------------------------
        --  Holding registers for start address fetched via Scatter/Gather
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address1_sg <= (others => '0');
                    elsif(desc_data_wren='1' and strt_addr_count = ADDRESS_1) then
                        start_address1_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR1_SG;

        -- Start Address Register 2 on SG Side
        REG_START_ADDR2_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address2_sg <= (others => '0');
                    elsif(desc_data_wren='1' and strt_addr_count = ADDRESS_2) then
                        start_address2_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR2_SG;

        -- Start Address Register 3 on SG Side
        REG_START_ADDR3_SG : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address3_sg <= (others => '0');
                    elsif(desc_data_wren = '1' and strt_addr_count = ADDRESS_3) then
                        start_address3_sg <= desc_strtaddress;
                    end if;
                end if;
            end process REG_START_ADDR3_SG;

        -----------------------------------------------------------------------
        --  Sample and Hold for DMA Controller
        -----------------------------------------------------------------------
        -- Start Address Register 1 on SG Side
        REG_START_ADDR1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_addr1 <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_addr1 <= start_address1_sg;
                    end if;
                end if;
            end process REG_START_ADDR1;

        -- Start Address Register 2 on SG Side
        REG_START_ADDR2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_addr2 <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_addr2 <= start_address2_sg;
                    end if;
                end if;
            end process REG_START_ADDR2;

        -- Start Address Register 3 on SG Side
        REG_START_ADDR3 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        start_address_addr3 <= (others => '0');
                    elsif(video_reg_update='1') then
                        start_address_addr3 <= start_address3_sg;
                    end if;
                end if;
            end process REG_START_ADDR3;

        START_ADDRESS_MUX : process(frame_number,
                                    start_address_addr1,
                                    start_address_addr2,
                                    start_address_addr3)
            begin
                case frame_number is
                    when "00000" =>
                        start_address_sg <= start_address_addr1;
                    when "00001" =>
                        start_address_sg <= start_address_addr2;
                    when others =>
                        start_address_sg <= start_address_addr3;
                end case;
            end process START_ADDRESS_MUX;

    end generate GEN_FSTORE3;

    update_complete     <= ftch_complete;
    start_address_out   <= start_address_sg;


end generate GEN_NO_RAM;


-------------------------------------------------------------------------------
-- LUT RAM
-- Use a lut RAM if the selected device supports LUT RAM's and the Address
-- width is within the bounds of a LUT RAM and if frame stores is greater
-- than 3.  There is no resource savings for less frame stores.
-------------------------------------------------------------------------------
GEN_LUTRAM : if USE_LUTRAM and STRT_ADDR_CNT_WIDTH <= 4 and C_NUM_FSTORES > 3 generate
constant ZERO_ADDR  : std_logic_vector(3 downto 0) := (others => '0');

signal addr                 : std_logic_vector(3 downto 0) := (others => '0');
signal copy_addr            : std_logic_vector(3 downto 0) := (others => '0');
signal copy_wren            : std_logic := '0';
--signal copyram_addr         : std_logic_vector(3 downto 0) := (others => '0');

signal copy_wren_ping       : std_logic := '0';
signal copy_wren_pong       : std_logic := '0';

signal copyram_addr_ping    : std_logic_vector(3 downto 0) := (others => '0');
signal copyram_addr_pong    : std_logic_vector(3 downto 0) := (others => '0');


begin

    -- Need to pad address up to 4 bits wide
    GEN_ADDR_WIDTH_LESS_4 : if STRT_ADDR_CNT_WIDTH < 4 generate
    constant ADDR_PAD_WIDTH : integer := 4 - STRT_ADDR_CNT_WIDTH;
    constant ADDRESS_PAD    : std_logic_vector
                                (ADDR_PAD_WIDTH-1 downto 0)
                                :=(others => '0');
    begin
        addr <= (ADDRESS_PAD & strt_addr_count) when copy_wren = '0'
           else copy_addr;

    end generate GEN_ADDR_WIDTH_LESS_4;

    -- Do not need to pad address, already at 4 bits
    GEN_ADDR_WIDTH_EQL_4 : if STRT_ADDR_CNT_WIDTH = 4 generate
    begin
        addr <= strt_addr_count when copy_wren = '0'
           else copy_addr;

    end generate GEN_ADDR_WIDTH_EQL_4;

    -- Instantiate LUTRAM
    GEN_BUFFER1 : for i in C_ADDR_WIDTH - 1 downto 0 generate
        LUT_RAM : RAM16X1S
            generic map
            (
                INIT    => X"0000"
            )
            port map
            (
                WE      => desc_data_wren           ,
                D       => desc_strtaddress(i)      ,
                WCLK    => prmry_aclk            ,
                A0      => addr(0)                  ,
                A1      => addr(1)                  ,
                A2      => addr(2)                  ,
                A3      => addr(3)                  ,
                O       => start_address_sg(i)
            );
    end generate GEN_BUFFER1;

    -- On completion of descriptor fetch, enable copying of
    -- sg LUTRAM (buffer1) to output LUTRAM (ping or pong)
    -- This copy of entire RAM is required because users may only
    -- update 1 start address or all addresses and a full copy is
    -- the simplest approach
    COPY_COUNTER : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or ftch_complete_clr = '1' or dmasr_halt = '1')then
                    copy_addr           <= (others => '1');
                    copy_wren           <= '0';
                    update_complete_i   <= '0';
                -- done with copy, hold wren able clear asserts
                elsif(copy_addr = ZERO_ADDR)then
                    copy_wren           <= '0';
                    copy_addr           <= (others => '0');
                    update_complete_i   <= '1';

                -- decrement address on copy
                elsif(copy_wren = '1')then
                    copy_addr           <= std_logic_vector(unsigned(copy_addr) - 1);
                    copy_wren           <= '1';
                    update_complete_i   <= '0';

                -- all desc data fetched therefore start copy
                elsif(ftch_complete = '1')then
                    copy_addr           <= (others => '1');
                    copy_wren           <= '1';
                    update_complete_i   <= '0';

                end if;
            end if;
        end process COPY_COUNTER;
    -- Pass out for setting flags
    update_complete <= update_complete_i;


    copy_wren_ping    <= copy_wren when (ping_pong = '1' and video_parameter_valid = '1')
                                     or (update_complete_i = '0' and video_parameter_valid = '0')
                    else '0';

    copyram_addr_ping <= copy_addr when ping_pong = '1'
                                     or (video_parameter_valid = '0' and update_complete_i = '0')
                    else frame_number(3 downto 0);

    copy_wren_pong    <= copy_wren when (ping_pong = '0' and video_parameter_valid = '1')
                                     or (update_complete_i = '0' and video_parameter_valid = '0')
                   else '0';

    copyram_addr_pong <= copy_addr when ping_pong = '0'
                                     or (video_parameter_valid = '0' and update_complete_i = '0')
                    else frame_number(3 downto 0);

    -- Ping Pong control for selecting which LUTRAM the DMA controller
    -- will fetch from and which one Scatter Gather will update.
    PING_PONG_PROCESS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1' or video_parameter_valid = '0')then
                    ping_pong <= '0';
                elsif(update_complete_i = '1' and video_reg_update = '1')then
                    ping_pong <= not ping_pong;
                end if;
            end if;
        end process PING_PONG_PROCESS;

    -- Instantiate PING LUTRAM
    GEN_BUFFER_PING : for i in C_ADDR_WIDTH - 1 downto 0 generate
        LUT_RAM : RAM16X1S
            generic map
            (
                INIT    => X"0000"
            )
            port map
            (
                WE      => copy_wren_ping                ,
                D       => start_address_sg(i)      ,
                WCLK    => prmry_aclk            ,
                A0      => copyram_addr_ping(0)          ,
                A1      => copyram_addr_ping(1)          ,
                A2      => copyram_addr_ping(2)          ,
                A3      => copyram_addr_ping(3)          ,
                O       => start_address_ping(i)
            );
    end generate GEN_BUFFER_PING;


    -- Instantiate PONG LUTRAM
    GEN_BUFFER_PONG : for i in C_ADDR_WIDTH - 1 downto 0 generate
        LUT_RAM : RAM16X1S
            generic map
            (
                INIT    => X"0000"
            )
            port map
            (
                WE      => copy_wren_pong                ,
                D       => start_address_sg(i)      ,
                WCLK    => prmry_aclk            ,
                A0      => copyram_addr_pong(0)          ,
                A1      => copyram_addr_pong(1)          ,
                A2      => copyram_addr_pong(2)          ,
                A3      => copyram_addr_pong(3)          ,
                O       => start_address_pong(i)
            );
    end generate GEN_BUFFER_PONG;

    -- Feed start address from LUTRAM opposite from what is being
    -- written to by scatter gather fetch and update.
    start_address_out <= start_address_ping when ping_pong = '0'
                    else start_address_pong;


end generate GEN_LUTRAM;

-------------------------------------------------------------------------------
-- BRAM
-- Use a BRAM if LUT RAMS are NOT supported or the Address width is out
-- of the bounds of a LUT RAM.
-------------------------------------------------------------------------------
GEN_BRAM    : if (USE_BRAM or STRT_ADDR_CNT_WIDTH > 4) and C_NUM_FSTORES > 3 generate
constant READ_ENABLED   : std_logic := '1';
constant ZERO_ADDR      : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');

--signal read_addr        : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');
signal copy_addr        : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '1');
signal copy_wren        : std_logic := '0';
--signal copyram_addr     : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');

signal copy_wren_ping       : std_logic := '0';
signal copy_wren_pong       : std_logic := '0';

signal copyram_addr_ping    : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');
signal copyram_addr_pong    : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');


signal copy_wren_ping_p       : std_logic := '0';
signal copy_wren_pong_p       : std_logic := '0';

signal copyram_addr_ping_p    : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');
signal copyram_addr_pong_p    : std_logic_vector(STRT_ADDR_CNT_WIDTH-1 downto 0) := (others => '0');

begin

    GEN_BUFFER1 : entity axi_vdma_v6_2.axi_vdma_blkmem
        generic map(
            C_DATA_WIDTH        => C_ADDR_WIDTH         ,
            C_ADDR_WIDTH        => STRT_ADDR_CNT_WIDTH  ,
            C_FAMILY            => C_FAMILY
        )
        port map(
            Clk         => prmry_aclk        ,
            Rst         => prmry_resetn        ,

            -- Write Port signals
            Wr_Enable   =>  desc_data_wren      ,
            Wr_Req      =>  desc_data_wren      ,
            Wr_Address  =>  strt_addr_count     ,
            Wr_Data     =>  desc_strtaddress    ,

            -- Read Port Signals
            Rd_Enable   =>  READ_ENABLED        ,
            Rd_Address  =>  copy_addr           ,
            Rd_Data     =>  start_address_sg
        );

    -- On completion of descriptor fetch, enable copying of
    -- sg LUTRAM (buffer1) to output LUTRAM (ping or pong)
    -- This copy of entire RAM is required because users may only
    -- update 1 start address or all addresses and a full copy is
    -- the simplest approach
    COPY_COUNTER : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or ftch_complete_clr = '1' or dmasr_halt = '1')then
                    copy_addr       <= (others => '1');
                    copy_wren       <= '0';
                    update_complete_i <= '0';
                -- done with copy, hold wren able clear asserts
                elsif(copy_addr = ZERO_ADDR)then
                    copy_wren       <= '0';
                    copy_addr       <= (others => '0');
                    update_complete_i <= '1';

                -- decrement address on copy
                elsif(copy_wren = '1')then
                    copy_addr <= std_logic_vector(unsigned(copy_addr) - 1);
                    copy_wren <= '1';
                    update_complete_i <= '0';

                -- all desc data fetched therefore start copy
                elsif(ftch_complete = '1')then
                    copy_addr <= (others => '1');
                    copy_wren <= '1';
                    update_complete_i <= '0';

                end if;
            end if;
        end process COPY_COUNTER;
    -- Pass out for setting flags
    update_complete <= update_complete_i;


    copy_wren_ping_p    <= copy_wren when (ping_pong = '1' and video_parameter_valid = '1')
                                     or (update_complete_i = '0' and video_parameter_valid = '0')
                    else '0';

    copyram_addr_ping_p <= copy_addr when ping_pong = '1'
                                     or (video_parameter_valid = '0' and update_complete_i = '0')
                    else frame_number;

    copy_wren_pong_p    <= copy_wren when (ping_pong = '0' and video_parameter_valid = '1')
                                     or (update_complete_i = '0' and video_parameter_valid = '0')
                   else '0';

    copyram_addr_pong_p <= copy_addr when ping_pong = '0'
                                     or (video_parameter_valid = '0' and update_complete_i = '0')
                    else frame_number;

   -- Delaying Ping Pong Write and Address signals for BRAM


    DELAY_PING_PONG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    copy_wren_ping <= '0';
                    copy_wren_pong <= '0';
		    copyram_addr_ping <= (others => '0');
		    copyram_addr_pong <= (others => '0');
                else
                    copy_wren_ping <= copy_wren_ping_p;
                    copy_wren_pong <= copy_wren_pong_p;
		    copyram_addr_ping <= copyram_addr_ping_p;
		    copyram_addr_pong <= copyram_addr_pong_p;
                end if;
            end if;
        end process DELAY_PING_PONG;

    -- Ping Pong control for selecting which LUTRAM the DMA controller
    -- will fetch from and which one Scatter Gather will update.
    PING_PONG_PROCESS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1' or video_parameter_valid = '0')then
                    ping_pong <= '0';
                elsif(update_complete_i = '1' and video_reg_update = '1')then
                    ping_pong <= not ping_pong;
                end if;
            end if;
        end process PING_PONG_PROCESS;

    GEN_BUFFER_PING : entity axi_vdma_v6_2.axi_vdma_blkmem
        generic map(
            C_DATA_WIDTH        => C_ADDR_WIDTH         ,
            C_ADDR_WIDTH        => STRT_ADDR_CNT_WIDTH  ,
            C_FAMILY            => C_FAMILY
        )
        port map(
            Clk         => prmry_aclk        ,
            Rst         => prmry_resetn        ,

            -- Write Port signals
            Wr_Enable   =>  copy_wren_ping           ,
            Wr_Req      =>  copy_wren_ping           ,
            Wr_Address  =>  copyram_addr_ping           ,
            Wr_Data     =>  start_address_sg    ,

            -- Read Port Signals
            Rd_Enable   =>  READ_ENABLED        ,
            Rd_Address  =>  frame_number(STRT_ADDR_CNT_WIDTH-1 downto 0), -- CR625681
            Rd_Data     =>  start_address_ping
        );

    GEN_BUFFER_PONG : entity axi_vdma_v6_2.axi_vdma_blkmem
        generic map(
            C_DATA_WIDTH        => C_ADDR_WIDTH         ,
            C_ADDR_WIDTH        => STRT_ADDR_CNT_WIDTH  ,
            C_FAMILY            => C_FAMILY
        )
        port map(
            Clk         => prmry_aclk        ,
            Rst         => prmry_resetn        ,

            -- Write Port signals
            Wr_Enable   =>  copy_wren_pong           ,
            Wr_Req      =>  copy_wren_pong           ,
            Wr_Address  =>  copyram_addr_pong           ,
            Wr_Data     =>  start_address_sg    ,

            -- Read Port Signals
            Rd_Enable   =>  READ_ENABLED        ,
            Rd_Address  =>  frame_number(STRT_ADDR_CNT_WIDTH-1 downto 0), -- CR625681
            Rd_Data     =>  start_address_pong
        );

    -- Feed start address from LUTRAM opposite from what is being
    -- written to by scatter gather fetch and update.
    start_address_out <= start_address_ping when ping_pong = '0'
                    else start_address_pong;


end generate GEN_BRAM;


-------------------------------------------------------------------------------
-- VIDEO DOUBLE REGISTER BLOCK FOR DMA CONTROLLER
-------------------------------------------------------------------------------
-- Vertical Size - Video Side
REG_VSIZE_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                crnt_vsize <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                crnt_vsize <= vsize_sg;
            end if;
        end if;
    end process REG_VSIZE_OUT;

-- Horizontal Size - Video Side
REG_HSIZE_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                crnt_hsize <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                crnt_hsize <= hsize_sg;
            end if;
        end if;
    end process REG_HSIZE_OUT;

-- Stride - Video Side
REG_STRIDE_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                crnt_stride <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                crnt_stride <= stride_sg;
            end if;
        end if;
    end process REG_STRIDE_OUT;

-- Frame Delay - Video Side
REG_FRMDLY_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                crnt_frmdly <= (others => '0');
            -- update video register
            elsif(video_reg_update='1') then
                crnt_frmdly <= frmdly_sg;
            end if;
        end if;
    end process REG_FRMDLY_OUT;

-- Pipe line for fmax (dble to allow for adjustments later if need be)
REG_ADDR_OUT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                crnt_start_address   <= (others => '0');
            else
                crnt_start_address   <= start_address_out;
            end if;
        end if;
    end process REG_ADDR_OUT;

end implementation;
