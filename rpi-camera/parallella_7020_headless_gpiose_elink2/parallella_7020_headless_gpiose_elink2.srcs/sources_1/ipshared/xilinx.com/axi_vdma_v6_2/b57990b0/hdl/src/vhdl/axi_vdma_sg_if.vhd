-------------------------------------------------------------------------------
-- axi_vdma_sg_if
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
-- Filename:          axi_vdma_sg_if.vhd
-- Description: This entity is the Scatter Gather Interface for Descriptor
--              Fetches.
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
entity  axi_vdma_sg_if is
    generic (

        -----------------------------------------------------------------------
        -- Scatter Gather Parameters
        -----------------------------------------------------------------------

        C_M_AXIS_SG_TDATA_WIDTH         : integer range 32 to 32        := 32   ;
            -- AXI Master Stream in for descriptor fetch

        C_M_AXI_SG_ADDR_WIDTH           : integer range 32 to 64        := 32   ;
            -- Master AXI Memory Map Data Width for Scatter Gather R/W Port

        C_M_AXI_ADDR_WIDTH              : integer range 32 to 64        := 32
            -- Master AXI Memory Map Address Width
    );
    port (

        prmry_aclk              : in  std_logic                             ;       --
        prmry_resetn            : in  std_logic                             ;       --
                                                                                    --
        dmasr_halt              : in  std_logic                             ;       --
        ftch_idle               : in  std_logic                             ;       --
        ftch_complete_clr       : in  std_logic                             ;       --
        ftch_complete           : out std_logic                             ;       --
                                                                                    --
        -- SG Descriptor Fetch AXI Stream In                                        --
        m_axis_ftch_tdata       : in  std_logic_vector                              --
                                    (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0)    ;       --
        m_axis_ftch_tvalid      : in  std_logic                             ;       --
        m_axis_ftch_tready      : out std_logic                             ;       --
        m_axis_ftch_tlast       : in  std_logic                             ;       --
                                                                                    --
        -- Descriptor Field Output                                                  --
        new_curdesc             : out std_logic_vector                              --
                                    (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)      ;       --
        new_curdesc_wren        : out std_logic                             ;       --
                                                                                    --
                                                                                    --
        desc_data_wren          : out std_logic                             ;       --
                                                                                    --
        desc_strtaddress        : out std_logic_vector                              --
                                    (C_M_AXI_ADDR_WIDTH-1 downto 0)         ;       --
        desc_vsize              : out std_logic_vector                              --
                                    (VSIZE_DWIDTH-1 downto 0)               ;       --
        desc_hsize              : out std_logic_vector                              --
                                    (HSIZE_DWIDTH-1 downto 0)               ;       --
        desc_stride             : out std_logic_vector                              --
                                    (STRIDE_DWIDTH-1 downto 0)              ;       --
        desc_frmdly             : out std_logic_vector                              --
                                    (FRMDLY_DWIDTH-1 downto 0)                      --
    );

end axi_vdma_sg_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_sg_if is
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
signal ftch_shftenbl            : std_logic := '0';
signal ftch_tready              : std_logic := '0';
signal desc_fetch_done_i        : std_logic := '0';

signal desc_reg6                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg5                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg4                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg3                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg2                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg1                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_reg0                : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');

signal desc_curdesc_lsb         : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_curdesc_msb         : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_strtaddr_lsb        : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');
signal desc_strtaddr_msb        : std_logic_vector(C_M_AXIS_SG_TDATA_WIDTH - 1 downto 0) := (others => '0');

signal desc_data_wren_i         : std_logic := '0';

signal ftch_idle_d1             : std_logic := '0';
signal ftch_idle_re             : std_logic := '0';
signal ftch_complete_i          : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Generate rising edge of ftch idle
REG_FETCH_IDLE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                ftch_idle_d1 <= '1';
            else
                ftch_idle_d1 <= ftch_idle;
            end if;
        end if;
    end process REG_FETCH_IDLE;

ftch_idle_re <= ftch_idle and not ftch_idle_d1;


DESC_FTCH_CMPLT : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                ftch_complete_i <= '0';

            -- SG Engine not going idle and commanded to clear flag
            elsif(ftch_idle_re = '0' and ftch_complete_clr = '1')then
                ftch_complete_i <= '0';

            -- On SG Engine going idle flag descriptor fetches as complete
            elsif(ftch_idle_re = '1')then
                ftch_complete_i <= '1';
            end if;
        end if;
    end process DESC_FTCH_CMPLT;

ftch_complete <= ftch_complete_i;

-- Drive fetch request done on tlast
desc_fetch_done_i       <= m_axis_ftch_tlast
                          and m_axis_ftch_tvalid
                          and ftch_tready;

-- Shift in data from SG engine if tvalid and fetch request
ftch_shftenbl           <= m_axis_ftch_tvalid
                          and ftch_tready
                          and not desc_data_wren_i;

-- Passed curdes write out to register module
new_curdesc_wren        <= desc_data_wren_i;

-- Drive ready if NOT writing video xfer paramters
-- and if not already fetched set of video paramerters/start addresses
ftch_tready             <= not desc_data_wren_i and not ftch_complete_i;

-- Drive ready out to SG Engine
m_axis_ftch_tready      <= ftch_tready;

-------------------------------------------------------------------------------
-- Large shift register to bring in descriptor fields
-------------------------------------------------------------------------------
DESC_WRD_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                desc_reg6     <= (others => '0');
                desc_reg5     <= (others => '0');
                desc_reg4     <= (others => '0');
                desc_reg3     <= (others => '0');
                desc_reg2     <= (others => '0');
                desc_reg1     <= (others => '0');
                desc_reg0     <= (others => '0');
            -- Shift if enabled or if doing and overlay
            elsif(ftch_shftenbl = '1')then
                desc_reg6       <= m_axis_ftch_tdata;
                desc_reg5       <= desc_reg6;
                desc_reg4       <= desc_reg5;
                desc_reg3       <= desc_reg4;
                desc_reg2       <= desc_reg3;
                desc_reg1       <= desc_reg2;
                desc_reg0       <= desc_reg1;
            end if;
        end if;
    end process DESC_WRD_PROCESS;

desc_curdesc_lsb   <= desc_reg0;
desc_curdesc_msb   <= desc_reg1;
desc_strtaddr_lsb  <= desc_reg2;
desc_strtaddr_msb  <= desc_reg3;

desc_vsize         <= desc_reg4(DESC_WRD4_VSIZE_MSB_BIT  downto DESC_WRD4_VSIZE_LSB_BIT);
desc_hsize         <= desc_reg5(DESC_WRD5_HSIZE_MSB_BIT  downto DESC_WRD5_HSIZE_LSB_BIT);
desc_stride        <= desc_reg6(DESC_WRD6_STRIDE_MSB_BIT downto DESC_WRD6_STRIDE_LSB_BIT);
desc_frmdly        <= desc_reg6(DESC_WRD6_FRMDLY_MSB_BIT downto DESC_WRD6_FRMDLY_LSB_BIT);

-------------------------------------------------------------------------------
-- BUFFER ADDRESS
-------------------------------------------------------------------------------
-- If 64 bit addressing then concatinate msb to lsb
GEN_NEW_64BIT_BUFADDR : if C_M_AXI_ADDR_WIDTH = 64 generate
    desc_strtaddress <= desc_strtaddr_msb & desc_strtaddr_lsb;
end generate GEN_NEW_64BIT_BUFADDR;

-- If 32 bit addressing then simply pass lsb out
GEN_NEW_32BIT_BUFADDR : if C_M_AXI_ADDR_WIDTH = 32 generate
    desc_strtaddress <= desc_strtaddr_lsb;
end generate GEN_NEW_32BIT_BUFADDR;

-------------------------------------------------------------------------------
-- NEW CURRENT DESCRIPTOR
-------------------------------------------------------------------------------
-- If 64 bit addressing then concatinate msb to lsb
GEN_NEW_64BIT_CURDESC : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
    new_curdesc <= desc_curdesc_msb & desc_curdesc_lsb;
end generate GEN_NEW_64BIT_CURDESC;

-- If 32 bit addressing then simply pass lsb out
GEN_NEW_32BIT_CURDESC : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
    new_curdesc <= desc_curdesc_lsb;
end generate GEN_NEW_32BIT_CURDESC;

-- Write new descriptor data out on last
REG_DESCDATA_WREN : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                desc_data_wren_i <= '0';
            -- Write new desc data on fetch done
            elsif(desc_fetch_done_i = '1')then
                desc_data_wren_i <= '1';
            else
                desc_data_wren_i <= '0';
            end if;
        end if;
    end process REG_DESCDATA_WREN;

desc_data_wren  <= desc_data_wren_i;


end implementation;
