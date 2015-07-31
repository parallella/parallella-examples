  -------------------------------------------------------------------------------
  -- axi_datamover_s2mm_basic_wrap.vhd
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
  -- Filename:        axi_datamover_s2mm_basic_wrap.vhd
  --
  -- Description:     
  --    This file implements the DataMover S2MM Basic Wrapper.                 
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
  
  
  
  -- axi_datamover Library Modules
  library axi_datamover_v5_1; 
  use axi_datamover_v5_1.axi_datamover_reset;  
  use axi_datamover_v5_1.axi_datamover_cmd_status;
  use axi_datamover_v5_1.axi_datamover_scc;
  use axi_datamover_v5_1.axi_datamover_addr_cntl;
  use axi_datamover_v5_1.axi_datamover_wrdata_cntl;
  use axi_datamover_v5_1.axi_datamover_wr_status_cntl;
  Use axi_datamover_v5_1.axi_datamover_skid2mm_buf;
  Use axi_datamover_v5_1.axi_datamover_skid_buf;
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_s2mm_basic_wrap is
    generic (
      
      C_INCLUDE_S2MM    : Integer range 0 to  2 :=  2;
         -- Specifies the type of S2MM function to include
         -- 0 = Omit S2MM functionality
         -- 1 = Full S2MM Functionality
         -- 2 = Basic S2MM functionality
         
      C_S2MM_AWID  : Integer range 0 to 255 :=  9;
         -- Specifies the constant value to output on 
         -- the ARID output port
         
      C_S2MM_ID_WIDTH    : Integer range 1 to  8 :=  4;
         -- Specifies the width of the S2MM ID port 
         
      C_S2MM_ADDR_WIDTH  : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel 
         -- Address bus
         
      C_S2MM_MDATA_WIDTH : Integer range 32 to 64 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus
      
      C_S2MM_SDATA_WIDTH : Integer range 8 to 64 :=  32;
         -- Specifies the width of the S2MM Master Stream Data 
         -- Channel data bus
      
      C_INCLUDE_S2MM_STSFIFO    : Integer range 0 to  1 :=  1;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit S2MM Status FIFO
         -- 1 = Include S2MM Status FIFO
         
      C_S2MM_STSCMD_FIFO_DEPTH    : Integer range 1 to 16 :=  1;
         -- Specifies the depth of the S2MM Command FIFO and the 
         -- optional Status FIFO
         -- Valid values are 1,4,8,16
         
      C_S2MM_STSCMD_IS_ASYNC    : Integer range 0 to  1 :=  0;
         -- Specifies if the Status and Command interfaces need to
         -- be asynchronous to the primary data path clocking
         -- 0 = Use same clocking as data path
         -- 1 = Use special Status/Command clock for the interfaces
         
      C_INCLUDE_S2MM_DRE    : Integer range 0 to  1 :=  0;
         -- Specifies if DRE is to be included in the S2MM function 
         -- 0 = Omit DRE
         -- 1 = Include DRE
      
      C_S2MM_BURST_SIZE    : Integer range 2 to  64 :=  16;
         -- Specifies the max number of databeats to use for MMap
         -- burst transfers by the S2MM function 

      C_S2MM_ADDR_PIPE_DEPTH    : Integer range 1 to 30 := 1;
          -- This parameter specifies the depth of the S2MM internal 
          -- address pipeline queues in the Write Address Controller 
          -- and the Write Data Controller. Increasing this value will 
          -- allow more Write Addresses to be issued to the AXI4 Write 
          -- Address Channel before transmission of the associated  
          -- write data on the Write Data Channel.

      C_ENABLE_CACHE_USER           : Integer range 0 to 1 := 1; 

      C_ENABLE_SKID_BUF                : string := "11111";

      C_MICRO_DMA                   : integer range 0 to 1 := 0;

      C_TAG_WIDTH        : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field
         
      C_FAMILY : String := "virtex7"
         -- Specifies the target FPGA family type
      
      );
    port (
      
      
      -- S2MM Primary Clock and reset inputs -----------------------------
      s2mm_aclk         : in  std_logic;                                --
         -- Primary synchronization clock for the Master side           --
         -- interface and internal logic. It is also used               --
         -- for the User interface synchronization when                 --
         -- C_STSCMD_IS_ASYNC = 0.                                      --
                                                                        --
      -- S2MM Primary Reset input                                       --
      s2mm_aresetn      : in  std_logic;                                --
         -- Reset used for the internal master logic                    --
      --------------------------------------------------------------------
     
      -- S2MM Halt request input control ---------------------------------
      s2mm_halt               : in  std_logic;                          --
         -- Active high soft shutdown request                           --
                                                                        --
      -- S2MM Halt Complete status flag                                 --
      s2mm_halt_cmplt         : Out  std_logic;                         --
         -- Active high soft shutdown complete status                   --
      --------------------------------------------------------------------
      
      
      
      -- S2MM Error discrete output --------------------------------------
      s2mm_err          : Out std_logic;                                --
         -- Composite Error indication                                  --
      --------------------------------------------------------------------
      
     
     
     
      -- Optional Command/Status Interface Clock and Reset Inputs  -------
      -- Only used when C_S2MM_STSCMD_IS_ASYNC = 1                      --
                                                                        --
      s2mm_cmdsts_awclk       : in  std_logic;                          --
      -- Secondary Clock input for async CMD/Status interface           --
                                                                        --
      s2mm_cmdsts_aresetn     : in  std_logic;                          --
        -- Secondary Reset input for async CMD/Status interface         --
      --------------------------------------------------------------------
      
      
      -- User Command Interface Ports (AXI Stream) ------------------------------------------------------
      s2mm_cmd_wvalid         : in  std_logic;                                                         --
      s2mm_cmd_wready         : out std_logic;                                                         --
      s2mm_cmd_wdata          : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_S2MM_ADDR_WIDTH+36)-1 downto 0);   --
      ---------------------------------------------------------------------------------------------------
      
      
      -- User Status Interface Ports (AXI Stream) ------------------------
      s2mm_sts_wvalid         : out std_logic;                          --
      s2mm_sts_wready         : in  std_logic;                          --
      s2mm_sts_wdata          : out std_logic_vector(7 downto 0);       --
      s2mm_sts_wstrb          : out std_logic_vector(0 downto 0);       --
      s2mm_sts_wlast          : out std_logic;                          --
      --------------------------------------------------------------------
      
      
      -- Address posting controls ----------------------------------------
      s2mm_allow_addr_req     : in  std_logic;                          --
      s2mm_addr_req_posted    : out std_logic;                          --
      s2mm_wr_xfer_cmplt      : out std_logic;                          --
      s2mm_ld_nxt_len         : out std_logic;                          --
      s2mm_wr_len             : out std_logic_vector(7 downto 0);       --
      --------------------------------------------------------------------
      
     
      
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
  
  
  
  
      
      -- S2MM AXI MMap Write Data Channel I/O  ---------------------------------------------
      s2mm_wdata              : Out  std_logic_vector(C_S2MM_MDATA_WIDTH-1 downto 0);     --
      s2mm_wstrb              : Out  std_logic_vector((C_S2MM_MDATA_WIDTH/8)-1 downto 0); --
      s2mm_wlast              : Out  std_logic;                                           --
      s2mm_wvalid             : Out  std_logic;                                           --
      s2mm_wready             : In   std_logic;                                           --
      --------------------------------------------------------------------------------------
      
      
      -- S2MM AXI MMap Write response Channel I/O  -----------------------------------------
      s2mm_bresp              : In   std_logic_vector(1 downto 0);                        --
      s2mm_bvalid             : In   std_logic;                                           --
      s2mm_bready             : Out  std_logic;                                           --
      --------------------------------------------------------------------------------------
      
      
      
      -- S2MM AXI Master Stream Channel I/O  -----------------------------------------------
      s2mm_strm_wdata         : In  std_logic_vector(C_S2MM_SDATA_WIDTH-1 downto 0);      --
      s2mm_strm_wstrb         : In  std_logic_vector((C_S2MM_SDATA_WIDTH/8)-1 downto 0);  --
      s2mm_strm_wlast         : In  std_logic;                                            --
      s2mm_strm_wvalid        : In  std_logic;                                            --
      s2mm_strm_wready        : Out std_logic;                                            --
      --------------------------------------------------------------------------------------
      
      -- Testing Support I/O ------------------------------------------
      s2mm_dbg_sel            : in  std_logic_vector( 3 downto 0);   --
      s2mm_dbg_data           : out std_logic_vector(31 downto 0)    --
      -----------------------------------------------------------------
      
      
      );                            
  
  end entity axi_datamover_s2mm_basic_wrap;
  
  
  architecture implementation of axi_datamover_s2mm_basic_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Function Declarations   ----------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_calc_wdemux_sel_bits
    --
    -- Function Description:
    --  This function calculates the number of address bits needed for  
    -- the Write Strobe demux select control. 
    --
    -------------------------------------------------------------------
    function func_calc_wdemux_sel_bits (mmap_dwidth_value : integer) return integer is
    
      Variable num_addr_bits_needed : Integer range 1 to 5 := 1;
    
    begin
    
      case mmap_dwidth_value is
        when 32 =>
          num_addr_bits_needed := 2;
        when 64 =>
          num_addr_bits_needed := 3;
        when 128 =>
          num_addr_bits_needed := 4;
        when others => -- 256 bits
          num_addr_bits_needed := 5;
      end case;
      
      Return (num_addr_bits_needed);
       
    end function func_calc_wdemux_sel_bits;
    

   


    -- Constant Declarations   ----------------------------------------
    
     Constant LOGIC_LOW                 : std_logic := '0';
     Constant LOGIC_HIGH                : std_logic := '1';
     Constant S2MM_AWID_VALUE           : integer range  0 to 255 := C_S2MM_AWID;
     Constant S2MM_AWID_WIDTH           : integer range  1 to   8 := C_S2MM_ID_WIDTH;
     Constant S2MM_ADDR_WIDTH           : integer range 32 to  64 := C_S2MM_ADDR_WIDTH;
     Constant S2MM_MDATA_WIDTH          : integer range 32 to 256 := C_S2MM_MDATA_WIDTH;
     Constant S2MM_SDATA_WIDTH          : integer range  8 to 256 := C_S2MM_SDATA_WIDTH;
     Constant S2MM_CMD_WIDTH            : integer                 := (C_TAG_WIDTH+C_S2MM_ADDR_WIDTH+32);
     Constant S2MM_STS_WIDTH            : integer                 :=  8; -- always 8 for S2MM Basic Version
     Constant INCLUDE_S2MM_STSFIFO      : integer range  0 to   1 :=  1;
     Constant S2MM_STSCMD_FIFO_DEPTH    : integer range  1 to  16 :=  C_S2MM_STSCMD_FIFO_DEPTH;
     Constant S2MM_STSCMD_IS_ASYNC      : integer range  0 to   1 :=  C_S2MM_STSCMD_IS_ASYNC;
     Constant S2MM_BURST_SIZE           : integer range 16 to 256 := 16;
     Constant WR_ADDR_CNTL_FIFO_DEPTH   : integer range  1 to  30 := C_S2MM_ADDR_PIPE_DEPTH;
     Constant WR_DATA_CNTL_FIFO_DEPTH   : integer range  1 to  30 := C_S2MM_ADDR_PIPE_DEPTH;
     
     Constant WR_STATUS_CNTL_FIFO_DEPTH : integer range  1 to  32 := WR_DATA_CNTL_FIFO_DEPTH+2;-- 2 added for going 
                                                                                               -- full thresholding
                                                                                               -- in WSC           
     
     
     Constant SEL_ADDR_WIDTH            : integer := func_calc_wdemux_sel_bits(S2MM_MDATA_WIDTH);
     Constant INCLUDE_S2MM_DRE          : integer range  0 to   1 :=  1;
     Constant OMIT_S2MM_DRE             : integer range  0 to   1 :=  0;
     Constant OMIT_INDET_BTT            : integer := 0;
     Constant SF_BYTES_RCVD_WIDTH       : integer := 1;
     Constant ZEROS_8_BIT               : std_logic_vector(7 downto 0) := (others => '0');
     
     
        
    
    -- Signal Declarations  ------------------------------------------
    
     signal sig_cmd_stat_rst_user        : std_logic := '0';
     signal sig_cmd_stat_rst_int         : std_logic := '0';
     signal sig_mmap_rst                 : std_logic := '0';
     signal sig_stream_rst               : std_logic := '0';
     signal sig_s2mm_cmd_wdata           : std_logic_vector(S2MM_CMD_WIDTH-1 downto 0) := (others => '0');
     signal sig_s2mm_cache_data          : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_cmd2mstr_command         : std_logic_vector(S2MM_CMD_WIDTH-1 downto 0) := (others => '0');        
     signal sig_cmd2mstr_cmd_valid       : std_logic := '0';                                             
     signal sig_mst2cmd_cmd_ready        : std_logic := '0';                                             
     signal sig_mstr2addr_addr           : std_logic_vector(S2MM_ADDR_WIDTH-1 downto 0) := (others => '0');             
     signal sig_mstr2addr_len            : std_logic_vector(7 downto 0) := (others => '0');                          
     signal sig_mstr2addr_size           : std_logic_vector(2 downto 0) := (others => '0');                          
     signal sig_mstr2addr_burst          : std_logic_vector(1 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cache          : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_user           : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cmd_cmplt      : std_logic := '0';
     signal sig_mstr2addr_calc_error     : std_logic := '0';
     signal sig_mstr2addr_cmd_valid      : std_logic := '0';                                             
     signal sig_addr2mstr_cmd_ready      : std_logic := '0';                                              
     signal sig_mstr2data_saddr_lsb      : std_logic_vector(SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2data_len            : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_mstr2data_strt_strb      : std_logic_vector((S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');      
     signal sig_mstr2data_last_strb      : std_logic_vector((S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_mstr2data_drr            : std_logic := '0';
     signal sig_mstr2data_eof            : std_logic := '0';
     signal sig_mstr2data_calc_error     : std_logic := '0';
     signal sig_mstr2data_cmd_last       : std_logic := '0';
     signal sig_mstr2data_cmd_valid      : std_logic := '0';                                             
     signal sig_data2mstr_cmd_ready      : std_logic := '0';                                               
     signal sig_addr2data_addr_posted    : std_logic := '0';
     signal sig_data2addr_data_rdy       : std_logic := '0';
     signal sig_data2all_tlast_error     : std_logic := '0';
     signal sig_data2all_dcntlr_halted   : std_logic := '0';
     signal sig_addr2wsc_calc_error      : std_logic := '0';
     signal sig_addr2wsc_cmd_fifo_empty  : std_logic := '0';
     signal sig_data2wsc_rresp           : std_logic_vector(1 downto 0) := (others => '0'); 
     signal sig_data2wsc_cmd_empty       : std_logic := '0';                   
     signal sig_data2wsc_calc_err        : std_logic := '0'; 
     signal sig_data2wsc_cmd_cmplt       : std_logic := '0';
     signal sig_data2wsc_last_err        : std_logic := '0';
     signal sig_calc2dm_calc_err         : std_logic := '0';
     signal sig_wsc2stat_status          : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_stat2wsc_status_ready    : std_logic := '0';   
     signal sig_wsc2stat_status_valid    : std_logic := '0';  
     signal sig_wsc2mstr_halt_pipe       : std_logic := '0';  
     signal sig_data2wsc_tag             : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2data_tag            : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2addr_tag            : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_addr_lsb       : std_logic_vector(SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_wvalid         : std_logic := '0';
     signal sig_skid2data_wready         : std_logic := '0';
     signal sig_data2skid_wdata          : std_logic_vector(C_S2MM_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_wstrb          : std_logic_vector((C_S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_data2skid_wlast          : std_logic := '0';
     signal sig_skid2axi_wvalid          : std_logic := '0';
     signal sig_axi2skid_wready          : std_logic := '0';
     signal sig_skid2axi_wdata           : std_logic_vector(C_S2MM_MDATA_WIDTH-1 downto 0) := (others => '0');     
     signal sig_skid2axi_wstrb           : std_logic_vector((C_S2MM_MDATA_WIDTH/8)-1 downto 0) := (others => '0'); 
     signal sig_skid2axi_wlast           : std_logic := '0';
     signal sig_data2wsc_sof             : std_logic := '0';
     signal sig_data2wsc_eof             : std_logic := '0';
     signal sig_data2wsc_valid           : std_logic := '0';
     signal sig_wsc2data_ready           : std_logic := '0';
     signal sig_data2wsc_eop             : std_logic := '0';
     signal sig_data2wsc_bytes_rcvd      : std_logic_vector(SF_BYTES_RCVD_WIDTH-1 downto 0) := (others => '0');
     signal sig_dbg_data_mux_out         : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_0               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_1               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_rst2all_stop_request     : std_logic := '0';
     signal sig_data2rst_stop_cmplt      : std_logic := '0';
     signal sig_addr2rst_stop_cmplt      : std_logic := '0';
     signal sig_data2addr_stop_req       : std_logic := '0';
     signal sig_wsc2rst_stop_cmplt       : std_logic := '0';
     signal sig_data2skid_halt           : std_logic := '0';
     signal sig_realign2wdc_eop_error    : std_logic := '0';
     signal skid2wdc_wvalid              : std_logic := '0';
     signal wdc2skid_wready              : std_logic := '0';
     signal skid2wdc_wdata               : std_logic_vector(C_S2MM_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal skid2wdc_wstrb               : std_logic_vector((C_S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal skid2wdc_wlast               : std_logic := '0';
     signal s2mm_awcache_int             : std_logic_vector (3 downto 0);
     signal sig_cache2mstr_command       : std_logic_vector (7 downto 0);
    
    
  begin --(architecture implementation)
  
    
    
    -- Debug Port Assignments
    
    s2mm_dbg_data        <= sig_dbg_data_mux_out;
    
    -- Note that only the s2mm_dbg_sel(0) is used at this time
    sig_dbg_data_mux_out <= sig_dbg_data_1
      When (s2mm_dbg_sel(0) = '1')
      else sig_dbg_data_0 ;
    
    
    sig_dbg_data_0              <=  X"CAFE2222"             ;    -- 32 bit Constant indicating S2MM Basic type
    
    sig_dbg_data_1(0)           <= sig_cmd_stat_rst_user    ;
    sig_dbg_data_1(1)           <= sig_cmd_stat_rst_int     ;
    sig_dbg_data_1(2)           <= sig_mmap_rst             ;
    sig_dbg_data_1(3)           <= sig_stream_rst           ;
    sig_dbg_data_1(4)           <= sig_cmd2mstr_cmd_valid   ;
    sig_dbg_data_1(5)           <= sig_mst2cmd_cmd_ready    ;
    sig_dbg_data_1(6)           <= sig_stat2wsc_status_ready;
    sig_dbg_data_1(7)           <= sig_wsc2stat_status_valid;
    sig_dbg_data_1(11 downto 8) <= sig_data2wsc_tag         ; -- Current TAG of active data transfer
                         
                        
    sig_dbg_data_1(15 downto 12) <= sig_wsc2stat_status(3 downto 0); -- Internal status tag field
    sig_dbg_data_1(16)           <= sig_wsc2stat_status(4)         ; -- Internal error
    sig_dbg_data_1(17)           <= sig_wsc2stat_status(5)         ; -- Decode Error
    sig_dbg_data_1(18)           <= sig_wsc2stat_status(6)         ; -- Slave Error
    --sig_dbg_data_1(19)           <= sig_wsc2stat_status(7)         ; -- OKAY
    sig_dbg_data_1(19)           <= '0'                            ; -- OKAY not used by TB
    sig_dbg_data_1(20)           <= sig_stat2wsc_status_ready      ; -- Status Ready Handshake
    sig_dbg_data_1(21)           <= sig_wsc2stat_status_valid      ; -- Status Valid Handshake
                        
    
    sig_dbg_data_1(29 downto 22) <= sig_mstr2data_len              ; -- WDC Cmd FIFO LEN input
    sig_dbg_data_1(30)           <= sig_mstr2data_cmd_valid        ; -- WDC Cmd FIFO Valid Inpute
    sig_dbg_data_1(31)           <= sig_data2mstr_cmd_ready        ; -- WDC Cmd FIFO Ready Output
    
    
                        
    
    
    -- Write Data Channel I/O
     s2mm_wvalid         <= sig_skid2axi_wvalid; 
     sig_axi2skid_wready <= s2mm_wready        ;
     s2mm_wdata          <= sig_skid2axi_wdata ; 
     s2mm_wstrb          <= sig_skid2axi_wstrb ; 
     s2mm_wlast          <= sig_skid2axi_wlast ; 
     
     
    GEN_CACHE : if (C_ENABLE_CACHE_USER = 0) generate
      begin
     -- Cache signal tie-off
     s2mm_awcache <= "0011";  -- pre Interface-X guidelines for Masters
     s2mm_awuser <= "0000";  -- pre Interface-X guidelines for Masters
     sig_s2mm_cache_data <= (others => '0'); --s2mm_cmd_wdata(103 downto 96);
    end generate GEN_CACHE;
     
                        
    GEN_CACHE2 : if (C_ENABLE_CACHE_USER = 1) generate
      begin
     -- Cache signal tie-off
     s2mm_awcache <= "0011"; --sg_ctl (3 downto 0);  -- SG Cache from register
     s2mm_awuser <= "0000"; --sg_ctl (7 downto 4);  -- SG Cache from register
     sig_s2mm_cache_data <= s2mm_cmd_wdata(79 downto 72);
  --   sig_s2mm_cache_data <= s2mm_cmd_wdata(103 downto 96);
    end generate GEN_CACHE2;
                       
     -- Internal error output discrete
     s2mm_err            <=  sig_calc2dm_calc_err or sig_data2all_tlast_error;
     
     
     -- Rip the used portion of the Command Interface Command Data
     -- and throw away the padding
     sig_s2mm_cmd_wdata <= s2mm_cmd_wdata(S2MM_CMD_WIDTH-1 downto 0);
     
     
     
 
     -- No Realigner in S2MM Basic
     sig_realign2wdc_eop_error <= '0';

     
     
     
     
     
     
     
     
          
          
     ------------------------------------------------------------
     -- Instance: I_RESET 
     --
     -- Description:
     --   Reset Block  
     --
     ------------------------------------------------------------
      I_RESET : entity axi_datamover_v5_1.axi_datamover_reset
      generic map (
    
        C_STSCMD_IS_ASYNC    =>  S2MM_STSCMD_IS_ASYNC      
    
        )
      port map (
    
        primary_aclk         =>  s2mm_aclk               , 
        primary_aresetn      =>  s2mm_aresetn            , 
        secondary_awclk      =>  s2mm_cmdsts_awclk       , 
        secondary_aresetn    =>  s2mm_cmdsts_aresetn     , 
        halt_req             =>  s2mm_halt               , 
        halt_cmplt           =>  s2mm_halt_cmplt         , 
        flush_stop_request   =>  sig_rst2all_stop_request, 
        data_cntlr_stopped   =>  sig_data2rst_stop_cmplt , 
        addr_cntlr_stopped   =>  sig_addr2rst_stop_cmplt , 
        aux1_stopped         =>  sig_wsc2rst_stop_cmplt  , 
        aux2_stopped         =>  LOGIC_HIGH              , 
        cmd_stat_rst_user    =>  sig_cmd_stat_rst_user   , 
        cmd_stat_rst_int     =>  sig_cmd_stat_rst_int    , 
        mmap_rst             =>  sig_mmap_rst            , 
        stream_rst           =>  sig_stream_rst            
    
        );
    
    
    
  
  
          
     ------------------------------------------------------------
     -- Instance: I_CMD_STATUS 
     --
     -- Description:
     --   Command and Status Interface Block  
     --
     ------------------------------------------------------------
      I_CMD_STATUS : entity axi_datamover_v5_1.axi_datamover_cmd_status
      generic map (
    
        C_ADDR_WIDTH           =>  S2MM_ADDR_WIDTH           ,     
        C_INCLUDE_STSFIFO      =>  INCLUDE_S2MM_STSFIFO      ,     
        C_STSCMD_FIFO_DEPTH    =>  S2MM_STSCMD_FIFO_DEPTH    ,     
        C_STSCMD_IS_ASYNC      =>  S2MM_STSCMD_IS_ASYNC      ,     
        C_CMD_WIDTH            =>  S2MM_CMD_WIDTH            ,     
        C_STS_WIDTH            =>  S2MM_STS_WIDTH            ,     
        C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER       ,
        C_FAMILY               =>  C_FAMILY                        

        )
      port map (
    
        primary_aclk           =>  s2mm_aclk                 ,     
        secondary_awclk        =>  s2mm_cmdsts_awclk         ,     
        user_reset             =>  sig_cmd_stat_rst_user     ,     
        internal_reset         =>  sig_cmd_stat_rst_int      ,     
        cmd_wvalid             =>  s2mm_cmd_wvalid           ,     
        cmd_wready             =>  s2mm_cmd_wready           ,     
        cmd_wdata              =>  sig_s2mm_cmd_wdata        ,     
        cache_data             =>  sig_s2mm_cache_data        ,     
        sts_wvalid             =>  s2mm_sts_wvalid           ,     
        sts_wready             =>  s2mm_sts_wready           ,     
        sts_wdata              =>  s2mm_sts_wdata            ,     
        sts_wstrb              =>  s2mm_sts_wstrb            ,     
        sts_wlast              =>  s2mm_sts_wlast            ,     
        cmd2mstr_command       =>  sig_cmd2mstr_command      ,     
        cache2mstr_command     =>  sig_cache2mstr_command      ,
        mst2cmd_cmd_valid      =>  sig_cmd2mstr_cmd_valid    ,     
        cmd2mstr_cmd_ready     =>  sig_mst2cmd_cmd_ready     ,     
        mstr2stat_status       =>  sig_wsc2stat_status       ,     
        stat2mstr_status_ready =>  sig_stat2wsc_status_ready ,     
        mst2stst_status_valid  =>  sig_wsc2stat_status_valid       
    
        );
    
    
    
  
  
          
     ------------------------------------------------------------
     -- Instance: I_RD_STATUS_CNTLR 
     --
     -- Description:
     -- Write Status Controller Block    
     --
     ------------------------------------------------------------
      I_WR_STATUS_CNTLR : entity axi_datamover_v5_1.axi_datamover_wr_status_cntl
      generic map (
    
        C_ENABLE_INDET_BTT     =>  OMIT_INDET_BTT              ,  
        C_SF_BYTES_RCVD_WIDTH  =>  SF_BYTES_RCVD_WIDTH         ,  
        C_STS_FIFO_DEPTH       =>  WR_STATUS_CNTL_FIFO_DEPTH   ,
        C_STS_WIDTH            =>  S2MM_STS_WIDTH              ,  
        C_TAG_WIDTH            =>  C_TAG_WIDTH                 ,  
        C_FAMILY               =>  C_FAMILY                       

        )
      port map (
    
        primary_aclk           =>  s2mm_aclk                   ,  
        mmap_reset             =>  sig_mmap_rst                ,  
        rst2wsc_stop_request   =>  sig_rst2all_stop_request    ,  
        wsc2rst_stop_cmplt     =>  sig_wsc2rst_stop_cmplt      ,  
        addr2wsc_addr_posted   =>  sig_addr2data_addr_posted   ,  
        s2mm_bresp             =>  s2mm_bresp                  ,  
        s2mm_bvalid            =>  s2mm_bvalid                 ,  
        s2mm_bready            =>  s2mm_bready                 ,  
        calc2wsc_calc_error    =>  sig_calc2dm_calc_err        ,  
        addr2wsc_calc_error    =>  sig_addr2wsc_calc_error     ,  
        addr2wsc_fifo_empty    =>  sig_addr2wsc_cmd_fifo_empty ,  
        data2wsc_tag           =>  sig_data2wsc_tag            ,  
        data2wsc_calc_error    =>  sig_data2wsc_calc_err       ,  
        data2wsc_last_error    =>  sig_data2wsc_last_err       ,  
        data2wsc_cmd_cmplt     =>  sig_data2wsc_cmd_cmplt      ,  
        data2wsc_valid         =>  sig_data2wsc_valid          ,  
        wsc2data_ready         =>  sig_wsc2data_ready          ,  
        data2wsc_eop           =>  sig_data2wsc_eop            ,  
        data2wsc_bytes_rcvd    =>  sig_data2wsc_bytes_rcvd     ,  
        wsc2stat_status        =>  sig_wsc2stat_status         ,  
        stat2wsc_status_ready  =>  sig_stat2wsc_status_ready   ,  
        wsc2stat_status_valid  =>  sig_wsc2stat_status_valid   ,  
        wsc2mstr_halt_pipe     =>  sig_wsc2mstr_halt_pipe         
      
        );
    
    
    
  
  
          
    ------------------------------------------------------------
    -- Instance: I_MSTR_SCC 
    --
    -- Description:
    -- Simple Command Calculator Block   
    --
    ------------------------------------------------------------
     I_MSTR_SCC : entity axi_datamover_v5_1.axi_datamover_scc
     generic map (
   
       C_SEL_ADDR_WIDTH     =>  SEL_ADDR_WIDTH           ,   
       C_ADDR_WIDTH         =>  S2MM_ADDR_WIDTH          ,   
       C_STREAM_DWIDTH      =>  S2MM_SDATA_WIDTH         ,   
       C_MAX_BURST_LEN      =>  C_S2MM_BURST_SIZE        ,   
       C_CMD_WIDTH          =>  S2MM_CMD_WIDTH           ,   
       C_MICRO_DMA          =>  C_MICRO_DMA              ,
       C_TAG_WIDTH          =>  C_TAG_WIDTH                  
   
       )
     port map (
   
       -- Clock input
       primary_aclk         =>  s2mm_aclk                ,   
       mmap_reset           =>  sig_mmap_rst             ,   
       cmd2mstr_command     =>  sig_cmd2mstr_command     ,   
       cache2mstr_command   =>  sig_cache2mstr_command     ,   
       cmd2mstr_cmd_valid   =>  sig_cmd2mstr_cmd_valid   ,   
       mst2cmd_cmd_ready    =>  sig_mst2cmd_cmd_ready    ,   
       mstr2addr_tag        =>  sig_mstr2addr_tag        ,   
       mstr2addr_addr       =>  sig_mstr2addr_addr       ,   
       mstr2addr_len        =>  sig_mstr2addr_len        ,   
       mstr2addr_size       =>  sig_mstr2addr_size       ,   
       mstr2addr_burst      =>  sig_mstr2addr_burst      ,   
       mstr2addr_cache      =>  sig_mstr2addr_cache      ,   
       mstr2addr_user       =>  sig_mstr2addr_user       ,   
       mstr2addr_calc_error =>  sig_mstr2addr_calc_error ,   
       mstr2addr_cmd_cmplt  =>  sig_mstr2addr_cmd_cmplt  ,   
       mstr2addr_cmd_valid  =>  sig_mstr2addr_cmd_valid  ,   
       addr2mstr_cmd_ready  =>  sig_addr2mstr_cmd_ready  ,   
       mstr2data_tag        =>  sig_mstr2data_tag        ,   
       mstr2data_saddr_lsb  =>  sig_mstr2data_saddr_lsb  ,   
       mstr2data_len        =>  sig_mstr2data_len        ,   
       mstr2data_strt_strb  =>  sig_mstr2data_strt_strb  ,   
       mstr2data_last_strb  =>  sig_mstr2data_last_strb  ,   
       mstr2data_sof        =>  sig_mstr2data_drr        ,   
       mstr2data_eof        =>  sig_mstr2data_eof        ,   
       mstr2data_calc_error =>  sig_mstr2data_calc_error ,   
       mstr2data_cmd_cmplt  =>  sig_mstr2data_cmd_last   ,   
       mstr2data_cmd_valid  =>  sig_mstr2data_cmd_valid  ,   
       data2mstr_cmd_ready  =>  sig_data2mstr_cmd_ready  ,   
       calc_error           =>  sig_calc2dm_calc_err         
       
       );
    
    
    
  
  
          
     ------------------------------------------------------------
     -- Instance: I_ADDR_CNTL 
     --
     -- Description:
     --   Address Controller Block  
     --
     ------------------------------------------------------------
      I_ADDR_CNTL : entity axi_datamover_v5_1.axi_datamover_addr_cntl
      generic map (
    
        -- obsoleted   C_ENABlE_WAIT_FOR_DATA       =>  ENABLE_WAIT_FOR_DATA        ,     
        C_ADDR_FIFO_DEPTH            =>  WR_ADDR_CNTL_FIFO_DEPTH     ,
        --C_ADDR_FIFO_DEPTH            =>  S2MM_STSCMD_FIFO_DEPTH      ,     
        C_ADDR_WIDTH                 =>  S2MM_ADDR_WIDTH             ,     
        C_ADDR_ID                    =>  S2MM_AWID_VALUE             ,     
        C_ADDR_ID_WIDTH              =>  S2MM_AWID_WIDTH             ,     
        C_TAG_WIDTH                  =>  C_TAG_WIDTH                 ,
        C_FAMILY               =>  C_FAMILY     
    
        )
      port map (
    
        primary_aclk                 =>  s2mm_aclk                   ,    
        mmap_reset                   =>  sig_mmap_rst                ,    
        addr2axi_aid                 =>  s2mm_awid                   ,    
        addr2axi_aaddr               =>  s2mm_awaddr                 ,    
        addr2axi_alen                =>  s2mm_awlen                  ,    
        addr2axi_asize               =>  s2mm_awsize                 ,    
        addr2axi_aburst              =>  s2mm_awburst                ,    
        addr2axi_aprot               =>  s2mm_awprot                 ,    
        addr2axi_avalid              =>  s2mm_awvalid                ,    
        addr2axi_acache               =>  open            ,
        addr2axi_auser                =>  open                 ,

        axi2addr_aready              =>  s2mm_awready                ,    
        
        mstr2addr_tag                =>  sig_mstr2addr_tag           ,    
        mstr2addr_addr               =>  sig_mstr2addr_addr          ,    
        mstr2addr_len                =>  sig_mstr2addr_len           ,    
        mstr2addr_size               =>  sig_mstr2addr_size          ,    
        mstr2addr_burst              =>  sig_mstr2addr_burst         ,    
        mstr2addr_cache              =>  sig_mstr2addr_cache         ,    
        mstr2addr_user               =>  sig_mstr2addr_user         ,    
        mstr2addr_cmd_cmplt          =>  sig_mstr2addr_cmd_cmplt     ,    
        mstr2addr_calc_error         =>  sig_mstr2addr_calc_error    ,    
        mstr2addr_cmd_valid          =>  sig_mstr2addr_cmd_valid     ,    
        addr2mstr_cmd_ready          =>  sig_addr2mstr_cmd_ready     ,    
        
        addr2rst_stop_cmplt          =>  sig_addr2rst_stop_cmplt     ,    
 
        allow_addr_req               =>  s2mm_allow_addr_req         ,
        addr_req_posted              =>  s2mm_addr_req_posted        ,
        
        addr2data_addr_posted        =>  sig_addr2data_addr_posted   ,    
        data2addr_data_rdy           =>  sig_data2addr_data_rdy      ,    
        data2addr_stop_req           =>  sig_data2addr_stop_req      ,    
        
        addr2stat_calc_error         =>  sig_addr2wsc_calc_error     ,    
        addr2stat_cmd_fifo_empty     =>  sig_addr2wsc_cmd_fifo_empty      
        );
    
    
    




   
  
ENABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(4) = '1' generate
begin 


      ------------------------------------------------------------
      -- Instance: I_S2MM_STRM_SKID_BUF 
      --
      -- Description:
      --   Instance for the S2MM Skid Buffer which provides for
      -- registerd Slave Stream inputs and supports bi-dir
      -- throttling.  
      --
      ------------------------------------------------------------
      I_S2MM_STRM_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
      generic map (
         
        C_WDATA_WIDTH  =>  S2MM_SDATA_WIDTH        
    
        )
      port map (
    
        -- System Ports
        aclk           =>  s2mm_aclk             ,  
        arst           =>  sig_mmap_rst          ,  
     
        -- Shutdown control (assert for 1 clk pulse)
        skid_stop      =>  sig_data2skid_halt    ,  
     
        -- Slave Side (Stream Data Input) 
        s_valid        =>  s2mm_strm_wvalid      ,  
        s_ready        =>  s2mm_strm_wready      ,  
        s_data         =>  s2mm_strm_wdata       ,  
        s_strb         =>  s2mm_strm_wstrb       ,  
        s_last         =>  s2mm_strm_wlast       ,  

        -- Master Side (Stream Data Output 
        m_valid        =>  skid2wdc_wvalid       ,  
        m_ready        =>  wdc2skid_wready       ,  
        m_data         =>  skid2wdc_wdata        ,  
        m_strb         =>  skid2wdc_wstrb        ,  
        m_last         =>  skid2wdc_wlast           
    
        );
    
       
end generate ENABLE_AXIS_SKID;
  
    
DISABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(4) = '0' generate
begin 

   skid2wdc_wvalid <= s2mm_strm_wvalid;
   s2mm_strm_wready <= wdc2skid_wready;
   skid2wdc_wdata <= s2mm_strm_wdata;
   skid2wdc_wstrb <= s2mm_strm_wstrb;
   skid2wdc_wlast <= s2mm_strm_wlast;
   

end generate DISABLE_AXIS_SKID; 

       

      ------------------------------------------------------------
      -- Instance: I_WR_DATA_CNTL 
      --
      -- Description:
      --     Write Data Controller Block
      --
      ------------------------------------------------------------
      I_WR_DATA_CNTL : entity axi_datamover_v5_1.axi_datamover_wrdata_cntl
      generic map (
    
        -- obsoleted   C_ENABlE_WAIT_FOR_DATA =>  ENABLE_WAIT_FOR_DATA       , 
        C_REALIGNER_INCLUDED   =>  OMIT_S2MM_DRE              , 
        C_ENABLE_INDET_BTT     =>  OMIT_INDET_BTT             , 
        C_SF_BYTES_RCVD_WIDTH  =>  SF_BYTES_RCVD_WIDTH        , 
        C_SEL_ADDR_WIDTH       =>  SEL_ADDR_WIDTH             , 
        C_DATA_CNTL_FIFO_DEPTH =>  WR_DATA_CNTL_FIFO_DEPTH    , 
        C_MMAP_DWIDTH          =>  S2MM_MDATA_WIDTH           , 
        C_STREAM_DWIDTH        =>  S2MM_SDATA_WIDTH           , 
        C_TAG_WIDTH            =>  C_TAG_WIDTH                , 
        C_FAMILY               =>  C_FAMILY                     
    
        )
      port map (
    
        primary_aclk           =>  s2mm_aclk                  , 
        mmap_reset             =>  sig_mmap_rst               , 
        rst2data_stop_request  =>  sig_rst2all_stop_request   , 
        data2addr_stop_req     =>  sig_data2addr_stop_req     , 
        data2rst_stop_cmplt    =>  sig_data2rst_stop_cmplt    , 
        wr_xfer_cmplt          =>  s2mm_wr_xfer_cmplt         ,
        s2mm_ld_nxt_len        =>  s2mm_ld_nxt_len            ,
        s2mm_wr_len            =>  s2mm_wr_len                ,
        data2skid_saddr_lsb    =>  sig_data2skid_addr_lsb     , 
        data2skid_wdata        =>  sig_data2skid_wdata        , 
        data2skid_wstrb        =>  sig_data2skid_wstrb        , 
        data2skid_wlast        =>  sig_data2skid_wlast        , 
        data2skid_wvalid       =>  sig_data2skid_wvalid       , 
        skid2data_wready       =>  sig_skid2data_wready       , 
        s2mm_strm_wvalid       =>  skid2wdc_wvalid            , 
        s2mm_strm_wready       =>  wdc2skid_wready            , 
        s2mm_strm_wdata        =>  skid2wdc_wdata             ,     
        s2mm_strm_wstrb        =>  skid2wdc_wstrb             ,         
        s2mm_strm_wlast        =>  skid2wdc_wlast             , 
        s2mm_strm_eop          =>  skid2wdc_wlast             , 
        s2mm_stbs_asserted     =>  ZEROS_8_BIT                , 
        realign2wdc_eop_error  =>  sig_realign2wdc_eop_error  , 
        mstr2data_tag          =>  sig_mstr2data_tag          , 
        mstr2data_saddr_lsb    =>  sig_mstr2data_saddr_lsb    , 
        mstr2data_len          =>  sig_mstr2data_len          , 
        mstr2data_strt_strb    =>  sig_mstr2data_strt_strb    , 
        mstr2data_last_strb    =>  sig_mstr2data_last_strb    , 
        mstr2data_drr          =>  sig_mstr2data_drr          , 
        mstr2data_eof          =>  sig_mstr2data_eof          , 
        mstr2data_sequential   =>  LOGIC_LOW                  , 
        mstr2data_calc_error   =>  sig_mstr2data_calc_error   , 
        mstr2data_cmd_cmplt    =>  sig_mstr2data_cmd_last     , 
        mstr2data_cmd_valid    =>  sig_mstr2data_cmd_valid    , 
        data2mstr_cmd_ready    =>  sig_data2mstr_cmd_ready    , 
        addr2data_addr_posted  =>  sig_addr2data_addr_posted  , 
        data2addr_data_rdy     =>  sig_data2addr_data_rdy     , 
        data2all_tlast_error   =>  sig_data2all_tlast_error   , 
        data2all_dcntlr_halted =>  sig_data2all_dcntlr_halted , 
        data2skid_halt         =>  sig_data2skid_halt         , 
        data2wsc_tag           =>  sig_data2wsc_tag           , 
        data2wsc_calc_err      =>  sig_data2wsc_calc_err      , 
        data2wsc_last_err      =>  sig_data2wsc_last_err      , 
        data2wsc_cmd_cmplt     =>  sig_data2wsc_cmd_cmplt     , 
        wsc2data_ready         =>  sig_wsc2data_ready         , 
        data2wsc_valid         =>  sig_data2wsc_valid         , 
        data2wsc_eop           =>  sig_data2wsc_eop           , 
        data2wsc_bytes_rcvd    =>  sig_data2wsc_bytes_rcvd    , 
        wsc2mstr_halt_pipe     =>  sig_wsc2mstr_halt_pipe       
       
        );
   
   
    
  
  
          
      ------------------------------------------------------------
      -- Instance: I_S2MM_MMAP_SKID_BUF 
      --
      -- Description:
      --   Instance for the S2MM Skid Buffer which provides for
      -- registered outputs and supports bi-dir throttling. 
      -- 
      -- This Module also provides Write Data Bus Mirroring and WSTRB
      -- Demuxing to match a narrow Stream to a wider MMap Write 
      -- Channel. By doing this in the skid buffer, the resource 
      -- utilization of the skid buffer can be minimized by only
      -- having to buffer/mux the Stream data width, not the MMap
      -- Data width.   
      --
      ------------------------------------------------------------
       I_S2MM_MMAP_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid2mm_buf
       generic map (
          
         C_MDATA_WIDTH    =>  S2MM_MDATA_WIDTH       ,  
         C_SDATA_WIDTH    =>  S2MM_SDATA_WIDTH       ,  
         C_ADDR_LSB_WIDTH =>  SEL_ADDR_WIDTH            
         
         )
       port map (
     
         -- System Ports
         ACLK             =>   s2mm_aclk             ,  
         ARST             =>   sig_stream_rst        ,  
         
         -- Slave Side (Wr Data Controller Input Side ) 
         S_ADDR_LSB       =>   sig_data2skid_addr_lsb,   
         S_VALID          =>   sig_data2skid_wvalid  ,  
         S_READY          =>   sig_skid2data_wready  ,  
         S_Data           =>   sig_data2skid_wdata   ,  
         S_STRB           =>   sig_data2skid_wstrb   ,  
         S_Last           =>   sig_data2skid_wlast   ,  

         -- Master Side (MMap Write Data Output Side) 
         M_VALID          =>   sig_skid2axi_wvalid   ,  
         M_READY          =>   sig_axi2skid_wready   ,  
         M_Data           =>   sig_skid2axi_wdata    ,  
         M_STRB           =>   sig_skid2axi_wstrb    ,  
         M_Last           =>   sig_skid2axi_wlast       
     
         );
                              
                              
                              
                              
                           
  end implementation;
