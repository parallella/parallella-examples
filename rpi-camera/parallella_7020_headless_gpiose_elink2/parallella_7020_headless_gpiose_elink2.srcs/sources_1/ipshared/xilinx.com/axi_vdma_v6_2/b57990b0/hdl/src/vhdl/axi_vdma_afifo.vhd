-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- axi_vdma_afifo.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
--  (c) Copyright 2010, 2012-2013 Xilinx, Inc. All rights reserved.
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library fifo_generator_v12_0;
use fifo_generator_v12_0.all;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.all;
--use proc_common_v4_0.coregen_comp_defs.all;
--use proc_common_v4_0.family_support.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;


-- synopsys translate_off
--library XilinxCoreLib;
--use XilinxCoreLib.all;
-- synopsys translate_on




ENTITY axi_vdma_afifo IS
  GENERIC (
    -------------------------------------------------------------------------
    -- Generic Declarations
    -------------------------------------------------------------------------
    C_FAMILY       	  : STRING  := "virtex7";   --
    C_FULL_FLAGS_RST_VAL  : INTEGER := 1;          -- 0,1 ; Default 1
    UW_DATA_WIDTH         : INTEGER := 16;          -- 1 - 1024; Default 16
    UW_FIFO_DEPTH         : INTEGER := 1024         -- 16 - 256K; Default 1K
    );
  PORT (

    -- Common signal
    rst              : in  std_logic := '0';

    sleep            : in  std_logic := '0';
    wr_rst_busy      : out std_logic := '0';
    rd_rst_busy      : out std_logic := '0';
    -- Write Domain signals
    wr_clk           : in  std_logic := '0';
    din              : in  std_logic_vector(UW_DATA_WIDTH-1 downto 0) := (others => '0');
    wr_en            : in  std_logic := '0';
    full             : out std_logic := '0';
    wr_data_count    : out std_logic_vector(clog2(uw_fifo_depth)-1 downto 0) := (others => '0');

    -- Read Domain signals
    rd_data_count    : out std_logic_vector(clog2(uw_fifo_depth)-1 downto 0) := (others => '0');
    rd_clk           : in  std_logic := '0';
    rd_en            : in  std_logic := '0';
    dout             : out std_logic_vector(UW_DATA_WIDTH-1 downto 0) := (others => '0');
    empty            : out std_logic := '1'

    );
END ENTITY axi_vdma_afifo;

ARCHITECTURE xilinx OF axi_vdma_afifo IS
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of xilinx : architecture is "yes";

  --CONSTANT GND : std_logic := '0';
  CONSTANT VCC : std_logic := '1';

  CONSTANT clog2_uw_fifo_depth   : integer := clog2(uw_fifo_depth);
  --Signals added to fix MTI and XSIM issues caused by fix for VCS issues not to use "LIBRARY_SCAN = TRUE"
  signal ZERO_pntr : std_logic_vector(clog2_uw_fifo_depth-1 downto 0) := (others => '0');
  signal GND : std_logic := '0';
   signal ALMOST_FULL           : std_logic;                 
   signal WR_ACK           : std_logic;                 
   signal OVERFLOW           : std_logic;                 
   signal ALMOST_EMPTY           : std_logic;                 
   signal VALID           : std_logic;                 
   signal UNDERFLOW           : std_logic;                 
   signal PROG_FULL           : std_logic;                 
   signal PROG_EMPTY          : std_logic;                 
   signal SBITERR             : std_logic;                 
   signal DBITERR             : std_logic;                  
   signal S_AXI_AWREADY       : std_logic;
   signal S_AXI_WREADY        : std_logic;
   signal S_AXI_BID           : std_logic_vector(3 DOWNTO 0);
   signal S_AXI_BRESP         : std_logic_vector(2-1 DOWNTO 0);
   signal S_AXI_BUSER         : std_logic_vector(0 downto 0);
   signal S_AXI_BVALID        : std_logic;

   -- AXI Full/Lite Master Write Channel (Read side)
   signal M_AXI_AWID          : std_logic_vector(3 DOWNTO 0);
   signal M_AXI_AWADDR        : std_logic_vector(31 DOWNTO 0);
   signal M_AXI_AWLEN         : std_logic_vector(8-1 DOWNTO 0);
   signal M_AXI_AWSIZE        : std_logic_vector(3-1 DOWNTO 0);
   signal M_AXI_AWBURST       : std_logic_vector(2-1 DOWNTO 0);
   signal M_AXI_AWLOCK        : std_logic_vector(2-1 DOWNTO 0);
   signal M_AXI_AWCACHE       : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_AWPROT        : std_logic_vector(3-1 DOWNTO 0);
   signal M_AXI_AWQOS         : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_AWREGION      : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_AWUSER        : std_logic_vector(0 downto 0);
   signal M_AXI_AWVALID       : std_logic;
   signal M_AXI_WID           : std_logic_vector(3 DOWNTO 0);
   signal M_AXI_WDATA         : std_logic_vector(63 DOWNTO 0);
   signal M_AXI_WSTRB         : std_logic_vector(7 DOWNTO 0);
   signal M_AXI_WLAST         : std_logic;
   signal M_AXI_WUSER         : std_logic_vector(0 downto 0);
   signal M_AXI_WVALID        : std_logic;
   signal M_AXI_BREADY        : std_logic;

   -- AXI Full/Lite Slave Read Channel (Write side)
   signal S_AXI_ARREADY       : std_logic;
   signal S_AXI_RID           : std_logic_vector(3 DOWNTO 0);       
   signal S_AXI_RDATA         : std_logic_vector(63 DOWNTO 0); 
   signal S_AXI_RRESP         : std_logic_vector(2-1 DOWNTO 0);
   signal S_AXI_RLAST         : std_logic;
   signal S_AXI_RUSER         : std_logic_vector(0 downto 0);
   signal S_AXI_RVALID        : std_logic;

   -- AXI Full/Lite Master Read Channel (Read side)
   signal M_AXI_ARID          : std_logic_vector(3 DOWNTO 0);        
   signal M_AXI_ARADDR        : std_logic_vector(31 DOWNTO 0);  
   signal M_AXI_ARLEN         : std_logic_vector(8-1 DOWNTO 0);
   signal M_AXI_ARSIZE        : std_logic_vector(3-1 DOWNTO 0);
   signal M_AXI_ARBURST       : std_logic_vector(2-1 DOWNTO 0);
   signal M_AXI_ARLOCK        : std_logic_vector(2-1 DOWNTO 0);
   signal M_AXI_ARCACHE       : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_ARPROT        : std_logic_vector(3-1 DOWNTO 0);
   signal M_AXI_ARQOS         : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_ARREGION      : std_logic_vector(4-1 DOWNTO 0);
   signal M_AXI_ARUSER        : std_logic_vector(0 downto 0);
   signal M_AXI_ARVALID       : std_logic;
   signal M_AXI_RREADY        : std_logic;

   -- AXI Streaming Slave Signals (Write side)
   signal S_AXIS_TREADY       : std_logic;

   -- AXI Streaming Master Signals (Read side)
   signal M_AXIS_TVALID       : std_logic;
   signal M_AXIS_TDATA        : std_logic_vector(63 DOWNTO 0);
   signal M_AXIS_TSTRB        : std_logic_vector(3 DOWNTO 0);
   signal M_AXIS_TKEEP        : std_logic_vector(3 DOWNTO 0);
   signal M_AXIS_TLAST        : std_logic;
   signal M_AXIS_TID          : std_logic_vector(7 DOWNTO 0);
   signal M_AXIS_TDEST        : std_logic_vector(3 DOWNTO 0);
   signal M_AXIS_TUSER        : std_logic_vector(3 DOWNTO 0);

   -- AXI Full/Lite Write Address Channel Signals
   signal AXI_AW_DATA_COUNT    : std_logic_vector(4 DOWNTO 0);
   signal AXI_AW_WR_DATA_COUNT : std_logic_vector(4 DOWNTO 0);
   signal AXI_AW_RD_DATA_COUNT : std_logic_vector(4 DOWNTO 0);
   signal AXI_AW_SBITERR       : std_logic;
   signal AXI_AW_DBITERR       : std_logic;
   signal AXI_AW_OVERFLOW      : std_logic;
   signal AXI_AW_UNDERFLOW     : std_logic;
   signal AXI_AW_PROG_FULL     : STD_LOGIC;
   signal AXI_AW_PROG_EMPTY    : STD_LOGIC;


   -- AXI Full/Lite Write Data Channel Signals
   signal AXI_W_DATA_COUNT     : std_logic_vector(10 DOWNTO 0);
   signal AXI_W_WR_DATA_COUNT  : std_logic_vector(10 DOWNTO 0);
   signal AXI_W_RD_DATA_COUNT  : std_logic_vector(10 DOWNTO 0);
   signal AXI_W_SBITERR        : std_logic;
   signal AXI_W_DBITERR        : std_logic;
   signal AXI_W_OVERFLOW       : std_logic;
   signal AXI_W_UNDERFLOW      : std_logic;
   signal AXI_W_PROG_FULL      : STD_LOGIC;
   signal AXI_W_PROG_EMPTY     : STD_LOGIC;

   -- AXI Full/Lite Write Response Channel Signals
   signal AXI_B_DATA_COUNT     : std_logic_vector(4 DOWNTO 0);
   signal AXI_B_WR_DATA_COUNT  : std_logic_vector(4 DOWNTO 0);
   signal AXI_B_RD_DATA_COUNT  : std_logic_vector(4 DOWNTO 0);
   signal AXI_B_SBITERR        : std_logic;
   signal AXI_B_DBITERR        : std_logic;
   signal AXI_B_OVERFLOW       : std_logic;
   signal AXI_B_UNDERFLOW      : std_logic;
   signal AXI_B_PROG_FULL      : STD_LOGIC;
   signal AXI_B_PROG_EMPTY     : STD_LOGIC;

   -- AXI Full/Lite Read Address Channel Signals
   signal AXI_AR_DATA_COUNT    : std_logic_vector(4 DOWNTO 0);
   signal AXI_AR_WR_DATA_COUNT : std_logic_vector(4 DOWNTO 0);
   signal AXI_AR_RD_DATA_COUNT : std_logic_vector(4 DOWNTO 0);
   signal AXI_AR_SBITERR       : std_logic;
   signal AXI_AR_DBITERR       : std_logic;
   signal AXI_AR_OVERFLOW      : std_logic;
   signal AXI_AR_UNDERFLOW     : std_logic;
   signal AXI_AR_PROG_FULL     : STD_LOGIC;
   signal AXI_AR_PROG_EMPTY    : STD_LOGIC;

   -- AXI Full/Lite Read Data Channel Signals
   signal AXI_R_DATA_COUNT     : std_logic_vector(10 DOWNTO 0);
   signal AXI_R_WR_DATA_COUNT  : std_logic_vector(10 DOWNTO 0);
   signal AXI_R_RD_DATA_COUNT  : std_logic_vector(10 DOWNTO 0);
   signal AXI_R_SBITERR        : std_logic;
   signal AXI_R_DBITERR        : std_logic;
   signal AXI_R_OVERFLOW       : std_logic;
   signal AXI_R_UNDERFLOW      : std_logic;
   signal AXI_R_PROG_FULL      : STD_LOGIC;
   signal AXI_R_PROG_EMPTY     : STD_LOGIC;

   -- AXI Streaming FIFO Related Signals
   signal AXIS_DATA_COUNT      : std_logic_vector(10 DOWNTO 0);
   signal AXIS_WR_DATA_COUNT   : std_logic_vector(10 DOWNTO 0);
   signal AXIS_RD_DATA_COUNT   : std_logic_vector(10 DOWNTO 0);
   signal AXIS_SBITERR         : std_logic;
   signal AXIS_DBITERR         : std_logic;
   signal AXIS_OVERFLOW        : std_logic;
   signal AXIS_UNDERFLOW       : std_logic;
   signal AXIS_PROG_FULL       : STD_LOGIC;
   signal AXIS_PROG_EMPTY      : STD_LOGIC;
  --Signals added to fix MTI and XSIM issues caused by fix for VCS issues not to use "LIBRARY_SCAN = TRUE"
   signal DATA_COUNT          : std_logic_vector(clog2_uw_fifo_depth-1 DOWNTO 0);                 


BEGIN

ZERO_pntr <= (others => '0');
GND <= '0';

  fg_inst : entity fifo_generator_v12_0.fifo_generator_v12_0
  GENERIC MAP (
    C_COMMON_CLOCK                      => 0,
--    C_COUNT_TYPE                        => C_COUNT_TYPE,
    C_COUNT_TYPE                        => 0,					--my
--    C_DATA_COUNT_WIDTH                  => C_DATA_COUNT_WIDTH,
    C_DATA_COUNT_WIDTH                  => clog2_uw_fifo_depth,		--my
--    C_DEFAULT_VALUE                     => C_DEFAULT_VALUE,
    C_DIN_WIDTH                         => uw_data_width,
--    C_DOUT_RST_VAL                      => C_DOUT_RST_VAL,
    C_DOUT_WIDTH                        => uw_data_width,
--    C_ENABLE_RLOCS                      => C_ENABLE_RLOCS,
    --C_FAMILY                            => "virtex7",
    C_FAMILY                            => C_FAMILY,				--my
    --C_FULL_FLAGS_RST_VAL                => uw_full_flags_rst_val,
    C_FULL_FLAGS_RST_VAL                => C_FULL_FLAGS_RST_VAL,					--my
--    C_HAS_ALMOST_EMPTY                  => C_HAS_ALMOST_EMPTY,
--    C_HAS_ALMOST_FULL                   => C_HAS_ALMOST_FULL,
--    C_HAS_BACKUP                        => C_HAS_BACKUP,
    C_HAS_DATA_COUNT                    => 0,					--my
--    C_HAS_DATA_COUNT                    => C_HAS_DATA_COUNT,
--    C_HAS_INT_CLK                       => C_HAS_INT_CLK,
--    C_HAS_MEMINIT_FILE                  => C_HAS_MEMINIT_FILE,
--    C_HAS_OVERFLOW                      => C_HAS_OVERFLOW,
    C_HAS_RD_DATA_COUNT                 => 1,					--my
--    C_HAS_RD_DATA_COUNT                 => C_HAS_RD_DATA_COUNT,
--    C_HAS_RD_RST                        => C_HAS_RD_RST,
    C_HAS_RST                           => 1,
    C_HAS_SRST                          => 0,
--    C_HAS_UNDERFLOW                     => C_HAS_UNDERFLOW,
--    C_HAS_VALID                         => C_HAS_VALID,
--    C_HAS_WR_ACK                        => C_HAS_WR_ACK,
    C_HAS_WR_DATA_COUNT                 => 1,					--my
--    C_HAS_WR_DATA_COUNT                 => C_HAS_WR_DATA_COUNT,
--    C_HAS_WR_RST                        => C_HAS_WR_RST,
    --C_IMPLEMENTATION_TYPE               => C_IMPLEMENTATION_TYPE,
    C_IMPLEMENTATION_TYPE               => 2,					--my --Block RAM
--    C_INIT_WR_PNTR_VAL                  => C_INIT_WR_PNTR_VAL,
    --C_MEMORY_TYPE                       => C_MEMORY_TYPE,		
    C_MEMORY_TYPE                       => 1,					--my --Block RAM
--    C_MIF_FILE_NAME                     => C_MIF_FILE_NAME,
--    C_OPTIMIZATION_MODE                 => C_OPTIMIZATION_MODE,
--    C_OVERFLOW_LOW                      => C_OVERFLOW_LOW,
    --C_PRELOAD_LATENCY                   => C_PRELOAD_LATENCY,
    --C_PRELOAD_REGS                      => C_PRELOAD_REGS,
    C_PRELOAD_LATENCY                   => 0,					--my
    C_PRELOAD_REGS                      => 1,					--my	
    --C_PRIM_FIFO_TYPE                    => C_PRIM_FIFO_TYPE,
              C_PRIM_FIFO_TYPE               =>  "512x36",  -- only used for V5 Hard FIFO        






    C_PROG_EMPTY_THRESH_ASSERT_VAL      => 10,
    C_PROG_EMPTY_THRESH_NEGATE_VAL      => 9,
    C_PROG_EMPTY_TYPE                   => 0,
    --C_PROG_FULL_THRESH_ASSERT_VAL       => if_then_else((UW_FIFO_TYPE = "BUILT_IN"), UW_FIFO_DEPTH-150, 14),		--my
    --C_PROG_FULL_THRESH_NEGATE_VAL       => if_then_else((UW_FIFO_TYPE = "BUILT_IN"), UW_FIFO_DEPTH-160, 12),		--my
    C_PROG_FULL_TYPE                    => 0,
    C_RD_DATA_COUNT_WIDTH               => clog2_uw_fifo_depth,		--my
--    C_RD_DATA_COUNT_WIDTH               => C_RD_DATA_COUNT_WIDTH,
    C_RD_DEPTH                          => uw_fifo_depth,
    --C_RD_FREQ                           => C_RD_FREQ,
    C_RD_FREQ                           => 1,					--my
    C_RD_PNTR_WIDTH                     => clog2_uw_fifo_depth,
--    C_UNDERFLOW_LOW                     => C_UNDERFLOW_LOW,
--    C_USE_DOUT_RST                      => C_USE_DOUT_RST,
--    C_USE_ECC                           => C_USE_ECC,
    C_USE_EMBEDDED_REG                  => 1,					--my
--    C_USE_EMBEDDED_REG                  => C_USE_EMBEDDED_REG,
--    C_USE_FIFO16_FLAGS                  => C_USE_FIFO16_FLAGS,
    C_USE_FWFT_DATA_COUNT               => 0,					--my
--    C_USE_FWFT_DATA_COUNT               => C_USE_FWFT_DATA_COUNT,
--    C_VALID_LOW                         => C_VALID_LOW,
--    C_WR_ACK_LOW                        => C_WR_ACK_LOW,
    C_WR_DATA_COUNT_WIDTH               => clog2_uw_fifo_depth,		--my
--    C_WR_DATA_COUNT_WIDTH               => C_WR_DATA_COUNT_WIDTH,
    C_WR_DEPTH                          => uw_fifo_depth,
    --C_WR_FREQ                           => C_WR_FREQ,
    C_WR_FREQ                           => 1,					--my
    C_WR_PNTR_WIDTH                     => clog2_uw_fifo_depth,
--    C_WR_RESPONSE_LATENCY               => C_WR_RESPONSE_LATENCY,
--    C_MSGON_VAL                         => C_MSGON_VAL,
--    C_ENABLE_RST_SYNC                   => C_ENABLE_RST_SYNC,
--    C_ERROR_INJECTION_TYPE              => C_ERROR_INJECTION_TYPE,
    C_SYNCHRONIZER_STAGE                => MTBF_STAGES,
              -- AXI Interface related parameters start here
              C_INTERFACE_TYPE               =>  0,    --           : integer := 0; -- 0: Native Interface; 1: AXI Interface
              C_AXI_TYPE                     =>  0,    --           : integer := 0; -- 0: AXI Stream; 1: AXI Full; 2: AXI Lite
              C_HAS_AXI_WR_CHANNEL           =>  0,    --           : integer := 0;
              C_HAS_AXI_RD_CHANNEL           =>  0,    --           : integer := 0;
              C_HAS_SLAVE_CE                 =>  0,    --           : integer := 0;
              C_HAS_MASTER_CE                =>  0,    --           : integer := 0;
              C_ADD_NGC_CONSTRAINT           =>  0,    --           : integer := 0;
              C_USE_COMMON_OVERFLOW          =>  0,    --           : integer := 0;
              C_USE_COMMON_UNDERFLOW         =>  0,    --           : integer := 0;
              C_USE_DEFAULT_SETTINGS         =>  0,    --           : integer := 0;

              -- AXI Full/Lite
              C_AXI_ID_WIDTH                 =>  4 ,    --           : integer := 0;
              C_AXI_ADDR_WIDTH               =>  32,    --           : integer := 0;
              C_AXI_DATA_WIDTH               =>  64,    --           : integer := 0;
              C_AXI_LEN_WIDTH                =>  8,     --           : integer := 8;
              C_AXI_LOCK_WIDTH               =>  2,     --           : integer := 2;
              C_HAS_AXI_ID                   =>  0,     --           : integer := 0;
              C_HAS_AXI_AWUSER               =>  0 ,    --           : integer := 0;
              C_HAS_AXI_WUSER                =>  0 ,    --           : integer := 0;
              C_HAS_AXI_BUSER                =>  0 ,    --           : integer := 0;
              C_HAS_AXI_ARUSER               =>  0 ,    --           : integer := 0;
              C_HAS_AXI_RUSER                =>  0 ,    --           : integer := 0;
              C_AXI_ARUSER_WIDTH             =>  1 ,    --           : integer := 0;
              C_AXI_AWUSER_WIDTH             =>  1 ,    --           : integer := 0;
              C_AXI_WUSER_WIDTH              =>  1 ,    --           : integer := 0;
              C_AXI_BUSER_WIDTH              =>  1 ,    --           : integer := 0;
              C_AXI_RUSER_WIDTH              =>  1 ,    --           : integer := 0;
                                                 
              -- AXI Streaming
              C_HAS_AXIS_TDATA               =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TID                 =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TDEST               =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TUSER               =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TREADY              =>  1 ,    --           : integer := 0;
              C_HAS_AXIS_TLAST               =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TSTRB               =>  0 ,    --           : integer := 0;
              C_HAS_AXIS_TKEEP               =>  0 ,    --           : integer := 0;
              C_AXIS_TDATA_WIDTH             =>  64,    --           : integer := 1;
              C_AXIS_TID_WIDTH               =>  8 ,    --           : integer := 1;
              C_AXIS_TDEST_WIDTH             =>  4 ,    --           : integer := 1;
              C_AXIS_TUSER_WIDTH             =>  4 ,    --           : integer := 1;
              C_AXIS_TSTRB_WIDTH             =>  4 ,    --           : integer := 1;
              C_AXIS_TKEEP_WIDTH             =>  4 ,    --           : integer := 1;

              -- AXI Channel Type
              -- WACH --> Write Address Channel
              -- WDCH --> Write Data Channel
              -- WRCH --> Write Response Channel
              -- RACH --> Read Address Channel
              -- RDCH --> Read Data Channel
              -- AXIS --> AXI Streaming
              C_WACH_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logic
              C_WDCH_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
              C_WRCH_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
              C_RACH_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
              C_RDCH_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
              C_AXIS_TYPE                   =>  0,    --            : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie

              -- AXI Implementation Type
              -- 1 = Common Clock Block RAM FIFO
              -- 2 = Common Clock Distributed RAM FIFO
              -- 11 = Independent Clock Block RAM FIFO
              -- 12 = Independent Clock Distributed RAM FIFO
              C_IMPLEMENTATION_TYPE_WACH    =>  1,    --            : integer := 0;
              C_IMPLEMENTATION_TYPE_WDCH    =>  1,    --            : integer := 0;
              C_IMPLEMENTATION_TYPE_WRCH    =>  1,    --            : integer := 0;
              C_IMPLEMENTATION_TYPE_RACH    =>  1,    --            : integer := 0;
              C_IMPLEMENTATION_TYPE_RDCH    =>  1,    --            : integer := 0;
              C_IMPLEMENTATION_TYPE_AXIS    =>  1,    --            : integer := 0;

              -- AXI FIFO Type
              -- 0 = Data FIFO
              -- 1 = Packet FIFO
              -- 2 = Low Latency Data FIFO
              C_APPLICATION_TYPE_WACH      =>  0,    --             : integer := 0;
              C_APPLICATION_TYPE_WDCH      =>  0,    --             : integer := 0;
              C_APPLICATION_TYPE_WRCH      =>  0,    --             : integer := 0;
              C_APPLICATION_TYPE_RACH      =>  0,    --             : integer := 0;
              C_APPLICATION_TYPE_RDCH      =>  0,    --             : integer := 0;
              C_APPLICATION_TYPE_AXIS      =>  0,    --             : integer := 0;

              -- Enable ECC
              -- 0 = ECC disabled
              -- 1 = ECC enabled
              C_USE_ECC_WACH               =>  0,    --             : integer := 0;
              C_USE_ECC_WDCH               =>  0,    --             : integer := 0;
              C_USE_ECC_WRCH               =>  0,    --             : integer := 0;
              C_USE_ECC_RACH               =>  0,    --             : integer := 0;
              C_USE_ECC_RDCH               =>  0,    --             : integer := 0;
              C_USE_ECC_AXIS               =>  0,    --             : integer := 0;

              -- ECC Error Injection Type
              -- 0 = No Error Injection
              -- 1 = Single Bit Error Injection
              -- 2 = Double Bit Error Injection
              -- 3 = Single Bit and Double Bit Error Injection
              C_ERROR_INJECTION_TYPE_WACH  =>  0,    --             : integer := 0;
              C_ERROR_INJECTION_TYPE_WDCH  =>  0,    --             : integer := 0;
              C_ERROR_INJECTION_TYPE_WRCH  =>  0,    --             : integer := 0;
              C_ERROR_INJECTION_TYPE_RACH  =>  0,    --             : integer := 0;
              C_ERROR_INJECTION_TYPE_RDCH  =>  0,    --             : integer := 0;
              C_ERROR_INJECTION_TYPE_AXIS  =>  0,    --             : integer := 0;

              -- Input Data Width
              -- Accumulation of all AXI input signal's width
              C_DIN_WIDTH_WACH                    =>  32,    --      : integer := 1;
              C_DIN_WIDTH_WDCH                    =>  64,    --      : integer := 1;
              C_DIN_WIDTH_WRCH                    =>  2 ,    --      : integer := 1;
              C_DIN_WIDTH_RACH                    =>  32,    --      : integer := 1;
              C_DIN_WIDTH_RDCH                    =>  64,    --      : integer := 1;
              C_DIN_WIDTH_AXIS                    =>  1 ,    --      : integer := 1;

              C_WR_DEPTH_WACH                     =>  16  ,   --      : integer := 16;
              C_WR_DEPTH_WDCH                     =>  1024,   --      : integer := 16;
              C_WR_DEPTH_WRCH                     =>  16  ,   --      : integer := 16;
              C_WR_DEPTH_RACH                     =>  16  ,   --      : integer := 16;
              C_WR_DEPTH_RDCH                     =>  1024,   --      : integer := 16;
              C_WR_DEPTH_AXIS                     =>  1024,   --      : integer := 16;

              C_WR_PNTR_WIDTH_WACH                =>  4 ,    --      : integer := 4;
              C_WR_PNTR_WIDTH_WDCH                =>  10,    --      : integer := 4;
              C_WR_PNTR_WIDTH_WRCH                =>  4 ,    --      : integer := 4;
              C_WR_PNTR_WIDTH_RACH                =>  4 ,    --      : integer := 4;
              C_WR_PNTR_WIDTH_RDCH                =>  10,    --      : integer := 4;
              C_WR_PNTR_WIDTH_AXIS                =>  10,    --      : integer := 4;

              C_HAS_DATA_COUNTS_WACH              =>  0,    --      : integer := 0;
              C_HAS_DATA_COUNTS_WDCH              =>  0,    --      : integer := 0;
              C_HAS_DATA_COUNTS_WRCH              =>  0,    --      : integer := 0;
              C_HAS_DATA_COUNTS_RACH              =>  0,    --      : integer := 0;
              C_HAS_DATA_COUNTS_RDCH              =>  0,    --      : integer := 0;
              C_HAS_DATA_COUNTS_AXIS              =>  0,    --      : integer := 0;

              C_HAS_PROG_FLAGS_WACH               =>  0,    --      : integer := 0;
              C_HAS_PROG_FLAGS_WDCH               =>  0,    --      : integer := 0;
              C_HAS_PROG_FLAGS_WRCH               =>  0,    --      : integer := 0;
              C_HAS_PROG_FLAGS_RACH               =>  0,    --      : integer := 0;
              C_HAS_PROG_FLAGS_RDCH               =>  0,    --      : integer := 0;
              C_HAS_PROG_FLAGS_AXIS               =>  0,    --      : integer := 0;

              C_PROG_FULL_TYPE_WACH               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_TYPE_WDCH               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_TYPE_WRCH               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_TYPE_RACH               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_TYPE_RDCH               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_TYPE_AXIS               =>  5   ,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_WACH  =>  1023,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_WDCH  =>  1023,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_WRCH  =>  1023,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_RACH  =>  1023,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_RDCH  =>  1023,    --      : integer := 0;
              C_PROG_FULL_THRESH_ASSERT_VAL_AXIS  =>  1023,    --      : integer := 0;

              C_PROG_EMPTY_TYPE_WACH              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_TYPE_WDCH              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_TYPE_WRCH              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_TYPE_RACH              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_TYPE_RDCH              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_TYPE_AXIS              =>  5   ,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH =>  1022,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH =>  1022,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH =>  1022,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH =>  1022,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH =>  1022,    --      : integer := 0;
              C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS =>  1022,    --      : integer := 0;

              C_REG_SLICE_MODE_WACH               =>  0,    --      : integer := 0;
              C_REG_SLICE_MODE_WDCH               =>  0,    --      : integer := 0;
              C_REG_SLICE_MODE_WRCH               =>  0,    --      : integer := 0;
              C_REG_SLICE_MODE_RACH               =>  0,    --      : integer := 0;
              C_REG_SLICE_MODE_RDCH               =>  0,    --      : integer := 0;
              C_REG_SLICE_MODE_AXIS               =>  0     --      : integer := 0


  )
  PORT MAP (
    backup                              => GND,
    backup_marker                       => GND,
    clk                                 => GND,
    rst                                 => rst,
    srst                                => GND,
    wr_clk                              => wr_clk,
    wr_rst                              => GND,
    rd_clk                              => rd_clk,
    rd_rst                              => GND,
    din                                 => din,
    wr_en                               => wr_en,
    rd_en                               => rd_en,
    sleep                     		=> sleep,
    wr_rst_busy                     	=> wr_rst_busy,
    rd_rst_busy                     	=> rd_rst_busy,

    prog_empty_thresh                   => ZERO_pntr,
    prog_empty_thresh_assert            => ZERO_pntr,
    prog_empty_thresh_negate            => ZERO_pntr,
    prog_full_thresh                    => ZERO_pntr,
    prog_full_thresh_assert             => ZERO_pntr,
    prog_full_thresh_negate             => ZERO_pntr,

    int_clk                             => GND,
    injectdbiterr                       => GND,
    injectsbiterr                       => GND,
    dout                                => dout,
    full                                => full,
    empty                               => empty,
    almost_full                         => ALMOST_FULL,
    wr_ack                              => WR_ACK,
    overflow                            => OVERFLOW,
    almost_empty                        => ALMOST_EMPTY,
    valid                               => VALID,
    underflow                           => UNDERFLOW,
    data_count                          => DATA_COUNT,
    rd_data_count                       => rd_data_count,
    wr_data_count                       => wr_data_count,
    prog_full                           => PROG_FULL,
    prog_empty                          => PROG_EMPTY,
    sbiterr                             => SBITERR,
    dbiterr                             => DBITERR,
              m_aclk                    =>  '0',                   --       : IN  std_logic := '0';
              s_aclk                    =>  '0',                   --       : IN  std_logic := '0';
              s_aresetn                 =>  '0',                   --       : IN  std_logic := '0';
              m_aclk_en                 =>  '0',                   --       : IN  std_logic := '0';
              s_aclk_en                 =>  '0',                   --       : IN  std_logic := '0';

              -- AXI Full/Lite Slave Write Channel (write side)
              s_axi_awid                =>  "0000",         --(others => '0'),      --      : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awaddr              =>  "00000000000000000000000000000000",   --(others => '0'),      --      : IN  std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awlen               =>  "00000000",          --(others => '0'),      --      : IN  std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awsize              =>  "000",          --(others => '0'),      --      : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awburst             =>  "00",           --(others => '0'),      --      : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awlock              =>  "00",           --(others => '0'),      --      : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awcache             =>  "0000",         --(others => '0'),      --      : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awprot              =>  "000",          --(others => '0'),      --      : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awqos               =>  "0000",         --(others => '0'),      --      : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awregion            =>  "0000",         --(others => '0'),      --      : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awuser              =>  "0",            --(others => '0'),      --      : IN  std_logic_vector(C_AXI_AWUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_awvalid             =>  '0',                  --      : IN  std_logic := '0';
              s_axi_awready             =>  S_AXI_AWREADY,        --      : OUT std_logic;
              s_axi_wid                 =>  "0000",         --(others => '0'),      --      : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_wdata               =>  "0000000000000000000000000000000000000000000000000000000000000000", --(others => '0'),      --      : IN  std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_wstrb               =>  "00000000",          --(others => '0'),      --      : IN  std_logic_vector(C_AXI_DATA_WIDTH/8-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_wlast               =>  '0',                  --      : IN  std_logic := '0';
              s_axi_wuser               =>  "0",            --(others => '0'),      --      : IN  std_logic_vector(C_AXI_WUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_wvalid              =>  '0',                  --      : IN  std_logic := '0';
              s_axi_wready              =>  S_AXI_WREADY,         --      : OUT std_logic;
              s_axi_bid                 =>  S_AXI_BID,            --      : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_bresp               =>  S_AXI_BRESP,          --      : OUT std_logic_vector(2-1 DOWNTO 0);
              s_axi_buser               =>  S_AXI_BUSER,          --      : OUT std_logic_vector(C_AXI_BUSER_WIDTH-1 DOWNTO 0);
              s_axi_bvalid              =>  S_AXI_BVALID,          --      : OUT std_logic;
              s_axi_bready              =>  '0',                  --      : IN  std_logic := '0';

              -- AXI Full/Lite Master Write Channel (Read side)
              m_axi_awid                =>  M_AXI_AWID,           --       : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0);
              m_axi_awaddr              =>  M_AXI_AWADDR,         --       : OUT std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0);
              m_axi_awlen               =>  M_AXI_AWLEN,          --       : OUT std_logic_vector(8-1 DOWNTO 0);
              m_axi_awsize              =>  M_AXI_AWSIZE,         --       : OUT std_logic_vector(3-1 DOWNTO 0);
              m_axi_awburst             =>  M_AXI_AWBURST,        --       : OUT std_logic_vector(2-1 DOWNTO 0);
              m_axi_awlock              =>  M_AXI_AWLOCK,         --       : OUT std_logic_vector(2-1 DOWNTO 0);
              m_axi_awcache             =>  M_AXI_AWCACHE,        --       : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_awprot              =>  M_AXI_AWPROT,         --       : OUT std_logic_vector(3-1 DOWNTO 0);
              m_axi_awqos               =>  M_AXI_AWQOS,          --       : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_awregion            =>  M_AXI_AWREGION,       --       : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_awuser              =>  M_AXI_AWUSER,         --       : OUT std_logic_vector(C_AXI_AWUSER_WIDTH-1 DOWNTO 0);
              m_axi_awvalid             =>  M_AXI_AWVALID,        --       : OUT std_logic;
              m_axi_awready             =>  '0',                  --       : IN  std_logic := '0';
              m_axi_wid                 =>  M_AXI_WID,            --       : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0);
              m_axi_wdata               =>  M_AXI_WDATA,          --       : OUT std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0);
              m_axi_wstrb               =>  M_AXI_WSTRB,          --       : OUT std_logic_vector(C_AXI_DATA_WIDTH/8-1 DOWNTO 0);
              m_axi_wlast               =>  M_AXI_WLAST,          --       : OUT std_logic;
              m_axi_wuser               =>  M_AXI_WUSER,          --       : OUT std_logic_vector(C_AXI_WUSER_WIDTH-1 DOWNTO 0);
              m_axi_wvalid              =>  M_AXI_WVALID,         --       : OUT std_logic;
              m_axi_wready              =>  '0',                  --       : IN  std_logic := '0';
              m_axi_bid                 =>  "0000",               --(others => '0'),      --       : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              m_axi_bresp               =>  "00",                 --(others => '0'),      --       : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              m_axi_buser               =>  "0",                  --(others => '0'),      --       : IN  std_logic_vector(C_AXI_BUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              m_axi_bvalid              =>  '0',                  --       : IN  std_logic := '0';
              m_axi_bready              =>  M_AXI_BREADY,         --       : OUT std_logic;

              -- AXI Full/Lite Slave Read Channel (Write side)
              s_axi_arid               =>  "0000",         --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_araddr             =>  "00000000000000000000000000000000",   --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0'); 
              s_axi_arlen              =>  "00000000",          --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arsize             =>  "000",          --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arburst            =>  "00",           --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arlock             =>  "00",           --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arcache            =>  "0000",         --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arprot             =>  "000",          --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arqos              =>  "0000",         --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arregion           =>  "0000",         --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_aruser             =>  "0",            --(others => '0'),      (others => '0'),       --       : IN  std_logic_vector(C_AXI_ARUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axi_arvalid            =>  '0',                   --       : IN  std_logic := '0';
              s_axi_arready            =>  S_AXI_ARREADY,         --       : OUT std_logic;
              s_axi_rid                =>  S_AXI_RID,             --       : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0);       
              s_axi_rdata              =>  S_AXI_RDATA,           --       : OUT std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0); 
              s_axi_rresp              =>  S_AXI_RRESP,           --       : OUT std_logic_vector(2-1 DOWNTO 0);
              s_axi_rlast              =>  S_AXI_RLAST,           --       : OUT std_logic;
              s_axi_ruser              =>  S_AXI_RUSER,           --       : OUT std_logic_vector(C_AXI_RUSER_WIDTH-1 DOWNTO 0);
              s_axi_rvalid             =>  S_AXI_RVALID,          --       : OUT std_logic;
              s_axi_rready             =>  '0',                   --       : IN  std_logic := '0';

              -- AXI Full/Lite Master Read Channel (Read side)
              m_axi_arid               =>  M_AXI_ARID,           --        : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0);        
              m_axi_araddr             =>  M_AXI_ARADDR,         --        : OUT std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0);  
              m_axi_arlen              =>  M_AXI_ARLEN,          --        : OUT std_logic_vector(8-1 DOWNTO 0);
              m_axi_arsize             =>  M_AXI_ARSIZE,         --        : OUT std_logic_vector(3-1 DOWNTO 0);
              m_axi_arburst            =>  M_AXI_ARBURST,        --        : OUT std_logic_vector(2-1 DOWNTO 0);
              m_axi_arlock             =>  M_AXI_ARLOCK,         --        : OUT std_logic_vector(2-1 DOWNTO 0);
              m_axi_arcache            =>  M_AXI_ARCACHE,        --        : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_arprot             =>  M_AXI_ARPROT,         --        : OUT std_logic_vector(3-1 DOWNTO 0);
              m_axi_arqos              =>  M_AXI_ARQOS,          --        : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_arregion           =>  M_AXI_ARREGION,       --        : OUT std_logic_vector(4-1 DOWNTO 0);
              m_axi_aruser             =>  M_AXI_ARUSER,         --        : OUT std_logic_vector(C_AXI_ARUSER_WIDTH-1 DOWNTO 0);
              m_axi_arvalid            =>  M_AXI_ARVALID,        --        : OUT std_logic;
              m_axi_arready            =>  '0',                  --        : IN  std_logic := '0';
              m_axi_rid                =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');        
              m_axi_rdata              =>  "0000000000000000000000000000000000000000000000000000000000000000", --(others => '0'),      --        : IN  std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');  
              m_axi_rresp              =>  "00",                 --(others => '0'),      --        : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
              m_axi_rlast              =>  '0',                  --        : IN  std_logic := '0';
              m_axi_ruser              =>  "0",                  --(others => '0'),      --        : IN  std_logic_vector(C_AXI_RUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              m_axi_rvalid             =>  '0',                  --        : IN  std_logic := '0';
              m_axi_rready             =>  M_AXI_RREADY,         --        : OUT std_logic;

              -- AXI Streaming Slave Signals (Write side)
              s_axis_tvalid            =>  '0',                  --        : IN  std_logic := '0';
              s_axis_tready            =>  S_AXIS_TREADY,        --        : OUT std_logic;
              s_axis_tdata             =>  "0000000000000000000000000000000000000000000000000000000000000000", --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TDATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axis_tstrb             =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TSTRB_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axis_tkeep             =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TKEEP_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axis_tlast             =>  '0',                  --        : IN  std_logic := '0';
              s_axis_tid               =>  "00000000",                 --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axis_tdest             =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TDEST_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
              s_axis_tuser             =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_AXIS_TUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

              -- AXI Streaming Master Signals (Read side)
              m_axis_tvalid            =>  M_AXIS_TVALID,        --        : OUT std_logic;
              m_axis_tready            =>  '0',                  --        : IN  std_logic := '0';
              m_axis_tdata             =>  M_AXIS_TDATA,         --        : OUT std_logic_vector(C_AXIS_TDATA_WIDTH-1 DOWNTO 0);
              m_axis_tstrb             =>  M_AXIS_TSTRB,         --        : OUT std_logic_vector(C_AXIS_TSTRB_WIDTH-1 DOWNTO 0);
              m_axis_tkeep             =>  M_AXIS_TKEEP,         --        : OUT std_logic_vector(C_AXIS_TKEEP_WIDTH-1 DOWNTO 0);
              m_axis_tlast             =>  M_AXIS_TLAST,         --        : OUT std_logic;
              m_axis_tid               =>  M_AXIS_TID,           --        : OUT std_logic_vector(C_AXIS_TID_WIDTH-1 DOWNTO 0);
              m_axis_tdest             =>  M_AXIS_TDEST,         --        : OUT std_logic_vector(C_AXIS_TDEST_WIDTH-1 DOWNTO 0);
              m_axis_tuser             =>  M_AXIS_TUSER,         --        : OUT std_logic_vector(C_AXIS_TUSER_WIDTH-1 DOWNTO 0);

              -- AXI Full/Lite Write Address Channel Signals
              axi_aw_injectsbiterr     =>  '0',                  --        : IN  std_logic := '0';
              axi_aw_injectdbiterr     =>  '0',                  --        : IN  std_logic := '0';
              axi_aw_prog_full_thresh  =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WACH-1 DOWNTO 0) := (OTHERS => '0');
              axi_aw_prog_empty_thresh =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WACH-1 DOWNTO 0) := (OTHERS => '0');
              axi_aw_data_count        =>  AXI_AW_DATA_COUNT,    --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0);
              axi_aw_wr_data_count     =>  AXI_AW_WR_DATA_COUNT, --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0);
              axi_aw_rd_data_count     =>  AXI_AW_RD_DATA_COUNT, --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0);
              axi_aw_sbiterr           =>  AXI_AW_SBITERR,       --        : OUT std_logic;
              axi_aw_dbiterr           =>  AXI_AW_DBITERR,       --        : OUT std_logic;
              axi_aw_overflow          =>  AXI_AW_OVERFLOW,      --        : OUT std_logic;
              axi_aw_underflow         =>  AXI_AW_UNDERFLOW,     --        : OUT std_logic;
              axi_aw_prog_full         =>  AXI_AW_PROG_FULL,     --        : OUT STD_LOGIC := '0';
              axi_aw_prog_empty        =>  AXI_AW_PROG_EMPTY,    --        : OUT STD_LOGIC := '1';


              -- AXI Full/Lite Write Data Channel Signals
              axi_w_injectsbiterr      =>  '0',                  --        : IN  std_logic := '0';
              axi_w_injectdbiterr      =>  '0',                  --        : IN  std_logic := '0';
              axi_w_prog_full_thresh   =>  "0000000000",         --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WDCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_w_prog_empty_thresh  =>  "0000000000",         --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WDCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_w_data_count         =>  AXI_W_DATA_COUNT,     --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0);
              axi_w_wr_data_count      =>  AXI_W_WR_DATA_COUNT,  --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0);
              axi_w_rd_data_count      =>  AXI_W_RD_DATA_COUNT,  --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0);
              axi_w_sbiterr            =>  AXI_W_SBITERR,        --        : OUT std_logic;
              axi_w_dbiterr            =>  AXI_W_DBITERR,        --        : OUT std_logic;
              axi_w_overflow           =>  AXI_W_OVERFLOW,       --        : OUT std_logic;
              axi_w_underflow          =>  AXI_W_UNDERFLOW,      --        : OUT std_logic;
              axi_w_prog_full          =>  AXI_W_PROG_FULL,      --        : OUT STD_LOGIC := '0';
              axi_w_prog_empty         =>  AXI_W_PROG_EMPTY,     --        : OUT STD_LOGIC := '1';

              -- AXI Full/Lite Write Response Channel Signals
              axi_b_injectsbiterr      =>  '0',                  --        : IN  std_logic := '0';
              axi_b_injectdbiterr      =>  '0',                  --        : IN  std_logic := '0';
              axi_b_prog_full_thresh   =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WRCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_b_prog_empty_thresh  =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WRCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_b_data_count         =>  AXI_B_DATA_COUNT,     --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0);
              axi_b_wr_data_count      =>  AXI_B_WR_DATA_COUNT,  --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0);
              axi_b_rd_data_count      =>  AXI_B_RD_DATA_COUNT,  --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0);
              axi_b_sbiterr            =>  AXI_B_SBITERR,        --        : OUT std_logic;
              axi_b_dbiterr            =>  AXI_B_DBITERR,        --        : OUT std_logic;
              axi_b_overflow           =>  AXI_B_OVERFLOW,       --        : OUT std_logic;
              axi_b_underflow          =>  AXI_B_UNDERFLOW,      --        : OUT std_logic;
              axi_b_prog_full          =>  AXI_B_PROG_FULL,      --        : OUT STD_LOGIC := '0';
              axi_b_prog_empty         =>  AXI_B_PROG_EMPTY,     --        : OUT STD_LOGIC := '1';

              -- AXI Full/Lite Read Address Channel Signals
              axi_ar_injectsbiterr     =>  '0',                  --        : IN  std_logic := '0';
              axi_ar_injectdbiterr     =>  '0',                  --        : IN  std_logic := '0';
              axi_ar_prog_full_thresh  =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_RACH-1 DOWNTO 0) := (OTHERS => '0');
              axi_ar_prog_empty_thresh =>  "0000",               --(others => '0'),      --        : IN  std_logic_vector(C_WR_PNTR_WIDTH_RACH-1 DOWNTO 0) := (OTHERS => '0');
              axi_ar_data_count        =>  AXI_AR_DATA_COUNT,    --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0);
              axi_ar_wr_data_count     =>  AXI_AR_WR_DATA_COUNT, --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0);
              axi_ar_rd_data_count     =>  AXI_AR_RD_DATA_COUNT, --        : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0);
              axi_ar_sbiterr           =>  AXI_AR_SBITERR,       --        : OUT std_logic;
              axi_ar_dbiterr           =>  AXI_AR_DBITERR,       --        : OUT std_logic;
              axi_ar_overflow          =>  AXI_AR_OVERFLOW,      --        : OUT std_logic;
              axi_ar_underflow         =>  AXI_AR_UNDERFLOW,     --        : OUT std_logic;
              axi_ar_prog_full         =>  AXI_AR_PROG_FULL,     --        : OUT STD_LOGIC := '0';
              axi_ar_prog_empty        =>  AXI_AR_PROG_EMPTY,    --        : OUT STD_LOGIC := '1';

              -- AXI Full/Lite Read Data Channel Signals
              axi_r_injectsbiterr     =>  '0',                  --         : IN  std_logic := '0';
              axi_r_injectdbiterr     =>  '0',                  --         : IN  std_logic := '0';
              axi_r_prog_full_thresh  =>  "0000000000",         --(others => '0'),      --         : IN  std_logic_vector(C_WR_PNTR_WIDTH_RDCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_r_prog_empty_thresh =>  "0000000000",         --(others => '0'),      --         : IN  std_logic_vector(C_WR_PNTR_WIDTH_RDCH-1 DOWNTO 0) := (OTHERS => '0');
              axi_r_data_count        =>  AXI_R_DATA_COUNT,     --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0);
              axi_r_wr_data_count     =>  AXI_R_WR_DATA_COUNT,  --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0);
              axi_r_rd_data_count     =>  AXI_R_RD_DATA_COUNT,  --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0);
              axi_r_sbiterr           =>  AXI_R_SBITERR,        --         : OUT std_logic;
              axi_r_dbiterr           =>  AXI_R_DBITERR,        --         : OUT std_logic;
              axi_r_overflow          =>  AXI_R_OVERFLOW,       --         : OUT std_logic;
              axi_r_underflow         =>  AXI_R_UNDERFLOW,      --         : OUT std_logic;
              axi_r_prog_full         =>  AXI_R_PROG_FULL,      --         : OUT STD_LOGIC := '0';
              axi_r_prog_empty        =>  AXI_R_PROG_EMPTY,     --         : OUT STD_LOGIC := '1';

              -- AXI Streaming FIFO Related Signals
              axis_injectsbiterr      =>  '0',                  --         : IN  std_logic := '0';
              axis_injectdbiterr      =>  '0',                  --         : IN  std_logic := '0';
              axis_prog_full_thresh   =>  "0000000000",         --(others => '0'),      --         : IN  std_logic_vector(C_WR_PNTR_WIDTH_AXIS-1 DOWNTO 0) := (OTHERS => '0');
              axis_prog_empty_thresh  =>  "0000000000",         --(others => '0'),      --         : IN  std_logic_vector(C_WR_PNTR_WIDTH_AXIS-1 DOWNTO 0) := (OTHERS => '0');
              axis_data_count         =>  AXIS_DATA_COUNT,      --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0);
              axis_wr_data_count      =>  AXIS_WR_DATA_COUNT,   --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0);
              axis_rd_data_count      =>  AXIS_RD_DATA_COUNT,   --         : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0);
              axis_sbiterr            =>  AXIS_SBITERR,         --         : OUT std_logic;
              axis_dbiterr            =>  AXIS_DBITERR,         --         : OUT std_logic;
              axis_overflow           =>  AXIS_OVERFLOW,        --         : OUT std_logic;
              axis_underflow          =>  AXIS_UNDERFLOW,       --         : OUT std_logic
              axis_prog_full          =>  AXIS_PROG_FULL,       --         : OUT STD_LOGIC := '0';
              axis_prog_empty         =>  AXIS_PROG_EMPTY       --         : OUT STD_LOGIC := '1';
  );

END ARCHITECTURE xilinx;
