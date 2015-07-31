  -------------------------------------------------------------------------------
  -- axi_datamover_mm2s_basic_wrap.vhd
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
  -- Filename:        axi_datamover_mm2s_basic_wrap.vhd
  --
  -- Description:     
  --    This file implements the DataMover MM2S Basic Wrapper.                 
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
  use axi_datamover_v5_1.axi_datamover_rddata_cntl;
  use axi_datamover_v5_1.axi_datamover_rd_status_cntl;
  use axi_datamover_v5_1.axi_datamover_skid_buf;
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_mm2s_basic_wrap is
    generic (
      
      C_INCLUDE_MM2S     : Integer range 0 to  2 :=  2;
         -- Specifies the type of MM2S function to include
         -- 0 = Omit MM2S functionality
         -- 1 = Full MM2S Functionality
         -- 2 = Basic MM2S functionality
         
      C_MM2S_ARID        : Integer range 0 to  255 :=  8;
         -- Specifies the constant value to output on 
         -- the ARID output port
         
      C_MM2S_ID_WIDTH    : Integer range 1 to   8 :=  4;
         -- Specifies the width of the MM2S ID port 
         
      C_MM2S_ADDR_WIDTH  : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel 
         -- Address bus
         
      C_MM2S_MDATA_WIDTH : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus
      
      C_MM2S_SDATA_WIDTH : Integer range 8 to 64 :=  32;
         -- Specifies the width of the MM2S Master Stream Data 
         -- Channel data bus
      
      C_INCLUDE_MM2S_STSFIFO    : Integer range 0 to  1 :=  1;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit MM2S Status FIFO
         -- 1 = Include MM2S Status FIFO
         
      C_MM2S_STSCMD_FIFO_DEPTH    : Integer range 1 to 16 :=  1;
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
      
      C_MM2S_BURST_SIZE  : Integer range 2 to  64 :=  16;
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
      C_ENABLE_CACHE_USER    : Integer range 0 to 1 := 1;

      C_ENABLE_SKID_BUF         : string := "11111";

      C_MICRO_DMA         : integer range 0 to 1 := 0;

      C_TAG_WIDTH        : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field
         
      C_FAMILY           : String := "virtex7"
         -- Specifies the target FPGA family type
      
      );
    port (
      
      
      -- MM2S Primary Clock and Reset inputs -----------------------
      mm2s_aclk          : in  std_logic;                         --
         -- Primary synchronization clock for the Master side     --
         -- interface and internal logic. It is also used         --
         -- for the User interface synchronization when           --
         -- C_STSCMD_IS_ASYNC = 0.                                --
                                                                  --
      -- MM2S Primary Reset input                                 --
      mm2s_aresetn       : in  std_logic;                         --
         -- Reset used for the internal master logic              --
      --------------------------------------------------------------
     
      -- MM2S Halt request input control ---------------------------
      mm2s_halt          : in  std_logic;                         --
         -- Active high soft shutdown request                     --
                                                                  --
      -- MM2S Halt Complete status flag                           --
      mm2s_halt_cmplt    : Out  std_logic;                        --
         -- Active high soft shutdown complete status             --
      --------------------------------------------------------------
      
      
      
      -- Error discrete output -------------------------------------
      mm2s_err           : Out std_logic;                         --
         -- Composite Error indication                            --
      --------------------------------------------------------------
     
     
     
      -- Optional MM2S Command and Status Clock and Reset ----------
      -- These are used when C_MM2S_STSCMD_IS_ASYNC = 1           --
      mm2s_cmdsts_awclk   : in  std_logic;                        --
      -- Secondary Clock input for async CMD/Status interface     --
                                                                  --
      mm2s_cmdsts_aresetn : in  std_logic;                        --
        -- Secondary Reset input for async CMD/Status interface   --
      --------------------------------------------------------------
      
      
      
      -- User Command Interface Ports (AXI Stream) -------------------------------------------------
      mm2s_cmd_wvalid     : in  std_logic;                                                        --
      mm2s_cmd_wready     : out std_logic;                                                        --
      mm2s_cmd_wdata      : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_MM2S_ADDR_WIDTH+36)-1 downto 0);  --
      ----------------------------------------------------------------------------------------------
     
      
      -- User Status Interface Ports (AXI Stream) -----------------
      mm2s_sts_wvalid     : out std_logic;                       --
      mm2s_sts_wready     : in  std_logic;                       --
      mm2s_sts_wdata      : out std_logic_vector(7 downto 0);    --
      mm2s_sts_wstrb      : out std_logic_vector(0 downto 0);    --
      mm2s_sts_wlast      : out std_logic;                       --
      -------------------------------------------------------------
      
      
      -- Address Posting contols ----------------------------------
      mm2s_allow_addr_req  : in  std_logic;                      --
      mm2s_addr_req_posted : out std_logic;                      --
      mm2s_rd_xfer_cmplt   : out std_logic;                      --
      -------------------------------------------------------------
      
                                                              
                                                              
      
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
      
      
        
      -- Currently unsupported AXI Address Channel output signals -------
        -- addr2axi_alock   : out std_logic_vector(2 downto 0);        --
        -- addr2axi_acache  : out std_logic_vector(4 downto 0);        --
        -- addr2axi_aqos    : out std_logic_vector(3 downto 0);        --
        -- addr2axi_aregion : out std_logic_vector(3 downto 0);        --
      -------------------------------------------------------------------
  
  
      
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
  
      
      -- Testing Support I/O --------------------------------------------
      mm2s_dbg_sel            : in  std_logic_vector( 3 downto 0);     --
      mm2s_dbg_data           : out std_logic_vector(31 downto 0)      --
      -------------------------------------------------------------------
      
      
      );
  
  end entity axi_datamover_mm2s_basic_wrap;
  
  
  architecture implementation of axi_datamover_mm2s_basic_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Function Declarations   ----------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_calc_rdmux_sel_bits
    --
    -- Function Description:
    --  This function calculates the number of address bits needed for  
    -- the Read data mux select control. 
    --
    -------------------------------------------------------------------
    function func_calc_rdmux_sel_bits (mmap_dwidth_value : integer) return integer is
    
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
       
    end function func_calc_rdmux_sel_bits;
    
     
     
     
    -- Constant Declarations   ----------------------------------------
    
     Constant LOGIC_LOW               : std_logic := '0';
     Constant LOGIC_HIGH              : std_logic := '1';
     Constant INCLUDE_MM2S            : integer range  0 to   2 :=  2;
     Constant MM2S_ARID_VALUE         : integer range  0 to 255 := C_MM2S_ARID;
     Constant MM2S_ARID_WIDTH         : integer range  1 to  8  := C_MM2S_ID_WIDTH;
     Constant MM2S_ADDR_WIDTH         : integer range 32 to  64 := C_MM2S_ADDR_WIDTH;
     Constant MM2S_MDATA_WIDTH        : integer range 32 to 256 := C_MM2S_MDATA_WIDTH;
     Constant MM2S_SDATA_WIDTH        : integer range  8 to 256 := C_MM2S_SDATA_WIDTH;
     Constant MM2S_CMD_WIDTH          : integer                 := (C_TAG_WIDTH+C_MM2S_ADDR_WIDTH+32);
     Constant MM2S_STS_WIDTH          : integer                 := 8; -- always 8 for MM2S
     Constant INCLUDE_MM2S_STSFIFO    : integer range  0 to   1 :=  1;
     Constant MM2S_STSCMD_FIFO_DEPTH  : integer range  1 to  64 :=  C_MM2S_STSCMD_FIFO_DEPTH;
     Constant MM2S_STSCMD_IS_ASYNC    : integer range  0 to   1 :=  C_MM2S_STSCMD_IS_ASYNC;
     Constant INCLUDE_MM2S_DRE        : integer range  0 to   1 :=  0;
     Constant DRE_ALIGN_WIDTH         : integer range  1 to   3 :=  2;
     Constant MM2S_BURST_SIZE         : integer range 16 to 256 := 16;
     Constant RD_ADDR_CNTL_FIFO_DEPTH : integer range  1 to  30 := C_MM2S_ADDR_PIPE_DEPTH;  
     Constant RD_DATA_CNTL_FIFO_DEPTH : integer range  1 to  30 := C_MM2S_ADDR_PIPE_DEPTH; 
     Constant SEL_ADDR_WIDTH          : integer := func_calc_rdmux_sel_bits(MM2S_MDATA_WIDTH);
     Constant DRE_ALIGN_ZEROS         : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     -- obsoleted   Constant DISABLE_WAIT_FOR_DATA   : integer := 0;
     
        
    
    -- Signal Declarations  ------------------------------------------
    
     signal sig_cmd_stat_rst_user        : std_logic := '0';
     signal sig_cmd_stat_rst_int         : std_logic := '0';
     signal sig_mmap_rst                 : std_logic := '0';
     signal sig_stream_rst               : std_logic := '0';
     signal sig_mm2s_cmd_wdata           : std_logic_vector(MM2S_CMD_WIDTH-1 downto 0);        
     signal sig_mm2s_cache_data          : std_logic_vector(7 downto 0);        
     signal sig_cmd2mstr_command         : std_logic_vector(MM2S_CMD_WIDTH-1 downto 0) := (others => '0');        
     signal sig_cmd2mstr_cmd_valid       : std_logic := '0';                                             
     signal sig_mst2cmd_cmd_ready        : std_logic := '0';                                             
     signal sig_mstr2addr_addr           : std_logic_vector(MM2S_ADDR_WIDTH-1 downto 0) := (others => '0');             
     signal sig_mstr2addr_len            : std_logic_vector(7 downto 0) := (others => '0');                          
     signal sig_mstr2addr_size           : std_logic_vector(2 downto 0) := (others => '0');                          
     signal sig_mstr2addr_burst          : std_logic_vector(1 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cache          : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_user          : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cmd_cmplt      : std_logic := '0';
     signal sig_mstr2addr_calc_error     : std_logic := '0';
     signal sig_mstr2addr_cmd_valid      : std_logic := '0';                                             
     signal sig_addr2mstr_cmd_ready      : std_logic := '0';                                              
     signal sig_mstr2data_saddr_lsb      : std_logic_vector(SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2data_len            : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_mstr2data_strt_strb      : std_logic_vector((MM2S_SDATA_WIDTH/8)-1 downto 0) := (others => '0');      
     signal sig_mstr2data_last_strb      : std_logic_vector((MM2S_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_mstr2data_drr            : std_logic := '0';
     signal sig_mstr2data_eof            : std_logic := '0';
     signal sig_mstr2data_sequential     : std_logic := '0';
     signal sig_mstr2data_calc_error     : std_logic := '0';
     signal sig_mstr2data_cmd_cmplt      : std_logic := '0';
     signal sig_mstr2data_cmd_valid      : std_logic := '0';                                             
     signal sig_data2mstr_cmd_ready      : std_logic := '0';                                               
     signal sig_addr2data_addr_posted    : std_logic := '0';
     signal sig_data2all_dcntlr_halted   : std_logic := '0';
     signal sig_addr2rsc_calc_error      : std_logic := '0';
     signal sig_addr2rsc_cmd_fifo_empty  : std_logic := '0';
     signal sig_data2rsc_tag             : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2rsc_calc_err        : std_logic := '0';                     
     signal sig_data2rsc_okay            : std_logic := '0';
     signal sig_data2rsc_decerr          : std_logic := '0';
     signal sig_data2rsc_slverr          : std_logic := '0';
     signal sig_data2rsc_cmd_cmplt       : std_logic := '0';
     signal sig_rsc2data_ready           : std_logic := '0';
     signal sig_data2rsc_valid           : std_logic := '0';
     signal sig_calc2dm_calc_err         : std_logic := '0';
     signal sig_data2skid_wvalid         : std_logic := '0';                                     
     signal sig_data2skid_wready         : std_logic := '0';                                     
     signal sig_data2skid_wdata          : std_logic_vector(MM2S_SDATA_WIDTH-1 downto 0) := (others => '0');     
     signal sig_data2skid_wstrb          : std_logic_vector((MM2S_SDATA_WIDTH/8)-1 downto 0) := (others => '0'); 
     signal sig_data2skid_wlast          : std_logic := '0';                                     
     signal sig_rsc2stat_status          : std_logic_vector(MM2S_STS_WIDTH-1 downto 0) := (others => '0');
     signal sig_stat2rsc_status_ready    : std_logic := '0';   
     signal sig_rsc2stat_status_valid    : std_logic := '0';  
     signal sig_rsc2mstr_halt_pipe       : std_logic := '0';  
     signal sig_mstr2data_tag            : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2addr_tag            : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_dbg_data_mux_out         : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_0               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_1               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_rst2all_stop_request     : std_logic := '0';
     signal sig_data2rst_stop_cmplt      : std_logic := '0';
     signal sig_addr2rst_stop_cmplt      : std_logic := '0';
     signal sig_data2addr_stop_req       : std_logic := '0';
     signal sig_data2skid_halt           : std_logic := '0';

    signal sig_cache2mstr_command       : std_logic_vector (7 downto 0);
     signal mm2s_arcache_int             : std_logic_vector (3 downto 0);

    
    
    
  begin --(architecture implementation)
 
 
  
    -- Debug Support ------------------------------------------
    
    mm2s_dbg_data  <= sig_dbg_data_mux_out;
    
    
    -- Note that only the mm2s_dbg_sel(0) is used at this time
    sig_dbg_data_mux_out <= sig_dbg_data_1
      When (mm2s_dbg_sel(0) = '1')
      else sig_dbg_data_0 ;
    
    
    sig_dbg_data_0              <=  X"BEEF2222"             ;    -- 32 bit Constant indicating MM2S Basic type
    
    sig_dbg_data_1(0)           <= sig_cmd_stat_rst_user    ;
    sig_dbg_data_1(1)           <= sig_cmd_stat_rst_int     ;
    sig_dbg_data_1(2)           <= sig_mmap_rst             ;
    sig_dbg_data_1(3)           <= sig_stream_rst           ;
    sig_dbg_data_1(4)           <= sig_cmd2mstr_cmd_valid   ;
    sig_dbg_data_1(5)           <= sig_mst2cmd_cmd_ready    ;
    sig_dbg_data_1(6)           <= sig_stat2rsc_status_ready;
    sig_dbg_data_1(7)           <= sig_rsc2stat_status_valid;
    sig_dbg_data_1(11 downto 8) <= sig_data2rsc_tag         ; -- Current TAG of active data transfer
                        

    sig_dbg_data_1(15 downto 12) <= sig_rsc2stat_status(3 downto 0); -- Internal status tag field
    sig_dbg_data_1(16)           <= sig_rsc2stat_status(4)         ; -- Internal error
    sig_dbg_data_1(17)           <= sig_rsc2stat_status(5)         ; -- Decode Error
    sig_dbg_data_1(18)           <= sig_rsc2stat_status(6)         ; -- Slave Error
    sig_dbg_data_1(19)           <= sig_rsc2stat_status(7)         ; -- OKAY
    sig_dbg_data_1(20)           <= sig_stat2rsc_status_ready      ; -- Status Ready Handshake
    sig_dbg_data_1(21)           <= sig_rsc2stat_status_valid      ; -- Status Valid Handshake
                        
    
    -- Spare bits in debug1
    sig_dbg_data_1(31 downto 22) <= (others => '0')                ; -- spare bits
                        
                        
                        
                        
                        
    
    GEN_CACHE : if (C_ENABLE_CACHE_USER = 0) generate

       begin
 
    -- Cache signal tie-off
    mm2s_arcache       <= "0011";  -- Per Interface-X guidelines for Masters
    mm2s_aruser        <= "0000";  -- Per Interface-X guidelines for Masters
    sig_mm2s_cache_data <= (others => '0'); --mm2s_cmd_wdata(103 downto 96);
     
       end generate GEN_CACHE;                 


    GEN_CACHE2 : if (C_ENABLE_CACHE_USER = 1) generate

       begin
 
    -- Cache signal tie-off
    mm2s_arcache       <= "0011"; --sg_ctl (3 downto 0);  -- SG Cache from register
    mm2s_aruser        <= "0000";--sg_ctl (7 downto 4);  -- Per Interface-X guidelines for Masters
  --  sig_mm2s_cache_data <= mm2s_cmd_wdata(103 downto 96);
    sig_mm2s_cache_data <= mm2s_cmd_wdata(79 downto 72);
     
       end generate GEN_CACHE2;                 
    
    -- Cache signal tie-off
     
                        
                       
    -- Internal error output discrete ------------------------------
    mm2s_err                <=  sig_calc2dm_calc_err;
     
     
    -- Rip the used portion of the Command Interface Command Data
    -- and throw away the padding
    sig_mm2s_cmd_wdata <= mm2s_cmd_wdata(MM2S_CMD_WIDTH-1 downto 0);
     
     
          
   ------------------------------------------------------------
   -- Instance: I_RESET 
   --
   -- Description:
   --   Reset Block  
   --
   ------------------------------------------------------------
    I_RESET : entity axi_datamover_v5_1.axi_datamover_reset
    generic map (
  
      C_STSCMD_IS_ASYNC    =>  MM2S_STSCMD_IS_ASYNC       
  
      )
    port map (
  
      primary_aclk         =>  mm2s_aclk                , 
      primary_aresetn      =>  mm2s_aresetn             , 
      secondary_awclk      =>  mm2s_cmdsts_awclk        , 
      secondary_aresetn    =>  mm2s_cmdsts_aresetn      , 
      halt_req             =>  mm2s_halt                , 
      halt_cmplt           =>  mm2s_halt_cmplt          , 
      flush_stop_request   =>  sig_rst2all_stop_request , 
      data_cntlr_stopped   =>  sig_data2rst_stop_cmplt  , 
      addr_cntlr_stopped   =>  sig_addr2rst_stop_cmplt  , 
      aux1_stopped         =>  LOGIC_HIGH               , 
      aux2_stopped         =>  LOGIC_HIGH               , 
      cmd_stat_rst_user    =>  sig_cmd_stat_rst_user    , 
      cmd_stat_rst_int     =>  sig_cmd_stat_rst_int     , 
      mmap_rst             =>  sig_mmap_rst             , 
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
  
      C_ADDR_WIDTH           =>  MM2S_ADDR_WIDTH           ,    
      C_INCLUDE_STSFIFO      =>  INCLUDE_MM2S_STSFIFO      ,    
      C_STSCMD_FIFO_DEPTH    =>  MM2S_STSCMD_FIFO_DEPTH    ,    
      C_STSCMD_IS_ASYNC      =>  MM2S_STSCMD_IS_ASYNC      ,    
      C_CMD_WIDTH            =>  MM2S_CMD_WIDTH            ,    
      C_STS_WIDTH            =>  MM2S_STS_WIDTH            ,    
      C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER       ,
      C_FAMILY               =>  C_FAMILY                      

      )
    port map (
  
      primary_aclk           =>  mm2s_aclk                 ,   
      secondary_awclk        =>  mm2s_cmdsts_awclk         ,   
      user_reset             =>  sig_cmd_stat_rst_user     ,   
      internal_reset         =>  sig_cmd_stat_rst_int      ,   
      cmd_wvalid             =>  mm2s_cmd_wvalid           ,   
      cmd_wready             =>  mm2s_cmd_wready           ,   
      cmd_wdata              =>  sig_mm2s_cmd_wdata        ,   
      cache_data             =>  sig_mm2s_cache_data       ,
      sts_wvalid             =>  mm2s_sts_wvalid           ,   
      sts_wready             =>  mm2s_sts_wready           ,   
      sts_wdata              =>  mm2s_sts_wdata            ,   
      sts_wstrb              =>  mm2s_sts_wstrb            ,   
      sts_wlast              =>  mm2s_sts_wlast            ,   
      cmd2mstr_command       =>  sig_cmd2mstr_command      ,   
      mst2cmd_cmd_valid      =>  sig_cmd2mstr_cmd_valid    ,   
      cmd2mstr_cmd_ready     =>  sig_mst2cmd_cmd_ready     ,   
      mstr2stat_status       =>  sig_rsc2stat_status       ,   
      stat2mstr_status_ready =>  sig_stat2rsc_status_ready ,   
      mst2stst_status_valid  =>  sig_rsc2stat_status_valid     
  
      );
  
  
  


        
   ------------------------------------------------------------
   -- Instance: I_RD_STATUS_CNTLR 
   --
   -- Description:
   -- Read Status Controller Block    
   --
   ------------------------------------------------------------
    I_RD_STATUS_CNTLR : entity axi_datamover_v5_1.axi_datamover_rd_status_cntl
    generic map (
  
      C_STS_WIDTH            =>  MM2S_STS_WIDTH              , 
      C_TAG_WIDTH            =>  C_TAG_WIDTH                   

      )
    port map (
  
      primary_aclk           =>  mm2s_aclk                   , 
      mmap_reset             =>  sig_mmap_rst                , 
      calc2rsc_calc_error    =>  sig_calc2dm_calc_err        , 
      addr2rsc_calc_error    =>  sig_addr2rsc_calc_error     , 
      addr2rsc_fifo_empty    =>  sig_addr2rsc_cmd_fifo_empty , 
      data2rsc_tag           =>  sig_data2rsc_tag            , 
      data2rsc_calc_error    =>  sig_data2rsc_calc_err       , 
      data2rsc_okay          =>  sig_data2rsc_okay           , 
      data2rsc_decerr        =>  sig_data2rsc_decerr         , 
      data2rsc_slverr        =>  sig_data2rsc_slverr         , 
      data2rsc_cmd_cmplt     =>  sig_data2rsc_cmd_cmplt      , 
      rsc2data_ready         =>  sig_rsc2data_ready          , 
      data2rsc_valid         =>  sig_data2rsc_valid          , 
      rsc2stat_status        =>  sig_rsc2stat_status         , 
      stat2rsc_status_ready  =>  sig_stat2rsc_status_ready   , 
      rsc2stat_status_valid  =>  sig_rsc2stat_status_valid   , 
      rsc2mstr_halt_pipe     =>  sig_rsc2mstr_halt_pipe        
    
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
     C_ADDR_WIDTH         =>  MM2S_ADDR_WIDTH          , 
     C_STREAM_DWIDTH      =>  MM2S_SDATA_WIDTH         , 
     C_MAX_BURST_LEN      =>  C_MM2S_BURST_SIZE        , 
     C_CMD_WIDTH          =>  MM2S_CMD_WIDTH           , 
     C_MICRO_DMA          =>  C_MICRO_DMA              ,
     C_TAG_WIDTH          =>  C_TAG_WIDTH                
 
     )
   port map (
 
     -- Clock input
     primary_aclk         =>  mm2s_aclk                , 
     mmap_reset           =>  sig_mmap_rst             , 
     cmd2mstr_command     =>  sig_cmd2mstr_command     , 
     cache2mstr_command     =>  sig_cache2mstr_command     , 
     cmd2mstr_cmd_valid   =>  sig_cmd2mstr_cmd_valid   , 
     mst2cmd_cmd_ready    =>  sig_mst2cmd_cmd_ready    , 
     mstr2addr_tag        =>  sig_mstr2addr_tag        , 
     mstr2addr_addr       =>  sig_mstr2addr_addr       , 
     mstr2addr_len        =>  sig_mstr2addr_len        , 
     mstr2addr_size       =>  sig_mstr2addr_size       , 
     mstr2addr_burst      =>  sig_mstr2addr_burst      , 
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
     mstr2data_cmd_cmplt  =>  sig_mstr2data_cmd_cmplt  , 
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
  
      -- obsoleted   C_ENABlE_WAIT_FOR_DATA   =>  DISABLE_WAIT_FOR_DATA       ,  
      --C_ADDR_FIFO_DEPTH        =>  MM2S_STSCMD_FIFO_DEPTH      ,  
      C_ADDR_FIFO_DEPTH        =>  RD_ADDR_CNTL_FIFO_DEPTH     ,
      C_ADDR_WIDTH             =>  MM2S_ADDR_WIDTH             ,  
      C_ADDR_ID                =>  MM2S_ARID_VALUE             ,  
      C_ADDR_ID_WIDTH          =>  MM2S_ARID_WIDTH             ,  
      C_TAG_WIDTH              =>  C_TAG_WIDTH                 ,    
      C_FAMILY               =>  C_FAMILY
  
      )
    port map (
  
      primary_aclk             =>  mm2s_aclk                   ,  
      mmap_reset               =>  sig_mmap_rst                ,  
      addr2axi_aid             =>  mm2s_arid                   ,  
      addr2axi_aaddr           =>  mm2s_araddr                 ,  
      addr2axi_alen            =>  mm2s_arlen                  ,  
      addr2axi_asize           =>  mm2s_arsize                 ,  
      addr2axi_aburst          =>  mm2s_arburst                ,  
      addr2axi_aprot           =>  mm2s_arprot                 ,  
      addr2axi_avalid          =>  mm2s_arvalid                ,  
      addr2axi_acache           =>  open                        , 
      addr2axi_auser            =>  open                        , 
      axi2addr_aready          =>  mm2s_arready                ,  
      
      mstr2addr_tag            =>  sig_mstr2addr_tag           ,  
      mstr2addr_addr           =>  sig_mstr2addr_addr          ,  
      mstr2addr_len            =>  sig_mstr2addr_len           ,  
      mstr2addr_size           =>  sig_mstr2addr_size          ,  
      mstr2addr_burst          =>  sig_mstr2addr_burst         ,  
      mstr2addr_cache          =>  sig_mstr2addr_cache         ,  
      mstr2addr_user           =>  sig_mstr2addr_user          ,  
      mstr2addr_cmd_cmplt      =>  sig_mstr2addr_cmd_cmplt     ,  
      mstr2addr_calc_error     =>  sig_mstr2addr_calc_error    ,  
      mstr2addr_cmd_valid      =>  sig_mstr2addr_cmd_valid     ,  
      addr2mstr_cmd_ready      =>  sig_addr2mstr_cmd_ready     ,  
      
      addr2rst_stop_cmplt      =>  sig_addr2rst_stop_cmplt     ,  
       
      allow_addr_req           =>  mm2s_allow_addr_req         ,
      addr_req_posted          =>  mm2s_addr_req_posted        ,
       
      addr2data_addr_posted    =>  sig_addr2data_addr_posted   ,  
      data2addr_data_rdy       =>  LOGIC_LOW                   ,  
      data2addr_stop_req       =>  sig_data2addr_stop_req      ,  
      
      addr2stat_calc_error     =>  sig_addr2rsc_calc_error     ,  
      addr2stat_cmd_fifo_empty =>  sig_addr2rsc_cmd_fifo_empty    
      );
  
  
  


        
    ------------------------------------------------------------
    -- Instance: I_RD_DATA_CNTL 
    --
    -- Description:
    --     Read Data Controller Block
    --
    ------------------------------------------------------------
     I_RD_DATA_CNTL : entity axi_datamover_v5_1.axi_datamover_rddata_cntl
     generic map (
   
       C_INCLUDE_DRE           =>  INCLUDE_MM2S_DRE         ,  
       C_ALIGN_WIDTH           =>  DRE_ALIGN_WIDTH          ,  
       C_SEL_ADDR_WIDTH        =>  SEL_ADDR_WIDTH           ,  
       C_DATA_CNTL_FIFO_DEPTH  =>  RD_DATA_CNTL_FIFO_DEPTH  ,  
       C_MMAP_DWIDTH           =>  MM2S_MDATA_WIDTH         ,  
       C_STREAM_DWIDTH         =>  MM2S_SDATA_WIDTH         ,  
       C_TAG_WIDTH             =>  C_TAG_WIDTH              ,  
       C_FAMILY                =>  C_FAMILY                    
   
       )
     port map (
   
       -- Clock and Reset  -----------------------------------
       primary_aclk           =>  mm2s_aclk                 ,  
       mmap_reset             =>  sig_mmap_rst              ,  
     
       -- Soft Shutdown Interface -----------------------------
       rst2data_stop_request  =>  sig_rst2all_stop_request  ,  
       data2addr_stop_req     =>  sig_data2addr_stop_req    ,  
       data2rst_stop_cmplt    =>  sig_data2rst_stop_cmplt   ,  
        
       -- External Address Pipelining Contol support
       mm2s_rd_xfer_cmplt     =>  mm2s_rd_xfer_cmplt        ,
        
        
       -- AXI Read Data Channel I/O  -------------------------------
       mm2s_rdata             =>  mm2s_rdata                ,   
       mm2s_rresp             =>  mm2s_rresp                ,   
       mm2s_rlast             =>  mm2s_rlast                ,   
       mm2s_rvalid            =>  mm2s_rvalid               ,   
       mm2s_rready            =>  mm2s_rready               ,   
       
       -- MM2S DRE Control  -----------------------------------
       mm2s_dre_new_align     =>  open                      ,   
       mm2s_dre_use_autodest  =>  open                      ,   
       mm2s_dre_src_align     =>  open                      ,   
       mm2s_dre_dest_align    =>  open                      ,   
       mm2s_dre_flush         =>  open                      ,   
       
       -- AXI Master Stream  -----------------------------------
       mm2s_strm_wvalid       =>  sig_data2skid_wvalid      ,  
       mm2s_strm_wready       =>  sig_data2skid_wready      ,  
       mm2s_strm_wdata        =>  sig_data2skid_wdata       ,       
       mm2s_strm_wstrb        =>  sig_data2skid_wstrb       ,           
       mm2s_strm_wlast        =>  sig_data2skid_wlast       ,  
  
      -- MM2S Store and Forward Supplimental Control -----------
       mm2s_data2sf_cmd_cmplt  => open                      ,                               
                                                                                     
  
       
       -- Command Calculator Interface --------------------------
       mstr2data_tag          =>  sig_mstr2data_tag         ,  
       mstr2data_saddr_lsb    =>  sig_mstr2data_saddr_lsb   ,  
       mstr2data_len          =>  sig_mstr2data_len         ,  
       mstr2data_strt_strb    =>  sig_mstr2data_strt_strb   ,  
       mstr2data_last_strb    =>  sig_mstr2data_last_strb   ,  
       mstr2data_drr          =>  sig_mstr2data_drr         ,  
       mstr2data_eof          =>  sig_mstr2data_eof         ,  
       mstr2data_sequential   =>  LOGIC_LOW                 ,  
       mstr2data_calc_error   =>  sig_mstr2data_calc_error  ,  
       mstr2data_cmd_cmplt    =>  sig_mstr2data_cmd_cmplt   ,  
       mstr2data_cmd_valid    =>  sig_mstr2data_cmd_valid   ,  
       data2mstr_cmd_ready    =>  sig_data2mstr_cmd_ready   ,  
       mstr2data_dre_src_align  => DRE_ALIGN_ZEROS          ,  
       mstr2data_dre_dest_align => DRE_ALIGN_ZEROS          ,  
       
       -- Address Controller Interface --------------------------
       addr2data_addr_posted  =>  sig_addr2data_addr_posted , 
       
       -- Data Controller Halted Status
       data2all_dcntlr_halted =>  sig_data2all_dcntlr_halted, 
        
       -- Output Stream Skid Buffer Halt control
       data2skid_halt         =>  sig_data2skid_halt        , 
        
        
       -- Read Status Controller Interface --------------------------
       data2rsc_tag           =>  sig_data2rsc_tag          , 
       data2rsc_calc_err      =>  sig_data2rsc_calc_err     , 
       data2rsc_okay          =>  sig_data2rsc_okay         , 
       data2rsc_decerr        =>  sig_data2rsc_decerr       , 
       data2rsc_slverr        =>  sig_data2rsc_slverr       , 
       data2rsc_cmd_cmplt     =>  sig_data2rsc_cmd_cmplt    , 
       rsc2data_ready         =>  sig_rsc2data_ready        , 
       data2rsc_valid         =>  sig_data2rsc_valid        , 
       rsc2mstr_halt_pipe     =>  sig_rsc2mstr_halt_pipe      
        
       );
  
  
  

ENABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(5) = '1' generate
begin 
        
    ------------------------------------------------------------
    -- Instance: I_MM2S_SKID_BUF 
    --
    -- Description:
    --   Instance for the MM2S Skid Buffer which provides for
    -- registerd Master Stream outputs and supports bi-dir
    -- throttling.  
    --
    ------------------------------------------------------------
     I_MM2S_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
     generic map (
        
       C_WDATA_WIDTH  =>  MM2S_SDATA_WIDTH        
   
       )
     port map (
   
       -- System Ports
       aclk           =>  mm2s_aclk             ,  
       arst           =>  sig_stream_rst        ,  
     
        -- Shutdown control (assert for 1 clk pulse)
       skid_stop      =>  sig_data2skid_halt    ,  
     
       -- Slave Side (Stream Data Input) 
       s_valid        =>  sig_data2skid_wvalid  ,  
       s_ready        =>  sig_data2skid_wready  ,  
       s_data         =>  sig_data2skid_wdata   ,  
       s_strb         =>  sig_data2skid_wstrb   ,  
       s_last         =>  sig_data2skid_wlast   ,  

       -- Master Side (Stream Data Output 
       m_valid        =>  mm2s_strm_wvalid      ,  
       m_ready        =>  mm2s_strm_wready      ,  
       m_data         =>  mm2s_strm_wdata       ,  
       m_strb         =>  mm2s_strm_wstrb       ,  
       m_last         =>  mm2s_strm_wlast          
   
       );
   
end generate ENABLE_AXIS_SKID;
  
    
DISABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(5) = '0' generate
begin 

   mm2s_strm_wvalid <= sig_data2skid_wvalid;
   sig_data2skid_wready <= mm2s_strm_wready;
   mm2s_strm_wdata <= sig_data2skid_wdata;
   mm2s_strm_wstrb <= sig_data2skid_wstrb; 
   mm2s_strm_wlast <= sig_data2skid_wlast;
   

end generate DISABLE_AXIS_SKID; 
    
  end implementation;
