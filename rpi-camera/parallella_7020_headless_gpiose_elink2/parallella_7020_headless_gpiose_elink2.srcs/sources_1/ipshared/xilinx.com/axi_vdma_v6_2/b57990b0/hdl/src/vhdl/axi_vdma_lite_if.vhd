-------------------------------------------------------------------------------
-- axi_vdma_lite_if
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
-- Filename:          axi_vdma_lite_if.vhd
-- Description: This entity is AXI Lite Interface Module for the AXI DMA
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

library lib_cdc_v1_0;
library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;


-------------------------------------------------------------------------------
entity  axi_vdma_lite_if is
    generic(


        C_MM2S_IS              		: integer range 0 to 1      	:= 1;
            -- Include or exclude MM2S channel
            -- 0 = exclude mm2s channel
            -- 1 = include mm2s channel

        C_S2MM_IS              		: integer range 0 to 1      	:= 1;
            -- Include or exclude S2MM channel
            -- 0 = exclude s2mm channel
            -- 1 = include s2mm channel


        C_PRMRY_IS_ACLK_ASYNC         	: integer range 0 to 1     	:= 1;
            -- Specifies the AXI Lite clock is asynchronous
            -- 0 = AXI Clocks are Synchronous
            -- 1 = AXI Clocks are Asynchronous
        C_NUM_CE                	: integer                	:= 8           ;
        C_S_AXI_LITE_ADDR_WIDTH     	: integer range 9 to 9   	:= 9           ;
        C_S_AXI_LITE_DATA_WIDTH     	: integer range 32 to 32 	:= 32
    );
    port (
        -----------------------------------------------------------------------         --
        -- AXI Lite Control Interface                                                   --
        -----------------------------------------------------------------------         --
        s_axi_lite_aclk             : in  std_logic                         ;           --
        s_axi_lite_aresetn          : in  std_logic                         ;           --

        m_axi_mm2s_aclk             : in  std_logic                                 ;       --
        mm2s_hrd_resetn             : in  std_logic                                 ;       --


        m_axi_s2mm_aclk             : in  std_logic                                 ;       --
        s2mm_hrd_resetn             : in  std_logic                                 ;       --

                                                                                       --
        -- AXI Lite Write Address Channel                                               --
        s_axi_lite_awvalid          : in  std_logic                         ;           --
        s_axi_lite_awready          : out std_logic                         ;           --
        s_axi_lite_awaddr           : in  std_logic_vector                              --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);           --
                                                                                        --
        -- AXI Lite Write Data Channel                                                  --
        s_axi_lite_wvalid           : in  std_logic                         ;           --
        s_axi_lite_wready           : out std_logic                         ;           --
        s_axi_lite_wdata            : in  std_logic_vector                              --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);           --
                                                                                        --
        -- AXI Lite Write Response Channel                                              --
        s_axi_lite_bresp            : out std_logic_vector(1 downto 0)      ;           --
        s_axi_lite_bvalid           : out std_logic                         ;           --
        s_axi_lite_bready           : in  std_logic                         ;           --
                                                                                        --
        -- AXI Lite Read Address Channel                                                --
        s_axi_lite_arvalid          : in  std_logic                         ;           --
        s_axi_lite_arready          : out std_logic                         ;           --
        s_axi_lite_araddr           : in  std_logic_vector                              --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);           --
        s_axi_lite_rvalid           : out std_logic                         ;           --
        s_axi_lite_rready           : in  std_logic                         ;           --
        s_axi_lite_rdata            : out std_logic_vector                              --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);           --
        s_axi_lite_rresp            : out std_logic_vector(1 downto 0)      ;           --
                                                                                        --
        axi2ip_lite_rdaddr          : out std_logic_vector                              --
                                    (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);           --
        -- MM2S Reg Interface  signals                                                          --
        mm2s_axi2ip_wrdata          : out std_logic_vector                              --
                                    (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);           --
        mm2s_axi2ip_wrce            : out std_logic_vector                              --
                                    (C_NUM_CE-1 downto 0)               ;           --
        mm2s_ip2axi_rddata          : in std_logic_vector                               --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  ;          --
        mm2s_axi2ip_rdaddr          : out std_logic_vector                              --
                                    (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);           --

        -- S2MM Reg Interface  signals                                                          --
        s2mm_axi2ip_wrdata          : out std_logic_vector                              --
                                    (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);           --
        s2mm_axi2ip_wrce            : out std_logic_vector                              --
                                    (C_NUM_CE-1 downto 0)               ;           --
        s2mm_ip2axi_rddata          : in std_logic_vector                               --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  ;          --
        s2mm_axi2ip_rdaddr          : out std_logic_vector                              --
                                    (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);           --


        axi2ip_common_region_1_rden : out std_logic                         ;           --
        axi2ip_common_region_2_rden : out std_logic                         ;           --
                                                                                        --
                                                                                        --
        ip2axi_rddata_common_region : in std_logic_vector                               --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)            --
    );
end axi_vdma_lite_if;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_lite_if is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Register I/F Address offset
constant ADDR_OFFSET    : integer := clog2(C_S_AXI_LITE_DATA_WIDTH/8);
-- Register I/F CE number
constant CE_ADDR_SIZE   : integer := clog2(C_NUM_CE);

constant ZERO_VALUE_VECT    : std_logic_vector(128 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- AXI Lite slave interface signals
signal awvalid              				: std_logic := '0';
signal wvalid               				: std_logic := '0';
signal arvalid              				: std_logic := '0';
signal awaddr               : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal wdata                : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');


signal araddr               : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');



signal mm2s_ip2axi_rddata_d1           : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) :=(others => '0');
signal s2mm_ip2axi_rddata_d1           : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) :=(others => '0');

signal write_response_accepted     			: std_logic := '0';
signal write_has_started     				: std_logic := '0';


signal awready_out_i            			: std_logic := '0';
signal wready_out_i            				: std_logic := '0';
signal wrce_gen                 			: std_logic_vector(C_NUM_CE-1 downto 0);
signal bvalid_out_i             			: std_logic := '0';



signal read_data_res_accepted     			: std_logic := '0';
signal read_has_started_i     				: std_logic := '0';
signal sig_arvalid_arrived		     		: std_logic := '0';
signal sig_arvalid_arrived_d1		     		: std_logic := '0';
signal sig_arvalid_arrived_d2		     		: std_logic := '0';
signal sig_arvalid_arrived_d3		     		: std_logic := '0';
signal sig_arvalid_arrived_d4		     		: std_logic := '0';
signal sig_arvalid_detected		     		: std_logic := '0';


signal arready_out_i_cmb            			: std_logic := '0';
signal arready_out_i            			: std_logic := '0';
signal arready_out_i_mm2s            			: std_logic := '0';
signal arready_out_i_s2mm            			: std_logic := '0';
signal arready_out_i_common            			: std_logic := '0';
signal rvalid_out_i             			: std_logic := '0';


----Async_mode

signal wready_out_to_bvalid            				: std_logic := '0'; 
signal mm2s_wrce_gen                 				: std_logic_vector(C_NUM_CE-1 downto 0);
signal s2mm_wrce_gen                 				: std_logic_vector(C_NUM_CE-1 downto 0);


signal addr_region_mm2s_rden_cmb		     		: std_logic := '0';
signal addr_region_s2mm_rden_cmb		     		: std_logic := '0';
signal addr_region_1_common_rden_cmb			     	: std_logic := '0';
signal addr_region_2_common_rden_cmb			     	: std_logic := '0';

signal ip2axi_rddata_captured					: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');                         	--
signal ip2axi_rddata_captured_d1				: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');                         	--
signal ip2axi_rddata_captured_mm2s_cdc_tig			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');                         	--
signal ip2axi_rddata_captured_s2mm_cdc_tig			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');                         	--
signal axi2ip_rdaddr_captured					: std_logic_vector(7 downto 2)  := (others => '0');                         	--
--signal axi2ip_rdaddr_captured_mm2s_cdc_tig			: std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0');                         	--
--signal axi2ip_rdaddr_captured_s2mm_cdc_tig			: std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0');                         	--
signal axi2ip_rdaddr_captured_mm2s_cdc_tig			: std_logic_vector(7 downto 2)  := (others => '0');                         	--
signal axi2ip_rdaddr_captured_s2mm_cdc_tig			: std_logic_vector(7 downto 2)  := (others => '0');                         	--
signal axi2ip_wraddr_captured					: std_logic_vector(7 downto 2)  := (others => '0');                         	--
--signal axi2ip_wraddr_captured_mm2s_cdc_tig			: std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0');                         	--
--signal axi2ip_wraddr_captured_s2mm_cdc_tig			: std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0)  := (others => '0');                         	--
signal axi2ip_wraddr_captured_mm2s_cdc_tig			: std_logic_vector(7 downto 2)  := (others => '0');                         	--
signal axi2ip_wraddr_captured_s2mm_cdc_tig			: std_logic_vector(7 downto 2)  := (others => '0');                         	--
signal arready_out_i_d1            				: std_logic := '0';


signal sig_awvalid_arrived_d1            			: std_logic := '0';
signal sig_awvalid_arrived            				: std_logic := '0';
signal sig_awvalid_detected            				: std_logic := '0';
signal sig_wvalid_arrived            				: std_logic := '0';
signal lite_wr_addr_phase_finished_data_phase_started		: std_logic := '0';
signal prepare_wrce            					: std_logic := '0';
signal prepare_wrce_d1            				: std_logic := '0';

signal prepare_wrce_pulse_lite 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d1 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d2 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d3 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d4 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d5 					: std_logic := '0';
signal prepare_wrce_pulse_lite_d6 					: std_logic := '0';
signal prepare_wrce_pulse_mm2s 					: std_logic := '0';
signal prepare_wrce_pulse_s2mm 					: std_logic := '0';
signal wready_mm2s    	        				: std_logic := '0';
signal wready_s2mm    	        				: std_logic := '0';
signal lite_mm2s_wr_done        				: std_logic := '0';
signal lite_s2mm_wr_done        				: std_logic := '0';
signal lite_wr_done	        				: std_logic := '0';
signal lite_wr_done_d1	        				: std_logic := '0';
signal sig_arvalid_arrived_d1_mm2s_rd_lite_domain     		: std_logic := '0';
signal sig_arvalid_arrived_d1_mm2s		     		: std_logic := '0';
signal sig_arvalid_arrived_d1_s2mm_rd_lite_domain     		: std_logic := '0';
signal sig_arvalid_arrived_d1_s2mm		     		: std_logic := '0';


signal mm2s_axi2ip_wrdata_cdc_tig          			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');           --
signal s2mm_axi2ip_wrdata_cdc_tig          			: std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0)  := (others => '0');           --


  ATTRIBUTE async_reg                      : STRING;

  ATTRIBUTE async_reg OF ip2axi_rddata_captured_mm2s_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF ip2axi_rddata_captured_s2mm_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF axi2ip_rdaddr_captured_mm2s_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF axi2ip_rdaddr_captured_s2mm_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF axi2ip_wraddr_captured_mm2s_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF axi2ip_wraddr_captured_s2mm_cdc_tig  : SIGNAL IS "true"; 

  ATTRIBUTE async_reg OF mm2s_axi2ip_wrdata_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF s2mm_axi2ip_wrdata_cdc_tig  : SIGNAL IS "true"; 

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin


s_axi_lite_awready  <= awready_out_i;
s_axi_lite_wready   <= wready_out_i;
s_axi_lite_bvalid   <= bvalid_out_i;

s_axi_lite_arready  <= arready_out_i;
s_axi_lite_rvalid   <= rvalid_out_i;

axi2ip_lite_rdaddr(8)  <= '0';
axi2ip_lite_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);
axi2ip_lite_rdaddr(1)  <= '0';
axi2ip_lite_rdaddr(0)  <= '0';


mm2s_axi2ip_rdaddr(8)  <= '0';
mm2s_axi2ip_rdaddr(1)  <= '0';
mm2s_axi2ip_rdaddr(0)  <= '0';
s2mm_axi2ip_rdaddr(8)  <= '0';
s2mm_axi2ip_rdaddr(1)  <= '0';
s2mm_axi2ip_rdaddr(0)  <= '0';
s_axi_lite_bresp    <= OKAY_RESP;
s_axi_lite_rresp    <= OKAY_RESP;

-------------------------------------------------------------------------------------------------
--------------------------- Register AXI4-LITE Control signals ----------------------------------
-------------------------------------------------------------------------------------------------
REG_INPUTS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                awvalid <=  '0'                 ;
                wvalid  <=  '0'                 ;
                arvalid <=  '0'                 ;
                awaddr  <=  (others => '0')     ;
                wdata   <=  (others => '0')     ;
                araddr  <=  (others => '0')     ;


            else
                awvalid <= s_axi_lite_awvalid   ;
                wvalid  <= s_axi_lite_wvalid    ;
                arvalid <= s_axi_lite_arvalid   ;
                awaddr  <= s_axi_lite_awaddr    ;
                wdata   <= s_axi_lite_wdata     ;
                araddr  <= s_axi_lite_araddr    ;


            end if;
        end if;
    end process REG_INPUTS;


-------------------------------------------------------------------------------
-------------------------------AXI4-LITE WRITE---------------------------------
-------------------------------------------------------------------------------
sig_awvalid_arrived 	<= awvalid;
sig_wvalid_arrived 	<= wvalid;

D1_LITE_WR_ADDR_PHASE_DETECT : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or write_has_started = '1')then
                sig_awvalid_arrived_d1  <= '0';
            else
                sig_awvalid_arrived_d1  <= sig_awvalid_arrived;
            end if;
        end if;
    end process D1_LITE_WR_ADDR_PHASE_DETECT;

AXI4_LITE_WR_STARTED : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or write_response_accepted = '1')then
                write_has_started <= '0';
            elsif(sig_awvalid_detected = '1')then
                write_has_started <= '1';
            end if;
        end if;
    end process AXI4_LITE_WR_STARTED;


sig_awvalid_detected <= sig_awvalid_arrived and not (sig_awvalid_arrived_d1) and not (write_has_started);

--axi2ip_wraddr_captured    <= awaddr when sig_awvalid_detected = '1';
   CAPTURE_AWADDR : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                axi2ip_wraddr_captured(7 downto 2) 	<= (others => '0');
            elsif(sig_awvalid_detected = '1')then
		axi2ip_wraddr_captured(7 downto 2)  <= awaddr(7 downto 2);
            end if;
        end if;
    end process CAPTURE_AWADDR;





   GEN_LITE_AWREADY : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                awready_out_i <= '0';
            else
                awready_out_i <= sig_awvalid_detected;
            end if;
        end if;
    end process GEN_LITE_AWREADY;

   GEN_WR_ADDR_PHASE_TO_DATA_PHASE : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or wready_out_i = '1')then
                lite_wr_addr_phase_finished_data_phase_started <= '0';
            elsif(awready_out_i = '1')then
                lite_wr_addr_phase_finished_data_phase_started <= '1';
            end if;
        end if;
    end process GEN_WR_ADDR_PHASE_TO_DATA_PHASE;


--------------------------------------------------------------------------------------------------
--***** SYNC_MODE
--------------------------------------------------------------------------------------------------
GEN_LITE_IS_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate

prepare_wrce <= sig_wvalid_arrived and lite_wr_addr_phase_finished_data_phase_started;

   GEN_WRCE_PULSE : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
              prepare_wrce_d1   <= '0';
            else
              prepare_wrce_d1   <= prepare_wrce;
            end if;
        end if;
    end process GEN_WRCE_PULSE;



-------------------------------------------------------------------------------
-- Decode and assert proper chip enable per captured axi lite write address
-------------------------------------------------------------------------------
AXI4_LITE_WRCE_GEN: for j in 0 to C_NUM_CE - 1 generate

constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
begin

    wrce_gen(j) <= (prepare_wrce and not prepare_wrce_d1) when axi2ip_wraddr_captured
                                ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                    downto ADDR_OFFSET)

                                = BAR(CE_ADDR_SIZE-1 downto 0)
          else '0';

   end generate AXI4_LITE_WRCE_GEN;

	 mm2s_axi2ip_wrce    <= wrce_gen;
	 s2mm_axi2ip_wrce    <= wrce_gen;



   GEN_LITE_WREADY : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                wready_out_i  <= '0';
            else
                wready_out_i  <= (prepare_wrce and not prepare_wrce_d1);
            end if;
        end if;
    end process GEN_LITE_WREADY;


	wready_out_to_bvalid 	<= wready_out_i;

-------------------------
--*READ
-------------------------

GEN_LITE_ARREADY_SYNC : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                arready_out_i <= '0';
            else
                arready_out_i <= sig_arvalid_arrived_d1;
            end if;
        end if;
    end process GEN_LITE_ARREADY_SYNC;



s_axi_lite_rdata    <= ip2axi_rddata_captured_d1;

   process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_d1 <= ip2axi_rddata_captured;

        end if;
    end process ;





ip2axi_rddata_captured  <=   	ip2axi_rddata_common_region 	when addr_region_1_common_rden_cmb = '1' or addr_region_2_common_rden_cmb = '1'
           		else    mm2s_ip2axi_rddata 		when addr_region_mm2s_rden_cmb = '1'
           		else    s2mm_ip2axi_rddata;

AXI4_LITE_RRESP_PROCESS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then

                rvalid_out_i        		<= '0';

            elsif(rvalid_out_i = '1' and s_axi_lite_rready = '1')then

                rvalid_out_i        		<= '0';

            elsif(arready_out_i = '1')then       

                rvalid_out_i        <= '1';

            end if;
        end if;
    end process AXI4_LITE_RRESP_PROCESS;
-------------------------
--*READ
-------------------------

mm2s_axi2ip_wrdata  <= wdata;
s2mm_axi2ip_wrdata  <= wdata;
mm2s_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);
s2mm_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);

end generate GEN_LITE_IS_SYNC;
--------------------------------------------------------------------------------------------------
--***** SYNC_MODE
--------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------AXI4-LITE READ----------------------------------
-------------------------------------------------------------------------------

sig_arvalid_arrived <= arvalid;

D1_LITE_RD_DETECT : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or read_has_started_i = '1')then
                sig_arvalid_arrived_d1  <= '0';
            else
                sig_arvalid_arrived_d1  <= sig_arvalid_arrived;
            end if;
        end if;
    end process D1_LITE_RD_DETECT;

AXI4_LITE_RD_STARTED : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or read_data_res_accepted = '1')then
                read_has_started_i <= '0';
            elsif(sig_arvalid_detected = '1')then
                read_has_started_i <= '1';
            end if;
        end if;
    end process AXI4_LITE_RD_STARTED;

sig_arvalid_detected 		<= sig_arvalid_arrived and not (sig_arvalid_arrived_d1) and not (read_has_started_i);
read_data_res_accepted 		<= rvalid_out_i and s_axi_lite_rready;

CAPTURE_ARADDR : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                axi2ip_rdaddr_captured(7 downto 2) 	<= (others => '0');
            elsif(sig_arvalid_detected = '1')then
		axi2ip_rdaddr_captured(7 downto 2)  <= araddr(7 downto 2);
            end if;
        end if;
    end process CAPTURE_ARADDR;

-------------------------------------------------------------------------------
-- Decode read_lite_addr MSB to get the region of read access
-------------------------------------------------------------------------------
--*****************************************************************************
-- MM2S_Region_1 	(0x00 to 0x1C)
-- MM2S_Region_2 	(0x50 to 0x9C)
-- S2MM_Region_1 	(0x30 to 0x3C)
-- S2MM_Region_2 	(0xA0 to 0xEC)
-- Common_Region_1 	(0x20 to 0x2C)	(common read only register)
-- Common_Region_2 	(0xF0 to 0xFC)	(s2mm read-only registers)
--*****************************************************************************


 
	addr_region_1_common_rden_cmb <= ((not axi2ip_rdaddr_captured(7)) and (not axi2ip_rdaddr_captured(6)) and (axi2ip_rdaddr_captured(5)) and (not axi2ip_rdaddr_captured(4)));

	addr_region_2_common_rden_cmb <=     (axi2ip_rdaddr_captured(7) and     axi2ip_rdaddr_captured(6) and axi2ip_rdaddr_captured(5) and     axi2ip_rdaddr_captured(4));

--MM2S Region read


addr_region_mm2s_rden_cmb <= 	(((not axi2ip_rdaddr_captured(6)) and (not axi2ip_rdaddr_captured(5))) 

					or

				((not axi2ip_rdaddr_captured(7)) and (not axi2ip_rdaddr_captured(5)) and (axi2ip_rdaddr_captured(4)))
					
					or

				((not axi2ip_rdaddr_captured(7)) and (axi2ip_rdaddr_captured(6)) and (axi2ip_rdaddr_captured(5))))

				;


--S2MM Region read


addr_region_s2mm_rden_cmb <= 	(((axi2ip_rdaddr_captured(7)) and (axi2ip_rdaddr_captured(5)) and (not axi2ip_rdaddr_captured(4)))
				
					or

				((not axi2ip_rdaddr_captured(6)) and (axi2ip_rdaddr_captured(5)) and (axi2ip_rdaddr_captured(4)))

					or

				((axi2ip_rdaddr_captured(6)) and (not axi2ip_rdaddr_captured(5)) and (not axi2ip_rdaddr_captured(4)))

					or

				((axi2ip_rdaddr_captured(7)) and (axi2ip_rdaddr_captured(6)) and (not axi2ip_rdaddr_captured(5))));
					

-------------------------------------------------------------------------------
-- Write Response
-------------------------------------------------------------------------------

AXI4_LITE_WRESP_PROCESS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then

                bvalid_out_i        		<= '0';

            elsif(bvalid_out_i = '1' and s_axi_lite_bready = '1')then

                bvalid_out_i        		<= '0';

            elsif(wready_out_to_bvalid = '1')then       

                bvalid_out_i        <= '1';

            end if;
        end if;
    end process AXI4_LITE_WRESP_PROCESS;

write_response_accepted <= bvalid_out_i and s_axi_lite_bready;



  axi2ip_common_region_1_rden <= addr_region_1_common_rden_cmb;

GEN_S2MM_COM_REG2_READ : if C_S2MM_IS = 1 generate

  axi2ip_common_region_2_rden <= addr_region_2_common_rden_cmb;

end generate GEN_S2MM_COM_REG2_READ;

GEN_NO_S2MM_COM_REG2_READ : if C_S2MM_IS = 0 generate

  axi2ip_common_region_2_rden <= '0';

end generate GEN_NO_S2MM_COM_REG2_READ;




--------------------------------------------------------------------------------------------------
--***** ASYNC_MODE
--------------------------------------------------------------------------------------------------

GEN_LITE_IS_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
--Both channels exist and async mode
 GEN_ASYNC_LITE_ACCESS : if C_MM2S_IS = 1  and C_S2MM_IS = 1 generate


prepare_wrce <= sig_wvalid_arrived and lite_wr_addr_phase_finished_data_phase_started;


   GEN_WRCE_PULSE : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
              prepare_wrce_d1   <= '0';
            else
              prepare_wrce_d1   <= prepare_wrce;
            end if;
        end if;
    end process GEN_WRCE_PULSE;


prepare_wrce_pulse_lite <= prepare_wrce and not prepare_wrce_d1;

--MM2S

----
----      	LITE_WVALID_MM2S_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----      	    generic map(
----      	        C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----      	        C_VECTOR_WIDTH          => 1 
----      	    )
----      	    port map (
----      	        prmry_aclk              => s_axi_lite_aclk                          ,
----      	        prmry_resetn            => s_axi_lite_aresetn                       ,
----      	        scndry_aclk             => m_axi_mm2s_aclk                          ,
----      	        scndry_resetn           => mm2s_hrd_resetn                          ,
----      	        scndry_in               => '0'                                      ,
----      	        prmry_out               => open                                     ,
----      	        prmry_in                => prepare_wrce_pulse_lite           ,
----      	        scndry_out              => prepare_wrce_pulse_mm2s      ,
----      	        scndry_vect_s_h         => '0'                                      ,
----      	        scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----      	        prmry_vect_out          => open                                     ,
----      	        prmry_vect_s_h          => '0'                                      ,
----      	        prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----      	        scndry_vect_out         => open
----      	    );
----


LITE_WVALID_MM2S_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => s_axi_lite_aresetn, 
        prmry_in                   => prepare_wrce_pulse_lite, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_mm2s_aclk, 
        scndry_resetn              => mm2s_hrd_resetn,
        scndry_out                 => prepare_wrce_pulse_mm2s,
        scndry_vect_out            => open
    );




-------------------------------------------------------------------------------
-- Decode and assert proper chip enable per captured axi lite write address
-------------------------------------------------------------------------------

AXI4_LITE_WRCE_MM2S_GEN: for j in 0 to C_NUM_CE - 1 generate

constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
begin

    mm2s_wrce_gen(j) <= prepare_wrce_pulse_mm2s when axi2ip_wraddr_captured_mm2s_cdc_tig
                                ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                    downto ADDR_OFFSET)

                                = BAR(CE_ADDR_SIZE-1 downto 0)
          else '0';

   end generate AXI4_LITE_WRCE_MM2S_GEN;


mm2s_axi2ip_wrce     <= mm2s_wrce_gen;


--S2MM


----      	LITE_WVALID_S2MM_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----      	    generic map(
----      	        C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----      	        C_VECTOR_WIDTH          => 1 
----      	    )
----      	    port map (
----      	        prmry_aclk              => s_axi_lite_aclk                          ,
----      	        prmry_resetn            => s_axi_lite_aresetn                       ,
----      	        scndry_aclk             => m_axi_s2mm_aclk                          ,
----      	        scndry_resetn           => s2mm_hrd_resetn                          ,
----      	        scndry_in               => '0'                                      ,
----      	        prmry_out               => open                                     ,
----      	        prmry_in                => prepare_wrce_pulse_lite           ,
----      	        scndry_out              => prepare_wrce_pulse_s2mm      ,
----      	        scndry_vect_s_h         => '0'                                      ,
----      	        scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----      	        prmry_vect_out          => open                                     ,
----      	        prmry_vect_s_h          => '0'                                      ,
----      	        prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----      	        scndry_vect_out         => open
----      	    );
----


LITE_WVALID_S2MM_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => s_axi_lite_aresetn, 
        prmry_in                   => prepare_wrce_pulse_lite, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_s2mm_aclk, 
        scndry_resetn              => s2mm_hrd_resetn,
        scndry_out                 => prepare_wrce_pulse_s2mm,
        scndry_vect_out            => open
    );






-------------------------------------------------------------------------------
-- Decode and assert proper chip enable per captured axi lite write address
-------------------------------------------------------------------------------

AXI4_LITE_WRCE_S2MM_GEN: for j in 0 to C_NUM_CE - 1 generate

constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
begin

    s2mm_wrce_gen(j) <= prepare_wrce_pulse_s2mm when axi2ip_wraddr_captured_s2mm_cdc_tig
                                ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                    downto ADDR_OFFSET)

                                = BAR(CE_ADDR_SIZE-1 downto 0)
          else '0';

   end generate AXI4_LITE_WRCE_S2MM_GEN;


s2mm_axi2ip_wrce     <= s2mm_wrce_gen;



   GEN_LITE_WREADY_OUT_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
        	prepare_wrce_pulse_lite_d1  <= prepare_wrce_pulse_lite;
        	prepare_wrce_pulse_lite_d2  <= prepare_wrce_pulse_lite_d1;
        	prepare_wrce_pulse_lite_d3  <= prepare_wrce_pulse_lite_d2;
        	prepare_wrce_pulse_lite_d4  <= prepare_wrce_pulse_lite_d3;
        	prepare_wrce_pulse_lite_d5  <= prepare_wrce_pulse_lite_d4;
        	prepare_wrce_pulse_lite_d6  <= prepare_wrce_pulse_lite_d5;
        end if;
    end process GEN_LITE_WREADY_OUT_D;



   GEN_LITE_WREADY_OUT : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
        	wready_out_i  		    <= '0';
            else
        	wready_out_i  		    <= prepare_wrce_pulse_lite_d6;
            end if;
        end if;
    end process GEN_LITE_WREADY_OUT;




	wready_out_to_bvalid 	<= wready_out_i;

-------------------------
--*READ
-------------------------

--MM2S

GEN_LITE_ARREADY_ASYNC_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                sig_arvalid_arrived_d2 <= sig_arvalid_arrived_d1;
                sig_arvalid_arrived_d3 <= sig_arvalid_arrived_d2;
                sig_arvalid_arrived_d4 <= sig_arvalid_arrived_d3;
        end if;
    end process GEN_LITE_ARREADY_ASYNC_D;


GEN_LITE_ARREADY_ASYNC : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                arready_out_i     <= '0';
            else
                arready_out_i     <= sig_arvalid_arrived_d4;
            end if;
        end if;
    end process GEN_LITE_ARREADY_ASYNC;




AXI4_LITE_RRESP_ASYNC_PROCESS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then

                rvalid_out_i        		<= '0';

            elsif(rvalid_out_i = '1' and s_axi_lite_rready = '1')then

                rvalid_out_i        		<= '0';

            elsif(arready_out_i = '1')then       

                rvalid_out_i        <= '1';

            end if;
        end if;
    end process AXI4_LITE_RRESP_ASYNC_PROCESS;



s_axi_lite_rdata    <= ip2axi_rddata_captured_d1;

   process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_d1 <= ip2axi_rddata_captured;

        end if;
    end process ;



ip2axi_rddata_captured  <=   	ip2axi_rddata_common_region 			when addr_region_1_common_rden_cmb = '1' or addr_region_2_common_rden_cmb = '1'
           		else    ip2axi_rddata_captured_mm2s_cdc_tig 		when addr_region_mm2s_rden_cmb = '1'
           		else    ip2axi_rddata_captured_s2mm_cdc_tig;






   process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	   mm2s_ip2axi_rddata_d1 <= mm2s_ip2axi_rddata;

        end if;
    end process ;


GEN_LITE_MM2S_RDATA_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_mm2s_cdc_tig <= mm2s_ip2axi_rddata_d1;

        end if;
    end process GEN_LITE_MM2S_RDATA_CROSSING;




   process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	   s2mm_ip2axi_rddata_d1 <= s2mm_ip2axi_rddata;

        end if;
    end process ;


GEN_LITE_S2MM_RDATA_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_s2mm_cdc_tig <= s2mm_ip2axi_rddata_d1;

        end if;
    end process GEN_LITE_S2MM_RDATA_CROSSING;




GEN_LITE_MM2S_WDATA_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	   mm2s_axi2ip_wrdata_cdc_tig  <= wdata;

        end if;
    end process GEN_LITE_MM2S_WDATA_CROSSING;



GEN_LITE_S2MM_WDATA_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	   s2mm_axi2ip_wrdata_cdc_tig  <= wdata;

        end if;
    end process GEN_LITE_S2MM_WDATA_CROSSING;




mm2s_axi2ip_wrdata  <= mm2s_axi2ip_wrdata_cdc_tig;
s2mm_axi2ip_wrdata  <= s2mm_axi2ip_wrdata_cdc_tig;



GEN_LITE_MM2S_RDADDR_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	  axi2ip_rdaddr_captured_mm2s_cdc_tig(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_MM2S_RDADDR_CROSSING;



GEN_LITE_S2MM_RDADDR_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	  axi2ip_rdaddr_captured_s2mm_cdc_tig(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_S2MM_RDADDR_CROSSING;



mm2s_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured_mm2s_cdc_tig(7 downto 2);
s2mm_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured_s2mm_cdc_tig(7 downto 2);


GEN_LITE_MM2S_WRADDR_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	  axi2ip_wraddr_captured_mm2s_cdc_tig(7 downto 2)  <= axi2ip_wraddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_MM2S_WRADDR_CROSSING;



GEN_LITE_S2MM_WRADDR_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	  axi2ip_wraddr_captured_s2mm_cdc_tig(7 downto 2)  <= axi2ip_wraddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_S2MM_WRADDR_CROSSING;






 end generate GEN_ASYNC_LITE_ACCESS;

--------------------------------------------
--ASYNC_MODE but only single channel enabled 
--------------------------------------------

GEN_S2MM_ONLY_ASYNC_LITE_ACCESS : if C_MM2S_IS = 0  and C_S2MM_IS = 1 generate

--Write
prepare_wrce <= sig_wvalid_arrived and lite_wr_addr_phase_finished_data_phase_started;


   GEN_WRCE_PULSE : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
              prepare_wrce_d1   <= '0';
            else
              prepare_wrce_d1   <= prepare_wrce;
            end if;
        end if;
    end process GEN_WRCE_PULSE;


prepare_wrce_pulse_lite <= prepare_wrce and not prepare_wrce_d1;

--S2MM


----      	LITE_WVALID_S2MM_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----      	    generic map(
----      	        C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----      	        C_VECTOR_WIDTH          => 1 
----      	    )
----      	    port map (
----      	        prmry_aclk              => s_axi_lite_aclk                          ,
----      	        prmry_resetn            => s_axi_lite_aresetn                       ,
----      	        scndry_aclk             => m_axi_s2mm_aclk                          ,
----      	        scndry_resetn           => s2mm_hrd_resetn                          ,
----      	        scndry_in               => '0'                                      ,
----      	        prmry_out               => open                                     ,
----      	        prmry_in                => prepare_wrce_pulse_lite           ,
----      	        scndry_out              => prepare_wrce_pulse_s2mm      ,
----      	        scndry_vect_s_h         => '0'                                      ,
----      	        scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----      	        prmry_vect_out          => open                                     ,
----      	        prmry_vect_s_h          => '0'                                      ,
----      	        prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----      	        scndry_vect_out         => open
----      	    );



LITE_WVALID_S2MM_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => s_axi_lite_aresetn, 
        prmry_in                   => prepare_wrce_pulse_lite, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_s2mm_aclk, 
        scndry_resetn              => s2mm_hrd_resetn,
        scndry_out                 => prepare_wrce_pulse_s2mm,
        scndry_vect_out            => open
    );




-------------------------------------------------------------------------------
-- Decode and assert proper chip enable per captured axi lite write address
-------------------------------------------------------------------------------

AXI4_LITE_WRCE_S2MM_GEN: for j in 0 to C_NUM_CE - 1 generate

constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
begin

    s2mm_wrce_gen(j) <= prepare_wrce_pulse_s2mm when axi2ip_wraddr_captured_s2mm_cdc_tig
                                ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                    downto ADDR_OFFSET)

                                = BAR(CE_ADDR_SIZE-1 downto 0)
          else '0';

   end generate AXI4_LITE_WRCE_S2MM_GEN;


s2mm_axi2ip_wrce     <= s2mm_wrce_gen;


   GEN_LITE_WREADY_OUT_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
        	prepare_wrce_pulse_lite_d1  <= prepare_wrce_pulse_lite;
        	prepare_wrce_pulse_lite_d2  <= prepare_wrce_pulse_lite_d1;
        	prepare_wrce_pulse_lite_d3  <= prepare_wrce_pulse_lite_d2;
        	prepare_wrce_pulse_lite_d4  <= prepare_wrce_pulse_lite_d3;
        	prepare_wrce_pulse_lite_d5  <= prepare_wrce_pulse_lite_d4;
        	prepare_wrce_pulse_lite_d6  <= prepare_wrce_pulse_lite_d5;
        end if;
    end process GEN_LITE_WREADY_OUT_D;



   GEN_LITE_WREADY_OUT : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
        	wready_out_i  		    <= '0';
            else
        	wready_out_i  		    <= prepare_wrce_pulse_lite_d6;
            end if;
        end if;
    end process GEN_LITE_WREADY_OUT;



	wready_out_to_bvalid 	<= wready_out_i;

--Read

--S2MM

GEN_LITE_ARREADY_ASYNC_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                sig_arvalid_arrived_d2 <= sig_arvalid_arrived_d1;
                sig_arvalid_arrived_d3 <= sig_arvalid_arrived_d2;
                sig_arvalid_arrived_d4 <= sig_arvalid_arrived_d3;
        end if;
    end process GEN_LITE_ARREADY_ASYNC_D;


GEN_LITE_ARREADY_ASYNC : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                arready_out_i     <= '0';
            else
                arready_out_i     <= sig_arvalid_arrived_d4;
            end if;
        end if;
    end process GEN_LITE_ARREADY_ASYNC;



AXI4_LITE_RRESP_ASYNC_PROCESS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then

                rvalid_out_i        		<= '0';

            elsif(rvalid_out_i = '1' and s_axi_lite_rready = '1')then

                rvalid_out_i        		<= '0';

            elsif(arready_out_i = '1')then       

                rvalid_out_i        <= '1';

            end if;
        end if;
    end process AXI4_LITE_RRESP_ASYNC_PROCESS;


s_axi_lite_rdata    <= ip2axi_rddata_captured_d1;

   process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_d1 <= ip2axi_rddata_captured;

        end if;
    end process ;


ip2axi_rddata_captured  <=   	ip2axi_rddata_common_region 	when addr_region_1_common_rden_cmb = '1' or addr_region_2_common_rden_cmb = '1'
           		else    mm2s_ip2axi_rddata 		when addr_region_mm2s_rden_cmb = '1'
           		else    ip2axi_rddata_captured_s2mm_cdc_tig;


   process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	   s2mm_ip2axi_rddata_d1 <= s2mm_ip2axi_rddata;

        end if;
    end process ;


GEN_LITE_S2MM_RDATA_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_s2mm_cdc_tig <= s2mm_ip2axi_rddata_d1;

        end if;
    end process GEN_LITE_S2MM_RDATA_CROSSING;







   mm2s_axi2ip_wrdata  <= wdata;

GEN_LITE_S2MM_WDATA_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	   s2mm_axi2ip_wrdata_cdc_tig  <= wdata;

        end if;
    end process GEN_LITE_S2MM_WDATA_CROSSING;


s2mm_axi2ip_wrdata  <= s2mm_axi2ip_wrdata_cdc_tig;





GEN_LITE_S2MM_RDADDR_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	  axi2ip_rdaddr_captured_s2mm_cdc_tig(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_S2MM_RDADDR_CROSSING;



mm2s_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);
s2mm_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured_s2mm_cdc_tig(7 downto 2);

GEN_LITE_S2MM_WRADDR_CROSSING : process(m_axi_s2mm_aclk)
    begin
        if(m_axi_s2mm_aclk'EVENT and m_axi_s2mm_aclk = '1')then

	  axi2ip_wraddr_captured_s2mm_cdc_tig(7 downto 2)  <= axi2ip_wraddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_S2MM_WRADDR_CROSSING;




mm2s_axi2ip_wrce     <= (others => '0');

 end generate GEN_S2MM_ONLY_ASYNC_LITE_ACCESS;





GEN_MM2S_ONLY_ASYNC_LITE_ACCESS : if C_MM2S_IS = 1  and C_S2MM_IS = 0 generate

--Write
prepare_wrce <= sig_wvalid_arrived and lite_wr_addr_phase_finished_data_phase_started;


   GEN_WRCE_PULSE : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
              prepare_wrce_d1   <= '0';
            else
              prepare_wrce_d1   <= prepare_wrce;
            end if;
        end if;
    end process GEN_WRCE_PULSE;


prepare_wrce_pulse_lite <= prepare_wrce and not prepare_wrce_d1;

--MM2S


----      	LITE_WVALID_MM2S_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----      	    generic map(
----      	        C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----      	        C_VECTOR_WIDTH          => 1 
----      	    )
----      	    port map (
----      	        prmry_aclk              => s_axi_lite_aclk                          ,
----      	        prmry_resetn            => s_axi_lite_aresetn                       ,
----      	        scndry_aclk             => m_axi_mm2s_aclk                          ,
----      	        scndry_resetn           => mm2s_hrd_resetn                          ,
----      	        scndry_in               => '0'                                      ,
----      	        prmry_out               => open                                     ,
----      	        prmry_in                => prepare_wrce_pulse_lite           ,
----      	        scndry_out              => prepare_wrce_pulse_mm2s      ,
----      	        scndry_vect_s_h         => '0'                                      ,
----      	        scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----      	        prmry_vect_out          => open                                     ,
----      	        prmry_vect_s_h          => '0'                                      ,
----      	        prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----      	        scndry_vect_out         => open
----      	    );


LITE_WVALID_MM2S_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axi_lite_aclk,
        prmry_resetn               => s_axi_lite_aresetn, 
        prmry_in                   => prepare_wrce_pulse_lite, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axi_mm2s_aclk, 
        scndry_resetn              => mm2s_hrd_resetn,
        scndry_out                 => prepare_wrce_pulse_mm2s,
        scndry_vect_out            => open
    );



-------------------------------------------------------------------------------
-- Decode and assert proper chip enable per captured axi lite write address
-------------------------------------------------------------------------------

AXI4_LITE_WRCE_MM2S_GEN: for j in 0 to C_NUM_CE - 1 generate

constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
begin

    mm2s_wrce_gen(j) <= prepare_wrce_pulse_mm2s when axi2ip_wraddr_captured_mm2s_cdc_tig
                                ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                    downto ADDR_OFFSET)

                                = BAR(CE_ADDR_SIZE-1 downto 0)
          else '0';

   end generate AXI4_LITE_WRCE_MM2S_GEN;


mm2s_axi2ip_wrce     <= mm2s_wrce_gen;

   GEN_LITE_WREADY_OUT_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
        	prepare_wrce_pulse_lite_d1  <= prepare_wrce_pulse_lite;
        	prepare_wrce_pulse_lite_d2  <= prepare_wrce_pulse_lite_d1;
        	prepare_wrce_pulse_lite_d3  <= prepare_wrce_pulse_lite_d2;
        	prepare_wrce_pulse_lite_d4  <= prepare_wrce_pulse_lite_d3;
        	prepare_wrce_pulse_lite_d5  <= prepare_wrce_pulse_lite_d4;
        	prepare_wrce_pulse_lite_d6  <= prepare_wrce_pulse_lite_d5;
        end if;
    end process GEN_LITE_WREADY_OUT_D;



   GEN_LITE_WREADY_OUT : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
        	wready_out_i  		    <= '0';
            else
        	wready_out_i  		    <= prepare_wrce_pulse_lite_d6;
            end if;
        end if;
    end process GEN_LITE_WREADY_OUT;


	wready_out_to_bvalid 	<= wready_out_i;

--Read

--MM2S

GEN_LITE_ARREADY_ASYNC_D : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                sig_arvalid_arrived_d2 <= sig_arvalid_arrived_d1;
                sig_arvalid_arrived_d3 <= sig_arvalid_arrived_d2;
                sig_arvalid_arrived_d4 <= sig_arvalid_arrived_d3;
        end if;
    end process GEN_LITE_ARREADY_ASYNC_D;


GEN_LITE_ARREADY_ASYNC : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                arready_out_i     <= '0';
            else
                arready_out_i     <= sig_arvalid_arrived_d4;
            end if;
        end if;
    end process GEN_LITE_ARREADY_ASYNC;


AXI4_LITE_RRESP_ASYNC_PROCESS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then

                rvalid_out_i        		<= '0';

            elsif(rvalid_out_i = '1' and s_axi_lite_rready = '1')then

                rvalid_out_i        		<= '0';

            elsif(arready_out_i = '1')then       

                rvalid_out_i        <= '1';

            end if;
        end if;
    end process AXI4_LITE_RRESP_ASYNC_PROCESS;


s_axi_lite_rdata    <= ip2axi_rddata_captured_d1;

   process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_d1 <= ip2axi_rddata_captured;

        end if;
    end process ;


ip2axi_rddata_captured  <=   	ip2axi_rddata_common_region 			when addr_region_1_common_rden_cmb = '1' or addr_region_2_common_rden_cmb = '1'
           		else    ip2axi_rddata_captured_mm2s_cdc_tig 		when addr_region_mm2s_rden_cmb = '1'
           		else    s2mm_ip2axi_rddata;

   process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	   mm2s_ip2axi_rddata_d1 <= mm2s_ip2axi_rddata;

        end if;
    end process ;


GEN_LITE_MM2S_RDATA_CROSSING : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then

	   ip2axi_rddata_captured_mm2s_cdc_tig <= mm2s_ip2axi_rddata_d1;

        end if;
    end process GEN_LITE_MM2S_RDATA_CROSSING;




GEN_LITE_MM2S_WDATA_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	   mm2s_axi2ip_wrdata_cdc_tig  <= wdata;

        end if;
    end process GEN_LITE_MM2S_WDATA_CROSSING;



  s2mm_axi2ip_wrdata  <= wdata;

mm2s_axi2ip_wrdata  <= mm2s_axi2ip_wrdata_cdc_tig;



GEN_LITE_MM2S_RDADDR_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	  axi2ip_rdaddr_captured_mm2s_cdc_tig(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_MM2S_RDADDR_CROSSING;


mm2s_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured_mm2s_cdc_tig(7 downto 2);
s2mm_axi2ip_rdaddr(7 downto 2)  <= axi2ip_rdaddr_captured(7 downto 2);


GEN_LITE_MM2S_WRADDR_CROSSING : process(m_axi_mm2s_aclk)
    begin
        if(m_axi_mm2s_aclk'EVENT and m_axi_mm2s_aclk = '1')then

	  axi2ip_wraddr_captured_mm2s_cdc_tig(7 downto 2)  <= axi2ip_wraddr_captured(7 downto 2);

        end if;
    end process GEN_LITE_MM2S_WRADDR_CROSSING;


s2mm_axi2ip_wrce     <= (others => '0');
 end generate GEN_MM2S_ONLY_ASYNC_LITE_ACCESS;





end generate GEN_LITE_IS_ASYNC;
end implementation;
