  -------------------------------------------------------------------------------
  -- axi_datamover_rd_sf.vhd
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
  -- Filename:        axi_datamover_rd_sf.vhd
  --
  -- Description:     
  --    This file implements the AXI DataMover Read (MM2S) Store and Forward module. 
  --  The design utilizes the AXI DataMover's new address pipelining
  --  control function. The design is such that predictive address  
  --  pipelining can be supported on the AXI Read Bus without over-commiting 
  --  the internal Data FIFO and potentially throttling the Read Data Channel 
  --  if the Data FIFO goes full. 
  -- 
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  library lib_pkg_v1_0;
  use lib_pkg_v1_0.lib_pkg.all;
  use lib_pkg_v1_0.lib_pkg.clog2;

  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_sfifo_autord;
  use axi_datamover_v5_1.axi_datamover_fifo;

  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_rd_sf is
    generic (
      
      C_SF_FIFO_DEPTH        : Integer range 128 to 8192 := 512;
        -- Sets the desired depth of the internal Data FIFO.
      
      C_MAX_BURST_LEN        : Integer range  2 to  256 :=  16;
        -- Indicates the max burst length being used by the external
        -- AXI4 Master for each AXI4 transfer request.
        
      C_DRE_IS_USED          : Integer range   0 to    1 :=   0;
        -- Indicates if the external Master is utilizing a DRE on
        -- the stream input to this module.
         
      C_DRE_CNTL_FIFO_DEPTH  : Integer range  1 to  32 :=  1;
        -- Specifies the depth of the internal dre control queue fifo
      
      C_DRE_ALIGN_WIDTH      : Integer range  1 to   3 :=  2;
        -- Sets the width of the DRE alignment control ports
      
      C_MMAP_DWIDTH          : Integer range   32 to  1024 := 64;
        -- Sets the AXI4 Memory Mapped Bus Data Width 
      
      C_STREAM_DWIDTH        : Integer range   8 to  1024 :=  32;
        -- Sets the Stream Data Width for the Input and Output
        -- Data streams.
        
      C_STRT_SF_OFFSET_WIDTH : Integer range   1 to 7 :=  2;
        -- Sets the bit width of the starting address offset port
        -- This should be set to log2(C_MMAP_DWIDTH/C_STREAM_DWIDTH)
    C_ENABLE_MM2S_TKEEP             : integer range 0 to 1 := 1; 
        
      C_TAG_WIDTH            : Integer range  1 to   8 :=  4;
        -- Indicates the width of the Tag field of the input DRE command
        
      C_FAMILY               : String  := "virtex7"
        -- Indicates the target FPGA Family.
      
      );
    port (
      
      -- Clock and Reset inputs --------------------------------------------
                                                                          --
      aclk                    : in  std_logic;                            --
         -- Primary synchronization clock for the Master side             --
         -- interface and internal logic. It is also used                 --
         -- for the User interface synchronization when                   --
         -- C_STSCMD_IS_ASYNC = 0.                                        --
                                                                          --
      -- Reset input                                                      --
      reset                   : in  std_logic;                            --
         -- Reset used for the internal syncronization logic              --
      ----------------------------------------------------------------------
    
    
      -- DataMover Read Side Address Pipelining Control Interface ----------
                                                                          --
      ok_to_post_rd_addr      : Out  Std_logic;                           --
        -- Indicates that the transfer token pool has at least            --
        -- one token available to borrow                                  --
                                                                          --
      rd_addr_posted          : In std_logic;                             --
        -- Indication that a read address has been posted to AXI4         --
                                                                          --
      rd_xfer_cmplt           : In std_logic;                             --
        -- Indicates that the Datamover has completed a Read Data         --
        -- transfer on the AXI4                                           --
      ----------------------------------------------------------------------
      
       
        
      -- Read Side Stream In from DataMover MM2S Read Data Controller ----------------------
                                                                                          --
      sf2sin_tready           : Out  Std_logic;                                           --
        -- DRE  Stream READY input                                                        --
                                                                                          --
      sin2sf_tvalid           : In  std_logic;                                            --
        -- DRE Stream VALID Output                                                        --
                                                                                          --
      sin2sf_tdata            : In  std_logic_vector(C_MMAP_DWIDTH-1 downto 0);           --
        -- DRE  Stream DATA input                                                         --
                                                                                          --
      sin2sf_tkeep            : In std_logic_vector((C_MMAP_DWIDTH/8)-1 downto 0);        --   
        -- DRE  Stream STRB input                                                         --
                                                                                          --
      sin2sf_tlast            : In std_logic;                                             --
        -- DRE  Xfer LAST input                                                           --
      --------------------------------------------------------------------------------------

      
      -- RDC Store and Forward Supplimental Controls ---------------------
      -- These are time aligned and qualified with the RDC Stream Input --
                                                                        --
      data2sf_cmd_cmplt       : In std_logic;                           --
      data2sf_dre_flush       : In std_logic;                           --
      --------------------------------------------------------------------
     
     
               
                
      -- DRE Control Interface from the Command Calculator  -----------------------------
                                                                                       --
      dre2mstr_cmd_ready      : Out std_logic ;                                        --
        -- Indication from the DRE that the command is being                           --
        -- accepted from the Command Calculator                                        --
                                                                                       --
      mstr2dre_cmd_valid      : In std_logic;                                          --
        -- The next command valid indication to the DRE                                --
        -- from the Command Calculator                                                 --
                                                                                       --
      mstr2dre_tag            : In std_logic_vector(C_TAG_WIDTH-1 downto 0);           --
        -- The next command tag                                                        --
                                                                                       --
      mstr2dre_dre_src_align  : In std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);     --
        -- The source (input) alignment for the DRE                                    --
                                                                                       --
      mstr2dre_dre_dest_align : In std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);     --
        -- The destinstion (output) alignment for the DRE                              --
                                                                                       --
      -- mstr2dre_btt            : In std_logic_vector(C_BTT_USED-1 downto 0);            --
      --   -- The bytes to transfer value for the input command                           --
                                                                                       --
      mstr2dre_drr            : In std_logic;                                          --
        -- The starting tranfer of a sequence of transfers                             --
                                                                                       --
      mstr2dre_eof            : In std_logic;                                          --
        -- The endiing tranfer of a sequence of transfers                              --
                                                                                       --
      -- mstr2dre_cmd_cmplt      : In std_logic;                                          --
      --   -- The last tranfer command of a sequence of transfers                         --
      --   -- spawned from a single parent command                                        --
                                                                                       --
      mstr2dre_calc_error     : In std_logic;                                          --
        -- Indication if the next command in the calculation pipe                      --
        -- has a calculation error                                                     --
                                                                                       --
      mstr2dre_strt_offset    : In std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0);--
        -- Outputs the starting offset of a transfer. This is used with Store          --
        -- and Forward Packer/Unpacker logic                                           --
      -----------------------------------------------------------------------------------



     -- MM2S DRE Control  -------------------------------------------------------------
                                                                                     --
      sf2dre_new_align      : Out std_logic;                                         --
        -- Active high signal indicating new DRE aligment required                   --
                                                                                     --
      sf2dre_use_autodest   : Out std_logic;                                         --
        -- Active high signal indicating to the DRE to use an auto-                  --
        -- calculated desination alignment based on the last transfer                --
                                                                                     --
      sf2dre_src_align      : Out std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);    --
        -- Bit field indicating the byte lane of the first valid data byte           --
        -- being sent to the DRE                                                     --
                                                                                     --
      sf2dre_dest_align     : Out std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);    --
        -- Bit field indicating the desired byte lane of the first valid data byte   --
        -- to be output by the DRE                                                   --
                                                                                     --
      sf2dre_flush          : Out std_logic;                                         --
        -- Active high signal indicating to the DRE to flush the current             --
        -- contents to the output register in preparation of a new alignment         --
        -- that will be comming on the next transfer input                           --
      ---------------------------------------------------------------------------------
               
                
                
                
      -- Stream Out  -----------------------------------------------------------------------
                                                                                          --
      sout2sf_tready          : In  std_logic;                                            --
        -- Write READY input from the Stream Master                                       --
                                                                                          --
      sf2sout_tvalid          : Out  std_logic;                                           --
        -- Write VALID output to the Stream Master                                        --
                                                                                          --
      sf2sout_tdata           : Out  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);        --
        -- Write DATA output to the Stream Master                                         --
                                                                                          --
      sf2sout_tkeep           : Out  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);    --
        -- Write DATA output to the Stream Master                                         --
                                                                                          --
      sf2sout_tlast           : Out  std_logic                                            --
        -- Write LAST output to the Stream Master                                         --
      --------------------------------------------------------------------------------------
 
      );
  
  end entity axi_datamover_rd_sf;
  
  
  architecture implementation of axi_datamover_rd_sf is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Functions ---------------------------------------------------------------------------
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_fifo_cnt_width
    --
    -- Function Description:
    --   simple function to set the width of the data fifo read 
    -- and write count outputs. 
    -------------------------------------------------------------------
    function funct_get_fifo_cnt_width (fifo_depth : integer) 
             return integer is
    
      Variable temp_width : integer := 8;
    
    begin
    
      if (fifo_depth = 1) then
      
         temp_width := 1;
      
      elsif (fifo_depth  = 2) then
      
         temp_width := 2;
      
      elsif (fifo_depth  <= 4) then
      
         temp_width := 3;
      
      elsif (fifo_depth  <= 8) then
      
         temp_width := 4;
      
      elsif (fifo_depth  <= 16) then
      
         temp_width := 5;
      
      elsif (fifo_depth  <= 32) then
      
         temp_width := 6;
      
      elsif (fifo_depth  <= 64) then
      
         temp_width := 7;
      
      elsif (fifo_depth  <= 128) then
      
         temp_width := 8;
      
      elsif (fifo_depth  <= 256) then
      
         temp_width := 9;
      
      elsif (fifo_depth  <= 512) then
      
         temp_width := 10;
      
      elsif (fifo_depth  <= 1024) then
      
         temp_width := 11;
      
      elsif (fifo_depth  <= 2048) then
      
         temp_width := 12;
      
      elsif (fifo_depth  <= 4096) then
      
         temp_width := 13;
      
      else -- assume 8192 depth
      
         temp_width := 14;
      
      end if;
      
      
      Return (temp_width);
     
    
    end function funct_get_fifo_cnt_width;
    
    
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_wrcnt_lsrip
    --
    -- Function Description:
    --   Calculates the ls index of the upper slice of the data fifo
    -- write count needed to repesent one max burst worth of data
    -- present in the fifo.
    --
    -------------------------------------------------------------------
    function funct_get_wrcnt_lsrip (max_burst_dbeats : integer) return integer is
    
      Variable temp_ls_index : Integer := 0;
    
    begin
      
      if (max_burst_dbeats <= 2) then
      
        temp_ls_index := 1;
      
      elsif (max_burst_dbeats <= 4) then
      
        temp_ls_index := 2;
      
      elsif (max_burst_dbeats <= 8) then
      
        temp_ls_index := 3;
      
      elsif (max_burst_dbeats <= 16) then
      
        temp_ls_index := 4;
      
      elsif (max_burst_dbeats <= 32) then
      
        temp_ls_index := 5;
      
      elsif (max_burst_dbeats <= 64) then
      
        temp_ls_index := 6;
      
      elsif (max_burst_dbeats <= 128) then
      
        temp_ls_index := 7;
      
      else
      
        temp_ls_index := 8;
      
      end if;
      
      Return (temp_ls_index);
      
      
    end function funct_get_wrcnt_lsrip;
    
     
     
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_stall_thresh
    --
    -- Function Description:
    -- Calculates the Stall threshold for the input side of the Data
    -- FIFO. If DRE is being used by the DataMover, then the threshold
    -- must be reduced to account for the potential of an extra write
    -- databeat per request (DRE alignment dependent).
    --
    -------------------------------------------------------------------
    function funct_get_stall_thresh (dre_is_used         : integer;
                                     max_xfer_length     : integer;
                                     data_fifo_depth     : integer;
                                     pipeline_delay_clks : integer;
                                     fifo_settling_clks  : integer) return integer is
    
      Constant DRE_PIPE_DELAY             : integer := 2; -- clks
      
      Variable var_num_max_xfers_allowed  : Integer := 0;
      Variable var_dre_dbeat_overhead     : Integer := 0;
      Variable var_delay_fudge_factor     : Integer := 0;    
      Variable var_thresh_headroom        : Integer := 0;
      Variable var_stall_thresh           : Integer := 0;
      
    begin
    
      var_num_max_xfers_allowed := data_fifo_depth/max_xfer_length;
      
      var_dre_dbeat_overhead    := var_num_max_xfers_allowed * dre_is_used;
      
      
      var_delay_fudge_factor    := (dre_is_used * DRE_PIPE_DELAY) + 
                                   pipeline_delay_clks            + 
                                   fifo_settling_clks;
      
      var_thresh_headroom       := max_xfer_length        + 
                                   var_dre_dbeat_overhead + 
                                   var_delay_fudge_factor;
      
      -- Scale the result to be in max transfer length increments
      var_stall_thresh          := (data_fifo_depth - var_thresh_headroom)/max_xfer_length;
      
      Return (var_stall_thresh);
      
      
    end function funct_get_stall_thresh;
    
    
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_size_drecntl_fifo
    --
    -- Function Description:
    --  Assures that the DRE control fifo depth is at least 4 deep else it
    -- is equal to the number of max burst transfers that can fit in the
    -- Store and Forward Data FIFO.
    --
    -------------------------------------------------------------------
    function funct_size_drecntl_fifo (sf_fifo_depth    : integer;
                                      max_burst_length : integer) return integer is
    
      
      Constant NEEDED_FIFO_DEPTH : integer := sf_fifo_depth/max_burst_length;
      
      
      Variable temp_fifo_depth : Integer := 4;
    
    begin
    
      If (NEEDED_FIFO_DEPTH < 4) Then
    
        temp_fifo_depth := 4;
      
      Else 

        temp_fifo_depth := NEEDED_FIFO_DEPTH;
          
      End if;
      
      
      Return (temp_fifo_depth);
      
      
    end function funct_size_drecntl_fifo;
    

     
     

    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_cntr_width
    --
    -- Function Description:
    --  Detirmine the width needed for the address offset counter used
    -- for the data fifo mux selects.
    --
    -------------------------------------------------------------------
    function funct_get_cntr_width (num_count_states : integer) return integer is
    
     Variable lvar_temp_width : Integer := 1;
    
    begin
      
      if (num_count_states <= 2) then
      
         lvar_temp_width := 1;
      
      elsif (num_count_states <= 4) then
      
         lvar_temp_width := 2;
      
      elsif (num_count_states <= 8) then
      
         lvar_temp_width := 3;
      
      elsif (num_count_states <= 16) then
      
         lvar_temp_width := 4;
      
      elsif (num_count_states <= 32) then
      
         lvar_temp_width := 5;
      
      elsif (num_count_states <= 64) then
      
         lvar_temp_width := 6;
      
      Else   -- 128 cnt states
         
         lvar_temp_width := 7;
      
      end if;
      
      
      
      Return (lvar_temp_width);
      
      
      
    end function funct_get_cntr_width;
    
    
    
    
    -- Constants ---------------------------------------------------------------------------
    
    Constant LOGIC_LOW                 : std_logic := '0';
    Constant LOGIC_HIGH                : std_logic := '1';
    
    Constant BLK_MEM_FIFO              : integer := 1;
    Constant SRL_FIFO                  : integer := 0;
    Constant NOT_NEEDED                : integer := 0;
    
    
    Constant MMAP_TKEEP_WIDTH          : integer := C_MMAP_DWIDTH/8; -- bits
    Constant TLAST_WIDTH               : integer := 1;               -- bits
    Constant CMPLT_WIDTH               : integer := 1;               -- bits
    Constant DRE_FLUSH_WIDTH           : integer := 1;               -- bits
    
    
    Constant DATA_FIFO_DEPTH           : integer := C_SF_FIFO_DEPTH;
    Constant DATA_FIFO_CNT_WIDTH       : integer := funct_get_fifo_cnt_width(DATA_FIFO_DEPTH);
    Constant DF_WRCNT_RIP_LS_INDEX     : integer := funct_get_wrcnt_lsrip(C_MAX_BURST_LEN);
    Constant DATA_FIFO_WIDTH           : integer := C_MMAP_DWIDTH    +
                                                    MMAP_TKEEP_WIDTH*C_ENABLE_MM2S_TKEEP +
                                                    TLAST_WIDTH      +
                                                    CMPLT_WIDTH      +
                                                    DRE_FLUSH_WIDTH;
    
    Constant DATA_OUT_LSB_INDEX        : integer := 0;
    Constant DATA_OUT_MSB_INDEX        : integer := C_MMAP_DWIDTH-1;
    
    Constant TKEEP_OUT_LSB_INDEX       : integer := DATA_OUT_MSB_INDEX+1;
    Constant TKEEP_OUT_MSB_INDEX       : integer := (TKEEP_OUT_LSB_INDEX+MMAP_TKEEP_WIDTH*C_ENABLE_MM2S_TKEEP)-1*C_ENABLE_MM2S_TKEEP;
    
    Constant TLAST_OUT_INDEX           : integer := TKEEP_OUT_MSB_INDEX+1*C_ENABLE_MM2S_TKEEP;
    Constant CMPLT_OUT_INDEX           : integer := TLAST_OUT_INDEX+1;
    Constant DRE_FLUSH_OUT_INDEX       : integer := CMPLT_OUT_INDEX+1;
    
    
    Constant TOKEN_POOL_SIZE           : integer := C_SF_FIFO_DEPTH / C_MAX_BURST_LEN;
    
    Constant TOKEN_CNTR_WIDTH          : integer := clog2(TOKEN_POOL_SIZE)+1;
    
    Constant TOKEN_CNT_ZERO            : Unsigned(TOKEN_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(0, TOKEN_CNTR_WIDTH);
    
    Constant TOKEN_CNT_ONE             : Unsigned(TOKEN_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, TOKEN_CNTR_WIDTH);
    
    Constant TOKEN_CNT_MAX             : Unsigned(TOKEN_CNTR_WIDTH-1 downto 0) :=  
                                         TO_UNSIGNED(TOKEN_POOL_SIZE, TOKEN_CNTR_WIDTH);
    
    Constant THRESH_COMPARE_WIDTH      : integer := TOKEN_CNTR_WIDTH+2;
    
              
    Constant RD_PATH_PIPE_DEPTH        : integer := 2; -- clocks excluding DRE
    
    Constant WRCNT_SETTLING_TIME       : integer := 2; -- data fifo push or pop settling clocks
    
    
    Constant DRE_COMPENSATION          : integer := 0; -- DRE does not contribute since it is on
                                                       -- the output side of the Store and Forward
    
    Constant RD_ADDR_POST_STALL_THRESH : integer := 
                                         funct_get_stall_thresh(DRE_COMPENSATION   ,
                                                                C_MAX_BURST_LEN    ,
                                                                C_SF_FIFO_DEPTH    ,
                                                                RD_PATH_PIPE_DEPTH ,
                                                                WRCNT_SETTLING_TIME);
    
    Constant RD_ADDR_POST_STALL_THRESH_US : Unsigned(THRESH_COMPARE_WIDTH-1 downto 0) := 
                                            TO_UNSIGNED(RD_ADDR_POST_STALL_THRESH , 
                                                        THRESH_COMPARE_WIDTH);
    
    
    Constant UNCOM_WRCNT_1             : Unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, DATA_FIFO_CNT_WIDTH);
    
    Constant UNCOM_WRCNT_0             : Unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(0, DATA_FIFO_CNT_WIDTH);
    

    Constant USE_SYNC_FIFO             : integer := 0;
    Constant SRL_FIFO_PRIM             : integer := 2;
    
    Constant TAG_WIDTH                 : integer := C_TAG_WIDTH;
    Constant SRC_ALIGN_WIDTH           : integer := C_DRE_ALIGN_WIDTH;
    Constant DEST_ALIGN_WIDTH          : integer := C_DRE_ALIGN_WIDTH;
    Constant DRR_WIDTH                 : integer := 1;
    Constant EOF_WIDTH                 : integer := 1;
    Constant CALC_ERR_WIDTH            : integer := 1;
    Constant SF_OFFSET_WIDTH           : integer := C_STRT_SF_OFFSET_WIDTH;
    
    

    
    
    
    -- Signals ---------------------------------------------------------------------------
    
    signal sig_good_sin_strm_dbeat    : std_logic := '0';
    signal sig_strm_sin_ready         : std_logic := '0';
    
    signal sig_good_sout_strm_dbeat   : std_logic := '0';
    signal sig_sout2sf_tready         : std_logic := '0';
    signal sig_sf2sout_tvalid         : std_logic := '0';
    signal sig_sf2sout_tdata          : std_logic_vector(C_STREAM_DWIDTH-1 downto 0) := (others => '0');
    signal sig_sf2sout_tkeep          : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_sf2sout_tlast          : std_logic := '0';
    
    signal sig_sf2dre_flush           : std_logic := '0';
    
    signal sig_push_data_fifo         : std_logic := '0';
    signal sig_pop_data_fifo          : std_logic := '0';
    signal sig_data_fifo_full         : std_logic := '0';
    signal sig_data_fifo_data_in      : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_dvalid       : std_logic := '0';
    signal sig_data_fifo_data_out     : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_wr_cnt       : std_logic_vector(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_wr_cnt_unsgnd     : unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    
    signal sig_wrcnt_mblen_slice      : unsigned(DATA_FIFO_CNT_WIDTH-1 downto 
                                                 DF_WRCNT_RIP_LS_INDEX) := (others => '0');
    
    signal sig_ok_to_post_rd_addr     : std_logic := '0';
    signal sig_rd_addr_posted         : std_logic := '0';
    signal sig_rd_xfer_cmplt          : std_logic := '0';
    signal sig_taking_last_token      : std_logic := '0';
    signal sig_stall_rd_addr_posts    : std_logic := '0';
    
    signal sig_incr_token_cntr        : std_logic := '0';
    signal sig_decr_token_cntr        : std_logic := '0';
    signal sig_token_eq_max           : std_logic := '0';
    signal sig_token_eq_zero          : std_logic := '0';
    signal sig_token_eq_one           : std_logic := '0';
    signal sig_token_cntr             : Unsigned(TOKEN_CNTR_WIDTH-1 downto 0) := (others => '0');
    
    signal sig_tokens_commited        : Unsigned(TOKEN_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_commit_plus_actual     : unsigned(THRESH_COMPARE_WIDTH-1 downto 0) := (others => '0');
    
    signal sig_cntl_fifo_has_data     : std_logic := '0';
    signal sig_get_cntl_fifo_data     : std_logic := '0';
                    
    signal sig_curr_tag_reg           : std_logic_vector(TAG_WIDTH-1 downto 0)        := (others => '0');
    signal sig_curr_src_align_reg     : std_logic_vector(SRC_ALIGN_WIDTH-1 downto 0)  := (others => '0');
    signal sig_curr_dest_align_reg    : std_logic_vector(DEST_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_curr_drr_reg           : std_logic := '0';
    signal sig_curr_eof_reg           : std_logic := '0';
    signal sig_curr_calc_error_reg    : std_logic := '0';
    signal sig_curr_strt_offset_reg   : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
    
    signal sig_ld_dre_cntl_reg        : std_logic := '0';
    
    signal sig_dfifo_data_out         : std_logic_vector(C_MMAP_DWIDTH-1 downto 0)    := (others => '0');
    signal sig_dfifo_tkeep_out        : std_logic_vector(MMAP_TKEEP_WIDTH-1 downto 0) := (others => '0');
    signal sig_dfifo_tlast_out        : std_logic := '0';
    signal sig_dfifo_cmd_cmplt_out    : std_logic := '0';
    signal sig_dfifo_dre_flush_out    : std_logic := '0';
    
  
  begin --(architecture implementation)
  
   
   
    -- Read Side (MM2S) Control Flags port connections
    ok_to_post_rd_addr       <= sig_ok_to_post_rd_addr ;
    sig_rd_addr_posted       <= rd_addr_posted         ;
    sig_rd_xfer_cmplt        <= rd_xfer_cmplt          ;
    
    
    
    --  Output Stream Port connections
    sig_sout2sf_tready       <= sout2sf_tready        ;
    sf2sout_tvalid           <= sig_sf2sout_tvalid    ;
    sf2sout_tdata            <= sig_sf2sout_tdata     ; 
    --sf2sout_tkeep            <= sig_sf2sout_tkeep     ;
    sf2sout_tlast            <= sig_sf2sout_tlast and
                                sig_sf2sout_tvalid    ;
    
   



GEN_MM2S_TKEEP_ENABLE4 : if C_ENABLE_MM2S_TKEEP = 1 generate
begin

    sf2sout_tkeep            <= sig_sf2sout_tkeep     ;
 
end generate GEN_MM2S_TKEEP_ENABLE4;

GEN_MM2S_TKEEP_DISABLE4 : if C_ENABLE_MM2S_TKEEP = 0 generate
begin

  sf2sout_tkeep        <= (others => '1');

end generate GEN_MM2S_TKEEP_DISABLE4;




 
    -- Input Stream port connections 
    sf2sin_tready            <= sig_strm_sin_ready;
    
    sig_strm_sin_ready       <= not(sig_data_fifo_full); -- Throttle if Read Side Data fifo goes full.
                                                         -- This should never happen if read address 
                                                         -- posting control is working properly.
    
    
    -- Stream transfer qualifiers
    
    sig_good_sin_strm_dbeat  <= sin2sf_tvalid and
                                sig_strm_sin_ready;
                               
 
    sig_good_sout_strm_dbeat <= sig_sf2sout_tvalid and  
                                sig_sout2sf_tready;     
  
  
  
  
  
  
  
 ---------------------------------------------------------------- 
 -- Unpacking Logic    ------------------------------------------
 ---------------------------------------------------------------- 
 
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: OMIT_UNPACKING
    --
    -- If Generate Description:
    --    Omits any unpacking logic in the Store and Forward module.
    -- The Stream and MMap data widths are the same. The Data FIFO
    -- output can be connected directly to the stream outputs.
    --
    ------------------------------------------------------------
    OMIT_UNPACKING : if (C_MMAP_DWIDTH = C_STREAM_DWIDTH) generate
    
      signal lsig_cmd_loaded          : std_logic := '0';
      signal lsig_ld_cmd              : std_logic := '0';
      signal lsig_cmd_cmplt_dbeat     : std_logic := '0';
      signal lsig_cmd_cmplt           : std_logic := '0';
      
      begin
   
            
            
        -- Data FIFO Output to the stream attachments
        sig_sf2sout_tvalid      <=  sig_data_fifo_dvalid and 
                                    lsig_cmd_loaded     ;
        
        sig_sf2sout_tdata       <=  sig_dfifo_data_out  ;
        
        sig_sf2sout_tkeep       <=  sig_dfifo_tkeep_out ;
        
        sig_sf2sout_tlast       <=  sig_dfifo_tlast_out ;
        
        sig_sf2dre_flush        <=  sig_dfifo_dre_flush_out   ;
        
         
         
        -- Control for reading the Data FIFO
        sig_pop_data_fifo       <=  lsig_cmd_loaded    and
                                    sig_sout2sf_tready and 
                                    sig_data_fifo_dvalid;
        
        -- Control for reading the Command/Offset FIFO
        sig_get_cntl_fifo_data  <= lsig_ld_cmd ;
      
        
        -- Control for loading the DRE Control Reg
        sig_ld_dre_cntl_reg     <= lsig_ld_cmd ;
        
       
        lsig_cmd_cmplt_dbeat    <= sig_dfifo_cmd_cmplt_out and
                                   lsig_cmd_loaded         and
                                   sig_data_fifo_dvalid    and
                                   sig_sout2sf_tready  ;

     
        -- Generate the control that loads the DRE
        lsig_ld_cmd             <= (sig_cntl_fifo_has_data and  -- startup or gap case
                                    not(lsig_cmd_loaded))  or
                                   (sig_cntl_fifo_has_data and  -- back to back commands
                                    lsig_cmd_cmplt_dbeat);
                                      
         
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_CMD_LOADED
        --
        -- Process Description:
        --  Implements the flop indicating a command from the cmd fifo
        -- has been loaded into the DRE Output Register.
        --
        -------------------------------------------------------------
        IMP_CMD_LOADED : process (aclk)
          begin
            if (aclk'event and aclk = '1') then
              if (reset = '1') then
       
                lsig_cmd_loaded <= '0';
       
              Elsif (lsig_ld_cmd = '1' ) Then
              
                lsig_cmd_loaded <= '1';
              
              elsif (sig_cntl_fifo_has_data = '0' and   -- No more commands queued and
                     lsig_cmd_cmplt_dbeat   = '1') then
       
                lsig_cmd_loaded <= '0';
       
              else
       
                null;  -- Hold Current State
       
              end if; 
            end if;       
          end process IMP_CMD_LOADED; 
        
        
        
       
       
       
      
      end generate OMIT_UNPACKING;
    
     
    
    
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: INCLUDE_UNPACKING
    --
    -- If Generate Description:
    --    Includes unpacking logic in the Store and Forward module.
    -- The MMap Data bus is wider than the Stream width.
    --
    ------------------------------------------------------------
    INCLUDE_UNPACKING : if (C_MMAP_DWIDTH > C_STREAM_DWIDTH) generate
    
      Constant MMAP2STRM_WIDTH_RATO  : integer := C_MMAP_DWIDTH/C_STREAM_DWIDTH;
    
      Constant DATA_SLICE_WIDTH      : integer := C_STREAM_DWIDTH;
      
      Constant TKEEP_SLICE_WIDTH     : integer := C_STREAM_DWIDTH/8;
      
      Constant FLAG_SLICE_WIDTH      : integer := TLAST_WIDTH;
      
      Constant OFFSET_CNTR_WIDTH     : integer := funct_get_cntr_width(MMAP2STRM_WIDTH_RATO);
      
      Constant OFFSET_CNT_ONE        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(1, OFFSET_CNTR_WIDTH);
      
      Constant OFFSET_CNT_MAX        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(MMAP2STRM_WIDTH_RATO-1, OFFSET_CNTR_WIDTH);
      
      
      
      -- Types -----------------------------------------------------------------------------
      type lsig_data_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(DATA_SLICE_WIDTH-1 downto 0);

      type lsig_tkeep_slice_type is array(MMAP2STRM_WIDTH_RATO downto 0) of
                    std_logic_vector(TKEEP_SLICE_WIDTH-1 downto 0);

      type lsig_flag_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(FLAG_SLICE_WIDTH-1 downto 0);


       
      -- local signals
      
      signal lsig_0ffset_cntr         : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := (others => '0');
      signal lsig_ld_offset           : std_logic := '0';
      signal lsig_incr_offset         : std_logic := '0';
      signal lsig_offset_cntr_eq_max  : std_logic := '0';
      signal lsig_fifo_data_out_wide  : lsig_data_slice_type;
      signal lsig_fifo_tkeep_out_wide : lsig_tkeep_slice_type;
      signal lsig_mux_sel             : integer range 0 to MMAP2STRM_WIDTH_RATO-1;
      signal lsig_data_mux_out        : std_logic_vector(DATA_SLICE_WIDTH-1 downto 0) ;
      signal lsig_tkeep_mux_out       : std_logic_vector(TKEEP_SLICE_WIDTH-1 downto 0);
      signal lsig_tlast_out           : std_logic := '0';
      signal lsig_dre_flush_out       : std_logic := '0';
      signal lsig_this_fifo_wrd_done  : std_logic := '0';
      signal lsig_cmd_loaded          : std_logic := '0';
      signal lsig_cmd_cmplt_dbeat     : std_logic := '0';
      signal lsig_cmd_cmplt           : std_logic := '0';
      signal lsig_next_slice_tkeep_0  : std_logic := '0';
       
        
      begin
    
       
       sig_sf2sout_tvalid      <= sig_data_fifo_dvalid and 
                                  lsig_cmd_loaded      ;
       
       sig_sf2sout_tdata       <= lsig_data_mux_out    ;
       
       sig_sf2sout_tkeep       <= lsig_tkeep_mux_out(TKEEP_SLICE_WIDTH-1 downto 0);
      
       sig_sf2sout_tlast       <= lsig_tlast_out       ;
      
       sig_sf2dre_flush        <= lsig_dre_flush_out   ;
       

       
       
       -- Control for reading the Data FIFO
       sig_pop_data_fifo       <= lsig_this_fifo_wrd_done and
                                  lsig_cmd_loaded         and
                                  sig_sout2sf_tready      and 
                                  sig_data_fifo_dvalid;
     
       -- Control for reading the Command/Offset FIFO
       sig_get_cntl_fifo_data  <= lsig_ld_offset;
       
       
       -- Control for loading the DRE Control Reg
       sig_ld_dre_cntl_reg     <= lsig_ld_offset ;
       
       
       lsig_next_slice_tkeep_0 <= lsig_fifo_tkeep_out_wide(lsig_mux_sel+1)(0);
       
       
       -- Detirmine if a Command Complete condition exists
       lsig_cmd_cmplt  <= '1'
         when (sig_dfifo_cmd_cmplt_out = '1' and
               lsig_next_slice_tkeep_0 = '0')
         Else '0';
       
       
       
       -- Detirmine if a TLAST condition exists
       -- From the RDC via the Data FIFO
       lsig_tlast_out <= '1'
         when (sig_dfifo_tlast_out     = '1' and
               lsig_next_slice_tkeep_0 = '0')
         Else '0';
        
       
       -- Detimine if a DRE Flush condition exists
       -- From the RDC via the Data FIFO
       lsig_dre_flush_out <= '1'
         when (sig_dfifo_dre_flush_out = '1' and
               lsig_next_slice_tkeep_0 = '0')
         Else '0';
      
      
      
       
       
       lsig_cmd_cmplt_dbeat <= lsig_cmd_cmplt          and
                               lsig_cmd_loaded         and
                               sig_data_fifo_dvalid    and
                               sig_sout2sf_tready  ;

     
       
       -- Check to see if the FIFO output word is finished. This occurs
       -- when the offset counter is at max value or the tlast from the
       -- fifo is set and the LS TKEED of the next MS Slice is zero.
       lsig_this_fifo_wrd_done  <= '1'
         When (lsig_offset_cntr_eq_max = '1' or
              (lsig_cmd_cmplt_dbeat    = '1' and
               lsig_next_slice_tkeep_0 = '0'))
         Else '0';
      
       
        
       -- Generate the control that loads the starting address
       -- offset for the next input packet
       lsig_ld_offset          <= (sig_cntl_fifo_has_data and  -- startup or gap case
                                   not(lsig_cmd_loaded))  or
                                  (sig_cntl_fifo_has_data and  -- back to back commands
                                   lsig_cmd_cmplt_dbeat);
                                  
       -- Generate the control for incrementing the offset counter
       lsig_incr_offset        <= sig_good_sout_strm_dbeat;
       
       
       -- Check to see if the offset counter has reached its max
       -- value
       lsig_offset_cntr_eq_max <=  '1'
         when  (lsig_0ffset_cntr = OFFSET_CNT_MAX)
         Else '0';
       
       
       
        
        
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_CMD_LOADED
       --
       -- Process Description:
       --  Implements the flop indicating a command from the cmd fifo
       -- has been loaded into the unpacker control logic.
       --
       -------------------------------------------------------------
       IMP_CMD_LOADED : process (aclk)
         begin
           if (aclk'event and aclk = '1') then
             if (reset = '1') then
      
               lsig_cmd_loaded <= '0';
      
             Elsif (lsig_ld_offset = '1' ) Then
             
               lsig_cmd_loaded <= '1';
             
             elsif (sig_cntl_fifo_has_data = '0' and   -- No more commands queued
                    lsig_cmd_cmplt_dbeat   = '1') then
      
               lsig_cmd_loaded <= '0';
      
             else
      
               null;  -- Hold Current State
      
             end if; 
           end if;       
         end process IMP_CMD_LOADED; 
       
       
       
       
       
       
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_OFFSET_CNTR
       --
       -- Process Description:
       --  Implements the address offset counter that is used to 
       -- generate the data and tkeep mux selects.
       -- Note that the counter has to be loaded with the starting
       -- offset plus one to sync up with the data input.
       -------------------------------------------------------------
       IMP_OFFSET_CNTR : process (aclk)
         begin
           if (aclk'event and aclk = '1') then
              if (reset = '1') then
       
                lsig_0ffset_cntr <= (others => '0');
       
              Elsif (lsig_ld_offset = '1') Then
              
                lsig_0ffset_cntr <= UNSIGNED(sig_curr_strt_offset_reg);
              
              elsif (lsig_incr_offset = '1') then
       
                lsig_0ffset_cntr <= lsig_0ffset_cntr + OFFSET_CNT_ONE;
       
              else
       
                null;  -- Hold Current State
       
              end if; 
           end if;       
         end process IMP_OFFSET_CNTR; 
       
       
       
       
     
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: DO_DATA_CONVERTER
       --
       -- For Generate Description:
       --   This ForGen converts the FIFO output data and tkeep from a single
       -- std logic vector type to a vector of slices. 
       --
       ------------------------------------------------------------
       DO_DATA_CONVERTER : for slice_index in 1 to MMAP2STRM_WIDTH_RATO generate
       
       begin
        
         lsig_fifo_data_out_wide(slice_index-1) <=
                            sig_dfifo_data_out((slice_index*DATA_SLICE_WIDTH)-1 downto 
                            (slice_index-1)*DATA_SLICE_WIDTH);
        
         
         lsig_fifo_tkeep_out_wide(slice_index-1) <=
                            sig_dfifo_tkeep_out((slice_index*TKEEP_SLICE_WIDTH)-1 downto 
                            (slice_index-1)*TKEEP_SLICE_WIDTH);
         
        
       end generate DO_DATA_CONVERTER;
     
     
       -- Assign the extra tkeep slice to all zeros to allow for detection
       -- of the data word done when the ls tkeep bit of the next tkeep 
       -- slice is zero and the offset count is pointing to the last slice
       -- position.
       lsig_fifo_tkeep_out_wide(MMAP2STRM_WIDTH_RATO) <= (others => '0');

       
       
       -- Mux the appropriate data and tkeep slice to the stream output
       lsig_mux_sel       <=  TO_INTEGER(lsig_0ffset_cntr);
     
       lsig_data_mux_out  <=  lsig_fifo_data_out_wide(lsig_mux_sel) ; 
     
       lsig_tkeep_mux_out(TKEEP_SLICE_WIDTH-1 downto 0) <=  lsig_fifo_tkeep_out_wide(lsig_mux_sel);
       
      
       
       
      end generate INCLUDE_UNPACKING;
     
   
   
   
   
   
   
   
     
    
    
  
  
      ------------------------------------------------------------
      -- If Generate
      --
      -- Label: OMIT_DRE_CNTL
      --
      -- If Generate Description:
      --   This IfGen is used to omit the DRE control logic and 
      -- minimize the Control FIFO when MM2S DRE is not included
      -- in the MM2S. 
      --
      ------------------------------------------------------------
      OMIT_DRE_CNTL : if (C_DRE_IS_USED = 0) generate
      
        
        -- Constant Declarations ------------------------------------------------------------------
        
        Constant USE_SYNC_FIFO           : integer := 0;
        Constant SRL_FIFO_PRIM           : integer := 2;
        
        Constant TAG_WIDTH               : integer := C_TAG_WIDTH;
        Constant DRR_WIDTH               : integer := 1;
        Constant EOF_WIDTH               : integer := 1;
        Constant CALC_ERR_WIDTH          : integer := 1;
        Constant SF_OFFSET_WIDTH         : integer := C_STRT_SF_OFFSET_WIDTH;
        
        Constant SF_OFFSET_FIFO_DEPTH    : integer := funct_size_drecntl_fifo(C_DRE_CNTL_FIFO_DEPTH,
                                                                              C_MAX_BURST_LEN);
        
        
        Constant SF_OFFSET_FIFO_WIDTH    : Integer := TAG_WIDTH        +  -- Tag field
                                                      DRR_WIDTH        +  -- DRE Re-alignment Request Flag Field
                                                      EOF_WIDTH        +  -- EOF flag field
                                                      CALC_ERR_WIDTH   +  -- Calc error flag
                                                      SF_OFFSET_WIDTH;    -- Store and Forward Offset

        Constant TAG_STRT_INDEX          : integer := 0;
        Constant DRR_STRT_INDEX          : integer := TAG_STRT_INDEX + TAG_WIDTH;
        Constant EOF_STRT_INDEX          : integer := DRR_STRT_INDEX + DRR_WIDTH;
        Constant CALC_ERR_STRT_INDEX     : integer := EOF_STRT_INDEX + EOF_WIDTH;
        Constant SF_OFFSET_STRT_INDEX    : integer := CALC_ERR_STRT_INDEX+CALC_ERR_WIDTH;
        
       
        
        -- Signal Declarations --------------------------------------------------------------------
        
        signal sig_offset_fifo_data_in   : std_logic_vector(SF_OFFSET_FIFO_WIDTH-1 downto 0) := (others => '0');
        signal sig_offset_fifo_data_out  : std_logic_vector(SF_OFFSET_FIFO_WIDTH-1 downto 0) := (others => '0');
        signal sig_offset_fifo_wr_valid  : std_logic := '0';
        signal sig_offset_fifo_wr_ready  : std_logic := '0';
        signal sig_offset_fifo_rd_valid  : std_logic := '0';
        signal sig_offset_fifo_rd_ready  : std_logic := '0';
             
        
        
        begin
      
          
          -- PCC DRE Command interface handshake 
          dre2mstr_cmd_ready        <= sig_offset_fifo_wr_ready ;
          sig_offset_fifo_wr_valid  <= mstr2dre_cmd_valid       ;
          
          
          -- No DRE so no controls
          sf2dre_new_align          <= '0';
          sf2dre_use_autodest       <= '0';
          sf2dre_src_align          <= (others => '0');
          sf2dre_dest_align         <= (others => '0');
          sf2dre_flush              <= '0';
      
          -- No DRE so no alignment values
          sig_curr_src_align_reg    <= (others => '0');
          sig_curr_dest_align_reg   <= (others => '0');
          
          
          
          -- Format the input data word for the Offset FIFO Queue
          sig_offset_fifo_data_in   <= mstr2dre_strt_offset  &  -- MS field
                                       mstr2dre_calc_error   &   
                                       mstr2dre_eof          &   
                                       mstr2dre_drr          &   
                                       mstr2dre_tag;             -- LS Field
          
          
          
          sig_cntl_fifo_has_data    <= sig_offset_fifo_rd_valid ;
          sig_offset_fifo_rd_ready  <= sig_get_cntl_fifo_data   ;
          
          
          -- Rip the output fifo data word
          sig_curr_tag_reg          <= sig_offset_fifo_data_out((TAG_STRT_INDEX+TAG_WIDTH)-1 downto TAG_STRT_INDEX);
          sig_curr_drr_reg          <= sig_offset_fifo_data_out(DRR_STRT_INDEX);
          sig_curr_eof_reg          <= sig_offset_fifo_data_out(EOF_STRT_INDEX);
          sig_curr_calc_error_reg   <= sig_offset_fifo_data_out(CALC_ERR_STRT_INDEX);
          sig_curr_strt_offset_reg  <= sig_offset_fifo_data_out((SF_OFFSET_STRT_INDEX+SF_OFFSET_WIDTH)-1 downto 
                                                                SF_OFFSET_STRT_INDEX);


          
          
          
          
               
          ------------------------------------------------------------
          -- Instance: I_DRE_CNTL_FIFO
          --
          -- Description:
          -- Instance for the Offset Control FIFO. This is still needed
          -- by the unpacker logic to get the starting offset at the
          -- begining of an input packet coming out of the Store and 
          -- Forward data FIFO.
          --
          ------------------------------------------------------------
          I_DRE_CNTL_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
          generic map (

            C_DWIDTH             =>  SF_OFFSET_FIFO_WIDTH   , 
            C_DEPTH              =>  SF_OFFSET_FIFO_DEPTH   , 
            C_IS_ASYNC           =>  USE_SYNC_FIFO          , 
            C_PRIM_TYPE          =>  SRL_FIFO_PRIM          , 
            C_FAMILY             =>  C_FAMILY                 

            )
          port map (

            -- Write Clock and reset
            fifo_wr_reset        =>  reset                    , 
            fifo_wr_clk          =>  aclk                     , 

            -- Write Side
            fifo_wr_tvalid       =>  sig_offset_fifo_wr_valid , 
            fifo_wr_tready       =>  sig_offset_fifo_wr_ready , 
            fifo_wr_tdata        =>  sig_offset_fifo_data_in  , 
            fifo_wr_full         =>  open                     , 


            -- Read Clock and reset
            fifo_async_rd_reset  =>  aclk                     , 
            fifo_async_rd_clk    =>  reset                    , 

            -- Read Side
            fifo_rd_tvalid       =>  sig_offset_fifo_rd_valid , 
            fifo_rd_tready       =>  sig_offset_fifo_rd_ready , 
            fifo_rd_tdata        =>  sig_offset_fifo_data_out , 
            fifo_rd_empty        =>  open                    

            );





      
        end generate OMIT_DRE_CNTL;
      
      
      
      
      
     
     
     
      
      
      
      ------------------------------------------------------------
      -- If Generate
      --
      -- Label: INCLUDE_DRE_CNTL
      --
      -- If Generate Description:
      --   This IfGen is used to include the DRE control logic and 
      -- Control FIFO when MM2S DRE is included in the MM2S.
      --
      --
      ------------------------------------------------------------
      INCLUDE_DRE_CNTL : if (C_DRE_IS_USED = 1) generate
      
        
        -- Constant Declarations
        
        Constant DRECNTL_FIFO_DEPTH    : integer := funct_size_drecntl_fifo(C_DRE_CNTL_FIFO_DEPTH,
                                                                            C_MAX_BURST_LEN);
        
        
        Constant DRECNTL_FIFO_WIDTH    : Integer := TAG_WIDTH        +  -- Tag field
                                                    SRC_ALIGN_WIDTH  +  -- Source align field width
                                                    DEST_ALIGN_WIDTH +  -- Dest align field width
                                                    DRR_WIDTH        +  -- DRE Re-alignment Request Flag Field
                                                    EOF_WIDTH        +  -- EOF flag field
                                                    CALC_ERR_WIDTH   +  -- Calc error flag
                                                    SF_OFFSET_WIDTH;    -- Store and Forward Offset

        Constant TAG_STRT_INDEX        : integer := 0;
        Constant SRC_ALIGN_STRT_INDEX  : integer := TAG_STRT_INDEX + TAG_WIDTH;
        Constant DEST_ALIGN_STRT_INDEX : integer := SRC_ALIGN_STRT_INDEX + SRC_ALIGN_WIDTH;
        Constant DRR_STRT_INDEX        : integer := DEST_ALIGN_STRT_INDEX + DEST_ALIGN_WIDTH;
        Constant EOF_STRT_INDEX        : integer := DRR_STRT_INDEX + DRR_WIDTH;
        Constant CALC_ERR_STRT_INDEX   : integer := EOF_STRT_INDEX + EOF_WIDTH;
        Constant SF_OFFSET_STRT_INDEX  : integer := CALC_ERR_STRT_INDEX+CALC_ERR_WIDTH;
        
        
        
        
        
        signal sig_cmd_fifo_data_in        : std_logic_vector(DRECNTL_FIFO_WIDTH-1 downto 0) := (others => '0');
        signal sig_cmd_fifo_data_out       : std_logic_vector(DRECNTL_FIFO_WIDTH-1 downto 0) := (others => '0');
        signal sig_fifo_wr_cmd_valid       : std_logic := '0';
        signal sig_fifo_wr_cmd_ready       : std_logic := '0';
        signal sig_fifo_rd_cmd_valid       : std_logic := '0';
        signal sig_fifo_rd_cmd_ready       : std_logic := '0';
             
        signal sig_dre_align_ready         : std_logic := '0';
        signal sig_dre_align_valid_reg     : std_logic := '0';
        signal sig_dre_use_autodest_reg    : std_logic := '0';
        signal sig_dre_src_align_reg       : std_logic_vector(SRC_ALIGN_WIDTH-1 downto 0)  := (others => '0');
        signal sig_dre_dest_align_reg      : std_logic_vector(DEST_ALIGN_WIDTH-1 downto 0) := (others => '0');
        signal sig_dre_flush_reg           : std_logic := '0';
             
        begin
 
 
          
          -- Assign the DRE Control Outputs
          sf2dre_new_align      <= sig_dre_align_valid_reg;
          sf2dre_use_autodest   <= sig_dre_use_autodest_reg;
          sf2dre_src_align      <= sig_dre_src_align_reg;
          sf2dre_dest_align     <= sig_dre_dest_align_reg;
          sf2dre_flush          <= sig_sf2dre_flush;      -- from RDC via data FIFO
      
 
          
          -- PCC DRE Command interface handshake 
          dre2mstr_cmd_ready    <= sig_fifo_wr_cmd_ready;
          sig_fifo_wr_cmd_valid <= mstr2dre_cmd_valid   ;
          
          -- Format the input data word for the DRE Control FIFO Queue
          sig_cmd_fifo_data_in  <=  mstr2dre_strt_offset    &
                                    mstr2dre_calc_error     &
                                    mstr2dre_eof            &   
                                    mstr2dre_drr            &   
                                    mstr2dre_dre_dest_align &   
                                    mstr2dre_dre_src_align  &   
                                    mstr2dre_tag;   
          
          
          
          
          
          -- Formulate the DRE Control FIFO Read signaling
          sig_cntl_fifo_has_data   <= sig_fifo_rd_cmd_valid  ;
          sig_fifo_rd_cmd_ready    <= sig_get_cntl_fifo_data ;
          
          
          
          
                                       
                              
          -- Rip the output fifo data word
          sig_curr_tag_reg         <= sig_cmd_fifo_data_out((TAG_STRT_INDEX+TAG_WIDTH)-1 downto TAG_STRT_INDEX);
          sig_curr_src_align_reg   <= sig_cmd_fifo_data_out((SRC_ALIGN_STRT_INDEX+SRC_ALIGN_WIDTH)-1 downto 
                                                            SRC_ALIGN_STRT_INDEX);
          sig_curr_dest_align_reg  <= sig_cmd_fifo_data_out((DEST_ALIGN_STRT_INDEX+DEST_ALIGN_WIDTH)-1 downto 
                                                            DEST_ALIGN_STRT_INDEX);
          sig_curr_drr_reg         <= sig_cmd_fifo_data_out(DRR_STRT_INDEX);
          sig_curr_eof_reg         <= sig_cmd_fifo_data_out(EOF_STRT_INDEX);
          sig_curr_calc_error_reg  <= sig_cmd_fifo_data_out(CALC_ERR_STRT_INDEX);
          sig_curr_strt_offset_reg <= sig_cmd_fifo_data_out((SF_OFFSET_STRT_INDEX+SF_OFFSET_WIDTH)-1 downto 
                                                            SF_OFFSET_STRT_INDEX);


               
                              
                              
                                       
          ------------------------------------------------------------
          -- Instance: I_DRE_CNTL_FIFO
          --
          -- Description:
          -- Instance for the DRE Control FIFO
          --
          ------------------------------------------------------------
          I_DRE_CNTL_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
          generic map (

            C_DWIDTH             =>  DRECNTL_FIFO_WIDTH     , 
            C_DEPTH              =>  DRECNTL_FIFO_DEPTH     , 
            C_IS_ASYNC           =>  USE_SYNC_FIFO          , 
            C_PRIM_TYPE          =>  SRL_FIFO_PRIM          , 
            C_FAMILY             =>  C_FAMILY                 

            )
          port map (

            -- Write Clock and reset
            fifo_wr_reset        =>   reset                 , 
            fifo_wr_clk          =>   aclk                  , 

            -- Write Side
            fifo_wr_tvalid       =>   sig_fifo_wr_cmd_valid , 
            fifo_wr_tready       =>   sig_fifo_wr_cmd_ready , 
            fifo_wr_tdata        =>   sig_cmd_fifo_data_in  , 
            fifo_wr_full         =>   open                  , 


            -- Read Clock and reset
            fifo_async_rd_reset  =>   aclk                  , 
            fifo_async_rd_clk    =>   reset                 , 

            -- Read Side
            fifo_rd_tvalid       =>   sig_fifo_rd_cmd_valid , 
            fifo_rd_tready       =>   sig_fifo_rd_cmd_ready , 
            fifo_rd_tdata        =>   sig_cmd_fifo_data_out , 
            fifo_rd_empty        =>   open                    

            );



          
  
          
           
           
          
          -------------------------------------------------------------------------
          -- DRE Control Register
          -------------------------------------------------------------------------
          
           
          
          -- The DRE will auto-flush on a received TLAST so a commanded Flush 
          -- is not needed.                                                             
          sig_dre_flush_reg         <= '0';
  
  

          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_CNTL_REG
          --
          -- Process Description:
          --  Implements the DRE alignment Output Register.
          --
          -------------------------------------------------------------
          IMP_CNTL_REG : process (aclk)
            begin
              if (aclk'event and aclk = '1') then
                if (reset = '1') then
         
                  sig_dre_use_autodest_reg  <= '0'             ;
                  sig_dre_src_align_reg     <= (others => '0') ;
                  sig_dre_dest_align_reg    <= (others => '0') ;
                
                Elsif (sig_ld_dre_cntl_reg = '1' ) Then
                
                  sig_dre_use_autodest_reg  <= not(sig_curr_drr_reg)   ;
                  sig_dre_src_align_reg     <= sig_curr_src_align_reg  ;
                  sig_dre_dest_align_reg    <= sig_curr_dest_align_reg ;
                
                
                Elsif (sig_good_sout_strm_dbeat = '1') Then
                
                  sig_dre_use_autodest_reg  <= '0'             ;
                  sig_dre_src_align_reg     <= (others => '0') ;
                  sig_dre_dest_align_reg    <= (others => '0') ;
                
                else
         
                  null;  -- Hold Current State
         
                end if; 
              end if;       
            end process IMP_CNTL_REG; 
          
        
        
       
            
            
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_DRE_CNTL_VALID_REG
          --
          -- Process Description:
          --  Implements the DRE Alignment valid Register.
          --
          -------------------------------------------------------------
          IMP_DRE_CNTL_VALID_REG : process (aclk)
            begin
              if (aclk'event and aclk = '1') then
                if (reset = '1') then
         
                  sig_dre_align_valid_reg   <= '0' ; 
                
                Elsif (sig_ld_dre_cntl_reg = '1' ) Then
                
                  sig_dre_align_valid_reg   <= '1'  ; 
                
                
                Elsif (sig_good_sout_strm_dbeat = '1') Then
                
                  sig_dre_align_valid_reg   <= '0' ; 
                
                else
         
                  null;  -- Hold Current State
         
                end if; 
              end if;       
            end process IMP_DRE_CNTL_VALID_REG; 
          
        
        
 
      
        end generate INCLUDE_DRE_CNTL;
  
 
  
  
  
  
  
  
  
  
  
  
  
 
 ---------------------------------------------------------------- 
 -- Token Counter Logic  
 -- Predicting fifo space availability at some point in the  
 -- future is based on managing a virtual pool of transfer tokens.
 -- A token represents 1 max length burst worth of space in the
 -- Data FIFO. 
 ---------------------------------------------------------------- 
    
    
    -- calculate how many tokens are commited to pending transfers
    sig_tokens_commited <= TOKEN_CNT_MAX - sig_token_cntr;
    
    
    
    -- Decrement the token counter when a token is
    -- borrowed
    sig_decr_token_cntr <= '1'
      when (sig_rd_addr_posted = '1' and 
            sig_token_eq_zero  = '0')
      else '0';
    
    
    -- Increment the token counter when a  
    -- token is returned.
    sig_incr_token_cntr <= '1'
      when (sig_rd_xfer_cmplt = '1' and 
            sig_token_eq_max  = '0')
      else '0';
  
    
    
    -- Detect when the xfer token count is at max value
    sig_token_eq_max <= '1' 
     when (sig_token_cntr = TOKEN_CNT_MAX)
     Else '0';
  
    -- Detect when the xfer token count is at one
    sig_token_eq_one <= '1' 
     when (sig_token_cntr = TOKEN_CNT_ONE)
     Else '0';
  
    -- Detect when the xfer token count is at zero
    sig_token_eq_zero <= '1' 
     when (sig_token_cntr = TOKEN_CNT_ZERO)
     Else '0';
  
    -- Look ahead to see if the xfer token pool is going empty
    sig_taking_last_token <= '1'
      When (sig_token_eq_one   = '1' and
            sig_rd_addr_posted = '1')
      Else '0';
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_TOKEN_CNTR
    --
    -- Process Description:
    -- Implements the Token counter
    --
    -------------------------------------------------------------
    IMP_TOKEN_CNTR : process (aclk)
      begin
        if (aclk'event and aclk = '1') then
          if (reset  = '1' ) then 

            sig_token_cntr <= TOKEN_CNT_MAX;
            
          elsif (sig_incr_token_cntr = '1' and
                 sig_decr_token_cntr = '0') then

            sig_token_cntr <= sig_token_cntr + TOKEN_CNT_ONE;
            
          elsif (sig_incr_token_cntr = '0' and
                 sig_decr_token_cntr = '1') then

            sig_token_cntr <= sig_token_cntr - TOKEN_CNT_ONE;
            
          else
            null;  -- hold current value
          end if; 
        end if;       
      end process IMP_TOKEN_CNTR; 

 
     
     
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_TOKEN_AVAIL_FLAG
    --
    -- Process Description:
    --   Implements the flag indicating that the AXI Read Master
    -- can post a read address request on the AXI4 bus.
    --
    -- Read address posting can occur if:
    --
    --  - The write side LEN fifo is not empty.                   
    --  - The commited plus actual Data FIFO space is less than 
    --    the stall threshold (a max length read burst can fit 
    --    in the data FIFO without overflow).   
    --  - The max allowed commited read count has not been reached.      
    --
    -- The flag is cleared after each address has been posted to
    -- ensure a second unauthorized post does not occur.
    -------------------------------------------------------------
    IMP_TOKEN_AVAIL_FLAG : process (aclk)
      begin
        if (aclk'event and aclk = '1') then
           if (reset              = '1' or
               sig_rd_addr_posted = '1') then
    
             sig_ok_to_post_rd_addr <= '0';
    
           else
    
             sig_ok_to_post_rd_addr <= not(sig_stall_rd_addr_posts) and -- the commited Data FIFO space is approaching full 
                                       not(sig_token_eq_zero)       and -- max allowed pending reads has not been reached
                                       not(sig_taking_last_token);      -- the max allowed pending reads is about to be reached
    
           end if; 
        end if;       
      end process IMP_TOKEN_AVAIL_FLAG; 
 
 
 
  
  
    
    
 
 
  
  
    
    
 ---------------------------------------------------------------- 
 -- Data FIFO Logic ------------------------------------------
 ---------------------------------------------------------------- 
 
   
GEN_MM2S_TKEEP_ENABLE3 : if C_ENABLE_MM2S_TKEEP = 1 generate
begin

    
    -- FIFO Output ripping to components
    sig_dfifo_data_out       <=  sig_data_fifo_data_out(DATA_OUT_MSB_INDEX downto
                                                        DATA_OUT_LSB_INDEX);
     
    sig_dfifo_tkeep_out      <=  sig_data_fifo_data_out(TKEEP_OUT_MSB_INDEX downto
                                                        TKEEP_OUT_LSB_INDEX);
     
    sig_dfifo_tlast_out      <=  sig_data_fifo_data_out(TLAST_OUT_INDEX) ;
    
    sig_dfifo_cmd_cmplt_out  <=  sig_data_fifo_data_out(CMPLT_OUT_INDEX) ;
  
    sig_dfifo_dre_flush_out  <=  sig_data_fifo_data_out(DRE_FLUSH_OUT_INDEX) ;
  

end generate GEN_MM2S_TKEEP_ENABLE3;

GEN_MM2S_TKEEP_DISABLE3 : if C_ENABLE_MM2S_TKEEP = 0 generate
begin
    
    -- FIFO Output ripping to components
    sig_dfifo_data_out       <=  sig_data_fifo_data_out(DATA_OUT_MSB_INDEX downto
                                                        DATA_OUT_LSB_INDEX);
     
    sig_dfifo_tkeep_out      <=  (others => '1');
     
    sig_dfifo_tlast_out      <=  sig_data_fifo_data_out(TLAST_OUT_INDEX) ;
    
    sig_dfifo_cmd_cmplt_out  <=  sig_data_fifo_data_out(CMPLT_OUT_INDEX) ;
  
    sig_dfifo_dre_flush_out  <=  sig_data_fifo_data_out(DRE_FLUSH_OUT_INDEX) ;
  


end generate GEN_MM2S_TKEEP_DISABLE3;


 
  
    
    -- Stall Threshold calculations
    sig_fifo_wr_cnt_unsgnd   <= UNSIGNED(sig_data_fifo_wr_cnt);
 
    sig_wrcnt_mblen_slice    <= sig_fifo_wr_cnt_unsgnd(DATA_FIFO_CNT_WIDTH-1 downto 
                                                       DF_WRCNT_RIP_LS_INDEX);
    
    sig_commit_plus_actual   <= RESIZE(sig_tokens_commited, THRESH_COMPARE_WIDTH) +
                                RESIZE(sig_wrcnt_mblen_slice, THRESH_COMPARE_WIDTH);
    
    
    -- Compare the commited read space plus the actual used space against the
    -- stall threshold. Assert the read address posting stall flag if the
    -- threshold is met or exceeded.
    sig_stall_rd_addr_posts  <= '1'
      when (sig_commit_plus_actual > RD_ADDR_POST_STALL_THRESH_US)
      Else '0';
    
    
    
    
    -- FIFO Rd/WR Controls
    sig_push_data_fifo <= sig_good_sin_strm_dbeat;
    
    -- sig_pop_data_fifo  <= sig_sout2sf_tready and 
    --                       sig_data_fifo_dvalid;
    
    
      
GEN_MM2S_TKEEP_ENABLE2 : if C_ENABLE_MM2S_TKEEP = 1 generate
begin

 
    -- Concatonate the Stream inputs into the single FIFO data in value 
    sig_data_fifo_data_in <= data2sf_dre_flush &  -- ms Field
                             data2sf_cmd_cmplt &  
                             sin2sf_tlast      &
                             sin2sf_tkeep      & 
                             sin2sf_tdata;        -- ls field


end generate GEN_MM2S_TKEEP_ENABLE2;

GEN_MM2S_TKEEP_DISABLE2 : if C_ENABLE_MM2S_TKEEP = 0 generate
begin
 
    -- Concatonate the Stream inputs into the single FIFO data in value 
    sig_data_fifo_data_in <= data2sf_dre_flush &  -- ms Field
                             data2sf_cmd_cmplt &  
                             sin2sf_tlast      &
                             --sin2sf_tkeep      & 
                             sin2sf_tdata;        -- ls field



end generate GEN_MM2S_TKEEP_DISABLE2;

   
   
                                                    
    ------------------------------------------------------------
    -- Instance: I_DATA_FIFO 
    --
    -- Description:
    --  Implements the Store and Forward data FIFO (synchronous)   
    --
    ------------------------------------------------------------
    I_DATA_FIFO : entity axi_datamover_v5_1.axi_datamover_sfifo_autord
    generic map (

      C_DWIDTH                =>  DATA_FIFO_WIDTH       ,  
      C_DEPTH                 =>  DATA_FIFO_DEPTH       ,  
      C_DATA_CNT_WIDTH        =>  DATA_FIFO_CNT_WIDTH   ,  
      C_NEED_ALMOST_EMPTY     =>  NOT_NEEDED            ,  
      C_NEED_ALMOST_FULL      =>  NOT_NEEDED            ,  
      C_USE_BLKMEM            =>  BLK_MEM_FIFO          ,  
      C_FAMILY                =>  C_FAMILY                 

      )
    port map (

     -- Inputs 
      SFIFO_Sinit             =>  reset                  , 
      SFIFO_Clk               =>  aclk                   , 
      SFIFO_Wr_en             =>  sig_push_data_fifo     , 
      SFIFO_Din               =>  sig_data_fifo_data_in  , 
      SFIFO_Rd_en             =>  sig_pop_data_fifo      , 
      SFIFO_Clr_Rd_Data_Valid =>  LOGIC_LOW              , 
      
     -- Outputs
      SFIFO_DValid            =>  sig_data_fifo_dvalid   , 
      SFIFO_Dout              =>  sig_data_fifo_data_out , 
      SFIFO_Full              =>  sig_data_fifo_full     , 
      SFIFO_Empty             =>  open                   , 
      SFIFO_Almost_full       =>  open                   , 
      SFIFO_Almost_empty      =>  open                   , 
      SFIFO_Rd_count          =>  open                   ,  
      SFIFO_Rd_count_minus1   =>  open                   ,  
      SFIFO_Wr_count          =>  sig_data_fifo_wr_cnt   ,  
      SFIFO_Rd_ack            =>  open                     

    );



 
 
 
 
 
 
  
  
  end implementation;
