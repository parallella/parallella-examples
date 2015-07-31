-------------------------------------------------------------------------------
-- axi_vdma_s2mm_linebuf
-------------------------------------------------------------------------------
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
-- Filename:          axi_vdma_s2mm_linebuf.vhd
-- Description: This entity encompases the line buffer logic
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

library lib_cdc_v1_0;
library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

-------------------------------------------------------------------------------
entity  axi_vdma_s2mm_linebuf is
    generic (
        C_DATA_WIDTH                	: integer range 8 to 1024           	:= 32;
            -- Line Buffer Data Width
        C_INCLUDE_S2MM_DRE              : integer range 0 to 1      	:= 0;


        C_S2MM_SOF_ENABLE               : integer range 0 to 1      		:= 0;
            -- Enable/Disable start of frame generation on tuser(0). This
            -- is only valid for external frame sync (C_USE_FSYNC = 1)
            -- 0 = disable SOF
            -- 1 = enable SOF

        C_S_AXIS_S2MM_TUSER_BITS        : integer range 1 to 1      		:= 1;
            -- Slave AXI Stream User Width for S2MM Channel

        C_TOPLVL_LINEBUFFER_DEPTH   	: integer range 0 to 65536          	:= 512; -- CR625142
            -- Depth as set by user at top level parameter

        C_LINEBUFFER_DEPTH          	: integer range 0 to 65536          	:= 512;
            -- Linebuffer depth in Bytes. Must be a power of 2

        C_LINEBUFFER_AF_THRESH       	: integer range 1 to 65536         	:= 1;
            -- Linebuffer almost full threshold in Bytes. Must be a power of 2

        C_PRMRY_IS_ACLK_ASYNC       	: integer range 0 to 1              	:= 0 ;
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - Primary data path channels (MM2S and S2MM)
            --                            run asynchronous to AXI Lite, DMA Control,
            --                            and SG.
        ENABLE_FLUSH_ON_FSYNC      	: integer range 0 to 1        		:= 0      ;
        C_USE_S2MM_FSYNC                : integer range 0 to 2      	:= 2; --2013.1
        C_USE_FSYNC                 	: integer range 0 to 1      		:= 0;               
        C_INCLUDE_MM2S       		: integer range 0 to 1        		:= 0      ;
        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 1;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers
 
        --C_ENABLE_DEBUG_INFO             : string := "1111111111111111";		-- 1 to 16 -- 
        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '1');		--15 downto 0  -- 
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
        

        C_FAMILY                    : string            			:= "virtex7"
            -- Device family used for proper BRAM selection
    );
    port (
        s_axis_aclk                 : in  std_logic                         ;       --
        s_axis_resetn               : in  std_logic                         ;       --
                                                                                    --
        m_axis_aclk                 : in  std_logic                         ;       --
        m_axis_resetn               : in  std_logic                         ;       --
                                                                                    --
        s2mm_axis_linebuf_reset_out : out  std_logic                         ;   --
                                                                                    --
        strm_not_finished           : in  std_logic                         ;       --
        -- Graceful shut down control                                               --
        run_stop                    : in  std_logic                         ;       --
        dm_halt                     : in  std_logic                         ;       -- CR591965
        dm_halt_cmplt               : in  std_logic                         ;       -- CR591965
        s2mm_fsize_mismatch_err_s   : in  std_logic                         ;       -- CR591965
        s2mm_fsize_mismatch_err     : in  std_logic                         ;       -- CR591965
                                                                                    --
        -- Line Tracking Control                                                    --
        crnt_vsize                  : in  std_logic_vector                          -- CR575884
                                        (VSIZE_DWIDTH-1 downto 0)           ;       -- CR575884
        crnt_vsize_d2_s             : out  std_logic_vector                          -- CR575884
                                        (VSIZE_DWIDTH-1 downto 0)           ;       -- CR575884
        chnl_ready_external         : in  std_logic                         ;       -- CR575884
        s2mm_fsync_core             : out  std_logic                         ;       -- CR575884
        s2mm_fsync                  : in  std_logic                         ;       -- CR575884
        s2mm_tuser_fsync_top        : in  std_logic                         ;       -- CR575884
 
        mm2s_axis_resetn            : in  std_logic           := '1'              ;                   --
        m_axis_mm2s_aclk            : in  std_logic           := '0'              ;                   --
        mm2s_fsync                  : in  std_logic                         ;           --
        fsync_src_select            : in  std_logic_vector(1 downto 0)      ;           --
        fsync_src_select_s          : out  std_logic_vector(1 downto 0)      ;           --
        drop_fsync_d_pulse_gen_fsize_less_err  : out  std_logic      ;           --
        hold_dummy_tready_low       : out  std_logic      ;           --
        hold_dummy_tready_low2      : out  std_logic      ;           --


        s2mm_dmasr_fsize_less_err   : in  std_logic                         ;       --

   no_fsync_before_vsize_sel_00_01  : in  std_logic                         ;       -- CR575884
       s2mm_fsize_mismatch_err_flag : in  std_logic                         ;       -- CR575884
        fsync_out_m                 : out  std_logic                         ;       -- CR575884
        fsync_out                   : in  std_logic                         ;       -- CR575884
        frame_sync                  : in  std_logic                         ;       -- CR575884
                                                                                    --
        -- Line Buffer Threshold                                                    --
        linebuf_threshold           : in  std_logic_vector                          --
                                        (LINEBUFFER_THRESH_WIDTH-1 downto 0);       --
        -- Stream In                                                                --
        s_axis_tdata                : in  std_logic_vector                          --
                                        (C_DATA_WIDTH-1 downto 0)           ;       --
        s_axis_tkeep                : in  std_logic_vector                          --
                                        ((C_DATA_WIDTH/8)-1 downto 0)       ;       --
        s_axis_tlast                : in  std_logic                         ;       --
        s_axis_tvalid               : in  std_logic                         ;       --
        s_axis_tready               : out std_logic                         ;       --
        s_axis_tuser                : in  std_logic_vector                          --
                                        (C_S_AXIS_S2MM_TUSER_BITS-1 downto 0);      --
 capture_dm_done_vsize_counter	    : out std_logic_vector(12 downto 0);                                                                                   --
        -- Stream Out                                                               --
        m_axis_tdata                : out std_logic_vector                          --
                                        (C_DATA_WIDTH-1 downto 0)           ;       --
        m_axis_tkeep                : out std_logic_vector                          --
                                        ((C_DATA_WIDTH/8)-1 downto 0)       ;       --
        m_axis_tlast                : out std_logic                         ;       --
        m_axis_tvalid               : out std_logic                         ;       --
        m_axis_tready               : in  std_logic                         ;       --
                                                                                    --
        -- Fifo Status Flags                                                        --
        s2mm_fifo_full              : out std_logic                         ;       --
        s2mm_fifo_almost_full       : out std_logic                         ;       --
        s2mm_all_lines_xfred        : out std_logic                         ;       -- CR591965
        all_lasts_rcvd              : out std_logic			    ;	
        s2mm_tuser_fsync            : out std_logic
    );

end axi_vdma_s2mm_linebuf;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_s2mm_linebuf is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Bufer depth
--constant BUFFER_DEPTH           : integer := max2(128,C_LINEBUFFER_DEPTH/(C_DATA_WIDTH/8));
constant BUFFER_DEPTH           : integer := C_LINEBUFFER_DEPTH;

-- Buffer width is data width + strobe width + 1 bit for tlast
constant BUFFER_WIDTH           : integer := C_DATA_WIDTH + (C_DATA_WIDTH/8)*C_INCLUDE_S2MM_DRE + 1; --tkeep
-- Buffer data count width




constant DATACOUNT_WIDTH        : integer := clog2(BUFFER_DEPTH);

constant USE_BRAM_FIFOS         : integer   := 1; -- Use BRAM FIFOs

-- Constants for line tracking logic
constant VSIZE_ONE_VALUE            : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := std_logic_vector(to_unsigned(1,VSIZE_DWIDTH));
constant VSIZE_TWO_VALUE            : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := std_logic_vector(to_unsigned(2,VSIZE_DWIDTH));


constant VSIZE_ZERO_VALUE           : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := (others => '0');

constant ZERO_VALUE_VECT            : std_logic_vector(255 downto 0) := (others => '0');


-- Linebuffer threshold support
constant THRESHOLD_LSB_INDEX        : integer := clog2((C_DATA_WIDTH/8));

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal fifo_din                     : std_logic_vector(BUFFER_WIDTH - 1 downto 0) := (others => '0');
signal fifo_dout                    : std_logic_vector(BUFFER_WIDTH - 1 downto 0):= (others => '0');
signal fifo_wren                    : std_logic := '0';
signal fifo_rden                    : std_logic := '0';
signal fifo_empty_i                 : std_logic := '0';
signal fifo_full_i                  : std_logic := '0';
signal fifo_ainit                   : std_logic := '0';
signal fifo_wrcount                 : std_logic_vector(DATACOUNT_WIDTH-1 downto 0);
signal fifo_almost_full_i           : std_logic := '0'; -- CR604273/CR604272

signal s_axis_tready_i              : std_logic := '0';
signal s_axis_tvalid_i              : std_logic := '0';
signal s_axis_tlast_i               : std_logic := '0';
signal s_axis_tdata_i               : std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others => '0');
signal s_axis_tkeep_i               : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal s_axis_tkeep_signal          : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal m_axis_tkeep_signal          : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal s_axis_tuser_i               : std_logic_vector(C_S_AXIS_S2MM_TUSER_BITS-1 downto 0) := (others => '0');

signal crnt_vsize_cdc_tig                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal crnt_vsize_d1                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal crnt_vsize_d2                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal vsize_counter                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');
signal decr_vcount                  : std_logic := '0';
signal chnl_ready                   : std_logic := '0';
signal s_axis_tready_out            : std_logic := '0';
signal slv2skid_s_axis_tvalid       : std_logic := '0';
signal data_count_af_threshold_cdc_tig      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal data_count_af_threshold_d1      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal data_count_af_threshold      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal s_data_count_af_thresh       : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal dm_halt_reg                  : std_logic := '0'; -- CR591965
signal run_stop_reg                 : std_logic := '0'; -- CR591965

signal s_axis_fifo_ainit            : std_logic := '0';
signal s_axis_tuser_d1              : std_logic := '0';
signal tuser_fsync                  : std_logic := '0';

signal m_axis_fifo_ainit            : std_logic := '0';                                             -- CR623449
signal done_vsize_counter           : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0'); -- CR623449
signal m_axis_tlast_i               : std_logic := '0';                                             -- CR623449
signal m_axis_tvalid_i              : std_logic := '0';                                             -- CR623449
signal done_decr_vcount             : std_logic := '0';                                             -- CR623449
signal p_fsync_out                  : std_logic := '0';
-- Added for CR626585
signal s2mm_all_lines_xfred_i       : std_logic := '0';
signal s_axis_fifo_ainit_nosync     : std_logic := '0';
signal m_axis_fifo_ainit_nosync     : std_logic := '0';
signal s2mm_axis_linebuf_reset_out_inv : std_logic := '0';
signal s2mm_tuser_fsync_sig         : std_logic := '0';

signal s2mm_dmasr_fsize_less_err_d1 : std_logic := '0';
signal s2mm_dmasr_fsize_less_err_fe : std_logic := '0';

signal wr_rst_busy_sig              : std_logic := '0';
signal rd_rst_busy_sig              : std_logic := '0';                  




  ATTRIBUTE async_reg                      : STRING;
  ATTRIBUTE async_reg OF crnt_vsize_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF crnt_vsize_d1       : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF data_count_af_threshold_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF data_count_af_threshold_d1       : SIGNAL IS "true"; 


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
fsync_out_m <= p_fsync_out;
		s2mm_axis_linebuf_reset_out_inv <=    s_axis_fifo_ainit_nosync        ;


		s2mm_tuser_fsync <=    s2mm_tuser_fsync_sig        ;
		crnt_vsize_d2_s <=    crnt_vsize_d2        ;


s2mm_axis_linebuf_reset_out <=    not(s2mm_axis_linebuf_reset_out_inv)        ;

s_axis_fifo_ainit_nosync <= '1' when (s_axis_resetn = '0')
                           or (dm_halt_reg = '1')                          
                else '0';

m_axis_fifo_ainit_nosync <= '1' when (m_axis_resetn = '0')
                                or (dm_halt = '1')                                            
                else '0';                                                                     



-- fifo ainit in the S_AXIS clock domain
s_axis_fifo_ainit <= '1' when (s_axis_resetn = '0')
                           or (fsync_out = '1')                            -- CR591965
                           or (dm_halt_reg = '1')                          -- CR591965
                else '0';

m_axis_fifo_ainit <= '1' when (m_axis_resetn = '0')
                           or (frame_sync = '1')                                                -- CR623449
                           or (dm_halt = '1')                                                   -- CR623449
                else '0';                                                                       -- CR623449



GEN_VSIZE_SNAPSHOT_LOGIC : if (C_USE_FSYNC = 1 and (C_ENABLE_DEBUG_INFO_12 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate

begin

	S2MM_DMASR_BIT7_D1 : process(m_axis_aclk)
	    begin
	        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
	            if(m_axis_resetn = '0')then
	                s2mm_dmasr_fsize_less_err_d1 <= '0';
	            else
	                s2mm_dmasr_fsize_less_err_d1 <= s2mm_dmasr_fsize_less_err;
	            end if;
	        end if;
	    end process S2MM_DMASR_BIT7_D1;
	
	
	s2mm_dmasr_fsize_less_err_fe <= s2mm_dmasr_fsize_less_err_d1 and not s2mm_dmasr_fsize_less_err;
	
	
	    DM_VSIZE_AT_FSIZE_LESS_ERR : process(m_axis_aclk)
	        begin
	            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
	                if(m_axis_resetn = '0' or s2mm_dmasr_fsize_less_err_fe = '1')then
				
				capture_dm_done_vsize_counter   <= (others => '0');
	
			elsif (s2mm_fsize_mismatch_err = '1' and s2mm_dmasr_fsize_less_err = '0')then
	
				capture_dm_done_vsize_counter   <= done_vsize_counter;
	
	            	end if;
	            end if;
	        end process DM_VSIZE_AT_FSIZE_LESS_ERR;
	

end generate GEN_VSIZE_SNAPSHOT_LOGIC;


GEN_NO_VSIZE_SNAPSHOT_LOGIC : if (C_USE_FSYNC = 0 or (C_ENABLE_DEBUG_INFO_12 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate

begin

	capture_dm_done_vsize_counter <= (others => '0');

end generate GEN_NO_VSIZE_SNAPSHOT_LOGIC;



GEN_S2MM_DRE_ON : if C_INCLUDE_S2MM_DRE = 1 generate
begin

m_axis_tkeep 	    <= m_axis_tkeep_signal;
s_axis_tkeep_signal <= s_axis_tkeep;

end generate GEN_S2MM_DRE_ON;

GEN_S2MM_DRE_OFF : if C_INCLUDE_S2MM_DRE = 0 generate
begin

m_axis_tkeep 	    <= (others => '1');
s_axis_tkeep_signal <= (others => '1');

end generate GEN_S2MM_DRE_OFF;





--*****************************************************************************--
--**              USE FSYNC MODE                         **--
--*****************************************************************************--
GEN_FSYNC_LOGIC : if (ENABLE_FLUSH_ON_FSYNC = 1 and C_S2MM_SOF_ENABLE = 0) generate


    type  STRM_WR_SM_TYPE is (STRM_WR_IDLE,
                              STRM_WR_START,
                              STRM_WR_RUNNING,
                              STRM_WR_LAST
                             );


    signal strm_write_ns            : STRM_WR_SM_TYPE;
    signal strm_write_cs            : STRM_WR_SM_TYPE;

    type  FIFO_RD_SM_TYPE is (FIFO_RD_IDLE,
                       --   FIFO_RD_START,
                              FIFO_RD_RUNNING,
                              FIFO_RD_FSYNC,
                              FIFO_RD_FSYNC_LAST,
                               FIFO_RD_LAST
                             );
    signal fifo_read_ns             : FIFO_RD_SM_TYPE;
    signal fifo_read_cs             : FIFO_RD_SM_TYPE;
    
    signal load_counter             : std_logic := '0';
    signal load_counter_sm          : std_logic := '0';
    signal strm_write_pending_sm    : std_logic := '0';
    signal strm_write_pending       : std_logic := '0';
    signal fifo_rd_pending_sm       : std_logic := '0';
    signal fifo_rd_pending          : std_logic := '0';
    signal stop_tready_sm           : std_logic := '0';
    signal stop_tready              : std_logic := '0';
    signal strm_write_pending_m_axi : std_logic := '0';
    signal stop_tready_s_axi        : std_logic := '0';
    signal dm_halt_frame            : std_logic := '0';    

begin

s2mm_all_lines_xfred <=            s2mm_all_lines_xfred_i;



--*****************************************************************************--
--**              LINE BUFFER MODE (Sync or Async)                           **--
--*****************************************************************************--
GEN_LINEBUFFER : if C_LINEBUFFER_DEPTH /= 0 generate
begin

    -- Divide by number bytes per data beat and add padding to dynamic
    -- threshold setting
    data_count_af_threshold <= linebuf_threshold((DATACOUNT_WIDTH-1) + THRESHOLD_LSB_INDEX
                                            downto THRESHOLD_LSB_INDEX);



    -- Synchronous clock therefore instantiate an Asynchronous FIFO
    GEN_SYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
    begin
               
      

        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_sfifo
            generic map(
                 UW_DATA_WIDTH     => BUFFER_WIDTH        ,
          C_FULL_FLAGS_RST_VAL     => 1        ,
                 UW_FIFO_DEPTH     => BUFFER_DEPTH        ,
                 C_FAMILY          => C_FAMILY
            )
            port map(
                -- Inputs
                 rst               => s_axis_fifo_ainit_nosync   ,
                 sleep             => '0'         ,
                 wr_rst_busy       => wr_rst_busy_sig         ,
                 rd_rst_busy       => rd_rst_busy_sig         ,
                 clk               => s_axis_aclk         ,
                 wr_en             => fifo_wren           ,
                 din               => fifo_din            ,
                 rd_en             => fifo_rden           ,

                -- Outputs
                 dout              => fifo_dout           ,
                 full              => fifo_full_i         ,
                 empty             => fifo_empty_i        ,
                 data_count        => fifo_wrcount  
            );



--wr_rst_busy_sig <= '0';
--rd_rst_busy_sig <= '0';

    end generate GEN_SYNC_FIFO;


    -- Asynchronous clock therefore instantiate an Asynchronous FIFO
    GEN_ASYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
    begin

      
LB_BRAM : if ( (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo
            generic map(
                 UW_DATA_WIDTH   => BUFFER_WIDTH                    ,
          C_FULL_FLAGS_RST_VAL   => 1        ,
                 UW_FIFO_DEPTH   => BUFFER_DEPTH                    ,
                 C_FAMILY        => C_FAMILY
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => open         ,
                 rd_rst_busy     => open         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         ,
                 wr_data_count   => fifo_wrcount         ,
                 rd_data_count   => open                 
            );

wr_rst_busy_sig <= '0';
rd_rst_busy_sig <= '0';
end generate LB_BRAM;                     

      
LB_BUILT_IN : if ( (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo_builtin
            generic map(
                 PL_FIFO_TYPE    => "BUILT_IN"                    ,
                 PL_READ_MODE    => "FWFT"                    ,
                 PL_FASTER_CLOCK => "RD_CLK"                    , --WR_CLK
                 PL_FULL_FLAGS_RST_VAL => 0                     , -- ?
                 PL_DATA_WIDTH   => BUFFER_WIDTH                    ,
                 C_FAMILY        => C_FAMILY ,
                 PL_FIFO_DEPTH   => BUFFER_DEPTH                    
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => wr_rst_busy_sig         ,
                 rd_rst_busy     => rd_rst_busy_sig         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         
            );

end generate LB_BUILT_IN;                     








     end generate GEN_ASYNC_FIFO;

   GEN_S2MM_DRE_ENABLED_TKEEP : if C_INCLUDE_S2MM_DRE = 1 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tkeep_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= fifo_dout(BUFFER_WIDTH-2 downto (BUFFER_WIDTH-2) - (C_DATA_WIDTH/8) + 1);
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;

   end generate GEN_S2MM_DRE_ENABLED_TKEEP;

   GEN_NO_S2MM_DRE_DISABLE_TKEEP : if C_INCLUDE_S2MM_DRE = 0 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= (others => '1');
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;



   end generate GEN_NO_S2MM_DRE_DISABLE_TKEEP;


    -- Top level line buffer depth not equal to zero therefore gererate threshold
    -- flags. (CR625142)



    GEN_THRESHOLD_ENABLED : if C_TOPLVL_LINEBUFFER_DEPTH /= 0  and (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin


------   GEN_THRESHOLD_ENABLED_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
------    begin



        -- Almost full flag
        -- This flag is only used by S2MM and the threshold has been adjusted to allow registering
        -- of the flag for timing and also to assert and deassert from an outside S2MM perspective
      
        REG_ALMST_FULL : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit = '1')then
                        fifo_almost_full_i <= '0';
                    -- write count greater than or equal to threshold value therefore assert thresold flag
                    elsif(fifo_wrcount >= s_data_count_af_thresh or (fifo_full_i='1' or wr_rst_busy_sig = '1')) then
                        fifo_almost_full_i <= '1';
                    -- In all other cases de-assert flag
                    else
                        fifo_almost_full_i <= '0';
                    end if;
                end if;
            end process REG_ALMST_FULL;



        -- Drive fifo flags out if Linebuffer included
        s2mm_fifo_almost_full   <= fifo_almost_full_i or fifo_full_i or wr_rst_busy_sig;
        s2mm_fifo_full          <= fifo_full_i or wr_rst_busy_sig ;





-----    end generate GEN_THRESHOLD_ENABLED_NO_SOF;
-----
-----








    end generate GEN_THRESHOLD_ENABLED;

    -- Top level line buffer depth is zero therefore turn off threshold logic.
    -- this occurs for async operation where the async fifo is needed for CDC (CR625142)
    GEN_THRESHOLD_DISABLED  : if C_TOPLVL_LINEBUFFER_DEPTH = 0  or (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        fifo_almost_full_i      <= '0';
        s2mm_fifo_almost_full   <= '0';
        s2mm_fifo_full          <= '0';
    end generate GEN_THRESHOLD_DISABLED;

   



-----    GEN_MSTR_SKID_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
-----    begin




 --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
----    I_MSTR_SKID : entity axi_vdma_v6_2.axi_vdma_skid_buf
----        generic map(
----            C_WDATA_WIDTH           => C_DATA_WIDTH		,
----            C_TUSER_WIDTH           => C_S_AXIS_S2MM_TUSER_BITS
----
----        )
----        port map(
----            -- System Ports
----            ACLK                   => s_axis_aclk              ,
----            ARST                   => s_axis_fifo_ainit        ,
----
----            -- Shutdown control (assert for 1 clk pulse)
----            skid_stop              => '0'                      ,
----
----            -- Slave Side (Stream Data Input)
----            S_VALID                => slv2skid_s_axis_tvalid   ,
----            S_READY                => s_axis_tready_out        ,
----            S_Data                 => s_axis_tdata             ,
----            S_STRB                 => s_axis_tkeep             ,
----            S_Last                 => s_axis_tlast             ,
----            S_User                 => s_axis_tuser             ,
----
----            -- Master Side (Stream Data Output)
----            M_VALID                => s_axis_tvalid_i          ,
----            M_READY                => s_axis_tready_i          ,
----            M_Data                 => s_axis_tdata_i           ,
----            M_STRB                 => s_axis_tkeep_i           ,
----            M_Last                 => s_axis_tlast_i           ,
----            M_User                 => s_axis_tuser_i
----        );


s_axis_tvalid_i		<= 	slv2skid_s_axis_tvalid; 	 
s_axis_tdata_i 		<= 	s_axis_tdata;
s_axis_tkeep_i 		<= 	s_axis_tkeep_signal;
s_axis_tlast_i 		<= 	s_axis_tlast;
s_axis_tuser_i 		<= 	s_axis_tuser;

s_axis_tready_out	<= 	s_axis_tready_i; 	 



-----    end generate GEN_MSTR_SKID_NO_SOF;




    -- Pass out top level
    -- Qualify with channel ready to 'turn off' ready
    -- at end of video frame
    --s_axis_tready   <= s_axis_tready_out and not chnl_fsync ;
    s_axis_tready   <= s_axis_tready_out and chnl_ready and 
                       not stop_tready_s_axi ;

    -- Qualify with channel ready to 'turn off' writes to
    -- fifo at end of video frame
    slv2skid_s_axis_tvalid <= s_axis_tvalid and chnl_ready and 
                              not stop_tready_s_axi ;

    -- Generate start of frame fsync
-------    GEN_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 1 generate
-------    begin
-------
-------        TUSER_RE_PROCESS : process(s_axis_aclk)
-------            begin
-------                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
-------                    if(s_axis_fifo_ainit_nosync = '1')then
-------                        s_axis_tuser_d1 <= '0';
-------                    else
-------                        s_axis_tuser_d1 <= s_axis_tuser_i(0) and s_axis_tvalid_i;
-------                    end if;
-------                end if;
-------            end process TUSER_RE_PROCESS;
-------
-------        tuser_fsync <= s_axis_tuser_i(0) and s_axis_tvalid_i and not s_axis_tuser_d1;
-------
-------    end generate GEN_SOF_FSYNC;
-------
-------    -- Do not generate start of frame fsync
-------    GEN_NO_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 0 generate
-------    begin
        tuser_fsync <= '0';
-------    end generate GEN_NO_SOF_FSYNC;
-------
-------

end generate GEN_LINEBUFFER;

--*****************************************************************************--
--**               NO LINE BUFFER MODE (Sync Only)                           **--
--*****************************************************************************--
GEN_NO_LINEBUFFER : if (C_LINEBUFFER_DEPTH = 0) generate
begin

    m_axis_tdata        <= s_axis_tdata;
    m_axis_tkeep        <= s_axis_tkeep_signal;
    m_axis_tvalid_i     <= s_axis_tvalid and chnl_ready and 
                           not stop_tready_s_axi;
    m_axis_tlast_i      <= s_axis_tlast;


    m_axis_tvalid       <= m_axis_tvalid_i;
    m_axis_tlast        <= m_axis_tlast_i;


    s_axis_tready_i     <= m_axis_tready and chnl_ready and 
                           not stop_tready_s_axi;
    s_axis_tready_out   <= m_axis_tready and chnl_ready and 
                           not stop_tready_s_axi;
    s_axis_tready       <= s_axis_tready_i;

    -- fifo signals not used
    s2mm_fifo_full          <= '0';
    s2mm_fifo_almost_full   <= '0';

    -- Generate start of frame fsync
-----    GEN_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 1 generate
-----    begin
-----
-----        TUSER_RE_PROCESS : process(s_axis_aclk)
-----            begin
-----                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
-----                    if(s_axis_fifo_ainit_nosync = '1')then
-----                        s_axis_tuser_d1 <= '0';
-----                    else
-----                        s_axis_tuser_d1 <= s_axis_tuser_i(0) and s_axis_tvalid_i;
-----                    end if;
-----                end if;
-----            end process TUSER_RE_PROCESS;
-----
-----        tuser_fsync <= s_axis_tuser_i(0) and s_axis_tvalid_i and not s_axis_tuser_d1;
-----
-----    end generate GEN_SOF_FSYNC;
-----
-----    -- Do not generate start of frame fsync
-----    GEN_NO_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 0 generate
-----    begin
        tuser_fsync <= '0';
-----    end generate GEN_NO_SOF_FSYNC;



end generate GEN_NO_LINEBUFFER;


-- Instantiate Clock Domain Crossing for Asynchronous clock
GEN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin



VSIZE_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   crnt_vsize_cdc_tig <= crnt_vsize;
	   crnt_vsize_d1      <= crnt_vsize_cdc_tig;

        end if;
    end process VSIZE_CNT_CROSSING;


	   crnt_vsize_d2 <= crnt_vsize_d1;








        -- Cross datamover halt and fifo threshold to secondary for reset use
----        STRM_WR_HALT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----                C_VECTOR_WIDTH          => 1 
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => '0'                                      ,
----                prmry_out               => open                                     ,
----                prmry_in                => dm_halt                                  , -- CR591965
----                scndry_out              => dm_halt_reg                              , -- CR591965
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)                  ,
----                scndry_vect_out         => open
----            );
  

STRM_WR_HALT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => dm_halt, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => dm_halt_reg,
        scndry_vect_out            => open
    );









THRESH_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   data_count_af_threshold_cdc_tig <= data_count_af_threshold;
	   data_count_af_threshold_d1      <= data_count_af_threshold_cdc_tig;

        end if;
    end process THRESH_CNT_CROSSING;


	   s_data_count_af_thresh <= data_count_af_threshold_d1;





      -- Cross run_stop  to secondary 
----    RUNSTOP_AXIS_1_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                               ,
----            prmry_resetn            => m_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => run_stop                         ,
----            scndry_out              => run_stop_reg                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


RUNSTOP_AXIS_1_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => run_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => run_stop_reg,
        scndry_vect_out            => open
    );







        -- CR623449 cross fsync_out back to primary
----        FSYNC_OUT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => fsync_out                                ,
----                prmry_out               => p_fsync_out                              ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );
----




FSYNC_OUT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => fsync_out, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => p_fsync_out,
        scndry_vect_out            => open
    );









        -- Cross tuser fsync to primary
----        TUSER_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => tuser_fsync                              ,
----                prmry_out               => s2mm_tuser_fsync_sig                         ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );
----


TUSER_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => tuser_fsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => s2mm_tuser_fsync_sig,
        scndry_vect_out            => open
    );





 

--       WR_PENDING_P_S_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
--            generic map(
--                C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
--                C_VECTOR_WIDTH          => DATACOUNT_WIDTH
--            )
--            port map (
--                prmry_aclk              => m_axis_aclk                              ,
--                prmry_resetn            => m_axis_resetn                            ,
--                scndry_aclk             => s_axis_aclk                              ,
--                scndry_resetn           => s_axis_resetn                            ,
--                scndry_in               => '0'                       ,
--                prmry_out               => open                 ,
--                prmry_in                => stop_tready                              , 
--                scndry_out              => stop_tready_s_axi                        , 
--                scndry_vect_s_h         => '0'                                      ,
--                scndry_vect_in          => ZERO_VALUE_VECT(DATACOUNT_WIDTH-1 downto 0),
--                prmry_vect_out          => open                                     ,
--                prmry_vect_s_h          => '1'                                      ,
--                prmry_vect_in           => ZERO_VALUE_VECT(DATACOUNT_WIDTH-1 downto 0)                  ,
--                scndry_vect_out         => open
--            );
--


WR_PENDING_P_S_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => stop_tready, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => stop_tready_s_axi,
        scndry_vect_out            => open
    );







----       WR_PENDING_S_P_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----                C_VECTOR_WIDTH          => DATACOUNT_WIDTH
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => strm_write_pending                       ,
----                prmry_out               => strm_write_pending_m_axi                 ,
----                prmry_in                => '0'                              , 
----                scndry_out              => open                        , 
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(DATACOUNT_WIDTH-1 downto 0),
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '1'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(DATACOUNT_WIDTH-1 downto 0)                  ,
----                scndry_vect_out         => open
----            );
----

WR_PENDING_S_P_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => strm_write_pending, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => strm_write_pending_m_axi,
        scndry_vect_out            => open
    );








--GEN_FIFO_SIDE_DM_HALT_REG_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
--begin


   FIFO_SIDE_DM_HALT_REG : process(m_axis_aclk) is
   begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0' and p_fsync_out = '0')then
               dm_halt_frame <= '0';
            elsif (p_fsync_out = '1') then
               dm_halt_frame <= '0';
            elsif (dm_halt = '1') then
               dm_halt_frame <= '1';
            end if;
      end if;
   end process FIFO_SIDE_DM_HALT_REG;

--end generate GEN_FIFO_SIDE_DM_HALT_REG_NO_SOF; 



end generate GEN_FOR_ASYNC;

-- Synchronous clock therefore just map signals across
GEN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    crnt_vsize_d2               <= crnt_vsize;
    dm_halt_reg                 <= dm_halt;
    run_stop_reg                 <= run_stop;
    dm_halt_frame               <= dm_halt;
    s2mm_tuser_fsync_sig            <= tuser_fsync;
    p_fsync_out                 <= fsync_out;
    --s2mm_all_lines_xfred        <= all_lines_xfred;   -- CR591965/CR623449
    s_data_count_af_thresh      <= data_count_af_threshold;
    strm_write_pending_m_axi    <= strm_write_pending;
    stop_tready_s_axi           <= stop_tready;

end generate GEN_FOR_SYNC;

--*****************************************************************************
--** Vertical Line Tracking
--*****************************************************************************
-- Decrement vertical count with each accept tlast
decr_vcount <= '1' when s_axis_tlast = '1'
                    and s_axis_tvalid = '1'
                    and s_axis_tready_out = '1'
          else '0';

----GEN_NO_SOF_SM : if C_S2MM_SOF_ENABLE = 0 generate
----begin


STRM_SIDE_SM: process (strm_write_cs,
                       fsync_out,
                       decr_vcount,
                       vsize_counter)is
begin
    
    strm_write_pending_sm <= '0';
    strm_write_ns <= strm_write_cs;
    
    case strm_write_cs is
    
    when STRM_WR_IDLE => 
                          if(fsync_out = '1') then
                               strm_write_ns <= STRM_WR_RUNNING;
                               strm_write_pending_sm <= '1';
                          end if;

    when STRM_WR_RUNNING => 
                          if (decr_vcount = '1' and 
                              vsize_counter = VSIZE_ONE_VALUE) then
                               strm_write_ns <= STRM_WR_IDLE;
                               strm_write_pending_sm <= '0';                          
                          elsif (decr_vcount = '1' and 
                                 vsize_counter = VSIZE_TWO_VALUE) then
                               strm_write_ns <= STRM_WR_LAST;
                          end if;
                          strm_write_pending_sm <= '1';
                                   
    when STRM_WR_LAST =>                             
                           if (decr_vcount = '1' ) then
                               strm_write_ns <= STRM_WR_IDLE;
                               strm_write_pending_sm <= '0';
                           end if;
                           strm_write_pending_sm <= '1';
    -- coverage off
     when others =>
                           strm_write_ns <= STRM_WR_IDLE;
    -- coverage on
    
    end case;
    
end process STRM_SIDE_SM;


   STRM_SIDE_SM_REG : process(s_axis_aclk) is
   begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_fifo_ainit_nosync = '1' and fsync_out = '0')then
               strm_write_cs <= STRM_WR_IDLE;
               strm_write_pending <= '0';
            else
               strm_write_cs <= strm_write_ns;
               strm_write_pending <= strm_write_pending_sm;
         end if;
      end if;
   end process STRM_SIDE_SM_REG;   

-- Drive ready at fsync out then de-assert once all lines have
-- been accepted.
VERT_COUNTER : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_fifo_ainit = '1' and fsync_out = '0')then
                vsize_counter   <= (others => '0');
                chnl_ready      <= '0';
            elsif(fsync_out = '1')then
                vsize_counter   <= crnt_vsize_d2;
                chnl_ready      <= '1';
            elsif(decr_vcount = '1' and vsize_counter = VSIZE_ONE_VALUE)then
                vsize_counter   <= (others => '0');
                chnl_ready      <= '0';
            elsif(decr_vcount = '1' and vsize_counter /= VSIZE_ZERO_VALUE)then
                vsize_counter   <= std_logic_vector(unsigned(vsize_counter) - 1);
                chnl_ready      <= '1';
            end if;
        end if;
    end process VERT_COUNTER;

 -- decrement based on master axis signals for determining done (CR623449)
done_decr_vcount <= '1' when m_axis_tlast_i = '1'
                         and m_axis_tvalid_i = '1'
                         and m_axis_tready = '1'
          else '0';

-- CR623449 - base done on master clock domain
DONE_VERT_COUNTER : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_fifo_ainit_nosync = '1' and p_fsync_out = '0')then
                done_vsize_counter   <= (others => '0');
            elsif(load_counter = '1')then
                done_vsize_counter   <= crnt_vsize;
            elsif(done_decr_vcount = '1' and done_vsize_counter = VSIZE_ONE_VALUE)then
                done_vsize_counter   <= (others => '0');
            elsif(done_decr_vcount = '1' and done_vsize_counter /= VSIZE_ZERO_VALUE)then
                done_vsize_counter   <= std_logic_vector(unsigned(done_vsize_counter) - 1);
            end if;
        end if;
    end process DONE_VERT_COUNTER;

FIFO_SIDE_SM: process (fifo_read_cs,
                       done_decr_vcount,
                       p_fsync_out,
                       done_vsize_counter,
                       strm_write_pending_m_axi,
                       crnt_vsize)is
begin

    fifo_read_ns <= fifo_read_cs;
    load_counter_sm <= '0';
    fifo_rd_pending_sm <= '0';
    stop_tready_sm <= '0';

    case fifo_read_cs is
    
         when FIFO_RD_IDLE => 
                                  if(p_fsync_out = '1') then
                                        fifo_rd_pending_sm <= '1';
                                        load_counter_sm <= '1';
                                        if (crnt_vsize = VSIZE_ONE_VALUE) then
                                          fifo_read_ns <= FIFO_RD_LAST;
                                        else
                                          fifo_read_ns <= FIFO_RD_RUNNING;
                                        end if;                                        
                                  end if;                                      
         
         when FIFO_RD_RUNNING =>                                    
                                  if (p_fsync_out = '1') then                                  
                                          if (strm_write_pending_m_axi = '0') then
                                              stop_tready_sm <= '1';
                                          end if;
                                          if (done_decr_vcount = '1' and 
                                              done_vsize_counter = VSIZE_ONE_VALUE) then
				               fifo_read_ns <= FIFO_RD_FSYNC_LAST;
				          else
                                               fifo_read_ns <= FIFO_RD_FSYNC;
				          end if; 
                                  else
                                      if (done_decr_vcount = '1' and 
                                          done_vsize_counter = VSIZE_TWO_VALUE) then
                                          fifo_read_ns <= FIFO_RD_LAST;
                                      end if;
                                  end if;
                                  fifo_rd_pending_sm <= '1';                                
         
         when FIFO_RD_FSYNC =>    
                                  if (done_decr_vcount = '1' and 
                                      done_vsize_counter = VSIZE_TWO_VALUE) then
                                     fifo_read_ns <= FIFO_RD_FSYNC_LAST;
                                  end if;
                                  fifo_rd_pending_sm <= '1';
                                  stop_tready_sm <= '1';
         
         when FIFO_RD_FSYNC_LAST =>
                                  if (done_decr_vcount = '1' ) then
                                     fifo_read_ns <= FIFO_RD_RUNNING;
                                     load_counter_sm <= '1';
                                     stop_tready_sm <= '0';
                                  end if;
                                  fifo_rd_pending_sm <= '1';
                                  stop_tready_sm <= '1';
         
         when FIFO_RD_LAST =>     
                                  if (p_fsync_out = '1') then                                  
                                      if (strm_write_pending_m_axi = '0') then
                                          stop_tready_sm <= '1';
                                      end if;
                                      if (done_decr_vcount = '1' ) then
                                         fifo_read_ns <= FIFO_RD_RUNNING;
                                         load_counter_sm <= '1';
                                      else                                             
                                         fifo_read_ns <= FIFO_RD_FSYNC_LAST;                                             
                                      end if;  
                                  else                                 
                                      if (done_decr_vcount = '1' ) then
                                         fifo_read_ns <= FIFO_RD_IDLE;
                                         fifo_rd_pending_sm <= '0';                                     
                                      end if;
                                  end if;
                                  fifo_rd_pending_sm <= '1';
         
         
         -- coverage off
          when others =>
                                 fifo_read_ns <= FIFO_RD_IDLE;
         -- coverage on
    end case;
        
 end process FIFO_SIDE_SM;


   FIFO_SIDE_SM_REG : process(m_axis_aclk) is
   begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if((m_axis_fifo_ainit_nosync = '1' and p_fsync_out = '0' ) or 
                dm_halt_frame = '1')then
             fifo_read_cs <= FIFO_RD_IDLE;
             load_counter <= '0';
             fifo_rd_pending <= '0';
             stop_tready <= '0';
         else
             fifo_read_cs <= fifo_read_ns;
             load_counter <= load_counter_sm;
             fifo_rd_pending <= fifo_rd_pending_sm;
             stop_tready <= stop_tready_sm;
         end if;
      end if;
   end process FIFO_SIDE_SM_REG;
   

DONE_XFER_SIG : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_fifo_ainit_nosync = '1' and p_fsync_out = '0')then
                s2mm_all_lines_xfred_i <= '1';
            elsif(load_counter = '1' )then
                s2mm_all_lines_xfred_i <= '0';
            elsif(done_decr_vcount = '1' and done_vsize_counter = VSIZE_ONE_VALUE)then
                s2mm_all_lines_xfred_i <= '1';
            elsif(done_decr_vcount = '1' and done_vsize_counter /= VSIZE_ZERO_VALUE)then
                s2mm_all_lines_xfred_i <= '0';
            end if;
        end if;
    end process DONE_XFER_SIG;

----end generate GEN_NO_SOF_SM; 




   all_lasts_rcvd <= not strm_write_pending_m_axi;
s2mm_fsync_core <= s2mm_fsync;
fsync_src_select_s <= (others => '0');
drop_fsync_d_pulse_gen_fsize_less_err <= '0';
hold_dummy_tready_low <= '0';
hold_dummy_tready_low2 <= '0';

end generate GEN_FSYNC_LOGIC;


--*****************************************************************************--
--**              USE FSYNC MODE                         **--
--*****************************************************************************--
GEN_NO_FSYNC_LOGIC : if ENABLE_FLUSH_ON_FSYNC = 0 generate
begin


--*****************************************************************************--

--*****************************************************************************--
--**              LINE BUFFER MODE (Sync or Async)                           **--
--*****************************************************************************--
GEN_LINEBUFFER : if C_LINEBUFFER_DEPTH /= 0 generate
begin

    -- Divide by number bytes per data beat and add padding to dynamic
    -- threshold setting
    data_count_af_threshold <= linebuf_threshold((DATACOUNT_WIDTH-1) + THRESHOLD_LSB_INDEX
                                            downto THRESHOLD_LSB_INDEX);


    -- Synchronous clock therefore instantiate an Asynchronous FIFO
    GEN_SYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
    begin
----
----	GEN_SYNC_FIFO_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
----    begin


     
      
        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_sfifo
            generic map(
                 UW_DATA_WIDTH     => BUFFER_WIDTH        ,
          C_FULL_FLAGS_RST_VAL     => 1        ,
                 UW_FIFO_DEPTH     => BUFFER_DEPTH        ,
                 C_FAMILY          => C_FAMILY
            )
            port map(
                -- Inputs
                 rst               => s_axis_fifo_ainit_nosync   ,
                 sleep             => '0'         ,
                 wr_rst_busy       => wr_rst_busy_sig         ,
                 rd_rst_busy       => rd_rst_busy_sig         ,
                 clk               => s_axis_aclk         ,
                 wr_en             => fifo_wren           ,
                 din               => fifo_din            ,
                 rd_en             => fifo_rden           ,

                -- Outputs
                 dout              => fifo_dout           ,
                 full              => fifo_full_i         ,
                 empty             => fifo_empty_i        ,
                 data_count        => fifo_wrcount  
            );



--wr_rst_busy_sig <= '0';
--rd_rst_busy_sig <= '0';

----    end generate GEN_SYNC_FIFO_NO_SOF;
----


    end generate GEN_SYNC_FIFO;


    -- Asynchronous clock therefore instantiate an Asynchronous FIFO
    GEN_ASYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
    begin

----
----	GEN_ASYNC_FIFO_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
----    begin
----


               
      
LB_BRAM : if ((C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo
            generic map(
                 UW_DATA_WIDTH   => BUFFER_WIDTH                    ,
          C_FULL_FLAGS_RST_VAL   => 1        ,
                 UW_FIFO_DEPTH   => BUFFER_DEPTH                    ,
                 C_FAMILY        => C_FAMILY
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => open         ,
                 rd_rst_busy     => open         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         ,
                 wr_data_count   => fifo_wrcount         ,
                 rd_data_count   => open                 
            );

wr_rst_busy_sig <= '0';
rd_rst_busy_sig <= '0';
end generate LB_BRAM;                     

      
LB_BUILT_IN : if ( (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo_builtin
            generic map(
                 PL_FIFO_TYPE    => "BUILT_IN"                    ,
                 PL_READ_MODE    => "FWFT"                    ,
                 PL_FASTER_CLOCK => "RD_CLK"                    , --WR_CLK
                 PL_FULL_FLAGS_RST_VAL => 0                     , -- ?
                 PL_DATA_WIDTH   => BUFFER_WIDTH                    ,
                 C_FAMILY        => C_FAMILY ,
                 PL_FIFO_DEPTH   => BUFFER_DEPTH                    
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => wr_rst_busy_sig         ,
                 rd_rst_busy     => rd_rst_busy_sig         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         
            );

end generate LB_BUILT_IN;                     


      

----     end generate GEN_ASYNC_FIFO_NO_SOF;
----
----
----








     end generate GEN_ASYNC_FIFO;

   GEN_S2MM_DRE_ENABLED_TKEEP : if C_INCLUDE_S2MM_DRE = 1 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tkeep_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= fifo_dout(BUFFER_WIDTH-2 downto (BUFFER_WIDTH-2) - (C_DATA_WIDTH/8) + 1);
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;

   end generate GEN_S2MM_DRE_ENABLED_TKEEP;

   GEN_NO_S2MM_DRE_DISABLE_TKEEP : if C_INCLUDE_S2MM_DRE = 0 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= (others => '1');
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;



   end generate GEN_NO_S2MM_DRE_DISABLE_TKEEP;


    -- Generate start of frame fsync
    GEN_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 1 generate
    begin

        TUSER_RE_PROCESS : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit_nosync = '1')then
                        s_axis_tuser_d1 <= '0';
                    else
                        s_axis_tuser_d1 <= s_axis_tuser_i(0) and s_axis_tvalid_i;
                    end if;
                end if;
            end process TUSER_RE_PROCESS;

        tuser_fsync <= s_axis_tuser_i(0) and s_axis_tvalid_i and not s_axis_tuser_d1;

    end generate GEN_SOF_FSYNC;

    -- Do not generate start of frame fsync
    GEN_NO_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 0 generate
    begin
        tuser_fsync <= '0';
    end generate GEN_NO_SOF_FSYNC;

    -- Top level line buffer depth not equal to zero therefore gererate threshold
    -- flags. (CR625142)
    GEN_THRESHOLD_ENABLED : if C_TOPLVL_LINEBUFFER_DEPTH /= 0   and (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin

----    GEN_THRESHOLD_ENABLED_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
----    begin




        -- Almost full flag
        -- This flag is only used by S2MM and the threshold has been adjusted to allow registering
        -- of the flag for timing and also to assert and deassert from an outside S2MM perspective

            
      
        REG_ALMST_FULL : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit = '1')then
                        fifo_almost_full_i <= '0';
                    -- write count greater than or equal to threshold value therefore assert thresold flag
                    elsif(fifo_wrcount >= s_data_count_af_thresh or (fifo_full_i='1' or wr_rst_busy_sig = '1')) then
                        fifo_almost_full_i <= '1';
                    -- In all other cases de-assert flag
                    else
                        fifo_almost_full_i <= '0';
                    end if;
                end if;
            end process REG_ALMST_FULL;




        -- Drive fifo flags out if Linebuffer included
        s2mm_fifo_almost_full   <= fifo_almost_full_i or fifo_full_i or wr_rst_busy_sig;
        s2mm_fifo_full          <= fifo_full_i or wr_rst_busy_sig;

----    end generate GEN_THRESHOLD_ENABLED_NO_SOF;







    end generate GEN_THRESHOLD_ENABLED;

    -- Top level line buffer depth is zero therefore turn off threshold logic.
    -- this occurs for async operation where the async fifo is needed for CDC (CR625142)
    GEN_THRESHOLD_DISABLED  : if C_TOPLVL_LINEBUFFER_DEPTH = 0   or (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        fifo_almost_full_i      <= '0';
        s2mm_fifo_almost_full   <= '0';
        s2mm_fifo_full          <= '0';
    end generate GEN_THRESHOLD_DISABLED;




----    GEN_MSTR_SKID_NO_SOF : if C_S2MM_SOF_ENABLE = 0 generate
----    begin

    --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
   ---- I_MSTR_SKID : entity axi_vdma_v6_2.axi_vdma_skid_buf
   ----     generic map(
   ----         C_WDATA_WIDTH           => C_DATA_WIDTH             ,
   ----         C_TUSER_WIDTH           => C_S_AXIS_S2MM_TUSER_BITS
   ----     )
   ----     port map(
   ----         -- System Ports
   ----         ACLK                   => s_axis_aclk              ,
   ----         ARST                   => s_axis_fifo_ainit        ,

   ----         -- Shutdown control (assert for 1 clk pulse)
   ----         skid_stop              => '0'                      ,

   ----         -- Slave Side (Stream Data Input)
   ----         S_VALID                => slv2skid_s_axis_tvalid   ,
   ----         S_READY                => s_axis_tready_out        ,
   ----         S_Data                 => s_axis_tdata             ,
   ----         S_STRB                 => s_axis_tkeep             ,
   ----         S_Last                 => s_axis_tlast             ,
   ----         S_User                 => s_axis_tuser             ,

   ----         -- Master Side (Stream Data Output)
   ----         M_VALID                => s_axis_tvalid_i          ,
   ----         M_READY                => s_axis_tready_i          ,
   ----         M_Data                 => s_axis_tdata_i           ,
   ----         M_STRB                 => s_axis_tkeep_i           ,
   ----         M_Last                 => s_axis_tlast_i           ,
   ----         M_User                 => s_axis_tuser_i
   ----     );




s_axis_tvalid_i		<= 	slv2skid_s_axis_tvalid; 	 
s_axis_tdata_i 		<= 	s_axis_tdata;
s_axis_tkeep_i 		<= 	s_axis_tkeep_signal;
s_axis_tlast_i 		<= 	s_axis_tlast;
s_axis_tuser_i 		<= 	s_axis_tuser;

s_axis_tready_out	<= 	s_axis_tready_i; 	 





    -- Pass out top level
    -- Qualify with channel ready to 'turn off' ready
    -- at end of video frame
    s_axis_tready   <= s_axis_tready_out and chnl_ready;


    -- Qualify with channel ready to 'turn off' writes to
    -- fifo at end of video frame
    slv2skid_s_axis_tvalid <= s_axis_tvalid and chnl_ready;


end generate GEN_LINEBUFFER;

--*****************************************************************************--
--**               NO LINE BUFFER MODE (Sync Only)                           **--
--*****************************************************************************--
GEN_NO_LINEBUFFER : if (C_LINEBUFFER_DEPTH = 0) generate
begin

    m_axis_tdata        <= s_axis_tdata;
    m_axis_tkeep        <= s_axis_tkeep_signal;
    m_axis_tvalid_i     <= s_axis_tvalid and chnl_ready;
    m_axis_tlast_i      <= s_axis_tlast;


    m_axis_tvalid   <= m_axis_tvalid_i;
    m_axis_tlast    <= m_axis_tlast_i;


    s_axis_tready_i     <= m_axis_tready and chnl_ready;
    s_axis_tready_out   <= m_axis_tready and chnl_ready;
    s_axis_tready       <= s_axis_tready_i;

    -- fifo signals not used
    s2mm_fifo_full          <= '0';
    s2mm_fifo_almost_full   <= '0';


    -- Generate start of frame fsync
    GEN_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 1 generate
    begin

        TUSER_RE_PROCESS : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit_nosync = '1')then
                        s_axis_tuser_d1 <= '0';
                    else
                        s_axis_tuser_d1 <= s_axis_tuser_i(0) and s_axis_tvalid_i;
                    end if;
                end if;
            end process TUSER_RE_PROCESS;

        tuser_fsync <= s_axis_tuser_i(0) and s_axis_tvalid_i and not s_axis_tuser_d1;

    end generate GEN_SOF_FSYNC;

    -- Do not generate start of frame fsync
    GEN_NO_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 0 generate
    begin
        tuser_fsync <= '0';
    end generate GEN_NO_SOF_FSYNC;


end generate GEN_NO_LINEBUFFER;


-- Instantiate Clock Domain Crossing for Asynchronous clock
GEN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin



VSIZE_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   crnt_vsize_cdc_tig <= crnt_vsize;
	   crnt_vsize_d1      <= crnt_vsize_cdc_tig;

        end if;
    end process VSIZE_CNT_CROSSING;


	   crnt_vsize_d2 <= crnt_vsize_d1;



        -- Cross datamover halt and fifo threshold to secondary for reset use
----        STRM_WR_HALT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----                C_VECTOR_WIDTH          => 1 
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => '0'                                      ,
----                prmry_out               => open                                     ,
----                prmry_in                => dm_halt                                  , -- CR591965
----                scndry_out              => dm_halt_reg                              , -- CR591965
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)                  ,
----                scndry_vect_out         => open
----            );
  
STRM_WR_HALT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => dm_halt, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => dm_halt_reg,
        scndry_vect_out            => open
    );




THRESH_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   data_count_af_threshold_cdc_tig <= data_count_af_threshold;
	   data_count_af_threshold_d1      <= data_count_af_threshold_cdc_tig;

        end if;
    end process THRESH_CNT_CROSSING;


	   s_data_count_af_thresh <= data_count_af_threshold_d1;








        -- Cross run_stop  to secondary 

----    RUNSTOP_AXIS_0_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                               ,
----            prmry_resetn            => m_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => run_stop                         ,
----            scndry_out              => run_stop_reg                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


RUNSTOP_AXIS_0_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => run_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => run_stop_reg,
        scndry_vect_out            => open
    );





        -- CR623449 cross fsync_out back to primary
----        FSYNC_OUT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => fsync_out                                ,
----                prmry_out               => p_fsync_out                              ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );
----



FSYNC_OUT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => fsync_out, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => p_fsync_out,
        scndry_vect_out            => open
    );





        -- Cross tuser fsync to primary
----        TUSER_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => tuser_fsync                              ,
----                prmry_out               => s2mm_tuser_fsync_sig                         ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );
----


TUSER_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => tuser_fsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => s2mm_tuser_fsync_sig,
        scndry_vect_out            => open
    );






end generate GEN_FOR_ASYNC;

-- Synchronous clock therefore just map signals across
GEN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    crnt_vsize_d2               <= crnt_vsize;
    dm_halt_reg                 <= dm_halt;
    run_stop_reg                 <= run_stop;
    p_fsync_out                 <= fsync_out;
    s2mm_tuser_fsync_sig            <= tuser_fsync;
    s_data_count_af_thresh      <= data_count_af_threshold;

end generate GEN_FOR_SYNC;

--*****************************************************************************
--** Vertical Line Tracking
--*****************************************************************************

-- Generate vertical size counter for case when SOF not used
GEN_NO_SOF_VCOUNT : if C_S2MM_SOF_ENABLE = 0 generate
begin

    -- Decrement vertical count with each accept tlast
    decr_vcount <= '1' when s_axis_tlast = '1'
                        and s_axis_tvalid = '1'
                        and s_axis_tready_out = '1'
              else '0';

    -- Drive ready at fsync out then de-assert once all lines have
    -- been accepted.
    VERT_COUNTER : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_fifo_ainit = '1' and fsync_out = '0')then
                    vsize_counter   <= (others => '0');
                    chnl_ready      <= '0';
                elsif(fsync_out = '1')then
                    vsize_counter   <= crnt_vsize_d2;
                    chnl_ready      <= '1';
                elsif(decr_vcount = '1' and vsize_counter = VSIZE_ONE_VALUE)then
                    vsize_counter   <= (others => '0');
                    chnl_ready      <= '0';
                elsif(decr_vcount = '1' and vsize_counter /= VSIZE_ZERO_VALUE)then
                    vsize_counter   <= std_logic_vector(unsigned(vsize_counter) - 1);
                    chnl_ready      <= '1';
                end if;
            end if;
        end process VERT_COUNTER;

    -- decrement based on master axis signals for determining done (CR623449)
    done_decr_vcount <= '1' when m_axis_tlast_i = '1'
                             and m_axis_tvalid_i = '1'
                             and m_axis_tready = '1'
              else '0';


    -- CR623449 - base done on master clock domain
    DONE_VERT_COUNTER : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                if(m_axis_fifo_ainit = '1' and p_fsync_out = '0')then
                    done_vsize_counter   <= (others => '0');
                    s2mm_all_lines_xfred_i <= '1';
                elsif(p_fsync_out = '1')then
                    done_vsize_counter   <= crnt_vsize;
                    s2mm_all_lines_xfred_i <= '0';

                elsif(done_decr_vcount = '1' and done_vsize_counter = VSIZE_ONE_VALUE)then
                    done_vsize_counter   <= (others => '0');
                    s2mm_all_lines_xfred_i <= '1';

                elsif(done_decr_vcount = '1' and done_vsize_counter /= VSIZE_ZERO_VALUE)then
                    done_vsize_counter   <= std_logic_vector(unsigned(done_vsize_counter) - 1);
                    s2mm_all_lines_xfred_i <= '0';

                end if;
            end if;
        end process DONE_VERT_COUNTER;



end generate GEN_NO_SOF_VCOUNT;
----
----
----
------ Generate vertical size counter for case when SOF is used
GEN_SOF_VCOUNT : if C_S2MM_SOF_ENABLE = 1 generate
begin

    chnl_ready <= run_stop_reg;

    -- decrement based on master axis signals for determining done (CR623449)
    done_decr_vcount <= '1' when m_axis_tlast_i = '1'
                             and m_axis_tvalid_i = '1'
                             and m_axis_tready = '1'
              else '0';


    -- CR623449 - base done on master clock domain
    DONE_VERT_COUNTER : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                if(m_axis_fifo_ainit = '1' and p_fsync_out = '0')then
                    done_vsize_counter   <= (others => '0');
                    s2mm_all_lines_xfred_i <= '1';
                elsif(p_fsync_out = '1')then
                    done_vsize_counter   <= crnt_vsize;
                    s2mm_all_lines_xfred_i <= '0';

                elsif(done_decr_vcount = '1' and done_vsize_counter = VSIZE_ONE_VALUE)then
                    done_vsize_counter   <= (others => '0');
                    s2mm_all_lines_xfred_i <= '1';

                elsif(done_decr_vcount = '1' and done_vsize_counter /= VSIZE_ZERO_VALUE)then
                    done_vsize_counter   <= std_logic_vector(unsigned(done_vsize_counter) - 1);
                    s2mm_all_lines_xfred_i <= '0';

                end if;
            end if;
        end process DONE_VERT_COUNTER;


end generate GEN_SOF_VCOUNT;



s2mm_all_lines_xfred <= s2mm_all_lines_xfred_i;
all_lasts_rcvd <= s2mm_all_lines_xfred_i;
s2mm_fsync_core <= s2mm_fsync;
fsync_src_select_s <= (others => '0');
drop_fsync_d_pulse_gen_fsize_less_err <= '0';
hold_dummy_tready_low <= '0';
hold_dummy_tready_low2 <= '0';
end generate GEN_NO_FSYNC_LOGIC;









--*****************************************************************************--
--**              USE FSYNC MODE                         **--
--*****************************************************************************--
GEN_S2MM_FLUSH_SOF_LOGIC : if (ENABLE_FLUSH_ON_FSYNC = 1 and C_S2MM_SOF_ENABLE = 1) generate





signal fsync_src_select_s_int 				: std_logic_vector(1 downto 0) := (others => '0');
signal fsync_src_select_cdc_tig 			: std_logic_vector(1 downto 0) := (others => '0');
signal fsync_src_select_d1 				: std_logic_vector(1 downto 0) := (others => '0');
signal mmap_not_finished 				: std_logic := '0';
signal mmap_not_finished_s 				: std_logic := '0';
signal mm2s_fsync_s2mm_s 				: std_logic := '0';
signal s2mm_fsync_int 					: std_logic := '0';
signal s2mm_fsync_d_pulse 				: std_logic := '0';
signal delay_s2mm_fsync_core_till_mmap_done 		: std_logic := '0';
signal delay_s2mm_fsync_core_till_mmap_done_flag 	: std_logic := '0';
signal delay_s2mm_fsync_core_till_mmap_done_flag_d1 	: std_logic := '0';
signal sig_drop_fsync_d_pulse_gen_fsize_less_err 	: std_logic := '0';
signal delay_fsync_fsize_err_till_dm_halt_cmplt_s 	: std_logic := '0';
signal delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s : std_logic := '0';
signal dm_halt_cmplt_flag_s 				: std_logic := '0';
signal delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s 	: std_logic := '0';
signal delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1 	: std_logic := '0';
signal d_fsync_halt_cmplt_s 				: std_logic := '0';
signal fsize_err_to_dm_halt_flag 			: std_logic := '0';
signal fsize_err_to_dm_halt_flag_ored 			: std_logic := '0';

  ATTRIBUTE async_reg                      : STRING;
  ATTRIBUTE async_reg OF fsync_src_select_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF fsync_src_select_d1       : SIGNAL IS "true"; 

begin


--*****************************************************************************--

--*****************************************************************************--
--**              LINE BUFFER MODE (Sync or Async)                           **--
--*****************************************************************************--
GEN_LINEBUFFER_FLUSH_SOF : if C_LINEBUFFER_DEPTH /= 0 generate
begin

    -- Divide by number bytes per data beat and add padding to dynamic
    -- threshold setting
    data_count_af_threshold <= linebuf_threshold((DATACOUNT_WIDTH-1) + THRESHOLD_LSB_INDEX
                                            downto THRESHOLD_LSB_INDEX);


    -- Synchronous clock therefore instantiate an Asynchronous FIFO
    GEN_SYNC_FIFO_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
    begin

                
      
        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_sfifo
            generic map(
                 UW_DATA_WIDTH     => BUFFER_WIDTH        ,
          C_FULL_FLAGS_RST_VAL     => 1        ,
                 UW_FIFO_DEPTH     => BUFFER_DEPTH        ,
                 C_FAMILY          => C_FAMILY
            )
            port map(
                -- Inputs
                 rst               => s_axis_fifo_ainit_nosync   ,
                 sleep             => '0'         ,
                 wr_rst_busy       =>  wr_rst_busy_sig        ,
                 rd_rst_busy       =>  rd_rst_busy_sig        ,
                 clk               => s_axis_aclk         ,
                 wr_en             => fifo_wren           ,
                 din               => fifo_din            ,
                 rd_en             => fifo_rden           ,

                -- Outputs
                 dout              => fifo_dout           ,
                 full              => fifo_full_i         ,
                 empty             => fifo_empty_i        ,
                 data_count        => fifo_wrcount  
            );



--wr_rst_busy_sig <= '0';
--rd_rst_busy_sig <= '0';

    end generate GEN_SYNC_FIFO_FLUSH_SOF;


    -- Asynchronous clock therefore instantiate an Asynchronous FIFO
    GEN_ASYNC_FIFO_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
    begin

          
      
LB_BRAM : if ((C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo
            generic map(
                 UW_DATA_WIDTH   => BUFFER_WIDTH                    ,
          C_FULL_FLAGS_RST_VAL   => 1        ,
                 UW_FIFO_DEPTH   => BUFFER_DEPTH                    ,
                 C_FAMILY        => C_FAMILY
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => open         ,
                 rd_rst_busy     => open         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         ,
                 wr_data_count   => fifo_wrcount         ,
                 rd_data_count   => open                 
            );

wr_rst_busy_sig <= '0';
rd_rst_busy_sig <= '0';
end generate LB_BRAM;                     

      
LB_BUILT_IN : if ((C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0) )
  generate   
    begin


        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo_builtin
            generic map(
                 PL_FIFO_TYPE    => "BUILT_IN"                    ,
                 PL_READ_MODE    => "FWFT"                    ,
                 PL_FASTER_CLOCK => "RD_CLK"                    , --WR_CLK
                 PL_FULL_FLAGS_RST_VAL => 0                     , -- ?
                 PL_DATA_WIDTH   => BUFFER_WIDTH                    ,
                 C_FAMILY        => C_FAMILY ,
                 PL_FIFO_DEPTH   => BUFFER_DEPTH                    
            )
            port map(
                 rst             => s_axis_fifo_ainit_nosync    ,
                 sleep           => '0'         ,
                 wr_rst_busy     => wr_rst_busy_sig         ,
                 rd_rst_busy     => rd_rst_busy_sig         ,
                 wr_clk          => s_axis_aclk          ,
                 wr_en           => fifo_wren            ,
                 din             => fifo_din             ,
                 rd_clk          => m_axis_aclk          ,
                 rd_en           => fifo_rden            ,

                -- Outputs
                 dout            => fifo_dout            ,
                 full            => fifo_full_i          ,
                 empty           => fifo_empty_i         
            );

end generate LB_BUILT_IN;                     


      


     end generate GEN_ASYNC_FIFO_FLUSH_SOF;
   GEN_S2MM_DRE_ENABLED_TKEEP : if C_INCLUDE_S2MM_DRE = 1 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tkeep_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= fifo_dout(BUFFER_WIDTH-2 downto (BUFFER_WIDTH-2) - (C_DATA_WIDTH/8) + 1);
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;

   end generate GEN_S2MM_DRE_ENABLED_TKEEP;

   GEN_NO_S2MM_DRE_DISABLE_TKEEP : if C_INCLUDE_S2MM_DRE = 0 generate
   begin


    -- AXI Slave Side of FIFO
    fifo_din            <= s_axis_tlast_i & s_axis_tdata_i;
    fifo_wren           <= s_axis_tvalid_i and  s_axis_tready_i;


    s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;


    -- AXI Master Side of FIFO
    fifo_rden           <= m_axis_tready and m_axis_tvalid_i;
    m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig;
    m_axis_tdata        <= fifo_dout(C_DATA_WIDTH-1 downto 0);
    m_axis_tkeep_signal <= (others => '1');
    m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);


    m_axis_tlast    <= m_axis_tlast_i;
    m_axis_tvalid   <= m_axis_tvalid_i;



   end generate GEN_NO_S2MM_DRE_DISABLE_TKEEP;


    -- Top level line buffer depth not equal to zero therefore gererate threshold
    -- flags. (CR625142)
    GEN_THRESHOLD_ENABLED_FLUSH_SOF : if C_TOPLVL_LINEBUFFER_DEPTH /= 0   and (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin

        -- Almost full flag
        -- This flag is only used by S2MM and the threshold has been adjusted to allow registering
        -- of the flag for timing and also to assert and deassert from an outside S2MM perspective




      
        REG_ALMST_FULL : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit = '1')then
                        fifo_almost_full_i <= '0';
                    -- write count greater than or equal to threshold value therefore assert thresold flag
                    elsif(fifo_wrcount >= s_data_count_af_thresh or (fifo_full_i='1' or wr_rst_busy_sig = '1')) then
                        fifo_almost_full_i <= '1';
                    -- In all other cases de-assert flag
                    else
                        fifo_almost_full_i <= '0';
                    end if;
                end if;
            end process REG_ALMST_FULL;




        -- Drive fifo flags out if Linebuffer included
        s2mm_fifo_almost_full   <= fifo_almost_full_i or fifo_full_i or wr_rst_busy_sig;
        s2mm_fifo_full          <= fifo_full_i or wr_rst_busy_sig;

    end generate GEN_THRESHOLD_ENABLED_FLUSH_SOF;

    -- Top level line buffer depth is zero therefore turn off threshold logic.
    -- this occurs for async operation where the async fifo is needed for CDC (CR625142)
    GEN_THRESHOLD_DISABLED_FLUSH_SOF  : if C_TOPLVL_LINEBUFFER_DEPTH = 0   or (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        fifo_almost_full_i      <= '0';
        s2mm_fifo_almost_full   <= '0';
        s2mm_fifo_full          <= '0';
    end generate GEN_THRESHOLD_DISABLED_FLUSH_SOF;



    --*********************************************************--
    --**               S2MM SLAVE SKID BUFFER                **--
    --*********************************************************--
--    I_MSTR_SKID_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_skid_buf
--        generic map(
--            C_WDATA_WIDTH           => C_DATA_WIDTH             ,
--            C_TUSER_WIDTH           => C_S_AXIS_S2MM_TUSER_BITS
--        )
--        port map(
--            -- System Ports
--            ACLK                   => s_axis_aclk              ,
--            ARST                   => s_axis_fifo_ainit        ,
--
--            -- Shutdown control (assert for 1 clk pulse)
--            skid_stop              => '0'                      ,
--
--            -- Slave Side (Stream Data Input)
--            S_VALID                => slv2skid_s_axis_tvalid   ,
--            S_READY                => s_axis_tready_out        ,
--            S_Data                 => s_axis_tdata             ,
--            S_STRB                 => s_axis_tkeep             ,
--            S_Last                 => s_axis_tlast             ,
--            S_User                 => s_axis_tuser             ,
--
--            -- Master Side (Stream Data Output)
--            M_VALID                => s_axis_tvalid_i          ,
--            M_READY                => s_axis_tready_i          ,
--            M_Data                 => s_axis_tdata_i           ,
--            M_STRB                 => s_axis_tkeep_i           ,
--            M_Last                 => s_axis_tlast_i           ,
--            M_User                 => s_axis_tuser_i
--        );


s_axis_tvalid_i		<= 	slv2skid_s_axis_tvalid; 	 
s_axis_tdata_i 		<= 	s_axis_tdata;
s_axis_tkeep_i 		<= 	s_axis_tkeep_signal;
s_axis_tlast_i 		<= 	s_axis_tlast;
s_axis_tuser_i 		<= 	s_axis_tuser;

s_axis_tready_out	<= 	s_axis_tready_i; 	 


    -- Pass out top level
    -- Qualify with channel ready to 'turn off' ready
    -- at end of video frame
    --------s_axis_tready   <= s_axis_tready_out and chnl_ready_external;
    s_axis_tready   <= s_axis_tready_out ;


    -- Qualify with channel ready to 'turn off' writes to
    -- fifo at end of video frame
    ------slv2skid_s_axis_tvalid <= s_axis_tvalid and chnl_ready_external;
    slv2skid_s_axis_tvalid <= s_axis_tvalid ;


end generate GEN_LINEBUFFER_FLUSH_SOF;

--*****************************************************************************--
--**               NO LINE BUFFER MODE (Sync Only)                           **--
--*****************************************************************************--
GEN_NO_LINEBUFFER_FLUSH_SOF : if (C_LINEBUFFER_DEPTH = 0) generate
begin

    m_axis_tdata        <= s_axis_tdata;
    m_axis_tkeep        <= s_axis_tkeep_signal;
    m_axis_tvalid_i     <= s_axis_tvalid;
    --------------------m_axis_tvalid_i     <= s_axis_tvalid and chnl_ready_external;
    m_axis_tlast_i      <= s_axis_tlast;


    m_axis_tvalid   <= m_axis_tvalid_i;
    m_axis_tlast    <= m_axis_tlast_i;


    ----------s_axis_tready_i     <= m_axis_tready and chnl_ready_external;
    s_axis_tready_i     <= m_axis_tready;
    ---------s_axis_tready_out   <= m_axis_tready and chnl_ready_external;
    s_axis_tready_out   <= m_axis_tready;
    s_axis_tready       <= s_axis_tready_i;

    -- fifo signals not used
    s2mm_fifo_full          <= '0';
    s2mm_fifo_almost_full   <= '0';


--------------------------    -- Generate start of frame fsync
--------------------------    GEN_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 1 generate
--------------------------    begin
--------------------------
--------------------------        TUSER_RE_PROCESS : process(s_axis_aclk)
--------------------------            begin
--------------------------                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
--------------------------                    if(s_axis_fifo_ainit_nosync = '1')then
--------------------------                        s_axis_tuser_d1 <= '0';
--------------------------                    else
--------------------------                        s_axis_tuser_d1 <= s_axis_tuser_i(0) and s_axis_tvalid_i;
--------------------------                    end if;
--------------------------                end if;
--------------------------            end process TUSER_RE_PROCESS;
--------------------------
--------------------------        tuser_fsync <= s_axis_tuser_i(0) and s_axis_tvalid_i and not s_axis_tuser_d1;
--------------------------
--------------------------    end generate GEN_SOF_FSYNC;
--------------------------
--------------------------    -- Do not generate start of frame fsync
--------------------------    GEN_NO_SOF_FSYNC : if C_S2MM_SOF_ENABLE = 0 generate
--------------------------    begin
--------------------------        tuser_fsync <= '0';
--------------------------    end generate GEN_NO_SOF_FSYNC;


end generate GEN_NO_LINEBUFFER_FLUSH_SOF;


-- Instantiate Clock Domain Crossing for Asynchronous clock
GEN_FOR_ASYNC_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin



VSIZE_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   crnt_vsize_cdc_tig <= crnt_vsize;
	   crnt_vsize_d1      <= crnt_vsize_cdc_tig;

        end if;
    end process VSIZE_CNT_CROSSING;


	   crnt_vsize_d2 <= crnt_vsize_d1;



        -- Cross datamover halt and fifo threshold to secondary for reset use
----        STRM_WR_HALT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----                C_VECTOR_WIDTH          => 1 
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => '0'                                      ,
----                prmry_out               => open                                     ,
----                prmry_in                => dm_halt                                  , -- CR591965
----                scndry_out              => dm_halt_reg                              , -- CR591965
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0),
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)                  ,
----                scndry_vect_out         => open
----            );
  
STRM_WR_HALT_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => dm_halt, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => dm_halt_reg,
        scndry_vect_out            => open
    );




THRESH_CNT_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

	   data_count_af_threshold_cdc_tig <= data_count_af_threshold;
	   data_count_af_threshold_d1      <= data_count_af_threshold_cdc_tig;

        end if;
    end process THRESH_CNT_CROSSING;


	   s_data_count_af_thresh <= data_count_af_threshold_d1;







        -- Cross run_stop  to secondary 

----    RUNSTOP_AXIS_0_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                               ,
----            prmry_resetn            => m_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => run_stop                         ,
----            scndry_out              => run_stop_reg                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


RUNSTOP_AXIS_0_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => run_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => run_stop_reg,
        scndry_vect_out            => open
    );




        -- CR623449 cross fsync_out back to primary
----        FSYNC_OUT_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => fsync_out                                ,
----                prmry_out               => p_fsync_out                              ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );
----


FSYNC_OUT_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => fsync_out, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => p_fsync_out,
        scndry_vect_out            => open
    );





        -- Cross tuser fsync to primary
----        TUSER_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----            generic map(
----                C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----                C_VECTOR_WIDTH          => 1
----            )
----            port map (
----                prmry_aclk              => m_axis_aclk                              ,
----                prmry_resetn            => m_axis_resetn                            ,
----                scndry_aclk             => s_axis_aclk                              ,
----                scndry_resetn           => s_axis_resetn                            ,
----                scndry_in               => tuser_fsync                              ,
----                prmry_out               => s2mm_tuser_fsync_sig                         ,
----                prmry_in                => '0'                                      ,
----                scndry_out              => open                                     ,
----                scndry_vect_s_h         => '0'                                      ,
----                scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----                prmry_vect_out          => open                                     ,
----                prmry_vect_s_h          => '0'                                      ,
----                prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----                scndry_vect_out         => open
----            );



TUSER_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_aclk,
        prmry_resetn               => s_axis_resetn, 
        prmry_in                   => tuser_fsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => s2mm_tuser_fsync_sig,
        scndry_vect_out            => open
    );





----    MMAP_NOT_FINISHED_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                               ,
----            prmry_resetn            => m_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => mmap_not_finished                         ,
----            scndry_out              => mmap_not_finished_s                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


MMAP_NOT_FINISHED_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => mmap_not_finished, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mmap_not_finished_s,
        scndry_vect_out            => open
    );





GEN_FSYNC_SEL_CROSSING : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then

		fsync_src_select_cdc_tig <= fsync_src_select;
		fsync_src_select_d1      <= fsync_src_select_cdc_tig;

        end if;
    end process GEN_FSYNC_SEL_CROSSING;
fsync_src_select_s_int <= fsync_src_select_d1;



GEN_FOR_ASYNC_CROSS_FSYNC : if C_INCLUDE_MM2S = 1 generate
begin


----    CROSS_FSYNC_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_mm2s_aclk                               ,
----            prmry_resetn            => mm2s_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => mm2s_fsync                         ,
----            scndry_out              => mm2s_fsync_s2mm_s                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


CROSS_FSYNC_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_mm2s_aclk,
        prmry_resetn               => mm2s_axis_resetn, 
        prmry_in                   => mm2s_fsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mm2s_fsync_s2mm_s,
        scndry_vect_out            => open
    );




end generate GEN_FOR_ASYNC_CROSS_FSYNC;

GEN_FOR_ASYNC_NO_CROSS_FSYNC : if C_INCLUDE_MM2S = 0 generate
begin

mm2s_fsync_s2mm_s <= '0';

end generate GEN_FOR_ASYNC_NO_CROSS_FSYNC;


end generate GEN_FOR_ASYNC_FLUSH_SOF;



-- Synchronous clock therefore just map signals across
GEN_FOR_SYNC_FLUSH_SOF : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    crnt_vsize_d2               <= crnt_vsize;
    mmap_not_finished_s         <= mmap_not_finished;
    fsync_src_select_s_int          <= fsync_src_select;
    dm_halt_reg                 <= dm_halt;
    --dm_halt_cmplt_s                 <= dm_halt_cmplt;
    run_stop_reg                <= run_stop;
    p_fsync_out                 <= fsync_out;
    s2mm_tuser_fsync_sig        <= tuser_fsync;
    s_data_count_af_thresh      <= data_count_af_threshold;


GEN_FOR_SYNC_CROSS_FSYNC : if C_INCLUDE_MM2S = 1 generate
begin

    mm2s_fsync_s2mm_s           <= mm2s_fsync;

end generate GEN_FOR_SYNC_CROSS_FSYNC;

GEN_FOR_SYNC_NO_CROSS_FSYNC : if C_INCLUDE_MM2S = 0 generate
begin

mm2s_fsync_s2mm_s <= '0';

end generate GEN_FOR_SYNC_NO_CROSS_FSYNC;




end generate GEN_FOR_SYNC_FLUSH_SOF;

--*****************************************************************************
--** Vertical Line Tracking
--*****************************************************************************

-----------------------GEN_SOF_VCOUNT : if C_S2MM_SOF_ENABLE = 1 generate
-----------------------begin


    -- decrement based on master axis signals for determining done (CR623449)
    done_decr_vcount <= '1' when m_axis_tlast_i = '1'
                             and m_axis_tvalid_i = '1'
                             and m_axis_tready = '1'
              else '0';


    -- CR623449 - base done on master clock domain
    DONE_VERT_COUNTER_FLUSH_SOF : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                if((m_axis_fifo_ainit = '1' and p_fsync_out = '0') or s2mm_fsize_mismatch_err_flag = '1')then
                    done_vsize_counter   <= (others => '0');
                    mmap_not_finished <= '0';
                elsif(p_fsync_out = '1')then
                    done_vsize_counter   <= crnt_vsize;
                    mmap_not_finished <= '1';

                elsif(done_decr_vcount = '1' and done_vsize_counter = VSIZE_ONE_VALUE)then
                    done_vsize_counter   <= (others => '0');
                    mmap_not_finished <= '0';

                elsif(done_decr_vcount = '1' and done_vsize_counter /= VSIZE_ZERO_VALUE)then
                    done_vsize_counter   <= std_logic_vector(unsigned(done_vsize_counter) - 1);
                    mmap_not_finished <= '1';

                end if;
            end if;
        end process DONE_VERT_COUNTER_FLUSH_SOF;


delay_s2mm_fsync_core_till_mmap_done    <= '1'  when  mmap_not_finished_s = '1' and  strm_not_finished = '0' and s2mm_fsync_int = '1' and delay_s2mm_fsync_core_till_mmap_done_flag = '0'
                                    else '0';


hold_dummy_tready_low <= delay_s2mm_fsync_core_till_mmap_done or delay_s2mm_fsync_core_till_mmap_done_flag;

HOLD_DELAY_FSYNC_IN_FLAG : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_resetn = '0' or mmap_not_finished_s = '0' or sig_drop_fsync_d_pulse_gen_fsize_less_err = '1')then
                delay_s2mm_fsync_core_till_mmap_done_flag  <= '0';
            elsif(delay_s2mm_fsync_core_till_mmap_done = '1')then
                delay_s2mm_fsync_core_till_mmap_done_flag  <= '1';
            end if;
        end if;
    end process HOLD_DELAY_FSYNC_IN_FLAG;



D1_HOLD_DELAY_FSYNC_IN_FLAG : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_resetn = '0' or sig_drop_fsync_d_pulse_gen_fsize_less_err = '1')then
                delay_s2mm_fsync_core_till_mmap_done_flag_d1  <= '0';
            else
                delay_s2mm_fsync_core_till_mmap_done_flag_d1  <= delay_s2mm_fsync_core_till_mmap_done_flag;
            end if;
        end if;
    end process D1_HOLD_DELAY_FSYNC_IN_FLAG;


s2mm_fsync_d_pulse <= delay_s2mm_fsync_core_till_mmap_done_flag_d1 and (not delay_s2mm_fsync_core_till_mmap_done_flag) ;





s2mm_fsync_core <= (s2mm_fsync_int and not (delay_s2mm_fsync_core_till_mmap_done) and not (delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s)) or s2mm_fsync_d_pulse or d_fsync_halt_cmplt_s;


sig_drop_fsync_d_pulse_gen_fsize_less_err    <= '1'  when  delay_s2mm_fsync_core_till_mmap_done_flag = '1' and s2mm_fsync_int = '1'
                                        else '0';




GEN_FOR_C_USE_S2MM_FSYNC_1 : if C_USE_S2MM_FSYNC = 1 generate
begin
                 s2mm_fsync_int <= s2mm_fsync and run_stop_reg and no_fsync_before_vsize_sel_00_01;

end generate GEN_FOR_C_USE_S2MM_FSYNC_1;


GEN_FOR_C_USE_S2MM_FSYNC_2 : if C_USE_S2MM_FSYNC = 2 generate
begin
                 s2mm_fsync_int <= s2mm_tuser_fsync_top and run_stop_reg;

end generate GEN_FOR_C_USE_S2MM_FSYNC_2;




        -- Frame sync cross bar
------        FSYNC_CROSSBAR_S2MM_S : process(fsync_src_select_s_int,
------                                 run_stop_reg,
------                                 s2mm_fsync,
------                                 mm2s_fsync_s2mm_s, no_fsync_before_vsize_sel_00_01,
------                                 s2mm_tuser_fsync_top)
------            begin
------                case fsync_src_select_s_int is
------
------                    when "00" =>   -- primary fsync (default)
------                        s2mm_fsync_int <= s2mm_fsync and run_stop_reg and no_fsync_before_vsize_sel_00_01;
------                    when "01" =>   -- other channel fsync
------                        s2mm_fsync_int <= mm2s_fsync_s2mm_s and run_stop_reg and no_fsync_before_vsize_sel_00_01;
------                    when "10" =>   -- s2mm_tuser_fsync_top fsync  (used only by s2mm)
------                        s2mm_fsync_int <= s2mm_tuser_fsync_top and run_stop_reg;
------                    when others =>
------                        s2mm_fsync_int <= '0';
------                end case;
------            end process FSYNC_CROSSBAR_S2MM_S;
------

-----------------------end generate GEN_SOF_VCOUNT;


S2MM_FSIZE_ERR_TO_DM_HALT_FLAG : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_resetn = '0' or dm_halt_reg = '1')then
                fsize_err_to_dm_halt_flag  <= '0';
            elsif(s2mm_fsize_mismatch_err_s = '1')then
                fsize_err_to_dm_halt_flag  <= '1';
            end if;
        end if;
    end process S2MM_FSIZE_ERR_TO_DM_HALT_FLAG;



fsize_err_to_dm_halt_flag_ored <= s2mm_fsize_mismatch_err_s or fsize_err_to_dm_halt_flag or dm_halt_reg;



delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s    <= '1'  when  fsize_err_to_dm_halt_flag_ored = '1' and s2mm_fsync_int = '1' 
                                    else '0';


FSIZE_LESS_DM_HALT_CMPLT_FLAG : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_resetn = '0' or fsize_err_to_dm_halt_flag_ored = '0')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s  <= '0';
            elsif(delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s = '1')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s  <= '1';
            end if;
        end if;
    end process FSIZE_LESS_DM_HALT_CMPLT_FLAG;

REG_D_FSYNC : process(s_axis_aclk)
    begin
        if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
            if(s_axis_resetn = '0')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1  <= '0';
            else
                delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1  <= delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s;
            end if;
        end if;
    end process REG_D_FSYNC;


d_fsync_halt_cmplt_s <= delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1 and not delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s;


hold_dummy_tready_low2 <= delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s or delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s;


s2mm_all_lines_xfred <= '0';
all_lasts_rcvd <= '0';
tuser_fsync <= '0';
fsync_src_select_s <= fsync_src_select_s_int;
drop_fsync_d_pulse_gen_fsize_less_err <= sig_drop_fsync_d_pulse_gen_fsize_less_err;

end generate GEN_S2MM_FLUSH_SOF_LOGIC;





end implementation;
