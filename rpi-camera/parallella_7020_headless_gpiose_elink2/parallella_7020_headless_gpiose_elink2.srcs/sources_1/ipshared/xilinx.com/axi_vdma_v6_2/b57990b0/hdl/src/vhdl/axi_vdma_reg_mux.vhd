-------------------------------------------------------------------------------
-- axi_vdma_reg_mux
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
-- Filename:          axi_vdma_reg_mux.vhd
-- Description: This entity is AXI VDMA Register Module Top Level
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_vdma.vhd
--                   |- axi_vdma_pkg.vhd
--                   |- axi_vdmantrpt.vhd
--                   |- axi_vdma_rst_module.vhd
--                   |   |- axi_vdma_reset.vhd (mm2s)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |   |- axi_vdma_reset.vhd (s2mm)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |
--                   |- axi_vdma_regf.vhd
--                   |   |- axi_vdma_litef.vhd
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
--                   |   |- axi_vdma_sgf.vhd (mm2s)
--                   |   |- axi_vdma_sm.vhd (mm2s)
--                   |   |- axi_vdma_cmdstsf.vhd (mm2s)
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
--                   |   |- axi_vdma_sgf.vhd (s2mm)
--                   |   |- axi_vdma_sm.vhd (s2mm)
--                   |   |- axi_vdma_cmdstsf.vhd (s2mm)
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
entity  axi_vdma_reg_mux is
    generic (
        C_TOTAL_NUM_REGISTER            	: integer                	:= 8       ;
            -- Total number of defined registers for AXI VDMA.  Used
            -- to determine wrce and rdce vector widths.

        C_INCLUDE_SG                    	: integer range 0 to 1   	:= 1       ;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_CHANNEL_IS_MM2S               	: integer range 0 to 1   	:= 1       ;
            -- Channel type for Read Mux
            -- 0 = Channel is S2MM
            -- 1 = Channel is MM2S

        C_NUM_FSTORES                   	: integer range 1 to 32 	:= 3        ;
            -- Number of Frame Stores

        C_ENABLE_VIDPRMTR_READS     		: integer range 0 to 1       	:= 1       ;
            -- Specifies whether video parameters are readable by axi_lite interface
            -- when configure for Register Direct Mode
            -- 0 = Disable Video Parameter Reads
            -- 1 = Enable Video Parameter Reads

        C_S_AXI_LITE_ADDR_WIDTH     		: integer range 9 to 9    	:= 9       ;
            -- AXI Lite interface address width

        C_S_AXI_LITE_DATA_WIDTH     		: integer range 32 to 32   	:= 32       ;
            -- AXI Lite interface data width

        C_M_AXI_SG_ADDR_WIDTH       		: integer range 32 to 64    	:= 32       ;
            -- Scatter Gather engine Address Width

        C_M_AXI_ADDR_WIDTH          		: integer range 32 to 32    	:= 32
            -- Master AXI Memory Map Address Width for MM2S Write Port
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        axi2ip_rdaddr               : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)     ;       --
        axi2ip_rden                 : in  std_logic                                 ;       --
        ip2axi_rddata               : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        ip2axi_rddata_valid         : out std_logic                                 ;       --


        reg_index                   : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --


        dmacr                       : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        dmasr                       : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        dma_irq_mask                       : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        curdesc_lsb                 : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        curdesc_msb                 : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        taildesc_lsb                : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        taildesc_msb                : in  std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --
        num_frame_store             : in  std_logic_vector                                  --
                                           (NUM_FRM_STORE_WIDTH-1 downto 0)         ;       --
        linebuf_threshold           : in  std_logic_vector                                  --
                                           (THRESH_MSB_BIT downto 0)                ;       --
        -- Register Direct Support                                                          --
        reg_module_vsize            : in  std_logic_vector                                  --
                                           (VSIZE_DWIDTH-1 downto 0)                ;       --
        reg_module_hsize            : in  std_logic_vector                                  --
                                           (HSIZE_DWIDTH-1 downto 0)                ;       --
        reg_module_stride           : in  std_logic_vector                                  --
                                           (STRIDE_DWIDTH-1 downto 0)               ;       --
        reg_module_frmdly           : in  std_logic_vector                                  --
                                           (FRMDLY_DWIDTH-1 downto 0)               ;       --
        reg_module_start_address1   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address2   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address3   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address4   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address5   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address6   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address7   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address8   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address9   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address10  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address11  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address12  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address13  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address14  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address15  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address16  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address17   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address18   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address19   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address20   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address21   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address22   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address23   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address24   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address25   : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address26  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address27  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address28  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address29  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address30  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address31  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)        ;       --
        reg_module_start_address32  : in  std_logic_vector                                  --
                                           (C_M_AXI_ADDR_WIDTH - 1 downto 0)                --

    );
end axi_vdma_reg_mux;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_reg_mux is

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";
ATTRIBUTE DONT_TOUCH                           : STRING;

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

constant VSIZE_PAD_WIDTH    : integer := C_S_AXI_LITE_DATA_WIDTH-VSIZE_DWIDTH;
constant VSIZE_PAD          : std_logic_vector(VSIZE_PAD_WIDTH-1 downto 0) 	:= (others => '0');
constant HSIZE_PAD_WIDTH    : integer := C_S_AXI_LITE_DATA_WIDTH-HSIZE_DWIDTH;
constant HSIZE_PAD          : std_logic_vector(HSIZE_PAD_WIDTH-1 downto 0) 	:= (others => '0');

constant FRMSTORE_ZERO_PAD  : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH - 1
                                downto FRMSTORE_MSB_BIT+1) 			:= (others => '0');
constant THRESH_ZERO_PAD    : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH - 1
                                downto THRESH_MSB_BIT+1) 			:= (others => '0');


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal read_addr_ri         : std_logic_vector(8 downto 0) 			:= (others => '0');
signal read_addr            : std_logic_vector(7 downto 0) 			:= (others => '0');
signal read_addr_sg_1       : std_logic_vector(7 downto 0) 			:= (others => '0');
signal ip2axi_rddata_int    : std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)     ;       --


  ATTRIBUTE DONT_TOUCH OF ip2axi_rddata_int               : SIGNAL IS "true";
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

ip2axi_rddata <= ip2axi_rddata_int;
--*****************************************************************************
-- AXI LITE READ MUX
--*****************************************************************************
-- Register module is for MM2S Channel therefore look at
-- MM2S Register offsets
GEN_READ_MUX_FOR_MM2S : if C_CHANNEL_IS_MM2S = 1 generate
begin
    -- Scatter Gather Mode Read MUX
    GEN_READ_MUX_SG : if C_INCLUDE_SG = 1 generate
    begin
        --read_addr <= axi2ip_rdaddr(9 downto 0);
        read_addr_sg_1 <= axi2ip_rdaddr(7 downto 0);

        AXI_LITE_READ_MUX : process(read_addr_sg_1       ,
                                    axi2ip_rden     ,
                                    dmacr         ,
                                    dmasr         ,
                                    curdesc_lsb   ,
                                    curdesc_msb   ,
                                    taildesc_lsb  ,
                                    taildesc_msb  ,
                                    num_frame_store,
                                    linebuf_threshold)
            begin
                case read_addr_sg_1 is
                    when MM2S_DMACR_OFFSET_SG        =>
                        ip2axi_rddata_int       <= dmacr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_DMASR_OFFSET_SG        =>
                        ip2axi_rddata_int       <= dmasr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_CURDESC_LSB_OFFSET_SG  =>
                        ip2axi_rddata_int       <= curdesc_lsb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_CURDESC_MSB_OFFSET_SG  =>
                        ip2axi_rddata_int       <= curdesc_msb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_TAILDESC_LSB_OFFSET_SG =>
                        ip2axi_rddata_int       <= taildesc_lsb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_TAILDESC_MSB_OFFSET_SG =>
                        ip2axi_rddata_int       <= taildesc_msb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_FRAME_STORE_OFFSET_SG =>
                        ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                             & num_frame_store;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_THRESHOLD_OFFSET_SG =>
                        ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                            & linebuf_threshold;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when others =>
                        ip2axi_rddata_int       <= (others => '0');
                        ip2axi_rddata_valid <= '0';
                end case;
            end process AXI_LITE_READ_MUX;
    end generate GEN_READ_MUX_SG;



    -- Register Direct Mode Read MUX
    GEN_READ_MUX_REG_DIRECT : if C_INCLUDE_SG = 0  and C_ENABLE_VIDPRMTR_READS = 1 generate
    begin

        read_addr <= axi2ip_rdaddr(7 downto 0);
        read_addr_ri <= reg_index(0) & axi2ip_rdaddr(7 downto 0);



        -- 1 start addresses
        GEN_FSTORES_1  : if C_NUM_FSTORES = 1 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1)
                begin
                    case read_addr is
                        when  MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_1;

        -- 2 start addresses
        GEN_FSTORES_2  : if C_NUM_FSTORES = 2 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_2;

        -- 3 start addresses
        GEN_FSTORES_3  : if C_NUM_FSTORES = 3 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_3;

        -- 4 start addresses
        GEN_FSTORES_4  : if C_NUM_FSTORES = 4 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_4;

        -- 5 start addresses
        GEN_FSTORES_5  : if C_NUM_FSTORES = 5 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_5;

        -- 6 start addresses
        GEN_FSTORES_6  : if C_NUM_FSTORES = 6 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_6;

        -- 7 start addresses
        GEN_FSTORES_7  : if C_NUM_FSTORES = 7 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_7;

        -- 8 start addresses
        GEN_FSTORES_8  : if C_NUM_FSTORES = 8 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_8;

        -- 9 start addresses
        GEN_FSTORES_9  : if C_NUM_FSTORES = 9 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_9;

        -- 10 start addresses
        GEN_FSTORES_10  : if C_NUM_FSTORES = 10 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_10;

        -- 11 start addresses
        GEN_FSTORES_11  : if C_NUM_FSTORES = 11 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_11;

        -- 12 start addresses
        GEN_FSTORES_12  : if C_NUM_FSTORES = 12 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_12;

        -- 13 start addresses
        GEN_FSTORES_13  : if C_NUM_FSTORES = 13 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_13;

        -- 14 start addresses
        GEN_FSTORES_14  : if C_NUM_FSTORES = 14 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_14;

        -- 15 start addresses
        GEN_FSTORES_15  : if C_NUM_FSTORES = 15 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_15;

        -- 16 start addresses
        GEN_FSTORES_16  : if C_NUM_FSTORES = 16 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16)
                begin
                    case read_addr is
                        when MM2S_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_16;

        -- 17 start addresses
        GEN_FSTORES_17  : if C_NUM_FSTORES = 17 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_17;

        -- 18 start addresses
        GEN_FSTORES_18  : if C_NUM_FSTORES = 18 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_18;

        -- 19 start addresses
        GEN_FSTORES_19  : if C_NUM_FSTORES = 19 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_19;

        -- 20 start addresses
        GEN_FSTORES_20  : if C_NUM_FSTORES = 20 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_20;

        -- 21 start addresses
        GEN_FSTORES_21  : if C_NUM_FSTORES = 21 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_21;

        -- 22 start addresses
        GEN_FSTORES_22  : if C_NUM_FSTORES = 22 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_22;

        -- 23 start addresses
        GEN_FSTORES_23  : if C_NUM_FSTORES = 23 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_23;

        -- 24 start addresses
        GEN_FSTORES_24  : if C_NUM_FSTORES = 24 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_24;

        -- 25 start addresses
        GEN_FSTORES_25  : if C_NUM_FSTORES = 25 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_25;

        -- 26 start addresses
        GEN_FSTORES_26  : if C_NUM_FSTORES = 26 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_26;

        -- 27 start addresses
        GEN_FSTORES_27  : if C_NUM_FSTORES = 27 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_27;

        -- 28 start addresses
        GEN_FSTORES_28  : if C_NUM_FSTORES = 28 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_28;

        -- 29 start addresses
        GEN_FSTORES_29  : if C_NUM_FSTORES = 29 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_29;

        -- 30 start addresses
        GEN_FSTORES_30  : if C_NUM_FSTORES = 30 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_30;

        -- 31 start addresses
        GEN_FSTORES_31  : if C_NUM_FSTORES = 31 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30    ,
                                        reg_module_start_address31)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR31_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address31;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_31;

        -- 32 start addresses
        GEN_FSTORES_32  : if C_NUM_FSTORES = 32 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30    ,
                                        reg_module_start_address31    ,
                                        reg_module_start_address32)
                begin
                    case read_addr_ri is
                        when MM2S_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;

                        when MM2S_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR31_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address31;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_STARTADDR32_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address32;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_32;



    end generate GEN_READ_MUX_REG_DIRECT;

    -- Register Direct Mode Read MUX
    GEN_READ_MUX_LITE_REG_DIRECT : if C_INCLUDE_SG = 0  and C_ENABLE_VIDPRMTR_READS = 0 generate
    begin
        read_addr <= axi2ip_rdaddr(7 downto 0);

        AXI_LITE_READ_MUX : process(read_addr                           ,
                                    axi2ip_rden                         ,
                                    dmacr                             ,
                                    reg_index                             ,
                                    dmasr                             ,
                                    num_frame_store                   ,
                                    linebuf_threshold)
            begin
                case read_addr is
                    when MM2S_DMACR_OFFSET_8          =>
                        ip2axi_rddata_int       <= dmacr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_DMASR_OFFSET_8          =>
                        ip2axi_rddata_int       <= dmasr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when MM2S_REG_INDEX_OFFSET_8          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_FRAME_STORE_OFFSET_8 =>
                        ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                             & num_frame_store;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when MM2S_THRESHOLD_OFFSET_8 =>
                        ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                            & linebuf_threshold;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when others =>
                        ip2axi_rddata_int       <= (others => '0');
                        ip2axi_rddata_valid <= '0';
                end case;
            end process AXI_LITE_READ_MUX;
    end generate GEN_READ_MUX_LITE_REG_DIRECT;

end generate GEN_READ_MUX_FOR_MM2S;


-- Register module is for S2MM Channel therefore look at
-- S2MM Register offsets
GEN_READ_MUX_FOR_S2MM : if C_CHANNEL_IS_MM2S = 0 generate
begin
    -- Scatter Gather Mode Read MUX
    GEN_READ_MUX_SG : if C_INCLUDE_SG = 1 generate
    begin
        --read_addr <= axi2ip_rdaddr(9 downto 0);
        read_addr_sg_1 <= axi2ip_rdaddr(7 downto 0);

        AXI_LITE_READ_MUX : process(read_addr_sg_1       ,
                                    axi2ip_rden     ,
                                    dmacr         ,
                                    dmasr         ,
                                    curdesc_lsb   ,
                                    dma_irq_mask   ,
                                    taildesc_lsb  ,
                                    taildesc_msb  ,
                                    num_frame_store,
                                    linebuf_threshold)
            begin
                case read_addr_sg_1 is
                    when S2MM_DMACR_OFFSET_SG        =>
                        ip2axi_rddata_int       <= dmacr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMASR_OFFSET_SG        =>
                        ip2axi_rddata_int       <= dmasr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_CURDESC_LSB_OFFSET_SG  =>
                        ip2axi_rddata_int       <= curdesc_lsb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_SG  =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_TAILDESC_LSB_OFFSET_SG =>
                        ip2axi_rddata_int       <= taildesc_lsb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_TAILDESC_MSB_OFFSET_SG =>
                        ip2axi_rddata_int       <= taildesc_msb;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_FRAME_STORE_OFFSET_SG =>
                        ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                             & num_frame_store;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_THRESHOLD_OFFSET_SG =>
                        ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                            & linebuf_threshold;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when others =>
                        ip2axi_rddata_int       <= (others => '0');
                        ip2axi_rddata_valid <= '0';
                end case;
            end process AXI_LITE_READ_MUX;
    end generate GEN_READ_MUX_SG;



    -- Register Direct Mode Read MUX
    GEN_READ_MUX_REG_DIRECT : if C_INCLUDE_SG = 0  and C_ENABLE_VIDPRMTR_READS = 1 generate
    begin

        read_addr <= axi2ip_rdaddr(7 downto 0);
        read_addr_ri <= reg_index(0) & axi2ip_rdaddr(7 downto 0);
        -- 17 start addresses


        -- 1 start addresses
        GEN_FSTORES_1  : if C_NUM_FSTORES = 1 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_1;

        -- 2 start addresses
        GEN_FSTORES_2  : if C_NUM_FSTORES = 2 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_2;

        -- 3 start addresses
        GEN_FSTORES_3  : if C_NUM_FSTORES = 3 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_3;

        -- 4 start addresses
        GEN_FSTORES_4  : if C_NUM_FSTORES = 4 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_4;

        -- 5 start addresses
        GEN_FSTORES_5  : if C_NUM_FSTORES = 5 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_5;

        -- 6 start addresses
        GEN_FSTORES_6  : if C_NUM_FSTORES = 6 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_6;

        -- 7 start addresses
        GEN_FSTORES_7  : if C_NUM_FSTORES = 7 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_7;

        -- 8 start addresses
        GEN_FSTORES_8  : if C_NUM_FSTORES = 8 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_8;

        -- 9 start addresses
        GEN_FSTORES_9  : if C_NUM_FSTORES = 9 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_9;

        -- 10 start addresses
        GEN_FSTORES_10  : if C_NUM_FSTORES = 10 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_10;

        -- 11 start addresses
        GEN_FSTORES_11  : if C_NUM_FSTORES = 11 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_11;

        -- 12 start addresses
        GEN_FSTORES_12  : if C_NUM_FSTORES = 12 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_12;

        -- 13 start addresses
        GEN_FSTORES_13  : if C_NUM_FSTORES = 13 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_13;

        -- 14 start addresses
        GEN_FSTORES_14  : if C_NUM_FSTORES = 14 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_14;

        -- 15 start addresses
        GEN_FSTORES_15  : if C_NUM_FSTORES = 15 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_15;

        -- 16 start addresses
        GEN_FSTORES_16  : if C_NUM_FSTORES = 16 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                          ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16)
                begin
                    case read_addr is
                        when S2MM_DMACR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_8          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_8 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_8 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_8           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_8         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR1_OFFSET_8 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_8      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_8     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_16;

        -- 17 start addresses
        GEN_FSTORES_17  : if C_NUM_FSTORES = 17 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_17;


        -- 18 start addresses
        GEN_FSTORES_18  : if C_NUM_FSTORES = 18 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_18;

        -- 19 start addresses
        GEN_FSTORES_19  : if C_NUM_FSTORES = 19 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_19;

        -- 20 start addresses
        GEN_FSTORES_20  : if C_NUM_FSTORES = 20 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_20;

        -- 21 start addresses
        GEN_FSTORES_21  : if C_NUM_FSTORES = 21 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_21;

        -- 22 start addresses
        GEN_FSTORES_22  : if C_NUM_FSTORES = 22 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_22;

        -- 23 start addresses
        GEN_FSTORES_23  : if C_NUM_FSTORES = 23 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_23;

        -- 24 start addresses
        GEN_FSTORES_24  : if C_NUM_FSTORES = 24 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_24;

        -- 25 start addresses
        GEN_FSTORES_25  : if C_NUM_FSTORES = 25 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_25;

        -- 26 start addresses
        GEN_FSTORES_26  : if C_NUM_FSTORES = 26 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_26;

        -- 27 start addresses
        GEN_FSTORES_27  : if C_NUM_FSTORES = 27 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_27;

        -- 28 start addresses
        GEN_FSTORES_28  : if C_NUM_FSTORES = 28 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_28;

        -- 29 start addresses
        GEN_FSTORES_29  : if C_NUM_FSTORES = 29 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_29;

        -- 30 start addresses
        GEN_FSTORES_30  : if C_NUM_FSTORES = 30 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_30;

        -- 31 start addresses
        GEN_FSTORES_31  : if C_NUM_FSTORES = 31 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30    ,
                                        reg_module_start_address31)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR31_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address31;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_31;

        -- 32 start addresses
        GEN_FSTORES_32  : if C_NUM_FSTORES = 32 generate
        begin
            AXI_LITE_READ_MUX : process(read_addr_ri                       ,
                                        axi2ip_rden                     ,
                                        dmacr                         ,
                                        dmasr                         , reg_index ,
                                    dma_irq_mask   ,
                                        num_frame_store               ,
                                        linebuf_threshold             ,
                                        reg_module_vsize              ,
                                        reg_module_hsize              ,
                                        reg_module_stride             ,
                                        reg_module_frmdly             ,
                                        reg_module_start_address1     ,
                                        reg_module_start_address2     ,
                                        reg_module_start_address3     ,
                                        reg_module_start_address4     ,
                                        reg_module_start_address5     ,
                                        reg_module_start_address6     ,
                                        reg_module_start_address7     ,
                                        reg_module_start_address8     ,
                                        reg_module_start_address9     ,
                                        reg_module_start_address10    ,
                                        reg_module_start_address11    ,
                                        reg_module_start_address12    ,
                                        reg_module_start_address13    ,
                                        reg_module_start_address14    ,
                                        reg_module_start_address15    ,
                                        reg_module_start_address16    ,
                                        reg_module_start_address17    ,
                                        reg_module_start_address18    ,
                                        reg_module_start_address19    ,
                                        reg_module_start_address20    ,
                                        reg_module_start_address21    ,
                                        reg_module_start_address22    ,
                                        reg_module_start_address23    ,
                                        reg_module_start_address24    ,
                                        reg_module_start_address25    ,
                                        reg_module_start_address26    ,
                                        reg_module_start_address27    ,
                                        reg_module_start_address28    ,
                                        reg_module_start_address29    ,
                                        reg_module_start_address30    ,
                                        reg_module_start_address31    ,
                                        reg_module_start_address32)
                begin
                    case read_addr_ri is
                        when S2MM_DMACR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_90          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_90          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_90          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_90 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_90 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_90           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_90         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_DMACR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmacr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMASR_OFFSET_91          =>
                            ip2axi_rddata_int       <= dmasr;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DMA_IRQ_MASK_OFFSET_91          =>
                            ip2axi_rddata_int       <= dma_irq_mask;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_91          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_FRAME_STORE_OFFSET_91 =>
                            ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                                 & num_frame_store;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_THRESHOLD_OFFSET_91 =>
                            ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                                & linebuf_threshold;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_VSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= VSIZE_PAD & reg_module_vsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_HSIZE_OFFSET_91           =>
                            ip2axi_rddata_int       <= HSIZE_PAD & reg_module_hsize;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_DLYSTRD_OFFSET_91         =>
                            ip2axi_rddata_int       <= RSVD_BITS_31TO29
                                                & reg_module_frmdly
                                                & RSVD_BITS_23TO16
                                                & reg_module_stride;
                            ip2axi_rddata_valid <= axi2ip_rden;



                        when S2MM_STARTADDR1_OFFSET_90 =>
                            ip2axi_rddata_int       <= reg_module_start_address1;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR2_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address2;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR3_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address3;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR4_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address4;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR5_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address5;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR6_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address6;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR7_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address7;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR8_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address8;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR9_OFFSET_90      =>
                            ip2axi_rddata_int       <= reg_module_start_address9;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR10_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address10;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR11_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address11;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR12_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address12;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR13_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address13;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR14_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address14;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR15_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address15;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR16_OFFSET_90     =>
                            ip2axi_rddata_int       <= reg_module_start_address16;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR17_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address17;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR18_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address18;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR19_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address19;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR20_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address20;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR21_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address21;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR22_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address22;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR23_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address23;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR24_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address24;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR25_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address25;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR26_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address26;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR27_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address27;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR28_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address28;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR29_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address29;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR30_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address30;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR31_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address31;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_STARTADDR32_OFFSET_91     =>
                            ip2axi_rddata_int       <= reg_module_start_address32;
                            ip2axi_rddata_valid <= axi2ip_rden;
                        when others =>
                            ip2axi_rddata_int       <= (others => '0');
                            ip2axi_rddata_valid <= '0';
                    end case;
                end process AXI_LITE_READ_MUX;
        end generate GEN_FSTORES_32;




    end generate GEN_READ_MUX_REG_DIRECT;

    -- Register Direct Mode Read MUX
    GEN_READ_MUX_LITE_REG_DIRECT : if C_INCLUDE_SG = 0  and C_ENABLE_VIDPRMTR_READS = 0 generate
    begin
        read_addr <= axi2ip_rdaddr(7 downto 0);

        AXI_LITE_READ_MUX : process(read_addr                           ,
                                    axi2ip_rden                         ,
                                    dmacr                             ,
                                    reg_index                             ,
                                    dmasr                             ,
                                    dma_irq_mask   ,
                                    num_frame_store                   ,
                                    linebuf_threshold)
            begin
                case read_addr is
                    when S2MM_DMACR_OFFSET_8          =>
                        ip2axi_rddata_int       <= dmacr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMASR_OFFSET_8          =>
                        ip2axi_rddata_int       <= dmasr;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_DMA_IRQ_MASK_8          =>
                        ip2axi_rddata_int       <= dma_irq_mask;
                        ip2axi_rddata_valid <= axi2ip_rden;
                        when S2MM_REG_INDEX_OFFSET_8          =>
                            ip2axi_rddata_int       <= reg_index;
                            ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_FRAME_STORE_OFFSET_8 =>
                        ip2axi_rddata_int       <= FRMSTORE_ZERO_PAD
                                             & num_frame_store;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when S2MM_THRESHOLD_OFFSET_8 =>
                        ip2axi_rddata_int       <= THRESH_ZERO_PAD
                                            & linebuf_threshold;
                        ip2axi_rddata_valid <= axi2ip_rden;
                    when others =>
                        ip2axi_rddata_int       <= (others => '0');
                        ip2axi_rddata_valid <= '0';
                end case;
            end process AXI_LITE_READ_MUX;
    end generate GEN_READ_MUX_LITE_REG_DIRECT;

end generate GEN_READ_MUX_FOR_S2MM;

end implementation;
