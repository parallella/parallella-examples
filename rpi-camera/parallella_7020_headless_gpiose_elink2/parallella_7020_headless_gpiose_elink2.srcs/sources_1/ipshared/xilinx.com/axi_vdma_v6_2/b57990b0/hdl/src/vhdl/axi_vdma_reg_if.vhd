-------------------------------------------------------------------------------
-- axi_vdma_reg_if
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
-- Filename:          axi_vdma_reg_if.vhd
-- Description: This entity is AXI VDMA Register Interface Top Level
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

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

library lib_cdc_v1_0;
-------------------------------------------------------------------------------
entity  axi_vdma_reg_if is
    generic(
        C_INCLUDE_MM2S              	: integer range 0 to 1      	:= 1;
            -- Include or exclude MM2S channel
            -- 0 = exclude mm2s channel
            -- 1 = include mm2s channel

        C_INCLUDE_S2MM              	: integer range 0 to 1      	:= 1;
            -- Include or exclude S2MM channel
            -- 0 = exclude s2mm channel
            -- 1 = include s2mm channel
        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 1;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers
        C_ENABLE_DEBUG_INFO_0       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 0
        C_ENABLE_DEBUG_INFO_1       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 1
        C_ENABLE_DEBUG_INFO_2       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 2
        C_ENABLE_DEBUG_INFO_3       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 3
        C_ENABLE_DEBUG_INFO_4       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 4
        C_ENABLE_DEBUG_INFO_5       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 5
        C_ENABLE_DEBUG_INFO_6       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 6
        C_ENABLE_DEBUG_INFO_7       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 7
        C_ENABLE_DEBUG_INFO_8       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 8
        C_ENABLE_DEBUG_INFO_9       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 9
        C_ENABLE_DEBUG_INFO_10      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 10
        C_ENABLE_DEBUG_INFO_11      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 11
        C_ENABLE_DEBUG_INFO_12      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 12
        C_ENABLE_DEBUG_INFO_13      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 13
        C_ENABLE_DEBUG_INFO_14      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 14
        C_ENABLE_DEBUG_INFO_15      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 15






        C_INCLUDE_SG                    : integer range 0 to 1   	:= 1;
            -- Include or Exclude Scatter Gather Engine
            -- 0 = Exclude Scatter Gather Engine (Enables Register Direct Mode)
            -- 1 = Include Scatter Gather Engine

        C_ENABLE_VIDPRMTR_READS         : integer range 0 to 1   	:= 1;
            -- Specifies whether video parameters are readable by axi_lite interface
            -- when configure for Register Direct Mode
            -- 0 = Disable Video Parameter Reads (Saves FPGA Resources)
            -- 1 = Enable Video Parameter Reads

        C_TOTAL_NUM_REGISTER            : integer                	:= 8;
            -- Number of register CE's

        C_PRMRY_IS_ACLK_ASYNC         	: integer range 0 to 1     	:= 0;
            -- Specifies the AXI Lite clock is asynchronous
            -- 0 = AXI Clocks are Synchronous
            -- 1 = AXI Clocks are Asynchronous

        C_S_AXI_LITE_ADDR_WIDTH     	: integer range 9 to 9    	:= 9;
            -- AXI Lite interface address width

        C_S_AXI_LITE_DATA_WIDTH     	: integer range 32 to 32    	:= 32;
            -- AXI Lite interface data width

        C_VERSION_MAJOR             	: std_logic_vector (3 downto 0) := X"1" ;
            -- Major Version number 0, 1, 2, 3 etc.

        C_VERSION_MINOR             	: std_logic_vector (7 downto 0) := X"00";
            -- Minor Version Number 00, 01, 02, etc.

        C_VERSION_REVISION          	: std_logic_vector (3 downto 0) := X"a" ;
            -- Version Revision character (EDK) a,b,c,etc

        C_REVISION_NUMBER           	: string 			:= "Build Number: 0000"
            -- Internal build number
    );
    port (
        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        s_axi_lite_aclk             : in  std_logic                                 ;       --
        s_axi_lite_reset_n          : in  std_logic                                 ;       --
                                                                                            --
        -- AXI Lite Write Address Channel                                                   --
        s_axi_lite_awvalid          : in  std_logic                                 ;       --
        s_axi_lite_awready          : out std_logic                                 ;       --
        s_axi_lite_awaddr           : in  std_logic_vector                                  --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)        ;       --
                                                                                            --
        -- AXI Lite Write Data Channel                                                      --
        s_axi_lite_wvalid           : in  std_logic                                 ;       --
        s_axi_lite_wready           : out std_logic                                 ;       --
        s_axi_lite_wdata            : in  std_logic_vector                                  --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)        ;       --
                                                                                            --
        -- AXI Lite Write Response Channel                                                  --
        s_axi_lite_bresp            : out std_logic_vector(1 downto 0)              ;       --
        s_axi_lite_bvalid           : out std_logic                                 ;       --
        s_axi_lite_bready           : in  std_logic                                 ;       --
                                                                                            --
        -- AXI Lite Read Address Channel                                                    --
        s_axi_lite_arvalid          : in  std_logic                                 ;       --
        s_axi_lite_arready          : out std_logic                                 ;       --
        s_axi_lite_araddr           : in  std_logic_vector                                  --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)        ;       --
        s_axi_lite_rvalid           : out std_logic                                 ;       --
        s_axi_lite_rready           : in  std_logic                                 ;       --
        s_axi_lite_rdata            : out std_logic_vector                                  --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)        ;       --
        s_axi_lite_rresp            : out std_logic_vector(1 downto 0)              ;       --
                                                                                            --
                                                                                            --
        -- MM2S Register Interface                                                          --
        m_axi_mm2s_aclk             : in  std_logic                                 ;       --
        mm2s_hrd_resetn             : in  std_logic                                 ;       --
        mm2s_axi2ip_wrce            : out  std_logic_vector                                 --
                                        (C_TOTAL_NUM_REGISTER-1 downto 0)           ;       --
        mm2s_axi2ip_wrdata          : out  std_logic_vector                                 --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)        ;       --
        mm2s_axi2ip_rdaddr          : out std_logic_vector                                  --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)        ;       --
        mm2s_ip2axi_rddata          : in std_logic_vector                               --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  ;          --
        mm2s_ip2axi_frame_ptr_ref   : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        mm2s_ip2axi_frame_store     : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        mm2s_ip2axi_introut         : in  std_logic                                 ;       --
                                                                                            --
                                                                                            --
        -- S2MM Register Interface                                                          --

        m_axi_s2mm_aclk             : in  std_logic                                 ;       --
        s2mm_hrd_resetn             : in  std_logic                                 ;       --



        s2mm_axi2ip_wrce            : out std_logic_vector                                  --
                                        (C_TOTAL_NUM_REGISTER-1 downto 0)           ;       --
        s2mm_axi2ip_wrdata          : out std_logic_vector                                  --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)        ;       --
                                                                                            --
        s2mm_ip2axi_rddata          : in std_logic_vector                               --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  ;          --
        s2mm_axi2ip_rdaddr          : out std_logic_vector                                  --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)        ;       --
        s2mm_ip2axi_frame_ptr_ref   : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        s2mm_ip2axi_frame_store     : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)             ;       --
        s2mm_ip2axi_introut         : in  std_logic                                 ;       --


s2mm_capture_dm_done_vsize_counter  :  in std_logic_vector(12 downto 0) ;
s2mm_capture_hsize_at_uf_err        :  in std_logic_vector(15 downto 0) ;

        mm2s_chnl_current_frame     : in std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        mm2s_genlock_pair_frame     : in std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --

        s2mm_chnl_current_frame     : in std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        s2mm_genlock_pair_frame     : in std_logic_vector
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --

        -- Interrupt Out                                                                    --
        mm2s_introut                : out std_logic                                 ;       --
        s2mm_introut                : out std_logic                                         --


    );
end axi_vdma_reg_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_reg_if is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
constant AXI_LITE_SYNC      : integer := 0;

constant ZERO_VALUE_VECT    : std_logic_vector(128 downto 0) := (others => '0');

-- PARK_PTR_REF Register constants
constant PARK_PAD_WIDTH     : integer := (C_S_AXI_LITE_DATA_WIDTH - (FRAME_NUMBER_WIDTH * 4))/4;
constant PARK_REG_PAD       : std_logic_vector(PARK_PAD_WIDTH-1 downto 0) := (others => '0');




-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
--signal axi2ip_rden                  			: std_logic := '0';
signal ip2axi_rddata_common_region  			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');

-- version signals
signal rev_num                      			: integer := string2int(C_REVISION_NUMBER);
signal vdma_version_i               			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');
signal park_ptr_ref_i               			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');
signal genlock_frm_ptr_i            			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_hsize_at_lsize_less_err 			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_vsize_at_fsize_less_err 			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) 	:= (others => '0');

signal mm2s_frame_ptr_ref           			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_frame_store             			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_chnl_current_frame_i    			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_genlock_pair_frame_i    			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');

signal s2mm_frame_ptr_ref           			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_frame_store             			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_chnl_current_frame_i    			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_genlock_pair_frame_i    			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');

signal sig_axi2ip_common_region_1_rden                  : std_logic 						:= '0';
signal sig_axi2ip_common_region_2_rden                  : std_logic 						:= '0';
signal read_region_mux_select              		: std_logic_vector(3 downto 0) 				:= (others => '0');
signal sig_axi2ip_lite_rdaddr          			: std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)	:= (others => '0');           --


signal mm2s_ip2axi_frame_ptr_ref_cdc_tig           	: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_ip2axi_frame_store_cdc_tig             	: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_chnl_current_frame_cdc_tig    		: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal mm2s_genlock_pair_frame_cdc_tig    		: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_ip2axi_frame_ptr_ref_cdc_tig		: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_ip2axi_frame_store_cdc_tig 			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_chnl_current_frame_cdc_tig 			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_genlock_pair_frame_cdc_tig 			: std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0) 	:= (others => '0');
signal s2mm_capture_hsize_at_uf_err_cdc_tig		: std_logic_vector(15 downto 0) 			:= (others => '0');
signal s2mm_capture_dm_done_vsize_counter_cdc_tig	: std_logic_vector(12 downto 0) 			:= (others => '0');


  ATTRIBUTE async_reg                      : STRING;
  ATTRIBUTE async_reg OF mm2s_ip2axi_frame_ptr_ref_cdc_tig         : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF mm2s_ip2axi_frame_store_cdc_tig           : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF mm2s_chnl_current_frame_cdc_tig    	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF mm2s_genlock_pair_frame_cdc_tig    	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_ip2axi_frame_ptr_ref_cdc_tig	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_ip2axi_frame_store_cdc_tig 	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_chnl_current_frame_cdc_tig 	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_genlock_pair_frame_cdc_tig 	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_capture_hsize_at_uf_err_cdc_tig	   : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_capture_dm_done_vsize_counter_cdc_tig  : SIGNAL IS "true"; 

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin





read_region_mux_select(3) 		<= sig_axi2ip_common_region_2_rden ;
read_region_mux_select(2) 		<= sig_axi2ip_common_region_1_rden ;
read_region_mux_select(1 downto 0) 	<= sig_axi2ip_lite_rdaddr(3 downto 2);





-------------------------------------------------------------------------------
-- Generate AXI Lite Inteface
-------------------------------------------------------------------------------
GEN_AXI_LITE_IF : if C_INCLUDE_MM2S = 1 or C_INCLUDE_S2MM = 1 generate
begin
    AXI_LITE_IF_I : entity axi_vdma_v6_2.axi_vdma_lite_if
        generic map(
            C_NUM_CE                    => C_TOTAL_NUM_REGISTER     ,
            C_MM2S_IS                   => C_INCLUDE_MM2S           ,
            C_S2MM_IS                   => C_INCLUDE_S2MM           ,
            C_PRMRY_IS_ACLK_ASYNC       => C_PRMRY_IS_ACLK_ASYNC    ,
            C_S_AXI_LITE_ADDR_WIDTH     => C_S_AXI_LITE_ADDR_WIDTH  ,
            C_S_AXI_LITE_DATA_WIDTH     => C_S_AXI_LITE_DATA_WIDTH
        )
        port map(
            s_axi_lite_aclk             => s_axi_lite_aclk          ,
            s_axi_lite_aresetn          => s_axi_lite_reset_n       ,

            m_axi_mm2s_aclk             => m_axi_mm2s_aclk                      ,
            mm2s_hrd_resetn             => mm2s_hrd_resetn                      ,

            m_axi_s2mm_aclk             => m_axi_s2mm_aclk                      ,
            s2mm_hrd_resetn             => s2mm_hrd_resetn                      ,

            -- AXI Lite Write Address Channel
            s_axi_lite_awvalid          => s_axi_lite_awvalid       ,
            s_axi_lite_awready          => s_axi_lite_awready       ,
            s_axi_lite_awaddr           => s_axi_lite_awaddr        ,

            -- AXI Lite Write Data Channel
            s_axi_lite_wvalid           => s_axi_lite_wvalid        ,
            s_axi_lite_wready           => s_axi_lite_wready        ,
            s_axi_lite_wdata            => s_axi_lite_wdata         ,

            -- AXI Lite Write Response Channel
            s_axi_lite_bresp            => s_axi_lite_bresp         ,
            s_axi_lite_bvalid           => s_axi_lite_bvalid        ,
            s_axi_lite_bready           => s_axi_lite_bready        ,

            -- AXI Lite Read Address Channel
            s_axi_lite_arvalid          => s_axi_lite_arvalid       ,
            s_axi_lite_arready          => s_axi_lite_arready       ,
            s_axi_lite_araddr           => s_axi_lite_araddr        ,
            s_axi_lite_rvalid           => s_axi_lite_rvalid        ,
            s_axi_lite_rready           => s_axi_lite_rready        ,
            s_axi_lite_rdata            => s_axi_lite_rdata         ,
            s_axi_lite_rresp            => s_axi_lite_rresp         ,

            axi2ip_common_region_1_rden => sig_axi2ip_common_region_1_rden              ,
            axi2ip_common_region_2_rden => sig_axi2ip_common_region_2_rden              ,
            axi2ip_lite_rdaddr          => sig_axi2ip_lite_rdaddr            ,

            mm2s_axi2ip_wrce            => mm2s_axi2ip_wrce              ,
            mm2s_axi2ip_wrdata          => mm2s_axi2ip_wrdata            ,
            mm2s_ip2axi_rddata          => mm2s_ip2axi_rddata              ,
            mm2s_axi2ip_rdaddr          => mm2s_axi2ip_rdaddr            ,
            s2mm_axi2ip_wrce            => s2mm_axi2ip_wrce              ,
            s2mm_axi2ip_wrdata          => s2mm_axi2ip_wrdata            ,
            s2mm_ip2axi_rddata          => s2mm_ip2axi_rddata              ,
            s2mm_axi2ip_rdaddr          => s2mm_axi2ip_rdaddr            ,
            ip2axi_rddata_common_region => ip2axi_rddata_common_region

        );
end generate GEN_AXI_LITE_IF;

-------------------------------------------------------------------------------
-- No channels therefore do not generate an AXI Lite interface
-------------------------------------------------------------------------------
GEN_NO_AXI_LITE_IF : if C_INCLUDE_MM2S = 0 and C_INCLUDE_S2MM = 0 generate
begin
    s_axi_lite_awready          <= '0';
    s_axi_lite_wready           <= '0';
    s_axi_lite_bresp            <= (others => '0');
    s_axi_lite_bvalid           <= '0';
    s_axi_lite_arready          <= '0';
    s_axi_lite_rvalid           <= '0';
    s_axi_lite_rdata            <= (others => '0');
    s_axi_lite_rresp            <= (others => '0');

end generate GEN_NO_AXI_LITE_IF;

-------------------------------------------------------------------------------
-- Generate MM2S Registers if included
-------------------------------------------------------------------------------
GEN_MM2S_LITE_CROSSINGS : if C_INCLUDE_MM2S = 1 generate
begin

  GEN_MM2S_CROSSINGS_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
  

        mm2s_frame_ptr_ref  		<= mm2s_ip2axi_frame_ptr_ref;
        mm2s_frame_store    		<= mm2s_ip2axi_frame_store;
        mm2s_chnl_current_frame_i    	<= mm2s_chnl_current_frame;
        mm2s_genlock_pair_frame_i    	<= mm2s_genlock_pair_frame;
        mm2s_introut            	<= mm2s_ip2axi_introut;


  end generate GEN_MM2S_CROSSINGS_SYNC;

  GEN_MM2S_CROSSINGS_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
  

        mm2s_frame_ptr_ref  			<= mm2s_ip2axi_frame_ptr_ref_cdc_tig;
        mm2s_frame_store    			<= mm2s_ip2axi_frame_store_cdc_tig;
        mm2s_chnl_current_frame_i    		<= mm2s_chnl_current_frame_cdc_tig;
        mm2s_genlock_pair_frame_i    		<= mm2s_genlock_pair_frame_cdc_tig;


GEN_LITE_MM2S_MISC_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then


        mm2s_ip2axi_frame_ptr_ref_cdc_tig  	<= mm2s_ip2axi_frame_ptr_ref;
        mm2s_ip2axi_frame_store_cdc_tig    	<= mm2s_ip2axi_frame_store;
        mm2s_chnl_current_frame_cdc_tig    	<= mm2s_chnl_current_frame;
        mm2s_genlock_pair_frame_cdc_tig    	<= mm2s_genlock_pair_frame;


        end if;
    end process GEN_LITE_MM2S_MISC_CROSSING;


MM2S_INTRPT_CROSSING_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES_LITE
    )
    port map (
        prmry_aclk                 => m_axi_mm2s_aclk,
        prmry_resetn               => mm2s_hrd_resetn, 
        prmry_in                   => mm2s_ip2axi_introut, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axi_lite_aclk, 
        scndry_resetn              => s_axi_lite_reset_n,
        scndry_out                 => mm2s_introut,
        scndry_vect_out            => open
    );



  end generate GEN_MM2S_CROSSINGS_ASYNC;





end generate GEN_MM2S_LITE_CROSSINGS;

-------------------------------------------------------------------------------
-- Tie MM2S Register outputs to zero if excluded
-------------------------------------------------------------------------------
GEN_NO_MM2S_CROSSINGS : if C_INCLUDE_MM2S = 0 generate
begin
    mm2s_introut                <= '0';
    mm2s_frame_ptr_ref  	<= (others => '0');
    mm2s_frame_store    	<= (others => '0');
    mm2s_chnl_current_frame_i   <= (others => '0');
    mm2s_genlock_pair_frame_i   <= (others => '0');

end generate GEN_NO_MM2S_CROSSINGS;


-------------------------------------------------------------------------------
-- Generate S2MM Registers if included
-------------------------------------------------------------------------------
GEN_S2MM_LITE_CROSSINGS : if C_INCLUDE_S2MM = 1 generate
begin

  GEN_S2MM_CROSSINGS_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate

        s2mm_frame_ptr_ref  				<= s2mm_ip2axi_frame_ptr_ref;
        s2mm_frame_store    				<= s2mm_ip2axi_frame_store;
        s2mm_chnl_current_frame_i    			<= s2mm_chnl_current_frame;
        s2mm_genlock_pair_frame_i    			<= s2mm_genlock_pair_frame;
        s2mm_introut        				<= s2mm_ip2axi_introut;
	s2mm_hsize_at_lsize_less_err(15 downto 0)	<= s2mm_capture_hsize_at_uf_err(15 downto 0);
	s2mm_vsize_at_fsize_less_err(12 downto 0)	<= s2mm_capture_dm_done_vsize_counter(12 downto 0);

  end generate GEN_S2MM_CROSSINGS_SYNC;

  GEN_S2MM_CROSSINGS_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate

        s2mm_frame_ptr_ref  				<= s2mm_ip2axi_frame_ptr_ref_cdc_tig;
        s2mm_frame_store    				<= s2mm_ip2axi_frame_store_cdc_tig;
        s2mm_chnl_current_frame_i    			<= s2mm_chnl_current_frame_cdc_tig;
        s2mm_genlock_pair_frame_i    			<= s2mm_genlock_pair_frame_cdc_tig;
	s2mm_hsize_at_lsize_less_err(15 downto 0)	<= s2mm_capture_hsize_at_uf_err_cdc_tig(15 downto 0);
	s2mm_vsize_at_fsize_less_err(12 downto 0)	<= s2mm_capture_dm_done_vsize_counter_cdc_tig(12 downto 0);


GEN_LITE_S2MM_MISC_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then


        s2mm_ip2axi_frame_ptr_ref_cdc_tig  			<= s2mm_ip2axi_frame_ptr_ref;
        s2mm_ip2axi_frame_store_cdc_tig    			<= s2mm_ip2axi_frame_store;
        s2mm_chnl_current_frame_cdc_tig    			<= s2mm_chnl_current_frame;
        s2mm_genlock_pair_frame_cdc_tig    			<= s2mm_genlock_pair_frame;
	s2mm_capture_hsize_at_uf_err_cdc_tig(15 downto 0)	<= s2mm_capture_hsize_at_uf_err(15 downto 0);
	s2mm_capture_dm_done_vsize_counter_cdc_tig(12 downto 0)	<= s2mm_capture_dm_done_vsize_counter(12 downto 0);


        end if;
    end process GEN_LITE_S2MM_MISC_CROSSING;




S2MM_INTRPT_CROSSING_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES_LITE
    )
    port map (
        prmry_aclk                 => m_axi_s2mm_aclk,
        prmry_resetn               => s2mm_hrd_resetn, 
        prmry_in                   => s2mm_ip2axi_introut, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axi_lite_aclk, 
        scndry_resetn              => s_axi_lite_reset_n,
        scndry_out                 => s2mm_introut,
        scndry_vect_out            => open
    );




  end generate GEN_S2MM_CROSSINGS_ASYNC;



end generate GEN_S2MM_LITE_CROSSINGS;

-------------------------------------------------------------------------------
-- Tie S2MM Register outputs to zero if excluded
-------------------------------------------------------------------------------
GEN_NO_S2MM_CROSSINGS : if C_INCLUDE_S2MM = 0 generate
begin

    	s2mm_introut                			<= '0';
        s2mm_frame_ptr_ref  				<= (others => '0');
        s2mm_frame_store    				<= (others => '0');
        s2mm_chnl_current_frame_i    			<= (others => '0');
        s2mm_genlock_pair_frame_i    			<= (others => '0');
	s2mm_hsize_at_lsize_less_err(15 downto 0)	<= (others => '0');
	s2mm_vsize_at_fsize_less_err(12 downto 0)	<= (others => '0');


end generate GEN_NO_S2MM_CROSSINGS;


s2mm_hsize_at_lsize_less_err(31 downto 16)		<= (others => '0');
s2mm_vsize_at_fsize_less_err(31 downto 13)		<= (others => '0');


--*****************************************************************************
-- GenLock frame number Reference Register (located here because mm2s and s2mm are
-- combined into this one register)
--*****************************************************************************

genlock_frm_ptr_i(31 downto 29)  <= (others => '0');
genlock_frm_ptr_i(28 downto 24)  <= s2mm_genlock_pair_frame_i;
genlock_frm_ptr_i(23 downto 21)  <= (others => '0');
genlock_frm_ptr_i(20 downto 16)  <= s2mm_chnl_current_frame_i;
genlock_frm_ptr_i(15 downto 13)  <= (others => '0');
genlock_frm_ptr_i(12 downto 8)   <= mm2s_genlock_pair_frame_i;
genlock_frm_ptr_i(7 downto 5)    <= (others => '0');
genlock_frm_ptr_i(4 downto 0)    <= mm2s_chnl_current_frame_i;

--*****************************************************************************
-- Park Pointer Reference Register (located here because mm2s and s2mm are
-- combined into this one register)
--*****************************************************************************
park_ptr_ref_i <= PARK_REG_PAD
                & s2mm_frame_store
                & PARK_REG_PAD
                & mm2s_frame_store
                & PARK_REG_PAD
                & s2mm_frame_ptr_ref
                & PARK_REG_PAD
                & mm2s_frame_ptr_ref;

--*****************************************************************************
-- VDMA Version (located here because it is not unique to one particular
-- channel)
--*****************************************************************************
vdma_version_i(31 downto 16) <= (C_VERSION_MAJOR & C_VERSION_MINOR & C_VERSION_REVISION);
vdma_version_i(15 downto 0)  <= std_logic_vector(to_unsigned(rev_num,16));


--*****************************************************************************
-- Read access to common_Region_1 (0x20 to 0x2C) or common_Region_2 (0xF0 to 0xFC)
--*****************************************************************************

GEN_COMMON_REGION_READ_MUX_STS_REG : if (C_ENABLE_DEBUG_INFO_12 = 1 or C_ENABLE_DEBUG_ALL = 1) generate
begin



COMMON_REGION_READ_MUX : process(read_region_mux_select,
                         park_ptr_ref_i,genlock_frm_ptr_i,s2mm_hsize_at_lsize_less_err, s2mm_vsize_at_fsize_less_err,
                         vdma_version_i
                         )
    begin
        case read_region_mux_select is

            when "0101" => -- GenLock Frame ptr capture 	0x24
                ip2axi_rddata_common_region       <= genlock_frm_ptr_i;
            when "0110" => -- Park ptr 				0x28
                ip2axi_rddata_common_region       <= park_ptr_ref_i;
            when "0111" => -- VDMA version			0x2C
                ip2axi_rddata_common_region       <= vdma_version_i;
            when "1000" => -- S2MM HSIZE STS 			0xF0
                ip2axi_rddata_common_region       <= s2mm_hsize_at_lsize_less_err;
            when "1001" => -- S2MM VSIZE STS			0xF4
                ip2axi_rddata_common_region       <= s2mm_vsize_at_fsize_less_err;
            when others => -- RESERVED				0x20, 0xF8, 0xFC
                ip2axi_rddata_common_region       <= (others => '0');

        end case;
    end process COMMON_REGION_READ_MUX;

end generate GEN_COMMON_REGION_READ_MUX_STS_REG;

GEN_COMMON_REGION_READ_MUX_NO_STS_REG : if (C_ENABLE_DEBUG_INFO_12 = 0 and C_ENABLE_DEBUG_ALL = 0) generate
begin



COMMON_REGION_READ_MUX : process(read_region_mux_select,
                         park_ptr_ref_i,
                         vdma_version_i
                         )
    begin
        case read_region_mux_select is

            --when "0101" => -- GenLock Frame ptr capture 	0x24
            --    ip2axi_rddata_common_region       <= genlock_frm_ptr_i;
            when "0110" => -- Park ptr 				0x28
                ip2axi_rddata_common_region       <= park_ptr_ref_i;
            when "0111" => -- VDMA version			0x2C
                ip2axi_rddata_common_region       <= vdma_version_i;
            --when "1000" => -- S2MM HSIZE STS 			0xF0
            --    ip2axi_rddata_common_region       <= s2mm_hsize_at_lsize_less_err;
            --when "1001" => -- S2MM VSIZE STS			0xF4
            --    ip2axi_rddata_common_region       <= s2mm_vsize_at_fsize_less_err;
            when others => -- RESERVED				0x20, 0x24, 0xF0, 0xF4, 0xF8, 0xFC
                ip2axi_rddata_common_region       <= (others => '0');

        end case;
    end process COMMON_REGION_READ_MUX;

end generate GEN_COMMON_REGION_READ_MUX_NO_STS_REG;






end implementation;
