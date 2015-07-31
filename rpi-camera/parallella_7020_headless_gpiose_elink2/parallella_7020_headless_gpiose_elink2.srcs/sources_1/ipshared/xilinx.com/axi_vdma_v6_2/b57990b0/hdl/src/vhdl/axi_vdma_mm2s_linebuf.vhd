-------------------------------------------------------------------------------
-- axi_vdma_mm2s_linebuf
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
-- Filename:          axi_vdma_mm2s_linebuf.vhd
-- Description: This entity encompases the mm2s line buffer logic
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
entity  axi_vdma_mm2s_linebuf is
    generic (
        C_DATA_WIDTH                	: integer range 8 to 1024           := 32;
        C_M_AXIS_MM2S_TDATA_WIDTH   	: integer range 8 to 1024           	:= 32;
            -- Line Buffer Data Width

        C_INCLUDE_S2MM              	: integer range 0 to 1              	:= 0;
        C_INCLUDE_MM2S_SF           	: integer range 0 to 1              	:= 0;
            -- Include or exclude MM2S Store And Forward Functionality
            -- 0 = Exclude MM2S Store and Forward
            -- 1 = Include MM2S Store and Forward
        C_INCLUDE_MM2S_DRE              : integer range 0 to 1      	:= 0;

        C_MM2S_SOF_ENABLE               : integer range 0 to 1      		:= 0;
            -- Enable/Disable start of frame generation on tuser(0). This
            -- is only valid for external frame sync (C_USE_FSYNC = 1)
            -- 0 = disable SOF
            -- 1 = enable SOF

        C_M_AXIS_MM2S_TUSER_BITS        : integer range 1 to 1          	:= 1;
            -- Master AXI Stream User Width for MM2S Channel

        C_TOPLVL_LINEBUFFER_DEPTH   	: integer range 0 to 65536          	:= 512; -- CR625142
            -- Depth as set by user at top level parameter

        C_LINEBUFFER_DEPTH          	: integer range 0 to 65536          	:= 512;
            -- Linebuffer depth in Bytes. Must be a power of 2

        C_LINEBUFFER_AE_THRESH       	: integer range 1 to 65536         	:= 1;
            -- Linebuffer almost empty threshold in Bytes. Must be a power of 2

        C_PRMRY_IS_ACLK_ASYNC       	: integer range 0 to 1              	:= 0 ;
            -- Primary MM2S/S2MM sync/async mode
            -- 0 = synchronous mode     - all clocks are synchronous
            -- 1 = asynchronous mode    - Primary data path channels (MM2S and S2MM)
            --                            run asynchronous to AXI Lite, DMA Control,
            --                            and SG.
          --C_ENABLE_DEBUG_INFO             : string := "1111111111111111";		-- 1 to 16 -- 
        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '1');		--15 downto 0  -- 
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

        ENABLE_FLUSH_ON_FSYNC       	: integer range 0 to 1        		:= 0      ;

        C_FAMILY                    	: string            			:= "virtex7"
            -- Device family used for proper BRAM selection
    );
    port (
        -- MM2S AXIS Input Side (i.e. Datamover side)
        s_axis_aclk                 : in  std_logic                         ;   --
        s_axis_resetn               : in  std_logic                         ;   --
                                                                                --
        -- MM2S AXIS Output Side                                                --
        m_axis_aclk                 : in  std_logic                         ;   --
        m_axis_resetn               : in  std_logic                         ;   --
        mm2s_axis_linebuf_reset_out : out  std_logic                         ;   --

        s2mm_axis_resetn            : in  std_logic           := '1'              ;                   --
        s_axis_s2mm_aclk            : in  std_logic           := '0'              ;                   --

        mm2s_fsync                  : in  std_logic                         ;   --
        s2mm_fsync                  : in  std_logic                         ;   --
        mm2s_fsync_core             : out  std_logic                         ;   --
        mm2s_fsize_mismatch_err_s   : out  std_logic                         ;   --
        mm2s_fsize_mismatch_err_m   : out  std_logic                         ;   --
        mm2s_vsize_cntr_clr_flag    : out  std_logic                         ;   --
MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S   : out  std_logic                         ;   --

        fsync_src_select            : in  std_logic_vector(1 downto 0)      ;           --

                                                                                --
        run_stop                    : in  std_logic                         ;   --
        -- Graceful shut down control                                           --
        dm_halt                     : in  std_logic                         ;   --
        dm_halt_reg_out             : out  std_logic                         ;   --
        cmdsts_idle                 : in  std_logic                         ;   --
        stop                        : in  std_logic                         ;   -- CR623291
        stop_reg_out                : out  std_logic                         ;   -- CR623291
                                                                                --
        -- Vertical Line Count control                                          --
        fsync_out                   : in  std_logic                         ;   -- CR616211
        fsync_out_m                 : out  std_logic                         ;   -- CR616211
        mm2s_fsize_mismatch_err_flag: in  std_logic                         ;   -- CR616211
        frame_sync                  : in  std_logic                         ;   -- CR616211
        crnt_vsize                  : in  std_logic_vector                      --
                                        (VSIZE_DWIDTH-1 downto 0)           ;   -- CR616211
        crnt_vsize_d2_out           : out  std_logic_vector                      --
                                        (VSIZE_DWIDTH-1 downto 0)           ;   -- CR616211
                                                                             --
        linebuf_threshold           : in  std_logic_vector                      --
                                        (LINEBUFFER_THRESH_WIDTH-1 downto 0);   --
                                                                                --
        -- Stream In (Datamover To Line Buffer)                                 --
        s_axis_tdata                : in  std_logic_vector                      --
                                        (C_DATA_WIDTH-1 downto 0)           ;   --
        s_axis_tkeep                : in  std_logic_vector                      --
                                        ((C_DATA_WIDTH/8)-1 downto 0)       ;   --
        s_axis_tlast                : in  std_logic                         ;   --
        s_axis_tvalid               : in  std_logic                         ;   --
        s_axis_tready               : out std_logic                         ;   --
                                                                                --
                                                                                --
        -- Stream Out (Line Buffer To MM2S AXIS)                                --
        m_axis_tdata                : out std_logic_vector                      --
                                        (C_DATA_WIDTH-1 downto 0)           ;   --
        m_axis_tkeep                : out std_logic_vector                      --
                                        ((C_DATA_WIDTH/8)-1 downto 0)       ;   --
        m_axis_tlast                : out std_logic                         ;   --
        m_axis_tvalid               : out std_logic                         ;   --
        m_axis_tready               : in  std_logic                         ;   --
        m_axis_tuser                : out std_logic_vector                      --
                                        (C_M_AXIS_MM2S_TUSER_BITS-1 downto 0);  --
                                                                                --
        -- Fifo Status Flags                                                    --
        dwidth_fifo_pipe_empty      : in std_logic                         ;   --
        dwidth_fifo_pipe_empty_m    : out std_logic                         ;   --
        mm2s_fifo_pipe_empty        : out std_logic                         ;   --
        mm2s_fifo_empty             : out std_logic                         ;   --
        mm2s_fifo_almost_empty      : out std_logic                         ;   --
        mm2s_all_lines_xfred_s_dwidth      : in std_logic                         ;   --
        mm2s_all_lines_xfred_s      : out std_logic                         ;   --
        mm2s_all_lines_xfred        : out std_logic                             -- CR616211
    );

end axi_vdma_mm2s_linebuf;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_mm2s_linebuf is
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
-- Increase data width by 1 when tuser support included.
--constant BUFFER_WIDTH           : integer := C_DATA_WIDTH + (C_DATA_WIDTH/8) + 1;
constant BUFFER_WIDTH           : integer := C_DATA_WIDTH           -- tdata
                                          + (C_DATA_WIDTH/8)*C_INCLUDE_MM2S_DRE        -- tkeep
                                          + 1                       -- tlast
                                          + (C_MM2S_SOF_ENABLE      -- tuser
                                            *C_M_AXIS_MM2S_TUSER_BITS);






-- Buffer data count width
constant DATACOUNT_WIDTH        : integer := clog2(BUFFER_DEPTH);


constant DATA_COUNT_ZERO                : std_logic_vector(DATACOUNT_WIDTH-1 downto 0)
                                        := (others => '0');

constant USE_BRAM_FIFOS                 : integer   := 1; -- Use BRAM FIFOs


constant ZERO_VALUE_VECT                : std_logic_vector(255 downto 0) := (others => '0');

-- Constants for line tracking logic
constant VSIZE_ONE_VALUE            : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := std_logic_vector(to_unsigned(1,VSIZE_DWIDTH));

constant VSIZE_ZERO_VALUE           : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                        := (others => '0');

-- Linebuffer threshold support
constant THRESHOLD_LSB_INDEX        : integer := clog2((C_DATA_WIDTH/8));
constant THRESHOLD_PAD              : std_logic_vector(THRESHOLD_LSB_INDEX-1 downto 0)  := (others => '0');


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal fifo_din                     : std_logic_vector(BUFFER_WIDTH - 1 downto 0) := (others => '0');
signal fifo_dout                    : std_logic_vector(BUFFER_WIDTH - 1 downto 0) := (others => '0');
signal fifo_wren                    : std_logic := '0';
signal fifo_rden                    : std_logic := '0';
signal fifo_empty_i                 : std_logic := '0';
signal fifo_full_i                  : std_logic := '0';
signal fifo_ainit                   : std_logic := '0';
signal fifo_rdcount                 : std_logic_vector(DATACOUNT_WIDTH -1 downto 0) := (others => '0');

signal s_axis_tready_i              : std_logic := '0'; -- CR619293
signal m_axis_tready_i              : std_logic := '0';
signal m_axis_tvalid_i              : std_logic := '0';
signal m_axis_tlast_i               : std_logic := '0';
signal m_axis_tdata_i               : std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others => '0');
signal m_axis_tkeep_i               : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal m_axis_tkeep_signal          : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal s_axis_tkeep_signal          : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal m_axis_tuser_i               : std_logic_vector(C_M_AXIS_MM2S_TUSER_BITS - 1 downto 0) := (others => '0');

signal m_axis_tready_d1             : std_logic := '0';
signal m_axis_tlast_d1              : std_logic := '0';
signal m_axis_tvalid_d1             : std_logic := '0';

signal crnt_vsize_cdc_tig           : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');  -- CR575884
signal crnt_vsize_d1                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');  -- CR575884
signal crnt_vsize_d2                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');  -- CR575884
signal vsize_counter                : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');  -- CR575884
signal decr_vcount                  : std_logic := '0';                                              -- CR575884
signal all_lines_xfred              : std_logic := '0'; -- CR616211
signal all_lines_xfred_no_dwidth    : std_logic := '0'; -- CR616211
signal mm2s_all_lines_xfred_s_sig   : std_logic := '0'; -- CR616211

signal m_axis_tvalid_out            : std_logic := '0'; -- CR576993
signal m_axis_tlast_out             : std_logic := '0'; -- CR616211
signal slv2skid_s_axis_tvalid       : std_logic := '0'; -- CR576993
signal fifo_empty_d1                : std_logic := '0'; -- CR576993

-- FIFO Pipe empty signals
signal fifo_pipe_empty              : std_logic := '0';
signal fifo_wren_d1                 : std_logic := '0'; -- CR579191
signal pot_empty                    : std_logic := '0'; -- CR579191

signal fifo_almost_empty_i          : std_logic := '1'; -- CR604273/CR604272
signal fifo_almost_empty_d1         : std_logic := '1';
signal fifo_almost_empty_fe         : std_logic := '0'; -- CR604273/CR604272

signal fifo_almost_empty_reg        : std_logic := '1';
signal data_count_ae_threshold_cdc_tig      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal data_count_ae_threshold_d1      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal data_count_ae_threshold      : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal m_data_count_ae_thresh       : std_logic_vector(DATACOUNT_WIDTH-1 downto 0) := (others => '0');
signal sf_threshold_met             : std_logic := '0';

signal cmdsts_idle_d1               : std_logic := '0';
signal cmdsts_idle_fe               : std_logic := '0';
signal stop_reg                     : std_logic := '0'; --CR623291

signal s_axis_fifo_ainit            : std_logic := '0';
signal m_axis_fifo_ainit            : std_logic := '0';
signal s_axis_fifo_ainit_nosync     : std_logic := '0';
signal m_axis_fifo_ainit_nosync     : std_logic := '0';
signal dm_decr_vcount               : std_logic := '0';                                                 -- CR619293
signal dm_xfred_all_lines           : std_logic := '0';                                                 -- CR619293
signal dm_vsize_counter             : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');     -- CR619293
signal dm_xfred_all_lines_reg       : std_logic := '0';                                                 -- CR619293

signal sof_flag                     : std_logic := '0';
signal mm2s_fifo_pipe_empty_i       : std_logic := '0';
signal frame_sync_d1                : std_logic := '0';

signal m_skid_reset                 : std_logic := '0';
signal dm_halt_reg                  : std_logic := '0';
signal mm2s_axis_linebuf_reset_out_inv : std_logic       := '0'                  ;   --
signal sof_reset 		    : std_logic := '0';

signal wr_rst_busy_sig              : std_logic := '0';
signal rd_rst_busy_sig              : std_logic := '0';                  



  ATTRIBUTE async_reg                      : STRING;

  ATTRIBUTE async_reg OF crnt_vsize_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF crnt_vsize_d1       : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF data_count_ae_threshold_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF data_count_ae_threshold_d1       : SIGNAL IS "true"; 

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin
mm2s_fifo_pipe_empty 	<= mm2s_fifo_pipe_empty_i;
dm_halt_reg_out 	<= dm_halt_reg;
stop_reg_out 		<= stop_reg;
crnt_vsize_d2_out 	<= crnt_vsize_d2;

GEN_MM2S_DRE_ON : if C_INCLUDE_MM2S_DRE = 1 generate
begin

m_axis_tkeep 	    <= m_axis_tkeep_signal;
s_axis_tkeep_signal <= s_axis_tkeep;

end generate GEN_MM2S_DRE_ON;

GEN_MM2S_DRE_OFF : if C_INCLUDE_MM2S_DRE = 0 generate
begin

m_axis_tkeep 	    <= (others => '1');
s_axis_tkeep_signal <= (others => '1');

end generate GEN_MM2S_DRE_OFF;

    GEN_LINEBUF_NO_SOF : if (ENABLE_FLUSH_ON_FSYNC = 0 or C_MM2S_SOF_ENABLE = 0) generate
    begin

	mm2s_fsync_core 			<= mm2s_fsync;
	MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S <= '0';
	mm2s_fsize_mismatch_err_s 		<= '0';



--*****************************************************************************--
--**              LINE BUFFER MODE (Sync or Async)                           **--
--*****************************************************************************--
GEN_LINEBUFFER : if C_LINEBUFFER_DEPTH /= 0 generate
begin

    -- Divide by number bytes per data beat and add padding to dynamic
    -- threshold setting
    data_count_ae_threshold <= linebuf_threshold((DATACOUNT_WIDTH-1) + THRESHOLD_LSB_INDEX
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
                 data_count        => fifo_rdcount  
            );

--wr_rst_busy_sig <= '0';
--rd_rst_busy_sig <= '0';

    end generate GEN_SYNC_FIFO;

    -- Asynchronous clock therefore instantiate an Asynchronous FIFO
    GEN_ASYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
    begin
LB_BRAM : if ( (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1) )
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
                -- Inputs
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
                 wr_data_count   => open         , --CR622702
                 rd_data_count   => fifo_rdcount         
            );

wr_rst_busy_sig <= '0';
rd_rst_busy_sig <= '0';

end generate LB_BRAM;                     


      
LB_BUILT_IN : if ( (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0) )
  generate   
    begin

        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo_builtin
            generic map(
                 PL_FIFO_TYPE    => "BUILT_IN"                    ,
                 PL_READ_MODE    => "FWFT"                    ,
                 PL_FASTER_CLOCK => "WR_CLK"                    , --RD_CLK
                 PL_FULL_FLAGS_RST_VAL => 0                     , -- ?
                 PL_DATA_WIDTH   => BUFFER_WIDTH                    ,
                 C_FAMILY        => C_FAMILY ,
                 PL_FIFO_DEPTH   => BUFFER_DEPTH                    
            )
            port map(
                -- Inputs
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




    -- Generate an SOF on tuser(0). currently vdma only support 1 tuser bit that is set by
    -- frame sync and driven out on first data beat of mm2s packet.
   GEN_SOF : if ENABLE_FLUSH_ON_FSYNC = 0 and C_MM2S_SOF_ENABLE = 1 generate
   --signal sof_reset : std_logic := '0';
   begin
       sof_reset   <= '1' when (s_axis_resetn = '0')
                            or (dm_halt = '1')
                 else '0';

       -- On frame sync set flag and then clear flag when
       -- sof written to fifo.
       SOF_FLAG_PROCESS : process(s_axis_aclk)
           begin
               if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                   if(sof_reset = '1' or fifo_wren = '1')then
                       sof_flag <= '0';
                   elsif(frame_sync = '1')then
                       sof_flag <= '1';
                   end if;
               end if;
           end process SOF_FLAG_PROCESS;

   GEN_MM2S_DRE_ENABLED_TKEEP : if C_INCLUDE_MM2S_DRE = 1 generate
   begin

       -- AXI Slave Side of FIFO
       fifo_din            <= sof_flag & s_axis_tlast & s_axis_tkeep_signal & s_axis_tdata;
       fifo_wren           <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
       s_axis_tready       <= s_axis_tready_i; -- CR619293

       -- AXI Master Side of FIFO
       fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
       m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
       m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
       m_axis_tkeep_i      <= fifo_dout(BUFFER_WIDTH-3 downto (BUFFER_WIDTH-3) - (C_DATA_WIDTH/8) + 1);
       m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-2);
       m_axis_tuser_i(0)   <= fifo_dout(BUFFER_WIDTH-1);

   end generate GEN_MM2S_DRE_ENABLED_TKEEP;

   GEN_NO_MM2S_DRE_DISABLE_TKEEP : if C_INCLUDE_MM2S_DRE = 0 generate
   begin

       -- AXI Slave Side of FIFO
       fifo_din            <= sof_flag & s_axis_tlast & s_axis_tdata;
       fifo_wren           <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i     <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
       s_axis_tready       <= s_axis_tready_i; -- CR619293

       -- AXI Master Side of FIFO
       fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
       m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
       m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
       m_axis_tkeep_i      <= (others => '1');
       m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-2);
       m_axis_tuser_i(0)   <= fifo_dout(BUFFER_WIDTH-1);

   end generate GEN_NO_MM2S_DRE_DISABLE_TKEEP;


   end generate GEN_SOF;


   -- SOF turned off therefore do not generate SOF on tuser
   GEN_NO_SOF : if C_MM2S_SOF_ENABLE = 0 generate
   begin
   GEN_MM2S_DRE_ENABLED_TKEEP : if C_INCLUDE_MM2S_DRE = 1 generate
   begin


        sof_flag <= '0';

        -- AXI Slave Side of FIFO
        fifo_din            <= s_axis_tlast & s_axis_tkeep_signal & s_axis_tdata;
       fifo_wren            <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i      <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
        s_axis_tready       <= s_axis_tready_i; -- CR619293

        -- AXI Master Side of FIFO
        fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
        m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
        m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
        m_axis_tkeep_i      <= fifo_dout(BUFFER_WIDTH-2 downto (BUFFER_WIDTH-2) - (C_DATA_WIDTH/8) + 1);
        m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);
        m_axis_tuser_i      <= (others => '0');

   end generate GEN_MM2S_DRE_ENABLED_TKEEP;

   GEN_NO_MM2S_DRE_DISABLE_TKEEP : if C_INCLUDE_MM2S_DRE = 0 generate
   begin

        sof_flag <= '0';

        -- AXI Slave Side of FIFO
        fifo_din            <= s_axis_tlast & s_axis_tdata;
       fifo_wren            <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i      <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
        s_axis_tready       <= s_axis_tready_i; -- CR619293

        -- AXI Master Side of FIFO
        fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
        m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
        m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
        m_axis_tkeep_i      <= (others => '1');
        m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-1);
        m_axis_tuser_i      <= (others => '0');


   end generate GEN_NO_MM2S_DRE_DISABLE_TKEEP;


    end generate GEN_NO_SOF;

    -- Top level line buffer depth not equal to zero therefore gererate threshold
    -- flags. (CR625142)
    GEN_THRESHOLD_ENABLED : if C_TOPLVL_LINEBUFFER_DEPTH /= 0 and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin

        -- Almost empty flag (note: asserts when empty also)
    
      
        REG_ALMST_EMPTY : process(m_axis_aclk)
            begin
                if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                    if(m_axis_fifo_ainit = '1')then
                        fifo_almost_empty_reg <= '1';
                    --elsif(fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= DATA_COUNT_AE_THRESHOLD or fifo_empty_i = '1')then
                    --elsif((fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= m_data_count_ae_thresh
                    --  or fifo_empty_i = '1') and fifo_full_i = '0')then
                    elsif((fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= m_data_count_ae_thresh
                      or (fifo_empty_i = '1' or rd_rst_busy_sig = '1')))then
                        fifo_almost_empty_reg <= '1';
                    else
                        fifo_almost_empty_reg <= '0';
                    end if;
                end if;
            end process REG_ALMST_EMPTY;


        mm2s_fifo_almost_empty  <= fifo_almost_empty_reg
                                or (not sf_threshold_met) -- CR622777
                                or (not m_axis_tvalid_out); -- CR625724

        mm2s_fifo_empty         <= not m_axis_tvalid_out;
    end generate GEN_THRESHOLD_ENABLED;

    -- Top level line buffer depth is zero therefore turn off threshold logic.
    -- this occurs for async operation where the async fifo is needed for CDC (CR625142)
    GEN_THRESHOLD_DISABLED  : if C_TOPLVL_LINEBUFFER_DEPTH = 0 or (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        mm2s_fifo_empty             <= '0';
        mm2s_fifo_almost_empty      <= '0';
        fifo_almost_empty_reg       <= '0';
    end generate GEN_THRESHOLD_DISABLED;

    -- CR#578903
    -- FIFO, FIFO Pipe, and Skid Buffer are all empty.  This is used to safely
    -- assert reset on shutdown and also used to safely generate fsync in free-run mode
    -- CR622702 - need to look at write side of fifo to prevent false empties due to async fifo
    --fifo_pipe_empty <= '1' when (fifo_wrcount(DATACOUNT_WIDTH-1 downto 0) = DATA_COUNT_ZERO -- Data count is 0
    --                                and m_axis_tvalid_out = '0')                            -- Skid Buffer is done
    --                        -- Forced stop and Threshold not met (CR623291)
    --                        or  (sf_threshold_met = '0' and stop_reg = '1')
    --              else '0';
    -- CR623879 fixed flase fifo_pipe_assertions due to extreme AXI4 throttling on
    -- mm2s reads causing fifo to go empty for extended periods of time.  This then
    -- caused flase idles to be flagged and frame syncs were then generated in free run mode
--------    fifo_pipe_empty <= '1' when (all_lines_xfred = '1' and m_axis_tvalid_out = '0') -- All data for frame transmitted
--------                            or  (sf_threshold_met = '0'              -- Or Threshold not met
--------                                and stop_reg = '1'                   -- Commanded to stop
--------                                and m_axis_tvalid_out = '0')         -- And NOT driving tvalid
--------                  else '0';
--------

    -- If store and forward is turned on by user then gate tvalid with
    -- threshold met
    GEN_THRESH_MET_FOR_SNF : if C_INCLUDE_MM2S_SF = 1  and C_TOPLVL_LINEBUFFER_DEPTH /= 0 and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin
            -- Register fifo_almost empty in order to generate
            -- almost empty fall edge pulse
            REG_ALMST_EMPTY_FE : process(m_axis_aclk)
                begin
                    if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                        if(m_axis_fifo_ainit = '1')then
                            fifo_almost_empty_d1 <= '1';
                        else
                            fifo_almost_empty_d1 <= fifo_almost_empty_reg;
                        end if;
                    end if;
                end process REG_ALMST_EMPTY_FE;

            -- Almost empty falling edge
            fifo_almost_empty_fe <= not fifo_almost_empty_reg and fifo_almost_empty_d1;

            -- Store and Forward threshold met
            THRESH_MET : process(m_axis_aclk)
                begin
                    if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                        if(m_axis_fifo_ainit = '1')then
                            sf_threshold_met <= '0';
                        elsif(fsync_out = '1')then
                            sf_threshold_met <= '0';
                        -- Reached threshold or all reads done for the frame
                        elsif(fifo_almost_empty_fe = '1'
                          or (dm_xfred_all_lines_reg = '1'))then
                            sf_threshold_met <= '1';
                        end if;
                    end if;
                end process THRESH_MET;

    end generate GEN_THRESH_MET_FOR_SNF;

    -- Store and forward off therefore do not need to meet threshold
    GEN_NO_THRESH_MET_FOR_SNF : if C_INCLUDE_MM2S_SF = 0  or C_TOPLVL_LINEBUFFER_DEPTH = 0  or (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        sf_threshold_met <= '1';
    end generate GEN_NO_THRESH_MET_FOR_SNF;


    --*********************************************************--
    --**               MM2S MASTER SKID BUFFER               **--
    --*********************************************************--
    I_MSTR_SKID : entity axi_vdma_v6_2.axi_vdma_skid_buf
        generic map(
            C_WDATA_WIDTH           => C_DATA_WIDTH             ,
            C_TUSER_WIDTH           => C_M_AXIS_MM2S_TUSER_BITS
        )
        port map(
            -- System Ports
            ACLK                   => m_axis_aclk               ,
            ARST                   => m_axis_fifo_ainit_nosync              ,

            -- Shutdown control (assert for 1 clk pulse)
            skid_stop              => '0'                       ,

            -- Slave Side (Stream Data Input)
            S_VALID                => m_axis_tvalid_i           ,
            S_READY                => m_axis_tready_i           ,
            S_Data                 => m_axis_tdata_i            ,
            S_STRB                 => m_axis_tkeep_i            ,
            S_Last                 => m_axis_tlast_i            ,
            S_User                 => m_axis_tuser_i            ,

            -- Master Side (Stream Data Output)
            M_VALID                => m_axis_tvalid_out         ,
            M_READY                => m_axis_tready             ,
            M_Data                 => m_axis_tdata              ,
            M_STRB                 => m_axis_tkeep_signal              ,
            M_Last                 => m_axis_tlast_out          ,
            M_User                 => m_axis_tuser
        );

    -- Pass out of core
    m_axis_tvalid   <= m_axis_tvalid_out;
    m_axis_tlast    <= m_axis_tlast_out;

    -- Register to break long timing paths for use in
    -- transfer complete generation
    REG_STRM_SIGS : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                if(m_axis_fifo_ainit = '1')then
                    m_axis_tlast_d1     <= '0';
                    m_axis_tvalid_d1    <= '0';
                    m_axis_tready_d1    <= '0';
                else
                    m_axis_tlast_d1     <= m_axis_tlast_out;
                    m_axis_tvalid_d1    <= m_axis_tvalid_out;
                    m_axis_tready_d1    <= m_axis_tready;
                end if;
            end if;
        end process REG_STRM_SIGS;



end generate GEN_LINEBUFFER;

--*****************************************************************************--
--**               NO LINE BUFFER MODE (Sync Only)                           **--
--*****************************************************************************--
-- LineBuffer forced on if asynchronous mode is enabled
GEN_NO_LINEBUFFER : if (C_LINEBUFFER_DEPTH = 0) generate     -- No Line Buffer
begin

    -- Map Datamover to AXIS Master Out
    m_axis_tdata        <= s_axis_tdata;
    m_axis_tkeep_signal <= s_axis_tkeep_signal;
    m_axis_tvalid       <= s_axis_tvalid;
    m_axis_tlast        <= s_axis_tlast;

    s_axis_tready       <= m_axis_tready;

    -- Tie FIFO Flags off
    mm2s_fifo_empty          <= '0';
    mm2s_fifo_almost_empty   <= '0';


    -- Generate sof on tuser(0)
    GEN_SOF : if C_MM2S_SOF_ENABLE = 1 generate
    begin
        -- On frame sync set flag and then clear flag when
        -- sof written to fifo.
        SOF_FLAG_PROCESS : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit = '1' or (s_axis_tvalid = '1' and m_axis_tready = '1'))then
                        sof_flag <= '0';
                    elsif(frame_sync = '1')then
                        sof_flag <= '1';
                    end if;
                end if;
            end process SOF_FLAG_PROCESS;

        m_axis_tuser(0) <= sof_flag;

    end generate GEN_SOF;

    -- Do not generate sof on tuser(0)
    GEN_NO_SOF : if C_MM2S_SOF_ENABLE = 0 generate
    begin
        sof_flag        <= '0';
        m_axis_tuser    <= (others => '0');
    end generate GEN_NO_SOF;


    -- CR#578903
    -- Register tvalid to break timing paths for use in
    -- psuedo fifo empty for channel idle generation and
    -- for xfer complete generation.
    REG_STRM_SIGS : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    m_axis_tvalid_d1        <= '0';
                    m_axis_tlast_d1         <= '0';
                    m_axis_tready_d1        <= '0';
                else
                    m_axis_tvalid_d1        <= s_axis_tvalid;
                    m_axis_tlast_d1         <= s_axis_tlast;
                    m_axis_tready_d1        <= m_axis_tready;
                end if;
            end if;
        end process REG_STRM_SIGS;

    -- CR#578903
    -- Psuedo FIFO, FIFO Pipe, and Skid Buffer are all empty.  This is used to safely
    -- assert reset on shutdown and also used to safely generate fsync in free-run mode
    -- This flag is looked at at the end of frames.
    -- Order of else-if is critical
    -- CR579191 modified method to prevent double fsync assertions
    REG_PIPE_EMPTY : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    fifo_pipe_empty <= '1';

                -- Command/Status not idle indicates pending datamover commands
                -- set psuedo fifo empty to NOT empty.
                elsif(cmdsts_idle_fe = '1')then
                    fifo_pipe_empty <= '0';

                -- On accepted tlast then clear psuedo empty flag back to being empty
                elsif(pot_empty = '1' and cmdsts_idle = '1')then
                    fifo_pipe_empty <= '1';
                end if;
            end if;
        end process REG_PIPE_EMPTY;

    REG_IDLE_FE : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    cmdsts_idle_d1 <= '1';
                else
                    cmdsts_idle_d1 <= cmdsts_idle;
                end if;
            end if;
        end process REG_IDLE_FE;

    -- CR579586 Use falling edge to set pfifo empty
    cmdsts_idle_fe  <= not cmdsts_idle and cmdsts_idle_d1;

    -- CR579191
    POTENTIAL_EMPTY_PROCESS : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    pot_empty <= '1';
                elsif(m_axis_tvalid_d1 = '1' and m_axis_tlast_d1 = '1' and m_axis_tready_d1 = '1')then
                    pot_empty <= '1';
                elsif(m_axis_tvalid_d1 = '1' and m_axis_tlast_d1 = '0')then
                    pot_empty <= '0';
                end if;
            end if;
        end process POTENTIAL_EMPTY_PROCESS;

end generate GEN_NO_LINEBUFFER;


--*****************************************************************************--
--**                    MM2S ASYNCH CLOCK SUPPORT                            **--
--*****************************************************************************--
-- Cross fifo pipe empty flag to secondary clock domain
GEN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

    -- Pipe Empty and Shutdown reset CDC
----    SHUTDOWN_RST_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,
----            prmry_out               => open                                     ,
----            prmry_in                => fifo_pipe_empty                          ,
----            scndry_out              => mm2s_fifo_pipe_empty_i                   ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----


SHUTDOWN_RST_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => fifo_pipe_empty, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mm2s_fifo_pipe_empty_i,
        scndry_vect_out            => open
    );







    -- Vertical Count and All Lines Transferred CDC (CR616211)
----    ALL_LINES_XFRED_P_S_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                       ,   -- CR619293
----            prmry_out               => open                   ,   -- CR619293
----            prmry_in                => all_lines_xfred                          ,
----            scndry_out              => mm2s_all_lines_xfred                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                               ,
----            prmry_vect_out          => open                            ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0) ,
----            scndry_vect_out         => open
----        );
----
----


ALL_LINES_XFRED_P_S_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => all_lines_xfred, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mm2s_all_lines_xfred,
        scndry_vect_out            => open
    );







    -- Vertical Count and All Lines Transferred CDC (CR616211)
----    ALL_LINES_XFRED_S_P_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => dm_xfred_all_lines                       ,   -- CR619293
----            prmry_out               => dm_xfred_all_lines_reg                   ,   -- CR619293
----            prmry_in                => '0'                          ,
----            scndry_out              => open                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                               ,
----            prmry_vect_out          => open                            ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0) ,
----            scndry_vect_out         => open
----        );
----


ALL_LINES_XFRED_S_P_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dm_xfred_all_lines, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => dm_xfred_all_lines_reg,
        scndry_vect_out            => open
    );




VSIZE_CNT_CROSSING : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then

	   crnt_vsize_cdc_tig <= crnt_vsize;
	   crnt_vsize_d1      <= crnt_vsize_cdc_tig;

        end if;
    end process VSIZE_CNT_CROSSING;


	   crnt_vsize_d2 <= crnt_vsize_d1;



    -- Cross stop signal  (CR623291)
----    STOP_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => stop                                     ,
----            prmry_out               => stop_reg                                 ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----

STOP_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => stop_reg,
        scndry_vect_out            => open
    );



    -- Cross datamover halt and threshold signals
----    HALT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => dm_halt                                  ,
----            prmry_out               => dm_halt_reg                              ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                  ,
----            prmry_vect_out          => open                   ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out         => open
----        );
----

HALT_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dm_halt, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => dm_halt_reg,
        scndry_vect_out            => open
    );






THRESH_CNT_CROSSING : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then

	   data_count_ae_threshold_cdc_tig <= data_count_ae_threshold;
	   data_count_ae_threshold_d1      <= data_count_ae_threshold_cdc_tig;

        end if;
    end process THRESH_CNT_CROSSING;


	   m_data_count_ae_thresh <= data_count_ae_threshold_d1;







end generate GEN_FOR_ASYNC;

--*****************************************************************************--
--**                    MM2S SYNCH CLOCK SUPPORT                             **--
--*****************************************************************************--
GEN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    mm2s_fifo_pipe_empty_i      <= fifo_pipe_empty;
    crnt_vsize_d2               <= crnt_vsize;              -- CR616211
    mm2s_all_lines_xfred        <= all_lines_xfred;         -- CR616211
    dm_xfred_all_lines_reg      <= dm_xfred_all_lines;      -- CR619293
    stop_reg                    <= stop;                    -- CR623291
    dm_halt_reg                 <= dm_halt;
    m_data_count_ae_thresh      <= data_count_ae_threshold;

end generate GEN_FOR_SYNC;



--*****************************************************************************
--** Vertical Line Tracking (CR616211)
--*****************************************************************************
-- Decrement vertical count with each accept tlast
decr_vcount <= '1' when m_axis_tlast_d1 = '1'
                    and m_axis_tvalid_d1 = '1'
                    and m_axis_tready_d1 = '1'
          else '0';


-- Drive ready at fsync out then de-assert once all lines have
-- been accepted.
VERT_COUNTER : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_fifo_ainit = '1' and fsync_out = '0')then
                vsize_counter       <= (others => '0');
                all_lines_xfred     <= '1';
            elsif(fsync_out = '1')then
                vsize_counter       <= crnt_vsize_d2;
                all_lines_xfred     <= '0';
            elsif(decr_vcount = '1' and vsize_counter = VSIZE_ONE_VALUE)then
                vsize_counter       <= (others => '0');
                all_lines_xfred     <= '1';

            elsif(decr_vcount = '1' and vsize_counter /= VSIZE_ZERO_VALUE)then
                vsize_counter       <= std_logic_vector(unsigned(vsize_counter) - 1);
                all_lines_xfred     <= '0';

            end if;
        end if;
    end process VERT_COUNTER;

-- Store and forward or no line buffer (CR619293)
GEN_VCOUNT_FOR_SNF : if C_LINEBUFFER_DEPTH /= 0 and C_INCLUDE_MM2S_SF = 1 generate
begin
    dm_decr_vcount <= '1' when s_axis_tlast = '1'
                           and s_axis_tvalid = '1'
                           and s_axis_tready_i = '1'
              else '0';

    -- Delay 1 pipe to align with cnrt_vsize
    REG_FSYNC_TO_ALIGN : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_fifo_ainit = '1' and frame_sync = '0')then
                    frame_sync_d1 <= '0';
                else
                    frame_sync_d1 <= frame_sync;
                end if;
            end if;
        end process REG_FSYNC_TO_ALIGN;

    -- Count lines to determine when datamover done.  Used for snf mode
    -- for threshold met (CR619293)
    DM_DONE     : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_fifo_ainit = '1')then
                    dm_vsize_counter        <= (others => '0');
                    dm_xfred_all_lines      <= '0';
                --elsif(fsync_out = '1')then     -- CR623088
                elsif(frame_sync_d1 = '1')then     -- CR623088
                    dm_vsize_counter       <= crnt_vsize;
                    dm_xfred_all_lines     <= '0';
                elsif(dm_decr_vcount = '1' and dm_vsize_counter = VSIZE_ONE_VALUE)then
                    dm_vsize_counter       <= (others => '0');
                    dm_xfred_all_lines     <= '1';

                elsif(dm_decr_vcount = '1' and dm_vsize_counter /= VSIZE_ZERO_VALUE)then
                    dm_vsize_counter       <= std_logic_vector(unsigned(dm_vsize_counter) - 1);
                    dm_xfred_all_lines     <= '0';

                end if;
            end if;
        end process DM_DONE;

end generate GEN_VCOUNT_FOR_SNF;

-- Not store and forward or no line buffer (CR619293)
GEN_NO_VCOUNT_FOR_SNF : if C_LINEBUFFER_DEPTH = 0 or C_INCLUDE_MM2S_SF = 0 generate
begin
    dm_vsize_counter        <= (others => '0');
    dm_xfred_all_lines      <= '0';
    dm_decr_vcount          <= '0';
end generate GEN_NO_VCOUNT_FOR_SNF;


--*****************************************************************************--
--**                    SPECIAL RESET GENERATION                             **--
--*****************************************************************************--


-- Assert reset to skid buffer on hard reset or on shutdown when fifo pipe empty
-- Waiting for fifo_pipe_empty is required to prevent a AXIS protocol violation
-- when channel shut down early
REG_SKID_RESET : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0')then
                m_skid_reset <= '1';

            elsif(fifo_pipe_empty = '1')then
                if(fsync_out = '1' or dm_halt_reg = '1')then
                    m_skid_reset <= '1';
                else
                    m_skid_reset <= '0';
                end if;
            else
                m_skid_reset <= '0';
            end if;
        end if;
    end process REG_SKID_RESET;

-- Fifo/logic reset for slave side clock domain (m_axi_mm2s_aclk)
-- If error (dm_halt=1) then halt immediatly without protocol violation
s_axis_fifo_ainit <= '1' when s_axis_resetn = '0'
                           or frame_sync = '1'          -- Frame sync
                           or dm_halt = '1'             -- Datamover being halted (halt due to error)
                else '0';

-- Fifo/logic reset for master side clock domain (m_axis_mm2s_aclk)
m_axis_fifo_ainit <= '1' when m_axis_resetn = '0'
                           or fsync_out = '1'           -- Frame sync
                           or dm_halt_reg = '1'         -- Datamover being halted
                else '0';




-- Fifo/logic reset for slave side clock domain (m_axi_mm2s_aclk)
-- If error (dm_halt=1) then halt immediatly without protocol violation
s_axis_fifo_ainit_nosync <= '1' when s_axis_resetn = '0'
                           or dm_halt = '1'             -- Datamover being halted (halt due to error)
                else '0';

-- Fifo/logic reset for master side clock domain (m_axis_mm2s_aclk)
m_axis_fifo_ainit_nosync <= '1' when m_axis_resetn = '0'
                           or dm_halt_reg = '1'         -- Datamover being halted
                else '0';





--reset for axis_dwidth

mm2s_axis_linebuf_reset_out_inv <= m_axis_fifo_ainit_nosync;
mm2s_axis_linebuf_reset_out <= not (mm2s_axis_linebuf_reset_out_inv);



MM2S_DWIDTH_CONV_IS : if (C_DATA_WIDTH /=  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin


fifo_pipe_empty <= dwidth_fifo_pipe_empty;
dwidth_fifo_pipe_empty_m <= mm2s_fifo_pipe_empty_i;

 end generate MM2S_DWIDTH_CONV_IS;


  MM2S_DWIDTH_CONV_IS_NOT : if (C_DATA_WIDTH =  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin



    fifo_pipe_empty <= '1' when (all_lines_xfred = '1' and m_axis_tvalid_out = '0') -- All data for frame transmitted
                            or  (sf_threshold_met = '0'              -- Or Threshold not met
                                and stop_reg = '1'                   -- Commanded to stop
                                and m_axis_tvalid_out = '0')         -- And NOT driving tvalid
                  else '0';

dwidth_fifo_pipe_empty_m <= '1';

  end generate MM2S_DWIDTH_CONV_IS_NOT;


mm2s_all_lines_xfred_s 	     <= '0';
fsync_out_m                  <= '0';                    
mm2s_vsize_cntr_clr_flag     <= '0';                    
mm2s_fsize_mismatch_err_m    <= '0';                    


end generate GEN_LINEBUF_NO_SOF;

    GEN_LINEBUF_FLUSH_SOF : if (ENABLE_FLUSH_ON_FSYNC = 1 and C_MM2S_SOF_ENABLE = 1) generate

	signal s2mm_fsync_mm2s_s 		: std_logic 			:= '0';
	signal run_stop_reg                  	: std_logic 			:= '0';
	signal fsync_out_d1                  	: std_logic 			:= '0';
	signal mm2s_fsync_int 			: std_logic 			:= '0';
	signal fsize_mismatch_err_int_s 	: std_logic 			:= '0';
	signal fsize_mismatch_err_int_m 	: std_logic 			:= '0';
	signal fsize_mismatch_err_flag_s 	: std_logic 			:= '0';
	signal fsize_mismatch_err_flag_vsize_cntr_clr 	: std_logic 		:= '0';
	signal fsize_mismatch_err_flag_cmb_s 	: std_logic 			:= '0';
	signal fsync_src_select_cdc_tig 	: std_logic_vector(1 downto 0) 	:= (others => '0');
	signal fsync_src_select_d1       	: std_logic_vector(1 downto 0) 	:= (others => '0');
	signal fsync_src_select_s_int 		: std_logic_vector(1 downto 0) 	:= (others => '0');
	signal fsize_err_to_dm_halt_flag 	: std_logic 			:= '0';
	signal fsize_err_to_dm_halt_flag_ored 	: std_logic 			:= '0';
	signal delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s : std_logic 	:= '0';
	signal delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s 	: std_logic 	:= '0';
	signal delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1 	: std_logic 	:= '0';
	signal d_fsync_halt_cmplt_s 		: std_logic 			:= '0';

  ATTRIBUTE async_reg                      : STRING;
  ATTRIBUTE async_reg OF fsync_src_select_cdc_tig  : SIGNAL IS "true"; 
  ATTRIBUTE async_reg OF fsync_src_select_d1       : SIGNAL IS "true"; 


    begin






--*****************************************************************************--
--**              LINE BUFFER MODE (Sync or Async)                           **--
--*****************************************************************************--
GEN_LINEBUFFER : if C_LINEBUFFER_DEPTH /= 0 generate
begin

    -- Divide by number bytes per data beat and add padding to dynamic
    -- threshold setting
    data_count_ae_threshold <= linebuf_threshold((DATACOUNT_WIDTH-1) + THRESHOLD_LSB_INDEX
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
                 data_count        => fifo_rdcount  
            );

--wr_rst_busy_sig <= '0';
--rd_rst_busy_sig <= '0';
    end generate GEN_SYNC_FIFO;

    -- Asynchronous clock therefore instantiate an Asynchronous FIFO

    GEN_ASYNC_FIFO : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
    begin


LB_BRAM : if ( (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1) )
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
                -- Inputs
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
                 wr_data_count   => open         , --CR622702
                 rd_data_count   => fifo_rdcount         
            );

wr_rst_busy_sig <= '0';
rd_rst_busy_sig <= '0';

end generate LB_BRAM;                     


      
LB_BUILT_IN : if ( (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0) )
  generate   
    begin

        I_LINEBUFFER_FIFO : entity axi_vdma_v6_2.axi_vdma_afifo_builtin
            generic map(
                 PL_FIFO_TYPE    => "BUILT_IN"                    ,
                 PL_READ_MODE    => "FWFT"                    ,
                 PL_FASTER_CLOCK => "WR_CLK"                    , --RD_CLK
                 PL_FULL_FLAGS_RST_VAL => 0                     , -- ?
                 PL_DATA_WIDTH   => BUFFER_WIDTH                    ,
                 C_FAMILY        => C_FAMILY ,
                 PL_FIFO_DEPTH   => BUFFER_DEPTH                    
            )
            port map(
                -- Inputs
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




    -- Generate an SOF on tuser(0). currently vdma only support 1 tuser bit that is set by
    -- frame sync and driven out on first data beat of mm2s packet.
------    GEN_SOF : if C_MM2S_SOF_ENABLE = 1 generate
------    signal sof_reset : std_logic := '0';
------    begin
        sof_reset   <= '1' when (s_axis_resetn = '0')
                             or (dm_halt = '1')
                  else '0';

        -- On frame sync set flag and then clear flag when
        -- sof written to fifo.
        SOF_FLAG_PROCESS : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(sof_reset = '1' or fifo_wren = '1')then
                        sof_flag <= '0';
                    elsif(frame_sync = '1')then
                        sof_flag <= '1';
                    end if;
                end if;
            end process SOF_FLAG_PROCESS;

   GEN_MM2S_DRE_ENABLED_TKEEP : if C_INCLUDE_MM2S_DRE = 1 generate
   begin
        -- AXI Slave Side of FIFO
        fifo_din            <= sof_flag & s_axis_tlast & s_axis_tkeep_signal & s_axis_tdata;
       fifo_wren            <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i      <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
        s_axis_tready       <= s_axis_tready_i; -- CR619293

        -- AXI Master Side of FIFO
        fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
        m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
        m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
        m_axis_tkeep_i      <= fifo_dout(BUFFER_WIDTH-3 downto (BUFFER_WIDTH-3) - (C_DATA_WIDTH/8) + 1);
        m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-2);
        m_axis_tuser_i(0)   <= fifo_dout(BUFFER_WIDTH-1);

   end generate GEN_MM2S_DRE_ENABLED_TKEEP;

   GEN_NO_MM2S_DRE_DISABLE_TKEEP : if C_INCLUDE_MM2S_DRE = 0 generate
   begin
        -- AXI Slave Side of FIFO
        fifo_din            <= sof_flag & s_axis_tlast  & s_axis_tdata;
       fifo_wren            <= s_axis_tvalid and s_axis_tready_i;
       s_axis_tready_i      <= not fifo_full_i and not wr_rst_busy_sig and not s_axis_fifo_ainit;
        s_axis_tready       <= s_axis_tready_i; -- CR619293

        -- AXI Master Side of FIFO
        fifo_rden           <= m_axis_tready_i and m_axis_tvalid_i;
        m_axis_tvalid_i     <= not fifo_empty_i and not rd_rst_busy_sig and sf_threshold_met;
        m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
        m_axis_tkeep_i      <= (others => '1');
        m_axis_tlast_i      <= fifo_dout(BUFFER_WIDTH-2);
        m_axis_tuser_i(0)   <= fifo_dout(BUFFER_WIDTH-1);

   end generate GEN_NO_MM2S_DRE_DISABLE_TKEEP;

------    end generate GEN_SOF;
------
------
    -- SOF turned off therefore do not generate SOF on tuser
----------    GEN_NO_SOF : if C_MM2S_SOF_ENABLE = 0 generate
----------    begin
----------
----------        sof_flag <= '0';
----------
----------        -- AXI Slave Side of FIFO
----------        fifo_din            <= s_axis_tlast & s_axis_tkeep & s_axis_tdata;
----------        fifo_wren           <= s_axis_tvalid and not fifo_full_i and not s_axis_fifo_ainit;
----------        s_axis_tready_i     <= not fifo_full_i and not s_axis_fifo_ainit;
----------        s_axis_tready       <= s_axis_tready_i; -- CR619293
----------
----------        -- AXI Master Side of FIFO
----------        fifo_rden           <= m_axis_tready_i and not fifo_empty_i and sf_threshold_met;
----------        m_axis_tvalid_i     <= not fifo_empty_i and sf_threshold_met;
----------        m_axis_tdata_i      <= fifo_dout(C_DATA_WIDTH-1 downto 0);
----------        m_axis_tkeep_i      <= fifo_dout(BUFFER_WIDTH-2 downto (BUFFER_WIDTH-2) - (C_DATA_WIDTH/8) + 1);
----------        m_axis_tlast_i      <= not fifo_empty_i and fifo_dout(BUFFER_WIDTH-1);
----------        m_axis_tuser_i      <= (others => '0');
----------
----------    end generate GEN_NO_SOF;

    -- Top level line buffer depth not equal to zero therefore gererate threshold
    -- flags. (CR625142)
    GEN_THRESHOLD_ENABLED : if C_TOPLVL_LINEBUFFER_DEPTH /= 0  and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin

        -- Almost empty flag (note: asserts when empty also)

    
      
        REG_ALMST_EMPTY : process(m_axis_aclk)
            begin
                if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                    if(m_axis_fifo_ainit = '1')then
                        fifo_almost_empty_reg <= '1';
                    --elsif(fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= DATA_COUNT_AE_THRESHOLD or fifo_empty_i = '1')then
                    --elsif((fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= m_data_count_ae_thresh
                    --  or fifo_empty_i = '1') and fifo_full_i = '0')then
                    elsif((fifo_rdcount(DATACOUNT_WIDTH-1 downto 0) <= m_data_count_ae_thresh
                      or (fifo_empty_i = '1' or rd_rst_busy_sig = '1')))then
                        fifo_almost_empty_reg <= '1';
                    else
                        fifo_almost_empty_reg <= '0';
                    end if;
                end if;
            end process REG_ALMST_EMPTY;


        mm2s_fifo_almost_empty  <= fifo_almost_empty_reg
                                or (not sf_threshold_met) -- CR622777
                                or (not m_axis_tvalid_out); -- CR625724

        mm2s_fifo_empty         <= not m_axis_tvalid_out;
    end generate GEN_THRESHOLD_ENABLED;

    -- Top level line buffer depth is zero therefore turn off threshold logic.
    -- this occurs for async operation where the async fifo is needed for CDC (CR625142)
    GEN_THRESHOLD_DISABLED  : if C_TOPLVL_LINEBUFFER_DEPTH = 0  or (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        mm2s_fifo_empty             <= '0';
        mm2s_fifo_almost_empty      <= '0';
        fifo_almost_empty_reg       <= '0';
    end generate GEN_THRESHOLD_DISABLED;

    -- CR#578903
    -- FIFO, FIFO Pipe, and Skid Buffer are all empty.  This is used to safely
    -- assert reset on shutdown and also used to safely generate fsync in free-run mode
    -- CR622702 - need to look at write side of fifo to prevent false empties due to async fifo
    --fifo_pipe_empty <= '1' when (fifo_wrcount(DATACOUNT_WIDTH-1 downto 0) = DATA_COUNT_ZERO -- Data count is 0
    --                                and m_axis_tvalid_out = '0')                            -- Skid Buffer is done
    --                        -- Forced stop and Threshold not met (CR623291)
    --                        or  (sf_threshold_met = '0' and stop_reg = '1')
    --              else '0';
    -- CR623879 fixed flase fifo_pipe_assertions due to extreme AXI4 throttling on
    -- mm2s reads causing fifo to go empty for extended periods of time.  This then
    -- caused flase idles to be flagged and frame syncs were then generated in free run mode
----------------    fifo_pipe_empty <= '1' when (all_lines_xfred = '1' and m_axis_tvalid_out = '0') -- All data for frame transmitted
----------------                            or  (sf_threshold_met = '0'              -- Or Threshold not met
----------------                                and stop_reg = '1'                   -- Commanded to stop
----------------                                and m_axis_tvalid_out = '0')         -- And NOT driving tvalid
----------------                  else '0';
----------------

    -- If store and forward is turned on by user then gate tvalid with
    -- threshold met
    GEN_THRESH_MET_FOR_SNF : if C_INCLUDE_MM2S_SF = 1 and C_TOPLVL_LINEBUFFER_DEPTH /= 0 and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1)  generate
    begin
            -- Register fifo_almost empty in order to generate
            -- almost empty fall edge pulse
            REG_ALMST_EMPTY_FE : process(m_axis_aclk)
                begin
                    if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                        if(m_axis_fifo_ainit = '1')then
                            fifo_almost_empty_d1 <= '1';
                        else
                            fifo_almost_empty_d1 <= fifo_almost_empty_reg;
                        end if;
                    end if;
                end process REG_ALMST_EMPTY_FE;

            -- Almost empty falling edge
            fifo_almost_empty_fe <= not fifo_almost_empty_reg and fifo_almost_empty_d1;

            -- Store and Forward threshold met
            THRESH_MET : process(m_axis_aclk)
                begin
                    if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                        if(m_axis_fifo_ainit = '1')then
                            sf_threshold_met <= '0';
                        elsif(fsync_out = '1')then
                            sf_threshold_met <= '0';
                        -- Reached threshold or all reads done for the frame
                        elsif(fifo_almost_empty_fe = '1'
                          or (dm_xfred_all_lines_reg = '1'))then
                            sf_threshold_met <= '1';
                        end if;
                    end if;
                end process THRESH_MET;

    end generate GEN_THRESH_MET_FOR_SNF;

    -- Store and forward off therefore do not need to meet threshold
    GEN_NO_THRESH_MET_FOR_SNF : if C_INCLUDE_MM2S_SF = 0 or C_TOPLVL_LINEBUFFER_DEPTH = 0  or (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0)  generate
    begin
        sf_threshold_met <= '1';
    end generate GEN_NO_THRESH_MET_FOR_SNF;


    --*********************************************************--
    --**               MM2S MASTER SKID BUFFER               **--
    --*********************************************************--
    I_MSTR_SKID : entity axi_vdma_v6_2.axi_vdma_skid_buf
        generic map(
            C_WDATA_WIDTH           => C_DATA_WIDTH             ,
            C_TUSER_WIDTH           => C_M_AXIS_MM2S_TUSER_BITS
        )
        port map(
            -- System Ports
            ACLK                   => m_axis_aclk               ,
            ARST                   => m_axis_fifo_ainit_nosync              ,

            -- Shutdown control (assert for 1 clk pulse)
            skid_stop              => '0'                       ,

            -- Slave Side (Stream Data Input)
            S_VALID                => m_axis_tvalid_i           ,
            S_READY                => m_axis_tready_i           ,
            S_Data                 => m_axis_tdata_i            ,
            S_STRB                 => m_axis_tkeep_i            ,
            S_Last                 => m_axis_tlast_i            ,
            S_User                 => m_axis_tuser_i            ,

            -- Master Side (Stream Data Output)
            M_VALID                => m_axis_tvalid_out         ,
            M_READY                => m_axis_tready             ,
            M_Data                 => m_axis_tdata              ,
            M_STRB                 => m_axis_tkeep_signal              ,
            M_Last                 => m_axis_tlast_out          ,
            M_User                 => m_axis_tuser
        );

    -- Pass out of core
    m_axis_tvalid   <= m_axis_tvalid_out;
    m_axis_tlast    <= m_axis_tlast_out;

    -- Register to break long timing paths for use in
    -- transfer complete generation
    REG_STRM_SIGS : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
                if(m_axis_fifo_ainit = '1')then
                    m_axis_tlast_d1     <= '0';
                    m_axis_tvalid_d1    <= '0';
                    m_axis_tready_d1    <= '0';
                else
                    m_axis_tlast_d1     <= m_axis_tlast_out;
                    m_axis_tvalid_d1    <= m_axis_tvalid_out;
                    m_axis_tready_d1    <= m_axis_tready;
                end if;
            end if;
        end process REG_STRM_SIGS;



end generate GEN_LINEBUFFER;

--*****************************************************************************--
--**               NO LINE BUFFER MODE (Sync Only)                           **--
--*****************************************************************************--
-- LineBuffer forced on if asynchronous mode is enabled
GEN_NO_LINEBUFFER : if (C_LINEBUFFER_DEPTH = 0) generate     -- No Line Buffer
begin

    -- Map Datamover to AXIS Master Out
    m_axis_tdata        <= s_axis_tdata;
    m_axis_tkeep_signal <= s_axis_tkeep_signal;
    m_axis_tvalid       <= s_axis_tvalid;
    m_axis_tlast        <= s_axis_tlast;

    s_axis_tready       <= m_axis_tready;

    -- Tie FIFO Flags off
    mm2s_fifo_empty          <= '0';
    mm2s_fifo_almost_empty   <= '0';


    -- Generate sof on tuser(0)
----    GEN_SOF : if C_MM2S_SOF_ENABLE = 1 generate
---    begin
        -- On frame sync set flag and then clear flag when
        -- sof written to fifo.
        SOF_FLAG_PROCESS : process(s_axis_aclk)
            begin
                if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                    if(s_axis_fifo_ainit = '1' or (s_axis_tvalid = '1' and m_axis_tready = '1'))then
                        sof_flag <= '0';
                    elsif(frame_sync = '1')then
                        sof_flag <= '1';
                    end if;
                end if;
            end process SOF_FLAG_PROCESS;

        m_axis_tuser(0) <= sof_flag;

---    end generate GEN_SOF;

    -- Do not generate sof on tuser(0)
-----    GEN_NO_SOF : if C_MM2S_SOF_ENABLE = 0 generate
-----    begin
-----        sof_flag        <= '0';
-----        m_axis_tuser    <= (others => '0');
-----    end generate GEN_NO_SOF;


    -- CR#578903
    -- Register tvalid to break timing paths for use in
    -- psuedo fifo empty for channel idle generation and
    -- for xfer complete generation.
    REG_STRM_SIGS : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    m_axis_tvalid_d1        <= '0';
                    m_axis_tlast_d1         <= '0';
                    m_axis_tready_d1        <= '0';
                else
                    m_axis_tvalid_d1        <= s_axis_tvalid;
                    m_axis_tlast_d1         <= s_axis_tlast;
                    m_axis_tready_d1        <= m_axis_tready;
                end if;
            end if;
        end process REG_STRM_SIGS;

    -- CR#578903
    -- Psuedo FIFO, FIFO Pipe, and Skid Buffer are all empty.  This is used to safely
    -- assert reset on shutdown and also used to safely generate fsync in free-run mode
    -- This flag is looked at at the end of frames.
    -- Order of else-if is critical
    -- CR579191 modified method to prevent double fsync assertions
    REG_PIPE_EMPTY : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    fifo_pipe_empty <= '1';

                -- Command/Status not idle indicates pending datamover commands
                -- set psuedo fifo empty to NOT empty.
                elsif(cmdsts_idle_fe = '1')then
                    fifo_pipe_empty <= '0';

                -- On accepted tlast then clear psuedo empty flag back to being empty
                elsif(pot_empty = '1' and cmdsts_idle = '1')then
                    fifo_pipe_empty <= '1';
                end if;
            end if;
        end process REG_PIPE_EMPTY;

    REG_IDLE_FE : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    cmdsts_idle_d1 <= '1';
                else
                    cmdsts_idle_d1 <= cmdsts_idle;
                end if;
            end if;
        end process REG_IDLE_FE;

    -- CR579586 Use falling edge to set pfifo empty
    cmdsts_idle_fe  <= not cmdsts_idle and cmdsts_idle_d1;

    -- CR579191
    POTENTIAL_EMPTY_PROCESS : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_resetn = '0' or dm_halt = '1')then
                    pot_empty <= '1';
                elsif(m_axis_tvalid_d1 = '1' and m_axis_tlast_d1 = '1' and m_axis_tready_d1 = '1')then
                    pot_empty <= '1';
                elsif(m_axis_tvalid_d1 = '1' and m_axis_tlast_d1 = '0')then
                    pot_empty <= '0';
                end if;
            end if;
        end process POTENTIAL_EMPTY_PROCESS;

end generate GEN_NO_LINEBUFFER;


--*****************************************************************************--
--**                    MM2S ASYNCH CLOCK SUPPORT                            **--
--*****************************************************************************--
-- Cross fifo pipe empty flag to secondary clock domain
GEN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin

    -- Pipe Empty and Shutdown reset CDC
----    SHUTDOWN_RST_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,
----            prmry_out               => open                                     ,
----            prmry_in                => fifo_pipe_empty                          ,
----            scndry_out              => mm2s_fifo_pipe_empty_i                   ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----


SHUTDOWN_RST_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => fifo_pipe_empty, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mm2s_fifo_pipe_empty_i,
        scndry_vect_out            => open
    );







    -- Vertical Count and All Lines Transferred CDC (CR616211)
----    ALL_LINES_XFRED_P_S_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_P_S                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                       ,   -- CR619293
----            prmry_out               => open                   ,   -- CR619293
----            prmry_in                => all_lines_xfred                          ,
----            scndry_out              => mm2s_all_lines_xfred                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                               ,
----            prmry_vect_out          => open                            ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0) ,
----            scndry_vect_out         => open
----        );
----

ALL_LINES_XFRED_P_S_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => all_lines_xfred, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => mm2s_all_lines_xfred,
        scndry_vect_out            => open
    );








    -- Vertical Count and All Lines Transferred CDC (CR616211)
----    ALL_LINES_XFRED_S_P_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => dm_xfred_all_lines                       ,   -- CR619293
----            prmry_out               => dm_xfred_all_lines_reg                   ,   -- CR619293
----            prmry_in                => '0'                          ,
----            scndry_out              => open                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                               ,
----            prmry_vect_out          => open                            ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0) ,
----            scndry_vect_out         => open
----        );
----

ALL_LINES_XFRED_S_P_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dm_xfred_all_lines, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => dm_xfred_all_lines_reg,
        scndry_vect_out            => open
    );





VSIZE_CNT_CROSSING : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then

	   crnt_vsize_cdc_tig <= crnt_vsize;
	   crnt_vsize_d1      <= crnt_vsize_cdc_tig;

        end if;
    end process VSIZE_CNT_CROSSING;


	   crnt_vsize_d2 <= crnt_vsize_d1;









    -- Cross stop signal  (CR623291)
----    STOP_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => stop                                     ,
----            prmry_out               => stop_reg                                 ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );

STOP_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => stop_reg,
        scndry_vect_out            => open
    );






----    MM2S_RUN_STOP_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => run_stop                                     ,
----            prmry_out               => run_stop_reg                                 ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );


MM2S_RUN_STOP_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => run_stop, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => run_stop_reg,
        scndry_vect_out            => open
    );









----    MM2S_FSIZE_ERR_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                     ,
----            prmry_out               => open                                 ,
----            prmry_in                => fsize_mismatch_err_int_s                                      ,
----            scndry_out              => fsize_mismatch_err_int_m                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,
----            prmry_vect_out          => open                                     ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,
----            scndry_vect_out         => open
----        );
----



MM2S_FSIZE_ERR_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => fsize_mismatch_err_int_s, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => fsize_mismatch_err_int_m,
        scndry_vect_out            => open
    );






----    MM2S_FSYNC_OUT_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                               ,
----            prmry_resetn            => m_axis_resetn                             ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => fsync_out                         ,
----            scndry_out              =>  fsync_out_m                         ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----


MM2S_FSYNC_OUT_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => m_axis_aclk,
        prmry_resetn               => m_axis_resetn, 
        prmry_in                   => fsync_out, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => s_axis_aclk, 
        scndry_resetn              => s_axis_resetn,
        scndry_out                 => fsync_out_m,
        scndry_vect_out            => open
    );





GEN_FSYNC_SEL_CROSSING : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then

		fsync_src_select_cdc_tig <= fsync_src_select;
		fsync_src_select_d1      <= fsync_src_select_cdc_tig;

        end if;
    end process GEN_FSYNC_SEL_CROSSING;


fsync_src_select_s_int <= fsync_src_select_d1;



    -- Cross datamover halt and threshold signals
----    HALT_CDC_I : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_LEVEL_S_P                           ,
----            C_VECTOR_WIDTH          => 1 
----        )
----        port map (
----            prmry_aclk              => m_axis_aclk                              ,
----            prmry_resetn            => m_axis_resetn                            ,
----            scndry_aclk             => s_axis_aclk                              ,
----            scndry_resetn           => s_axis_resetn                            ,
----            scndry_in               => dm_halt                                  ,
----            prmry_out               => dm_halt_reg                              ,
----            prmry_in                => '0'                                      ,
----            scndry_out              => open                                     ,
----            scndry_vect_s_h         => '0'                                      ,
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)                  ,
----            prmry_vect_out          => open                   ,
----            prmry_vect_s_h          => '0'                                      ,
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out         => open
----        );
----


HALT_CDC_I : entity lib_cdc_v1_0.cdc_sync
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
        prmry_in                   => dm_halt, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => dm_halt_reg,
        scndry_vect_out            => open
    );






THRESH_CNT_CROSSING : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then

	   data_count_ae_threshold_cdc_tig <= data_count_ae_threshold;
	   data_count_ae_threshold_d1      <= data_count_ae_threshold_cdc_tig;

        end if;
    end process THRESH_CNT_CROSSING;


	   m_data_count_ae_thresh <= data_count_ae_threshold_d1;






GEN_ASYNC_CROSS_FSYNC : if C_INCLUDE_S2MM = 1 generate
begin


----    CROSS_FSYNC_CDC_I_FLUSH_MM2S_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_P_S_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => s_axis_s2mm_aclk                               ,
----            prmry_resetn            => s2mm_axis_resetn                             ,
----            scndry_aclk             => m_axis_aclk                              ,
----            scndry_resetn           => m_axis_resetn                            ,
----            scndry_in               => '0'                                      ,   -- Not Used
----            prmry_out               => open                                     ,   -- Not Used
----            prmry_in                => s2mm_fsync                         ,
----            scndry_out              => s2mm_fsync_mm2s_s                          ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----



CROSS_FSYNC_CDC_I_FLUSH_MM2S_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => s_axis_s2mm_aclk,
        prmry_resetn               => s2mm_axis_resetn, 
        prmry_in                   => s2mm_fsync, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => m_axis_aclk, 
        scndry_resetn              => m_axis_resetn,
        scndry_out                 => s2mm_fsync_mm2s_s,
        scndry_vect_out            => open
    );







end generate GEN_ASYNC_CROSS_FSYNC;

GEN_ASYNC_NO_CROSS_FSYNC : if C_INCLUDE_S2MM = 0 generate
begin

s2mm_fsync_mm2s_s <= '0';

end generate GEN_ASYNC_NO_CROSS_FSYNC;





end generate GEN_FOR_ASYNC;

--*****************************************************************************--
--**                    MM2S SYNCH CLOCK SUPPORT                             **--
--*****************************************************************************--
GEN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    mm2s_fifo_pipe_empty_i      <= fifo_pipe_empty;
    crnt_vsize_d2               <= crnt_vsize;              -- CR616211
    mm2s_all_lines_xfred        <= all_lines_xfred;         -- CR616211
    dm_xfred_all_lines_reg      <= dm_xfred_all_lines;      -- CR619293
    stop_reg                    <= stop;                    -- CR623291
    run_stop_reg                <= run_stop;                    -- CR623291
    fsync_out_m                 <= fsync_out;                    -- CR623291
    dm_halt_reg                 <= dm_halt;
    m_data_count_ae_thresh      <= data_count_ae_threshold;
    fsync_src_select_s_int      <= fsync_src_select;
    fsize_mismatch_err_int_m    <= fsize_mismatch_err_int_s;


GEN_SYNC_CROSS_FSYNC : if C_INCLUDE_S2MM = 1 generate
begin

    s2mm_fsync_mm2s_s           <= s2mm_fsync;

end generate GEN_SYNC_CROSS_FSYNC;

GEN_SYNC_NO_CROSS_FSYNC : if C_INCLUDE_S2MM = 0 generate
begin

s2mm_fsync_mm2s_s <= '0';

end generate GEN_SYNC_NO_CROSS_FSYNC;

end generate GEN_FOR_SYNC;


NO_DWIDTH_VERT_COUNTER : if (C_DATA_WIDTH =  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin



--*****************************************************************************
--** Vertical Line Tracking (CR616211)
--*****************************************************************************
-- Decrement vertical count with each accept tlast
decr_vcount <= '1' when m_axis_tlast_d1 = '1'
                    and m_axis_tvalid_d1 = '1'
                    and m_axis_tready_d1 = '1'
          else '0';


-- Drive ready at fsync out then de-assert once all lines have
-- been accepted.
VERT_COUNTER : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if((m_axis_fifo_ainit = '1' and fsync_out = '0') or fsize_mismatch_err_flag_vsize_cntr_clr = '1' )then
                vsize_counter       <= (others => '0');
                all_lines_xfred_no_dwidth     <= '1';
            elsif(fsync_out = '1')then
                vsize_counter       <= crnt_vsize_d2;
                all_lines_xfred_no_dwidth     <= '0';
            elsif(decr_vcount = '1' and vsize_counter = VSIZE_ONE_VALUE)then
                vsize_counter       <= (others => '0');
                all_lines_xfred_no_dwidth     <= '1';

            elsif(decr_vcount = '1' and vsize_counter /= VSIZE_ZERO_VALUE)then
                vsize_counter       <= std_logic_vector(unsigned(vsize_counter) - 1);
                all_lines_xfred_no_dwidth     <= '0';

            end if;
        end if;
    end process VERT_COUNTER;




  end generate NO_DWIDTH_VERT_COUNTER;




-- Store and forward or no line buffer (CR619293)
GEN_VCOUNT_FOR_SNF : if C_LINEBUFFER_DEPTH /= 0 and C_INCLUDE_MM2S_SF = 1 generate
begin
    dm_decr_vcount <= '1' when s_axis_tlast = '1'
                           and s_axis_tvalid = '1'
                           and s_axis_tready_i = '1'
              else '0';

    -- Delay 1 pipe to align with cnrt_vsize
    REG_FSYNC_TO_ALIGN : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_fifo_ainit = '1' and frame_sync = '0')then
                    frame_sync_d1 <= '0';
                else
                    frame_sync_d1 <= frame_sync;
                end if;
            end if;
        end process REG_FSYNC_TO_ALIGN;

    -- Count lines to determine when datamover done.  Used for snf mode
    -- for threshold met (CR619293)
    DM_DONE     : process(s_axis_aclk)
        begin
            if(s_axis_aclk'EVENT and s_axis_aclk = '1')then
                if(s_axis_fifo_ainit = '1')then
                    dm_vsize_counter        <= (others => '0');
                    dm_xfred_all_lines      <= '0';
                --elsif(fsync_out = '1')then     -- CR623088
                elsif(frame_sync_d1 = '1')then     -- CR623088
                    dm_vsize_counter       <= crnt_vsize;
                    dm_xfred_all_lines     <= '0';
                elsif(dm_decr_vcount = '1' and dm_vsize_counter = VSIZE_ONE_VALUE)then
                    dm_vsize_counter       <= (others => '0');
                    dm_xfred_all_lines     <= '1';

                elsif(dm_decr_vcount = '1' and dm_vsize_counter /= VSIZE_ZERO_VALUE)then
                    dm_vsize_counter       <= std_logic_vector(unsigned(dm_vsize_counter) - 1);
                    dm_xfred_all_lines     <= '0';

                end if;
            end if;
        end process DM_DONE;

end generate GEN_VCOUNT_FOR_SNF;

-- Not store and forward or no line buffer (CR619293)
GEN_NO_VCOUNT_FOR_SNF : if C_LINEBUFFER_DEPTH = 0 or C_INCLUDE_MM2S_SF = 0 generate
begin
    dm_vsize_counter        <= (others => '0');
    dm_xfred_all_lines      <= '0';
    dm_decr_vcount          <= '0';
end generate GEN_NO_VCOUNT_FOR_SNF;


--*****************************************************************************--
--**                    SPECIAL RESET GENERATION                             **--
--*****************************************************************************--


-- Assert reset to skid buffer on hard reset or on shutdown when fifo pipe empty
-- Waiting for fifo_pipe_empty is required to prevent a AXIS protocol violation
-- when channel shut down early
REG_SKID_RESET : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0')then
                m_skid_reset <= '1';

            elsif(fifo_pipe_empty = '1')then
                if(fsync_out = '1' or dm_halt_reg = '1')then
                    m_skid_reset <= '1';
                else
                    m_skid_reset <= '0';
                end if;
            else
                m_skid_reset <= '0';
            end if;
        end if;
    end process REG_SKID_RESET;

-- Fifo/logic reset for slave side clock domain (m_axi_mm2s_aclk)
-- If error (dm_halt=1) then halt immediatly without protocol violation
s_axis_fifo_ainit <= '1' when s_axis_resetn = '0'
                           or frame_sync = '1'          -- Frame sync
                           or dm_halt = '1'             -- Datamover being halted (halt due to error)
                else '0';

-- Fifo/logic reset for master side clock domain (m_axis_mm2s_aclk)
m_axis_fifo_ainit <= '1' when m_axis_resetn = '0'
                           or fsync_out = '1'           -- Frame sync
                           or dm_halt_reg = '1'         -- Datamover being halted
                else '0';



-- Fifo/logic reset for slave side clock domain (m_axi_mm2s_aclk)
-- If error (dm_halt=1) then halt immediatly without protocol violation
s_axis_fifo_ainit_nosync <= '1' when s_axis_resetn = '0'
                           or dm_halt = '1'             -- Datamover being halted (halt due to error)
                else '0';

-- Fifo/logic reset for master side clock domain (m_axis_mm2s_aclk)
m_axis_fifo_ainit_nosync <= '1' when m_axis_resetn = '0'
                           or dm_halt_reg = '1'         -- Datamover being halted
                else '0';





--reset for axis_dwidth

mm2s_axis_linebuf_reset_out_inv <= m_axis_fifo_ainit_nosync;
mm2s_axis_linebuf_reset_out <= not (mm2s_axis_linebuf_reset_out_inv);

all_lines_xfred 	<= mm2s_all_lines_xfred_s_sig;
mm2s_all_lines_xfred_s 	<= mm2s_all_lines_xfred_s_sig;


--C_DATA_WIDTH = C_M_AXIS_MM2S_TDATA_WIDTH_CALCULATED

MM2S_DWIDTH_CONV_IS : if (C_DATA_WIDTH /=  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin


mm2s_all_lines_xfred_s_sig <= mm2s_all_lines_xfred_s_dwidth;
fifo_pipe_empty <= dwidth_fifo_pipe_empty;
dwidth_fifo_pipe_empty_m <= mm2s_fifo_pipe_empty_i;

 end generate MM2S_DWIDTH_CONV_IS;


  MM2S_DWIDTH_CONV_IS_NOT : if (C_DATA_WIDTH =  C_M_AXIS_MM2S_TDATA_WIDTH) generate
  begin


mm2s_all_lines_xfred_s_sig <= all_lines_xfred_no_dwidth;

    fifo_pipe_empty <= '1' when (all_lines_xfred = '1' and m_axis_tvalid_out = '0') -- All data for frame transmitted
                            or  (sf_threshold_met = '0'              -- Or Threshold not met
                                and stop_reg = '1'                   -- Commanded to stop
                                and m_axis_tvalid_out = '0')         -- And NOT driving tvalid
                  else '0';

dwidth_fifo_pipe_empty_m <= '1';

  end generate MM2S_DWIDTH_CONV_IS_NOT;


                        mm2s_fsync_int <= mm2s_fsync and run_stop_reg;

        -- Frame sync cross bar
----        FSYNC_CROSSBAR_MM2S_S : process(fsync_src_select_s_int,
----                                 run_stop_reg,
----                                 mm2s_fsync,
----                                 s2mm_fsync_mm2s_s)
----            begin
----                case fsync_src_select_s_int is
----
----                    when "00" =>   -- primary fsync (default)
----                        mm2s_fsync_int <= mm2s_fsync and run_stop_reg;
----                    when "01" =>   -- other channel fsync
----                        mm2s_fsync_int <= s2mm_fsync_mm2s_s and run_stop_reg;
----                    when others =>
----                        mm2s_fsync_int <= '0';
----                end case;
----            end process FSYNC_CROSSBAR_MM2S_S;


    FSIZE_MISMATCH_MM2S_FLUSH_SOF_s : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk='1')then
                if(m_axis_resetn = '0')then
                    fsize_mismatch_err_int_s <= '0';
                -- fsync occurred when not all lines transferred
                elsif(mm2s_fsync_int = '1' and mm2s_all_lines_xfred_s_sig = '0')then
                    fsize_mismatch_err_int_s <= '1';
                else
                    fsize_mismatch_err_int_s <= '0';
                end if;
            end if;
        end process FSIZE_MISMATCH_MM2S_FLUSH_SOF_s;


    FSIZE_MISMATCH_FLAG_MM2S_FLUSH_SOF_s : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk='1')then
                if(m_axis_resetn = '0' or mm2s_fsync_int = '1')then
                    fsize_mismatch_err_flag_s <= '0';
                elsif(fsize_mismatch_err_int_s = '1')then
                    fsize_mismatch_err_flag_s <= '1';
                end if;
            end if;
        end process FSIZE_MISMATCH_FLAG_MM2S_FLUSH_SOF_s;


fsize_mismatch_err_flag_cmb_s <= fsize_mismatch_err_int_s or fsize_mismatch_err_flag_s;

MM2S_DROP_RESIDUAL_OF_FSIZE_ERR_FRAME_S <= fsize_mismatch_err_flag_cmb_s;

mm2s_fsize_mismatch_err_s <= fsize_mismatch_err_int_s;
mm2s_fsize_mismatch_err_m <= fsize_mismatch_err_int_m;

mm2s_vsize_cntr_clr_flag  <= fsize_mismatch_err_flag_vsize_cntr_clr or fsize_mismatch_err_int_s;


    D1_FSYNC_OUT : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk='1')then
                if(m_axis_resetn = '0')then
                    fsync_out_d1 <= '0';
                else
                    fsync_out_d1 <= fsync_out;
                end if;
            end if;
        end process D1_FSYNC_OUT;




    FLAG_VSIZE_CNTR_CLR : process(m_axis_aclk)
        begin
            if(m_axis_aclk'EVENT and m_axis_aclk='1')then
                if(m_axis_resetn = '0' or fsync_out_d1 = '1')then
                    fsize_mismatch_err_flag_vsize_cntr_clr <= '0';
                elsif(fsize_mismatch_err_int_s = '1')then
                    fsize_mismatch_err_flag_vsize_cntr_clr <= '1';
                end if;
            end if;
        end process FLAG_VSIZE_CNTR_CLR;



MM2S_FSIZE_ERR_TO_DM_HALT_FLAG : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0' or dm_halt_reg = '1')then
                fsize_err_to_dm_halt_flag  <= '0';
            elsif(fsize_mismatch_err_int_s = '1')then
                fsize_err_to_dm_halt_flag  <= '1';
            end if;
        end if;
    end process MM2S_FSIZE_ERR_TO_DM_HALT_FLAG;



fsize_err_to_dm_halt_flag_ored <= fsize_mismatch_err_int_s or fsize_err_to_dm_halt_flag or dm_halt_reg;


delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s    <= '1'  when  fsize_err_to_dm_halt_flag_ored = '1' and mm2s_fsync_int = '1' 
                                    else '0';


MM2S_FSIZE_LESS_DM_HALT_CMPLT_FLAG : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0' or fsize_err_to_dm_halt_flag_ored = '0')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s  <= '0';
            elsif(delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s = '1')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s  <= '1';
            end if;
        end if;
    end process MM2S_FSIZE_LESS_DM_HALT_CMPLT_FLAG;

MM2S_REG_D_FSYNC : process(m_axis_aclk)
    begin
        if(m_axis_aclk'EVENT and m_axis_aclk = '1')then
            if(m_axis_resetn = '0')then
                delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1  <= '0';
            else
                delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1  <= delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s;
            end if;
        end if;
    end process MM2S_REG_D_FSYNC;


d_fsync_halt_cmplt_s <= delay_fsync_fsize_err_till_dm_halt_cmplt_s_d1 and not delay_fsync_fsize_err_till_dm_halt_cmplt_flag_s;

mm2s_fsync_core <= (mm2s_fsync_int and not (delay_fsync_fsize_err_till_dm_halt_cmplt_pulse_s)) or d_fsync_halt_cmplt_s;


--mm2s_fsync_core <= mm2s_fsync_int;



end generate GEN_LINEBUF_FLUSH_SOF;








end implementation;
