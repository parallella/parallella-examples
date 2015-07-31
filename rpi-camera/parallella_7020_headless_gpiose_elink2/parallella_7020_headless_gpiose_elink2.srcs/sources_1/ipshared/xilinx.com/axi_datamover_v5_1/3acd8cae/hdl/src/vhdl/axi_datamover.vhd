-------------------------------------------------------------------------------
-- axi_datamover.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--                                                                      
--  (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-- Filename:        axi_datamover.vhd
--
-- Description:     
--  Top level VHDL wrapper for the AXI DataMover                
--                  
--                  
--                  
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



library axi_datamover_v5_1;
use axi_datamover_v5_1.axi_datamover_mm2s_omit_wrap ;
use axi_datamover_v5_1.axi_datamover_mm2s_full_wrap ;
use axi_datamover_v5_1.axi_datamover_mm2s_basic_wrap;
use axi_datamover_v5_1.axi_datamover_s2mm_omit_wrap ;
use axi_datamover_v5_1.axi_datamover_s2mm_full_wrap ;
use axi_datamover_v5_1.axi_datamover_s2mm_basic_wrap;


-------------------------------------------------------------------------------

entity axi_datamover is
  generic (
    C_INCLUDE_MM2S              : Integer range 0 to  2 :=  2;
       -- Specifies the type of MM2S function to include
       -- 0 = Omit MM2S functionality
       -- 1 = Full MM2S Functionality
       -- 2 = Basic MM2S functionality
       
    C_M_AXI_MM2S_ARID           : Integer range 0 to  255 :=  0;
       -- Specifies the constant value to output on 
       -- the ARID output port
       
    C_M_AXI_MM2S_ID_WIDTH       : Integer range 1 to  8 :=  4;
       -- Specifies the width of the MM2S ID port 
       
    C_M_AXI_MM2S_ADDR_WIDTH     : Integer range 32 to  64 :=  32;
       -- Specifies the width of the MMap Read Address Channel 
       -- Address bus
       
    C_M_AXI_MM2S_DATA_WIDTH     : Integer range 32 to 1024 :=  32;
       -- Specifies the width of the MMap Read Data Channel
       -- data bus
    
    C_M_AXIS_MM2S_TDATA_WIDTH   : Integer range 8 to 1024 :=  32;
       -- Specifies the width of the MM2S Master Stream Data 
       -- Channel data bus
    
    C_INCLUDE_MM2S_STSFIFO      : Integer range 0 to  1 :=  1;
       -- Specifies if a Status FIFO is to be implemented
       -- 0 = Omit MM2S Status FIFO
       -- 1 = Include MM2S Status FIFO
       
    C_MM2S_STSCMD_FIFO_DEPTH    : Integer range 1 to 16 :=  4;
       -- Specifies the depth of the MM2S Command FIFO and the 
       -- optional Status FIFO
       -- Valid values are 1,4,8,16
       
    C_MM2S_STSCMD_IS_ASYNC      : Integer range 0 to  1 :=  0;
       -- Specifies if the Status and Command interfaces need to
       -- be asynchronous to the primary data path clocking
       -- 0 = Use same clocking as data path
       -- 1 = Use special Status/Command clock for the interfaces
       
    C_INCLUDE_MM2S_DRE          : Integer range 0 to  1 :=  1;
       -- Specifies if DRE is to be included in the MM2S function 
       -- 0 = Omit DRE
       -- 1 = Include DRE
    
    C_MM2S_BURST_SIZE           : Integer range 2 to  256 :=  16;
       -- Specifies the max number of databeats to use for MMap
       -- burst transfers by the MM2S function 
    
    C_MM2S_BTT_USED             : Integer range 8 to  23 :=  16;
      -- Specifies the number of bits used from the BTT field
      -- of the input Command Word of the MM2S Command Interface 
   
    C_MM2S_ADDR_PIPE_DEPTH      : Integer range 1 to 30 := 3;
      -- This parameter specifies the depth of the MM2S internal 
      -- child command queues in the Read Address Controller and 
      -- the Read Data Controller. Increasing this value will 
      -- allow more Read Addresses to be issued to the AXI4 Read 
      -- Address Channel before receipt of the associated read 
      -- data on the Read Data Channel.

    C_MM2S_INCLUDE_SF           : Integer range 0 to 1 := 1 ;
      -- This parameter specifies the inclusion/omission of the
      -- MM2S (Read) Store and Forward function
      -- 0 = Omit MM2S Store and Forward
      -- 1 = Include MM2S Store and Forward
    
  
   
     
    
    C_INCLUDE_S2MM              : Integer range 0 to  4 :=  2;
       -- Specifies the type of S2MM function to include
       -- 0 = Omit S2MM functionality
       -- 1 = Full S2MM Functionality
       -- 2 = Basic S2MM functionality
       
    C_M_AXI_S2MM_AWID           : Integer range 0 to  255 :=  1;
       -- Specifies the constant value to output on 
       -- the ARID output port
       
    C_M_AXI_S2MM_ID_WIDTH       : Integer range 1 to  8 :=  4;
       -- Specifies the width of the S2MM ID port 
       
    C_M_AXI_S2MM_ADDR_WIDTH     : Integer range 32 to  64 :=  32;
       -- Specifies the width of the MMap Read Address Channel 
       -- Address bus
       
    C_M_AXI_S2MM_DATA_WIDTH     : Integer range 32 to 1024 :=  32;
       -- Specifies the width of the MMap Read Data Channel
       -- data bus
    
    C_S_AXIS_S2MM_TDATA_WIDTH   : Integer range 8 to 1024 :=  32;
       -- Specifies the width of the S2MM Master Stream Data 
       -- Channel data bus
    
    C_INCLUDE_S2MM_STSFIFO      : Integer range 0 to  1 :=  1;
       -- Specifies if a Status FIFO is to be implemented
       -- 0 = Omit S2MM Status FIFO
       -- 1 = Include S2MM Status FIFO
       
    C_S2MM_STSCMD_FIFO_DEPTH    : Integer range 1 to 16 :=  4;
       -- Specifies the depth of the S2MM Command FIFO and the 
       -- optional Status FIFO
       -- Valid values are 1,4,8,16
       
    C_S2MM_STSCMD_IS_ASYNC      : Integer range 0 to  1 :=  0;
       -- Specifies if the Status and Command interfaces need to
       -- be asynchronous to the primary data path clocking
       -- 0 = Use same clocking as data path
       -- 1 = Use special Status/Command clock for the interfaces
       
    C_INCLUDE_S2MM_DRE          : Integer range 0 to  1 :=  1;
       -- Specifies if DRE is to be included in the S2MM function 
       -- 0 = Omit DRE
       -- 1 = Include DRE
    
    C_S2MM_BURST_SIZE           : Integer range 2 to  256 :=  16;
       -- Specifies the max number of databeats to use for MMap
       -- burst transfers by the S2MM function 
    
    C_S2MM_BTT_USED             : Integer range 8 to  23 :=  16;
      -- Specifies the number of bits used from the BTT field
      -- of the input Command Word of the S2MM Command Interface 
   
    C_S2MM_SUPPORT_INDET_BTT    : Integer range 0 to  1 :=  0;
       -- Specifies if support for indeterminate packet lengths
       -- are to be received on the input Stream interface 
       -- 0 = Omit support (User MUST transfer the exact number of  
       --     bytes on the Stream interface as specified in the BTT 
       --     field of the Corresponding DataMover Command)
       -- 1 = Include support for indeterminate packet lengths
       --     This causes FIFOs to be added and "Store and Forward" 
       --     behavior of the S2MM function

    C_S2MM_ADDR_PIPE_DEPTH      : Integer range 1 to 30 := 3;
        -- This parameter specifies the depth of the S2MM internal 
        -- address pipeline queues in the Write Address Controller 
        -- and the Write Data Controller. Increasing this value will 
        -- allow more Write Addresses to be issued to the AXI4 Write 
        -- Address Channel before transmission of the associated  
        -- write data on the Write Data Channel.

    C_S2MM_INCLUDE_SF           : Integer range 0 to 1 := 1 ;
      -- This parameter specifies the inclusion/omission of the
      -- S2MM (Write) Store and Forward function
      -- 0 = Omit S2MM Store and Forward
      -- 1 = Include S2MM Store and Forward
 
    C_ENABLE_CACHE_USER             : integer range 0 to 1 := 0; 

    C_ENABLE_SKID_BUF                  : string := "11111";
    C_ENABLE_MM2S_TKEEP             : integer range 0 to 1 := 1; 
    C_ENABLE_S2MM_TKEEP             : integer range 0 to 1 := 1;
    C_ENABLE_S2MM_ADV_SIG           : integer range 0 to 1 := 0; 
    C_ENABLE_MM2S_ADV_SIG           : integer range 0 to 1 := 0; 
    C_MICRO_DMA                     : integer range 0 to 1 := 0;
     
    C_FAMILY                    : String := "virtex7"
       -- Specifies the target FPGA family type
    
    
    );
  port (

      -- MM2S Primary Clock input ----------------------------------
      m_axi_mm2s_aclk           : in  std_logic;                  --
         -- Primary synchronization clock for the Master side     --
         -- interface and internal logic. It is also used         --
         -- for the User interface synchronization when           --
         -- C_STSCMD_IS_ASYNC = 0.                                --
                                                                  --
      -- MM2S Primary Reset input                                 --
      m_axi_mm2s_aresetn        : in  std_logic;                  --
         -- Reset used for the internal master logic              --
      --------------------------------------------------------------

      -- MM2S Halt request input control --------------------
      mm2s_halt                 : in  std_logic;           --
         -- Active high soft shutdown request              --
                                                           --
      -- MM2S Halt Complete status flag                    --
      mm2s_halt_cmplt           : Out std_logic;           --
         -- Active high soft shutdown complete status      --
      -------------------------------------------------------
      
      
      -- Error discrete output -------------------------
      mm2s_err                  : Out std_logic;      --
         -- Composite Error indication                --
      --------------------------------------------------
     
     
      -- Memory Map to Stream Command FIFO and Status FIFO I/O ---------
      m_axis_mm2s_cmdsts_aclk    : in  std_logic;                     --
      -- Secondary Clock input for async CMD/Status interface         --
                                                                      --
      m_axis_mm2s_cmdsts_aresetn : in  std_logic;                     --
        -- Secondary Reset input for async CMD/Status interface       --
      ------------------------------------------------------------------
      
      
      
      -- User Command Interface Ports (AXI Stream) -------------------------------------------------
      s_axis_mm2s_cmd_tvalid     : in  std_logic;                                                 -- 
      s_axis_mm2s_cmd_tready     : out std_logic;                                                 -- 
      s_axis_mm2s_cmd_tdata      : in  std_logic_vector(((8*C_ENABLE_CACHE_USER)+C_M_AXI_MM2S_ADDR_WIDTH+40)-1 downto 0); --
      ---------------------------------------------------------------------------------------------- 
      
      -- User Status Interface Ports (AXI Stream) ------------------------
      m_axis_mm2s_sts_tvalid     : out std_logic;                       --
      m_axis_mm2s_sts_tready     : in  std_logic;                       --
      m_axis_mm2s_sts_tdata      : out std_logic_vector(7 downto 0);    --
      m_axis_mm2s_sts_tkeep      : out std_logic_vector(0 downto 0);    --
      m_axis_mm2s_sts_tlast      : out std_logic;                       --
      --------------------------------------------------------------------
      
      
      -- Address Posting contols -----------------------
      mm2s_allow_addr_req       : in  std_logic;      --                 
      mm2s_addr_req_posted      : out std_logic;      --                 
      mm2s_rd_xfer_cmplt        : out std_logic;      --
      --------------------------------------------------                 
      
      
      -- MM2S AXI Address Channel I/O  --------------------------------------------------
      m_axi_mm2s_arid     : out std_logic_vector(C_M_AXI_MM2S_ID_WIDTH-1 downto 0);    --
         -- AXI Address Channel ID output                                              --
                                                                                       --
      m_axi_mm2s_araddr   : out std_logic_vector(C_M_AXI_MM2S_ADDR_WIDTH-1 downto 0);  --
         -- AXI Address Channel Address output                                         --
                                                                                       --
      m_axi_mm2s_arlen    : out std_logic_vector(7 downto 0);                          --
         -- AXI Address Channel LEN output                                             --
         -- Sized to support 256 data beat bursts                                      --
                                                                                       --
      m_axi_mm2s_arsize   : out std_logic_vector(2 downto 0);                          --
         -- AXI Address Channel SIZE output                                            --
                                                                                       --
      m_axi_mm2s_arburst  : out std_logic_vector(1 downto 0);                          --
         -- AXI Address Channel BURST output                                           --
                                                                                       --
      m_axi_mm2s_arprot   : out std_logic_vector(2 downto 0);                          --
         -- AXI Address Channel PROT output                                            --
                                                                                       --
      m_axi_mm2s_arcache  : out std_logic_vector(3 downto 0);                          --
         -- AXI Address Channel CACHE output                                           --

      m_axi_mm2s_aruser   : out std_logic_vector(3 downto 0);                          --
         -- AXI Address Channel USER output                                           --
                                                                                       --
      m_axi_mm2s_arvalid  : out std_logic;                                             --
         -- AXI Address Channel VALID output                                           --
                                                                                       --
      m_axi_mm2s_arready  : in  std_logic;                                             --
         -- AXI Address Channel READY input                                            --
      -----------------------------------------------------------------------------------  
                                              
                                              
                                              
                                              
      -- Currently unsupported AXI Address Channel output signals -------
        -- m_axi_mm2s_alock   : out std_logic_vector(2 downto 0);      --
        -- m_axi_mm2s_acache  : out std_logic_vector(4 downto 0);      --
        -- m_axi_mm2s_aqos    : out std_logic_vector(3 downto 0);      --
        -- m_axi_mm2s_aregion : out std_logic_vector(3 downto 0);      --
      -------------------------------------------------------------------
  
  
  
  
      
      -- MM2S AXI MMap Read Data Channel I/O  ------------------------------------------------
      m_axi_mm2s_rdata        : In  std_logic_vector(C_M_AXI_MM2S_DATA_WIDTH-1 downto 0);   -- 
      m_axi_mm2s_rresp        : In  std_logic_vector(1 downto 0);                           -- 
      m_axi_mm2s_rlast        : In  std_logic;                                              -- 
      m_axi_mm2s_rvalid       : In  std_logic;                                              -- 
      m_axi_mm2s_rready       : Out std_logic;                                              -- 
      ----------------------------------------------------------------------------------------
      
      
      -- MM2S AXI Master Stream Channel I/O  -------------------------------------------------------
      m_axis_mm2s_tdata       : Out  std_logic_vector(C_M_AXIS_MM2S_TDATA_WIDTH-1 downto 0);      -- 
      m_axis_mm2s_tkeep       : Out  std_logic_vector((C_M_AXIS_MM2S_TDATA_WIDTH/8)-1 downto 0);  -- 
      m_axis_mm2s_tlast       : Out  std_logic;                                                   -- 
      m_axis_mm2s_tvalid      : Out  std_logic;                                                   -- 
      m_axis_mm2s_tready      : In   std_logic;                                                   -- 
      ----------------------------------------------------------------------------------------------
      
      -- Testing Support I/O --------------------------------------------------------
      mm2s_dbg_sel            : in  std_logic_vector( 3 downto 0);                 -- 
      mm2s_dbg_data           : out std_logic_vector(31 downto 0) ;                -- 
      -------------------------------------------------------------------------------
      

 
      
      
      -- S2MM Primary Clock input ---------------------------------
      m_axi_s2mm_aclk         : in  std_logic;                   --
         -- Primary synchronization clock for the Master side    --
         -- interface and internal logic. It is also used        --
         -- for the User interface synchronization when          --
         -- C_STSCMD_IS_ASYNC = 0.                               --
                                                                 --
      -- S2MM Primary Reset input                                --
      m_axi_s2mm_aresetn      : in  std_logic;                   --
         -- Reset used for the internal master logic             --
      -------------------------------------------------------------                                                           
 
     
      -- S2MM Halt request input control ------------------
      s2mm_halt               : in  std_logic;           --
         -- Active high soft shutdown request            --
                                                         --
      -- S2MM Halt Complete status flag                  --
      s2mm_halt_cmplt         : out std_logic;           --
         -- Active high soft shutdown complete status    --
      -----------------------------------------------------
      
      
      -- S2MM Error discrete output ------------------
      s2mm_err                : Out std_logic;      --
         -- Composite Error indication              --
      ------------------------------------------------
      
      
     
      -- Memory Map to Stream Command FIFO and Status FIFO I/O -----------------
      m_axis_s2mm_cmdsts_awclk   : in  std_logic;                             --
      -- Secondary Clock input for async CMD/Status interface                 --
                                                                              --
      m_axis_s2mm_cmdsts_aresetn : in  std_logic;                             --
        -- Secondary Reset input for async CMD/Status interface               --
      --------------------------------------------------------------------------  
      
      -- User Command Interface Ports (AXI Stream) --------------------------------------------------
      s_axis_s2mm_cmd_tvalid     : in  std_logic;                                                  --
      s_axis_s2mm_cmd_tready     : out std_logic;                                                  --
      s_axis_s2mm_cmd_tdata      : in  std_logic_vector(((8*C_ENABLE_CACHE_USER)+C_M_AXI_S2MM_ADDR_WIDTH+40)-1 downto 0);  --
      -----------------------------------------------------------------------------------------------
                                                                                                     
                                                                                                     
      -- User Status Interface Ports (AXI Stream) -----------------------------------------------------------
      m_axis_s2mm_sts_tvalid     : out std_logic;                                                          --
      m_axis_s2mm_sts_tready     : in  std_logic;                                                          --
      m_axis_s2mm_sts_tdata      : out std_logic_vector(((C_S2MM_SUPPORT_INDET_BTT*24)+8)-1 downto 0);     --
      m_axis_s2mm_sts_tkeep      : out std_logic_vector((((C_S2MM_SUPPORT_INDET_BTT*24)+8)/8)-1 downto 0); --
      m_axis_s2mm_sts_tlast      : out std_logic;                                                          --
      -------------------------------------------------------------------------------------------------------
      
      -- Address posting controls -----------------------------------------
      s2mm_allow_addr_req    : in  std_logic;                            --
      s2mm_addr_req_posted   : out std_logic;                            --
      s2mm_wr_xfer_cmplt     : out std_logic;                            --
      s2mm_ld_nxt_len        : out std_logic;                            --
      s2mm_wr_len            : out std_logic_vector(7 downto 0);         --
      ---------------------------------------------------------------------
      
     
      -- S2MM AXI Address Channel I/O  ----------------------------------------------------
      m_axi_s2mm_awid       : out std_logic_vector(C_M_AXI_S2MM_ID_WIDTH-1 downto 0);    --
         -- AXI Address Channel ID output                                                --
                                                                                         --
      m_axi_s2mm_awaddr     : out std_logic_vector(C_M_AXI_S2MM_ADDR_WIDTH-1 downto 0);  --
         -- AXI Address Channel Address output                                           --
                                                                                         --
      m_axi_s2mm_awlen      : out std_logic_vector(7 downto 0);                          --
         -- AXI Address Channel LEN output                                               --
         -- Sized to support 256 data beat bursts                                        --
                                                                                         --
      m_axi_s2mm_awsize     : out std_logic_vector(2 downto 0);                          --
         -- AXI Address Channel SIZE output                                              --
                                                                                         --
      m_axi_s2mm_awburst    : out std_logic_vector(1 downto 0);                          --
         -- AXI Address Channel BURST output                                             --
                                                                                         --
      m_axi_s2mm_awprot     : out std_logic_vector(2 downto 0);                          --
         -- AXI Address Channel PROT output                                              --
                                                                                         --
      m_axi_s2mm_awcache    : out std_logic_vector(3 downto 0);                          --
         -- AXI Address Channel CACHE output                                             --

      m_axi_s2mm_awuser    : out std_logic_vector(3 downto 0);                          --
         -- AXI Address Channel USER output                                             --
                                                                                         --
      m_axi_s2mm_awvalid    : out std_logic;                                             --
         -- AXI Address Channel VALID output                                             --
                                                                                         --
      m_axi_s2mm_awready    : in  std_logic;                                             --
         -- AXI Address Channel READY input                                              --
      -------------------------------------------------------------------------------------   
      
        
      -- Currently unsupported AXI Address Channel output signals -------
        -- m_axi_s2mm__awlock   : out std_logic_vector(2 downto 0);    --
        -- m_axi_s2mm__awcache  : out std_logic_vector(4 downto 0);    --
        -- m_axi_s2mm__awqos    : out std_logic_vector(3 downto 0);    --
        -- m_axi_s2mm__awregion : out std_logic_vector(3 downto 0);    --
      -------------------------------------------------------------------
  
  
  
  
      
      -- S2MM AXI MMap Write Data Channel I/O  --------------------------------------------------
      m_axi_s2mm_wdata        : Out  std_logic_vector(C_M_AXI_S2MM_DATA_WIDTH-1 downto 0);     --
      m_axi_s2mm_wstrb        : Out  std_logic_vector((C_M_AXI_S2MM_DATA_WIDTH/8)-1 downto 0); --
      m_axi_s2mm_wlast        : Out  std_logic;                                                --
      m_axi_s2mm_wvalid       : Out  std_logic;                                                --
      m_axi_s2mm_wready       : In   std_logic;                                                --
      -------------------------------------------------------------------------------------------
      
      
      -- S2MM AXI MMap Write response Channel I/O  -------------------------
      m_axi_s2mm_bresp        : In   std_logic_vector(1 downto 0);        --
      m_axi_s2mm_bvalid       : In   std_logic;                           --
      m_axi_s2mm_bready       : Out  std_logic;                           --
      ----------------------------------------------------------------------
                                                                          
                                                                          
      -- S2MM AXI Slave Stream Channel I/O  -------------------------------------------------------
      s_axis_s2mm_tdata       : In  std_logic_vector(C_S_AXIS_S2MM_TDATA_WIDTH-1 downto 0);      --
      s_axis_s2mm_tkeep       : In  std_logic_vector((C_S_AXIS_S2MM_TDATA_WIDTH/8)-1 downto 0);  --
      s_axis_s2mm_tlast       : In  std_logic;                                                   --
      s_axis_s2mm_tvalid      : In  std_logic;                                                   --
      s_axis_s2mm_tready      : Out std_logic;                                                   --
      ---------------------------------------------------------------------------------------------
      
      -- Testing Support I/O  ------------------------------------------------
      s2mm_dbg_sel            : in  std_logic_vector( 3 downto 0);          --
      s2mm_dbg_data           : out std_logic_vector(31 downto 0)           --
      ------------------------------------------------------------------------
      
 
    );

end entity axi_datamover;


architecture implementation of axi_datamover is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";


 
   
   -- Function Declarations 
   
   -------------------------------------------------------------------
   -- Function
   --
   -- Function Name: funct_clip_brst_len
   --
   -- Function Description:
   -- This function is used to limit the parameterized max burst 
   -- databeats when the tranfer data width is 256 bits or greater.
   -- This is required to keep from crossing the 4K byte xfer
   -- boundary required by AXI. This process is further complicated
   -- by the inclusion/omission of upsizers or downsizers in the 
   -- data path.
   --
   -------------------------------------------------------------------
   function funct_clip_brst_len (param_burst_beats         : integer;
                                 mmap_transfer_bit_width   : integer;
                                 stream_transfer_bit_width : integer;
                                 down_up_sizers_enabled    : integer) return integer is
   
     constant FCONST_SIZERS_ENABLED : boolean := (down_up_sizers_enabled > 0);
     Variable fvar_max_burst_dbeats : Integer;
     
     
     
   begin
      
      
      if (FCONST_SIZERS_ENABLED) then -- use MMap dwidth for calc
      
        If (mmap_transfer_bit_width <= 128) Then -- allowed
      
          fvar_max_burst_dbeats := param_burst_beats;
        
        Elsif (mmap_transfer_bit_width <= 256) Then
        
           If (param_burst_beats <= 128) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 128;
           
           End if;
        
        Elsif (mmap_transfer_bit_width <= 512) Then
        
           If (param_burst_beats <= 64) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 64;
           
           End if;
        
        Else -- 1024 bit mmap width case
        
           If (param_burst_beats <= 32) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 32;
           
           End if;
        
        
        End if;
      
      else                            -- use stream dwidth for calc
      
        If (stream_transfer_bit_width <= 128) Then -- allowed
      
          fvar_max_burst_dbeats := param_burst_beats;
        
        Elsif (stream_transfer_bit_width <= 256) Then
        
           If (param_burst_beats <= 128) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 128;
           
           End if;
        
        Elsif (stream_transfer_bit_width <= 512) Then
        
           If (param_burst_beats <= 64) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 64;
           
           End if;
        
        Else -- 1024 bit stream width case
        
           If (param_burst_beats <= 32) Then
    
             fvar_max_burst_dbeats := param_burst_beats;
           
           Else 
           
             fvar_max_burst_dbeats := 32;
           
           End if;
        
        
        End if;
      
      end if;
      
      
      
      Return (fvar_max_burst_dbeats);
        
        
   end function funct_clip_brst_len;
   
   
   
    
   -------------------------------------------------------------------
   -- Function
   --
   -- Function Name: funct_fix_depth_16
   --
   -- Function Description:
   -- This function is used to fix the Command and Status FIFO depths to
   -- 16 entries when Async clocking mode is enabled. This is required
   -- due to the way the async_fifo_fg.vhd design in proc_common is 
   -- implemented.
   -------------------------------------------------------------------
   function funct_fix_depth_16 (async_clocking_mode : integer;
                                requested_depth     : integer) return integer is
   
     Variable fvar_depth_2_use : Integer;
   
   begin
        
      If (async_clocking_mode = 1) Then -- async mode so fix at 16
      
        fvar_depth_2_use := 16;
      
      Elsif (requested_depth > 16) Then -- limit at 16
      
        fvar_depth_2_use := 16;
      
      Else -- use requested depth
        
        fvar_depth_2_use := requested_depth;
      
      End if;
      
      Return (fvar_depth_2_use);
        
        
   end function funct_fix_depth_16;
   
   
   
    
   -------------------------------------------------------------------
   -- Function
   --
   -- Function Name: funct_get_min_btt_width
   --
   -- Function Description:
   --   This function calculates the minimum required value  
   -- for the used width of the command BTT field. 
   --
   -------------------------------------------------------------------
   function funct_get_min_btt_width (max_burst_beats : integer;
                                     bytes_per_beat  : integer ) return integer is
   
     Variable var_min_btt_needed      : Integer;
     Variable var_max_bytes_per_burst : Integer;
   
   
   begin
   
     var_max_bytes_per_burst := max_burst_beats*bytes_per_beat;
     
     
     if (var_max_bytes_per_burst <= 16) then
     
        var_min_btt_needed := 5;
     
     elsif (var_max_bytes_per_burst <= 32) then
     
        var_min_btt_needed := 6;
     
     elsif (var_max_bytes_per_burst <= 64) then
     
        var_min_btt_needed := 7;
     
     elsif (var_max_bytes_per_burst <= 128) then
     
        var_min_btt_needed := 8;
     
     elsif (var_max_bytes_per_burst <= 256) then
     
        var_min_btt_needed := 9;
     
     elsif (var_max_bytes_per_burst <= 512) then
     
        var_min_btt_needed := 10;
     
     elsif (var_max_bytes_per_burst <= 1024) then
     
        var_min_btt_needed := 11;
     
     elsif (var_max_bytes_per_burst <= 2048) then
     
        var_min_btt_needed := 12;
     
     elsif (var_max_bytes_per_burst <= 4096) then
     
        var_min_btt_needed := 13;
     
     else   -- 8K byte range
     
        var_min_btt_needed := 14;
          
     end if;
     
     
     
     Return (var_min_btt_needed);
   
     
   end function funct_get_min_btt_width;
   
   
   -------------------------------------------------------------------
   -- Function
   --
   -- Function Name: funct_get_xfer_bytes_per_dbeat
   --
   -- Function Description:
   --  Calculates the nuber of bytes that will transfered per databeat
   -- on the AXI4 MMap Bus.
   --
   -------------------------------------------------------------------
   function funct_get_xfer_bytes_per_dbeat (mmap_transfer_bit_width   : integer;
                                            stream_transfer_bit_width : integer;
                                            down_up_sizers_enabled    : integer) return integer is
     
     Variable temp_bytes_per_dbeat : Integer := 4;
   
   begin
   
     if (down_up_sizers_enabled > 0) then  -- down/up sizers are in use, use full mmap dwidth
     
        temp_bytes_per_dbeat := mmap_transfer_bit_width/8;
     
     else                                  -- No down/up sizers so use Stream data width
     
        temp_bytes_per_dbeat := stream_transfer_bit_width/8;
     
     end if;
     
   
     Return (temp_bytes_per_dbeat);
   
   
   
   end function funct_get_xfer_bytes_per_dbeat;
   
   
   -------------------------------------------------------------------
   -- Function
   --
   -- Function Name: funct_fix_btt_used
   --
   -- Function Description:
   --  THis function makes sure the BTT width used is at least the
   -- minimum needed.
   --
   -------------------------------------------------------------------
   function funct_fix_btt_used (requested_btt_width : integer;
                                min_btt_width       : integer) return integer is
   
     Variable var_corrected_btt_width : Integer;
   
   begin
   
     
     If (requested_btt_width < min_btt_width) Then
         
       var_corrected_btt_width :=  min_btt_width;
     
     else
         
       var_corrected_btt_width :=  requested_btt_width;
     
     End if;
     
     
     Return (var_corrected_btt_width);
   
     
   end function funct_fix_btt_used;
   
   -------------------------------------------------------------------
   -- Constant Declarations 
   -------------------------------------------------------------------
    
   Constant MM2S_TAG_WIDTH         : integer := 4;
   Constant S2MM_TAG_WIDTH         : integer := 4;
   
   Constant MM2S_DOWNSIZER_ENABLED : integer := C_MM2S_INCLUDE_SF;
   Constant S2MM_UPSIZER_ENABLED   : integer := C_S2MM_INCLUDE_SF + C_S2MM_SUPPORT_INDET_BTT;
   
   
   
   Constant MM2S_MAX_BURST_BEATS    : integer   := funct_clip_brst_len(C_MM2S_BURST_SIZE,
                                                                       C_M_AXI_MM2S_DATA_WIDTH,
                                                                       C_M_AXIS_MM2S_TDATA_WIDTH,
                                                                       MM2S_DOWNSIZER_ENABLED);
   
   Constant S2MM_MAX_BURST_BEATS    : integer   := funct_clip_brst_len(C_S2MM_BURST_SIZE,
                                                                       C_M_AXI_S2MM_DATA_WIDTH,
                                                                       C_S_AXIS_S2MM_TDATA_WIDTH,
                                                                       S2MM_UPSIZER_ENABLED);
   
   
   Constant MM2S_CMDSTS_FIFO_DEPTH  : integer := funct_fix_depth_16(C_MM2S_STSCMD_IS_ASYNC,
                                                                    C_MM2S_STSCMD_FIFO_DEPTH);
   
   Constant S2MM_CMDSTS_FIFO_DEPTH  : integer := funct_fix_depth_16(C_S2MM_STSCMD_IS_ASYNC,
                                                                    C_S2MM_STSCMD_FIFO_DEPTH);
   
 
   
   
   Constant MM2S_BYTES_PER_BEAT     : integer := funct_get_xfer_bytes_per_dbeat(C_M_AXI_MM2S_DATA_WIDTH,
                                                                                C_M_AXIS_MM2S_TDATA_WIDTH,
                                                                                MM2S_DOWNSIZER_ENABLED);
   
   Constant MM2S_MIN_BTT_NEEDED     : integer := funct_get_min_btt_width(MM2S_MAX_BURST_BEATS,
                                                                         MM2S_BYTES_PER_BEAT);
   
   Constant MM2S_CORRECTED_BTT_USED : integer := funct_fix_btt_used(C_MM2S_BTT_USED,
                                                                    MM2S_MIN_BTT_NEEDED);
   
   
   Constant S2MM_BYTES_PER_BEAT     : integer := funct_get_xfer_bytes_per_dbeat(C_M_AXI_S2MM_DATA_WIDTH,
                                                                                C_S_AXIS_S2MM_TDATA_WIDTH,
                                                                                S2MM_UPSIZER_ENABLED);
   
   Constant S2MM_MIN_BTT_NEEDED     : integer := funct_get_min_btt_width(S2MM_MAX_BURST_BEATS,
                                                                         S2MM_BYTES_PER_BEAT);
   
   Constant S2MM_CORRECTED_BTT_USED : integer := funct_fix_btt_used(C_S2MM_BTT_USED,
                                                                    S2MM_MIN_BTT_NEEDED);
 
 
  -- Signals
   signal sig_mm2s_tstrb     : std_logic_vector((C_M_AXIS_MM2S_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
   signal sig_mm2s_sts_tstrb : std_logic_vector(0 downto 0) := (others => '0');
   signal sig_s2mm_tstrb     : std_logic_vector((C_S_AXIS_S2MM_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
   signal sig_s2mm_sts_tstrb : std_logic_vector((((C_S2MM_SUPPORT_INDET_BTT*24)+8)/8)-1 downto 0) := (others => '0');
 
 
 

begin --(architecture implementation)


  
  
  -------------------------------------------------------------
  -- Conversion to tkeep for external stream connnections
  -------------------------------------------------------------
  
  -- MM2S Status Stream Output    
  m_axis_mm2s_sts_tkeep <= sig_mm2s_sts_tstrb ;
  
  
GEN_MM2S_TKEEP_ENABLE1 : if C_ENABLE_MM2S_TKEEP = 1 generate
begin

  
  -- MM2S Stream Output
  m_axis_mm2s_tkeep     <= sig_mm2s_tstrb     ;
 

end generate GEN_MM2S_TKEEP_ENABLE1;

GEN_MM2S_TKEEP_DISABLE1 : if C_ENABLE_MM2S_TKEEP = 0 generate
begin

  m_axis_mm2s_tkeep        <= (others => '1');

end generate GEN_MM2S_TKEEP_DISABLE1;


 
GEN_S2MM_TKEEP_ENABLE1 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin

  -- S2MM Stream Input
  sig_s2mm_tstrb        <= s_axis_s2mm_tkeep  ;


end generate GEN_S2MM_TKEEP_ENABLE1;

GEN_S2MM_TKEEP_DISABLE1 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin

  sig_s2mm_tstrb        <= (others => '1');

end generate GEN_S2MM_TKEEP_DISABLE1;

  
  -- S2MM Status Stream Output    
  m_axis_s2mm_sts_tkeep <= sig_s2mm_sts_tstrb ;
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_MM2S_OMIT
  --
  -- If Generate Description:
  --  Instantiate the MM2S OMIT Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_MM2S_OMIT : if (C_INCLUDE_MM2S = 0) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_MM2S_OMIT_WRAPPER 
       --
       -- Description:
       -- Read omit Wrapper Instance    
       --
       ------------------------------------------------------------
        I_MM2S_OMIT_WRAPPER : entity axi_datamover_v5_1.axi_datamover_mm2s_omit_wrap
        generic map (
      
          C_INCLUDE_MM2S           =>  C_INCLUDE_MM2S             ,
          C_MM2S_ARID              =>  C_M_AXI_MM2S_ARID          ,   
          C_MM2S_ID_WIDTH          =>  C_M_AXI_MM2S_ID_WIDTH      ,
          C_MM2S_ADDR_WIDTH        =>  C_M_AXI_MM2S_ADDR_WIDTH    ,  
          C_MM2S_MDATA_WIDTH       =>  C_M_AXI_MM2S_DATA_WIDTH    ,  
          C_MM2S_SDATA_WIDTH       =>  C_M_AXIS_MM2S_TDATA_WIDTH  ,  
          C_INCLUDE_MM2S_STSFIFO   =>  C_INCLUDE_MM2S_STSFIFO     ,
          C_MM2S_STSCMD_FIFO_DEPTH =>  MM2S_CMDSTS_FIFO_DEPTH     ,
          C_MM2S_STSCMD_IS_ASYNC   =>  C_MM2S_STSCMD_IS_ASYNC     ,
          C_INCLUDE_MM2S_DRE       =>  C_INCLUDE_MM2S_DRE         ,
          C_MM2S_BURST_SIZE        =>  MM2S_MAX_BURST_BEATS       ,
          C_MM2S_BTT_USED          =>  MM2S_CORRECTED_BTT_USED    ,
          C_MM2S_ADDR_PIPE_DEPTH   =>  C_MM2S_ADDR_PIPE_DEPTH     ,
          C_TAG_WIDTH              =>  MM2S_TAG_WIDTH             ,
          C_ENABLE_CACHE_USER          =>  C_ENABLE_CACHE_USER            ,
          C_FAMILY                 =>  C_FAMILY
          )
        port map (
      
          mm2s_aclk                =>  m_axi_mm2s_aclk            ,  
          mm2s_aresetn             =>  m_axi_mm2s_aresetn         ,  
          mm2s_halt                =>  mm2s_halt                  ,
          mm2s_halt_cmplt          =>  mm2s_halt_cmplt            ,
          mm2s_err                 =>  mm2s_err                   ,  
          mm2s_cmdsts_awclk        =>  m_axis_mm2s_cmdsts_aclk    ,  
          mm2s_cmdsts_aresetn      =>  m_axis_mm2s_cmdsts_aresetn ,  
                                   
          mm2s_cmd_wvalid          =>  s_axis_mm2s_cmd_tvalid     ,  
          mm2s_cmd_wready          =>  s_axis_mm2s_cmd_tready     ,  
          mm2s_cmd_wdata           =>  s_axis_mm2s_cmd_tdata      ,  
                                                  
          mm2s_sts_wvalid          =>  m_axis_mm2s_sts_tvalid     ,  
          mm2s_sts_wready          =>  m_axis_mm2s_sts_tready     ,  
          mm2s_sts_wdata           =>  m_axis_mm2s_sts_tdata      ,  
          mm2s_sts_wstrb           =>  sig_mm2s_sts_tstrb         ,  
          mm2s_sts_wlast           =>  m_axis_mm2s_sts_tlast      ,  
                                                  
          mm2s_allow_addr_req      =>  mm2s_allow_addr_req        ,   
          mm2s_addr_req_posted     =>  mm2s_addr_req_posted       ,
          mm2s_rd_xfer_cmplt       =>  mm2s_rd_xfer_cmplt         ,
          
          mm2s_arid                =>  m_axi_mm2s_arid            ,  
          mm2s_araddr              =>  m_axi_mm2s_araddr          ,  
          mm2s_arlen               =>  m_axi_mm2s_arlen           ,  
          mm2s_arsize              =>  m_axi_mm2s_arsize          ,  
          mm2s_arburst             =>  m_axi_mm2s_arburst         ,  
          mm2s_arprot              =>  m_axi_mm2s_arprot          ,
          mm2s_arcache             =>  m_axi_mm2s_arcache         ,
          mm2s_aruser              =>  m_axi_mm2s_aruser          ,
          mm2s_arvalid             =>  m_axi_mm2s_arvalid         ,  
          mm2s_arready             =>  m_axi_mm2s_arready         ,  
                                                  
          mm2s_rdata               =>  m_axi_mm2s_rdata           ,  
          mm2s_rresp               =>  m_axi_mm2s_rresp           ,  
          mm2s_rlast               =>  m_axi_mm2s_rlast           ,  
          mm2s_rvalid              =>  m_axi_mm2s_rvalid          ,  
          mm2s_rready              =>  m_axi_mm2s_rready          ,  
                                                  
          mm2s_strm_wdata          =>  m_axis_mm2s_tdata          ,  
          mm2s_strm_wstrb          =>  sig_mm2s_tstrb             ,  
          mm2s_strm_wlast          =>  m_axis_mm2s_tlast          ,  
          mm2s_strm_wvalid         =>  m_axis_mm2s_tvalid         ,  
          mm2s_strm_wready         =>  m_axis_mm2s_tready         ,   
     
          mm2s_dbg_sel             =>  mm2s_dbg_sel               ,
          mm2s_dbg_data            =>  mm2s_dbg_data 
          );
      
 
  
  
     end generate GEN_MM2S_OMIT;



  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_MM2S_FULL
  --
  -- If Generate Description:
  --  Instantiate the MM2S Full Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_MM2S_FULL : if (C_INCLUDE_MM2S = 1) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_MM2S_FULL_WRAPPER 
       --
       -- Description:
       -- Read Full Wrapper Instance    
       --
       ------------------------------------------------------------
        I_MM2S_FULL_WRAPPER : entity axi_datamover_v5_1.axi_datamover_mm2s_full_wrap
        generic map (
      
          C_INCLUDE_MM2S           =>  C_INCLUDE_MM2S             ,
          C_MM2S_ARID              =>  C_M_AXI_MM2S_ARID          ,   
          C_MM2S_ID_WIDTH          =>  C_M_AXI_MM2S_ID_WIDTH      ,
          C_MM2S_ADDR_WIDTH        =>  C_M_AXI_MM2S_ADDR_WIDTH    ,  
          C_MM2S_MDATA_WIDTH       =>  C_M_AXI_MM2S_DATA_WIDTH    ,  
          C_MM2S_SDATA_WIDTH       =>  C_M_AXIS_MM2S_TDATA_WIDTH  ,  
          C_INCLUDE_MM2S_STSFIFO   =>  C_INCLUDE_MM2S_STSFIFO     ,
          C_MM2S_STSCMD_FIFO_DEPTH =>  MM2S_CMDSTS_FIFO_DEPTH     ,
          C_MM2S_STSCMD_IS_ASYNC   =>  C_MM2S_STSCMD_IS_ASYNC     ,
          C_INCLUDE_MM2S_DRE       =>  C_INCLUDE_MM2S_DRE         ,
          C_MM2S_BURST_SIZE        =>  MM2S_MAX_BURST_BEATS       ,
          C_MM2S_BTT_USED          =>  MM2S_CORRECTED_BTT_USED    ,
          C_MM2S_ADDR_PIPE_DEPTH   =>  C_MM2S_ADDR_PIPE_DEPTH     ,
          C_TAG_WIDTH              =>  MM2S_TAG_WIDTH             ,
          C_INCLUDE_MM2S_GP_SF     =>  C_MM2S_INCLUDE_SF          ,
          C_ENABLE_CACHE_USER   =>  C_ENABLE_CACHE_USER     ,
          C_ENABLE_MM2S_TKEEP       =>  C_ENABLE_MM2S_TKEEP        ,
          C_ENABLE_SKID_BUF        =>  C_ENABLE_SKID_BUF           ,
          C_FAMILY                 =>  C_FAMILY
          )
        port map (
      
          mm2s_aclk                =>  m_axi_mm2s_aclk            ,  
          mm2s_aresetn             =>  m_axi_mm2s_aresetn         ,  
          mm2s_halt                =>  mm2s_halt                  ,
          mm2s_halt_cmplt          =>  mm2s_halt_cmplt            ,
          mm2s_err                 =>  mm2s_err                   ,  
          mm2s_cmdsts_awclk        =>  m_axis_mm2s_cmdsts_aclk    ,  
          mm2s_cmdsts_aresetn      =>  m_axis_mm2s_cmdsts_aresetn ,  
                                   
          mm2s_cmd_wvalid          =>  s_axis_mm2s_cmd_tvalid     ,  
          mm2s_cmd_wready          =>  s_axis_mm2s_cmd_tready     ,  
          mm2s_cmd_wdata           =>  s_axis_mm2s_cmd_tdata      ,  
                                                  
          mm2s_sts_wvalid          =>  m_axis_mm2s_sts_tvalid     ,  
          mm2s_sts_wready          =>  m_axis_mm2s_sts_tready     ,  
          mm2s_sts_wdata           =>  m_axis_mm2s_sts_tdata      ,  
          mm2s_sts_wstrb           =>  sig_mm2s_sts_tstrb         ,  
          mm2s_sts_wlast           =>  m_axis_mm2s_sts_tlast      ,  
                                                  
          mm2s_allow_addr_req      =>  mm2s_allow_addr_req        ,   
          mm2s_addr_req_posted     =>  mm2s_addr_req_posted       ,
          mm2s_rd_xfer_cmplt       =>  mm2s_rd_xfer_cmplt         ,
          
          mm2s_arid                =>  m_axi_mm2s_arid            ,  
          mm2s_araddr              =>  m_axi_mm2s_araddr          ,  
          mm2s_arlen               =>  m_axi_mm2s_arlen           ,  
          mm2s_arsize              =>  m_axi_mm2s_arsize          ,  
          mm2s_arburst             =>  m_axi_mm2s_arburst         ,  
          mm2s_arprot              =>  m_axi_mm2s_arprot          ,  
          mm2s_arcache             =>  m_axi_mm2s_arcache         ,
          mm2s_aruser              =>  m_axi_mm2s_aruser          ,
          mm2s_arvalid             =>  m_axi_mm2s_arvalid         ,  
          mm2s_arready             =>  m_axi_mm2s_arready         ,  
                                                  
          mm2s_rdata               =>  m_axi_mm2s_rdata           ,  
          mm2s_rresp               =>  m_axi_mm2s_rresp           ,  
          mm2s_rlast               =>  m_axi_mm2s_rlast           ,  
          mm2s_rvalid              =>  m_axi_mm2s_rvalid          ,  
          mm2s_rready              =>  m_axi_mm2s_rready          ,  
                                                  
          mm2s_strm_wdata          =>  m_axis_mm2s_tdata          ,  
          mm2s_strm_wstrb          =>  sig_mm2s_tstrb             ,  
          mm2s_strm_wlast          =>  m_axis_mm2s_tlast          ,  
          mm2s_strm_wvalid         =>  m_axis_mm2s_tvalid         ,  
          mm2s_strm_wready         =>  m_axis_mm2s_tready         ,   
     
          mm2s_dbg_sel             =>  mm2s_dbg_sel               ,
          mm2s_dbg_data            =>  mm2s_dbg_data 
          );
      
 
  
  
     end generate GEN_MM2S_FULL;



  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_MM2S_BASIC
  --
  -- If Generate Description:
  --  Instantiate the MM2S Basic Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_MM2S_BASIC : if (C_INCLUDE_MM2S = 2) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_MM2S_BASIC_WRAPPER 
       --
       -- Description:
       -- Read Basic Wrapper Instance    
       --
       ------------------------------------------------------------
        I_MM2S_BASIC_WRAPPER : entity axi_datamover_v5_1.axi_datamover_mm2s_basic_wrap
        generic map (
      
          C_INCLUDE_MM2S           =>  C_INCLUDE_MM2S             ,
          C_MM2S_ARID              =>  C_M_AXI_MM2S_ARID          ,   
          C_MM2S_ID_WIDTH          =>  C_M_AXI_MM2S_ID_WIDTH      ,
          C_MM2S_ADDR_WIDTH        =>  C_M_AXI_MM2S_ADDR_WIDTH    ,  
          C_MM2S_MDATA_WIDTH       =>  C_M_AXI_MM2S_DATA_WIDTH    ,  
          C_MM2S_SDATA_WIDTH       =>  C_M_AXIS_MM2S_TDATA_WIDTH  ,  
          C_INCLUDE_MM2S_STSFIFO   =>  C_INCLUDE_MM2S_STSFIFO     ,
          C_MM2S_STSCMD_FIFO_DEPTH =>  MM2S_CMDSTS_FIFO_DEPTH     ,
          C_MM2S_STSCMD_IS_ASYNC   =>  C_MM2S_STSCMD_IS_ASYNC     ,
          C_INCLUDE_MM2S_DRE       =>  C_INCLUDE_MM2S_DRE         ,
          C_MM2S_BURST_SIZE        =>  MM2S_MAX_BURST_BEATS       ,
          C_MM2S_BTT_USED          =>  MM2S_CORRECTED_BTT_USED    ,
          C_MM2S_ADDR_PIPE_DEPTH   =>  C_MM2S_ADDR_PIPE_DEPTH     ,
          C_TAG_WIDTH              =>  MM2S_TAG_WIDTH             ,
          C_ENABLE_CACHE_USER      =>  C_ENABLE_CACHE_USER        ,
          C_ENABLE_SKID_BUF        =>  C_ENABLE_SKID_BUF          ,
          C_MICRO_DMA              =>  C_MICRO_DMA                ,
          C_FAMILY                 =>  C_FAMILY
          )
        port map (
      
          mm2s_aclk                =>  m_axi_mm2s_aclk            ,  
          mm2s_aresetn             =>  m_axi_mm2s_aresetn         ,  
 
          mm2s_halt                =>  mm2s_halt                  ,
          mm2s_halt_cmplt          =>  mm2s_halt_cmplt            ,          
          mm2s_err                 =>  mm2s_err                   ,  
          mm2s_cmdsts_awclk        =>  m_axis_mm2s_cmdsts_aclk    ,  
          mm2s_cmdsts_aresetn      =>  m_axis_mm2s_cmdsts_aresetn ,  
                                   
          mm2s_cmd_wvalid          =>  s_axis_mm2s_cmd_tvalid     ,  
          mm2s_cmd_wready          =>  s_axis_mm2s_cmd_tready     ,  
          mm2s_cmd_wdata           =>  s_axis_mm2s_cmd_tdata      ,  
                                                  
          mm2s_sts_wvalid          =>  m_axis_mm2s_sts_tvalid     ,  
          mm2s_sts_wready          =>  m_axis_mm2s_sts_tready     ,  
          mm2s_sts_wdata           =>  m_axis_mm2s_sts_tdata      ,  
          mm2s_sts_wstrb           =>  sig_mm2s_sts_tstrb         ,  
          mm2s_sts_wlast           =>  m_axis_mm2s_sts_tlast      ,  
                                                  
          mm2s_allow_addr_req      =>  mm2s_allow_addr_req        ,   
          mm2s_addr_req_posted     =>  mm2s_addr_req_posted       ,
          mm2s_rd_xfer_cmplt       =>  mm2s_rd_xfer_cmplt         ,
          
          mm2s_arid                =>  m_axi_mm2s_arid            ,  
          mm2s_araddr              =>  m_axi_mm2s_araddr          ,  
          mm2s_arlen               =>  m_axi_mm2s_arlen           ,  
          mm2s_arsize              =>  m_axi_mm2s_arsize          ,  
          mm2s_arburst             =>  m_axi_mm2s_arburst         ,  
          mm2s_arprot              =>  m_axi_mm2s_arprot          ,  
          mm2s_arcache             =>  m_axi_mm2s_arcache         ,
          mm2s_aruser              =>  m_axi_mm2s_aruser          ,
          mm2s_arvalid             =>  m_axi_mm2s_arvalid         ,  
          mm2s_arready             =>  m_axi_mm2s_arready         ,  
                                                  
          mm2s_rdata               =>  m_axi_mm2s_rdata           ,  
          mm2s_rresp               =>  m_axi_mm2s_rresp           ,  
          mm2s_rlast               =>  m_axi_mm2s_rlast           ,  
          mm2s_rvalid              =>  m_axi_mm2s_rvalid          ,  
          mm2s_rready              =>  m_axi_mm2s_rready          ,  
                                                  
          mm2s_strm_wdata          =>  m_axis_mm2s_tdata          ,  
          mm2s_strm_wstrb          =>  sig_mm2s_tstrb             ,  
          mm2s_strm_wlast          =>  m_axis_mm2s_tlast          ,  
          mm2s_strm_wvalid         =>  m_axis_mm2s_tvalid         ,  
          mm2s_strm_wready         =>  m_axis_mm2s_tready         ,   
     
          mm2s_dbg_sel             =>  mm2s_dbg_sel               ,
          mm2s_dbg_data            =>  mm2s_dbg_data 
          );
      
 
  
  
     end generate GEN_MM2S_BASIC;


  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_S2MM_OMIT
  --
  -- If Generate Description:
  --  Instantiate the S2MM OMIT Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_S2MM_OMIT : if (C_INCLUDE_S2MM = 0) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_S2MM_OMIT_WRAPPER 
       --
       -- Description:
       -- Write Omit Wrapper Instance    
       --
       ------------------------------------------------------------
        I_S2MM_OMIT_WRAPPER : entity axi_datamover_v5_1.axi_datamover_s2mm_omit_wrap
        generic map (
      
          C_INCLUDE_S2MM            =>  C_INCLUDE_S2MM           ,
          C_S2MM_AWID               =>  C_M_AXI_S2MM_AWID        ,
          C_S2MM_ID_WIDTH           =>  C_M_AXI_S2MM_ID_WIDTH    ,
          C_S2MM_ADDR_WIDTH         =>  C_M_AXI_S2MM_ADDR_WIDTH  ,  
          C_S2MM_MDATA_WIDTH        =>  C_M_AXI_S2MM_DATA_WIDTH  ,  
          C_S2MM_SDATA_WIDTH        =>  C_S_AXIS_S2MM_TDATA_WIDTH , 
          C_INCLUDE_S2MM_STSFIFO    =>  C_INCLUDE_S2MM_STSFIFO   ,
          C_S2MM_STSCMD_FIFO_DEPTH  =>  S2MM_CMDSTS_FIFO_DEPTH   ,
          C_S2MM_STSCMD_IS_ASYNC    =>  C_S2MM_STSCMD_IS_ASYNC   ,
          C_INCLUDE_S2MM_DRE        =>  C_INCLUDE_S2MM_DRE       ,
          C_S2MM_BURST_SIZE         =>  S2MM_MAX_BURST_BEATS     ,
          C_S2MM_SUPPORT_INDET_BTT  =>  C_S2MM_SUPPORT_INDET_BTT ,        
          C_S2MM_ADDR_PIPE_DEPTH    =>  C_S2MM_ADDR_PIPE_DEPTH   ,
          C_TAG_WIDTH               =>  S2MM_TAG_WIDTH           ,
          C_ENABLE_CACHE_USER          =>  C_ENABLE_CACHE_USER            ,
          C_FAMILY                  =>  C_FAMILY
                  
          )
        port map (
      
          s2mm_aclk            =>  m_axi_s2mm_aclk               , 
          s2mm_aresetn         =>  m_axi_s2mm_aresetn            , 
          s2mm_halt            =>  s2mm_halt                     ,
          s2mm_halt_cmplt      =>  s2mm_halt_cmplt               ,
          s2mm_err             =>  s2mm_err                      , 
          s2mm_cmdsts_awclk    =>  m_axis_s2mm_cmdsts_awclk      , 
          s2mm_cmdsts_aresetn  =>  m_axis_s2mm_cmdsts_aresetn    , 
                                                             
          s2mm_cmd_wvalid      =>  s_axis_s2mm_cmd_tvalid        , 
          s2mm_cmd_wready      =>  s_axis_s2mm_cmd_tready        , 
          s2mm_cmd_wdata       =>  s_axis_s2mm_cmd_tdata         , 
                                              
          s2mm_sts_wvalid      =>  m_axis_s2mm_sts_tvalid        , 
          s2mm_sts_wready      =>  m_axis_s2mm_sts_tready        , 
          s2mm_sts_wdata       =>  m_axis_s2mm_sts_tdata         , 
          s2mm_sts_wstrb       =>  sig_s2mm_sts_tstrb            , 
          s2mm_sts_wlast       =>  m_axis_s2mm_sts_tlast         , 
       
          s2mm_allow_addr_req  =>  s2mm_allow_addr_req           ,
          s2mm_addr_req_posted =>  s2mm_addr_req_posted          ,
          s2mm_wr_xfer_cmplt   =>  s2mm_wr_xfer_cmplt            ,
          s2mm_ld_nxt_len      =>  s2mm_ld_nxt_len               ,
          s2mm_wr_len          =>  s2mm_wr_len                   ,
          
                                              
          s2mm_awid            =>  m_axi_s2mm_awid               , 
          s2mm_awaddr          =>  m_axi_s2mm_awaddr             , 
          s2mm_awlen           =>  m_axi_s2mm_awlen              , 
          s2mm_awsize          =>  m_axi_s2mm_awsize             , 
          s2mm_awburst         =>  m_axi_s2mm_awburst            , 
          s2mm_awprot          =>  m_axi_s2mm_awprot             , 
          s2mm_awcache         =>  m_axi_s2mm_awcache            ,
          s2mm_awuser          =>  m_axi_s2mm_awuser             ,
          s2mm_awvalid         =>  m_axi_s2mm_awvalid            , 
          s2mm_awready         =>  m_axi_s2mm_awready            , 
                                              
          s2mm_wdata           =>  m_axi_s2mm_wdata              , 
          s2mm_wstrb           =>  m_axi_s2mm_wstrb              , 
          s2mm_wlast           =>  m_axi_s2mm_wlast              , 
          s2mm_wvalid          =>  m_axi_s2mm_wvalid             , 
          s2mm_wready          =>  m_axi_s2mm_wready             , 
    
          s2mm_bresp           =>  m_axi_s2mm_bresp              , 
          s2mm_bvalid          =>  m_axi_s2mm_bvalid             , 
          s2mm_bready          =>  m_axi_s2mm_bready             , 
                                              
          s2mm_strm_wdata      =>  s_axis_s2mm_tdata             , 
          s2mm_strm_wstrb      =>  sig_s2mm_tstrb                , 
          s2mm_strm_wlast      =>  s_axis_s2mm_tlast             , 
          s2mm_strm_wvalid     =>  s_axis_s2mm_tvalid            , 
          s2mm_strm_wready     =>  s_axis_s2mm_tready            ,  
     
          s2mm_dbg_sel         =>  s2mm_dbg_sel                  ,
          s2mm_dbg_data        =>  s2mm_dbg_data 
          );
  
  
  
     end generate GEN_S2MM_OMIT;


  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_S2MM_FULL
  --
  -- If Generate Description:
  --  Instantiate the S2MM FULL Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_S2MM_FULL : if (C_INCLUDE_S2MM = 1) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_S2MM_FULL_WRAPPER 
       --
       -- Description:
       -- Write Full Wrapper Instance    
       --
       ------------------------------------------------------------
        I_S2MM_FULL_WRAPPER : entity axi_datamover_v5_1.axi_datamover_s2mm_full_wrap
        generic map (
      
          C_INCLUDE_S2MM            =>  C_INCLUDE_S2MM           ,
          C_S2MM_AWID               =>  C_M_AXI_S2MM_AWID        ,
          C_S2MM_ID_WIDTH           =>  C_M_AXI_S2MM_ID_WIDTH    ,
          C_S2MM_ADDR_WIDTH         =>  C_M_AXI_S2MM_ADDR_WIDTH  ,  
          C_S2MM_MDATA_WIDTH        =>  C_M_AXI_S2MM_DATA_WIDTH  ,  
          C_S2MM_SDATA_WIDTH        =>  C_S_AXIS_S2MM_TDATA_WIDTH , 
          C_INCLUDE_S2MM_STSFIFO    =>  C_INCLUDE_S2MM_STSFIFO   ,
          C_S2MM_STSCMD_FIFO_DEPTH  =>  S2MM_CMDSTS_FIFO_DEPTH   ,
          C_S2MM_STSCMD_IS_ASYNC    =>  C_S2MM_STSCMD_IS_ASYNC   ,
          C_INCLUDE_S2MM_DRE        =>  C_INCLUDE_S2MM_DRE       ,
          C_S2MM_BURST_SIZE         =>  S2MM_MAX_BURST_BEATS     ,
          C_S2MM_BTT_USED           =>  S2MM_CORRECTED_BTT_USED  ,
          C_S2MM_SUPPORT_INDET_BTT  =>  C_S2MM_SUPPORT_INDET_BTT ,
          C_S2MM_ADDR_PIPE_DEPTH    =>  C_S2MM_ADDR_PIPE_DEPTH   ,
          C_TAG_WIDTH               =>  S2MM_TAG_WIDTH           ,
          C_INCLUDE_S2MM_GP_SF      =>  C_S2MM_INCLUDE_SF        ,
          C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER   , 
          C_ENABLE_S2MM_TKEEP       =>  C_ENABLE_S2MM_TKEEP        ,
          C_ENABLE_SKID_BUF         =>  C_ENABLE_SKID_BUF        ,
          C_FAMILY                  =>  C_FAMILY
                  
          )
        port map (
      
          s2mm_aclk            =>  m_axi_s2mm_aclk               , 
          s2mm_aresetn         =>  m_axi_s2mm_aresetn            , 
          s2mm_halt            =>  s2mm_halt                     ,
          s2mm_halt_cmplt      =>  s2mm_halt_cmplt               ,
          s2mm_err             =>  s2mm_err                      , 
          s2mm_cmdsts_awclk    =>  m_axis_s2mm_cmdsts_awclk      , 
          s2mm_cmdsts_aresetn  =>  m_axis_s2mm_cmdsts_aresetn    , 
          
          s2mm_cmd_wvalid      =>  s_axis_s2mm_cmd_tvalid        , 
          s2mm_cmd_wready      =>  s_axis_s2mm_cmd_tready        , 
          s2mm_cmd_wdata       =>  s_axis_s2mm_cmd_tdata         , 
                                              
          s2mm_sts_wvalid      =>  m_axis_s2mm_sts_tvalid        , 
          s2mm_sts_wready      =>  m_axis_s2mm_sts_tready        , 
          s2mm_sts_wdata       =>  m_axis_s2mm_sts_tdata         , 
          s2mm_sts_wstrb       =>  sig_s2mm_sts_tstrb            , 
          s2mm_sts_wlast       =>  m_axis_s2mm_sts_tlast         , 
       
          s2mm_allow_addr_req  =>  s2mm_allow_addr_req           ,
          s2mm_addr_req_posted =>  s2mm_addr_req_posted          ,
          s2mm_wr_xfer_cmplt   =>  s2mm_wr_xfer_cmplt            ,
          s2mm_ld_nxt_len      =>  s2mm_ld_nxt_len               ,
          s2mm_wr_len          =>  s2mm_wr_len                   ,
          
          s2mm_awid            =>  m_axi_s2mm_awid               , 
          s2mm_awaddr          =>  m_axi_s2mm_awaddr             , 
          s2mm_awlen           =>  m_axi_s2mm_awlen              , 
          s2mm_awsize          =>  m_axi_s2mm_awsize             , 
          s2mm_awburst         =>  m_axi_s2mm_awburst            , 
          s2mm_awprot          =>  m_axi_s2mm_awprot             , 
          s2mm_awcache         =>  m_axi_s2mm_awcache            ,
          s2mm_awuser          =>  m_axi_s2mm_awuser             ,
          s2mm_awvalid         =>  m_axi_s2mm_awvalid            , 
          s2mm_awready         =>  m_axi_s2mm_awready            , 
                                              
          s2mm_wdata           =>  m_axi_s2mm_wdata              , 
          s2mm_wstrb           =>  m_axi_s2mm_wstrb              , 
          s2mm_wlast           =>  m_axi_s2mm_wlast              , 
          s2mm_wvalid          =>  m_axi_s2mm_wvalid             , 
          s2mm_wready          =>  m_axi_s2mm_wready             , 
    
          s2mm_bresp           =>  m_axi_s2mm_bresp              , 
          s2mm_bvalid          =>  m_axi_s2mm_bvalid             , 
          s2mm_bready          =>  m_axi_s2mm_bready             , 
    
                                              
          s2mm_strm_wdata      =>  s_axis_s2mm_tdata             , 
          s2mm_strm_wstrb      =>  sig_s2mm_tstrb                , 
          s2mm_strm_wlast      =>  s_axis_s2mm_tlast             , 
          s2mm_strm_wvalid     =>  s_axis_s2mm_tvalid            , 
          s2mm_strm_wready     =>  s_axis_s2mm_tready            ,  
     
          s2mm_dbg_sel         =>  s2mm_dbg_sel                  ,
          s2mm_dbg_data        =>  s2mm_dbg_data      
     
          );
  
  
  
     end generate GEN_S2MM_FULL;

  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_S2MM_BASIC
  --
  -- If Generate Description:
  --  Instantiate the S2MM Basic Wrapper 
  --
  --
  ------------------------------------------------------------
  GEN_S2MM_BASIC : if (C_INCLUDE_S2MM = 2) generate
  
  
     begin
  
       ------------------------------------------------------------
       -- Instance: I_S2MM_BASIC_WRAPPER 
       --
       -- Description:
       -- Write Basic Wrapper Instance    
       --
       ------------------------------------------------------------
        I_S2MM_BASIC_WRAPPER : entity axi_datamover_v5_1.axi_datamover_s2mm_basic_wrap
        generic map (
      
          C_INCLUDE_S2MM            =>  C_INCLUDE_S2MM           ,
          C_S2MM_AWID               =>  C_M_AXI_S2MM_AWID        ,
          C_S2MM_ID_WIDTH           =>  C_M_AXI_S2MM_ID_WIDTH    ,
          C_S2MM_ADDR_WIDTH         =>  C_M_AXI_S2MM_ADDR_WIDTH  ,  
          C_S2MM_MDATA_WIDTH        =>  C_M_AXI_S2MM_DATA_WIDTH  ,  
          C_S2MM_SDATA_WIDTH        =>  C_S_AXIS_S2MM_TDATA_WIDTH , 
          C_INCLUDE_S2MM_STSFIFO    =>  C_INCLUDE_S2MM_STSFIFO   ,
          C_S2MM_STSCMD_FIFO_DEPTH  =>  S2MM_CMDSTS_FIFO_DEPTH   ,
          C_S2MM_STSCMD_IS_ASYNC    =>  C_S2MM_STSCMD_IS_ASYNC   ,
          C_INCLUDE_S2MM_DRE        =>  C_INCLUDE_S2MM_DRE       ,
          C_S2MM_BURST_SIZE         =>  S2MM_MAX_BURST_BEATS     ,
          C_S2MM_ADDR_PIPE_DEPTH    =>  C_S2MM_ADDR_PIPE_DEPTH   ,
          C_TAG_WIDTH               =>  S2MM_TAG_WIDTH           ,
          C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER   ,
          C_ENABLE_SKID_BUF         =>  C_ENABLE_SKID_BUF        ,
          C_MICRO_DMA              =>  C_MICRO_DMA                ,
          C_FAMILY                  =>  C_FAMILY
                  
          )
        port map (
      
          s2mm_aclk            =>  m_axi_s2mm_aclk               , 
          s2mm_aresetn         =>  m_axi_s2mm_aresetn            , 

          s2mm_halt            =>  s2mm_halt                     ,
          s2mm_halt_cmplt      =>  s2mm_halt_cmplt               ,
          s2mm_err             =>  s2mm_err                      , 
          s2mm_cmdsts_awclk    =>  m_axis_s2mm_cmdsts_awclk      , 
          s2mm_cmdsts_aresetn  =>  m_axis_s2mm_cmdsts_aresetn    , 
          
          s2mm_cmd_wvalid      =>  s_axis_s2mm_cmd_tvalid        , 
          s2mm_cmd_wready      =>  s_axis_s2mm_cmd_tready        , 
          s2mm_cmd_wdata       =>  s_axis_s2mm_cmd_tdata         , 
                                              
          s2mm_sts_wvalid      =>  m_axis_s2mm_sts_tvalid        , 
          s2mm_sts_wready      =>  m_axis_s2mm_sts_tready        , 
          s2mm_sts_wdata       =>  m_axis_s2mm_sts_tdata         , 
          s2mm_sts_wstrb       =>  sig_s2mm_sts_tstrb            , 
          s2mm_sts_wlast       =>  m_axis_s2mm_sts_tlast         , 
       
          s2mm_allow_addr_req  =>  s2mm_allow_addr_req           ,
          s2mm_addr_req_posted =>  s2mm_addr_req_posted          ,
          s2mm_wr_xfer_cmplt   =>  s2mm_wr_xfer_cmplt            ,
          s2mm_ld_nxt_len      =>  s2mm_ld_nxt_len               ,
          s2mm_wr_len          =>  s2mm_wr_len                   ,
                                                        
          s2mm_awid            =>  m_axi_s2mm_awid               , 
          s2mm_awaddr          =>  m_axi_s2mm_awaddr             , 
          s2mm_awlen           =>  m_axi_s2mm_awlen              , 
          s2mm_awsize          =>  m_axi_s2mm_awsize             , 
          s2mm_awburst         =>  m_axi_s2mm_awburst            , 
          s2mm_awprot          =>  m_axi_s2mm_awprot             , 
          s2mm_awcache         =>  m_axi_s2mm_awcache            ,
          s2mm_awuser          =>  m_axi_s2mm_awuser             ,
          s2mm_awvalid         =>  m_axi_s2mm_awvalid            , 
          s2mm_awready         =>  m_axi_s2mm_awready            , 
                                              
          s2mm_wdata           =>  m_axi_s2mm_wdata              , 
          s2mm_wstrb           =>  m_axi_s2mm_wstrb              , 
          s2mm_wlast           =>  m_axi_s2mm_wlast              , 
          s2mm_wvalid          =>  m_axi_s2mm_wvalid             , 
          s2mm_wready          =>  m_axi_s2mm_wready             , 
    
          s2mm_bresp           =>  m_axi_s2mm_bresp              , 
          s2mm_bvalid          =>  m_axi_s2mm_bvalid             , 
          s2mm_bready          =>  m_axi_s2mm_bready             , 
    
                                              
          s2mm_strm_wdata      =>  s_axis_s2mm_tdata             , 
          s2mm_strm_wstrb      =>  sig_s2mm_tstrb                , 
          s2mm_strm_wlast      =>  s_axis_s2mm_tlast             , 
          s2mm_strm_wvalid     =>  s_axis_s2mm_tvalid            , 
          s2mm_strm_wready     =>  s_axis_s2mm_tready            ,  
     
          s2mm_dbg_sel         =>  s2mm_dbg_sel                  ,
          s2mm_dbg_data        =>  s2mm_dbg_data      
     
          );
  
  
  
     end generate GEN_S2MM_BASIC;


end implementation;
