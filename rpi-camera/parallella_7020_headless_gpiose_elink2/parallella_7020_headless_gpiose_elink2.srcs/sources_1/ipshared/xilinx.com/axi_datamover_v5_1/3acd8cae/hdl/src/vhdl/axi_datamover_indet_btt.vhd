  -------------------------------------------------------------------------------
  -- axi_datamover_indet_btt.vhd
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
  -- Filename:        axi_datamover_indet_btt.vhd
  --
  -- Description:     
  --    This file implements the DataMover S2MM Indeterminate BTT support module.                 
  --  This Module keeps track of the incoming data stream and generates a transfer                
  --  descriptor for each AXI MMap Burst worth of data loaded in the Data FIFO.                 
  --  This information is stored in a separate FIFO that the Predictive Transfer
  -- Calculator fetches sequentially as it is generating commands for the AXI MMap  
  -- bus.               
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  


  library lib_pkg_v1_0; 
  Use lib_pkg_v1_0.lib_pkg.clog2;
  
  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_sfifo_autord;
  use axi_datamover_v5_1.axi_datamover_skid_buf;
  Use axi_datamover_v5_1.axi_datamover_stbs_set;
  Use axi_datamover_v5_1.axi_datamover_stbs_set_nodre;

  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_indet_btt is
    generic (
      
      C_SF_FIFO_DEPTH          : integer range 128 to 8192 := 128;
        -- Sets the depth of the Data FIFO
      
      C_IBTT_XFER_BYTES_WIDTH  : Integer range   1 to   14 := 8;
        -- Sets the width of the sf2pcc_xfer_bytes port
  
      C_STRT_OFFSET_WIDTH      : Integer range   1 to 7 :=  2;
        -- Sets the bit width of the starting address offset port
        -- This should be set to log2(C_MMAP_DWIDTH/C_STREAM_DWIDTH)
        
      C_MAX_BURST_LEN          : Integer range  2 to  256 := 16;
        -- Indicates what is set as the allowed max burst length for AXI4
        -- transfers
      
      C_MMAP_DWIDTH            : Integer range   32  to 1024 := 32;
        -- Indicates the width of the AXI4 MMap data path
      
      C_STREAM_DWIDTH          : Integer range   8 to  1024 := 32;
        -- Indicates the width of the stream data path

      C_ENABLE_SKID_BUF                : string := "11111";
    C_ENABLE_S2MM_TKEEP             : integer range 0 to 1 := 1; 
      C_ENABLE_DRE                     : Integer range 0 to 1 := 0;
      
      C_FAMILY                 : String  := "virtex7"
        -- Specifies the target FPGA Family
      
      );
    port (
      
      -- Clock input --------------------------------------------
      primary_aclk              : in  std_logic;               --
         -- Primary synchronization clock for the Master side  --
         -- interface and internal logic. It is also used      --
         -- for the User interface synchronization when        --
         -- C_STSCMD_IS_ASYNC = 0.                             --
                                                               --
      -- Reset input                                           --
      mmap_reset                : in  std_logic;               --
         -- Reset used for the internal master logic           --
      -----------------------------------------------------------
      
     
      
     -- Write Data Controller I/O  ----------------------------------------------------------
                                                                                           --
      ibtt2wdc_stbs_asserted    : Out  std_logic_vector(7 downto 0);                       --
        -- Indicates the number of asserted WSTRB bits for the                             --
        -- associated output stream data beat                                              --
                                                                                           --
      ibtt2wdc_eop              : Out  std_logic;                                          --
        -- Write End of Packet flag output to Write Data Controller                        --
                                                                                           --
      ibtt2wdc_tdata            : Out  std_logic_vector(C_MMAP_DWIDTH-1 downto 0);         --
        -- Write DATA output to Write Data Controller                                      --
                                                                                           --
      ibtt2wdc_tstrb            : Out  std_logic_vector((C_MMAP_DWIDTH/8)-1 downto 0);     --
        -- Write DATA output to Write Data Controller                                      --
                                                                                           --
      ibtt2wdc_tlast            : Out  std_logic;                                          --
        -- Write LAST output to Write Data Controller                                      --
                                                                                           --
      ibtt2wdc_tvalid           : Out  std_logic;                                          --
        -- Write VALID output to Write Data Controller                                     --
                                                                                           --
      wdc2ibtt_tready           : In  std_logic;                                           --
        -- Write READY input from Write Data Controller                                    --
      ---------------------------------------------------------------------------------------
 
 
     -- DRE Stream In ----------------------------------------------------------------------
                                                                                          --
      dre2ibtt_tvalid           : In  std_logic;                                          --
        -- DRE Stream VALID Output                                                        --
                                                                                          --
      ibtt2dre_tready           : Out Std_logic;                                          --
        -- DRE  Stream READY input                                                        --
                                                                                          --
      dre2ibtt_tdata            : In  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);       --  
        -- DRE  Stream DATA input                                                         --
                                                                                          --
      dre2ibtt_tstrb            : In  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);   --     
        -- DRE  Stream STRB input                                                         --
                                                                                          --
      dre2ibtt_tlast            : In  std_logic;                                          --
        -- DRE  Xfer LAST input                                                           --
                                                                                          --
      dre2ibtt_eop              : In  std_logic;                                          --
        -- DRE  Stream end of Stream packet flag                                          --
      --------------------------------------------------------------------------------------          
  
 
  
      -- Starting Address Offset Input  ------------------------------------------------- 
                                                                                       --
      dre2ibtt_strt_addr_offset : In std_logic_vector(C_STRT_OFFSET_WIDTH-1 downto 0); -- 
        -- Used by Packing logic to set the initial data slice position for the        --
        -- packing operation. Packing is only needed if the MMap and Stream Data       --
        -- widths do not match. This input is sampled on the first valid DRE Stream In -- 
        -- input databeat of a packet.                                                 --
        --                                                                             -- 
      ----------------------------------------------------------------------------------- 
  
               
                
      -- Store and Forward Command Calculator Interface ---------------------------------------
                                                                                             --
      sf2pcc_xfer_valid         : Out std_logic;                                             --
        -- Indicates that at least 1 xfer descriptor entry is in in the XFER_DESCR_FIFO      --
                                                                                             --
      pcc2sf_xfer_ready         : in std_logic;                                              --
        -- Indicates that a full burst of data has been loaded into the data FIFO            --
                                                                                             --
                                                                                             --
      sf2pcc_cmd_cmplt          : Out std_logic;                                             --
        -- Indicates that this is the final xfer for an associated command loaded            --
        -- into the Realigner by the IBTTCC interface                                        --
                                                                                             --
                                                                                             --
      sf2pcc_packet_eop         : Out std_logic;                                             --
        -- Indicates the end of a Stream Packet corresponds to the pending                   --
        -- xfer data described by this xfer descriptor                                       --
                                                                                             --
      sf2pcc_xfer_bytes         : Out std_logic_vector(C_IBTT_XFER_BYTES_WIDTH-1 downto 0)   --
        -- This byte count is used by the IBTTCC for setting up the spawned child            --
        -- commands. The IBTTCC must use this count to generate the appropriate              --
        -- LEN value to put out on the AXI4 Write Addr Channel and the WSTRB on the AXI4     --
        -- Write Data Channel.                                                               --
      -----------------------------------------------------------------------------------------  
 
      );
  
  end entity axi_datamover_indet_btt;
  
  
  architecture implementation of axi_datamover_indet_btt is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    -- Functions
    
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
    
    
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_rnd2pwr_of_2
    --
    -- Function Description:
    --  Rounds the input value up to the nearest power of 2 between
    --  4 and 32. THis is used for sizing the SRL based XD FIFO.
    --
    -------------------------------------------------------------------
    function funct_rnd2pwr_of_2 (input_value : integer) return integer is

      Variable temp_pwr2 : Integer := 128;

    begin

      if (input_value <= 4) then

         temp_pwr2 := 4;

      elsif (input_value <= 8) then

         temp_pwr2 := 8;

      elsif (input_value <= 16) then

         temp_pwr2 := 16;

      else

         temp_pwr2 := 32;

      end if;


      Return (temp_pwr2);

    end function funct_rnd2pwr_of_2;
    -------------------------------------------------------------------
   
     
    
    
    
    
    
    
    -- Constants
    
    Constant LOGIC_LOW                 : std_logic := '0';
    Constant LOGIC_HIGH                : std_logic := '1';
    Constant BITS_PER_BYTE             : integer   := 8;
    
    Constant MMAP2STRM_WIDTH_RATO      : integer := C_MMAP_DWIDTH/C_STREAM_DWIDTH;
    
    Constant STRM_WSTB_WIDTH           : integer := C_STREAM_DWIDTH/BITS_PER_BYTE;
    Constant MMAP_WSTB_WIDTH           : integer := C_MMAP_DWIDTH/BITS_PER_BYTE;
    Constant STRM_STRBS_ASSERTED_WIDTH : integer := clog2(STRM_WSTB_WIDTH)+1;
   
   -- Constant DATA_FIFO_DFACTOR        : integer := 4; -- set buffer to 4 times the Max allowed Burst Length   
   -- Constant DATA_FIFO_DEPTH          : integer := C_MAX_BURST_LEN*DATA_FIFO_DFACTOR;
    Constant DATA_FIFO_DEPTH           : integer := C_SF_FIFO_DEPTH;
    Constant DATA_FIFO_WIDTH           : integer := C_MMAP_DWIDTH+MMAP_WSTB_WIDTH*C_ENABLE_S2MM_TKEEP+2;
    -- Constant DATA_FIFO_WIDTH           : integer := C_MMAP_DWIDTH+STRB_CNTR_WIDTH+2;
    Constant DATA_FIFO_CNT_WIDTH       : integer := clog2(DATA_FIFO_DEPTH)+1;
    
    Constant BURST_CNTR_WIDTH          : integer := clog2(C_MAX_BURST_LEN);
    Constant MAX_BURST_DBEATS          : Unsigned(BURST_CNTR_WIDTH-1 downto 0) :=  
                                         TO_UNSIGNED(C_MAX_BURST_LEN-1, BURST_CNTR_WIDTH);
    
    Constant DBC_ONE                   : Unsigned(BURST_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, BURST_CNTR_WIDTH);
    
    Constant BYTE_CNTR_WIDTH           : integer := C_IBTT_XFER_BYTES_WIDTH;
    
    Constant BYTES_PER_MMAP_DBEAT      : integer := C_MMAP_DWIDTH/BITS_PER_BYTE;
    Constant BYTES_PER_STRM_DBEAT      : integer := C_STREAM_DWIDTH/BITS_PER_BYTE;
    --Constant MAX_BYTE_CNT              : integer := C_MAX_BURST_LEN*BYTES_PER_DBEAT;
    --Constant NUM_STRB_BITS             : integer := BYTES_PER_DBEAT;
    Constant BCNTR_ONE                 : Unsigned(BYTE_CNTR_WIDTH-1 downto 0) := 
                                         TO_UNSIGNED(1, BYTE_CNTR_WIDTH);
    --Constant XD_FIFO_DEPTH             : integer := 16;
    Constant XD_FIFO_DEPTH             : integer := funct_rnd2pwr_of_2(DATA_FIFO_DEPTH/C_MAX_BURST_LEN);
    Constant XD_FIFO_CNT_WIDTH         : integer := clog2(XD_FIFO_DEPTH)+1;
    Constant XD_FIFO_WIDTH             : integer := BYTE_CNTR_WIDTH+2;
    
    Constant MMAP_STBS_ASSERTED_WIDTH  : integer := 8;
    Constant SKIDBUF2WDC_DWIDTH        : integer := C_MMAP_DWIDTH + MMAP_STBS_ASSERTED_WIDTH;
    Constant SKIDBUF2WDC_STRB_WIDTH    : integer := SKIDBUF2WDC_DWIDTH/BITS_PER_BYTE;
    --Constant NUM_ZEROS_WIDTH         : integer := MMAP_STBS_ASSERTED_WIDTH;
    
    Constant STRB_CNTR_WIDTH           : integer := MMAP_STBS_ASSERTED_WIDTH;
    
    
    
    
    
    
    -- Signals
    
    signal sig_wdc2ibtt_tready        : std_logic := '0';
    signal sig_ibtt2wdc_tvalid        : std_logic := '0';
    signal sig_ibtt2wdc_tdata         : std_logic_vector(C_MMAP_DWIDTH-1 downto 0) := (others => '0');
    signal sig_ibtt2wdc_tstrb         : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
    signal sig_ibtt2wdc_tlast         : std_logic := '0';
    signal sig_ibtt2wdc_eop           : std_logic := '0';
    signal sig_push_data_fifo         : std_logic := '0';
    signal sig_pop_data_fifo          : std_logic := '0';
    signal sig_data_fifo_data_in      : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_data_out     : std_logic_vector(DATA_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_dvalid       : std_logic := '0';
    signal sig_data_fifo_full         : std_logic := '0';
    signal sig_data_fifo_rd_cnt       : std_logic_vector(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_data_fifo_wr_cnt       : std_logic_vector(DATA_FIFO_CNT_WIDTH-1 downto 0) := (others => '0');
    signal sig_push_xd_fifo           : std_logic := '0';
    signal sig_pop_xd_fifo            : std_logic := '0';
    signal sig_xd_fifo_data_in        : std_logic_vector(XD_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_xd_fifo_data_out       : std_logic_vector(XD_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_xd_fifo_dvalid         : std_logic := '0';
    signal sig_xd_fifo_full           : std_logic := '0';
    signal sig_tmp           : std_logic := '0';
    signal sig_strm_in_ready          : std_logic := '0';
    signal sig_good_strm_dbeat        : std_logic := '0';
    signal sig_good_tlast_dbeat       : std_logic := '0';
    signal sig_dre2ibtt_tlast_reg     : std_logic := '0';
    signal sig_dre2ibtt_eop_reg       : std_logic := '0';
    signal sig_burst_dbeat_cntr       : Unsigned(BURST_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_incr_dbeat_cntr        : std_logic := '0';
    signal sig_clr_dbeat_cntr         : std_logic := '0';
    signal sig_clr_dbc_reg            : std_logic := '0';
    signal sig_dbc_max                : std_logic := '0';
    signal sig_pcc2ibtt_xfer_ready    : std_logic := '0';
    signal sig_byte_cntr              : unsigned(BYTE_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_byte_cntr_incr_value   : unsigned(BYTE_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_ld_byte_cntr           : std_logic := '0';
    signal sig_incr_byte_cntr         : std_logic := '0';
    signal sig_clr_byte_cntr          : std_logic := '0';
    signal sig_fifo_tstrb_out         : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
    signal sig_num_ls_zeros           : integer range 0 to STRM_WSTB_WIDTH := 0;
    signal sig_ls_assert_found        : std_logic := '0';
    signal sig_num_ms_zeros           : integer range 0 to STRM_WSTB_WIDTH := 0;
    signal sig_ms_assert_found        : std_logic := '0';
   -- signal sig_num_zeros              : unsigned(NUM_ZEROS_WIDTH-1 downto 0) := (others => '0');
   -- signal sig_num_ones               : unsigned(NUM_ZEROS_WIDTH-1 downto 0) := (others => '0');
    signal sig_stbs2sfcc_asserted     : std_logic_vector(MMAP_STBS_ASSERTED_WIDTH-1 downto 0) := (others => '0');
    signal sig_stbs2wdc_asserted      : std_logic_vector(MMAP_STBS_ASSERTED_WIDTH-1 downto 0) := (others => '0');
    signal sig_ibtt2wdc_stbs_asserted : std_logic_vector(MMAP_STBS_ASSERTED_WIDTH-1 downto 0) := (others => '0');
    signal sig_skidbuf_in_tready      : std_logic := '0';
    signal sig_skidbuf_in_tvalid      : std_logic := '0';
    signal sig_skidbuf_in_tdata       : std_logic_vector(SKIDBUF2WDC_DWIDTH-1 downto 0) := (others => '0');
    signal sig_skidbuf_in_tstrb       : std_logic_vector(SKIDBUF2WDC_STRB_WIDTH-1 downto 0) := (others => '0');
    signal sig_skidbuf_in_tlast       : std_logic := '0';
    signal sig_skidbuf_in_eop         : std_logic := '0';
    signal sig_skidbuf_out_tready     : std_logic := '0';
    signal sig_skidbuf_out_tvalid     : std_logic := '0';
    signal sig_skidbuf_out_tdata      : std_logic_vector(SKIDBUF2WDC_DWIDTH-1 downto 0) := (others => '0');
    signal sig_skidbuf_out_tstrb      : std_logic_vector(SKIDBUF2WDC_STRB_WIDTH-1 downto 0) := (others => '0');
    signal sig_skidbuf_out_tlast      : std_logic := '0';
    signal sig_skidbuf_out_eop        : std_logic := '0';

    signal sig_enable_dbcntr          : std_logic := '0';
    signal sig_good_fifo_write        : std_logic := '0';
    
    
    
    
  begin --(architecture implementation)
  
   -- Write Data Controller I/O 
   sig_wdc2ibtt_tready       <= wdc2ibtt_tready      ;
   
   ibtt2wdc_tvalid           <= sig_ibtt2wdc_tvalid  ;
   ibtt2wdc_tdata            <= sig_ibtt2wdc_tdata   ; 
   ibtt2wdc_tstrb            <= sig_ibtt2wdc_tstrb   ;
   ibtt2wdc_tlast            <= sig_ibtt2wdc_tlast   ;
   ibtt2wdc_eop              <= sig_ibtt2wdc_eop     ;
   
   ibtt2wdc_stbs_asserted    <= sig_ibtt2wdc_stbs_asserted;
   
   
    
   -- PCC I/O 
   sf2pcc_xfer_valid         <= sig_xd_fifo_dvalid;
   sig_pcc2ibtt_xfer_ready   <= pcc2sf_xfer_ready;
  
  
  
   
   sf2pcc_packet_eop         <= sig_xd_fifo_data_out(BYTE_CNTR_WIDTH+1); 
   sf2pcc_cmd_cmplt          <= sig_xd_fifo_data_out(BYTE_CNTR_WIDTH);
   sf2pcc_xfer_bytes         <= sig_xd_fifo_data_out(BYTE_CNTR_WIDTH-1 downto 0); 
 
    
    
    -- DRE Stream In 
    ibtt2dre_tready          <= sig_strm_in_ready;
    
    -- sig_strm_in_ready        <= not(sig_xd_fifo_full) and
    --                             not(sig_data_fifo_full);
    
    sig_good_strm_dbeat      <= dre2ibtt_tvalid and
                                sig_strm_in_ready;
                               
    sig_good_tlast_dbeat     <= sig_good_strm_dbeat and
                                dre2ibtt_tlast;
    
    
  
 -- Burst Packet Counter Logic ------------------------------- 
 
 
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_DBC_STUFF
    --
    -- Process Description:
    -- Just a register for data beat counter signals.
    --
    -------------------------------------------------------------
    REG_DBC_STUFF : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then

              sig_dre2ibtt_tlast_reg    <= '0';
              sig_dre2ibtt_eop_reg      <= '0';
              sig_clr_dbc_reg           <= '0';
              
            else

              sig_dre2ibtt_tlast_reg    <= dre2ibtt_tlast;
              sig_dre2ibtt_eop_reg      <= dre2ibtt_eop;
              sig_clr_dbc_reg           <= sig_clr_dbeat_cntr;

            end if; 
         end if;       
       end process REG_DBC_STUFF; 
  
 
      --        sig_clr_dbc_reg           <= sig_clr_dbeat_cntr;
 
    
    -- Increment the dataBeat counter on a data fifo wide
    -- load condition. If packer logic is enabled, this will
    -- only occur when a full fifo data width has been collected
    -- from the Stream input.
    sig_incr_dbeat_cntr      <= sig_good_strm_dbeat and
                                sig_enable_dbcntr;
  
    -- Check to see if a max burst len of databeats have been
    -- loaded into the FIFO
    sig_dbc_max <= '1' 
     when (sig_burst_dbeat_cntr = MAX_BURST_DBEATS)
     Else '0';
  
    -- Start the counter over at a max burst len boundary or at  
    -- the end of the packet.
    sig_clr_dbeat_cntr <= '1' 
     when (sig_dbc_max          = '1' and
           sig_good_strm_dbeat  = '1' and
           sig_enable_dbcntr    = '1') or
          (sig_good_tlast_dbeat = '1' and
           sig_enable_dbcntr    = '1')
     Else '0';
  
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_DBC_CMTR
    --
    -- Process Description:
    -- The Databeat Counter keeps track of how many databeats have 
    -- been loaded into the Data FIFO. When a max burst worth of
    -- databeats have been loaded (or a TLAST encountered), the 
    -- XD FIFO can be loaded with a transfer data set to be sent
    -- to the IBTTCC.
    --
    -------------------------------------------------------------
    IMP_DBC_CMTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset  = '1' or
                sig_clr_dbeat_cntr = '1') then 

              sig_burst_dbeat_cntr <= (others => '0');
              
            elsif (sig_incr_dbeat_cntr = '1') then

              sig_burst_dbeat_cntr <= sig_burst_dbeat_cntr + DBC_ONE;
              
            else
              null;  -- hold current value
            end if; 
         end if;       
       end process IMP_DBC_CMTR; 
 
 
     
     
 
 
 
 
     -----  Byte Counter Logic -----------------------------------------------
 
  
  
    sig_clr_byte_cntr        <= sig_clr_dbc_reg and 
                                not(sig_good_strm_dbeat);
    
 
    sig_ld_byte_cntr         <= sig_clr_dbc_reg and 
                                sig_good_strm_dbeat;
    
    sig_incr_byte_cntr       <= sig_good_strm_dbeat;
    
    
    sig_byte_cntr_incr_value <= RESIZE(UNSIGNED(sig_stbs2sfcc_asserted), BYTE_CNTR_WIDTH);  
    
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_BYTE_CMTR
    --
    -- Process Description:
    -- Keeps a running byte count per burst packet loaded into the 
    -- xfer FIFO. It is based on the strobes set on the incoming
    -- Stream dbeat.
    --
    -------------------------------------------------------------
    IMP_BYTE_CMTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset        = '1' or
                sig_clr_byte_cntr = '1') then 

              sig_byte_cntr <= (others => '0');
              
            elsif (sig_ld_byte_cntr = '1') then

              sig_byte_cntr <= sig_byte_cntr_incr_value;
              
            elsif (sig_incr_byte_cntr = '1') then

              sig_byte_cntr <= sig_byte_cntr + sig_byte_cntr_incr_value;
              
            else
              null;  -- hold current value
            end if; 
         end if;       
       end process IMP_BYTE_CMTR; 
 
 
     
 
     
   
        
    ------------------------------------------------------------
    -- Instance: I_IBTTCC_STBS_SET 
    --
    -- Description:
    --   Instance of the asserted strobe counter for the IBTTCC
    -- interface.   
    --
    ------------------------------------------------------------

SAME_WIDTH_NO_DRE : if (C_ENABLE_DRE = 0 and (C_STREAM_DWIDTH = C_MMAP_DWIDTH)) generate
begin 

    I_IBTTCC_STBS_SET : entity axi_datamover_v5_1.axi_datamover_stbs_set_nodre
    generic map (
  
      C_STROBE_WIDTH      =>  STRM_WSTB_WIDTH   
  
      )
    port map (
  
      tstrb_in            =>  dre2ibtt_tstrb,
      num_stbs_asserted   =>  sig_stbs2sfcc_asserted  -- 8 bit wide slv
  
      );
  
end generate SAME_WIDTH_NO_DRE;    
    
   
DIFF_WIDTH_OR_DRE : if (C_ENABLE_DRE /= 0 or (C_STREAM_DWIDTH /= C_MMAP_DWIDTH)) generate
begin 

    I_IBTTCC_STBS_SET : entity axi_datamover_v5_1.axi_datamover_stbs_set
    generic map (
  
      C_STROBE_WIDTH      =>  STRM_WSTB_WIDTH   
  
      )
    port map (
  
      tstrb_in            =>  dre2ibtt_tstrb,
      num_stbs_asserted   =>  sig_stbs2sfcc_asserted  -- 8 bit wide slv
  
      );
  
end generate DIFF_WIDTH_OR_DRE;    
 
 


 
     
 
    -----  Xfer Descriptor FIFO Logic -----------------------------------------------
     
   
    sig_push_xd_fifo    <= sig_clr_dbc_reg ;
    
    sig_pop_xd_fifo     <= sig_pcc2ibtt_xfer_ready and
                           sig_xd_fifo_dvalid ;
   
    sig_xd_fifo_data_in <= sig_dre2ibtt_eop_reg   &         -- (TLAST for the input Stream)
                           sig_dre2ibtt_tlast_reg &         -- (TLAST for the IBTTCC command)
                           std_logic_vector(sig_byte_cntr); -- Number of bytes in this xfer
                              
                              
                                
    ------------------------------------------------------------
    -- Instance: I_XD_FIFO 
    --
    -- Description:
    -- Implement the Transfer Desciptor (XD) FIFO. This FIFO holds
    -- the individual child command xfer descriptors used by the
    -- IBTTCC to generate the commands sent to the Address Cntlr and
    -- the Data Cntlr.    
    --
    ------------------------------------------------------------
    I_XD_FIFO : entity axi_datamover_v5_1.axi_datamover_sfifo_autord
    generic map (

    C_DWIDTH                =>  XD_FIFO_WIDTH        ,  
    C_DEPTH                 =>  XD_FIFO_DEPTH        ,  
    C_DATA_CNT_WIDTH        =>  XD_FIFO_CNT_WIDTH    ,  
    C_NEED_ALMOST_EMPTY     =>  0                    ,  
    C_NEED_ALMOST_FULL      =>  1                    ,  
    C_USE_BLKMEM            =>  0                    ,  
    C_FAMILY                =>  C_FAMILY                

      )
    port map (

   -- Inputs 
    SFIFO_Sinit             =>  mmap_reset            , 
    SFIFO_Clk               =>  primary_aclk          , 
    SFIFO_Wr_en             =>  sig_push_xd_fifo      , 
    SFIFO_Din               =>  sig_xd_fifo_data_in   , 
    SFIFO_Rd_en             =>  sig_pop_xd_fifo       , 
    SFIFO_Clr_Rd_Data_Valid =>  LOGIC_LOW             , 
    
   -- Outputs
    SFIFO_DValid            =>  sig_xd_fifo_dvalid    , 
    SFIFO_Dout              =>  sig_xd_fifo_data_out  , 
    SFIFO_Full              =>  sig_xd_fifo_full      , 
    SFIFO_Empty             =>  open                  , 
    SFIFO_Almost_full       =>  sig_tmp                  , 
    SFIFO_Almost_empty      =>  open                  , 
    SFIFO_Rd_count          =>  open                  ,  
    SFIFO_Rd_count_minus1   =>  open                  ,  
    SFIFO_Wr_count          =>  open                  ,  
    SFIFO_Rd_ack            =>  open                    

    );


 
 
 
 
 
 
 
 
 
 
 
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
    
        
         -- The data beat counter is always enabled when the packer
         -- is omitted.
         sig_enable_dbcntr     <= '1'; 
         
         sig_good_fifo_write   <= sig_good_strm_dbeat;
         
         sig_strm_in_ready     <= not(sig_xd_fifo_full) and
                                  not(sig_data_fifo_full) and
                                  not (sig_tmp);
         
  
GEN_S2MM_TKEEP_ENABLE5 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin

         -- Concatonate the Stream inputs into the single FIFO data 
         -- word input value 
         sig_data_fifo_data_in <= dre2ibtt_eop     &  -- end of packet marker
                                  dre2ibtt_tlast   &  -- Tlast marker
                                  dre2ibtt_tstrb   &  -- TSTRB Value
                                  dre2ibtt_tdata;     -- data value


end generate GEN_S2MM_TKEEP_ENABLE5;

GEN_S2MM_TKEEP_DISABLE5 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin
         -- Concatonate the Stream inputs into the single FIFO data 
         -- word input value 
         sig_data_fifo_data_in <= dre2ibtt_eop     &  -- end of packet marker
                                  dre2ibtt_tlast   &  -- Tlast marker
                                  --dre2ibtt_tstrb   &  -- TSTRB Value
                                  dre2ibtt_tdata;     -- data value
end generate GEN_S2MM_TKEEP_DISABLE5;


           
       end generate OMIT_PACKING;
     
     
    
    
  
  
  
  
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: INCLUDE_PACKING
    --
    -- If Generate Description:
    --    Includes packing logic in the IBTT Store and Forward 
    -- module. The MMap Data bus is wider than the Stream width.
    --
    ------------------------------------------------------------
    INCLUDE_PACKING : if (C_MMAP_DWIDTH > C_STREAM_DWIDTH) generate
    
      
      Constant TLAST_WIDTH           : integer := 1; -- bit
      Constant EOP_WIDTH             : integer := 1; -- bit
      
      
      Constant DATA_SLICE_WIDTH      : integer := C_STREAM_DWIDTH;
      Constant STRB_SLICE_WIDTH      : integer := STRM_WSTB_WIDTH;
      
      Constant FLAG_SLICE_WIDTH      : integer := TLAST_WIDTH + 
                                                  EOP_WIDTH;
      
      
      Constant OFFSET_CNTR_WIDTH     : integer := funct_get_cntr_width(MMAP2STRM_WIDTH_RATO);
      
      Constant OFFSET_CNT_ONE        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(1, OFFSET_CNTR_WIDTH);
      
      Constant OFFSET_CNT_MAX        : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := 
                                       TO_UNSIGNED(MMAP2STRM_WIDTH_RATO-1, OFFSET_CNTR_WIDTH);
      
      
      
      
      -- Types -----------------------------------------------------------------------------
      type lsig_data_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(DATA_SLICE_WIDTH-1 downto 0);

      type lsig_strb_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(STRB_SLICE_WIDTH-1 downto 0);

      type lsig_flag_slice_type is array(MMAP2STRM_WIDTH_RATO-1 downto 0) of
                    std_logic_vector(FLAG_SLICE_WIDTH-1 downto 0);


       
      -- local signals
      
      signal lsig_data_slice_reg       : lsig_data_slice_type;
      signal lsig_strb_slice_reg       : lsig_strb_slice_type;
      signal lsig_flag_slice_reg       : lsig_flag_slice_type;
      
       
      signal lsig_reg_segment          : std_logic_vector(DATA_SLICE_WIDTH-1 downto 0)   := (others => '0');
      signal lsig_segment_ld           : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      signal lsig_segment_clr          : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      
      signal lsig_0ffset_to_to_use     : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := (others => '0');
      
      signal lsig_0ffset_cntr          : unsigned(OFFSET_CNTR_WIDTH-1 downto 0) := (others => '0');
      signal lsig_ld_offset            : std_logic := '0';
      signal lsig_incr_offset          : std_logic := '0';
      signal lsig_offset_cntr_eq_max   : std_logic := '0';
      
      signal lsig_combined_data        : std_logic_vector(C_MMAP_DWIDTH-1 downto 0) := (others => '0');
      signal lsig_combined_strb        : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
      
      
      signal lsig_tlast_or             : std_logic := '0';
      signal lsig_eop_or               : std_logic := '0';
      
      signal lsig_partial_tlast_or     : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      signal lsig_partial_eop_or       : std_logic_vector(MMAP2STRM_WIDTH_RATO-1 downto 0) := (others => '0');
      
      signal lsig_packer_full          : std_logic := '0';
      signal lsig_packer_empty         : std_logic := '0';
      signal lsig_set_packer_full      : std_logic := '0';
      signal lsig_good_push2fifo       : std_logic := '0';
      signal lsig_first_dbeat          : std_logic := '0';
        
        
      begin
    

       -- Generate the stream ready
       sig_strm_in_ready       <= not(sig_xd_fifo_full) and
                                  not(sig_tmp) and
                                  (not(lsig_packer_full) or
                                  lsig_good_push2fifo) ;
    
        
        
       -- Enable the Data Beat counter when the packer is 
       -- going full
       sig_enable_dbcntr       <= lsig_set_packer_full; 

       
       -- Assign the flag indicating that a fifo write is going
       -- to occur at the next rising clock edge.
       sig_good_fifo_write     <=  lsig_good_push2fifo;
       
GEN_S2MM_TKEEP_ENABLE6 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin
     -- Format the composite FIFO input data word
       sig_data_fifo_data_in   <= lsig_eop_or        &   -- MS Bit
                                  lsig_tlast_or      &
                                  lsig_combined_strb &
                                  lsig_combined_data  ;  -- LS Bits
        

 
end generate GEN_S2MM_TKEEP_ENABLE6;

GEN_S2MM_TKEEP_DISABLE6 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin
     -- Format the composite FIFO input data word
       sig_data_fifo_data_in   <= lsig_eop_or        &   -- MS Bit
                                  lsig_tlast_or      &
                                  --lsig_combined_strb &
                                  lsig_combined_data  ;  -- LS Bits
        


end generate GEN_S2MM_TKEEP_DISABLE6;

       
         
       -- Generate a flag indicating a write to the DataFIFO 
       -- is going to complete 
       lsig_good_push2fifo    <=  lsig_packer_full and
                                  not(sig_data_fifo_full);
       
       -- Generate the control that loads the starting address
       -- offset for the next input packet
       lsig_ld_offset          <= lsig_first_dbeat and
                                  sig_good_strm_dbeat;
                                  
       -- Generate the control for incrementing the offset counter
       lsig_incr_offset        <= sig_good_strm_dbeat;
       
       
       -- Generate a flag indicating the packer input register
       -- array is full or has loaded the last data beat of
       -- the input paket
       lsig_set_packer_full    <=  sig_good_strm_dbeat  and
                                   (dre2ibtt_tlast      or 
                                    lsig_offset_cntr_eq_max);

       -- Check to see if the offset counter has reached its max
       -- value
       lsig_offset_cntr_eq_max <=  '1'
         --when  (lsig_0ffset_cntr = OFFSET_CNT_MAX)
         when  (lsig_0ffset_to_to_use = OFFSET_CNT_MAX)
         Else '0';
       
       
       -- Mux between the input start offset and the offset counter
       -- output to use for the packer slice load control.  
       lsig_0ffset_to_to_use <= UNSIGNED(dre2ibtt_strt_addr_offset) 
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
       IMP_OFFSET_LD_MARKER : process (primary_aclk)
         begin
           if (primary_aclk'event and primary_aclk = '1') then
              if (mmap_reset = '1') then
       
                lsig_first_dbeat <= '1';
       
              elsif (sig_good_strm_dbeat = '1' and
                     dre2ibtt_tlast      = '0') then
       
                lsig_first_dbeat <= '0';
       
              Elsif (sig_good_strm_dbeat = '1' and
                     dre2ibtt_tlast      = '1') Then
              
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
       IMP_OFFSET_CNTR : process (primary_aclk)
         begin
           if (primary_aclk'event and primary_aclk = '1') then
              if (mmap_reset = '1') then
       
                lsig_0ffset_cntr <= (others => '0');
       
              Elsif (lsig_ld_offset = '1') Then
              
               lsig_0ffset_cntr <= UNSIGNED(dre2ibtt_strt_addr_offset) + OFFSET_CNT_ONE;
              
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
       IMP_PACK_REG_FULL : process (primary_aclk)
         begin
           if (primary_aclk'event and primary_aclk = '1') then
              if (mmap_reset = '1') then
       
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
           when (sig_good_strm_dbeat = '1' and
                TO_INTEGER(lsig_0ffset_to_to_use) = slice_index)
           Else '0';
         
         
        
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_DATA_SLICE
         --
         -- Process Description:
         --   Implement a data register slice abd Strobe register slice 
         -- for the packer (upsizer). 
         --
         -------------------------------------------------------------
         IMP_DATA_SLICE : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
               if (mmap_reset = '1') then
        
                 lsig_data_slice_reg(slice_index) <= (others => '0');
                 lsig_strb_slice_reg(slice_index) <= (others => '0');
                 
                 
               elsif (lsig_segment_ld(slice_index) = '1') then
        
                 lsig_data_slice_reg(slice_index) <= dre2ibtt_tdata;
                 lsig_strb_slice_reg(slice_index) <= dre2ibtt_tstrb;
        
               -- optional clear of slice reg 
               elsif (lsig_segment_ld(slice_index) = '0' and
                      lsig_good_push2fifo          = '1') then

                 lsig_data_slice_reg(slice_index) <= (others => '0');
                 lsig_strb_slice_reg(slice_index) <= (others => '0');
        
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
         IMP_FLAG_SLICE : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
               if (mmap_reset = '1') then
        
                 lsig_flag_slice_reg(slice_index) <= (others => '0');
        
               elsif (lsig_segment_ld(slice_index) = '1') then
        
                 lsig_flag_slice_reg(slice_index) <= dre2ibtt_tlast & -- bit 1
                                                     dre2ibtt_eop;    -- bit 0
               
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
       lsig_tlast_or            <= lsig_partial_tlast_or(MMAP2STRM_WIDTH_RATO-1) ;
       lsig_eop_or              <= lsig_partial_eop_or(MMAP2STRM_WIDTH_RATO-1);
       
       lsig_partial_tlast_or(0) <= lsig_flag_slice_reg(0)(1);
       lsig_partial_eop_or(0)   <= lsig_flag_slice_reg(0)(0);
       

       
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
     
          lsig_partial_tlast_or(slice_index) <= lsig_partial_tlast_or(slice_index-1) or
                                                --lsig_partial_tlast_or(slice_index);
                                                lsig_flag_slice_reg(slice_index)(1);
                                                  
                                                  
                                                  
                                                  
          lsig_partial_eop_or(slice_index)   <= lsig_partial_eop_or(slice_index-1) or
                                                --lsig_partial_eop_or(slice_index); 
                                                lsig_flag_slice_reg(slice_index)(0);
  
  
       end generate DO_FLAG_OR;
  
       
  
       
       

     
        
        
     
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: DO_DATA_COMBINER
       --
       -- For Generate Description:
       --   Combines the Data Slice register and Strobe slice register
       -- outputs into a single data and single strobe vector used for 
       -- input data to the Data FIFO.
       --
       --
       ------------------------------------------------------------
       DO_DATA_COMBINER : for slice_index in 1 to MMAP2STRM_WIDTH_RATO generate
       
       begin
        
         lsig_combined_data((slice_index*DATA_SLICE_WIDTH)-1 downto 
                            (slice_index-1)*DATA_SLICE_WIDTH) <=
                            lsig_data_slice_reg(slice_index-1);
        
         
         lsig_combined_strb((slice_index*STRB_SLICE_WIDTH)-1 downto 
                            (slice_index-1)*STRB_SLICE_WIDTH) <=
                            lsig_strb_slice_reg(slice_index-1);
        
        
       end generate DO_DATA_COMBINER;
     
     
     
     
     
     
     
       
      end generate INCLUDE_PACKING;
     
     
    
    
  
  
  
  
  
  
  
  
  
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
 -- Data FIFO Logic ------------------------------------------
 
     --sig_push_data_fifo <= sig_good_strm_dbeat;
     sig_push_data_fifo <= sig_good_fifo_write;
     
     
     
     sig_pop_data_fifo  <= sig_skidbuf_in_tready and 
                           sig_data_fifo_dvalid;
     
     
     
    -- -- Concatonate the Stream inputs into the single FIFO data in value 
    --  sig_data_fifo_data_in <= dre2ibtt_eop   &  -- end of packet marker
    --                           dre2ibtt_tlast &
    --                           dre2ibtt_tstrb & 
    --                           dre2ibtt_tdata;
 
                                                     
    ------------------------------------------------------------
    -- Instance: I_DATA_FIFO 
    --
    -- Description:
    --  Implements the Store and Forward data FIFO   
    --
    ------------------------------------------------------------
    I_DATA_FIFO : entity axi_datamover_v5_1.axi_datamover_sfifo_autord
    generic map (

      C_DWIDTH                =>  DATA_FIFO_WIDTH       ,  
      C_DEPTH                 =>  DATA_FIFO_DEPTH       ,  
      C_DATA_CNT_WIDTH        =>  DATA_FIFO_CNT_WIDTH   ,  
      C_NEED_ALMOST_EMPTY     =>  0                     ,  
      C_NEED_ALMOST_FULL      =>  0                     ,  
      C_USE_BLKMEM            =>  1                     ,  
      C_FAMILY                =>  C_FAMILY                 

      )
    port map (

     -- Inputs 
      SFIFO_Sinit             =>  mmap_reset             , 
      SFIFO_Clk               =>  primary_aclk           , 
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
      SFIFO_Rd_count          =>  sig_data_fifo_rd_cnt   ,  
      SFIFO_Rd_count_minus1   =>  open                   ,  
      SFIFO_Wr_count          =>  sig_data_fifo_wr_cnt   ,  
      SFIFO_Rd_ack            =>  open                     

    );



 
 
    
    
    
 
 
    -------------------------------------------------------------------------
    ----------------  Asserted TSTRB calculation logic  --------------------- 
    -------------------------------------------------------------------------
     
GEN_S2MM_TKEEP_ENABLE7 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin

    
     -- Rip the write strobe value from the FIFO output data
     sig_fifo_tstrb_out   <=  sig_data_fifo_data_out(DATA_FIFO_WIDTH-3 downto 
                                                     C_MMAP_DWIDTH);
                                

end generate GEN_S2MM_TKEEP_ENABLE7;

GEN_S2MM_TKEEP_DISBALE7 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin

     sig_fifo_tstrb_out   <= (others => '1');

end generate GEN_S2MM_TKEEP_DISBALE7;


   
        
    ------------------------------------------------------------
    -- Instance: I_WDC_STBS_SET 
    --
    -- Description:
    --   Instance of the asserted strobe counter for the WDC
    -- interface.   
    --
    ------------------------------------------------------------
SAME_WIDTH_NO_DRE_WDC : if (C_ENABLE_DRE = 0 and (C_STREAM_DWIDTH = C_MMAP_DWIDTH)) generate
begin
 

     I_WDC_STBS_SET : entity axi_datamover_v5_1.axi_datamover_stbs_set_nodre
     generic map (
    
       C_STROBE_WIDTH      =>  MMAP_WSTB_WIDTH   
    
       )
     port map (
    
       tstrb_in            =>  sig_fifo_tstrb_out,
       num_stbs_asserted   =>  sig_stbs2wdc_asserted
    
       );
    
end generate SAME_WIDTH_NO_DRE_WDC;    
    
   
DIFF_WIDTH_OR_DRE_WDC : if (C_ENABLE_DRE /= 0 or (C_STREAM_DWIDTH /= C_MMAP_DWIDTH)) generate
begin
 

     I_WDC_STBS_SET : entity axi_datamover_v5_1.axi_datamover_stbs_set
     generic map (
    
       C_STROBE_WIDTH      =>  MMAP_WSTB_WIDTH   
    
       )
     port map (
    
       tstrb_in            =>  sig_fifo_tstrb_out,
       num_stbs_asserted   =>  sig_stbs2wdc_asserted
    
       );
    
end generate DIFF_WIDTH_OR_DRE_WDC;    
    
    
     
     
    -------------------------------------------------------------------------
    -------  Isolation Skid Buffer Logic (needed for Fmax timing) ----------- 
    -------------------------------------------------------------------------
     
     
     -- Skid Buffer output assignments -----------
     sig_skidbuf_out_tready     <=  sig_wdc2ibtt_tready;
     sig_ibtt2wdc_tvalid        <=  sig_skidbuf_out_tvalid;
     sig_ibtt2wdc_tdata         <=  sig_skidbuf_out_tdata(C_MMAP_DWIDTH-1 downto 0) ;
     sig_ibtt2wdc_tstrb         <=  sig_skidbuf_out_tstrb(MMAP_WSTB_WIDTH-1 downto 0) ;
     sig_ibtt2wdc_tlast         <=  sig_skidbuf_out_tlast ;
                                                      
     -- Rip the EOP marker from the MS bit of the skid output strobes
     sig_ibtt2wdc_eop           <=  sig_skidbuf_out_tstrb(MMAP_WSTB_WIDTH) ;
     
     -- Rip the upper 8 bits of the skid output data for the strobes asserted value
     sig_ibtt2wdc_stbs_asserted <=  sig_skidbuf_out_tdata(SKIDBUF2WDC_DWIDTH-1 downto 
                                                          C_MMAP_DWIDTH);
     
     
    
     
     
     -- Skid Buffer input assignments -----------
    
     sig_skidbuf_in_tvalid <= sig_data_fifo_dvalid;
    
    
    
     sig_skidbuf_in_eop    <= sig_data_fifo_data_out(DATA_FIFO_WIDTH-1);
    
    
     
     sig_skidbuf_in_tlast  <= sig_data_fifo_data_out(DATA_FIFO_WIDTH-2);
     
    
     -- Steal the extra input strobe bit and use it for the EOP marker
----     sig_skidbuf_in_tstrb  <= sig_skidbuf_in_eop &
----                              sig_data_fifo_data_out(DATA_FIFO_WIDTH-3 downto 
----                                                     C_MMAP_DWIDTH);
---- 

     sig_skidbuf_in_tstrb  <= sig_skidbuf_in_eop &
                            sig_fifo_tstrb_out;
    
     -- Insert the Strobes Asserted count in the extra (MS) data byte 
     -- for the skid buffer
     sig_skidbuf_in_tdata <= sig_stbs2wdc_asserted &
                             sig_data_fifo_data_out(C_MMAP_DWIDTH-1 downto 0);
 

ENABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(2) = '1' generate
begin 


 
     ------------------------------------------------------------
     -- Instance: I_INDET_BTT_SKID_BUF 
     --
     -- Description:
     --   Instance for the Store and Forward isolation Skid Buffer
     -- which is required to achieve Fmax timing. Note that this 
     -- skid buffer is 1 byte wider than the stream data width to
     -- allow for the asserted strobes count to be passed through 
     -- it. The EOP marker is inserted in the extra strobe slot.
     --
     ------------------------------------------------------------
      I_INDET_BTT_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
      generic map (
         
        C_WDATA_WIDTH  =>  SKIDBUF2WDC_DWIDTH       
    
        )
      port map (
    
        -- System Ports
        aclk         =>  primary_aclk           ,  
        arst         =>  mmap_reset             ,  
     
        -- Shutdown control (assert for 1 clk pulse)
        skid_stop    =>  LOGIC_LOW              ,  
     
        -- Slave Side (Stream Data Input) 
        s_valid      =>  sig_skidbuf_in_tvalid  ,  
        s_ready      =>  sig_skidbuf_in_tready  ,  
        s_data       =>  sig_skidbuf_in_tdata   ,  
        s_strb       =>  sig_skidbuf_in_tstrb   ,  
        s_last       =>  sig_skidbuf_in_tlast   ,  

        -- Master Side (Stream Data Output 
        m_valid      =>  sig_skidbuf_out_tvalid ,  
        m_ready      =>  sig_skidbuf_out_tready ,  
        m_data       =>  sig_skidbuf_out_tdata  ,  
        m_strb       =>  sig_skidbuf_out_tstrb  ,  
        m_last       =>  sig_skidbuf_out_tlast     
    
        );
    
 
 
end generate ENABLE_AXIS_SKID;
  
    
DISABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(2) = '0' generate
begin 

     sig_skidbuf_out_tvalid <=   sig_skidbuf_in_tvalid;
     sig_skidbuf_in_tready  <=   sig_skidbuf_out_tready   ; 
     sig_skidbuf_out_tdata  <=   sig_skidbuf_in_tdata ;
     sig_skidbuf_out_tstrb  <=   sig_skidbuf_in_tstrb ;
     sig_skidbuf_out_tlast  <=   sig_skidbuf_in_tlast ;


end generate DISABLE_AXIS_SKID; 
 
 
 
 
  
  
  end implementation;
