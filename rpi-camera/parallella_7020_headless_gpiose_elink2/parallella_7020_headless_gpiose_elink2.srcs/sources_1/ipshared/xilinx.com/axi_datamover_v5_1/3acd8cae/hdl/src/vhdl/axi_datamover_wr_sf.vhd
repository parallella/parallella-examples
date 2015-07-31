  -------------------------------------------------------------------------------
  -- axi_datamover_wr_sf.vhd
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
  -- Filename:        axi_datamover_wr_sf.vhd
  --
  -- Description:     
  --    This file implements the AXI DataMover Write (S2MM) Store and Forward module. 
  --  The design utilizes the AXI DataMover's new address pipelining
  --  control function.  This module buffers write data and provides status and 
  --  control features such that the DataMover Write Master is only allowed 
  --  to post AXI WRite Requests if the associated write data needed to complete
  --  the Write Data transfer is present in the Data FIFO. In addition, the Write 
  --  side logic is such that Write transfer requests can be pipelined to the 
  --  AXI4 bus based on the Data FIFO contents but ahead of the actual Write Data
  --  transfers.
  -- 
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  library lib_pkg_v1_0;
  library lib_srl_fifo_v1_0;
  use lib_pkg_v1_0.lib_pkg.all;
  use lib_pkg_v1_0.lib_pkg.clog2;
  use lib_srl_fifo_v1_0.srl_fifo_f;
  
 

  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_sfifo_autord;

  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_wr_sf is
    generic (
      
      C_WR_ADDR_PIPE_DEPTH   : Integer range 1 to 30 := 4;
        -- This parameter indicates the depth of the DataMover
        -- write address pipelining queues for the Main data transport
        -- channels. The effective address pipelining on the AXI4 
        -- Write Address Channel will be the value assigned plus 2. 
      
      C_SF_FIFO_DEPTH        : Integer range 128 to 8192 := 512;
        -- Sets the desired depth of the internal Data FIFO.
      
    --   C_MAX_BURST_LEN        : Integer range  16 to  256 :=  16;
    --     -- Indicates the max burst length being used by the external
    --     -- AXI4 Master for each AXI4 transfer request.
        
    --   C_DRE_IS_USED          : Integer range   0 to    1 :=   0;
    --     -- Indicates if the external Master is utilizing a DRE on
    --     -- the stream input to this module.
         
      C_MMAP_DWIDTH          : Integer range   32 to  1024 := 64;
        -- Sets the AXI4 Memory Mapped Bus Data Width 
      
      C_STREAM_DWIDTH        : Integer range   8 to  1024 :=  16;
        -- Sets the Stream Data Width for the Input and Output
        -- Data streams.
  
      C_STRT_OFFSET_WIDTH    : Integer range   1 to 7 :=  2;
        -- Sets the bit width of the starting address offset port
        -- This should be set to log2(C_MMAP_DWIDTH/C_STREAM_DWIDTH)
        
      C_FAMILY               : String  := "virtex7"
        -- Indicates the target FPGA Family.
      
      );
    port (
      
      -- Clock and Reset inputs -----------------------------------------------       
                                                                             --       
      aclk                    : in  std_logic;                               --       
         -- Primary synchronization clock for the Master side                --       
         -- interface and internal logic. It is also used                    --       
         -- for the User interface synchronization when                      --       
         -- C_STSCMD_IS_ASYNC = 0.                                           --       
                                                                             --       
      -- Reset input                                                         --       
      reset                   : in  std_logic;                               --       
         -- Reset used for the internal syncronization logic                 --       
      -------------------------------------------------------------------------
      
      
    
    
      -- Slave Stream Input  ------------------------------------------------------------ 
                                                                                       -- 
      sf2sin_tready           : Out Std_logic;                                         -- 
        -- DRE  Stream READY input                                                     -- 
                                                                                       -- 
      sin2sf_tvalid           : In  std_logic;                                         -- 
        -- DRE Stream VALID Output                                                     -- 
                                                                                       -- 
      sin2sf_tdata            : In  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);      --    
        -- DRE  Stream DATA input                                                      -- 
                                                                                       -- 
      sin2sf_tkeep            : In  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);  --       
        -- DRE  Stream STRB input                                                      -- 
                                                                                       -- 
      sin2sf_tlast            : In  std_logic;                                         -- 
        -- DRE  Xfer LAST input                                                        --
                                                                                       -- 
      sin2sf_error            : In  std_logic;                                         -- 
        -- Stream Underrun/Overrun error input                                         --
      ----------------------------------------------------------------------------------- 
  
 
  
      -- Starting Address Offset Input  ------------------------------------------------- 
                                                                                       --
      sin2sf_strt_addr_offset : In std_logic_vector(C_STRT_OFFSET_WIDTH-1 downto 0);   -- 
        -- Used by Packing logic to set the initial data slice position for the        --
        -- packing operation. Packing is only needed if the MMap and Stream Data       --
        -- widths do not match.                                                        -- 
      ----------------------------------------------------------------------------------- 
               
                
      -- DataMover Write Side Address Pipelining Control Interface ---------------------- 
                                                                                       -- 
      ok_to_post_wr_addr      : Out  Std_logic;                                        -- 
        -- Indicates that the internal FIFO has enough data                            -- 
        -- physically present to supply one more max length                            -- 
        -- burst transfer or a completion burst                                        -- 
        -- (tlast asserted)                                                            -- 
                                                                                       -- 
      wr_addr_posted          : In std_logic;                                          -- 
        -- Indication that a write address has been posted to AXI4                     -- 
                                                                                       -- 
                                                                                       -- 
      wr_xfer_cmplt           : In  Std_logic;                                         -- 
        -- Indicates that the Datamover has completed a Write Data                     -- 
        -- transfer on the AXI4                                                        -- 
                                                                                       -- 
                                                                                       -- 
      wr_ld_nxt_len           : in  std_logic;                                         -- 
        -- Active high pulse indicating a new transfer LEN qualifier                   -- 
        -- has been queued to the DataMover Write Data Controller                      -- 
                                                                                       -- 
      wr_len                  : in  std_logic_vector(7 downto 0);                      -- 
        -- The actual LEN qualifier value that has been queued to the                  -- 
        -- DataMover Write Data Controller                                             --
      ----------------------------------------------------------------------------------- 


         
      
      -- Write Side Stream Out to DataMover S2MM ---------------------------------------- 
                                                                                       -- 
      sout2sf_tready          : In  std_logic;                                         -- 
        -- Write READY input from the Stream Master                                    -- 
                                                                                       -- 
      sf2sout_tvalid          : Out  std_logic;                                        -- 
        -- Write VALID output to the Stream Master                                     -- 
                                                                                       -- 
      sf2sout_tdata           : Out  std_logic_vector(C_MMAP_DWIDTH-1 downto 0);       -- 
        -- Write DATA output to the Stream Master                                      -- 
                                                                                       -- 
      sf2sout_tkeep           : Out  std_logic_vector((C_MMAP_DWIDTH/8)-1 downto 0);   -- 
        -- Write DATA output to the Stream Master                                      -- 
                                                                                       -- 
      sf2sout_tlast           : Out  std_logic;                                        -- 
        -- Write LAST output to the Stream Master                                      --
                                                                                       -- 
      sf2sout_error           : Out  std_logic                                         -- 
        -- Stream Underrun/Overrun error input                                         --
      ----------------------------------------------------------------------------------- 
     
 
      );
  
  end entity axi_datamover_wr_sf;
  
  
  architecture implementation of axi_datamover_wr_sf is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Functions ---------------------------------------------------------------------------
 
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_pwr2_depth
    --
    -- Function Description:
    --  Rounds up to the next power of 2 depth value in an input
    --  range of 1 to 8192
    --
    -------------------------------------------------------------------
    function funct_get_pwr2_depth (min_depth : integer) return integer is
     
      Variable var_temp_depth : Integer := 16;
     
    begin
       
      
      if (min_depth = 1) then
      
         var_temp_depth := 1;
      
      elsif (min_depth  = 2) then
      
         var_temp_depth := 2;
      
      elsif (min_depth  <= 4) then
      
         var_temp_depth := 4;
      
      elsif (min_depth  <= 8) then
      
         var_temp_depth := 8;
      
      elsif (min_depth  <= 16) then
      
         var_temp_depth := 16;
      
      elsif (min_depth  <= 32) then
      
         var_temp_depth := 32;
      
      elsif (min_depth  <= 64) then
      
         var_temp_depth := 64;
      
      elsif (min_depth  <= 128) then
      
         var_temp_depth := 128;
      
      elsif (min_depth  <= 256) then
      
         var_temp_depth := 256;
      
      elsif (min_depth  <= 512) then
      
         var_temp_depth := 512;
      
      elsif (min_depth  <= 1024) then
      
         var_temp_depth := 1024;
      
      elsif (min_depth  <= 2048) then
      
         var_temp_depth := 2048;
      
      elsif (min_depth  <= 4096) then
      
         var_temp_depth := 4096;
      
      else -- assume 8192 depth
      
         var_temp_depth := 8192;
      
      end if;
      
       
       
      Return (var_temp_depth);
       
       
    end function funct_get_pwr2_depth;
    
    
    
    
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
    -- Function Name: funct_get_cntr_width
    --
    -- Function Description:
    --  This function calculates the needed counter bit width from the 
    -- number of count sates needed (input).
    --
    -------------------------------------------------------------------
    function funct_get_cntr_width (num_cnt_values : integer) return integer is
    
      Variable temp_cnt_width : Integer := 0;
    
    begin
    
      
      if (num_cnt_values <= 2) then
      
        temp_cnt_width := 1;
      
      elsif (num_cnt_values <= 4) then
      
        temp_cnt_width := 2;
      
      elsif (num_cnt_values <= 8) then
      
        temp_cnt_width := 3;
      
      elsif (num_cnt_values <= 16) then
      
        temp_cnt_width := 4;
      
      elsif (num_cnt_values <= 32) then
      
        temp_cnt_width := 5;
      
      elsif (num_cnt_values <= 64) then
      
        temp_cnt_width := 6;
      
      elsif (num_cnt_values <= 128) then
      
        temp_cnt_width := 7;
      
      else
      
        temp_cnt_width := 8;
      
      end if;
      
      
      
      
      Return (temp_cnt_width);
      
      
    end function funct_get_cntr_width;
    

    
    
    
    -- Constants ---------------------------------------------------------------------------
    
    Constant LOGIC_LOW                 : std_logic := '0';
    Constant LOGIC_HIGH                : std_logic := '1';
    
    Constant BLK_MEM_FIFO              : integer := 1;
    Constant SRL_FIFO                  : integer := 0;
    Constant NOT_NEEDED                : integer := 0;
    
    
    Constant WSTB_WIDTH                : integer := C_MMAP_DWIDTH/8; -- bits
    Constant TLAST_WIDTH               : integer := 1;               -- bits
    Constant EOP_ERR_WIDTH             : integer := 1;               -- bits
    
    
    
    Constant DATA_FIFO_DEPTH           : integer := C_SF_FIFO_DEPTH;
    Constant DATA_FIFO_CNT_WIDTH       : integer := funct_get_fifo_cnt_width(DATA_FIFO_DEPTH);
    -- Constant DF_WRCNT_RIP_LS_INDEX     : integer := funct_get_wrcnt_lsrip(C_MAX_BURST_LEN);
    
     
    Constant DATA_FIFO_WIDTH           : integer := C_MMAP_DWIDTH +
                                                    --WSTB_WIDTH     +
                                                    TLAST_WIDTH   +
                                                    EOP_ERR_WIDTH;
    
    Constant DATA_OUT_MSB_INDEX        : integer := C_MMAP_DWIDTH-1;
    Constant DATA_OUT_LSB_INDEX        : integer := 0;
    
   --  Constant TSTRB_OUT_LSB_INDEX       : integer := DATA_OUT_MSB_INDEX+1;
   --  Constant TSTRB_OUT_MSB_INDEX       : integer := (TSTRB_OUT_LSB_INDEX+WSTB_WIDTH)-1;
    
   -- Constant TLAST_OUT_INDEX           : integer := TSTRB_OUT_MSB_INDEX+1;
    Constant TLAST_OUT_INDEX           : integer := DATA_OUT_MSB_INDEX+1;
    
    Constant EOP_ERR_OUT_INDEX         : integer := TLAST_OUT_INDEX+1;
    
    
    Constant WR_LEN_FIFO_DWIDTH        : integer := 8;
    Constant WR_LEN_FIFO_DEPTH         : integer := funct_get_pwr2_depth(C_WR_ADDR_PIPE_DEPTH + 2);
    
    Constant LEN_CNTR_WIDTH            : integer := 8;
    Constant LEN_CNT_ZERO              : Unsigned(LEN_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(0, LEN_CNTR_WIDTH);
    Constant LEN_CNT_ONE               : Unsigned(LEN_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, LEN_CNTR_WIDTH);
    
    Constant WR_XFER_CNTR_WIDTH        : integer := 8;
    Constant WR_XFER_CNT_ZERO          : Unsigned(WR_XFER_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(0, WR_XFER_CNTR_WIDTH);
    Constant WR_XFER_CNT_ONE           : Unsigned(WR_XFER_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, WR_XFER_CNTR_WIDTH);
    
    Constant UNCOM_WRCNT_1             : Unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, DATA_FIFO_CNT_WIDTH);
    
    Constant UNCOM_WRCNT_0             : Unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(0, DATA_FIFO_CNT_WIDTH);
    
    
    
    
    
    
    
    
    -- Signals ---------------------------------------------------------------------------
    
    
    signal sig_good_sin_strm_dbeat    : std_logic := '0';
    signal sig_strm_sin_ready         : std_logic := '0';
    
    signal sig_sout2sf_tready         : std_logic := '0';
    signal sig_sf2sout_tvalid         : std_logic := '0';
    signal sig_sf2sout_tdata          : std_logic_vector(C_MMAP_DWIDTH-1 downto 0) := (others => '0');
    signal sig_sf2sout_tkeep          : std_logic_vector(WSTB_WIDTH-1 downto 0) := (others => '0');
    signal sig_sf2sout_tlast          : std_logic := '0';
    
    signal sig_push_data_fifo         : std_logic := '0';
    signal sig_pop_data_fifo          : std_logic := '0';
    signal sig_data_fifo_full         : std_logic := '0';
    signal sig_data_fifo_data_in      : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_dvalid       : std_logic := '0';
    signal sig_data_fifo_data_out     : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    
    signal sig_ok_to_post_wr_addr     : std_logic := '0';
    signal sig_wr_addr_posted         : std_logic := '0';
    signal sig_wr_xfer_cmplt          : std_logic := '0';
    
    signal sig_wr_ld_nxt_len          : std_logic := '0';
    signal sig_push_len_fifo          : std_logic := '0';
    signal sig_pop_len_fifo           : std_logic := '0';
    signal sig_len_fifo_full          : std_logic := '0';
    signal sig_len_fifo_empty         : std_logic := '0';
    signal sig_len_fifo_data_in       : std_logic_vector(WR_LEN_FIFO_DWIDTH-1 downto 0) := (others => '0');
    signal sig_len_fifo_data_out      : std_logic_vector(WR_LEN_FIFO_DWIDTH-1 downto 0) := (others => '0');
    signal sig_len_fifo_len_out_un    : unsigned(WR_LEN_FIFO_DWIDTH-1 downto 0) := (others => '0');
  
    signal sig_uncom_wrcnt            : unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_sub_len_uncom_wrcnt    : std_logic := '0';
    signal sig_incr_uncom_wrcnt       : std_logic := '0';
    signal sig_resized_fifo_len       : unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_num_wr_dbeats_needed   : unsigned(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_enough_dbeats_rcvd     : std_logic := '0';
                    
    signal sig_sf2sout_eop_err_out    : std_logic := '0';
    
    signal sig_good_fifo_write        : std_logic := '0';
    
  
  begin --(architecture implementation)
  
   
   
    -- Write Side (S2MM) Control Flags port connections
    ok_to_post_wr_addr       <= sig_ok_to_post_wr_addr ;
    sig_wr_addr_posted       <= wr_addr_posted         ;
    sig_wr_xfer_cmplt        <= wr_xfer_cmplt          ;
  
    sig_wr_ld_nxt_len        <= wr_ld_nxt_len          ;
    sig_len_fifo_data_in     <= wr_len                 ;
  
    
    
    --  Output Stream Port connections
    sig_sout2sf_tready       <= sout2sf_tready          ;
    sf2sout_tvalid           <= sig_sf2sout_tvalid      ;
    sf2sout_tdata            <= sig_sf2sout_tdata       ; 
    sf2sout_tkeep            <= sig_sf2sout_tkeep       ;
    sf2sout_tlast            <= sig_sf2sout_tlast and
                                sig_sf2sout_tvalid      ;
    sf2sout_error            <= sig_sf2sout_eop_err_out ;
                               
                               
    
    -- Input Stream port connections 
    sf2sin_tready            <= sig_strm_sin_ready;
    
                                                          
    sig_good_sin_strm_dbeat  <= sin2sf_tvalid and
                                sig_strm_sin_ready;
                               
 
  
    
    
 ---------------------------------------------------------------- 
 -- Packing Logic      ------------------------------------------
 ---------------------------------------------------------------- 
 
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: OMIT_PACKING
    --
    -- If Generate Description:
    --    Omits any packing logic in the Store and Forward module.
    -- The Stream and MMap data widths are the same.
    --
    ------------------------------------------------------------
    OMIT_PACKING : if (C_MMAP_DWIDTH = C_STREAM_DWIDTH) generate
    
       begin
    
        
         sig_good_fifo_write   <= sig_good_sin_strm_dbeat;
         
         sig_strm_sin_ready    <= not(sig_data_fifo_full); 
         
         
         sig_push_data_fifo    <= sig_good_sin_strm_dbeat;
       
          
         -- Concatonate the Stream inputs into the single FIFO data in value 
         sig_data_fifo_data_in <= sin2sf_error &
                                  sin2sf_tlast &
                                --  sin2sf_tkeep & 
                                  sin2sf_tdata;
       
       end generate OMIT_PACKING;
     
     
    
    
  
  
  
  
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: INCLUDE_PACKING
    --
    -- If Generate Description:
    --    Includes packing logic in the Store and Forward module.
    -- The MMap Data bus is wider than the Stream width.
    --
    ------------------------------------------------------------
    INCLUDE_PACKING : if (C_MMAP_DWIDTH > C_STREAM_DWIDTH) generate
    
      Constant MMAP2STRM_WIDTH_RATO  : integer := C_MMAP_DWIDTH/C_STREAM_DWIDTH;
    
      Constant DATA_SLICE_WIDTH      : integer := C_STREAM_DWIDTH;
      
      Constant FLAG_SLICE_WIDTH      : integer := TLAST_WIDTH     + 
                                                  EOP_ERR_WIDTH;
      
      
      
      
      
      
      Constant OFFSET_CNTR_WIDTH     : integer := funct_get_cntr_width(MMAP2STRM_WIDTH_RATO);
      
      Constant OFFSET_CNT_ONE        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(1, OFFSET_CNTR_WIDTH);
      
      Constant OFFSET_CNT_MAX        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(MMAP2STRM_WIDTH_RATO-1, OFFSET_CNTR_WIDTH);
      
      
      
      
      -- Types -----------------------------------------------------------------------------
      type lsig_data_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(DATA_SLICE_WIDTH-1 downto 0);

      type lsig_flag_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(FLAG_SLICE_WIDTH-1 downto 0);


       
      -- local signals
      
      signal lsig_data_slice_reg      : lsig_data_slice_type;
      signal lsig_flag_slice_reg      : lsig_flag_slice_type;
      
       
      signal lsig_reg_segment         : std_logic_vector(DATA_SLICE_WIDTH-1 downto 0)   := (others => '0');
      signal lsig_segment_ld          : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      signal lsig_segment_clr         : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      
      signal lsig_0ffset_to_to_use    : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := (others => '0');
      
      signal lsig_0ffset_cntr         : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := (others => '0');
      signal lsig_ld_offset           : std_logic := '0';
      signal lsig_incr_offset         : std_logic := '0';
      signal lsig_offset_cntr_eq_max  : std_logic := '0';
      
      signal lsig_combined_data       : std_logic_vector(C_MMAP_DWIDTH-1 downto 0) := (others => '0');
      
      
      signal lsig_tlast_or            : std_logic := '0';
      signal lsig_eop_err_or          : std_logic := '0';
      
      signal lsig_partial_tlast_or    : std_logic_vector(MMAP2STRM_WIDTH_RATO downto 0) := (others => '0');
      signal lsig_partial_eop_err_or  : std_logic_vector(MMAP2STRM_WIDTH_RATO downto 0) := (others => '0');
      
      signal lsig_packer_full         : std_logic := '0';
      signal lsig_packer_empty        : std_logic := '0';
      signal lsig_set_packer_full     : std_logic := '0';
      signal lsig_good_push2fifo      : std_logic := '0';
      signal lsig_first_dbeat         : std_logic := '0';
      
        
        
        
      begin
    
       
       -- Assign the flag indicating that a fifo write is going
       -- to occur at the next rising clock edge.
       sig_good_fifo_write     <=  lsig_good_push2fifo;
       
       
       -- Generate the stream ready
       sig_strm_sin_ready       <= not(lsig_packer_full) or
                                   lsig_good_push2fifo ; 
       
       
       -- Format the FIFO input data 
       sig_data_fifo_data_in   <= lsig_eop_err_or    &   -- MS Bit
                                  lsig_tlast_or      &
                                  lsig_combined_data  ;  -- LS Bits
        
       
       -- Generate a write to the Data FIFO input
       sig_push_data_fifo      <= lsig_packer_full;
       
       
       -- Generate a flag indicating a write to the DataFIFO 
       -- is going to complete 
       lsig_good_push2fifo    <=  lsig_packer_full and
                                  not(sig_data_fifo_full);
       
       -- Generate the control that loads the starting address
       -- offset for the next input packet
       lsig_ld_offset          <= lsig_first_dbeat and
                                  sig_good_sin_strm_dbeat;
                                  
       -- Generate the control for incrementing the offset counter
       lsig_incr_offset        <= sig_good_sin_strm_dbeat;
       
       
       -- Generate a flag indicating the packer input register
       -- array is full or has loaded the last data beat of
       -- the input paket
       lsig_set_packer_full    <=  sig_good_sin_strm_dbeat  and
                                   (sin2sf_tlast            or 
                                    lsig_offset_cntr_eq_max);

       -- Check to see if the offset counter has reached its max
       -- value
       lsig_offset_cntr_eq_max <=  '1'
         --when  (lsig_0ffset_cntr = OFFSET_CNT_MAX)
         when  (lsig_0ffset_to_to_use = OFFSET_CNT_MAX)
         Else '0';
       
       
       -- Mux between the input start offset and the offset counter
       -- output to use for the packer slice load control.  
       lsig_0ffset_to_to_use <= UNSIGNED(sin2sf_strt_addr_offset) 
         when (lsig_first_dbeat = '1')
         Else lsig_0ffset_cntr;
       
        
        
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_OFFSET_LD_MARKER
       --
       -- Process Description:
       --  Implements the flop indicating the first databeat of
       -- an input data packet.
       --
       -------------------------------------------------------------
       IMP_OFFSET_LD_MARKER : process (aclk)
         begin
           if (aclk'event and aclk = '1') then
              if (reset = '1') then
       
                lsig_first_dbeat <= '1';
       
              elsif (sig_good_sin_strm_dbeat = '1' and
                     sin2sf_tlast            = '0') then
       
                lsig_first_dbeat <= '0';
       
              Elsif (sig_good_sin_strm_dbeat = '1' and
                     sin2sf_tlast            = '1') Then
              
                lsig_first_dbeat <= '1';
              
              else
       
                null;  -- Hold Current State
       
              end if; 
           end if;       
         end process IMP_OFFSET_LD_MARKER; 
       
       
       
       
       
       
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_OFFSET_CNTR
       --
       -- Process Description:
       --  Implements the address offset counter that is used to 
       -- steer the data loads into the packer register slices.
       -- Note that the counter has to be loaded with the starting
       -- offset plus one to sync up with the data input.
       -------------------------------------------------------------
       IMP_OFFSET_CNTR : process (aclk)
         begin
           if (aclk'event and aclk = '1') then
              if (reset = '1') then
       
                lsig_0ffset_cntr <= (others => '0');
       
              Elsif (lsig_ld_offset = '1') Then
              
               lsig_0ffset_cntr <= UNSIGNED(sin2sf_strt_addr_offset) + OFFSET_CNT_ONE;
              
              elsif (lsig_incr_offset = '1') then
       
                lsig_0ffset_cntr <= lsig_0ffset_cntr + OFFSET_CNT_ONE;
       
              else
       
                null;  -- Hold Current State
       
              end if; 
           end if;       
         end process IMP_OFFSET_CNTR; 
       
       
       
       
       
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_PACK_REG_FULL
       --
       -- Process Description:
       --   Implements the Packer Register full/empty flags
       --
       -------------------------------------------------------------
       IMP_PACK_REG_FULL : process (aclk)
         begin
           if (aclk'event and aclk = '1') then
              if (reset = '1') then
       
                lsig_packer_full  <= '0';
                lsig_packer_empty <= '1';
       
              Elsif (lsig_set_packer_full = '1' and
                     lsig_packer_full     = '0') Then
              
                lsig_packer_full  <= '1';
                lsig_packer_empty <= '0';
       
              elsif (lsig_set_packer_full = '0' and
                     lsig_good_push2fifo  = '1') then
              
                lsig_packer_full  <= '0';
                lsig_packer_empty <= '1';
       
              else
       
                null;  -- Hold Current State
       
              end if; 
           end if;       
         end process IMP_PACK_REG_FULL; 
       
       
       
       
       
       
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: DO_REG_SLICES
       --
       -- For Generate Description:
       --
       --  Implements the Packng Register Slices
       --
       --
       ------------------------------------------------------------
       DO_REG_SLICES : for slice_index in 0 to MMAP2STRM_WIDTH_RATO-1 generate


       
       begin
       
        
         -- generate the register load enable for each slice segment based
         -- on the address offset count value
         lsig_segment_ld(slice_index) <= '1'
           when (sig_good_sin_strm_dbeat = '1' and
                TO_INTEGER(lsig_0ffset_to_to_use) = slice_index)
           Else '0';
         
         
        
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_DATA_SLICE
         --
         -- Process Description:
         --   Implement a data register slice for the packer. 
         --
         -------------------------------------------------------------
         IMP_DATA_SLICE : process (aclk)
           begin
             if (aclk'event and aclk = '1') then
               if (reset = '1') then
        
                 lsig_data_slice_reg(slice_index) <= (others => '0');
        
               elsif (lsig_segment_ld(slice_index) = '1') then
        
                 lsig_data_slice_reg(slice_index) <= sin2sf_tdata;
        
               -- optional clear of slice reg 
               elsif (lsig_segment_ld(slice_index) = '0' and
                      lsig_good_push2fifo          = '1') then

                 lsig_data_slice_reg(slice_index) <= (others => '0');
        
               else
        
                 null;  -- Hold Current State
        
               end if; 
             end if;       
           end process IMP_DATA_SLICE; 
        
        
         
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_FLAG_SLICE
         --
         -- Process Description:
         --   Implement a flag register slice for the packer.
         --
         -------------------------------------------------------------
         IMP_FLAG_SLICE : process (aclk)
           begin
             if (aclk'event and aclk = '1') then
               if (reset = '1') then
        
                 lsig_flag_slice_reg(slice_index) <= (others => '0');
        
               elsif (lsig_segment_ld(slice_index) = '1') then
        
                 lsig_flag_slice_reg(slice_index) <= sin2sf_tlast & -- bit 1
                                                     sin2sf_error;  -- bit 0
               
               elsif (lsig_segment_ld(slice_index) = '0' and
                      lsig_good_push2fifo          = '1') then

                 lsig_flag_slice_reg(slice_index) <= (others => '0');
        
               else
        
                 null;  -- Hold Current State
        
               end if; 
             end if;       
           end process IMP_FLAG_SLICE; 
        
        
        
         
       end generate DO_REG_SLICES;
       
       
        
        
        
        
                                                                                
       -- Do the OR functions of the Flags -------------------------------------
       lsig_tlast_or   <= lsig_partial_tlast_or(MMAP2STRM_WIDTH_RATO-1) ;
       lsig_eop_err_or <= lsig_partial_eop_err_or(MMAP2STRM_WIDTH_RATO-1);
       
       lsig_partial_tlast_or(0)   <= lsig_flag_slice_reg(0)(1);
       lsig_partial_eop_err_or(0) <= lsig_flag_slice_reg(0)(0);
       

       
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: DO_FLAG_OR
       --
       -- For Generate Description:
       --  Implement the OR of the TLAST and EOP Error flags.
       --
       --
       --
       ------------------------------------------------------------
       DO_FLAG_OR : for slice_index in 1 to MMAP2STRM_WIDTH_RATO-1 generate
       
       begin
     
          lsig_partial_tlast_or(slice_index)   <= lsig_partial_tlast_or(slice_index-1) or
                                                  --lsig_partial_tlast_or(slice_index);
                                                  lsig_flag_slice_reg(slice_index)(1);
                                                  
                                                  
                                                  
                                                  
          lsig_partial_eop_err_or(slice_index) <= lsig_partial_eop_err_or(slice_index-1) or
                                                  --lsig_partial_eop_err_or(slice_index); 
                                                  lsig_flag_slice_reg(slice_index)(0);
       
       end generate DO_FLAG_OR;

     
        
        
     
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: DO_DATA_COMBINER
       --
       -- For Generate Description:
       --   Combines the Data Slice register outputs into a single
       -- vector for input to the Data FIFO.
       --
       --
       ------------------------------------------------------------
       DO_DATA_COMBINER : for slice_index in 1 to MMAP2STRM_WIDTH_RATO generate
       
       begin
        
         lsig_combined_data((slice_index*DATA_SLICE_WIDTH)-1 downto 
                            (slice_index-1)*DATA_SLICE_WIDTH) <=
                            lsig_data_slice_reg(slice_index-1);
        
        
       end generate DO_DATA_COMBINER;
     
     
     
     
     
       
       
      end generate INCLUDE_PACKING;
     
     
    
    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
     
 ---------------------------------------------------------------- 
 -- Data FIFO Logic    ------------------------------------------
 ---------------------------------------------------------------- 
 
     
     -- FIFO Input attachments
     
     -- sig_push_data_fifo <= sig_good_sin_strm_dbeat;
     
     
     -- -- Concatonate the Stream inputs into the single FIFO data in value 
     -- sig_data_fifo_data_in <= sin2sf_error &
     --                          sin2sf_tlast &
     --                          sin2sf_tkeep & 
     --                          sin2sf_tdata;
 
    
    
     -- FIFO Output to output stream attachments
     sig_sf2sout_tvalid      <=  sig_data_fifo_dvalid ;
     
     sig_sf2sout_tdata       <=  sig_data_fifo_data_out(DATA_OUT_MSB_INDEX downto
                                                        DATA_OUT_LSB_INDEX);
     
     -- sig_sf2sout_tkeep       <=  sig_data_fifo_data_out(TSTRB_OUT_MSB_INDEX downto
     --                                                    TSTRB_OUT_LSB_INDEX);
     
     -- When this Store and Forward is enabled, the Write Data Controller ignores the 
     -- TKEEP input so this is not sent through the FIFO.
     sig_sf2sout_tkeep       <=  (others => '1');
     
     
     
     sig_sf2sout_tlast       <=  sig_data_fifo_data_out(TLAST_OUT_INDEX) ;
     
     sig_sf2sout_eop_err_out <=  sig_data_fifo_data_out(EOP_ERR_OUT_INDEX) ;
     
     
     -- FIFO Rd/WR Controls
     
     
     sig_pop_data_fifo  <= sig_sout2sf_tready and 
                           sig_data_fifo_dvalid;
     
                                                     
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
      SFIFO_Wr_count          =>  open                   ,  
      SFIFO_Rd_ack            =>  open                     

    );



 
 
 
 
 
 
 
 
 
 
 
-------------------------------------------------------------------- 
-- Write Side Control Logic  
--------------------------------------------------------------------

    -- Convert the LEN fifo data output to unsigned
    sig_len_fifo_len_out_un <= unsigned(sig_len_fifo_data_out);
   
    -- Resize the unsigned LEN output to the Data FIFO writecount width
    sig_resized_fifo_len    <= RESIZE(sig_len_fifo_len_out_un , DATA_FIFO_CNT_WIDTH);
   
    
    -- The actual number of databeats needed for the queued write transfer
    -- is the current LEN fifo output plus 1.
    sig_num_wr_dbeats_needed <= sig_resized_fifo_len + UNCOM_WRCNT_1;
   
   
    -- Compare the uncommited receved data beat count to that needed
    -- for the next queued write request.
    sig_enough_dbeats_rcvd <= '1'
      When (sig_num_wr_dbeats_needed <= sig_uncom_wrcnt)
      else '0';
    
    
    
    
    -- Increment the uncommited databeat counter on a good input
    -- stream databeat (Read Side of SF)
   -- sig_incr_uncom_wrcnt    <=  sig_good_sin_strm_dbeat;
    sig_incr_uncom_wrcnt    <=  sig_good_fifo_write;
   

    -- Subtract the current number of databeats needed from the
    -- uncommited databeat counter when the associated transfer
    -- address/qualifiers have been posted to the AXI Write 
    -- Address Channel
    sig_sub_len_uncom_wrcnt <= sig_wr_addr_posted;
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_UNCOM_DBEAT_CNTR
    --
    -- Process Description:
    -- Implements the counter that keeps track of the received read
    -- data beat count that has not been commited to a transfer on  
    -- the write side with a Write Address posting.
    --
    -------------------------------------------------------------
    IMP_UNCOM_DBEAT_CNTR : process (aclk)
      begin
        if (aclk'event and aclk = '1') then
          if (reset            = '1') then 

            sig_uncom_wrcnt <= UNCOM_WRCNT_0;
            
          elsif (sig_incr_uncom_wrcnt    = '1' and
                 sig_sub_len_uncom_wrcnt = '1') then

            sig_uncom_wrcnt <= sig_uncom_wrcnt - sig_resized_fifo_len;
            
          elsif (sig_incr_uncom_wrcnt    = '1' and
                 sig_sub_len_uncom_wrcnt = '0') then

            sig_uncom_wrcnt <= sig_uncom_wrcnt + UNCOM_WRCNT_1;
            
          elsif (sig_incr_uncom_wrcnt    = '0' and
                 sig_sub_len_uncom_wrcnt = '1') then

            sig_uncom_wrcnt <= sig_uncom_wrcnt - sig_num_wr_dbeats_needed;
            
          else
            null;  -- hold current value
          end if; 
        end if;       
      end process IMP_UNCOM_DBEAT_CNTR; 
    
    
    





  
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_WR_ADDR_POST_FLAG
   --
   -- Process Description:
   --   Implements the flag indicating that the pending write
   -- transfer's data beat count has been received on the input
   -- side of the Data FIFO. This means the Write side can post
   -- the associated write address to the AXI4 bus and the 
   -- associated write data transfer can complete without CDMA
   -- throttling the Write Data Channel.     
   --
   -- The flag is cleared immediately after an address is posted
   -- to prohibit a second unauthorized posting while the control
   -- logic stabilizes to the next LEN FIFO value
   --.
   -------------------------------------------------------------
   IMP_WR_ADDR_POST_FLAG : process (aclk)
     begin
       if (aclk'event and aclk = '1') then
          if (reset              = '1' or
              sig_wr_addr_posted = '1') then
   
            sig_ok_to_post_wr_addr <= '0';
   
          else
   
            sig_ok_to_post_wr_addr <= not(sig_len_fifo_empty) and
                                      sig_enough_dbeats_rcvd; 
   
          end if; 
       end if;       
     end process IMP_WR_ADDR_POST_FLAG; 


 
   
   
   
   
   
   -------------------------------------------------------------
   -- LEN FIFO logic 
   -- The LEN FIFO stores the xfer lengths needed for each queued 
   -- write transfer in the DataMover S2MM Write Data Controller.  
    
   sig_push_len_fifo    <= sig_wr_ld_nxt_len and
                           not(sig_len_fifo_full);


   sig_pop_len_fifo     <= wr_addr_posted and
                           not(sig_len_fifo_empty);
  
 
 


   ------------------------------------------------------------
   -- Instance: I_WR_LEN_FIFO 
   --
   -- Description:
   -- Implement the LEN FIFO using SRL FIFO elements    
   --
   ------------------------------------------------------------
   I_WR_LEN_FIFO : entity lib_srl_fifo_v1_0.srl_fifo_f
   generic map (

     C_DWIDTH      =>  WR_LEN_FIFO_DWIDTH   ,  
     C_DEPTH       =>  WR_LEN_FIFO_DEPTH    ,  
     C_FAMILY      =>  C_FAMILY      

     )
   port map (

     Clk           =>  aclk                  ,  
     Reset         =>  reset                 ,  
     FIFO_Write    =>  sig_push_len_fifo     ,  
     Data_In       =>  sig_len_fifo_data_in  ,  
     FIFO_Read     =>  sig_pop_len_fifo      ,  
     Data_Out      =>  sig_len_fifo_data_out ,  
     FIFO_Empty    =>  sig_len_fifo_empty    ,  
     FIFO_Full     =>  sig_len_fifo_full     ,  
     Addr          =>  open                
 
     );

    

   
     
 
 
 
  
  
  end implementation;
