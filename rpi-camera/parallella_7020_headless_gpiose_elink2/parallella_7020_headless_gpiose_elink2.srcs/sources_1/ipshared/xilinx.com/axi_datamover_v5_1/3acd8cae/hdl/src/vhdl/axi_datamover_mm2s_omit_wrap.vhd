  -------------------------------------------------------------------------------
  -- axi_datamover_mm2s_omit_wrap.vhd
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
  -- Filename:        axi_datamover_mm2s_omit_wrap.vhd
  --
  -- Description:     
  --    This file implements the DataMover MM2S Omit Wrapper.                 
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
  
  
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_mm2s_omit_wrap is
    generic (
      
      C_INCLUDE_MM2S     : Integer range 0 to  2 :=  0;
         -- Specifies the type of MM2S function to include
         -- 0 = Omit MM2S functionality
         -- 1 = Full MM2S Functionality
         -- 2 = Lite MM2S functionality
         
      C_MM2S_ARID        : Integer range 0 to 255 :=  8;
         -- Specifies the constant value to output on 
         -- the ARID output port
         
      C_MM2S_ID_WIDTH    : Integer range 1 to  8 :=  4;
         -- Specifies the width of the MM2S ID port 
         
      C_MM2S_ADDR_WIDTH  : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel 
         -- Address bus
         
      C_MM2S_MDATA_WIDTH : Integer range 32 to 1024 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus
      
      C_MM2S_SDATA_WIDTH : Integer range 8 to 1024 :=  32;
         -- Specifies the width of the MM2S Master Stream Data 
         -- Channel data bus
                              
      C_INCLUDE_MM2S_STSFIFO    : Integer range 0 to  1 :=  0;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit MM2S Status FIFO
         -- 1 = Include MM2S Status FIFO
         
      C_MM2S_STSCMD_FIFO_DEPTH  : Integer range 1 to 16 :=  4;
         -- Specifies the depth of the MM2S Command FIFO and the 
         -- optional Status FIFO
         -- Valid values are 1,4,8,16
         
      C_MM2S_STSCMD_IS_ASYNC    : Integer range 0 to  1 :=  0;
         -- Specifies if the Status and Command interfaces need to
         -- be asynchronous to the primary data path clocking
         -- 0 = Use same clocking as data path
         -- 1 = Use special Status/Command clock for the interfaces
         
      C_INCLUDE_MM2S_DRE : Integer range 0 to  1 :=  0;
         -- Specifies if DRE is to be included in the MM2S function 
         -- 0 = Omit DRE
         -- 1 = Include DRE
      
      C_MM2S_BURST_SIZE  : Integer range 2 to  256 :=  16;
         -- Specifies the max number of databeats to use for MMap
         -- burst transfers by the MM2S function 
    
      C_MM2S_BTT_USED            : Integer range 8 to  23 :=  16;
        -- Specifies the number of bits used from the BTT field
        -- of the input Command Word of the MM2S Command Interface 
    
      C_MM2S_ADDR_PIPE_DEPTH     : Integer range 1 to 30 := 1;
        -- This parameter specifies the depth of the MM2S internal 
        -- child command queues in the Read Address Controller and 
        -- the Read Data Controller. Increasing this value will 
        -- allow more Read Addresses to be issued to the AXI4 Read 
        -- Address Channel before receipt of the associated read 
        -- data on the Read Data Channel.

      C_TAG_WIDTH        : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field

      C_ENABLE_CACHE_USER    : Integer range 0 to 1 := 0;

         
      C_FAMILY : String := "virtex7"
         -- Specifies the target FPGA family type
      
      );
    port (
      
      
      -- MM2S Primary Clock input --------------------------------
      mm2s_aclk               : in  std_logic;                 --
         -- Primary synchronization clock for the Master side  --
         -- interface and internal logic. It is also used      --
         -- for the User interface synchronization when        --
         -- C_STSCMD_IS_ASYNC = 0.                             --
                                                               --
      -- MM2S Primary Reset input                              --
      mm2s_aresetn            : in  std_logic;                 --
         -- Reset used for the internal master logic           --
      -----------------------------------------------------------
      
 
     
      -- MM2S Halt request input control-------------------------
      mm2s_halt               : in  std_logic;                 --
         -- Active high soft shutdown request                  --
                                                               --
      -- MM2S Halt Complete status flag                        --
      mm2s_halt_cmplt         : Out  std_logic;                --
         -- Active high soft shutdown complete status          --
      -----------------------------------------------------------
      
      
      
      -- Error discrete output ----------------------------------
      mm2s_err                : Out std_logic;                 --
         -- Composite Error indication                         --
      -----------------------------------------------------------
     
     
     
      -- Optional MM2S Command and Status clock and Reset -----------
      -- Only used when C_MM2S_STSCMD_IS_ASYNC = 1                 --
      mm2s_cmdsts_awclk       : in  std_logic;                     --
      -- Secondary Clock input for async CMD/Status interface      --
                                                                   --
      mm2s_cmdsts_aresetn     : in  std_logic;                     --
        -- Secondary Reset input for async CMD/Status interface    --
      ---------------------------------------------------------------
      
      
      -- User Command Interface Ports (AXI Stream) ----------------------------------------------------
      mm2s_cmd_wvalid         : in  std_logic;                                                       --
      mm2s_cmd_wready         : out std_logic;                                                       --
      mm2s_cmd_wdata          : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_MM2S_ADDR_WIDTH+36)-1 downto 0); --
      -------------------------------------------------------------------------------------------------
      
      -- User Status Interface Ports (AXI Stream) --------------------
      mm2s_sts_wvalid         : out std_logic;                      --
      mm2s_sts_wready         : in  std_logic;                      --
      mm2s_sts_wdata          : out std_logic_vector(7 downto 0);   --
      mm2s_sts_wstrb          : out std_logic_vector(0 downto 0);   --
      mm2s_sts_wlast          : out std_logic;                      --
      ----------------------------------------------------------------
      
      
      -- Address Posting contols -------------------------------------
      mm2s_allow_addr_req     : in  std_logic;                      --
      mm2s_addr_req_posted    : out std_logic;                      --
      mm2s_rd_xfer_cmplt      : out std_logic;                      --
      ----------------------------------------------------------------
      
      
      
      -- MM2S AXI Address Channel I/O  --------------------------------------
      mm2s_arid     : out std_logic_vector(C_MM2S_ID_WIDTH-1 downto 0);    --
         -- AXI Address Channel ID output                                  --
                                                                           --
      mm2s_araddr   : out std_logic_vector(C_MM2S_ADDR_WIDTH-1 downto 0);  --
         -- AXI Address Channel Address output                             --
                                                                           --
      mm2s_arlen    : out std_logic_vector(7 downto 0);                    --
         -- AXI Address Channel LEN output                                 --
         -- Sized to support 256 data beat bursts                          --
                                                                           --
      mm2s_arsize   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel SIZE output                                --
                                                                           --
      mm2s_arburst  : out std_logic_vector(1 downto 0);                    --
         -- AXI Address Channel BURST output                               --
                                                                           --
      mm2s_arprot   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel PROT output                                --
                                                                           --
      mm2s_arcache  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel CACHE output                               --

      mm2s_aruser  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel USER output                               --
                                                                           --
      mm2s_arvalid  : out std_logic;                                       --
         -- AXI Address Channel VALID output                               --
                                                                           --
      mm2s_arready  : in  std_logic;                                       --
         -- AXI Address Channel READY input                                --
      -----------------------------------------------------------------------
      
        
      -- Currently unsupported AXI Address Channel output signals -----------
        -- addr2axi_alock   : out std_logic_vector(2 downto 0);            --
        -- addr2axi_acache  : out std_logic_vector(4 downto 0);            --
        -- addr2axi_aqos    : out std_logic_vector(3 downto 0);            --
        -- addr2axi_aregion : out std_logic_vector(3 downto 0);            --
      -----------------------------------------------------------------------
  
  
      
      -- MM2S AXI MMap Read Data Channel I/O  ------------------------------------------
      mm2s_rdata              : In  std_logic_vector(C_MM2S_MDATA_WIDTH-1 downto 0);  --
      mm2s_rresp              : In  std_logic_vector(1 downto 0);                     --
      mm2s_rlast              : In  std_logic;                                        --
      mm2s_rvalid             : In  std_logic;                                        --
      mm2s_rready             : Out std_logic;                                        --
      ----------------------------------------------------------------------------------
      
      
      
      -- MM2S AXI Master Stream Channel I/O  -----------------------------------------------
      mm2s_strm_wdata         : Out  std_logic_vector(C_MM2S_SDATA_WIDTH-1 downto 0);     --
      mm2s_strm_wstrb         : Out  std_logic_vector((C_MM2S_SDATA_WIDTH/8)-1 downto 0); --
      mm2s_strm_wlast         : Out  std_logic;                                           --
      mm2s_strm_wvalid        : Out  std_logic;                                           --
      mm2s_strm_wready        : In   std_logic;                                           --
      --------------------------------------------------------------------------------------
      
      -- Testing Support I/O -----------------------------------------------
      mm2s_dbg_sel            : in  std_logic_vector( 3 downto 0);        --
      mm2s_dbg_data           : out std_logic_vector(31 downto 0)         --
      ----------------------------------------------------------------------
      
      
      );
  
  end entity axi_datamover_mm2s_omit_wrap;
  
  
  architecture implementation of axi_datamover_mm2s_omit_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    
    
    
    
    
  begin --(architecture implementation)
  
    
      mm2s_dbg_data        <=  X"BEEF0000"    ;    -- 32 bit Constant indicating OMIT type
    
    -- Just tie off output ports
      mm2s_halt_cmplt      <=  mm2s_halt      ;    
      mm2s_err             <=  '0'            ;    
      mm2s_cmd_wready      <=  '0'            ;    
      mm2s_sts_wvalid      <=  '0'            ;    
      mm2s_sts_wdata       <=  (others => '0');    
      mm2s_sts_wstrb       <=  (others => '0');    
      mm2s_sts_wlast       <=  '0'            ;    
      mm2s_arid            <=  (others => '0');    
      mm2s_araddr          <=  (others => '0');    
      mm2s_arlen           <=  (others => '0');    
      mm2s_arsize          <=  (others => '0');    
      mm2s_arburst         <=  (others => '0');    
      mm2s_arprot          <=  (others => '0');    
      mm2s_arcache         <=  (others => '0');    
      mm2s_aruser          <=  (others => '0');    
      mm2s_arvalid         <=  '0'            ;    
      mm2s_rready          <=  '0'            ;    
      mm2s_strm_wdata      <=  (others => '0');    
      mm2s_strm_wstrb      <=  (others => '0');    
      mm2s_strm_wlast      <=  '0'            ;    
      mm2s_strm_wvalid     <=  '0'            ;    
      mm2s_addr_req_posted <=  '0'            ;
      mm2s_rd_xfer_cmplt   <=  '0'            ;
    
    
    -- Input ports are ignored 
     
    
    
    
  end implementation;
