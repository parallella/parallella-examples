  -------------------------------------------------------------------------------
  -- axi_datamover_rddata_cntl.vhd
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
  -- Filename:        axi_datamover_rddata_cntl.vhd
  --
  -- Description:     
  --    This file implements the DataMover Master Read Data Controller.                 
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
  use axi_datamover_v5_1.axi_datamover_rdmux;  
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_rddata_cntl is
    generic (
      
      C_INCLUDE_DRE          : Integer range  0 to   1 :=  0;
        -- Indicates if the DRE interface is used
        
      C_ALIGN_WIDTH          : Integer range  1 to   3 :=  3;
        -- Sets the width of the DRE Alignment controls
        
      C_SEL_ADDR_WIDTH       : Integer range  1 to   8 :=  5;
        -- Sets the width of the LS bits of the transfer address that
        -- are being used to Mux read data from a wider AXI4 Read
        -- Data Bus
        
      C_DATA_CNTL_FIFO_DEPTH : Integer range  1 to  32 :=  4;
        -- Sets the depth of the internal command fifo used for the
        -- command queue
        
      C_MMAP_DWIDTH          : Integer range 32 to 1024 := 32;
        -- Indicates the native data width of the Read Data port
        
      C_STREAM_DWIDTH        : Integer range  8 to 1024 := 32;
        -- Sets the width of the Stream output data port
        
      C_TAG_WIDTH            : Integer range  1 to   8 :=  4;
        -- Indicates the width of the Tag field of the input command

    C_ENABLE_MM2S_TKEEP             : integer range 0 to 1 := 1; 
        
      C_FAMILY               : String                  := "virtex7"
        -- Indicates the device family of the target FPGA
        
      
      );
    port (
      
      -- Clock and Reset inputs ----------------------------------------
                                                                      --
      primary_aclk          : in  std_logic;                          --
         -- Primary synchronization clock for the Master side         --
         -- interface and internal logic. It is also used             --
         -- for the User interface synchronization when               --
         -- C_STSCMD_IS_ASYNC = 0.                                    --
                                                                      --
      -- Reset input                                                  --
      mmap_reset            : in  std_logic;                          --
         -- Reset used for the internal master logic                  --
      ------------------------------------------------------------------
      
     
      
      -- Soft Shutdown internal interface -----------------------------------
                                                                           --
      rst2data_stop_request : in  std_logic;                               --
         -- Active high soft stop request to modules                       --
                                                                           --
      data2addr_stop_req    : Out std_logic;                               --
        -- Active high signal requesting the Address Controller            --
        -- to stop posting commands to the AXI Read Address Channel        --
                                                                           --
      data2rst_stop_cmplt   : Out std_logic;                               --
        -- Active high indication that the Data Controller has completed   --
        -- any pending transfers committed by the Address Controller       --
        -- after a stop has been requested by the Reset module.            --
      -----------------------------------------------------------------------
   
   
        
      -- External Address Pipelining Contol support -------------------------
                                                                           --
      mm2s_rd_xfer_cmplt    : out std_logic;                               --
        -- Active high indication that the Data Controller has completed   --
        -- a single read data transfer on the AXI4 Read Data Channel.      --
        -- This signal escentially echos the assertion of rlast received   --
        -- from the AXI4.                                                  --
      -----------------------------------------------------------------------
      
      
      
        
     -- AXI Read Data Channel I/O  ---------------------------------------------
                                                                              --
      mm2s_rdata            : In  std_logic_vector(C_MMAP_DWIDTH-1 downto 0); --
        -- AXI Read data input                                                --
                                                                              --
      mm2s_rresp            : In  std_logic_vector(1 downto 0);               --
        -- AXI Read response input                                            --
                                                                              --
      mm2s_rlast            : In  std_logic;                                  --
        -- AXI Read LAST input                                                --
                                                                              --
      mm2s_rvalid           : In  std_logic;                                  --
        -- AXI Read VALID input                                               --
                                                                              --
      mm2s_rready           : Out std_logic;                                  --
        -- AXI Read data READY output                                         --
      --------------------------------------------------------------------------
               
                
                
                
     -- MM2S DRE Control  -------------------------------------------------------------
                                                                                     --
      mm2s_dre_new_align      : Out std_logic;                                       --
        -- Active high signal indicating new DRE aligment required                   --
                                                                                     --
      mm2s_dre_use_autodest   : Out std_logic;                                       --
        -- Active high signal indicating to the DRE to use an auto-                  --
        -- calculated desination alignment based on the last transfer                --
                                                                                     --
      mm2s_dre_src_align      : Out std_logic_vector(C_ALIGN_WIDTH-1 downto 0);      --
        -- Bit field indicating the byte lane of the first valid data byte           --
        -- being sent to the DRE                                                     --
                                                                                     --
      mm2s_dre_dest_align     : Out std_logic_vector(C_ALIGN_WIDTH-1 downto 0);      --
        -- Bit field indicating the desired byte lane of the first valid data byte   --
        -- to be output by the DRE                                                   --
                                                                                     --
      mm2s_dre_flush          : Out std_logic;                                       --
        -- Active high signal indicating to the DRE to flush the current             --
        -- contents to the output register in preparation of a new alignment         --
        -- that will be comming on the next transfer input                           --
      ---------------------------------------------------------------------------------
               
                
                
                
     -- AXI Master Stream Channel------------------------------------------------------
                                                                                     --
      mm2s_strm_wvalid   : Out std_logic;                                            --
        -- AXI Stream VALID Output                                                   --
                                                                                     --
      mm2s_strm_wready   : In  Std_logic;                                            --
        -- AXI Stream READY input                                                    --
                                                                                     --
      mm2s_strm_wdata    : Out std_logic_vector(C_STREAM_DWIDTH-1 downto 0);         --
        -- AXI Stream data output                                                    --
                                                                                     --
      mm2s_strm_wstrb    : Out std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);     --    
        -- AXI Stream STRB output                                                    --
                                                                                     --
      mm2s_strm_wlast    : Out std_logic;                                            --
        -- AXI Stream LAST output                                                    --
      ---------------------------------------------------------------------------------
               
                
      
      -- MM2S Store and Forward Supplimental Control   --------------------------------
      -- This output is time aligned and qualified with the AXI Master Stream Channel--
                                                                                     --
      mm2s_data2sf_cmd_cmplt   : out std_logic;                                      --
                                                                                     --
      ---------------------------------------------------------------------------------
                                                                                     
                                                                                     
                                                                                     
                                                                                     
                                                                                     
                
                
      -- Command Calculator Interface -------------------------------------------------
                                                                                     --
      mstr2data_tag        : In std_logic_vector(C_TAG_WIDTH-1 downto 0);            --
         -- The next command tag                                                     --
                                                                                     --
      mstr2data_saddr_lsb  : In std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0);       --
         -- The next command start address LSbs to use for the read data             --
         -- mux (only used if Stream data width is 8 or 16 bits).                    --
                                                                                     --
      mstr2data_len        : In std_logic_vector(7 downto 0);                        --
         -- The LEN value output to the Address Channel                              --
                                                                                     --
      mstr2data_strt_strb  : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);    --
         -- The starting strobe value to use for the first stream data beat          --
                                                                                     --
      mstr2data_last_strb  : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);    --
         -- The endiing (LAST) strobe value to use for the last stream               --
         -- data beat                                                                --
                                                                                     --
      mstr2data_drr        : In std_logic;                                           --
         -- The starting tranfer of a sequence of transfers                          --
                                                                                     --
      mstr2data_eof        : In std_logic;                                           --
         -- The endiing tranfer of a sequence of transfers                           --
                                                                                     --
      mstr2data_sequential : In std_logic;                                           --
         -- The next sequential tranfer of a sequence of transfers                   --
         -- spawned from a single parent command                                     --
                                                                                     --
      mstr2data_calc_error : In std_logic;                                           --
         -- Indication if the next command in the calculation pipe                   --
         -- has a calculation error                                                  --
                                                                                     --
      mstr2data_cmd_cmplt  : In std_logic;                                           --
         -- The indication to the Data Channel that the current                      --
         -- sub-command output is the last one compiled from the                     --
         -- parent command pulled from the Command FIFO                              --
                                                                                     --
      mstr2data_cmd_valid  : In std_logic;                                           --
         -- The next command valid indication to the Data Channel                    --
         -- Controller for the AXI MMap                                              --
                                                                                     --
      data2mstr_cmd_ready  : Out std_logic ;                                         --
         -- Indication from the Data Channel Controller that the                     --
         -- command is being accepted on the AXI Address Channel                     --
                                                                                     --
      mstr2data_dre_src_align   : In std_logic_vector(C_ALIGN_WIDTH-1 downto 0);     --
         -- The source (input) alignment for the DRE                                 --
                                                                                     --
      mstr2data_dre_dest_align  : In std_logic_vector(C_ALIGN_WIDTH-1 downto 0);     --
         -- The destinstion (output) alignment for the DRE                           --
      ---------------------------------------------------------------------------------
     
      
      
      
        
      -- Address Controller Interface -------------------------------------------------
                                                                                     --
      addr2data_addr_posted : In std_logic ;                                         --
         -- Indication from the Address Channel Controller to the                    --
         -- Data Controller that an address has been posted to the                   --
         -- AXI Address Channel                                                      --
      ---------------------------------------------------------------------------------


      
      -- Data Controller General Halted Status ----------------------------------------
                                                                                     --
      data2all_dcntlr_halted : Out std_logic;                                        --
         -- When asserted, this indicates the data controller has satisfied          --
         -- all pending transfers queued by the Address Controller and is halted.    --
      ---------------------------------------------------------------------------------
      
       
 
      -- Output Stream Skid Buffer Halt control ---------------------------------------
                                                                                     --
      data2skid_halt : Out std_logic;                                                --
         -- The data controller asserts this output for 1 primary clock period       --
         -- The pulse commands the MM2S Stream skid buffer to tun off outputs        --
         -- at the next tlast transmission.                                          --
      ---------------------------------------------------------------------------------
      
       
 
       
      -- Read Status Controller Interface ------------------------------------------------
                                                                                        --
      data2rsc_tag       : Out std_logic_vector(C_TAG_WIDTH-1 downto 0);                --
         -- The propagated command tag from the Command Calculator                      --
                                                                                        --
      data2rsc_calc_err  : Out std_logic ;                                              --
         -- Indication that the current command out from the Cntl FIFO                  --
         -- has a propagated calculation error from the Command Calculator              --
                                                                                        --
      data2rsc_okay      : Out std_logic ;                                              --
         -- Indication that the AXI Read transfer completed with OK status              --
                                                                                        --
      data2rsc_decerr    : Out std_logic ;                                              --
         -- Indication that the AXI Read transfer completed with decode error status    --
                                                                                        --
      data2rsc_slverr    : Out std_logic ;                                              --
         -- Indication that the AXI Read transfer completed with slave error status     --
                                                                                        --
      data2rsc_cmd_cmplt : Out std_logic ;                                              --
         -- Indication by the Data Channel Controller that the                          --
         -- corresponding status is the last status for a parent command                --
         -- pulled from the command FIFO                                                --
                                                                                        --
      rsc2data_ready     : in  std_logic;                                               --
         -- Handshake bit from the Read Status Controller Module indicating             --
         -- that the it is ready to accept a new Read status transfer                   --
                                                                                        --
      data2rsc_valid     : Out  std_logic ;                                             --
         -- Handshake bit output to the Read Status Controller Module                   --
         -- indicating that the Data Controller has valid tag and status                --
         -- indicators to transfer                                                      --
                                                                                        --
      rsc2mstr_halt_pipe : In std_logic                                                 --
         -- Status Flag indicating the Status Controller needs to stall the command     --
         -- execution pipe due to a Status flow issue or internal error. Generally      --
         -- this will occur if the Status FIFO is not being serviced fast enough to     --
         -- keep ahead of the command execution.                                        --
      ------------------------------------------------------------------------------------
      
      );
  
  end entity axi_datamover_rddata_cntl;
  
  
  architecture implementation of axi_datamover_rddata_cntl is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Function declaration   ----------------------------------------
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_set_cnt_width
    --
    -- Function Description:
    --    Sets a count width based on a fifo depth. A depth of 4 or less
    -- is a special case which requires a minimum count width of 3 bits.
    --
    -------------------------------------------------------------------
    function funct_set_cnt_width (fifo_depth : integer) return integer is
    
      Variable temp_cnt_width : Integer := 4;
    
    begin
    
      
      if (fifo_depth <= 4) then
      
         temp_cnt_width := 3;
      
      elsif (fifo_depth <= 8) then
      
         temp_cnt_width := 4;
      
      elsif (fifo_depth <= 16) then
      
         temp_cnt_width := 5;
      
      elsif (fifo_depth <= 32) then
      
         temp_cnt_width := 6;
      
      else  -- fifo depth <= 64
      
         temp_cnt_width := 7;
      
      end if;
      
      Return (temp_cnt_width);
       
       
    end function funct_set_cnt_width;
    
 
 
 
  
    -- Constant Declarations  --------------------------------------------
    
    Constant OKAY                   : std_logic_vector(1 downto 0) := "00";
    Constant EXOKAY                 : std_logic_vector(1 downto 0) := "01";
    Constant SLVERR                 : std_logic_vector(1 downto 0) := "10";
    Constant DECERR                 : std_logic_vector(1 downto 0) := "11";
                                    
    Constant STRM_STRB_WIDTH        : integer := C_STREAM_DWIDTH/8;
    Constant LEN_OF_ZERO            : std_logic_vector(7 downto 0) := (others => '0');
    Constant USE_SYNC_FIFO          : integer := 0;
    Constant REG_FIFO_PRIM          : integer := 0; 
    Constant BRAM_FIFO_PRIM         : integer := 1; 
    Constant SRL_FIFO_PRIM          : integer := 2; 
    Constant FIFO_PRIM_TYPE         : integer := SRL_FIFO_PRIM; 
    Constant TAG_WIDTH              : integer := C_TAG_WIDTH;
    Constant SADDR_LSB_WIDTH        : integer := C_SEL_ADDR_WIDTH;
    Constant LEN_WIDTH              : integer := 8;
    Constant STRB_WIDTH             : integer := C_STREAM_DWIDTH/8;
    Constant SOF_WIDTH              : integer := 1;
    Constant EOF_WIDTH              : integer := 1;
    Constant CMD_CMPLT_WIDTH        : integer := 1;
    Constant SEQUENTIAL_WIDTH       : integer := 1;
    Constant CALC_ERR_WIDTH         : integer := 1;
    Constant DRE_ALIGN_WIDTH        : integer := C_ALIGN_WIDTH;
                                    
    Constant DCTL_FIFO_WIDTH        : Integer := TAG_WIDTH        +  -- Tag field
                                                 SADDR_LSB_WIDTH  +  -- LS Address field width
                                                 LEN_WIDTH        +  -- LEN field
                                                 STRB_WIDTH       +  -- Starting Strobe field
                                                 STRB_WIDTH       +  -- Ending Strobe field
                                                 SOF_WIDTH        +  -- SOF Flag Field
                                                 EOF_WIDTH        +  -- EOF flag field
                                                 SEQUENTIAL_WIDTH +  -- Calc error flag
                                                 CMD_CMPLT_WIDTH  +  -- Sequential command flag
                                                 CALC_ERR_WIDTH   +  -- Command Complete Flag
                                                 DRE_ALIGN_WIDTH  +  -- DRE Source Align width
                                                 DRE_ALIGN_WIDTH ;   -- DRE Dest Align width
                                                 
                                    
    -- Caution, the INDEX calculations are order dependent so don't rearrange
    Constant TAG_STRT_INDEX         : integer := 0;
    Constant SADDR_LSB_STRT_INDEX   : integer := TAG_STRT_INDEX + TAG_WIDTH;
    Constant LEN_STRT_INDEX         : integer := SADDR_LSB_STRT_INDEX + SADDR_LSB_WIDTH;
    Constant STRT_STRB_STRT_INDEX   : integer := LEN_STRT_INDEX + LEN_WIDTH;
    Constant LAST_STRB_STRT_INDEX   : integer := STRT_STRB_STRT_INDEX + STRB_WIDTH;
    Constant SOF_STRT_INDEX         : integer := LAST_STRB_STRT_INDEX + STRB_WIDTH;
    Constant EOF_STRT_INDEX         : integer := SOF_STRT_INDEX + SOF_WIDTH;
    Constant SEQUENTIAL_STRT_INDEX  : integer := EOF_STRT_INDEX + EOF_WIDTH;
    Constant CMD_CMPLT_STRT_INDEX   : integer := SEQUENTIAL_STRT_INDEX + SEQUENTIAL_WIDTH;
    Constant CALC_ERR_STRT_INDEX    : integer := CMD_CMPLT_STRT_INDEX + CMD_CMPLT_WIDTH;
    Constant DRE_SRC_STRT_INDEX     : integer := CALC_ERR_STRT_INDEX + CALC_ERR_WIDTH;
    Constant DRE_DEST_STRT_INDEX    : integer := DRE_SRC_STRT_INDEX + DRE_ALIGN_WIDTH;
    
    Constant ADDR_INCR_VALUE        : integer := C_STREAM_DWIDTH/8;
    
    --Constant ADDR_POSTED_CNTR_WIDTH : integer := 5; -- allows up to 32 entry address queue
    Constant ADDR_POSTED_CNTR_WIDTH : integer := funct_set_cnt_width(C_DATA_CNTL_FIFO_DEPTH); 
    
    
    Constant ADDR_POSTED_ZERO       : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                      := (others => '0');
    Constant ADDR_POSTED_ONE        : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                      := TO_UNSIGNED(1, ADDR_POSTED_CNTR_WIDTH);
    Constant ADDR_POSTED_MAX        : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                       := (others => '1');
                    
    
    
    
    -- Signal Declarations  --------------------------------------------
    
    signal sig_good_dbeat               : std_logic := '0';
    signal sig_get_next_dqual           : std_logic := '0';
    signal sig_last_mmap_dbeat          : std_logic := '0';
    signal sig_last_mmap_dbeat_reg      : std_logic := '0';
    signal sig_data2mmap_ready          : std_logic := '0';
    signal sig_mmap2data_valid          : std_logic := '0';
    signal sig_mmap2data_last           : std_logic := '0';
    signal sig_aposted_cntr_ready       : std_logic := '0';
    signal sig_ld_new_cmd               : std_logic := '0';
    signal sig_ld_new_cmd_reg           : std_logic := '0';
    signal sig_cmd_cmplt_reg            : std_logic := '0';
    signal sig_tag_reg                  : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_lsb_reg             : std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_strt_strb_reg            : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_last_strb_reg            : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_addr_posted              : std_logic := '0';
    signal sig_addr_chan_rdy            : std_logic := '0';
    signal sig_dqual_rdy                : std_logic := '0';
    signal sig_good_mmap_dbeat          : std_logic := '0';
    signal sig_first_dbeat              : std_logic := '0';
    signal sig_last_dbeat               : std_logic := '0';
    signal sig_new_len_eq_0             : std_logic := '0';
    signal sig_dbeat_cntr               : unsigned(7 downto 0) := (others => '0');
    Signal sig_dbeat_cntr_int           : Integer range 0 to 255 := 0;
    signal sig_dbeat_cntr_eq_0          : std_logic := '0';
    signal sig_dbeat_cntr_eq_1          : std_logic := '0';
    signal sig_calc_error_reg           : std_logic := '0';
    signal sig_decerr                   : std_logic := '0';
    signal sig_slverr                   : std_logic := '0';
    signal sig_coelsc_okay_reg          : std_logic := '0';
    signal sig_coelsc_interr_reg        : std_logic := '0';
    signal sig_coelsc_decerr_reg        : std_logic := '0';
    signal sig_coelsc_slverr_reg        : std_logic := '0';
    signal sig_coelsc_cmd_cmplt_reg     : std_logic := '0';
    signal sig_coelsc_tag_reg           : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_pop_coelsc_reg           : std_logic := '0';
    signal sig_push_coelsc_reg          : std_logic := '0';
    signal sig_coelsc_reg_empty         : std_logic := '0';
    signal sig_coelsc_reg_full          : std_logic := '0';
    signal sig_rsc2data_ready           : std_logic := '0';
    signal sig_cmd_cmplt_last_dbeat     : std_logic := '0';
    signal sig_next_tag_reg             : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_next_strt_strb_reg       : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_next_last_strb_reg       : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_next_eof_reg             : std_logic := '0';
    signal sig_next_sequential_reg      : std_logic := '0';
    signal sig_next_cmd_cmplt_reg       : std_logic := '0';
    signal sig_next_calc_error_reg      : std_logic := '0';
    signal sig_next_dre_src_align_reg   : std_logic_vector(C_ALIGN_WIDTH-1 downto 0) := (others => '0');  
    signal sig_next_dre_dest_align_reg  : std_logic_vector(C_ALIGN_WIDTH-1 downto 0) := (others => '0'); 
    signal sig_pop_dqual_reg            : std_logic := '0';
    signal sig_push_dqual_reg           : std_logic := '0';
    signal sig_dqual_reg_empty          : std_logic := '0';
    signal sig_dqual_reg_full           : std_logic := '0';
    signal sig_addr_posted_cntr         : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_posted_cntr_eq_0    : std_logic := '0';
    signal sig_addr_posted_cntr_max     : std_logic := '0';
    signal sig_decr_addr_posted_cntr    : std_logic := '0';
    signal sig_incr_addr_posted_cntr    : std_logic := '0';
    signal sig_ls_addr_cntr             : unsigned(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_incr_ls_addr_cntr        : std_logic := '0';
    signal sig_addr_incr_unsgnd         : unsigned(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_no_posted_cmds           : std_logic := '0';
    Signal sig_cmd_fifo_data_in         : std_logic_vector(DCTL_FIFO_WIDTH-1 downto 0);
    Signal sig_cmd_fifo_data_out        : std_logic_vector(DCTL_FIFO_WIDTH-1 downto 0);
    signal sig_fifo_next_tag            : std_logic_vector(TAG_WIDTH-1 downto 0);
    signal sig_fifo_next_sadddr_lsb     : std_logic_vector(SADDR_LSB_WIDTH-1 downto 0);             
    signal sig_fifo_next_len            : std_logic_vector(LEN_WIDTH-1 downto 0);             
    signal sig_fifo_next_strt_strb      : std_logic_vector(STRB_WIDTH-1 downto 0);             
    signal sig_fifo_next_last_strb      : std_logic_vector(STRB_WIDTH-1 downto 0);             
    signal sig_fifo_next_drr            : std_logic := '0';
    signal sig_fifo_next_eof            : std_logic := '0';
    signal sig_fifo_next_cmd_cmplt      : std_logic := '0';
    signal sig_fifo_next_calc_error     : std_logic := '0';
    signal sig_fifo_next_sequential     : std_logic := '0';
    signal sig_fifo_next_dre_src_align  : std_logic_vector(C_ALIGN_WIDTH-1 downto 0) := (others => '0');  
    signal sig_fifo_next_dre_dest_align : std_logic_vector(C_ALIGN_WIDTH-1 downto 0) := (others => '0'); 
    signal sig_cmd_fifo_empty           : std_logic := '0';
    signal sig_fifo_wr_cmd_valid        : std_logic := '0';
    signal sig_fifo_wr_cmd_ready        : std_logic := '0';
    signal sig_fifo_rd_cmd_valid        : std_logic := '0';
    signal sig_fifo_rd_cmd_ready        : std_logic := '0';
    signal sig_sequential_push          : std_logic := '0';
    signal sig_clr_dqual_reg            : std_logic := '0';
    signal sig_advance_pipe             : std_logic := '0';
    signal sig_halt_reg                 : std_logic := '0';
    signal sig_halt_reg_dly1            : std_logic := '0';
    signal sig_halt_reg_dly2            : std_logic := '0';
    signal sig_halt_reg_dly3            : std_logic := '0';
    signal sig_data2skid_halt           : std_logic := '0';
    signal sig_rd_xfer_cmplt            : std_logic := '0';
    
                              
    
  begin --(architecture implementation)
  
    -- AXI MMap Data Channel Port assignments
    mm2s_rready          <= sig_data2mmap_ready;
    sig_mmap2data_valid  <= mm2s_rvalid        ;
    sig_mmap2data_last   <= mm2s_rlast         ;
    
    -- Read Status Block interface
    data2rsc_valid       <= sig_coelsc_reg_full      ;
    sig_rsc2data_ready   <= rsc2data_ready           ;
    
    data2rsc_tag         <= sig_coelsc_tag_reg       ;
    data2rsc_calc_err    <= sig_coelsc_interr_reg    ;
    data2rsc_okay        <= sig_coelsc_okay_reg      ;
    data2rsc_decerr      <= sig_coelsc_decerr_reg    ;
    data2rsc_slverr      <= sig_coelsc_slverr_reg    ;
    data2rsc_cmd_cmplt   <= sig_coelsc_cmd_cmplt_reg ;
    
    
                                                    
    -- AXI MM2S Stream Channel Port assignments               
    mm2s_strm_wvalid     <= (mm2s_rvalid             and         
                             sig_advance_pipe)       or
                            (sig_halt_reg            and  -- Force tvalid high on a Halt and
                             sig_dqual_reg_full      and  -- a transfer is scheduled and
                             not(sig_no_posted_cmds) and  -- there are cmds posted to AXi and
                             not(sig_calc_error_reg));    -- not a calc error       
    
            
                                                    
    mm2s_strm_wlast      <= (mm2s_rlast              and
                            sig_next_eof_reg)        or
                            (sig_halt_reg            and  -- Force tvalid high on a Halt and
                             sig_dqual_reg_full      and  -- a transfer is scheduled and
                             not(sig_no_posted_cmds) and  -- there are cmds posted to AXi and
                             not(sig_calc_error_reg));    -- not a calc error;        
    
    
     
    

GEN_MM2S_TKEEP_ENABLE5 : if C_ENABLE_MM2S_TKEEP = 1 generate
begin
   -- Generate the Write Strobes for the Stream interface
    mm2s_strm_wstrb <= (others => '1')
      When (sig_halt_reg = '1')        -- Force tstrb high on a Halt
      else sig_strt_strb_reg
      When (sig_first_dbeat = '1')
      Else sig_last_strb_reg
      When (sig_last_dbeat = '1')
      Else (others => '1');

 
end generate GEN_MM2S_TKEEP_ENABLE5;

GEN_MM2S_TKEEP_DISABLE5 : if C_ENABLE_MM2S_TKEEP = 0 generate
begin
   -- Generate the Write Strobes for the Stream interface
    mm2s_strm_wstrb <= (others => '1');


end generate GEN_MM2S_TKEEP_DISABLE5;

    
    
    
    -- MM2S Supplimental Controls
    mm2s_data2sf_cmd_cmplt <= (mm2s_rlast              and
                               sig_next_cmd_cmplt_reg) or
                              (sig_halt_reg            and  
                               sig_dqual_reg_full      and  
                               not(sig_no_posted_cmds) and  
                               not(sig_calc_error_reg));    
    
    
    
    
    
    
    -- Address Channel Controller synchro pulse input                  
    sig_addr_posted      <= addr2data_addr_posted;
                                                        
 
 
    -- Request to halt the Address Channel Controller                  
    data2addr_stop_req   <= sig_halt_reg;
 
    
    -- Halted flag to the reset module                  
    data2rst_stop_cmplt  <= (sig_halt_reg_dly3 and   -- Normal Mode shutdown
                            sig_no_posted_cmds and 
                            not(sig_calc_error_reg)) or
                            (sig_halt_reg_dly3 and   -- Shutdown after error trap
                             sig_calc_error_reg);
    
     
    
    -- Read Transfer Completed Status output
    mm2s_rd_xfer_cmplt <=  sig_rd_xfer_cmplt;                     
    
    
     
    -- Internal logic ------------------------------
 
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_RD_CMPLT_FLAG
    --
    -- Process Description:
    --   Implements the status flag indicating that a read data 
    -- transfer has completed. This is an echo of a rlast assertion
    -- and a qualified data beat on the AXI4 Read Data Channel 
    -- inputs.
    --
    -------------------------------------------------------------
    IMP_RD_CMPLT_FLAG : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset = '1') then
    
             sig_rd_xfer_cmplt <= '0';
    
           else
    
             sig_rd_xfer_cmplt <= sig_mmap2data_last and 
                                  sig_good_mmap_dbeat;
                                  
           end if; 
        end if;       
      end process IMP_RD_CMPLT_FLAG; 
     
    
 
  
    
    -- General flag for advancing the MMap Read and the Stream
    -- data pipelines
    sig_advance_pipe     <=  sig_addr_chan_rdy        and                                  
                             sig_dqual_rdy            and                                  
                             not(sig_coelsc_reg_full) and  -- new status back-pressure term
                             not(sig_calc_error_reg);                                      
    
                                      
    -- test for Kevin's status throttle case
    sig_data2mmap_ready  <= (mm2s_strm_wready or 
                             sig_halt_reg)    and    -- Ignore the Stream ready on a Halt request                              
                             sig_advance_pipe;          
    
     
     
    sig_good_mmap_dbeat  <= sig_data2mmap_ready and 
                            sig_mmap2data_valid;
    
    
    sig_last_mmap_dbeat  <= sig_good_mmap_dbeat and 
                            sig_mmap2data_last;
     
     
    sig_get_next_dqual   <= sig_last_mmap_dbeat; 
    
    
    
    
    
    
         
    ------------------------------------------------------------
    -- Instance: I_READ_MUX 
    --
    -- Description:
    --  Instance of the MM2S Read Data Channel Read Mux   
    --
    ------------------------------------------------------------
    I_READ_MUX : entity axi_datamover_v5_1.axi_datamover_rdmux
    generic map (
  
      C_SEL_ADDR_WIDTH     =>  C_SEL_ADDR_WIDTH ,   
      C_MMAP_DWIDTH        =>  C_MMAP_DWIDTH    ,   
      C_STREAM_DWIDTH      =>  C_STREAM_DWIDTH      
  
      )
    port map (
  
      mmap_read_data_in    =>  mm2s_rdata       ,   
      mux_data_out         =>  mm2s_strm_wdata  ,            
      mstr2data_saddr_lsb  =>  sig_addr_lsb_reg     
    
      );
   
   
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_LAST_DBEAT
    --
    -- Process Description:
    --   This implements a FLOP that creates a pulse
    -- indicating the LAST signal for an incoming read data channel
    -- has been received. Note that it is possible to have back to 
    -- back LAST databeats.
    --
    -------------------------------------------------------------
    REG_LAST_DBEAT : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset = '1') then

             sig_last_mmap_dbeat_reg <= '0';
             
           else
             
             sig_last_mmap_dbeat_reg <= sig_last_mmap_dbeat;
             
           end if; 
         end if;       
       end process REG_LAST_DBEAT; 
  
    
    
    
    
    

     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_NO_DATA_CNTL_FIFO
     --
     -- If Generate Description:
     --   Omits the input data control FIFO if the requested FIFO
     -- depth is 1. The Data Qualifier Register serves as a 
     -- 1 deep FIFO by itself.
     --
     ------------------------------------------------------------
     GEN_NO_DATA_CNTL_FIFO : if (C_DATA_CNTL_FIFO_DEPTH = 1) generate

       begin

         -- Command Calculator Handshake output
         data2mstr_cmd_ready    <= sig_fifo_wr_cmd_ready;           
        
         sig_fifo_rd_cmd_valid  <= mstr2data_cmd_valid ;
         
         
         
         -- pre 13.1 sig_fifo_wr_cmd_ready  <= sig_dqual_reg_empty     and                                         
         -- pre 13.1                           sig_aposted_cntr_ready  and                                         
         -- pre 13.1                           not(rsc2mstr_halt_pipe) and  -- The Rd Status Controller is not stalling
         -- pre 13.1                           not(sig_calc_error_reg);     -- the command execution pipe and there is  
         -- pre 13.1                                                        -- no calculation error being propagated

         sig_fifo_wr_cmd_ready  <= sig_push_dqual_reg;


                                                                    
         
         sig_fifo_next_tag             <= mstr2data_tag        ;    
         sig_fifo_next_sadddr_lsb      <= mstr2data_saddr_lsb  ;    
         sig_fifo_next_len             <= mstr2data_len        ;    
         sig_fifo_next_strt_strb       <= mstr2data_strt_strb  ;    
         sig_fifo_next_last_strb       <= mstr2data_last_strb  ;    
         sig_fifo_next_drr             <= mstr2data_drr        ;    
         sig_fifo_next_eof             <= mstr2data_eof        ;    
         sig_fifo_next_sequential      <= mstr2data_sequential ;    
         sig_fifo_next_cmd_cmplt       <= mstr2data_cmd_cmplt  ;    
         sig_fifo_next_calc_error      <= mstr2data_calc_error ; 
            
         sig_fifo_next_dre_src_align   <= mstr2data_dre_src_align  ; 
         sig_fifo_next_dre_dest_align  <= mstr2data_dre_dest_align ; 
                                                              
             
   
       end generate GEN_NO_DATA_CNTL_FIFO;
         
    
    
    
    
      
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_DATA_CNTL_FIFO
     --
     -- If Generate Description:
     --   Includes the input data control FIFO if the requested 
     -- FIFO depth is more than 1.
     --
     ------------------------------------------------------------
     GEN_DATA_CNTL_FIFO : if (C_DATA_CNTL_FIFO_DEPTH > 1) generate

       begin

       
         -- Command Calculator Handshake output
         data2mstr_cmd_ready    <= sig_fifo_wr_cmd_ready;           
         
         sig_fifo_wr_cmd_valid  <= mstr2data_cmd_valid  ;
         

         sig_fifo_rd_cmd_ready    <= sig_push_dqual_reg;  -- pop the fifo when dqual reg is pushed   
                                                               

         
         
                              
         -- Format the input fifo data word
         sig_cmd_fifo_data_in  <=   mstr2data_dre_dest_align &
                                    mstr2data_dre_src_align  &
                                    mstr2data_calc_error     &
                                    mstr2data_cmd_cmplt      &
                                    mstr2data_sequential     &
                                    mstr2data_eof            &
                                    mstr2data_drr            &
                                    mstr2data_last_strb      &
                                    mstr2data_strt_strb      &
                                    mstr2data_len            &
                                    mstr2data_saddr_lsb      &
                                    mstr2data_tag ;
         
          
         -- Rip the output fifo data word
         sig_fifo_next_tag        <= sig_cmd_fifo_data_out((TAG_STRT_INDEX+TAG_WIDTH)-1 downto 
                                                            TAG_STRT_INDEX);                   
         sig_fifo_next_sadddr_lsb <= sig_cmd_fifo_data_out((SADDR_LSB_STRT_INDEX+SADDR_LSB_WIDTH)-1 downto 
                                                            SADDR_LSB_STRT_INDEX);
         sig_fifo_next_len        <= sig_cmd_fifo_data_out((LEN_STRT_INDEX+LEN_WIDTH)-1 downto 
                                                            LEN_STRT_INDEX);
         sig_fifo_next_strt_strb  <= sig_cmd_fifo_data_out((STRT_STRB_STRT_INDEX+STRB_WIDTH)-1 downto 
                                                            STRT_STRB_STRT_INDEX);
         sig_fifo_next_last_strb  <= sig_cmd_fifo_data_out((LAST_STRB_STRT_INDEX+STRB_WIDTH)-1 downto 
                                                            LAST_STRB_STRT_INDEX);
         sig_fifo_next_drr        <= sig_cmd_fifo_data_out(SOF_STRT_INDEX);
         sig_fifo_next_eof        <= sig_cmd_fifo_data_out(EOF_STRT_INDEX);
         sig_fifo_next_sequential <= sig_cmd_fifo_data_out(SEQUENTIAL_STRT_INDEX);
         sig_fifo_next_cmd_cmplt  <= sig_cmd_fifo_data_out(CMD_CMPLT_STRT_INDEX);
         sig_fifo_next_calc_error <= sig_cmd_fifo_data_out(CALC_ERR_STRT_INDEX);

         sig_fifo_next_dre_src_align   <= sig_cmd_fifo_data_out((DRE_SRC_STRT_INDEX+DRE_ALIGN_WIDTH)-1 downto 
                                                                 DRE_SRC_STRT_INDEX);
         sig_fifo_next_dre_dest_align  <= sig_cmd_fifo_data_out((DRE_DEST_STRT_INDEX+DRE_ALIGN_WIDTH)-1 downto 
                                                                 DRE_DEST_STRT_INDEX);
         
                                           
                                           
                                           
         ------------------------------------------------------------
         -- Instance: I_DATA_CNTL_FIFO 
         --
         -- Description:
         -- Instance for the Command Qualifier FIFO
         --
         ------------------------------------------------------------
          I_DATA_CNTL_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
          generic map (
        
            C_DWIDTH             =>  DCTL_FIFO_WIDTH        ,  
            C_DEPTH              =>  C_DATA_CNTL_FIFO_DEPTH ,  
            C_IS_ASYNC           =>  USE_SYNC_FIFO          ,  
            C_PRIM_TYPE          =>  FIFO_PRIM_TYPE         ,  
            C_FAMILY             =>  C_FAMILY                  
           
            )
          port map (
            
            -- Write Clock and reset
            fifo_wr_reset        =>   mmap_reset            ,  
            fifo_wr_clk          =>   primary_aclk          ,  
            
            -- Write Side
            fifo_wr_tvalid       =>   sig_fifo_wr_cmd_valid ,  
            fifo_wr_tready       =>   sig_fifo_wr_cmd_ready ,  
            fifo_wr_tdata        =>   sig_cmd_fifo_data_in  ,  
            fifo_wr_full         =>   open                  ,  
           
            -- Read Clock and reset
            fifo_async_rd_reset  =>   mmap_reset            ,   
            fifo_async_rd_clk    =>   primary_aclk          ,  
            
            -- Read Side
            fifo_rd_tvalid       =>   sig_fifo_rd_cmd_valid ,  
            fifo_rd_tready       =>   sig_fifo_rd_cmd_ready ,  
            fifo_rd_tdata        =>   sig_cmd_fifo_data_out ,  
            fifo_rd_empty        =>   sig_cmd_fifo_empty       
           
            );
        

       end generate GEN_DATA_CNTL_FIFO;
         
          
    
   
  
  
  
  
  
    -- Data Qualifier Register ------------------------------------
    
    sig_ld_new_cmd           <= sig_push_dqual_reg      ;
    sig_addr_chan_rdy        <= not(sig_addr_posted_cntr_eq_0);
    sig_dqual_rdy            <= sig_dqual_reg_full      ;
    sig_strt_strb_reg        <= sig_next_strt_strb_reg  ;
    sig_last_strb_reg        <= sig_next_last_strb_reg  ;
    sig_tag_reg              <= sig_next_tag_reg        ;
    sig_cmd_cmplt_reg        <= sig_next_cmd_cmplt_reg  ;
    sig_calc_error_reg       <= sig_next_calc_error_reg ;
    
    
    -- Flag indicating that there are no posted commands to AXI
    sig_no_posted_cmds       <= sig_addr_posted_cntr_eq_0;
    
    
    
    -- new for no bubbles between child requests
    sig_sequential_push      <= sig_good_mmap_dbeat and -- MMap handshake qualified
                                sig_last_dbeat      and -- last data beat of transfer
                                sig_next_sequential_reg;-- next queued command is sequential 
                                                        -- to the current command
    
    
    -- pre 13.1 sig_push_dqual_reg       <= (sig_sequential_push   or
    -- pre 13.1                              sig_dqual_reg_empty)  and 
    -- pre 13.1                             sig_fifo_rd_cmd_valid  and
    -- pre 13.1                             sig_aposted_cntr_ready and 
    -- pre 13.1                             not(rsc2mstr_halt_pipe);  -- The Rd Status Controller is not  
                                                                      -- stalling the command execution pipe
    
    sig_push_dqual_reg       <= (sig_sequential_push    or
                                 sig_dqual_reg_empty)   and 
                                sig_fifo_rd_cmd_valid   and
                                sig_aposted_cntr_ready  and 
                                not(sig_calc_error_reg) and -- 13.1 addition => An error has not been propagated
                                not(rsc2mstr_halt_pipe);    -- The Rd Status Controller is not  
                                                            -- stalling the command execution pipe
                                                        
                                                        
    sig_pop_dqual_reg        <= not(sig_next_calc_error_reg) and 
                                sig_get_next_dqual and 
                                sig_dqual_reg_full  ; 
    
  
    -- new for no bubbles between child requests
    sig_clr_dqual_reg        <=  mmap_reset         or
                                 (sig_pop_dqual_reg and
                                 not(sig_push_dqual_reg));
  
    
  -------------------------------------------------------------
  -- Synchronous Process with Sync Reset
  --
  -- Label: IMP_DQUAL_REG
  --
  -- Process Description:
  --    This process implements a register for the Data 
  -- Control and qualifiers. It operates like a 1 deep Sync FIFO.
  --
  -------------------------------------------------------------
  IMP_DQUAL_REG : process (primary_aclk)
     begin
       if (primary_aclk'event and primary_aclk = '1') then
          if (sig_clr_dqual_reg = '1') then
            
            sig_next_tag_reg             <= (others => '0');
            sig_next_strt_strb_reg       <= (others => '0');
            sig_next_last_strb_reg       <= (others => '0');
            sig_next_eof_reg             <= '0';
            sig_next_cmd_cmplt_reg       <= '0';
            sig_next_sequential_reg      <= '0';
            sig_next_calc_error_reg      <= '0';
            sig_next_dre_src_align_reg   <= (others => '0');
            sig_next_dre_dest_align_reg  <= (others => '0');
            
            sig_dqual_reg_empty          <= '1';
            sig_dqual_reg_full           <= '0';
            
          elsif (sig_push_dqual_reg = '1') then
            
            sig_next_tag_reg             <= sig_fifo_next_tag            ;
            sig_next_strt_strb_reg       <= sig_fifo_next_strt_strb      ;
            sig_next_last_strb_reg       <= sig_fifo_next_last_strb      ;
            sig_next_eof_reg             <= sig_fifo_next_eof            ;
            sig_next_cmd_cmplt_reg       <= sig_fifo_next_cmd_cmplt      ;
            sig_next_sequential_reg      <= sig_fifo_next_sequential     ;
            sig_next_calc_error_reg      <= sig_fifo_next_calc_error     ;
            sig_next_dre_src_align_reg   <= sig_fifo_next_dre_src_align  ;  
            sig_next_dre_dest_align_reg  <= sig_fifo_next_dre_dest_align ;  
            
            sig_dqual_reg_empty          <= '0';
            sig_dqual_reg_full           <= '1';
            
          else
            null;  -- don't change state
          end if; 
       end if;       
     end process IMP_DQUAL_REG; 
     

  
  
  
    
    
    -- Address LS Cntr logic  --------------------------
    
    sig_addr_lsb_reg         <= STD_LOGIC_VECTOR(sig_ls_addr_cntr);
    sig_addr_incr_unsgnd     <= TO_UNSIGNED(ADDR_INCR_VALUE, C_SEL_ADDR_WIDTH);
    sig_incr_ls_addr_cntr    <= sig_good_mmap_dbeat;
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: DO_ADDR_LSB_CNTR
    --
    -- Process Description:
    --  Implements the LS Address Counter used for controlling
    -- the Read Data Mux during Burst transfers
    --
    -------------------------------------------------------------
    DO_ADDR_LSB_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1'  or
               (sig_pop_dqual_reg  = '1'  and
                sig_push_dqual_reg = '0')) then                 -- Clear the Counter
              
              sig_ls_addr_cntr <= (others => '0');
            
            elsif (sig_push_dqual_reg = '1') then               -- Load the Counter
              
              sig_ls_addr_cntr <= unsigned(sig_fifo_next_sadddr_lsb);
            
            elsif (sig_incr_ls_addr_cntr = '1') then            -- Increment the Counter
              
              sig_ls_addr_cntr <= sig_ls_addr_cntr + sig_addr_incr_unsgnd;
            
            else
              null;  -- Hold Current value
            end if; 
         end if;       
       end process DO_ADDR_LSB_CNTR; 
    
    
    
    
    
    
    
    
    
    
    
    
    ----- Address posted Counter logic --------------------------------
    
    sig_incr_addr_posted_cntr <= sig_addr_posted              ;
    
    
    sig_decr_addr_posted_cntr <= sig_last_mmap_dbeat_reg      ;
    
    
    sig_aposted_cntr_ready    <= not(sig_addr_posted_cntr_max);
    
    sig_addr_posted_cntr_eq_0 <= '1'
      when (sig_addr_posted_cntr = ADDR_POSTED_ZERO)
      Else '0';
    
    sig_addr_posted_cntr_max <= '1'
      when (sig_addr_posted_cntr = ADDR_POSTED_MAX)
      Else '0';
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_ADDR_POSTED_FIFO_CNTR
    --
    -- Process Description:
    --    This process implements a register for the Address 
    -- Posted FIFO that operates like a 1 deep Sync FIFO.
    --
    -------------------------------------------------------------
    IMP_ADDR_POSTED_FIFO_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_addr_posted_cntr <= ADDR_POSTED_ZERO;
              
            elsif (sig_incr_addr_posted_cntr = '1' and
                   sig_decr_addr_posted_cntr  = '0' and
                   sig_addr_posted_cntr_max = '0') then
              
              sig_addr_posted_cntr <= sig_addr_posted_cntr + ADDR_POSTED_ONE ;
              
            elsif (sig_incr_addr_posted_cntr  = '0' and
                   sig_decr_addr_posted_cntr   = '1' and
                   sig_addr_posted_cntr_eq_0 = '0') then
              
              sig_addr_posted_cntr <= sig_addr_posted_cntr - ADDR_POSTED_ONE ;
              
            else
              null;  -- don't change state
            end if; 
         end if;       
       end process IMP_ADDR_POSTED_FIFO_CNTR; 
     
         
      
      
      
      
      
      
    ------- First/Middle/Last Dbeat detirmination -------------------
     
     sig_new_len_eq_0 <= '1'
       When  (sig_fifo_next_len = LEN_OF_ZERO)
       else '0';
     
     
      
      
     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: DO_FIRST_MID_LAST
     --
     -- Process Description:
     --  Implements the detection of the First/Mid/Last databeat of
     -- a transfer.
     --
     -------------------------------------------------------------
     DO_FIRST_MID_LAST : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
             if (mmap_reset = '1') then
               
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '0';
             
             elsif (sig_ld_new_cmd = '1') then
               
               sig_first_dbeat   <= not(sig_new_len_eq_0);
               sig_last_dbeat    <= sig_new_len_eq_0;
             
             Elsif (sig_dbeat_cntr_eq_1 = '1' and
                    sig_good_mmap_dbeat = '1') Then
             
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '1';
             
             Elsif (sig_dbeat_cntr_eq_0 = '0' and
                    sig_dbeat_cntr_eq_1 = '0' and
                    sig_good_mmap_dbeat = '1') Then
             
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '0';
             
             else
               null; -- hols current state
             end if; 
          end if;       
        end process DO_FIRST_MID_LAST; 
    
    
   
   
   
   -------  Data Controller Halted Indication ------------------------------- 
    
 
    data2all_dcntlr_halted <= sig_no_posted_cmds  and
                              (sig_calc_error_reg or
                               rst2data_stop_request);
 
 
    
    
   -------  Data Beat counter logic ------------------------------- 
    sig_dbeat_cntr_int  <= TO_INTEGER(sig_dbeat_cntr);
    
    sig_dbeat_cntr_eq_0 <= '1'
      when (sig_dbeat_cntr_int = 0)
      Else '0';
    
    sig_dbeat_cntr_eq_1 <= '1'
      when (sig_dbeat_cntr_int = 1)
      Else '0';
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: DO_DBEAT_CNTR
    --
    -- Process Description:
    --
    --
    -------------------------------------------------------------
    DO_DBEAT_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              sig_dbeat_cntr <= (others => '0');
            elsif (sig_ld_new_cmd = '1') then
              sig_dbeat_cntr <= unsigned(sig_fifo_next_len);
            Elsif (sig_good_mmap_dbeat = '1' and
                   sig_dbeat_cntr_eq_0 = '0') Then
              sig_dbeat_cntr <= sig_dbeat_cntr-1;
            else
              null; -- Hold current state
            end if; 
         end if;       
       end process DO_DBEAT_CNTR; 
      
  
 
 
  
  
   ------  Read Response Status Logic  ------------------------------
  
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: LD_NEW_CMD_PULSE
   --
   -- Process Description:
   -- Generate a 1 Clock wide pulse when a new command has been
   -- loaded into the Command Register
   --
   -------------------------------------------------------------
   LD_NEW_CMD_PULSE : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset         = '1' or
               sig_ld_new_cmd_reg = '1') then
             sig_ld_new_cmd_reg <= '0';
           elsif (sig_ld_new_cmd = '1') then
             sig_ld_new_cmd_reg <= '1';
           else
             null; -- hold State
           end if; 
        end if;       
      end process LD_NEW_CMD_PULSE; 
  
                               
                               
   sig_pop_coelsc_reg  <= sig_coelsc_reg_full and
                          sig_rsc2data_ready ; 
                          
   sig_push_coelsc_reg <= (sig_good_mmap_dbeat and  
                           not(sig_coelsc_reg_full)) or
                          (sig_ld_new_cmd_reg and 
                           sig_calc_error_reg) ; 
   
   sig_cmd_cmplt_last_dbeat <= (sig_cmd_cmplt_reg and sig_mmap2data_last) or
                                sig_calc_error_reg;
   
   
      
  -------  Read Response Decode   
    
   -- Decode the AXI MMap Read Response       
   sig_decerr  <= '1'
     When mm2s_rresp = DECERR
     Else '0'; 
          
   sig_slverr  <= '1'
     When mm2s_rresp = SLVERR
     Else '0';      
   
   
   
          
          
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: RD_RESP_COELESC_REG
    --
    -- Process Description:
    --   Implement the Read error/status coelescing register. 
    -- Once a bit is set it will remain set until the overall 
    -- status is written to the Status Controller. 
    -- Tag bits are just registered at each valid dbeat.
    --
    -------------------------------------------------------------
    STATUS_COELESC_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset          = '1' or
               (sig_pop_coelsc_reg  = '1' and        -- Added more qualification here for simultaneus
                sig_push_coelsc_reg = '0')) then     -- push and pop condition per CR590244
                                                                                                
              sig_coelsc_tag_reg       <= (others => '0');
              sig_coelsc_cmd_cmplt_reg <= '0';
              sig_coelsc_interr_reg    <= '0';
              sig_coelsc_decerr_reg    <= '0';
              sig_coelsc_slverr_reg    <= '0';
              sig_coelsc_okay_reg      <= '1';       -- set back to default of "OKAY"
  
              sig_coelsc_reg_full      <= '0';
              sig_coelsc_reg_empty     <= '1';
  
  
              
            Elsif (sig_push_coelsc_reg = '1') Then
            
              sig_coelsc_tag_reg       <= sig_tag_reg;                             
              sig_coelsc_cmd_cmplt_reg <= sig_cmd_cmplt_last_dbeat;                  
              sig_coelsc_interr_reg    <= sig_calc_error_reg or 
                                          sig_coelsc_interr_reg;
              sig_coelsc_decerr_reg    <= sig_decerr or sig_coelsc_decerr_reg;
              sig_coelsc_slverr_reg    <= sig_slverr or sig_coelsc_slverr_reg;
              sig_coelsc_okay_reg      <= not(sig_decerr       or 
                                              sig_slverr       or 
                                              sig_calc_error_reg );
              
              sig_coelsc_reg_full      <= sig_cmd_cmplt_last_dbeat;
              sig_coelsc_reg_empty     <= not(sig_cmd_cmplt_last_dbeat);
                                            
              
            else
              
              null;  -- hold current state
              
            end if; 
         end if;       
       end process STATUS_COELESC_REG; 
   
   
   
   
   
   
   
   
   
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_DRE
    --
    -- If Generate Description:
    --  Ties off DRE Control signals to logic low when DRE is
    -- omitted from the MM2S functionality.
    --
    --
    ------------------------------------------------------------
    GEN_NO_DRE : if (C_INCLUDE_DRE = 0) generate
    
       begin
    
         mm2s_dre_new_align     <= '0';
         mm2s_dre_use_autodest  <= '0';
         mm2s_dre_src_align     <= (others => '0');
         mm2s_dre_dest_align    <= (others => '0');
         mm2s_dre_flush         <= '0';
        
       end generate GEN_NO_DRE;
   
    
    
    
    
    
    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_DRE_CNTLS
    --
    -- If Generate Description:
    -- Implements the DRE Control logic when MM2S DRE is enabled.
    --
    --  - The DRE needs to have forced alignment at a SOF assertion
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_DRE_CNTLS : if (C_INCLUDE_DRE = 1) generate
    
       -- local signals
       signal lsig_s_h_dre_autodest  : std_logic := '0';
       signal lsig_s_h_dre_new_align : std_logic := '0';
    
       begin
    
        
         mm2s_dre_new_align     <= lsig_s_h_dre_new_align;
         
         
         
         
         -- Autodest is asserted on a new parent command and the 
         -- previous parent command was not delimited with a EOF
         mm2s_dre_use_autodest  <= lsig_s_h_dre_autodest;
         
         
         
         
         -- Assign the DRE Source and Destination Alignments
         -- Only used when mm2s_dre_new_align is asserted 
         mm2s_dre_src_align     <= sig_next_dre_src_align_reg ;
         mm2s_dre_dest_align    <= sig_next_dre_dest_align_reg;
         
         
         -- Assert the Flush flag when the MMap Tlast input of the current transfer is
         -- asserted and the next transfer is not sequential and not the last 
         -- transfer of a packet.
         mm2s_dre_flush         <= mm2s_rlast and
                                   not(sig_next_sequential_reg) and   
                                   not(sig_next_eof_reg);
        
        
        
         
         
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_S_H_NEW_ALIGN
         --
         -- Process Description:
         --   Generates the new alignment command flag to the DRE.
         --
         -------------------------------------------------------------
         IMP_S_H_NEW_ALIGN : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset   = '1') then
                   
                   lsig_s_h_dre_new_align <= '0';
                 
                 
                 Elsif (sig_push_dqual_reg = '1' and
                        sig_fifo_next_drr  = '1') Then
                 
                   lsig_s_h_dre_new_align <= '1';
                 
                 elsif (sig_pop_dqual_reg = '1') then
                   
                   lsig_s_h_dre_new_align <=  sig_next_cmd_cmplt_reg and
                                             not(sig_next_sequential_reg) and
                                             not(sig_next_eof_reg);
                 
                 Elsif (sig_good_mmap_dbeat = '1') Then
                 
                   lsig_s_h_dre_new_align <= '0';
                 
                 
                 else
                   
                   null; -- hold current state
                 
                 end if; 
              end if;       
            end process IMP_S_H_NEW_ALIGN; 
        
        
        
         
         
        
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_S_H_AUTODEST
         --
         -- Process Description:
         --   Generates the control for the DRE indicating whether the
         -- DRE destination alignment should be derived from the write
         -- strobe stat of the last completed data-beat to the AXI 
         -- stream output.
         --
         -------------------------------------------------------------
         IMP_S_H_AUTODEST : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset   = '1') then
                   
                   lsig_s_h_dre_autodest <= '0';
                 
                 
                 Elsif (sig_push_dqual_reg = '1' and
                        sig_fifo_next_drr  = '1') Then
                   
                   lsig_s_h_dre_autodest <= '0';
                 
                 elsif (sig_pop_dqual_reg = '1') then
                   
                   lsig_s_h_dre_autodest <=  sig_next_cmd_cmplt_reg and
                                             not(sig_next_sequential_reg) and
                                             not(sig_next_eof_reg);
                 
                 Elsif (lsig_s_h_dre_new_align = '1' and
                        sig_good_mmap_dbeat    = '1') Then
                 
                   lsig_s_h_dre_autodest <= '0';
                 
                 
                 else
                   
                   null; -- hold current state
                 
                 end if; 
              end if;       
            end process IMP_S_H_AUTODEST; 
        
        
        
        
       end generate GEN_INCLUDE_DRE_CNTLS;
   
   
   
   
   
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   -------  Soft Shutdown Logic ------------------------------- 
    
    
    -- Assign the output port skid buf control
    data2skid_halt      <= sig_data2skid_halt;
    
    -- Create a 1 clock wide pulse to tell the output
    -- stream skid buffer to shut down its outputs
    sig_data2skid_halt  <=  sig_halt_reg_dly2 and 
                            not(sig_halt_reg_dly3);
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_HALT_REQ_REG
    --
    -- Process Description:
    --   Implements the flop for capturing the Halt request from 
    -- the Reset module.
    --
    -------------------------------------------------------------
    IMP_HALT_REQ_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_halt_reg      <= '0';
            
            elsif (rst2data_stop_request = '1') then
              
              sig_halt_reg <= '1';
            
            else
              null;  -- Hold current State
            end if; 
         end if;       
       end process IMP_HALT_REQ_REG; 
  
  
   
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_HALT_REQ_REG_DLY
    --
    -- Process Description:
    --   Implements the flops for delaying the halt request by 3
    -- clocks to allow the Address Controller to halt before the
    -- Data Contoller can safely indicate it has exhausted all
    -- transfers committed to the AXI Address Channel by the Address
    -- Controller.
    --
    -------------------------------------------------------------
    IMP_HALT_REQ_REG_DLY : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_halt_reg_dly1 <= '0';
              sig_halt_reg_dly2 <= '0';
              sig_halt_reg_dly3 <= '0';
            
            else
              
              sig_halt_reg_dly1 <= sig_halt_reg;
              sig_halt_reg_dly2 <= sig_halt_reg_dly1;
              sig_halt_reg_dly3 <= sig_halt_reg_dly2;
            
            end if; 
         end if;       
       end process IMP_HALT_REQ_REG_DLY; 
  
  
   
   
   
   
   
   
   
   
   
   
      
      
  end implementation;
