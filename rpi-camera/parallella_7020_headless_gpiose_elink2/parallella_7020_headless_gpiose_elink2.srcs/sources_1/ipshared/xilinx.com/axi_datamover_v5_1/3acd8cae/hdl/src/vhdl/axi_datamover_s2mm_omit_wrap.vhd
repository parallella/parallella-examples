  -------------------------------------------------------------------------------
  -- axi_datamover_s2mm_omit_wrap.vhd
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
  -- Filename:        axi_datamover_s2mm_omit_wrap.vhd
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
  
  entity axi_datamover_s2mm_omit_wrap is
    generic (
      
      C_INCLUDE_S2MM    : Integer range 0 to  2 :=  0;
         -- Specifies the type of S2MM function to include
         -- 0 = Omit S2MM functionality
         -- 1 = Full S2MM Functionality
         -- 2 = Lite S2MM functionality
         
      C_S2MM_AWID  : Integer range 0 to  255 :=  9;
         -- Specifies the constant value to output on 
         -- the ARID output port
         
      C_S2MM_ID_WIDTH    : Integer range 1 to  8 :=  4;
         -- Specifies the width of the S2MM ID port 
         
      C_S2MM_ADDR_WIDTH  : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel 
         -- Address bus
         
      C_S2MM_MDATA_WIDTH : Integer range 32 to 1024 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus
      
      C_S2MM_SDATA_WIDTH : Integer range 8 to 1024 :=  32;
         -- Specifies the width of the S2MM Master Stream Data 
         -- Channel data bus
      
      C_INCLUDE_S2MM_STSFIFO    : Integer range 0 to  1 :=  0;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit S2MM Status FIFO
         -- 1 = Include S2MM Status FIFO
         
      C_S2MM_STSCMD_FIFO_DEPTH    : Integer range 1 to 16 :=  4;
         -- Specifies the depth of the S2MM Command FIFO and the 
         -- optional Status FIFO
         -- Valid values are 1,4,8,16
         
      C_S2MM_STSCMD_IS_ASYNC    : Integer range 0 to  1 :=  0;
         -- Specifies if the Status and Command interfaces need to
         -- be asynchronous to the primary data path clocking
         -- 0 = Use same clocking as data path
         -- 1 = Use special Status/Command clock for the interfaces
         
      C_INCLUDE_S2MM_DRE        : Integer range 0 to  1 :=  0;
         -- Specifies if DRE is to be included in the S2MM function 
         -- 0 = Omit DRE
         -- 1 = Include DRE
      
      C_S2MM_BURST_SIZE         : Integer range 2 to  256 :=  16;
         -- Specifies the max number of databeats to use for MMap
         -- burst transfers by the S2MM function 
      
      C_S2MM_SUPPORT_INDET_BTT  : Integer range 0 to  1 :=  0;
         -- Specifies if Store and Forward is enabled
 
      C_S2MM_ADDR_PIPE_DEPTH    : Integer range 1 to 30 := 1;
          -- This parameter specifies the depth of the S2MM internal 
          -- address pipeline queues in the Write Address Controller 
          -- and the Write Data Controller. Increasing this value will 
          -- allow more Write Addresses to be issued to the AXI4 Write 
          -- Address Channel before transmission of the associated  
          -- write data on the Write Data Channel.

      C_TAG_WIDTH        : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field

      C_ENABLE_CACHE_USER    : Integer range 0 to 1 := 0;
         
      C_FAMILY : String := "virtex7"
         -- Specifies the target FPGA family type
      
      );
    port (
      
      
      -- S2MM Primary Clock and reset inputs -----------------------
      s2mm_aclk         : in  std_logic;                          --
         -- Primary synchronization clock for the Master side     --
         -- interface and internal logic. It is also used         --
         -- for the User interface synchronization when           --
         -- C_STSCMD_IS_ASYNC = 0.                                --
                                                                  --
      -- S2MM Primary Reset input                                 --
      s2mm_aresetn      : in  std_logic;                          --
         -- Reset used for the internal master logic              --
      --------------------------------------------------------------
      
 
     
      -- S2MM Halt request input control ---------------------------
      s2mm_halt               : in  std_logic;                    --
         -- Active high soft shutdown request                     --
                                                                  --
      -- S2MM Halt Complete status flag                           --
      s2mm_halt_cmplt         : out std_logic;                    --
         -- Active high soft shutdown complete status             --
      --------------------------------------------------------------
      
      
      
      -- S2MM Error discrete output --------------------------------
      s2mm_err          : Out std_logic;                          --
         -- Composite Error indication                            --
      --------------------------------------------------------------
     
     
     
      -- Optional S2MM Command/Status Clock and Reset Inputs -------
      -- Only used if C_S2MM_STSCMD_IS_ASYNC = 1                  --
      s2mm_cmdsts_awclk       : in  std_logic;                    --
      -- Secondary Clock input for async CMD/Status interface     --
                                                                  --
      s2mm_cmdsts_aresetn     : in  std_logic;                    --
        -- Secondary Reset input for async CMD/Status interface   --
      --------------------------------------------------------------
      
      
      -- User Command Interface Ports (AXI Stream) -----------------------------------------------------
      s2mm_cmd_wvalid         : in  std_logic;                                                        --
      s2mm_cmd_wready         : out std_logic;                                                        --
      s2mm_cmd_wdata          : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_S2MM_ADDR_WIDTH+36)-1 downto 0);  --
      --------------------------------------------------------------------------------------------------
      
      
      -- User Status Interface Ports (AXI Stream) --------------------------------------------------------
      s2mm_sts_wvalid         : out std_logic;                                                          --
      s2mm_sts_wready         : in  std_logic;                                                          --
      s2mm_sts_wdata          : out std_logic_vector(((C_S2MM_SUPPORT_INDET_BTT*24)+8)-1 downto 0);     --
      s2mm_sts_wstrb          : out std_logic_vector((((C_S2MM_SUPPORT_INDET_BTT*24)+8)/8)-1 downto 0); --
      s2mm_sts_wlast          : out std_logic;                                                          --
      ----------------------------------------------------------------------------------------------------
      
      
      -- Address posting controls -----------------------------------------
      s2mm_allow_addr_req     : in  std_logic;                           --
      s2mm_addr_req_posted    : out std_logic;                           --
      s2mm_wr_xfer_cmplt      : out std_logic;                           --
      s2mm_ld_nxt_len         : out std_logic;                           --
      s2mm_wr_len             : out std_logic_vector(7 downto 0);        --
      ---------------------------------------------------------------------
      
      
     
      
      -- S2MM AXI Address Channel I/O  --------------------------------------
      s2mm_awid     : out std_logic_vector(C_S2MM_ID_WIDTH-1 downto 0);    --
         -- AXI Address Channel ID output                                  --
                                                                           --
      s2mm_awaddr   : out std_logic_vector(C_S2MM_ADDR_WIDTH-1 downto 0);  --
         -- AXI Address Channel Address output                             --
                                                                           --
      s2mm_awlen    : out std_logic_vector(7 downto 0);                    --
         -- AXI Address Channel LEN output                                 --
         -- Sized to support 256 data beat bursts                          --
                                                                           --
      s2mm_awsize   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel SIZE output                                --
                                                                           --
      s2mm_awburst  : out std_logic_vector(1 downto 0);                    --
         -- AXI Address Channel BURST output                               --
                                                                           --
      s2mm_awprot   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel PROT output                                --
                                                                           --
      s2mm_awcache  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel PROT output                                --

      s2mm_awuser  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel PROT output                                --
                                                                           --
      s2mm_awvalid  : out std_logic;                                       --
         -- AXI Address Channel VALID output                               --
                                                                           --
      s2mm_awready  : in  std_logic;                                       --
         -- AXI Address Channel READY input                                --
      -----------------------------------------------------------------------
      
      
        
      -- Currently unsupported AXI Address Channel output signals -----------
        -- s2mm__awlock   : out std_logic_vector(2 downto 0);              --
        -- s2mm__awcache  : out std_logic_vector(4 downto 0);              --
        -- s2mm__awqos    : out std_logic_vector(3 downto 0);              --
        -- s2mm__awregion : out std_logic_vector(3 downto 0);              --
      -----------------------------------------------------------------------
  
  
  
  
      
      -- S2MM AXI MMap Write Data Channel I/O  ----------------------------------------------
      s2mm_wdata              : Out  std_logic_vector(C_S2MM_MDATA_WIDTH-1 downto 0);      --
      s2mm_wstrb              : Out  std_logic_vector((C_S2MM_MDATA_WIDTH/8)-1 downto 0);  --
      s2mm_wlast              : Out  std_logic;                                            --
      s2mm_wvalid             : Out  std_logic;                                            --
      s2mm_wready             : In   std_logic;                                            --
      ---------------------------------------------------------------------------------------
      
      
      -- S2MM AXI MMap Write response Channel I/O  ------------------------------------------
      s2mm_bresp              : In   std_logic_vector(1 downto 0);                         --
      s2mm_bvalid             : In   std_logic;                                            --
      s2mm_bready             : Out  std_logic;                                            --
      ---------------------------------------------------------------------------------------
      
      
      -- S2MM AXI Master Stream Channel I/O  ------------------------------------------------
      s2mm_strm_wdata         : In  std_logic_vector(C_S2MM_SDATA_WIDTH-1 downto 0);       --
      s2mm_strm_wstrb         : In  std_logic_vector((C_S2MM_SDATA_WIDTH/8)-1 downto 0);   --
      s2mm_strm_wlast         : In  std_logic;                                             --
      s2mm_strm_wvalid        : In  std_logic;                                             --
      s2mm_strm_wready        : Out std_logic;                                             --
      ---------------------------------------------------------------------------------------
      
      -- Testing Support I/O -----------------------------------------
      s2mm_dbg_sel            : in  std_logic_vector( 3 downto 0);  --
      s2mm_dbg_data           : out std_logic_vector(31 downto 0)   --
      ----------------------------------------------------------------
      
      
      );
  
  end entity axi_datamover_s2mm_omit_wrap;
  
  
  architecture implementation of axi_datamover_s2mm_omit_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    
    
    
    
    
  begin --(architecture implementation)
  
    
 
 
 
    -- Just tie off output ports
    
      s2mm_dbg_data        <=  X"CAFE0000"    ; -- 32 bit Constant indicating S2MM OMIT type
 
      s2mm_addr_req_posted <=  '0'            ;  
      s2mm_wr_xfer_cmplt   <=  '0'            ;  
      s2mm_ld_nxt_len      <=  '0'            ;
      s2mm_wr_len          <=  (others => '0');
      s2mm_halt_cmplt      <=  s2mm_halt      ;    
      s2mm_err             <=  '0'            ;    
      s2mm_cmd_wready      <=  '0'            ;    
      s2mm_sts_wvalid      <=  '0'            ;    
      s2mm_sts_wdata       <=  (others => '0');    
      s2mm_sts_wstrb       <=  (others => '0');    
      s2mm_sts_wlast       <=  '0'            ;    
      s2mm_awid            <=  (others => '0');    
      s2mm_awaddr          <=  (others => '0');    
      s2mm_awlen           <=  (others => '0');    
      s2mm_awsize          <=  (others => '0');    
      s2mm_awburst         <=  (others => '0');    
      s2mm_awprot          <=  (others => '0');    
      s2mm_awcache         <=  (others => '0');    
      s2mm_awuser          <=  (others => '0');    
      s2mm_awvalid         <=  '0'            ;    
      s2mm_wdata           <=  (others => '0');    
      s2mm_wstrb           <=  (others => '0');    
      s2mm_wlast           <=  '0'            ;    
      s2mm_wvalid          <=  '0'            ;    
      s2mm_bready          <=  '0'            ;    
      s2mm_strm_wready     <=  '0'            ;    
      
      
    -- Input ports are ignored 
     
    
    
    
  end implementation;
